#include <amxmodx>
#include <cod>
#include <csx>
#include <sqlx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <unixtime>
#include <nvault>

#define PLUGIN "CoD Stats"
#define VERSION "1.2.2"
#define AUTHOR "O'Zone"

#define TASK_TIME 9054

#define ADMIN_FLAG ADMIN_BAN

new const commandMenu[][] = { "menustaty", "say /statsmenu", "say_team /statsmenu", "say /statymenu", "say_team /statymenu", "say /menustaty", "say_team /menustaty" };
new const commandTime[][] = { "czas", "say /time", "say_team /time", "say /czas", "say_team /czas" };
new const commandAdminTime[][] = { "czasadmin", "say /timeadmin", "say_team /timeadmin", "say /tadmin", "say_team /tadmin", "say /czasadmin", "say_team /czasadmin", "say /cadmin", "say_team /cadmin", "say /adminczas", "say_team /adminczas" };
new const commandTopTime[][] = { "topczas", "say /ttop15", "say_team /ttop15", "say /toptime", "say_team /toptime", "say /ctop15", "say_team /ctop15", "say /topczas", "say_team /topczas" };
new const commandBestStats[][] = { "najlepszestaty", "say /staty", "say_team /staty", "say /beststats", "say_team /beststats", "say /bstats", "say_team /bstats", "say /najlepszestaty", "say_team /najlepszestaty", "say /nstaty", "say_team /nstaty" };
new const commandTopStats[][] = { "topstaty", "say /stop15", "say_team /stop15", "say /topstats", "say_team /topstats", "say /topstaty", "say_team /topstaty" };
new const commandMedals[][] = { "medale", "say /medal", "say_team /medal", "say /medale", "say_team /medale", "say /medals", "say_team /medals" };
new const commandTopMedals[][] = { "medale", "topmedale", "say /mtop15", "say_team /mtop15", "say /topmedals", "say_team /topmedals", "say /topmedale", "say_team /topmedale" };
new const commandSounds[][] = { "dzwieki", "say /dzwiek", "say_team /dzwiek", "say /dzwieki", "say_team /dzwieki", "say /sound", "say_team /sound" };

enum _:statsInfo { ADMIN, REVENGE, TIME, FIRST_VISIT, LAST_VISIT, KILLS, BRONZE, SILVER, GOLD, MEDALS, BEST_STATS, BEST_KILLS,
	BEST_HS_KILLS, BEST_DEATHS, CURRENT_STATS, CURRENT_KILLS, CURRENT_HS_KILLS, CURRENT_DEATHS, ROUND_KILLS, ROUND_HS_KILLS };
enum _:winers { THIRD, SECOND, FIRST };

new playerName[MAX_PLAYERS + 1][MAX_SAFE_NAME], playerStats[MAX_PLAYERS + 1][statsInfo], playerDamage[MAX_PLAYERS + 1][MAX_PLAYERS + 1],
	Handle:sql, Handle:connection, bool:sqlConnected, bool:blockCount, bool:showedOneAndOnly, round, dataLoaded, visitInfo;

new cvarMinPlayers, cvarMedalsEnabled, cvarGoldMedalExp, cvarSilverMedalExp, cvarBronzeMedalExp, cvarAssistEnabled,
	cvarAssistDamage, cvarAssistHonor, cvarAssistExp, cvarRevengeEnabled, cvarRevengeHonor, cvarRevengeExp;

new soundsVault, soundMayTheForce, soundOneAndOnly, soundPrepare, soundHumiliation, soundLastLeft;

forward amxbans_admin_connect(id);

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	bind_pcvar_num(create_cvar("cod_stats_min_players", "4"), cvarMinPlayers);
	bind_pcvar_num(create_cvar("cod_medals_enabled", "1"), cvarMedalsEnabled);
	bind_pcvar_num(create_cvar("cod_medals_gold_exp", "500"), cvarGoldMedalExp);
	bind_pcvar_num(create_cvar("cod_medals_silver_exp", "300"), cvarSilverMedalExp);
	bind_pcvar_num(create_cvar("cod_medals_bronze_exp", "100"), cvarBronzeMedalExp);
	bind_pcvar_num(create_cvar("cod_assist_enabled", "1"), cvarAssistEnabled);
	bind_pcvar_num(create_cvar("cod_assist_damage", "65"), cvarAssistDamage);
	bind_pcvar_num(create_cvar("cod_assist_honor", "1"), cvarAssistHonor);
	bind_pcvar_num(create_cvar("cod_assist_exp", "15"), cvarAssistExp);
	bind_pcvar_num(create_cvar("cod_revenge_enabled", "1"), cvarRevengeEnabled);
	bind_pcvar_num(create_cvar("cod_revenge_honor", "1"), cvarRevengeHonor);
	bind_pcvar_num(create_cvar("cod_revenge_exp", "15"), cvarRevengeExp);

	for (new i; i < sizeof commandMenu; i++) register_clcmd(commandMenu[i], "stats_menu");
	for (new i; i < sizeof commandTime; i++) register_clcmd(commandTime[i], "command_time");
	for (new i; i < sizeof commandAdminTime; i++) register_clcmd(commandAdminTime[i], "command_time_admin");
	for (new i; i < sizeof commandTopTime; i++) register_clcmd(commandTopTime[i], "command_time_top");
	for (new i; i < sizeof commandBestStats; i++) register_clcmd(commandBestStats[i], "command_best_stats");
	for (new i; i < sizeof commandTopStats; i++) register_clcmd(commandTopStats[i], "command_top_stats");
	for (new i; i < sizeof commandMedals; i++) register_clcmd(commandMedals[i], "command_medals");
	for (new i; i < sizeof commandTopMedals; i++) register_clcmd(commandTopMedals[i], "command_top_medals");
	for (new i; i < sizeof commandSounds; i++) register_clcmd(commandSounds[i], "command_sounds");

	register_message(get_user_msgid("SayText"), "say_text");

	soundsVault = nvault_open("cod_sound");
}

public plugin_cfg()
	sql_init();

public plugin_end()
{
	SQL_FreeHandle(sql);
	SQL_FreeHandle(connection);
}

public plugin_natives()
{
	register_native("cod_stats_add_kill", "_cod_stats_add_kill", 1);
	register_native("cod_get_user_time", "_cod_get_user_time", 1);
	register_native("cod_get_user_time_text", "_cod_get_user_time_text", 1);
}

public client_putinserver(id)
{
	for (new i = REVENGE; i <= ROUND_HS_KILLS; i++) playerStats[id][i] = 0;

	rem_bit(id, dataLoaded);
	rem_bit(id, visitInfo);
	rem_bit(id, soundOneAndOnly);
	rem_bit(id, soundLastLeft);
	rem_bit(id, soundPrepare);
	set_bit(id, soundMayTheForce);
	set_bit(id, soundHumiliation);

	if (is_user_bot(id) || is_user_hltv(id)) return;

	get_user_name(id, playerName[id], charsmax(playerName[]));

	cod_sql_string(playerName[id], playerName[id], charsmax(playerName[]));

	load_sounds(id);

	set_task(0.1, "load_stats", id);
}

public amxbans_admin_connect(id)
    client_authorized_post(id);

public client_authorized(id)
    client_authorized_post(id);

public client_authorized_post(id)
    playerStats[id][ADMIN] = (get_user_flags(id) & ADMIN_FLAG) ? 1 : 0;

public client_disconnected(id)
{
	remove_task(id);

	save_stats(id, 1);
}

public stats_menu(id)
{
	if (!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menu = menu_create("\yMenu \yStatystyk\r", "stats_menu_handle");

	menu_additem(menu, "\wMoj \rCzas \y(/czas)", "1");

	if (playerStats[id][ADMIN]) menu_additem(menu, "\wCzas \rAdminow \y(/adminczas)", "2");

	menu_additem(menu, "\wTop \rCzasu \y(/ctop15)", "3");
	menu_additem(menu, "\wNajlepsze \rStaty \y(/staty)", "4");
	menu_additem(menu, "\wTop \rStatow \y(/stop15)", "5");
	menu_additem(menu, "\wMoje \rMedale \y(/medale)", "6");
	menu_additem(menu, "\wTop \rMedali \y(/mtop15)", "7");

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public stats_menu_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new itemData[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, itemCallback);

	new item = str_to_num(itemData);

	switch (item) {
		case 1: command_time(id);
		case 2: command_time_admin(id)
		case 3: command_time_top(id);
		case 4: command_best_stats(id);
		case 5: command_top_stats(id);
		case 6: command_medals(id);
		case 7: command_top_medals(id);
	}

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public command_time(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[256], tempId[1];

	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT rank, count FROM (SELECT COUNT(*) as count FROM `cod_stats`) a CROSS JOIN (SELECT COUNT(*) as rank FROM `cod_stats` WHERE `time` > '%i' ORDER BY `time` DESC) b",
		playerStats[id][TIME] + get_user_time(id));

	SQL_ThreadQuery(sql, "show_time", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_time(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) cod_log_error(PLUGIN, "Could not connect to SQL database. Error: %s (%d)", error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) cod_log_error(PLUGIN, "Threaded query failed. Error: %s (%d)", error, errorNum);

		return PLUGIN_HANDLED;
	}

	new id = tempId[0];

	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new rank, count, hours, minutes, seconds = (playerStats[id][TIME] + get_user_time(id));

	rank = SQL_ReadResult(query, SQL_FieldNameToNum(query, "rank")) + 1;
	count = SQL_ReadResult(query, SQL_FieldNameToNum(query, "count"));

	while (seconds >= 60) {
		seconds -= 60;
		minutes++;
	}

	while (minutes >= 60) {
		minutes -= 60;
		hours++;
	}

	cod_print_chat(id, "Spedziles na serwerze lacznie^x04 %i h %i min %i s^x01.", hours, minutes, seconds);
	cod_print_chat(id, "Zajmujesz^x04 %i/%i^x01 miejsce w rankingu czasu gry.", rank, count);

	return PLUGIN_HANDLED;
}

public command_time_admin(id)
{
	if (!is_user_connected(id) || !playerStats[id][ADMIN]) return PLUGIN_HANDLED;

	new queryData[128], tempData[2];

	tempData[0] = id;
	tempData[1] = 1;

	formatex(queryData, charsmax(queryData), "SELECT name, time FROM `cod_stats` WHERE admin = '1' ORDER BY time DESC");

	SQL_ThreadQuery(sql, "show_top_time", queryData, tempData, sizeof(tempData));

	return PLUGIN_HANDLED;
}

public command_time_top(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[128], tempId[2];

	tempId[0] = id;
	tempId[1] = 0;

	formatex(queryData, charsmax(queryData), "SELECT name, time FROM `cod_stats` ORDER BY time DESC LIMIT 15");

	SQL_ThreadQuery(sql, "show_top_time", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_top_time(failState, Handle:query, error[], errorNum, tempData[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) cod_log_error(PLUGIN, "Could not connect to SQL database. Error: %s (%d)", error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) cod_log_error(PLUGIN, "Threaded query failed. Error: %s (%d)", error, errorNum);

		return PLUGIN_HANDLED;
	}

	new id = tempData[0];

	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	static motdData[2048], userName[64], motdLength, rank, seconds, minutes, hours;

	rank = 0;

	motdLength = format(motdData, charsmax(motdData), "<body bgcolor=#000000><font color=#FFB000><pre>");
	motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1s %-22.22s %13s^n", "#", "Nick", "Czas Gry");

	while (SQL_MoreResults(query)) {
		rank++;

		SQL_ReadResult(query, 0, userName, charsmax(userName));

		seconds = SQL_ReadResult(query, 1);
		minutes = 0;
		hours = 0;

		replace_all(userName, charsmax(userName), "<", "");
		replace_all(userName, charsmax(userName), ">", "");

		while (seconds >= 60) {
			seconds -= 60;
			minutes++;
		}

		while (minutes >= 60) {
			minutes -= 60;
			hours++;
		}

		if (rank >= 10) motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1i %-22.22s %1ih %1imin %1is^n", rank, userName, hours, minutes, seconds);
		else motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1i %-22.22s %2ih %1imin %1is^n", rank, userName, hours, minutes, seconds);

		SQL_NextRow(query);
	}

	tempData[1] ? show_motd(id, motdData, "Czas Gry Adminow") : show_motd(id, motdData, "Top15 Czasu Gry");

	return PLUGIN_HANDLED;
}

public command_best_stats(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[256], tempId[1];

	tempId[0] = id;

	playerStats[id][CURRENT_STATS] = playerStats[id][CURRENT_KILLS] * 2 + playerStats[id][CURRENT_HS_KILLS] - playerStats[id][CURRENT_DEATHS] * 2;

	if (playerStats[id][CURRENT_STATS] > playerStats[id][BEST_STATS]) {
		formatex(queryData, charsmax(queryData), "SELECT rank, count FROM (SELECT COUNT(*) as count FROM `cod_stats`) a CROSS JOIN (SELECT COUNT(*) as rank FROM `cod_stats` WHERE `beststats` > '%i' ORDER BY `beststats` DESC) b",
			playerStats[id][BEST_STATS]);
	} else {
		formatex(queryData, charsmax(queryData), "SELECT rank, count FROM (SELECT COUNT(*) as count FROM `cod_stats`) a CROSS JOIN (SELECT COUNT(*) as rank FROM `cod_stats` WHERE `beststats` > '%i' ORDER BY `beststats` DESC) b",
			playerStats[id][CURRENT_STATS]);
	}

	SQL_ThreadQuery(sql, "show_best_stats", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_best_stats(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) cod_log_error(PLUGIN, "Could not connect to SQL database. Error: %s (%d)", error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) cod_log_error(PLUGIN, "Threaded query failed. Error: %s (%d)", error, errorNum);

		return PLUGIN_HANDLED;
	}

	new id = tempId[0];

	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new rank = SQL_ReadResult(query, 0) + 1, players = SQL_ReadResult(query, 1);

	if (playerStats[id][CURRENT_STATS] > playerStats[id][BEST_STATS]) {
		cod_print_chat(id, "Twoje najlepsze staty to^x04 %i^x01 zabic (w tym^x04 %i^x01 z HS) i^x04 %i^x01 zgonow^x01.",
			playerStats[id][CURRENT_KILLS], playerStats[id][CURRENT_HS_KILLS], playerStats[id][CURRENT_DEATHS]);
	} else {
		cod_print_chat(id, "Twoje najlepsze staty to^x04 %i^x01 zabic (w tym^x04 %i^x01 z HS) i^x04 %i^x01 zgonow^x01.",
			playerStats[id][BEST_KILLS], playerStats[id][BEST_HS_KILLS], playerStats[id][BEST_DEATHS]);
	}

	cod_print_chat(id, "Zajmujesz^x04 %i/%i^x01 miejsce w rankingu najlepszych statystyk.", rank, players);

	return PLUGIN_HANDLED;
}

public command_top_stats(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[128], tempId[1];

	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT name, bestkills, besths, bestdeaths FROM `cod_stats` ORDER BY beststats DESC LIMIT 15");
	SQL_ThreadQuery(sql, "show_top_stats", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_top_stats(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) cod_log_error(PLUGIN, "Could not connect to SQL database. Error: %s (%d)", error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) cod_log_error(PLUGIN, "Threaded query failed. Error: %s (%d)", error, errorNum);

		return PLUGIN_HANDLED;
	}

	new id = tempId[0];

	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	static motdData[2048], userName[64], motdLength, rank, kills, hs, deaths;

	rank = 0;

	motdLength = format(motdData, charsmax(motdData), "<body bgcolor=#000000><font color=#FFB000><pre>");
	motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1s %-22.22s %19s %4s^n", "#", "Nick", "Zabojstwa", "Zgony");

	while (SQL_MoreResults(query)) {
		rank++;

		SQL_ReadResult(query, 0, userName, charsmax(userName));

		kills = SQL_ReadResult(query, 1);
		hs = SQL_ReadResult(query, 2);
		deaths = SQL_ReadResult(query, 3);

		replace_all(userName, charsmax(userName), "<", "");
		replace_all(userName, charsmax(userName), ">", "");

		if (rank >= 10) motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1i %-22.22s %1d (%i HS) %12d^n", rank, userName, kills, hs, deaths);
		else motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1i %-22.22s %2d (%i HS) %12d^n", rank, userName, kills, hs, deaths);

		SQL_NextRow(query);
	}

	show_motd(id, motdData, "Top15 Statystyk");

	return PLUGIN_HANDLED;
}

public command_medals(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[256], tempId[1];

	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT rank, count FROM (SELECT COUNT(*) as count FROM `cod_stats`) a CROSS JOIN (SELECT COUNT(*) as rank FROM `cod_stats` WHERE `medals` > '%i' ORDER BY `medals` DESC) b",
		playerStats[id][MEDALS]);

	SQL_ThreadQuery(sql, "show_medals", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_medals(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) cod_log_error(PLUGIN, "Could not connect to SQL database. Error: %s (%d)", error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) cod_log_error(PLUGIN, "Threaded query failed. Error: %s (%d)", error, errorNum);

		return PLUGIN_HANDLED;
	}

	new id = tempId[0];

	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new rank = SQL_ReadResult(query, 0) + 1, players = SQL_ReadResult(query, 1);

	cod_print_chat(id, "Twoje medale:^x04 %i Zlote^x01,^x04 %i Srebre^x01,^x04 %i Brazowe^x01.", playerStats[id][GOLD], playerStats[id][SILVER], playerStats[id][BRONZE]);
	cod_print_chat(id, "Zajmujesz^x04 %i/%i^x01 miejsce w rankingu medalowym.", rank, players);

	return PLUGIN_HANDLED;
}

public command_top_medals(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[128], tempId[1];

	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT name, gold, silver, bronze, medals FROM `cod_stats` ORDER BY medals DESC LIMIT 15");
	SQL_ThreadQuery(sql, "show_top_medals", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_top_medals(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) cod_log_error(PLUGIN, "Could not connect to SQL database. Error: %s (%d)", error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) cod_log_error(PLUGIN, "Threaded query failed. Error: %s (%d)", error, errorNum);

		return PLUGIN_HANDLED;
	}

	new id = tempId[0];

	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	static motdData[2048], userName[64], motdLength, rank, gold, silver, bronze, medals;

	rank = 0;

	motdLength = format(motdData, charsmax(motdData), "<body bgcolor=#000000><font color=#FFB000><pre>");
	motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1s %-22.22s %6s %8s %8s %5s^n", "#", "Nick", "Zlote", "Srebrne", "Brazowe", "Suma");

	while (SQL_MoreResults(query)) {
		rank++;

		SQL_ReadResult(query, 0, userName, charsmax(userName));

		gold = SQL_ReadResult(query, 1);
		silver = SQL_ReadResult(query, 2);
		bronze = SQL_ReadResult(query, 3);
		medals = SQL_ReadResult(query, 3);

		replace_all(userName, charsmax(userName), "<", "");
		replace_all(userName, charsmax(userName), ">", "");

		if (rank >= 10) motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1i %-22.22s %2d %7d %8d %7d^n", rank, userName, gold, silver, bronze, medals);
		else motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1i %-22.22s %3d %7d %8d %7d^n", rank, userName, gold, silver, bronze, medals);

		SQL_NextRow(query);
	}

	show_motd(id, motdData, "Top15 Medali");

	return PLUGIN_HANDLED;
}

public command_sounds(id)
{
	new menuData[64], menu = menu_create("\yUstawienia \rDzwiekow\w:", "command_sounds_handle");

	formatex(menuData, charsmax(menuData), "\wThe Force Will Be With You \w[\r%s\w]", get_bit(id, soundMayTheForce) ? "Wlaczony" : "Wylaczony");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "\wI Am The One And Only \w[\r%s\w]", get_bit(id, soundOneAndOnly) ? "Wlaczony" : "Wylaczony");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "\wDziabnal Mnie \w[\r%s\w]", get_bit(id, soundHumiliation) ? "Wlaczony" : "Wylaczony");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "\wKici Kici Tas Tas \w[\r%s\w]", get_bit(id, soundLastLeft) ? "Wlaczony" : "Wylaczony");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "\wNie Obijac Sie \w[\r%s\w]", get_bit(id, soundPrepare) ? "Wlaczony" : "Wylaczony");
	menu_additem(menu, menuData);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public command_sounds_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}


	switch(item) {
		case 0: get_bit(id, soundMayTheForce) ? rem_bit(id, soundMayTheForce) : set_bit(id, soundMayTheForce);
		case 1: get_bit(id, soundOneAndOnly) ? rem_bit(id, soundOneAndOnly) : set_bit(id, soundOneAndOnly);
		case 2: get_bit(id, soundHumiliation) ? rem_bit(id, soundHumiliation) : set_bit(id, soundHumiliation);
		case 3: get_bit(id, soundLastLeft) ? rem_bit(id, soundLastLeft) : set_bit(id, soundLastLeft);
		case 4: get_bit(id, soundPrepare) ? rem_bit(id, soundPrepare) : set_bit(id, soundPrepare);
	}

	save_sounds(id);

	command_sounds(id);

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public check_time(id)
{
	id -= TASK_TIME;

	if (get_bit(id, visitInfo)) return;

	if (get_bit(id, dataLoaded)) {
		set_task(3.0, "check_time", id + TASK_TIME);

		return;
	}

	set_bit(id, visitInfo);

	new currentYear, lastYear, currentMonth, lastMonth, currentDay, lastDay, hour, minute, second, time = get_systime();

	UnixToTime(time, currentYear, currentMonth, currentDay, hour, minute, second, UT_TIMEZONE_SERVER);

	cod_print_chat(id, "Aktualnie jest godzina^x03 %02d:%02d:%02d (Data: %02d.%02d.%02d)^x01.", hour, minute, second, currentDay, currentMonth, currentYear);

	if (playerStats[id][FIRST_VISIT] == playerStats[id][LAST_VISIT]) cod_print_chat(id, "To twoja^x03 pierwsza wizyta^x01 na serwerze. Zyczymy milej gry!" );
	else {
		UnixToTime(playerStats[id][LAST_VISIT], lastYear, lastMonth, lastDay, hour, minute, second, UT_TIMEZONE_SERVER);

		if (currentYear == lastYear && currentMonth == lastMonth && currentDay == lastDay) {
			cod_print_chat(id, "Twoja ostatnia wizyta miala miejsce^x04 dzisiaj^x01 o^x03 %02d:%02d:%02d^x01. Zyczymy milej gry!", hour, minute, second);
		} else if (currentYear == lastYear && currentMonth == lastMonth && (currentDay - 1) == lastDay) {
			cod_print_chat(id, "Twoja ostatnia wizyta miala miejsce^x04 wczoraj^x01 o^x03 %02d:%02d:%02d^x01. Zyczymy milej gry!", hour, minute, second);
		} else {
			cod_print_chat(id, "Twoja ostatnia wizyta:^x03 %02d:%02d:%02d (Data: %02d.%02d.%02d)^x01. Zyczymy milej gry!", hour, minute, second, lastDay, lastMonth, lastYear);
		}
	}
}

public cod_spawned(id, respawn)
{
	if (!get_bit(id, visitInfo)) set_task(5.0, "check_time", id + TASK_TIME);

	if (!respawn) for (new i = 1; i <= MAX_PLAYERS; i++) playerDamage[id][i] = 0;

	save_stats(id);
}

public first_round()
	blockCount = false;

public cod_restart_round()
	round = 0;

public cod_new_round()
{
	showedOneAndOnly = false;

	if (!round) {
		set_task(30.0, "first_round");

		blockCount = true;
	}

	round++;

	new bestId, bestRoundId, bestFrags, bestRoundFrags, bestRoundHS, tempFrags, bestDeaths, tempDeaths;

	for (new id = 1; id <= MAX_PLAYERS; id++) {
		if (!is_user_connected(id) || is_user_bot(id) || is_user_hltv(id)) continue;

		tempFrags = get_user_frags(id);
		tempDeaths = get_user_deaths(id);

		if (tempFrags > 0 && tempFrags > bestFrags) {
			bestFrags = tempFrags;
			bestDeaths = tempDeaths;
			bestId = id;
		}

		if (playerStats[id][ROUND_KILLS] > 0 && (playerStats[id][ROUND_KILLS] > bestRoundFrags || (playerStats[id][ROUND_KILLS] == bestRoundFrags && playerStats[id][ROUND_HS_KILLS] > bestRoundHS))) {
			bestRoundFrags = playerStats[id][ROUND_KILLS];
			bestRoundHS = playerStats[id][ROUND_HS_KILLS];
			bestRoundId = id;
		}

		playerStats[id][ROUND_KILLS] = 0;
		playerStats[id][ROUND_HS_KILLS] = 0;
	}

	if (is_user_connected(bestRoundId)) {
		new bestRoundName[64];

		get_user_name(bestRoundId, bestRoundName, charsmax(bestRoundName));

		cod_print_chat(0, "^x03%s^x01 byl najlepszym graczem rundy. Ustrzelil^x04 %i^x01 frag%s, w tym^x04 %i^x01 z HeadShotem.", bestRoundName, bestRoundFrags, bestRoundFrags > 1 ? "i" : "a", bestRoundHS);
	}

	if (is_user_connected(bestId)) {
		new bestName[64];

		get_user_name(bestId, bestName, charsmax(bestName));

		cod_print_chat(0, "^x03%s^x01 prowadzi w grze z^x04 %i^x01 fragami i^x04 %i^x01 zgonami.", bestName, bestFrags, bestDeaths);
	}
}

public cod_damage_post(attacker, victim, weapon, Float:damage, damageBits, hitPlace)
	playerDamage[attacker][victim] += floatround(damage);

public cod_killed(killer, victim, weaponId, hitPlace)
{
	playerStats[victim][CURRENT_DEATHS]++;
	playerStats[victim][REVENGE] = killer;

	playerStats[killer][CURRENT_KILLS]++;
	playerStats[killer][ROUND_KILLS]++;
	playerStats[killer][KILLS]++;

	if (hitPlace == HIT_HEAD) {
		playerStats[killer][CURRENT_HS_KILLS]++;
		playerStats[killer][ROUND_HS_KILLS]++;
	}

	if (weaponId == CSW_KNIFE) {
		for (new i = 1; i <= MAX_PLAYERS; i++) {
			if (!is_user_connected(i)) continue;

			if ((pev(i, pev_iuser2) == victim || i == victim) && get_bit(i, soundHumiliation)) client_cmd(i, "spk %s", codSounds[SOUND_HUMILIATION]);
		}
	}

	if (cvarRevengeEnabled && playerStats[killer][REVENGE] == victim) {
		set_user_frags(killer, get_user_frags(killer) + 1);

		cs_set_user_deaths(killer, cs_get_user_deaths(killer));

		new nameVictim[MAX_NAME];

		get_user_name(victim, nameVictim, charsmax(nameVictim));

		if (cvarMinPlayers >= get_playersnum()) cod_add_user_honor(killer, cvarRevengeHonor, true);

		if (cvarMinPlayers >= get_playersnum() && cvarRevengeExp) {
			new exp = cod_get_user_bonus_exp(killer, cvarRevengeExp);

			cod_set_user_exp(killer, exp);

			cod_print_chat(killer, "Zemsciles sie na^x03 %s^x01. Dostajesz fraga i^x03 %i^x01 expa!", nameVictim, exp);
		} else cod_print_chat(killer, "Zemsciles sie na^x03 %s^x01. Dostajesz fraga!", nameVictim);
	}

	if (cvarAssistEnabled) {
		new assist = 0, damage = 0;

		for (new id = 1; id <= MAX_PLAYERS; id++) {
			if (!is_user_connected(id) || is_user_bot(id) || is_user_hltv(id) || id == killer) continue;

			if (playerDamage[id][victim] > damage) {
				assist = id;
				damage = playerDamage[id][victim];
			}

			playerDamage[id][victim] = 0;
		}

		if (assist > 0 && damage > cvarAssistDamage) {
			set_user_frags(assist, get_user_frags(assist) + 1);

			cs_set_user_deaths(assist, cs_get_user_deaths(assist));

			new nameVictim[MAX_NAME], nameKiller[MAX_NAME];

			get_user_name(victim, nameVictim, charsmax(nameVictim));
			get_user_name(killer, nameKiller, charsmax(nameKiller));

			if (cvarMinPlayers >= get_playersnum()) cod_add_user_honor(assist, cvarAssistHonor, true);

			if (cvarMinPlayers >= get_playersnum() && cvarAssistExp) {
				new exp = exp = cod_get_user_bonus_exp(assist, cvarAssistExp);

				cod_set_user_exp(assist, exp);

				cod_print_chat(assist, "Pomogles^x03 %s^x01 w zabiciu^x03 %s^x01. Dostajesz fraga i^x03 %i^x01 expa!", nameKiller, nameVictim, exp);
			} else cod_print_chat(assist, "Pomogles^x03 %s^x01 w zabiciu^x03 %s^x01. Dostajesz fraga!", nameKiller, nameVictim);
		}
	}

	if (blockCount) return;

	new tCount, ctCount, lastT, lastCT;

	for (new i = 1; i <= MAX_PLAYERS; i++) {
		if (!is_user_alive(i)) continue;

		switch (get_user_team(i)) {
			case 1: {
				tCount++;
				lastT = i;
			}
			case 2: {
				ctCount++;
				lastCT = i;
			}
		}
	}

	if (tCount == 1 && ctCount == 1) {
		for (new i = 1; i <= MAX_PLAYERS; i++) {
			if (!is_user_connected(i)) continue;

			if ((pev(i, pev_iuser2) == lastT || pev(i, pev_iuser2) == lastCT || i == lastT || i == lastCT) && get_bit(i, soundMayTheForce)) client_cmd(i, "spk %s", codSounds[SOUND_FORCE]);
		}

		new lastTName[MAX_NAME], lastCTName[MAX_NAME];

		get_user_name(lastT, lastTName, charsmax(lastTName));
		get_user_name(lastCT, lastCTName, charsmax(lastCTName));

		cod_show_hud(0, TYPE_DHUD, 255, 128, 0, -1.0, 0.30, 0, 5.0, 5.0, 0.5, 0.15, "%s vs. %s", lastTName, lastCTName);
	}
	if (tCount == 1 && ctCount > 1 && !showedOneAndOnly) {
		showedOneAndOnly = true;

		for (new i = 1; i <= MAX_PLAYERS; i++) {
			if (!is_user_connected(i)) continue;

			if (((is_user_alive(i) && get_user_team(i) == 2) || (!is_user_alive(i) && get_user_team(pev(i, pev_iuser2)) == 2)) && get_bit(i, soundOneAndOnly)) client_cmd(i, "spk %s", codSounds[SOUND_LAST]);

			if (pev(i, pev_iuser2) == lastT || i == lastT) client_cmd(i, "spk %s", codSounds[SOUND_ONE]);
		}

		cod_show_hud(0, TYPE_DHUD, 255, 128, 0, -1.0, 0.30, 0, 5.0, 5.0, 0.5, 0.15, "%i vs %i", tCount, ctCount);
	}
	if (tCount > 1 && ctCount == 1 && !showedOneAndOnly) {
		showedOneAndOnly = true;

		for (new i = 1; i <= MAX_PLAYERS; i++) {
			if (!is_user_connected(i)) continue;

			if (((is_user_alive(i) && get_user_team(i) == 1) || (!is_user_alive(i) && get_user_team(pev(i, pev_iuser2)) == 1)) && get_bit(i, soundOneAndOnly)) client_cmd(i, "spk %s", codSounds[SOUND_LAST]);

			if (pev(i, pev_iuser2) == lastCT || i == lastCT) client_cmd(i, "spk %s", codSounds[SOUND_ONE]);
		}

		cod_show_hud(0, TYPE_DHUD, 255, 128, 0, -1.0, 0.30, 0, 5.0, 5.0, 0.5, 0.15, "%i vs %i", ctCount, tCount);
	}
}

public cod_bomb_planted(planter)
{
	for (new i = 1; i <= MAX_PLAYERS; i++) {
		if (!is_user_connected(i)) continue;

		if (((is_user_alive(i) && get_user_team(i) == 2) || (!is_user_alive(i) && get_user_team(pev(i, pev_iuser2)) == 2)) && get_bit(i, soundPrepare)) client_cmd(i, "spk %s", codSounds[SOUND_BOMB]);
	}
}

public cod_bomb_explode(planter, defuser)
	playerStats[planter][KILLS] += 3;

public cod_bomb_defused(defuser)
	playerStats[defuser][KILLS] += 3;

public cod_hostages_rescued(id)
	playerStats[id][KILLS] += 3;

public cod_end_map()
{
	if (cvarMedalsEnabled) {
		new playerName[MAX_NAME], winnersId[3], winnersFrags[3], tempFrags, swapFrags, swapId, exp;

		for (new id = 1; id <= MAX_PLAYERS; id++) {
			if (!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id)) continue;

			tempFrags = get_user_frags(id);

			if (tempFrags > winnersFrags[THIRD]) {
				winnersFrags[THIRD] = tempFrags;
				winnersId[THIRD] = id;

				if (tempFrags > winnersFrags[SECOND]) {
					swapFrags = winnersFrags[SECOND];
					swapId = winnersId[SECOND];
					winnersFrags[SECOND] = tempFrags;
					winnersId[SECOND] = id;
					winnersFrags[THIRD] = swapFrags;
					winnersId[THIRD] = swapId;

					if (tempFrags > winnersFrags[FIRST]) {
						swapFrags = winnersFrags[FIRST];
						swapId = winnersId[FIRST];
						winnersFrags[FIRST] = tempFrags;
						winnersId[FIRST] = id;
						winnersFrags[SECOND] = swapFrags;
						winnersId[SECOND] = swapId;
					}
				}
			}
		}

		if (!winnersId[FIRST]) return PLUGIN_CONTINUE;

		new const medals[][] = { "Brazowy", "Srebrny", "Zloty" };

		cod_print_chat(0, "Gratulacje dla^x03 Najlepszych Graczy^x01!");

		for (new i = 2; i >= 0; i--) {
			if (!is_user_connected(winnersId[i])) continue;

			switch (i) {
				case THIRD: {
					playerStats[winnersId[i]][BRONZE]++;
					exp = cvarBronzeMedalExp;
				} case SECOND: {
					playerStats[winnersId[i]][SILVER]++;
					exp = cvarSilverMedalExp;
				} case FIRST: {
					playerStats[winnersId[i]][GOLD]++;
					exp = cvarGoldMedalExp;
				}
			}

			save_stats(winnersId[i], 1);

			get_user_name(winnersId[i], playerName, charsmax(playerName));

			if (cvarMinPlayers >= get_playersnum() && exp) {
				cod_set_user_exp(winnersId[i], exp);

				cod_print_chat(0, "^x03 %s^x01 -^x03 %i^x01 Zabojstw - %s Medal (+^x03%i^x01 Doswiadczenia).", playerName, winnersFrags[i], medals[i], exp);
			} else cod_print_chat(0, "^x03 %s^x01 -^x03 %i^x01 Zabojstw - %s Medal.", playerName, winnersFrags[i], medals[i]);
		}
	}

	for (new id = 1; id <= MAX_PLAYERS; id++) {
		if (!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id)) continue;

		save_stats(id, 1);
	}

	return PLUGIN_CONTINUE;
}

public say_text(msgId, msgDest, msgEnt)
{
	new id = get_msg_arg_int(1);

	if (is_user_connected(id)) {
		new tempMessage[192], message[192], playerName[MAX_NAME], chatPrefix[16], stats[8], body[8], rank;

		get_msg_arg_string(2, tempMessage, charsmax(tempMessage));
		rank = get_user_stats(id, stats, body);

		if (rank > 3) return PLUGIN_CONTINUE;

		switch (rank) {
			case 1: formatex(chatPrefix, charsmax(chatPrefix), "^x04[TOP1]");
			case 2: formatex(chatPrefix, charsmax(chatPrefix), "^x04[TOP2]");
			case 3: formatex(chatPrefix, charsmax(chatPrefix), "^x04[TOP3]");
		}

		if (!equal(tempMessage, "#Cstrike_Chat_All")) {
			add(message, charsmax(message), chatPrefix);
			add(message, charsmax(message), " ");
			add(message, charsmax(message), tempMessage);
		} else {
	        get_user_name(id, playerName, charsmax(playerName));

	        get_msg_arg_string(4, tempMessage, charsmax(tempMessage));
	        set_msg_arg_string(4, "");

	        add(message, charsmax(message), chatPrefix);
	        add(message, charsmax(message), "^x03 ");
	        add(message, charsmax(message), playerName);
	        add(message, charsmax(message), "^x01 :  ");
	        add(message, charsmax(message), tempMessage);
		}

		set_msg_arg_string(2, message);
	}

	return PLUGIN_CONTINUE;
}

public sql_init()
{
	new host[64], user[64], pass[64], db[64], queryData[512], error[128], errorNum;

	get_cvar_string("cod_sql_host", host, charsmax(host));
	get_cvar_string("cod_sql_user", user, charsmax(user));
	get_cvar_string("cod_sql_pass", pass, charsmax(pass));
	get_cvar_string("cod_sql_db", db, charsmax(db));

	sql = SQL_MakeDbTuple(host, user, pass, db);

	connection = SQL_Connect(sql, errorNum, error, charsmax(error));

	if (errorNum) {
		cod_log_error(PLUGIN, "SQL Query Error. [%d] %s", errorNum, error);

		set_task(5.0, "sql_init");

		return;
	}

	formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_stats` (`name` varchar(%i) NOT NULL, `admin` INT NOT NULL, `kills` INT NOT NULL, `time` INT NOT NULL, ", MAX_SAFE_NAME);
	add(queryData, charsmax(queryData), "`firstvisit` INT NOT NULL, `lastvisit` INT NOT NULL, `bestkills` INT NOT NULL, `bestdeaths` INT NOT NULL, `besths` INT NOT NULL, ");
	add(queryData, charsmax(queryData), "`beststats` INT NOT NULL, `bronze` INT NOT NULL, `silver` INT NOT NULL, `gold` INT NOT NULL, `medals` INT NOT NULL, PRIMARY KEY (`name`));");

	new Handle:query = SQL_PrepareQuery(connection, queryData);

	SQL_Execute(query);

	SQL_FreeHandle(query);

	sqlConnected = true;
}

public load_stats(id)
{
	if (!sqlConnected) {
		set_task(1.0, "load_stats", id);

		return;
	}

	new queryData[128], tempId[1];

	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT * FROM `cod_stats` WHERE name = ^"%s^"", playerName[id]);
	SQL_ThreadQuery(sql, "load_stats_handle", queryData, tempId, sizeof(tempId));
}

public load_stats_handle(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) cod_log_error(PLUGIN, "Could not connect to SQL database. Error: %s (%d)", error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) cod_log_error(PLUGIN, "Threaded query failed. Error: %s (%d)", error, errorNum);

		return;
	}

	new id = tempId[0];

	if (SQL_NumRows(query)) {
		playerStats[id][KILLS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "kills"));
		playerStats[id][TIME] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "time"));
		playerStats[id][FIRST_VISIT] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "firstvisit"));
		playerStats[id][LAST_VISIT] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "lastvisit"));
		playerStats[id][BRONZE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "bronze"));
		playerStats[id][SILVER] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "silver"));
		playerStats[id][GOLD] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "gold"));
		playerStats[id][MEDALS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "medals"));
		playerStats[id][BEST_STATS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "beststats"));
		playerStats[id][BEST_KILLS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "bestkills"));
		playerStats[id][BEST_HS_KILLS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "besths"));
		playerStats[id][BEST_DEATHS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "bestdeaths"));
	} else {
		new queryData[128];

		formatex(queryData, charsmax(queryData), "INSERT IGNORE INTO `cod_stats` (`name`) VALUES (^"%s^")", playerName[id]);

		SQL_ThreadQuery(sql, "ignore_handle", queryData);
	}

	set_bit(id, dataLoaded);
}

stock save_stats(id, end = 0)
{
	if (!get_bit(id, dataLoaded)) return;

	static queryData[256], queryStats[128], queryMedals[128], medals;

	playerStats[id][CURRENT_STATS] = playerStats[id][CURRENT_KILLS] * 2 + playerStats[id][CURRENT_HS_KILLS] - playerStats[id][CURRENT_DEATHS] * 2;

	if (playerStats[id][CURRENT_STATS] > playerStats[id][BEST_STATS]) {
		formatex(queryStats, charsmax(queryStats), ", `bestkills` = %d, `besths` = %d, `bestdeaths` = %d, `beststats` = %d",
		playerStats[id][CURRENT_KILLS], playerStats[id][CURRENT_HS_KILLS], playerStats[id][CURRENT_DEATHS], playerStats[id][CURRENT_STATS]);
	}

	medals = playerStats[id][GOLD] * 3 + playerStats[id][SILVER] * 2 + playerStats[id][BRONZE];

	if (medals > playerStats[id][MEDALS]) {
		formatex(queryStats, charsmax(queryStats), ", `gold` = %d, `silver` = %d, `bronze` = %d, `medals` = %d",
		playerStats[id][GOLD], playerStats[id][SILVER], playerStats[id][BRONZE], medals);
	}

	formatex(queryData, charsmax(queryData), "UPDATE `cod_stats` SET `admin` = %i, `kills` = %i, `time` = %i, `lastvisit` = %i%s%s WHERE `name` = ^"%s^" AND `time` <= %i",
	playerStats[id][ADMIN], playerStats[id][KILLS], playerStats[id][TIME] + get_user_time(id), get_systime(), queryStats, queryMedals, playerName[id], playerStats[id][TIME] + get_user_time(id));

	switch (end) {
		case 0: SQL_ThreadQuery(sql, "ignore_handle", queryData);
		case 1: {
			new error[128], errorNum, Handle:query;

			query = SQL_PrepareQuery(connection, queryData);

			if (!SQL_Execute(query)) {
				errorNum = SQL_QueryError(query, error, charsmax(error));

				cod_log_error(PLUGIN, "Non-threaded query failed. Error: [%d] %s", errorNum, error);

				SQL_FreeHandle(query);
			}

			SQL_FreeHandle(query);
		}
	}

	if (end) rem_bit(id, dataLoaded);
}

public save_sounds(id)
{
	new vaultKey[MAX_NAME], vaultData[16];

	formatex(vaultKey, charsmax(vaultKey), "%s-sounds", playerName[id]);
	formatex(vaultData, charsmax(vaultData), "%d %d %d %d %d", get_bit(id, soundMayTheForce), get_bit(id, soundOneAndOnly), get_bit(id, soundHumiliation), get_bit(id, soundPrepare), get_bit(id, soundLastLeft));

	nvault_set(soundsVault, vaultKey, vaultData);

	return PLUGIN_CONTINUE;
}

public load_sounds(id)
{
	new vaultKey[MAX_NAME], vaultData[16], soundsData[5][5];

	formatex(vaultKey, charsmax(vaultKey), "%s-sounds", playerName[id]);

	if (nvault_get(soundsVault, vaultKey, vaultData, charsmax(vaultData))) {
		parse(vaultData, soundsData[0], charsmax(soundsData), soundsData[1], charsmax(soundsData), soundsData[2], charsmax(soundsData), soundsData[3], charsmax(soundsData), soundsData[4], charsmax(soundsData));

		if(str_to_num(soundsData[0])) set_bit(id, soundMayTheForce);
		if(str_to_num(soundsData[1])) set_bit(id, soundOneAndOnly);
		if(str_to_num(soundsData[2])) set_bit(id, soundHumiliation);
		if(str_to_num(soundsData[3])) set_bit(id, soundPrepare);
		if(str_to_num(soundsData[4])) set_bit(id, soundLastLeft);
	}

	return PLUGIN_CONTINUE;
}

public ignore_handle(failState, Handle:query, error[], errorNum, data[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) cod_log_error(PLUGIN, "Could not connect to SQL database. Error: %s (%d)", error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) cod_log_error(PLUGIN, "Threaded query failed. Error: %s (%d)", error, errorNum);
	}

	return PLUGIN_CONTINUE;
}

public _cod_stats_add_kill(id)
{
	if (!is_user_valid(id)) return;

	playerStats[id][CURRENT_KILLS]++;
	playerStats[id][KILLS]++;
}

public _cod_get_user_time(id)
{
	if (!is_user_valid(id)) return 0;

	return playerStats[id][TIME] + get_user_time(id);
}

public _cod_get_user_time_text(id, dataReturn[], dataLength)
{
	if (!is_user_valid(id)) return;

	static seconds, minutes, hours;

	seconds = playerStats[id][TIME] + get_user_time(id);

	minutes = 0; hours = 0;

	while (seconds >= 60) {
		seconds -= 60;
		minutes++;
	}

	while (minutes >= 60) {
		minutes -= 60;
		hours++;
	}

	param_convert(2);

	formatex(dataReturn, dataLength, "%i h %i min %i s", hours, minutes, seconds);
}
