#include <amxmodx>
#include <cod>
#include <sqlx>
#include <nvault>

#define PLUGIN "CoD Password"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define is_user_player(%1) (1 <= %1 <= iMaxPlayers)

#define Set(%2,%1) (%1 |= (1<<(%2&31)))
#define Rem(%2,%1) (%1 &= ~(1 <<(%2&31)))
#define Get(%2,%1) (%1 & (1<<(%2&31)))

#define MAX_PLAYERS 32
#define MAX_FAILS 3

new const szCommandPassword[][] = { "say /password", "say_team /password", "say /haslo", "say_team /haslo", "haslo" };

new szPlayerName[MAX_PLAYERS + 1][33], szPlayerPassword[MAX_PLAYERS + 1][33], iPasswordFail[MAX_PLAYERS + 1];

new iPassword, iLoaded, iMaxPlayers;

new cvarSaveType;

new gVault;

new Handle:hSqlHook;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cvarSaveType = register_cvar("cod_password_save_type", "1"); // 0 - SQL | 1 - NVAULT
	
	for(new i; i < sizeof szCommandPassword; i++)
		register_clcmd(szCommandPassword[i], "ManagePassword");

	register_clcmd("Ustaw_Haslo", "CmdSetPassword");
	register_clcmd("Zmien_Haslo", "CmdSetNewPassword");
	register_clcmd("Podaj_Haslo", "CmdCheckPassword");
	
	iMaxPlayers = get_maxplayers();
}

public plugin_cfg()
{
	if(get_pcvar_num(cvarSaveType))
	{
		gVault = nvault_open("cod_honor");
	
		if(gVault == INVALID_HANDLE)
			set_fail_state("Nie mozna otworzyc pliku cod_honor.vault");
	}
	else
		SqlInit();
}

public plugin_natives()
{
	register_native("cod_check_password", "_cod_check_password");
	register_native("cod_force_password", "_cod_force_password");
}

public plugin_end()
	SQL_FreeHandle(hSqlHook);

public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_CONTINUE;
		
	szPlayerName[id] = "";
	szPlayerPassword[id] = "";
	
	iPasswordFail[id] = 0;
	
	Rem(id, iLoaded);
	Rem(id, iPassword);

	get_user_name(id, szPlayerName[id], charsmax(szPlayerName[]));
	
	LoadPassword(id);
	
	return PLUGIN_CONTINUE;
}

public ManagePassword(id)
{
	if(!Get(id, iLoaded))
	{
		cod_print_chat(id, DontChange, "Twoje haslo nie zostalo jeszcze wczytane.");
		return PLUGIN_CONTINUE;
	}
	
	new szMenu[128], menu;
	
	if(get_user_password(id))
	{
		if(Get(id, iPassword))
			formatex(szMenu, charsmax(szMenu), "\yZarzadzaj \rHaslem:^n\wTwoje Haslo: \r%s^n\wKomenda: \rsetinfo ^"_codpass^" ^"%s^"", szPlayerPassword[id], szPlayerPassword[id]);
		else
			formatex(szMenu, charsmax(szMenu), "\yZarzadzaj \rHaslem:^n\wTwoje Haslo: \rUkryte");
			
		menu = menu_create(szMenu, "ManagePassword_Handle");
		
		formatex(szMenu, charsmax(szMenu), "\dUstaw Haslo");
		menu_additem(menu, szMenu);
		formatex(szMenu, charsmax(szMenu), "%s", Get(id, iPassword) ? "\yZmien \rHaslo" : "\dZmien Haslo");
		menu_additem(menu, szMenu);
	}
	else
	{
		formatex(szMenu, charsmax(szMenu), "\yZarzadzaj \rHaslem:^n\wTwoje Haslo: \rBrak");
		
		menu = menu_create(szMenu, "ManagePassword_Handle");
		
		formatex(szMenu, charsmax(szMenu), "\yUstaw \rHaslo");
		menu_additem(menu, szMenu);
		formatex(szMenu, charsmax(szMenu), "\dZmien Haslo");
		menu_additem(menu, szMenu);
		
		cod_print_chat(id, DontChange, "Nie ustawiles jeszcze swojego^x04 hasla^x01. Zrob to teraz!");
	}
 
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_BACKNAME, "Wstecz");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}

public ManagePassword_Handle(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0: 
		{
			if(get_user_password(id))
			{
				ManagePassword(id);
				return PLUGIN_CONTINUE;
			}
	
			cod_print_chat(id, DontChange, "Teraz wpisz twoje wybrane haslo.");
			client_print(id, print_center, "Wpisz twoje wybrane haslo!");
			
			client_cmd(id, "messagemode Ustaw_Haslo");
		}
		case 1: 
		{
			if(!get_user_password(id) || !Get(id, iPassword))
			{
				ManagePassword(id);
				return PLUGIN_CONTINUE;
			}
			
			cod_print_chat(id, DontChange, "Teraz wpisz twoje nowe haslo.");
			client_print(id, print_center, "Wpisz twoje nowe haslo!");
			
			client_cmd(id, "messagemode Zmien_Haslo");
		}
	}
	return PLUGIN_CONTINUE;
}

public CmdSetPassword(id)
{
	if(get_user_password(id))
	{
		cod_print_chat(id, DontChange, "Nie mozesz ustawic hasla, bo juz je masz!");
		return PLUGIN_CONTINUE;
	}
	
	new szPassword[33];
	
	read_args(szPassword, charsmax(szPassword));
	remove_quotes(szPassword);
	
	if(equal(szPassword, ""))
	{
		cod_print_chat(id, DontChange, "Nie wpisales zadnego hasla. Wpisz je teraz!");
		
		client_cmd(id, "messagemode Ustaw_Haslo");
		
		return PLUGIN_CONTINUE;
	}
	
	formatex(szPlayerPassword[id], charsmax(szPlayerPassword), szPassword);
	
	SavePassword(id);
	
	client_print(id, print_center, "Haslo zostalo ustawione!");
	cod_print_chat(id, DontChange, "Twoje haslo zostalo ustawione.");
	cod_print_chat(id, DontChange, "Wpisz w konsoli^x03 setinfo ^"_codpass^" ^"%s^"^x01.", szPlayerPassword[id]);
	
	Set(id, iPassword);
	
	cmd_execute(id, "setinfo _codpass %s", szPlayerPassword[id]);
	cmd_execute(id, "writecfg codpass");
	
	return PLUGIN_HANDLED;
}

public Cmd_SetNewPassword(id)
{
	if(!get_user_password(id))
	{
		cod_print_chat(id, DontChange, "Nie mozesz ustawic nowego hasla, bo nie masz zadnego!");
		return PLUGIN_HANDLED;
	}
	
	new szPassword[33];
	
	read_args(szPassword, charsmax(szPassword));
	remove_quotes(szPassword);
	
	if(equal(szPassword, ""))
	{
		cod_print_chat(id, DontChange, "Nie wpisales zadnego hasla. Wpisz je teraz!");
		client_cmd(id, "messagemode Zmien_Haslo");
		return PLUGIN_HANDLED;
	}
	
	formatex(szPlayerPassword[id], charsmax(szPlayerPassword), szPassword);
	
	SavePassword(id);
	
	client_print(id, print_center, "Nowe haslo zostalo ustawione!");
	cod_print_chat(id, DontChange, "Twoje nowe haslo zostalo ustawione.");
	cod_print_chat(id, DontChange, "Wpisz w konsoli^x03 setinfo ^"_codpass^" ^"%s^"^x01.", szPlayerPassword[id]);
	
	Set(id, iPassword);
	
	cmd_execute(id, "setinfo _codpass %s", szPlayerPassword[id]);
	cmd_execute(id, "writecfg codpass");
	
	return PLUGIN_HANDLED;
}

public CmdCheckPassword(id)
{
	if(Get(id, iPassword))
		return PLUGIN_HANDLED;
	
	new szPassword[33];
	
	read_args(szPassword, charsmax(szPassword));
	remove_quotes(szPassword);
	
	if(equal(szPassword, ""))
	{
		cod_print_chat(id, DontChange, "Nie wpisales zadnego hasla. Zrob to teraz!");
		client_cmd(id, "messagemode Podaj_Haslo");
		return PLUGIN_CONTINUE;
	}
	
	if(!equal(szPlayerPassword[id], szPassword))
	{
		if(++iPasswordFail[id] >= MAX_FAILS)
			server_cmd("kick #%d ^"Nieprawidlowe haslo!^"", get_user_userid(id));
		
		cod_print_chat(id, DontChange, "Podane haslo jest^x03 nieprawidlowe^x01. Sprobuj wpisac haslo jeszcze raz!");
		
		client_cmd(id, "messagemode Podaj_Haslo");
		
		return PLUGIN_CONTINUE;
	}
	
	cod_print_chat(id, DontChange, "Wpisane haslo jest^x03 prawidlowe^x01. Zyczymy milej gry.");
	
	Set(id, iPassword);
	
	return PLUGIN_CONTINUE;
}

public CheckPassword(id)
{
	if(!is_user_connected(id) || Get(id, iPassword))
		return PLUGIN_CONTINUE;

	client_cmd(id, "messagemode Podaj_Haslo");
	
	cod_print_chat(id, DontChange, "Wpisz jednorazowo swoje haslo.");
	client_print(id, print_center, "Wpisz swoje haslo!");
	
	return PLUGIN_CONTINUE;
}

public SqlInit()
{
	new szData[4][64];
	
	get_cvar_string("cod_sql_host", szData[0], charsmax(szData)); 
	get_cvar_string("cod_sql_user", szData[1], charsmax(szData)); 
	get_cvar_string("cod_sql_pass", szData[2], charsmax(szData)); 
	get_cvar_string("cod_sql_db", szData[3], charsmax(szData));  
	
	hSqlHook = SQL_MakeDbTuple(szData[0], szData[1], szData[2], szData[3]);

	new iError, szError[128];
	new Handle:hConnection = SQL_Connect(hSqlHook, iError, szError, charsmax(szError));
	
	if(iError)
	{
		log_to_file("addons/amxmodx/logs/password.log", "Error: %s", szError);
		return;
	}
	
	new szTemp[128], Handle:hQuery = SQL_PrepareQuery(hConnection, szTemp);
	
	formatex(szTemp, charsmax(szTemp), "CREATE TABLE IF NOT EXISTS `cod_password_system` (name VARCHAR(35), pass VARCHAR(35), PRIMARY KEY(name));");
	
	SQL_Execute(hQuery);
	SQL_FreeHandle(hQuery);
	SQL_FreeHandle(hConnection);
}

public LoadPassword(id)
{
	if(!is_user_connected(id))
		return;

	if(get_pcvar_num(cvarSaveType))
	{
		new szVaultKey[64], szVaultData[64];
	
		formatex(szVaultKey, charsmax(szVaultKey), "%s-cod_password", szPlayerName[id]);
	
		if(nvault_get(gVault, szVaultKey, szVaultData, charsmax(szVaultData)))
		{
			new szTempPassword[32];
			parse(szVaultData, szTempPassword, charsmax(szTempPassword));
	
			formatex(szPlayerPassword[id], charsmax(szPlayerPassword), szTempPassword);
		}
		
		new szPassword[33];
		
		cmd_execute(id, "exec codpass.cfg");
		get_user_info(id, "_codpass", szPassword, charsmax(szPassword));
		
		if(equal(szPlayerPassword[id], szPassword))
			Set(id, iPassword);
			
		Set(id, iLoaded);
	
		if(!get_user_password(id))
			ManagePassword(id);
	}
	else
	{
		new szTemp[128], szName[33], szData[1];
		
		szData[0] = id;
		
		mysql_escape_string(szName, szPlayerName[id], charsmax(szPlayerName));
	
		formatex(szTemp, charsmax(szTemp), "SELECT * FROM `cod_password_system` WHERE name = '%s'", szName);
		SQL_ThreadQuery(hSqlHook, "LoadPassword_Handle", szTemp, szData, 1);
	}
}

public LoadPassword_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iSize)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_to_file("addons/amxmodx/logs/cod_password.log", "<Query> Error: %s", szError);
		return;
	}
	
	new id = szData[0];
	
	if(!is_user_connected(id))
		return;
	
	if(SQL_MoreResults(hQuery))
	{
		SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "pass"), szPlayerPassword[id], charsmax(szPlayerPassword));
		
		new szPassword[33];
		
		cmd_execute(id, "exec codpass.cfg");
		get_user_info(id, "_codpass", szPassword, charsmax(szPassword));
		
		if(equal(szPlayerPassword[id], szPassword))
			Set(id, iPassword);
	}
	else
	{
		new szTemp[128], szName[33];
		
		mysql_escape_string(szName, szPlayerName[id], charsmax(szPlayerName));
		
		formatex(szTemp, charsmax(szTemp), "INSERT INTO `cod_password_system` VALUES ('%s', '')", szName);
		
		SQL_ThreadQuery(hSqlHook, "Ignore_Handle", szTemp);
	}
	
	Set(id, iLoaded);
	
	if(!get_user_password(id))
		ManagePassword(id);
}

public SavePassword(id)
{
	if(!Get(id, iLoaded))
		return;
		
	if(get_pcvar_num(cvarSaveType))
	{
		new szVaultKey[64], szVaultData[64];
	
		formatex(szVaultKey, charsmax(szVaultKey), "%s-cod_password", szPlayerName[id]);
		formatex(szVaultData, charsmax(szVaultData), "%s", szPlayerPassword[id]);
	
		nvault_set(gVault, szVaultKey, szVaultData);
	}
	else
	{
		new szTemp[256], szPassword[33], szName[33];
		
		mysql_escape_string(szPassword, szPlayerPassword[id], charsmax(szPlayerPassword));
		mysql_escape_string(szName, szPlayerName[id], charsmax(szPlayerName));
	
		formatex(szTemp, charsmax(szTemp), "UPDATE `cod_password_system` SET pass = '%s' WHERE name = '%s'", szPassword, szName);
	
		SQL_ThreadQuery(hSqlHook, "Ignore_Handle", szTemp);
	}
}

public Ignore_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iSize)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_to_file("addons/amxmodx/logs/cod_password.log", "Could not connect to SQL database.  [%d] %s", iError, szError);
		return;
	}
}

public _cod_check_password(iPlugin, iParams)
{
	if(iParams != 1)
		return PLUGIN_CONTINUE;
		
	new id = get_param(1);
	
	if(!is_user_player(id))
		return PLUGIN_CONTINUE;
	
	return Get(id, iPassword);
}

public _cod_force_password(iPlugin, iParams)
{
	if(iParams != 1)
		return PLUGIN_CONTINUE;
		
	new id = get_param(1);
	
	if(!is_user_player(id))
		return PLUGIN_CONTINUE;
	
	if(!get_user_password(id))
	{
		ManagePassword(id);
		return PLUGIN_CONTINUE;
	}
	
	CheckPassword(id);
	
	return PLUGIN_CONTINUE;
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

stock get_user_password(id)
	return !equal(szPlayerPassword[id], "") ? true : false;

stock cmd_execute(id, const szText[], any:...) 
{
    #pragma unused szText

    if(id == 0 || is_user_connected(id))
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