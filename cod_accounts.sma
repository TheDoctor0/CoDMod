#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Accounts"
#define AUTHOR "O'Zone"

#define TASK_PASSWORD   1945
#define TASK_LOAD       2491

enum _:playerInfo { STATUS, FAILS, PASSWORD[MAX_PASSWORD], TEMP_PASSWORD[MAX_PASSWORD], NAME[MAX_NAME], SAFE_NAME[MAX_SAFE_NAME] };
enum _:status { NOT_REGISTERED, NOT_LOGGED, LOGGED, GUEST };
enum _:queries { UPDATE, INSERT, DELETE };
new const accountStatus[status][] = { "Niezarejestrowany", "Niezalogowany", "Zalogowany", "Gosc" };

new const commandAccount[][] = { "konto", "say /haslo", "say_team /haslo", "say /password", "say_team /password",
	"say /konto", "say_team /konto", "say /account", "say_team /account" };

new playerData[MAX_PLAYERS + 1][playerInfo], dataLoaded, autoLogin,
	cvarAccountsEnabled, cvarLoginMaxTime, cvarPasswordMaxFails, cvarPasswordMinLength, cvarAutoLoginConfig, cvarSetinfo[32];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for (new i; i < sizeof commandAccount; i++) register_clcmd(commandAccount[i], "account_menu");

	bind_pcvar_num(create_cvar("cod_accounts_enabled", "1"), cvarAccountsEnabled);
	bind_pcvar_num(create_cvar("cod_accounts_login_max_time", "60"), cvarLoginMaxTime);
	bind_pcvar_num(create_cvar("cod_accounts_password_max_fails", "3"), cvarPasswordMaxFails);
	bind_pcvar_num(create_cvar("cod_accounts_password_min_length", "5"), cvarPasswordMinLength);
	bind_pcvar_num(create_cvar("cod_accounts_autologin_config", "1"), cvarAutoLoginConfig);
	bind_pcvar_string(create_cvar("cod_accounts_autologin_setinfo", "codpass"), cvarSetinfo, charsmax(cvarSetinfo));

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
}

public plugin_natives()
	register_native("cod_check_account", "_cod_check_account");

public cod_reset_all_data()
{
	for (new i = 1; i <= MAX_PLAYERS; i++) {
		rem_bit(i, dataLoaded);

		playerData[i][STATUS] = NOT_REGISTERED;
	}
}

public client_connect(id)
{
	playerData[id][PASSWORD] = "";
	playerData[id][STATUS] = NOT_REGISTERED;
	playerData[id][FAILS] = 0;

	rem_bit(id, dataLoaded);
	rem_bit(id, autoLogin);

	if (is_user_bot(id) || is_user_hltv(id) || !cvarAccountsEnabled) return;

	get_user_name(id, playerData[id][NAME], charsmax(playerData[][NAME]));
}

public cod_player_loaded(id, playerId)
	load_account(id);

public client_disconnected(id)
{
	remove_task(id + TASK_PASSWORD);
	remove_task(id + TASK_LOAD);
	remove_task(id);
}

public message_show_menu(msgId, dest, id)
{
	if (!cvarAccountsEnabled) return PLUGIN_CONTINUE;

	new const Team_Select[] = "#Team_Select";
	static menuData[sizeof(Team_Select)];

	get_msg_arg_string(4, menuData, charsmax(menuData));

	if (equal(menuData, Team_Select) && get_bit(id, dataLoaded) && playerData[id][STATUS] < LOGGED ) {
		set_pdata_int(id, 205, 0, 5);

		set_task(0.1, "account_menu", id);

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message_vgui_menu(msgId, dest, id)
{
	if (get_msg_arg_int(1) == 2 && cvarAccountsEnabled && get_bit(id, dataLoaded) && playerData[id][STATUS] < LOGGED ) {
		set_task(0.1, "account_menu", id);

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public check_account(id)
{
	if (cvarAccountsEnabled && playerData[id][STATUS] < LOGGED) {
		account_menu(id, true);

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public kick_player(id)
{
	id -= TASK_PASSWORD;

	if (is_user_connected(id)) server_cmd("kick #%d ^"Nie zalogowales sie w ciagu %is!^"", get_user_userid(id), cvarLoginMaxTime);
}

public account_menu(id, sound)
{
	if (!cvarAccountsEnabled || !is_user_connected(id) || !is_user_valid(id)) return PLUGIN_HANDLED;

	if (!get_bit(id, dataLoaded)) {
		remove_task(id);

		set_task(1.0, "account_menu", id);

		return PLUGIN_HANDLED;
	}

	if (!get_user_team(id) && playerData[id][STATUS] == LOGGED) {
		client_cmd(id, "chooseteam");
		engclient_cmd(id, "chooseteam");

		return PLUGIN_HANDLED;
	} else if (playerData[id][STATUS] < LOGGED) {
		cod_display_fade(id, 0, 0, 0x0001|0x0004, 0, 0, 0, 255);
	}

	if (sound) cod_play_sound(id, SOUND_SELECT);

	if (playerData[id][STATUS] <= NOT_LOGGED && !task_exists(id + TASK_PASSWORD) && cvarLoginMaxTime) set_task(float(cvarLoginMaxTime), "kick_player", id + TASK_PASSWORD);

	static menuData[256];

	formatex(menuData, charsmax(menuData), "\rSYSTEM REJESTRACJI^n^n\rNick: \w[\y%s\w]^n\rStatus: \w[\y%s\w]", playerData[id][NAME], accountStatus[playerData[id][STATUS]]);

	if ((playerData[id][STATUS] == NOT_LOGGED || playerData[id][STATUS] == LOGGED) && !get_bit(id, autoLogin)) {
		if (cvarAutoLoginConfig) format(menuData, charsmax(menuData),"%s^n\wWpisz w konsoli \ysetinfo ^"_%s^" ^"twojehaslo^"^n\wSprawi to, ze twoje haslo bedzie ladowane \rautomatycznie\w.", menuData, cvarSetinfo);
		else format(menuData, charsmax(menuData),"%s^n\wDopisz \ysetinfo ^"_%s^" ^"twojehaslo^" do swojego configu^n\wSprawi to, ze twoje haslo bedzie ladowane \rautomatycznie\w.", menuData, cvarSetinfo);
	}

	new menu = menu_create(menuData, "account_menu_handle"), callback = menu_makecallback("account_menu_callback");

	menu_additem(menu, "\yLogowanie", _, _, callback);
	menu_additem(menu, "\yRejestracja^n", _, _, callback);
	menu_additem(menu, "\yZmien \wHaslo", _, _, callback);
	menu_additem(menu, "\ySkasuj \wKonto^n", _, _, callback);
	menu_additem(menu, "\yZaloguj jako \wGosc \r(NIEZALECANE)^n", _, _, callback);

	if (playerData[id][STATUS] == LOGGED) menu_additem(menu, "\wWyjdz", _, _, callback);

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public account_menu_callback(id, menu, item)
{
	switch (item) {
		case 0: return playerData[id][STATUS] == NOT_LOGGED ? ITEM_ENABLED : ITEM_DISABLED;
		case 1: return (playerData[id][STATUS] == NOT_REGISTERED || playerData[id][STATUS] == GUEST) ? ITEM_ENABLED : ITEM_DISABLED;
		case 2, 3: return playerData[id][STATUS] == LOGGED ? ITEM_ENABLED : ITEM_DISABLED;
		case 4: return playerData[id][STATUS] == NOT_REGISTERED ? ITEM_ENABLED : ITEM_DISABLED;
	}

	return ITEM_ENABLED;
}

public account_menu_handle(id, menu, item)
{
	if (!cvarAccountsEnabled || !is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT || item == 5) {
		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	switch (item) {
		case 0: {
			cod_print_chat(id, "Wprowadz swoje^4 haslo^1, aby sie^4 zalogowac.");

			set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			show_hudmessage(id, "Wprowadz swoje haslo.");

			client_cmd(id, "messagemode WPROWADZ_SWOJE_HASLO");
		} case 1: {
			cod_print_chat(id, "Rozpoczales proces^4 rejestracji^1. Wprowadz wybrane^4 haslo^1.");

			set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			show_hudmessage(id, "Wprowadz swoje haslo.");

			client_cmd(id, "messagemode WPROWADZ_WYBRANE_HASLO");

			remove_task(id + TASK_PASSWORD);
		} case 2: {
			cod_print_chat(id, "Wprowadz swoje^4 aktualne haslo^1 w celu potwierdzenia tozsamosci.");

			set_hudmessage(255, 128, 0, 0.22, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			show_hudmessage(id, "Wprowadz swoje aktualne haslo.");

			client_cmd(id, "messagemode WPROWADZ_AKTUALNE_HASLO");
		} case 3: {
			cod_print_chat(id, "Wprowadz swoje^4 aktualne haslo^1 w celu potwierdzenia tozsamosci.");

			set_hudmessage(255, 128, 0, 0.22, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			show_hudmessage(id, "Wprowadz swoje aktualne haslo.");

			client_cmd(id, "messagemode WPROWADZ_SWOJE_AKTUALNE_HASLO");
		} case 4: {
			cod_print_chat(id, "Zalogowales sie jako^4 Gosc^1. By zabezpieczyc swoj nick^4 zarejestruj sie^1.");

			set_hudmessage(0, 255, 0, -1.0, 0.9, 0, 0.0, 3.5, 0.0, 0.0);
			show_hudmessage(id, "Zostales pomyslnie zalogowany jako Gosc.");

			remove_task(id + TASK_PASSWORD);

			playerData[id][STATUS] = GUEST;

			client_cmd(id, "chooseteam");

			engclient_cmd(id, "chooseteam");
		}
	}

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public login_account(id)
{
	if (!cvarAccountsEnabled || playerData[id][STATUS] != NOT_LOGGED || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;

	new password[MAX_PASSWORD];

	read_args(password, charsmax(password));

	remove_quotes(password);

	if (!equal(playerData[id][PASSWORD], password)) {
		if (cvarPasswordMaxFails) {
			if (++playerData[id][FAILS] >= cvarPasswordMaxFails) server_cmd("kick #%d ^"Nieprawidlowe haslo!^"", get_user_userid(id));

			cod_print_chat(id, "Podane haslo jest^4 nieprawidlowe^1. (Bledne haslo^4 %i/%i^1)", playerData[id][FAILS], cvarPasswordMaxFails);
		} else cod_print_chat(id, "Podane haslo jest^4 nieprawidlowe^1.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);

		show_hudmessage(id, "Podane haslo jest nieprawidlowe.");

		account_menu(id, true);

		return PLUGIN_HANDLED;
	}

	playerData[id][STATUS] = LOGGED;
	playerData[id][FAILS] = 0;

	remove_task(id + TASK_PASSWORD);

	cod_display_fade(id, 0, 0, 0x0000, 0, 0, 0, 255);

	cod_print_chat(id, "Zostales pomyslnie^4 zalogowany^1. Zyczymy milej gry.");

	set_hudmessage(0, 255, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	show_hudmessage(id, "Zostales pomyslnie zalogowany.");

	client_cmd(id, "chooseteam");
	engclient_cmd(id, "chooseteam");

	return PLUGIN_HANDLED;
}

public register_step_one(id)
{
	if (!cvarAccountsEnabled || (playerData[id][STATUS] != NOT_REGISTERED && playerData[id][STATUS] != GUEST) || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;

	new password[MAX_PASSWORD];

	read_args(password, charsmax(password));
	remove_quotes(password);

	if (strlen(password) < cvarPasswordMinLength) {
		cod_print_chat(id, "Haslo musi miec co najmniej^4 %i znakow^1.", cvarPasswordMinLength);

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		show_hudmessage(id, "Haslo musi miec co najmniej %i znakow.", cvarPasswordMinLength);

		account_menu(id, true);

		return PLUGIN_HANDLED;
	}

	copy(playerData[id][TEMP_PASSWORD], charsmax(playerData[][TEMP_PASSWORD]), password);

	cod_print_chat(id, "Teraz powtorz wybrane^4 haslo^1.");

	set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	show_hudmessage(id, "Powtorz wybrane haslo.");

	client_cmd(id, "messagemode POWTORZ_WYBRANE_HASLO");

	return PLUGIN_HANDLED;
}

public register_step_two(id)
{
	if (!cvarAccountsEnabled || (playerData[id][STATUS] != NOT_REGISTERED && playerData[id][STATUS] != GUEST) || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;

	new password[MAX_PASSWORD];

	read_args(password, charsmax(password));
	remove_quotes(password);

	if (!equal(password, playerData[id][TEMP_PASSWORD])) {
		cod_print_chat(id, "Podane hasla^4 roznia sie^1 od siebie.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		show_hudmessage(id, "Podane hasla roznia sie od siebie.");

		account_menu(id, true);

		return PLUGIN_HANDLED;
	}

	new menuData[192];

	formatex(menuData, charsmax(menuData), "\rPOTWIERDZENIE REJESTRACJI^n^n\wTwoj Nick: \y[\r%s\y]^n\wTwoje Haslo: \y[\r%s\y]", playerData[id][NAME], playerData[id][TEMP_PASSWORD]);

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
	if (!cvarAccountsEnabled || !is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	menu_destroy(menu);

	switch (item) {
		case 0: {
			playerData[id][STATUS] = LOGGED;

			copy(playerData[id][PASSWORD], charsmax(playerData[][PASSWORD]), playerData[id][TEMP_PASSWORD]);

			account_query(id, INSERT);

			cod_display_fade(id, 0, 0, 0x0000, 0, 0, 0, 255);

			set_hudmessage(0, 255, 0, -1.0, 0.9, 0, 0.0, 3.5, 0.0, 0.0);
			show_hudmessage(id, "Zostales pomyslnie zarejestrowany i zalogowany.");

			cod_print_chat(id, "Twoj nick zostal pomyslnie^4 zarejestrowany^1.");

			if (cvarAutoLoginConfig) {
				cod_print_chat(id, "Wpisz w konsoli komende^4 setinfo ^"_%s^" ^"%s^"^1, aby twoje haslo bylo ladowane automatycznie.", cvarSetinfo, playerData[id][PASSWORD]);

				cod_cmd_execute(id, "setinfo _%s %s", cvarSetinfo, playerData[id][PASSWORD]);
				cod_cmd_execute(id, "writecfg %s", cvarSetinfo);
			} else {
				cod_print_chat(id, "Dopisz komende^4 setinfo ^"_%s^" ^"%s^"^1 do swojego configu, aby twoje haslo bylo ladowane automatycznie.", cvarSetinfo, playerData[id][PASSWORD]);
			}

			client_cmd(id, "chooseteam");
			engclient_cmd(id, "chooseteam");
		} case 1: {
			cod_print_chat(id, "Rozpoczales proces^4 rejestracji^1. Wprowadz wybrane^4 haslo^1.");

			set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
			show_hudmessage(id, "Wprowadz wybrane haslo.");

			client_cmd(id, "messagemode WPROWADZ_WYBRANE_HASLO");
		} case 2: account_menu(id, false);
	}

	return PLUGIN_HANDLED;
}

public change_step_one(id)
{
	if (!cvarAccountsEnabled || playerData[id][STATUS] != LOGGED || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;

	new password[MAX_PASSWORD];

	read_args(password, charsmax(password));
	remove_quotes(password);

	if (!equal(playerData[id][PASSWORD], password)) {
		if (cvarPasswordMaxFails) {
			if (++playerData[id][FAILS] >= cvarPasswordMaxFails) server_cmd("kick #%d ^"Nieprawidlowe haslo!^"", get_user_userid(id));

			cod_print_chat(id, "Podane haslo jest^4 nieprawidlowe^1. (Bledne haslo^4 %i/%i^1)", playerData[id][FAILS], cvarPasswordMaxFails);
		} else cod_print_chat(id, "Podane haslo jest^4 nieprawidlowe^1.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		show_hudmessage(id, "Podane haslo jest nieprawidlowe.");

		account_menu(id, true);

		return PLUGIN_HANDLED;
	}

	cod_print_chat(id, "Wprowadz swoje^4 nowe haslo^1.");

	set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	show_hudmessage(id, "Wprowadz swoje nowe haslo.");

	client_cmd(id, "messagemode WPROWADZ_NOWE_HASLO");

	return PLUGIN_HANDLED;
}

public change_step_two(id)
{
	if (!cvarAccountsEnabled || playerData[id][STATUS] != LOGGED || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;

	new password[MAX_PASSWORD];

	read_args(password, charsmax(password));
	remove_quotes(password);

	if (equal(playerData[id][PASSWORD], password)) {
		cod_print_chat(id, "Nowe haslo jest^4 takie samo^1 jak aktualne.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		show_hudmessage(id, "Nowe haslo jest takie samo jak aktualne.");

		account_menu(id, true);

		return PLUGIN_HANDLED;
	}

	if (strlen(password) < cvarPasswordMinLength) {
		cod_print_chat(id, "Nowe haslo musi miec co najmniej^4 %i znakow^1.", cvarPasswordMinLength);

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		show_hudmessage(id, "Nowe haslo musi miec co najmniej %i znakow.", cvarPasswordMinLength);

		account_menu(id, true);

		return PLUGIN_HANDLED;
	}

	copy(playerData[id][TEMP_PASSWORD], charsmax(playerData[][TEMP_PASSWORD]), password);

	cod_print_chat(id, "Powtorz swoje nowe^4 haslo^1.");

	set_hudmessage(255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	show_hudmessage(id, "Powtorz swoje nowe haslo.");

	client_cmd(id, "messagemode POWTORZ_NOWE_HASLO");

	return PLUGIN_HANDLED;
}

public change_step_three(id)
{
	if (!cvarAccountsEnabled || playerData[id][STATUS] != LOGGED || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;

	new password[MAX_PASSWORD];

	read_args(password, charsmax(password));
	remove_quotes(password);

	if (!equal(password, playerData[id][TEMP_PASSWORD])) {
		cod_print_chat(id, "Podane hasla^4 roznia sie^1 od siebie.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		show_hudmessage(id, "Podane hasla roznia sie od siebie.");

		account_menu(id, true);

		return PLUGIN_HANDLED;
	}

	copy(playerData[id][PASSWORD], charsmax(playerData[][PASSWORD]), password);

	account_query(id, UPDATE);

	set_hudmessage(0, 255, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
	show_hudmessage(id, "Twoje haslo zostalo pomyslnie zmienione.");

	cod_print_chat(id, "Twoje haslo zostalo pomyslnie^4 zmienione^1.");

	if (cvarAutoLoginConfig) {
		cod_print_chat(id, "Wpisz w konsoli komende^4 setinfo ^"_%s^" ^"%s^"^1, aby twoje haslo bylo ladowane automatycznie.", cvarSetinfo, playerData[id][PASSWORD]);

		cod_cmd_execute(id, "setinfo _%s %s", cvarSetinfo, playerData[id][PASSWORD]);
		cod_cmd_execute(id, "writecfg %s", cvarSetinfo);
	} else {
		cod_print_chat(id, "Dopisz komende^4 setinfo ^"_%s^" ^"%s^"^1 do swojego configu, aby twoje haslo bylo ladowane automatycznie.", cvarSetinfo, playerData[id][PASSWORD]);
	}

	return PLUGIN_HANDLED;
}

public delete_account(id)
{
	if (!cvarAccountsEnabled || playerData[id][STATUS] != LOGGED || !get_bit(id, dataLoaded)) return PLUGIN_HANDLED;

	new password[MAX_PASSWORD];

	read_args(password, charsmax(password));
	remove_quotes(password);

	if (!equal(playerData[id][PASSWORD], password)) {
		if (cvarPasswordMaxFails) {
			if (++playerData[id][FAILS] >= cvarPasswordMaxFails) server_cmd("kick #%d ^"Nieprawidlowe haslo!^"", get_user_userid(id));

			cod_print_chat(id, "Podane haslo jest^4 nieprawidlowe^1. (Bledne haslo^4 %i/%i^1)", playerData[id][FAILS], cvarPasswordMaxFails);
		} else cod_print_chat(id, "Podane haslo jest^4 nieprawidlowe^1.");

		set_hudmessage(255, 0, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0);
		show_hudmessage(id, "Podane haslo jest nieprawidlowe.");

		account_menu(id, true);

		return PLUGIN_HANDLED;
	}

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
	if (item == 0) {
		account_query(id, DELETE);

		console_print(id, "==================================");
		console_print(id, "==========SYSTEM REJESTRACJI==========");
		console_print(id, "              Skasowales konto o nicku: %s", playerData[id][NAME]);
		console_print(id, "==================================");

		server_cmd("kick #%d ^"Konto zostalo usuniete!^"", get_user_userid(id));
	}

	menu_destroy(menu);

	return PLUGIN_CONTINUE;
}

public load_account(id)
{
	cod_get_player_password(id, playerData[id][PASSWORD], charsmax(playerData[][PASSWORD]));

	if (playerData[id][PASSWORD][0]) {
		new password[MAX_PASSWORD], info[32];

		formatex(info, charsmax(info), "_%s", cvarSetinfo);

		if (cvarAutoLoginConfig) cod_cmd_execute(id, "exec %s.cfg", cvarSetinfo);

		get_user_info(id, info, password, charsmax(password));

		if (equal(playerData[id][PASSWORD], password)) {
			playerData[id][STATUS] = LOGGED;

			cod_display_fade(id, 0, 0, 0x0000, 0, 0, 0, 255);

			set_bit(id, autoLogin);
		} else {
			playerData[id][STATUS] = NOT_LOGGED;

			cod_print_chat(id, "Musisz sie^3 zalogowac^1, aby miec dostep do glownych funkcji!");

			account_menu(id, true);
		}

		if (cvarAutoLoginConfig) cod_cmd_execute(id, "exec config.cfg");
	}

	set_bit(id, dataLoaded);
}

public account_query(id, type)
{
	if (!is_user_connected(id)) return;

	switch (type) {
		case INSERT, UPDATE: cod_set_player_password(id, playerData[id][PASSWORD]);
		case DELETE: cod_delete_player(id);
	}
}

public _cod_check_account(plugin_id, num_params)
{
	if (!cvarAccountsEnabled) return 1;

	new id = get_param(1);

	if (!is_user_valid(id)) {
		cod_log_error(PLUGIN, "Invalid Player (ID: %d)", id);

		return 0;
	}

	if (playerData[id][STATUS] < LOGGED) {
		cod_print_chat(id, "Musisz sie^3 zalogowac^1, aby miec dostep do glownych funkcji!");

		account_menu(id, true);

		return 0;
	}

	return 1;
}