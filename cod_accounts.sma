#include <amxmodx>
#include <sqlx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Accounts System"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define SETINFO "_csrpass"
#define CONFIG "csrpass"

#define TASK_PASSWORD 1945

#define m_iMenuCode 205
#define OFFSET_LINUX 5
#define VGUI_JOIN_TEAM_NUM 2

new playerName[33][64], playerSafeName[33][64], playerPassword[33][33], playerTempPassword[33][33], 
	playerFails[33], playerStatus[33], Handle:sql, dataLoaded, autoLogin, maxPlayers, hudSync;

enum _:status { NOT_REGISTERED, NOT_LOGGED, LOGGED, GUEST };

enum _:queries { UPDATE, INSERT, DELETE };

new const accountStatus[status][] = { "Niezarejestrowany", "Niezalogowany", "Zalogowany", "Gosc" };

new const commandAccount[][] = { "say /haslo", "say_team /haslo", "say /password", "say_team /password", 
	"say /konto", "say_team /konto", "say /account", "say_team /account", "haslo" };

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof commandAccount; i++) register_clcmd(commandAccount[i], "account_menu");
	
	register_clcmd("WPROWADZ_SWOJE_HASLO", "login_account");
	register_clcmd("WPROWADZ_WYBRANE_HASLO", "register_step_one");
	register_clcmd("POWTORZ_WYBRANE_HASLO", "register_step_two");
	register_clcmd("WPROWADZ_AKTUALNE_HASLO", "change_step_one");
	register_clcmd("WPROWADZ_NOWE_HASLO", "change_step_two");
	register_clcmd("POWTORZ_NOWE_HASLO", "change_step_three");
	register_clcmd("WPROWADZ_SWOJE_AKTUALNE_HASLO", "delete_account");

	register_concmd("joinclass", "check_account");
	register_concmd("jointeam", "check_account");
	register_concmd("chooseteam", "check_account");
	
	register_message(get_user_msgid("ShowMenu"), "message_show_menu");
	register_message(get_user_msgid("VGUIMenu"), "message_vgui_menu");

	register_forward(FM_PlayerPreThink, "player_prethink");
	
	hudSync = CreateHudSyncObj();
	maxPlayers = get_maxplayers();
}

public plugin_natives()
	register_native("cod_check_account", "_cod_check_account");

public plugin_cfg()
	sql_init();

public plugin_end()
	SQL_FreeHandle(sql);

public client_connect(id)
{
	if(is_user_bot(id) || is_user_hltv(id)) return;

	playerPassword[id] = "";
	
	playerFails[id] = 0;
	
	playerStatus[id] = NOT_REGISTERED;

	rem_bit(id, dataLoaded);
	rem_bit(id, autoLogin);

	get_user_name(id, playerName[id], charsmax(playerName[]));
	
	mysql_escape_string(playerName[id], playerSafeName[id], charsmax(playerSafeName[]));
	
	load_account(id);
}

public client_disconnected(id)
	remove_task(id + TASK_PASSWORD);

public message_team(id) 
{
	if(is_user_connected(id) && !is_user_bot(id) && !is_user_hltv(id) && playerStatus[id] < LOGGED) 
	{
		account_menu(id, 1);

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
	
public message_show_menu(msgId, dest, id)
{
	new const Team_Select[] = "#Team_Select";
	static menuData[sizeof(Team_Select)];
    
	get_msg_arg_string(4, menuData, charsmax(menuData));

	if(equal(menuData, Team_Select) && playerStatus[id] < LOGGED)
	{
		set_pdata_int(id, m_iMenuCode, 0, OFFSET_LINUX);

		set_task(0.1, "account_menu", id);
		
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message_vgui_menu(msgId, dest, id)
{
	if(get_msg_arg_int(1) == VGUI_JOIN_TEAM_NUM && playerStatus[id] < LOGGED)
	{
		account_menu(id, 1);

		return PLUGIN_HANDLED;
	} 

	return PLUGIN_CONTINUE;
}

public player_prethink(id) 
{
	if(get_bit(id, dataLoaded) && !is_user_bot(id) && !is_user_hltv(id) && is_user_connected(id) && playerStatus[id] < LOGGED) 
	{
		static msgScreenFade;
	
		if(!msgScreenFade) msgScreenFade = get_user_msgid("ScreenFade");

		message_begin(MSG_ONE, msgScreenFade, {0, 0, 0}, id);
		write_short(1<<12);
		write_short(1<<12);
		write_short(0x0000);
		write_byte(0);
		write_byte(0);
		write_byte(0);
		write_byte(255);
		message_end();
	}
}

public check_account(id)
{
	if(playerStatus[id] < LOGGED)
	{
		account_menu(id, 0);
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public kick_player(id)
{
	id -= TASK_PASSWORD;
	
	if(is_user_connected(id)) server_cmd("kick #%d ^"Nie zalogowales sie w ciagu 60s!^"", get_user_userid(id));
}
public account_menu(id, sound)
{
	if(!is_user_connected(id) || !is_user_valid(id)) return PLUGIN_HANDLED;

	if(!get_bit(id, dataLoaded))
	{
		set_task(0.1, "account_menu", id);

		return PLUGIN_HANDLED;
	}

	if(!get_user_team(id) && playerStatus[id] == LOGGED)
	{
		engclient_cmd(id, "chooseteam");

		return PLUGIN_HANDLED;
	}

	if(playerStatus[id] <= NOT_LOGGED) if(!task_exists(id + TASK_PASSWORD)) set_task(60.0, "kick_player", id + TASK_PASSWORD);

	if(!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	static menuData[192];

	formatex(menuData, charsmax(menuData), "\rSYSTEM REJESTRACJI^n^n\rNick: \w[\y%s\w]^n\rStatus: \w[\y%s\w]", playerName[id], accountStatus[playerStatus[id]]);
	
	if((playerStatus[id] == NOT_LOGGED || playerStatus[id] == LOGGED) && !get_bit(id, autoLogin)) format(menuData, charsmax(menuData),"%s^n\wWpisz w konsoli \ysetinfo ^"%s^" ^"twojehaslo^"^n\wSprawi to, ze twoje haslo bedzie ladowane \rautomatycznie\w.", menuData, SETINFO);

	new menu = menu_create(menuData, "account_menu_handle"), callback = menu_makecallback("account_menu_callback");
	
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

public account_menu_callback(id, menu, item)
{
	switch(item)
	{
		case 0: return playerStatus[id] == NOT_LOGGED ? ITEM_ENABLED : ITEM_DISABLED;
		case 1: return (playerStatus[id] == NOT_REGISTERED || playerStatus[id] == GUEST) ? ITEM_ENABLED : ITEM_DISABLED;
		case 2, 3: return playerStatus[id] == LOGGED ? ITEM_ENABLED : ITEM_DISABLED;
		case 4: return playerStatus[id] == NOT_REGISTERED ? ITEM_ENABLED : ITEM_DISABLED;
	}

	return ITEM_ENABLED;
}

public account_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
		
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	if(item == MENU_EXIT || item == 5)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}
	
	switch(item)
	{
		case 0:
		{
			cod_print_chat(id, "Wprowadz swoje^x04 haslo^x01, aby sie^x04 zalogowac.");

			set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, hudSync, "Wprowadz swoje haslo.");

			client_cmd(id, "messagemode WPROWADZ_SWOJE_HASLO");
		}
		case 1: 
		{
			cod_print_chat(id, "Rozpoczales proces^x04 rejestracji^x01. Wprowadz wybrane^x04 haslo^x01.");
	
			set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, hudSync, "Wprowadz wybrane haslo.");
	
			client_cmd(id, "messagemode WPROWADZ_WYBRANE_HASLO");

			remove_task(id + TASK_PASSWORD);
		}
		case 2:
		{
			cod_print_chat(id, "Wprowadz swoje^x04 aktualne haslo^x01 w celu potwierdzenia tozsamosci.");
			
			set_hudmessage(255, 128, 0, 0.22, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, hudSync, "Wprowadz swoje aktualne haslo.");
			
			client_cmd(id, "messagemode WPROWADZ_AKTUALNE_HASLO");
		}
		case 3: 
		{
			cod_print_chat(id, "Wprowadz swoje^x04 aktualne haslo^x01 w celu potwierdzenia tozsamosci.");
			
			set_hudmessage(255, 128, 0, 0.22, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, hudSync, "Wprowadz swoje aktualne haslo.");
			
			client_cmd(id, "messagemode WPROWADZ_SWOJE_AKTUALNE_HASLO");
		}
		case 4: 
		{
			cod_print_chat(id, "Zalogowales sie jako^x04 Gosc^x01. By zabezpieczyc swoj nick^x04 zarejestruj sie^x01.");
			
			set_hudmessage(0, 255, 0, -1.0, 0.9, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, hudSync, "Zostales pomyslnie zalogowany jako Gosc.");
			
			remove_task(id + TASK_PASSWORD);
			
			playerStatus[id] = GUEST;
			
			engclient_cmd(id, "chooseteam");
		}
	}

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public login_account(id)
{
	if(playerStatus[id] != NOT_LOGGED || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;
	
	new password[33];
	
	read_args(password, charsmax(password));
	
	remove_quotes(password);

	if(!equal(playerPassword[id], password))
	{
		if(++playerFails[id] >= 3) server_cmd("kick #%d ^"Nieprawidlowe haslo!^"", get_user_userid(id));
		
		cod_print_chat(id, "Podane haslo jest^x04 nieprawidlowe^x01. (Bledne haslo^x04 %i/3^x01)", playerFails[id]);
		
		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, hudSync, "Podane haslo jest nieprawidlowe.");
		
		account_menu(id, 0);
		
		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

	playerStatus[id] = LOGGED;

	playerFails[id] = 0;

	remove_task(id + TASK_PASSWORD);
	
	cod_print_chat(id, "Zostales pomyslnie^x04 zalogowany^x01. Zyczymy milej gry.");
	
	set_hudmessage(0, 255, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	ShowSyncHudMsg(id, hudSync, "Zostales pomyslnie zalogowany.");
	
	engclient_cmd(id, "chooseteam");
	
	return PLUGIN_HANDLED;
}

public register_step_one(id)
{
	if((playerStatus[id] != NOT_REGISTERED && playerStatus[id] != GUEST) || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;

	new password[33];
	
	read_args(password, charsmax(password));
	remove_quotes(password);
	
	if(strlen(password) < 5)
	{
		cod_print_chat(id, "Haslo musi miec co najmniej^x04 5 znakow^x01.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, hudSync, "Haslo musi miec co najmniej 5 znakow.");
		
		account_menu(id, 0);
		
		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	copy(playerTempPassword[id], charsmax(playerTempPassword), password);
	
	cod_print_chat(id, "Teraz powtorz wybrane^x04 haslo^x01.");
	
	set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	ShowSyncHudMsg(id, hudSync, "Powtorz wybrane haslo.");
	
	client_cmd(id, "messagemode POWTORZ_WYBRANE_HASLO");
	
	return PLUGIN_HANDLED;
}
	
public register_step_two(id)
{
	if((playerStatus[id] != NOT_REGISTERED && playerStatus[id] != GUEST) || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;
	
	new password[33];
	
	read_args(password, charsmax(password));
	remove_quotes(password);
	
	if(!equal(password, playerTempPassword[id]))
	{
		cod_print_chat(id, "Podane hasla^x04 roznia sie^x01 od siebie.");
		
		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, hudSync, "Podane hasla roznia sie od siebie.");
		
		account_menu(id, 0);
		
		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[192];
	
	formatex(menuData, charsmax(menuData), "\rPOTWIERDZENIE REJESTRACJI^n^n\wTwoj Nick: \y[\r%s\y]^n\wTwoje Haslo: \y[\r%s\y]", playerName[id], playerTempPassword[id]);

	new menu = menu_create(menuData, "register_confirmation_handle");
	
	menu_additem(menu, "\rPotwierdz \wRejestracje");
	menu_additem(menu, "\yZmien \wHaslo^n");
	menu_additem(menu, "\wAnuluj \wRejestracje");
 
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public register_confirmation_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
		
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	menu_destroy(menu);

	switch(item)
	{
		case 0:
		{
			playerStatus[id] = LOGGED;
			
			copy(playerPassword[id], charsmax(playerPassword[]), playerTempPassword[id]);

			account_query(id, INSERT);

			client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);
	
			set_hudmessage(0, 255, 0, -1.0, 0.9, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, hudSync, "Zostales pomyslnie zarejestrowany i zalogowany.");
	
			cod_print_chat(id, "Twoj nick zostal pomyslnie^x04 zarejestrowany^x01.");
			cod_print_chat(id, "Wpisz w konsoli komende^x04 setinfo ^"%s^" ^"%s^"^x01, aby twoje haslo bylo ladowane automatycznie.", SETINFO, playerPassword[id]);
	
			cmd_execute(id, "setinfo %s %s", SETINFO, playerPassword[id]);
			cmd_execute(id, "writecfg %s", CONFIG);
	
			engclient_cmd(id, "chooseteam");
		}
		case 1:
		{
			cod_print_chat(id, "Rozpoczales proces^x04 rejestracji^x01. Wprowadz wybrane^x04 haslo^x01.");

			client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
			set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			ShowSyncHudMsg(id, hudSync, "Wprowadz wybrane haslo.");
	
			client_cmd(id, "messagemode WPROWADZ_WYBRANE_HASLO");
		}
		case 2: account_menu(id, 0);
	}
	
	return PLUGIN_HANDLED;
}

public change_step_one(id)
{
	if(playerStatus[id] != LOGGED || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;

	new password[33];
	
	read_args(password, charsmax(password));
	remove_quotes(password);
	
	if(!equal(playerPassword[id], password))
	{
		if(++playerFails[id] >= 3) server_cmd("kick #%d ^"Nieprawidlowe haslo!^"", get_user_userid(id));
		
		cod_print_chat(id, "Podane haslo jest^x04 nieprawidlowe^x01. (Bledne haslo^x04 %i/3^x01)", playerFails[id]);
		
		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, hudSync, "Podane haslo jest nieprawidlowe.");
		
		account_menu(id, 0);
		
		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	cod_print_chat(id, "Wprowadz swoje^x04 nowe haslo^x01.");

	set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	ShowSyncHudMsg(id, hudSync, "Wprowadz swoje nowe haslo.");

	client_cmd(id, "messagemode WPROWADZ_NOWE_HASLO");
	
	return PLUGIN_HANDLED;
}

public change_step_two(id)
{
	if(playerStatus[id] != LOGGED || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;

	new password[33];
	
	read_args(password, charsmax(password));
	remove_quotes(password);
	
	if(equal(playerPassword[id], password))
	{
		cod_print_chat(id, "Nowe haslo jest^x04 takie samo^x01 jak aktualne.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, hudSync, "Nowe haslo jest takie samo jak aktualne.");
		
		account_menu(id, 0);
		
		return PLUGIN_HANDLED;
	}
	
	if(strlen(password) < 5)
	{
		cod_print_chat(id, "Nowe haslo musi miec co najmniej^x04 5 znakow^x01.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, hudSync, "Nowe haslo musi miec co najmniej 5 znakow.");
		
		account_menu(id, 0);
		
		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	copy(playerTempPassword[id], charsmax(playerTempPassword), password);
	
	cod_print_chat(id, "Powtorz swoje nowe^x04 haslo^x01.");
	
	set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	ShowSyncHudMsg(id, hudSync, "Powtorz swoje nowe haslo.");
	
	client_cmd(id, "messagemode POWTORZ_NOWE_HASLO");
	
	return PLUGIN_HANDLED;
}

public change_step_three(id)
{
	if(playerStatus[id] != LOGGED || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;
	
	new password[33];
	
	read_args(password, charsmax(password));
	remove_quotes(password);
	
	if(!equal(password, playerTempPassword[id]))
	{
		cod_print_chat(id, "Podane hasla^x04 roznia sie^x01 od siebie.");
		
		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, hudSync, "Podane hasla roznia sie od siebie.");
		
		account_menu(id, 0);
		
		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);
	
	copy(playerPassword[id], charsmax(playerPassword[]), password);

	account_query(id, UPDATE);
	
	set_hudmessage(0, 255, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	ShowSyncHudMsg(id, hudSync, "Twoje haslo zostalo pomyslnie zmienione.");
	
	cod_print_chat(id, "Twoje haslo zostalo pomyslnie^x04 zmienione^x01.");
	cod_print_chat(id, "Wpisz w konsoli komende^x04 setinfo ^"%s^" ^"%s^"^x01, aby twoje haslo bylo ladowane automatycznie.", SETINFO, playerPassword[id]);
	
	cmd_execute(id, "setinfo %s %s", SETINFO, playerPassword[id]);
	cmd_execute(id, "writecfg %s", CONFIG);
	
	return PLUGIN_HANDLED;
}

public delete_account(id)
{
	if(playerStatus[id] != LOGGED || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;
		
	new password[33];
	
	read_args(password, charsmax(password));
	remove_quotes(password);
	
	if(!equal(playerPassword[id], password))
	{
		if(++playerFails[id] >= 3) server_cmd("kick #%d ^"Nieprawidlowe haslo!^"", get_user_userid(id));
		
		cod_print_chat(id, "Podane haslo jest^x04 nieprawidlowe^x01. (Bledne haslo^x04 %i/3^x01)", playerFails[id]);
		
		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		ShowSyncHudMsg(id, hudSync, "Podane haslo jest nieprawidlowe.");
		
		account_menu(id, 0);
		
		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menuData[128];
	
	formatex(menuData, charsmax(menuData), "\wCzy na pewno chcesz \rusunac \wswoje konto?");

	new menu = menu_create(menuData, "delete_account_handle");
	
	menu_additem(menu, "\rTak");
	menu_additem(menu, "\wNie^n");
	menu_additem(menu, "\wWyjdz");
 
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public delete_account_handle(id, menu, item)
{
	if(item == 0)
	{
		account_query(id, DELETE);
		
		console_print(id, "==================================");
		console_print(id, "==========SYSTEM REJESTRACJI==========");
		console_print(id, "              Skasowales konto o nicku: %s", playerName[id]);
		console_print(id, "==================================");
		
		server_cmd("kick #%d ^"Konto zostalo usuniete!^"", get_user_userid(id));
	}
	
	menu_destroy(menu);

	return PLUGIN_CONTINUE;
}

public sql_init()
{
	new host[32], user[32], pass[32], db[32], queryData[128], error[128], errorNum;
	
	get_cvar_string("cod_sql_host", host, charsmax(host));
	get_cvar_string("cod_sql_user", user, charsmax(user));
	get_cvar_string("cod_sql_pass", pass, charsmax(pass));
	get_cvar_string("cod_sql_db", db, charsmax(db));
	
	sql = SQL_MakeDbTuple(host, user, pass, db);

	new Handle:connectHandle = SQL_Connect(sql, errorNum, error, charsmax(error));
	
	if(errorNum)
	{
		log_to_file("cod_mod.log", "Error: %s", error);
		
		return;
	}
	
	formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_accounts` (`name` VARCHAR(64), `pass` VARCHAR(33), PRIMARY KEY(`name`));");

	new Handle:query = SQL_PrepareQuery(connectHandle, queryData);

	SQL_Execute(query);
	
	SQL_FreeHandle(query);
	SQL_FreeHandle(connectHandle);
}

public load_account(id)
{
	new queryData[128], tempId[1];
	
	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT * FROM `cod_accounts` WHERE name = '%s'", playerSafeName[id]);
	SQL_ThreadQuery(sql, "load_account_handle", queryData, tempId, sizeof(tempId));
}

public load_account_handle(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if(failState) 
	{
		log_to_file("cod_mod.log", "SQL Error: %s (%d)", error, errorNum);
		
		return;
	}
	
	new id = tempId[0];
	
	if(SQL_MoreResults(query))
	{
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "pass"), playerPassword[id], charsmax(playerPassword[]));
		
		if(!equal(playerPassword[id], ""))
		{
			new password[33];
		
			cmd_execute(id, "exec %s.cfg", CONFIG);
		
			get_user_info(id, SETINFO, password, charsmax(password));

			if(equal(playerPassword[id], password))
			{
				playerStatus[id] = LOGGED;
				
				set_bit(id, autoLogin);
			}
			else playerStatus[id] = NOT_LOGGED;
		}
	}

	set_bit(id, dataLoaded);
}

public account_query(id, type)
{
	if(!is_user_connected(id)) return;

	new queryData[128], password[33];

	mysql_escape_string(playerPassword[id], password, charsmax(password));

	switch(type)
	{
		case INSERT: formatex(queryData, charsmax(queryData), "INSERT INTO `cod_accounts` VALUES ('%s', '%s')", playerSafeName[id], password);
		case UPDATE: formatex(queryData, charsmax(queryData), "UPDATE `cod_accounts` SET pass = '%s' WHERE name = '%s'", password, playerSafeName[id]);
		case DELETE: formatex(queryData, charsmax(queryData), "DELETE FROM `cod_accounts` WHERE name = '%s'", playerSafeName[id]);
	}

	SQL_ThreadQuery(sql, "ignore_handle", queryData);
}

public ignore_handle(failState, Handle:query, error[], errorNum, data[], dataSize)
{
	if (failState) 
	{
		if(failState == TQUERY_CONNECT_FAILED) log_to_file("cod_mod.log", "Could not connect to SQL database. [%d] %s", errorNum, error);
		else if (failState == TQUERY_QUERY_FAILED) log_to_file("cod_mod.log", "Query failed. [%d] %s", errorNum, error);
	}
	
	return PLUGIN_CONTINUE;
}

public _cod_check_account(plugin_id, num_params)
{
	new id = get_param(1);
	
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[CoD] Invalid Player (%d)", id);
		
		return 0;
	}
	
	if(playerStatus[id] < LOGGED)
	{
		cod_print_chat(id, "Musisz sie^x04 zalogowac^x01, aby miec dostep do glownych funkcji!");
		
		account_menu(id, 0);
		
		return 0;
	}
	
	return 1;
}