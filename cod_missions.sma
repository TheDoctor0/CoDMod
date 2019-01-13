#include <amxmodx>
#include <cstrike>
#include <nvault>
#include <cod>

#define PLUGIN "CoD Missions"
#define VERSION "1.1.1"
#define AUTHOR "O'Zone"

new missionDescription[][] =
{
	"Brak misji %i",
	"Musisz zabic jeszcze %i osob",
	"Musisz zabic jeszcze %i osob headshotem",
	"Musisz podlozyc bombe jeszcze %i razy",
	"Musisz rozbroic bombe jeszcze %i razy",
	"Musisz uratowac jeszcze %i hostow",
	"Musisz zadac jeszcze %i obrazen",
	"Musisz zabic klase %s jeszcze %i razy",
	"Musisz znalezc item %s jeszcze %i razy"
};

new const commandMission[][] = { "misje", "say /quest", "say_team /quest", "say /misja", "say_team /misja", "say /misje", "say_team /misje", "say /questy", "say_team /questy" };
new const commandProgress[][] = { "postep", "say /progress", "say_team /progress", "say /progres", "say_team /progres", "say /postep", "say_team /postep" };
new const commandEnd[][] = { "przerwij", "say /koniec", "say_team /koniec", "say /zakoncz", "say_team /zakoncz", "zakoncz", "say_team /przerwij", "say /przerwij" };

enum _:missionType { TYPE_NONE, TYPE_KILL, TYPE_HEADSHOT, TYPE_PLANT, TYPE_DEFUSE, TYPE_RESCUE, TYPE_DAMAGE, TYPE_CLASS, TYPE_ITEM };
enum _:playerInfo { PLAYER_ID, PLAYER_TYPE, PLAYER_ADDITIONAL, PLAYER_PROGRESS, PLAYER_CHAPTER };
enum _:chapterInfo { CHAPTER_NAME[MAX_NAME], CHAPTER_START, CHAPTER_END };
enum _:missionInfo { MISSION_CHAPTER, MISSION_AMOUNT, MISSION_TYPE, MISSION_REWARD };

new playerClass[MAX_PLAYERS + 1][MAX_NAME], playerName[MAX_PLAYERS + 1][MAX_NAME], playerData[MAX_PLAYERS + 1][playerInfo], Array:codChapters, Array:codMissions, cvarMinPlayers, missions, loaded;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	bind_pcvar_num(create_cvar("cod_missions_min_players", "4"), cvarMinPlayers);

	for (new i; i < sizeof commandMission; i++) register_clcmd(commandMission[i], "mission_menu");
	for (new i; i < sizeof commandProgress; i++) register_clcmd(commandProgress[i], "check_mission");
	for (new i; i < sizeof commandEnd; i++) register_clcmd(commandEnd[i], "reset_mission");

	register_logevent("log_event_mission", 3, "1=triggered");

	missions = nvault_open("cod_missions");

	if (missions == INVALID_HANDLE) set_fail_state("Nie mozna otworzyc pliku cod_missions.vault");

	codChapters = ArrayCreate(chapterInfo);
	codMissions = ArrayCreate(missionInfo);
}

public plugin_natives()
{
	register_native("cod_get_user_mission", "get_mission", 1);
	register_native("cod_get_user_mission_progress", "get_progress", 1);
	register_native("cod_get_user_mission_need", "get_progress_need", 1);
}

public plugin_cfg()
{
	new filePath[64];

	get_localinfo("amxx_configsdir", filePath, charsmax(filePath));

	format(filePath, charsmax(filePath), "%s/cod_missions.ini", filePath);

	if (!file_exists(filePath)) {
		new error[128];

		formatex(error, charsmax(error), "[CoD Missions] Nie mozna znalezc pliku cod_missions.ini w lokalizacji %s.", filePath);

		set_fail_state(error);
	}

	new lineData[128], chapterData[3][MAX_NAME], missionData[4][16], codMission[missionInfo], codChapter[chapterInfo], bool:missions = false, file = fopen(filePath, "r");

	while (!feof(file)) {
		fgets(file, lineData, charsmax(lineData));
		trim(lineData);

		if (lineData[0] == ';' || lineData[0] == '^0' || lineData[0] == '/') continue;

		if (lineData[0] == '[' && (lineData[1] == 'C' || lineData[1] == 'R')) {
			missions = false;

			continue;
		} else if (lineData[0] == '[' && lineData[1] == 'M') {
			missions = true;

			continue;
		}

		if (missions) {
			parse(lineData, missionData[0], charsmax(missionData[]), missionData[1], charsmax(missionData[]), missionData[2], charsmax(missionData[]), missionData[3], charsmax(missionData[]));

			codMission[MISSION_CHAPTER] = str_to_num(missionData[0]);
			codMission[MISSION_AMOUNT] = str_to_num(missionData[1]);
			codMission[MISSION_TYPE] = str_to_num(missionData[2]);
			codMission[MISSION_REWARD] = str_to_num(missionData[3]);

			ArrayPushArray(codMissions, codMission);
		} else {
			parse(lineData, chapterData[0], charsmax(chapterData[]), chapterData[1], charsmax(chapterData[]), chapterData[2], charsmax(chapterData[]));

			copy(codChapter[CHAPTER_NAME], charsmax(codChapter[CHAPTER_NAME]), chapterData[0]);
			codChapter[CHAPTER_START] = str_to_num(chapterData[1]);
			codChapter[CHAPTER_END] = str_to_num(chapterData[2]);

			ArrayPushArray(codChapters, codChapter);
		}
	}

	fclose(file);

	if (!ArraySize(codChapters)) set_fail_state("[CoD Missions] Nie zaladowano zadnego rozdzialu. Sprawdz plik konfiguracyjny cod_missions.ini!");
	if (!ArraySize(codMissions)) set_fail_state("[CoD Missions] Nie zaladowano zadnej misji. Sprawdz plik konfiguracyjny cod_missions.ini!");
}

public plugin_end()
	nvault_close(missions);

public client_disconnected(id)
	rem_bit(id, loaded);

public client_putinserver(id)
{
	get_user_name(id, playerName[id], charsmax(playerName[]));

	reset_mission(id, 1, 1);
}

public mission_menu(id)
{
	if (!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menu = menu_create("\yMenu \rMisji\w:", "mission_menu_handle"), callback = menu_makecallback("mission_menu_callback");

	menu_additem(menu, "Wybierz \yMisje", _, _, callback);
	menu_additem(menu, "Przerwij \yMisje", _, _, callback);
	menu_additem(menu, "Postep \yMisji", _, _, callback);

	menu_addtext(menu, "^n\wPo wykonaniu \ymisji\w zostaniesz wynagrodzony \rdoswiadczeniem\w.", 0);
	menu_addtext(menu, "\wMozesz \ywielokrotnie\w wykonywac ta sama misje.", 0);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public mission_menu_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
    }

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	switch (item) {
		case 0: select_chapter(id);
		case 1: reset_mission(id, 0, 0);
		case 2: check_mission(id);
	}

	return PLUGIN_HANDLED;
}

public mission_menu_callback(id, menu, item)
{
	switch (item) {
		case 0: if (playerData[id][PLAYER_TYPE]) return ITEM_DISABLED;
		case 1, 2: if (!playerData[id][PLAYER_TYPE]) return ITEM_DISABLED;
	}

	return ITEM_ENABLED;
}

public select_chapter(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (playerData[id][PLAYER_TYPE]) {
		cod_print_chat(id, "Najpierw wykonaj lub zrezygnuj z obecnej misji.");

		return PLUGIN_HANDLED;
	}

	new menuData[128], codChapter[chapterInfo], menu = menu_create("\yWybierz \rRozdzial\w:", "select_mission"), callback = menu_makecallback("select_chapter_callback");

	for (new i = 0; i < ArraySize(codChapters); i++) {
		ArrayGetArray(codChapters, i, codChapter);

		formatex(menuData, charsmax(menuData), "Rozdzial \y%s \w(\r%i \wPoziom - \r%i \wPoziom)", codChapter[CHAPTER_NAME], codChapter[CHAPTER_START], codChapter[CHAPTER_END]);

		menu_additem(menu, menuData, _, _, callback);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public select_chapter_callback(id, menu, item)
{
	new codChapter[chapterInfo];

	ArrayGetArray(codChapters, item, codChapter);

	if (cod_get_user_level(id) < codChapter[CHAPTER_START] || cod_get_user_level(id) > codChapter[CHAPTER_END]) return ITEM_DISABLED;

	return ITEM_ENABLED;
}

public select_mission(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
    }

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	playerData[id][PLAYER_CHAPTER] = item;

	menu_destroy(menu);

	new menuData[128], missionId[6], codMission[missionInfo], menu = menu_create("\yWybierz \rMisje\w:", "select_mission_handle");

	for (new i = 0; i < ArraySize(codMissions); i++) {
		ArrayGetArray(codMissions, i, codMission);

		if (playerData[id][PLAYER_CHAPTER] == codMission[MISSION_CHAPTER]) {
			switch (codMission[MISSION_TYPE]) {
				case TYPE_KILL: formatex(menuData, charsmax(menuData), "Zabij %i osob \y(Nagroda: %i Expa)", codMission[MISSION_AMOUNT], codMission[MISSION_REWARD]);
				case TYPE_HEADSHOT: formatex(menuData, charsmax(menuData), "Zabij %i osob z HS \y(Nagroda: %i Expa)",  codMission[MISSION_AMOUNT], codMission[MISSION_REWARD]);
				case TYPE_PLANT: formatex(menuData, charsmax(menuData), "Podloz %i bomb \y(Nagroda: %i Expa)",  codMission[MISSION_AMOUNT], codMission[MISSION_REWARD]);
				case TYPE_RESCUE: formatex(menuData, charsmax(menuData), "Uratuj %i razy hosty \y(Nagroda: %i Expa)",  codMission[MISSION_AMOUNT], codMission[MISSION_REWARD]);
				case TYPE_DEFUSE: formatex(menuData, charsmax(menuData), "Rozbroj %i bomb \y(Nagroda: %i Expa)",  codMission[MISSION_AMOUNT], codMission[MISSION_REWARD]);
				case TYPE_DAMAGE: formatex(menuData, charsmax(menuData), "Zadaj %i obrazen \y(Nagroda: %i Expa)",  codMission[MISSION_AMOUNT], codMission[MISSION_REWARD]);
				case TYPE_CLASS: formatex(menuData, charsmax(menuData), "Zabij %i razy wybrana klase \y(Nagroda: %i Expa)", codMission[MISSION_AMOUNT], codMission[MISSION_REWARD]);
				case TYPE_ITEM: formatex(menuData, charsmax(menuData), "Znajdz %i razy wybrany item \y(Nagroda: %i Expa)", codMission[MISSION_AMOUNT], codMission[MISSION_REWARD]);
				case TYPE_NONE: continue;
			}

			num_to_str(i, missionId, charsmax(missionId));

			menu_additem(menu, menuData, missionId);
		}
	}

	menu_addblank(menu);
	menu_additem(menu, "\wWyjscie");

	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public select_mission_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == TYPE_ITEM + 2) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new missionId[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, missionId, charsmax(missionId), _, _, itemCallback);

	reset_mission(id, 1, 1);

	playerData[id][PLAYER_ID] = str_to_num(missionId);
	playerData[id][PLAYER_TYPE] = get_mission_info(playerData[id][PLAYER_ID], MISSION_TYPE);

	switch (playerData[id][PLAYER_TYPE]) {
		case TYPE_CLASS: select_class(id);
		case TYPE_ITEM: select_item(id);
		default: {
			cod_print_chat(id, "Rozpoczales wykonywac^x03 misje^x01. Powodzenia!");

			save_mission(id);
		}
	}

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public select_class(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new menuData[128], className[MAX_NAME], classId[6], menu = menu_create("\yWybierz \rKlase \ydo \yMisji\w:", "select_handle");

	for (new i = 1; i < cod_get_classes_num(); i++) {
		cod_get_class_name(i, _, className, charsmax(className));

		formatex(menuData,charsmax(menuData), className);

		num_to_str(i, classId, charsmax(classId));

		menu_additem(menu, menuData, classId);
	}

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public select_item(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new menuData[128], itemName[MAX_NAME], itemId[6], menu = menu_create("\yWybierz \rItem \ydo \yMisji\w:", "select_handle");

	for (new i = 1; i < cod_get_items_num(); i++) {
		cod_get_item_name(i, itemName, charsmax(itemName));

		formatex(menuData,charsmax(menuData), itemName);

		num_to_str(i, itemId, charsmax(itemId));

		menu_additem(menu, menuData, itemId);
	}

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public select_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new missionData[6], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, missionData, charsmax(missionData), _, _, itemCallback);

	playerData[id][PLAYER_ADDITIONAL] = str_to_num(missionData);

	cod_print_chat(id, "Rozpoczales wykonywac^x03 misje^x01. Powodzenia!");

	save_mission(id);

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public cod_killed(killer, victim, weaponId, hitPlace)
{
	switch (playerData[killer][PLAYER_TYPE]) {
		case TYPE_KILL: add_progress(killer);
		case TYPE_HEADSHOT: if (hitPlace == HIT_HEAD) add_progress(killer);
		case TYPE_CLASS: if (playerData[killer][PLAYER_ADDITIONAL] == cod_get_user_class(victim)) add_progress(killer);
	}
}

public cod_item_changed(id, item)
	if (playerData[id][PLAYER_TYPE] == TYPE_ITEM && item == playerData[id][PLAYER_ADDITIONAL]) add_progress(id);

public cod_damage_post(attacker, victim, weapon, Float:damage, damageBits, hitPlace)
	if (playerData[attacker][PLAYER_TYPE] == TYPE_DAMAGE) add_progress(attacker, floatround(damage));

public log_event_mission()
{
	new userLog[80], userAction[64], userName[MAX_NAME];

	read_logargv(0, userLog, charsmax(userLog));
	read_logargv(2, userAction, charsmax(userAction));

	parse_loguser(userLog, userName, charsmax(userName));

	new id = get_user_index(userName);

	if (!is_user_connected(id) || playerData[id][PLAYER_TYPE] == TYPE_NONE) return PLUGIN_HANDLED;

	if (equal(userAction, "Planted_The_Bomb") && playerData[id][PLAYER_TYPE] == TYPE_PLANT) add_progress(id);
	if (equal(userAction, "Defused_The_Bomb") && playerData[id][PLAYER_TYPE] == TYPE_DEFUSE) add_progress(id);
	if (equal(userAction, "Rescued_A_Hostage") && playerData[id][PLAYER_TYPE] == TYPE_RESCUE) add_progress(id);

	return PLUGIN_HANDLED;
}

public give_reward(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new reward = cod_get_user_bonus_exp(id, get_mission_info(playerData[id][PLAYER_ID], MISSION_REWARD));

	cod_set_user_exp(id, reward);

	reset_mission(id, 0, 1);

	cod_print_chat(id, "Gratulacje! Ukonczyles swoja misje - otrzymujesz w nagrode^x03 %i^x01 doswiadczenia.", reward);

	return PLUGIN_HANDLED;
}

public check_mission(id)
{
	if (!playerData[id][PLAYER_TYPE]) cod_print_chat(id, "Nie wykonujesz zadnej misji.");
	else {
		new message[128], additional[MAX_NAME], codChapter[chapterInfo];

		ArrayGetArray(codChapters, playerData[id][PLAYER_CHAPTER], codChapter);

		if (playerData[id][PLAYER_TYPE] == TYPE_CLASS) cod_get_class_name(playerData[id][PLAYER_ADDITIONAL], _, additional, charsmax(additional));
		else if (playerData[id][PLAYER_TYPE] == TYPE_ITEM) cod_get_item_name(playerData[id][PLAYER_ADDITIONAL], additional, charsmax(additional));

		if (additional[0]) formatex(message, charsmax(message), missionDescription[playerData[id][PLAYER_TYPE]], additional, (get_progress_need(id) - get_progress(id)));
		else formatex(message, charsmax(message), missionDescription[playerData[id][PLAYER_TYPE]], (get_progress_need(id) - get_progress(id)));

		cod_print_chat(id, "Rozdzial:^x03 %s^x01. Postep:^x03 %i/%i^x01.", codChapter[CHAPTER_NAME], get_progress(id), get_progress_need(id));
		cod_print_chat(id, "Misja:^x03 %s^x01.", message);
	}

	return PLUGIN_HANDLED;
}

public cod_class_changed(id, class)
{
	if (is_user_bot(id) || is_user_hltv(id)) return PLUGIN_HANDLED;

	save_mission(id);

	cod_get_class_name(cod_get_user_class(id), _, playerClass[id], charsmax(playerClass[]));

	reset_mission(id, 1, 1);

	load_mission(id);

	return PLUGIN_HANDLED;
}

public save_mission(id)
{
	if (is_user_bot(id) || is_user_hltv(id) || !get_bit(id, loaded)) return PLUGIN_HANDLED;

	new vaultKey[MAX_NAME * 2], vaultData[64];

	formatex(vaultKey, charsmax(vaultKey), "%s-%s", playerName[id], playerClass[id]);
	formatex(vaultData, charsmax(vaultData), "%i %i %i %i %i", playerData[id][PLAYER_ID], playerData[id][PLAYER_TYPE], playerData[id][PLAYER_ADDITIONAL], playerData[id][PLAYER_PROGRESS], playerData[id][PLAYER_CHAPTER]);

	nvault_set(missions, vaultKey, vaultData);

	return PLUGIN_HANDLED;
}

public load_mission(id)
{
	if (is_user_bot(id) || is_user_hltv(id)) return PLUGIN_HANDLED;

	new vaultKey[MAX_NAME * 2], vaultData[64], missionData[5][16], missionParam[5];

	formatex(vaultKey, charsmax(vaultKey), "%s-%s", playerName[id], playerClass[id]);

	set_bit(id, loaded);

	if (nvault_get(missions, vaultKey, vaultData, charsmax(vaultData))) {
		parse(vaultData, missionData[0], charsmax(missionData[]), missionData[1], charsmax(missionData[]), missionData[2], charsmax(missionData[]), missionData[3], charsmax(missionData[]), missionData[4], charsmax(missionData[]));

		for (new i = 0; i < sizeof missionParam; i++) missionParam[i] = str_to_num(missionData[i]);

		if (!missionParam[1]) return PLUGIN_HANDLED;

		playerData[id][PLAYER_ID] = missionParam[0];
		playerData[id][PLAYER_TYPE] = missionParam[1];
		playerData[id][PLAYER_ADDITIONAL] = missionParam[2];
		playerData[id][PLAYER_PROGRESS] = missionParam[3];
		playerData[id][PLAYER_CHAPTER] = missionParam[4];

		if (missionParam[0] >= ArraySize(codMissions) || missionParam[4] >= ArraySize(codChapters)) {
			reset_mission(id, 0, 1);
		}
	}

	return PLUGIN_HANDLED;
}

public reset_mission(id, data, silent)
{
	playerData[id][PLAYER_TYPE] = TYPE_NONE;
	playerData[id][PLAYER_ID] = NONE;
	playerData[id][PLAYER_PROGRESS] = 0;

	if (!data) save_mission(id);
	if (!silent) cod_print_chat(id, "Zrezygnowales z wykonywania wybranej wczesniej^x03 misji^x01.");
}

stock get_mission_info(mission, info)
{
	new codMission[missionInfo];

	ArrayGetArray(codMissions, mission, codMission);

	return codMission[info];
}

stock add_progress(id, amount = 1)
{
	if (!is_user_connected(id) || get_playersnum() < cvarMinPlayers) return PLUGIN_HANDLED;

	playerData[id][PLAYER_PROGRESS] += amount;

	if (get_progress(id) >= get_progress_need(id)) give_reward(id);
	else save_mission(id);

	return PLUGIN_HANDLED;
}

public get_mission(id)
	return playerData[id][PLAYER_ID];

public get_progress(id)
	return playerData[id][PLAYER_PROGRESS] ? playerData[id][PLAYER_PROGRESS] : 0;

public get_progress_need(id)
	return playerData[id][PLAYER_TYPE] ? get_mission_info(playerData[id][PLAYER_ID], MISSION_AMOUNT) : 0;
