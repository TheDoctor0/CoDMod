#include <amxmodx>
#include <sqlx>
#include <hamsandwich>
#include <cod>

#define PLUGIN "CoD Register System"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define SETINFO "_csrpass"
#define CONFIG "csrpass"

#define TASK_PASSWORD 94328

#define is_user_valid(%1) (1 <= %1 <= gMaxPlayers)

new szPlayerName[33][33], szPlayerSafeName[33][33], szPlayerPassword[33][33], szPlayerTempPassword[33][33], 
szTemp[512], iPasswordFail[33], iStatus[33], iLoaded, iAutoLogin, gMaxPlayers, gHudSync, Handle:hHookSql;

enum { NOT_REGISTERED, NOT_LOGGED, LOGGED, GUEST };

enum { LOGIN, REGISTER_STEP1, REGISTER_STEP2 }

stock const FIRST_JOIN_MSG[] = "#Team_Select";
stock const FIRST_JOIN_MSG_SPEC[] = "#Team_Select_Spect";
stock const INGAME_JOIN_MSG[] = "#IG_Team_Select";
stock const INGAME_JOIN_MSG_SPEC[] = "#IG_Team_Select_Spect";

new const szStatus[][] = { "Niezarejestrowany", "Niezalogowany", "Zalogowany", "Gosc" };

new const szCommandPassword[][] = { "konto", "say /haslo", "say_team /haslo", "say /password", "say_team /password", "say /konto", "say_team /konto", "say /account", "say_team /account", "haslo" };

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_cvar("register_system_sql_host", "sql.pukawka.pl", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("register_system_sql_user", "262947", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("register_system_sql_pass", "v@+27KDFCgPHy#", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("register_system_sql_db", "262947_registersystem", FCVAR_SPONLY|FCVAR_PROTECTED);
	
	for(new i; i < sizeof szCommandPassword; i++) register_clcmd(szCommandPassword[i], "ManageMenu");
	
	register_clcmd("WPROWADZ_SWOJE_HASLO", "CheckPassword");
	register_clcmd("WPROWADZ_WYBRANE_HASLO", "RegisterStepOne");
	register_clcmd("POWTORZ_WYBRANE_HASLO", "RegisterStepTwo");
	register_clcmd("WPROWADZ_AKTUALNE_HASLO", "ChangeStepOne");
	register_clcmd("WPROWADZ_NOWE_HASLO", "ChangeStepTwo");
	register_clcmd("POWTORZ_NOWE_HASLO", "ChangeStepThree");
	register_clcmd("WPROWADZ_SWOJE_AKTUALNE_HASLO", "DeletePassword");
	
	register_message(get_user_msgid("ShowMenu"), "MessageShowMenu");
	register_message(get_user_msgid("VGUIMenu"), "MessageVGUIMenu");
	
	register_clcmd("chooseteam", "CheckRegister");
	register_clcmd("jointeam", "CheckRegister");
	
	gMaxPlayers = get_maxplayers();
	gHudSync = CreateHudSyncObj();
	
	SqlInit();
}

public plugin_natives()
	register_native("cod_check_register_system", "_cod_check_register_system");

public plugin_end()
	SQL_FreeHandle(hHookSql);

public client_connect(id)
{
	if(is_user_bot(id) || is_user_hltv(id)) return;

	szPlayerPassword[id] = "";
	
	iPasswordFail[id] = 0;
	
	iStatus[id] = NOT_REGISTERED;

	Rem(id, iLoaded);
	Rem(id, iAutoLogin);
	
	LoadPassword(id);
}

public client_disconnect(id)
	remove_task(id + TASK_PASSWORD);
	
public MessageShowMenu(iMsgid, iDest, id)
{
	static sMenuCode[32];
	get_msg_arg_string(4, sMenuCode, sizeof(sMenuCode) - 1);
	
	if(iStatus[id] < LOGGED && (equal(sMenuCode, FIRST_JOIN_MSG) || equal(sMenuCode, FIRST_JOIN_MSG_SPEC) || equal(sMenuCode, INGAME_JOIN_MSG) || equal(sMenuCode, INGAME_JOIN_MSG_SPEC)))
	{
		if(iStatus[id] == NOT_LOGGED) set_task(60.0, "KickPlayer", id + TASK_PASSWORD);

		cod_display_fade(id, 1, 1, 0x0004, 0, 0, 0, 255);

		ManageMenu(id);
		
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public MessageVGUIMenu(iMsgid, iDest, id)
{
	if(get_msg_arg_int(1) != 2 || iStatus[id] >= LOGGED) return PLUGIN_CONTINUE;

	if(iStatus[id] == NOT_LOGGED) set_task(60.0, "KickPlayer", id + TASK_PASSWORD);

	cod_display_fade(id, 1, 1, 0x0004, 0, 0, 0, 255);

	ManageMenu(id);
	
	return PLUGIN_HANDLED;
}

public CheckRegister(id)
{
	if(iStatus[id] < LOGGED)
	{
		ManageMenu(id);
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}
public KickPlayer(id)
{
	id -= TASK_PASSWORD;
	
	server_cmd("kick #%d ^"Nie zalogowales sie w ciagu 60s!^"", get_user_userid(id));
}

public ManageMenu(id)
{
	if(!Get(id, iLoaded)) return PLUGIN_HANDLED;
	
	new szMenu[256];
	
	formatex(szMenu, charsmax(szMenu), "\rSYSTEM REJESTRACJI^n^n\rNick: \w[\y%s\w]^n\rStatus: \w[\y%s\w]", szPlayerName[id], szStatus[iStatus[id]]);
	
	if((iStatus[id] == NOT_LOGGED || iStatus[id] == LOGGED) && !Get(id, iAutoLogin)) format(szMenu, charsmax(szMenu),"%s^n\wWpisz w konsoli komende \ysetinfo ^"%s^" ^"twojehaslo^"^n\wSprawi to, ze twoje haslo bedzie ladowane \rautomatycznie\w.", szMenu, SETINFO);

	new menu = menu_create(szMenu, "ManageMenu_Handle"), callback = menu_makecallback("ManageMenu_Callback");
	
	menu_additem(menu, "\yLogowanie", _, _, callback);
	menu_additem(menu, "\yRejestracja^n", _, _, callback);
	menu_additem(menu, "\yZmien \wHaslo", _, _, callback);
	menu_additem(menu, "\ySkasuj \wKonto^n", _, _, callback);
	menu_additem(menu, "\yZaloguj jako \wGosc \r(NIEZALECANE)^n", _, _, callback);
	menu_additem(menu, "\wWyjdz", _, _, callback);
 
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public ManageMenu_Callback(id, menu, item)
{
	switch(item)
	{
		case 0: return iStatus[id] == NOT_LOGGED ? ITEM_ENABLED : ITEM_DISABLED;
		case 1: return (iStatus[id] == NOT_REGISTERED || iStatus[id] == GUEST) ? ITEM_ENABLED : ITEM_DISABLED;
		case 2, 3: return iStatus[id] == LOGGED ? ITEM_ENABLED : ITEM_DISABLED;
		case 4: return iStatus[id] == NOT_REGISTERED ? ITEM_ENABLED : ITEM_DISABLED;
	}
	
	return ITEM_ENABLED;
}

public ManageMenu_Handle(id, menu, item)
{
	if(item == 5)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}
	
	switch(item)
	{
		case 0:
		{
			cod_print_chat(id, "Wprowadz swoje^x03 haslo^x01, aby sie^x03 zalogowac.");

			set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, gHudSync, "Wprowadz swoje haslo.");

			client_cmd(id, "messagemode WPROWADZ_SWOJE_HASLO");
		}
		case 1: 
		{
			cod_print_chat(id, "Rozpoczales proces^x03 rejestracji^x01. Wprowadz wybrane^x03 haslo^x01.");
	
			set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, gHudSync, "Wprowadz wybrane haslo.");
	
			client_cmd(id, "messagemode WPROWADZ_WYBRANE_HASLO");
		}
		case 2:
		{
			cod_print_chat(id, "Wprowadz swoje^x03 aktualne haslo^x01 w celu potwierdzenia tozsamosci.");
			
			set_hudmessage(255, 128, 0, 0.22, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, gHudSync, "Wprowadz swoje aktualne haslo.");
			
			client_cmd(id, "messagemode WPROWADZ_AKTUALNE_HASLO");
		}
		case 3: 
		{
			cod_print_chat(id, "Wprowadz swoje^x03 aktualne haslo^x01 w celu potwierdzenia tozsamosci.");
			
			set_hudmessage(255, 128, 0, 0.22, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, gHudSync, "Wprowadz swoje aktualne haslo.");
			
			client_cmd(id, "messagemode WPROWADZ_SWOJE_AKTUALNE_HASLO");
		}
		case 4: 
		{
			cod_print_chat(id, "Zalogowales sie jako^x03 Gosc^x01. By zabezpieczyc swoj nick^x03 zarejestruj sie^x01.");
			
			set_hudmessage(0, 255, 0, -1.0, 0.9, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, gHudSync, "Zostales pomyslnie zalogowany jako Gosc.");
			
			remove_task(id + TASK_PASSWORD);
			
			iStatus[id] = GUEST;
			
			engclient_cmd(id, "chooseteam");
		}
	}

	return PLUGIN_HANDLED;
}

public CheckPassword(id)
{
	if(iStatus[id] != NOT_LOGGED || !Get(id, iLoaded)) return PLUGIN_HANDLED;
	
	new szPassword[33];
	read_args(szPassword, charsmax(szPassword));
	
	remove_quotes(szPassword);

	if(!equal(szPlayerPassword[id], szPassword))
	{
		if(++iPasswordFail[id] >= 3) server_cmd("kick #%d ^"Nieprawidlowe haslo!^"", get_user_userid(id));
		
		cod_print_chat(id, "Podane haslo jest^x03 nieprawidlowe^x01. (Bledne haslo^x03 %i/3^x01)", iPasswordFail[id]);
		
		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, gHudSync, "Podane haslo jest nieprawidlowe.");
		
		ManageMenu(id);
		
		return PLUGIN_HANDLED;
	}
	
	cod_print_chat(id, "Zostales pomyslnie^x03 zalogowany^x01. Zyczymy milej gry.");
	
	set_hudmessage(0, 255, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	ShowSyncHudMsg(id, gHudSync, "Zostales pomyslnie zalogowany.");
	
	remove_task(id + TASK_PASSWORD);
	
	iStatus[id] = LOGGED;
	
	iPasswordFail[id] = 0;
	
	engclient_cmd(id, "chooseteam");
	
	return PLUGIN_HANDLED;
}

public RegisterStepOne(id)
{
	if((iStatus[id] != NOT_REGISTERED && iStatus[id] != GUEST) || !Get(id, iLoaded)) return PLUGIN_HANDLED;

	new szPassword[33];
	
	read_args(szPassword, charsmax(szPassword));
	remove_quotes(szPassword);
	
	if(strlen(szPassword) < 5)
	{
		cod_print_chat(id, "Haslo musi miec co najmniej^x03 5 znakow^x01.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, gHudSync, "Haslo musi miec co najmniej 5 znakow.");
		
		ManageMenu(id);
		
		return PLUGIN_HANDLED;
	}
	
	copy(szPlayerTempPassword[id], charsmax(szPlayerTempPassword), szPassword);
	
	cod_print_chat(id, "Teraz powtorz wybrane^x03 haslo^x01.");
	
	set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	ShowSyncHudMsg(id, gHudSync, "Powtorz wybrane haslo.");
	
	client_cmd(id, "messagemode POWTORZ_WYBRANE_HASLO");
	
	return PLUGIN_HANDLED;
}
	
public RegisterStepTwo(id)
{
	if((iStatus[id] != NOT_REGISTERED && iStatus[id] != GUEST) || !Get(id, iLoaded)) return PLUGIN_HANDLED;
	
	new szPassword[33];
	
	read_args(szPassword, charsmax(szPassword));
	remove_quotes(szPassword);
	
	if(!equal(szPassword, szPlayerTempPassword[id]))
	{
		cod_print_chat(id, "Podane hasla^x03 roznia sie^x01 od siebie.");
		
		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, gHudSync, "Podane hasla roznia sie od siebie.");
		
		ManageMenu(id);
		
		return PLUGIN_HANDLED;
	}
	
	copy(szPlayerPassword[id], charsmax(szPlayerPassword), szPassword);
	
	new szMenu[256];
	
	formatex(szMenu, charsmax(szMenu), "\rPOTWIERDZENIE REJESTRACJI^n^n\rNick: \w[\y%s\w]^n\rTwoje Haslo: \w[\y%s\w]", szPlayerName[id], szPlayerPassword[id]);

	new menu = menu_create(szMenu, "RegisterStepTwo_Handle");
	
	menu_additem(menu, "\rPotwierdz \wHaslo");
	menu_additem(menu, "\yZmien \wHaslo^n");
	menu_additem(menu, "\wAnuluj");
 
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public RegisterStepTwo_Handle(id, menu, item)
{
	switch(item)
	{
		case 0:
		{
			new szPassword[33];
			
			mysql_escape_string(szPlayerPassword[id], szPassword, charsmax(szPassword));
	
			formatex(szTemp, charsmax(szTemp), "UPDATE `register_system` SET pass = '%s' WHERE name = '%s'", szPassword, szPlayerSafeName[id]);
	
			SQL_ThreadQuery(hHookSql, "Ignore_Handle", szTemp);
	
			set_hudmessage(0, 255, 0, -1.0, 0.9, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, gHudSync, "Zostales pomyslnie zarejestrowany i zalogowany.");
	
			cod_print_chat(id, "Twoj nick zostal pomyslnie^x03 zarejestrowany^x01.");
			cod_print_chat(id, "Wpisz w konsoli komende^x03 setinfo ^"%s^" ^"%s^"^x01, aby twoje haslo bylo ladowane automatycznie.", SETINFO, szPlayerPassword[id]);
	
			cmd_execute(id, "setinfo %s %s", SETINFO, szPlayerPassword[id]);
			cmd_execute(id, "writecfg %s", CONFIG);
	
			iStatus[id] = LOGGED;
	
			if(!get_user_team(id)) engclient_cmd(id, "chooseteam");
		}
		case 1:
		{
			cod_print_chat(id, "Rozpoczales proces^x03 rejestracji^x01. Wprowadz wybrane^x03 haslo^x01.");
	
			set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, gHudSync, "Wprowadz wybrane haslo.");
	
			client_cmd(id, "messagemode WPROWADZ_WYBRANE_HASLO");
		}
		case 2: ManageMenu(id);
	}
	
	menu_destroy(menu);
	
	return PLUGIN_HANDLED;
}

public ChangeStepOne(id)
{
	if(iStatus[id] != LOGGED || !Get(id, iLoaded)) return PLUGIN_HANDLED;

	new szPassword[33];
	
	read_args(szPassword, charsmax(szPassword));
	remove_quotes(szPassword);
	
	if(!equal(szPlayerPassword[id], szPassword))
	{
		if(++iPasswordFail[id] >= 3) server_cmd("kick #%d ^"Nieprawidlowe haslo!^"", get_user_userid(id));
		
		cod_print_chat(id, "Podane haslo jest^x03 nieprawidlowe^x01. (Bledne haslo^x03 %i/3^x01)", iPasswordFail[id]);
		
		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, gHudSync, "Podane haslo jest nieprawidlowe.");
		
		ManageMenu(id);
		
		return PLUGIN_HANDLED;
	}
	
	cod_print_chat(id, "Wprowadz swoje^x03 nowe haslo^x01.");

	set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	ShowSyncHudMsg(id, gHudSync, "Wprowadz swoje nowe haslo.");

	client_cmd(id, "messagemode WPROWADZ_NOWE_HASLO");
	
	return PLUGIN_HANDLED;
}

public ChangeStepTwo(id)
{
	if(iStatus[id] != LOGGED || !Get(id, iLoaded)) return PLUGIN_HANDLED;

	new szPassword[33];
	
	read_args(szPassword, charsmax(szPassword));
	remove_quotes(szPassword);
	
	if(equal(szPlayerPassword[id], szPassword))
	{
		cod_print_chat(id, "Nowe haslo jest^x03 takie samo^x01 jak aktualne.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, gHudSync, "Nowe haslo jest takie samo jak aktualne.");
		
		ManageMenu(id);
		
		return PLUGIN_HANDLED;
	}
	
	if(strlen(szPassword) < 5)
	{
		cod_print_chat(id, "Nowe haslo musi miec co najmniej^x03 5 znakow^x01.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, gHudSync, "Nowe haslo musi miec co najmniej 5 znakow.");
		
		ManageMenu(id);
		
		return PLUGIN_HANDLED;
	}
	
	copy(szPlayerTempPassword[id], charsmax(szPlayerTempPassword), szPassword);
	
	cod_print_chat(id, "Powtorz swoje nowe^x03 haslo^x01.");
	
	set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	ShowSyncHudMsg(id, gHudSync, "Powtorz swoje nowe haslo.");
	
	client_cmd(id, "messagemode POWTORZ_NOWE_HASLO");
	
	return PLUGIN_HANDLED;
}

public ChangeStepThree(id)
{
	if(iStatus[id] != LOGGED || !Get(id, iLoaded)) return PLUGIN_HANDLED;
	
	new szPassword[33];
	
	read_args(szPassword, charsmax(szPassword));
	remove_quotes(szPassword);
	
	if(!equal(szPassword, szPlayerTempPassword[id]))
	{
		cod_print_chat(id, "Podane hasla^x03 roznia sie^x01 od siebie.");
		
		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, gHudSync, "Podane hasla roznia sie od siebie.");
		
		ManageMenu(id);
		
		return PLUGIN_HANDLED;
	}
	
	copy(szPlayerPassword[id], charsmax(szPlayerPassword), szPassword);
	
	mysql_escape_string(szPassword, szPassword, charsmax(szPassword));
	
	formatex(szTemp, charsmax(szTemp), "UPDATE `register_system` SET pass = '%s' WHERE name = '%s'", szPassword, szPlayerSafeName[id]);
	
	SQL_ThreadQuery(hHookSql, "Ignore_Handle", szTemp);
	
	set_hudmessage(0, 255, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	ShowSyncHudMsg(id, gHudSync, "Twoje haslo zostalo pomyslnie zmienione.");
	
	cod_print_chat(id, "Twoje haslo zostalo pomyslnie^x03 zmienione^x01.");
	cod_print_chat(id, "Wpisz w konsoli komende^x03 setinfo ^"%s^" ^"%s^"^x01, aby twoje haslo bylo ladowane automatycznie.", SETINFO, szPlayerPassword[id]);
	
	cmd_execute(id, "setinfo %s %s", SETINFO, szPlayerPassword[id]);
	cmd_execute(id, "writecfg %s", CONFIG);
	
	return PLUGIN_HANDLED;
}

public DeletePassword(id)
{
	if(iStatus[id] != LOGGED || !Get(id, iLoaded)) return PLUGIN_HANDLED;

	new szPassword[33];
	
	read_args(szPassword, charsmax(szPassword));
	remove_quotes(szPassword);
	
	if(!equal(szPlayerPassword[id], szPassword))
	{
		if(++iPasswordFail[id] >= 3) server_cmd("kick #%d ^"Nieprawidlowe haslo!^"", get_user_userid(id));
		
		cod_print_chat(id, "Podane haslo jest^x03 nieprawidlowe^x01. (Bledne haslo^x03 %i/3^x01)", iPasswordFail[id]);
		
		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, gHudSync, "Podane haslo jest nieprawidlowe.");
		
		ManageMenu(id);
		
		return PLUGIN_HANDLED;
	}
	
	new szMenu[128];
	
	formatex(szMenu, charsmax(szMenu), "\wCzy na pewno chcesz \rusunac \wswoje konto?");

	new menu = menu_create(szMenu, "DeletePassword_Handle");
	
	menu_additem(menu, "\rTak");
	menu_additem(menu, "\wNie^n");
	menu_additem(menu, "\wWyjdz");
 
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public DeletePassword_Handle(id, menu, item)
{
	if(item == 0)
	{
		formatex(szTemp, charsmax(szTemp), "DELETE FROM `register_system` WHERE name = '%s'", szPlayerSafeName[id]);
		
		SQL_ThreadQuery(hHookSql, "Ignore_Handle", szTemp);
		
		console_print(id, "==================================");
		console_print(id, "==========SYSTEM REJESTRACJI==========");
		console_print(id, "              Skasowales konto o nicku: %s", szPlayerName[id]);
		console_print(id, "==================================");
		
		server_cmd("kick #%d ^"Konto zostalo usuniete!^"", get_user_userid(id));
	}
	
	menu_destroy(menu);
	
	return PLUGIN_CONTINUE;
}

public SqlInit()
{
	new szData[4][64];
	
	get_cvar_string("register_system_sql_host", szData[0], charsmax(szData[])); 
	get_cvar_string("register_system_sql_user", szData[1], charsmax(szData[])); 
	get_cvar_string("register_system_sql_pass", szData[2], charsmax(szData[])); 
	get_cvar_string("register_system_sql_db", szData[3], charsmax(szData[])); 
	
	hHookSql = SQL_MakeDbTuple(szData[0], szData[1], szData[2], szData[3]);

	new iError, szError[128], Handle:hConn = SQL_Connect(hHookSql, iError, szError, charsmax(szError));
	
	if(iError)
	{
		log_to_file("addons/amxmodx/logs/register_system.log", "Error: %s", szError);
		
		return;
	}
	
	new szTemp[1024];
	
	formatex(szTemp, charsmax(szTemp), "CREATE TABLE IF NOT EXISTS `register_system` (name VARCHAR(35), pass VARCHAR(35), PRIMARY KEY(name));");

	new Handle:hQuery = SQL_PrepareQuery(hConn, szTemp);
	
	SQL_Execute(hQuery);
	SQL_FreeHandle(hQuery);
	SQL_FreeHandle(hConn);
}

public LoadPassword(id)
{
	get_user_name(id, szPlayerName[id], charsmax(szPlayerName));
	
	mysql_escape_string(szPlayerName[id], szPlayerSafeName[id], charsmax(szPlayerSafeName));
	
	new szData[1];
	
	szData[0] = id;
	
	formatex(szTemp, charsmax(szTemp), "SELECT * FROM `register_system` WHERE name = '%s'", szPlayerSafeName[id]);
	SQL_ThreadQuery(hHookSql, "LoadPassword_Handle", szTemp, szData, 1);
}

public LoadPassword_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_to_file("addons/amxmodx/logs/register_system.log", "<Query> Error: %s", szError);
		
		return;
	}
	
	new id = szData[0];
	
	if(SQL_MoreResults(hQuery))
	{
		SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "pass"), szPlayerPassword[id], charsmax(szPlayerPassword));
		
		new szPassword[33];
		
		cmd_execute(id, "exec %s.cfg", CONFIG);
		
		get_user_info(id, SETINFO, szPassword, charsmax(szPassword));
		
		if(!equal(szPlayerPassword[id], ""))
		{
			if(equal(szPlayerPassword[id], szPassword))
			{
				iStatus[id] = LOGGED;
				
				Set(id, iAutoLogin);
			}
			else iStatus[id] = NOT_LOGGED;
		}
	}
	else
	{
		formatex(szTemp, charsmax(szTemp), "INSERT IGNORE INTO `register_system` VALUES ('%s', '')", szPlayerSafeName[id]);
		SQL_ThreadQuery(hHookSql, "Ignore_Handle", szTemp);
	}
	
	Set(id, iLoaded);
}

public Ignore_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_to_file("addons/amxmodx/logs/register_system.log", "<Ignore Query> Error: %s", szError);
		
		return;
	}
}

public _cod_check_register_system(plugin_id, num_params)
{
	new id = get_param(1);
	
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[Register System] Invalid Player (%d)", id);
		
		return PLUGIN_HANDLED;
	}
	
	if(iStatus[id] < LOGGED)
	{
		cod_print_chat(id, "Musisz sie^x03 zalogowac^x01, aby miec dostep do glownych funkcji!");
		
		ManageMenu(id);
		
		return 0;
	}
	
	return 1;
}

stock mysql_escape_string(const szSource[], szDest[], iLen)
{
	copy(szDest, iLen, szSource);
	
	replace_all(szDest, iLen, "\\", "\\\\");
	replace_all(szDest, iLen, "\0", "\\0");
	replace_all(szDest, iLen, "\n", "\\n");
	replace_all(szDest, iLen, "\r", "\\r");
	replace_all(szDest, iLen, "\x1a", "\Z");
	replace_all(szDest, iLen, "'", "\'");
	replace_all(szDest, iLen, "`", "\`");
	replace_all(szDest, iLen, "^"", "\^"");
}

stock cmd_execute(id, const szText[], any:...) 
{
    #pragma unused szText

    if (id == 0 || is_user_connected(id))
	{
    	new szMessage[256];

    	format_args(szMessage, charsmax(szMessage), 1);

        message_begin(id == 0 ? MSG_ALL : MSG_ONE, 51, _, id);
        write_byte(strlen(szMessage) + 2);
        write_byte(10);
        write_string(szMessage);
        message_end();
    }
}