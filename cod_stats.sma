#include <amxmodx>
#include <cod>
#include <csx>
#include <sqlx>
#include <fakemeta>
#include <unixtime>

#define PLUGIN "CoD Stats"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define TASK_TIME 9054

enum _:statsInfo { ADMIN, TIME, FIRST_VISIT, LAST_VISIT, KILLS, BEST_STATS, BEST_KILLS, 
	BEST_HS_KILLS, BEST_DEATHS, CURRENT_STATS, CURRENT_KILLS, CURRENT_HS_KILLS, CURRENT_DEATHS };

new const commandMenu[][] = { "say /statsmenu", "say_team /statsmenu", "say /menustaty", "say_team /menustaty", "menustaty" };
new const commandTime[][] = { "say /time", "say_team /time", "say /czas", "say_team /czas", "czas" };
new const commandAdminTime[][] = { "say /timeadmin", "say_team /timeadmin", "say /tadmin", "say_team /tadmin", "say /czasadmin", "say_team /czasadmin", "say /cadmin", "say_team /cadmin", "say /adminczas", "say_team /adminczas", "czasadmin" };
new const commandTopTime[][] = { "say /ttop15", "say_team /ttop15", "say /toptime", "say_team /toptime", "say /ctop15", "say_team /ctop15", "say /topczas", "say_team /topczas", "topczas" };
new const commandBestStats[][] = { "say /staty", "say_team /staty", "say /beststats", "say_team /beststats", "say /bstats", "say_team /bstats", "say /najlepszestaty", "say_team /najlepszestaty", "say /nstaty", "say_team /nstaty", "najlepszestaty" };
new const commandTopStats[][] = { "say /stop15", "say_team /stop15", "say /topstats", "say_team /topstats", "say /topstaty", "say_team /topstaty", "topstaty" };

new playerName[MAX_PLAYERS + 1][64], playerStats[MAX_PLAYERS + 1][statsInfo], Handle:sql, bool:blockCount, bool:showedOneAndOnly, round, dataLoaded, visitInfo, maxPlayers;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for(new i; i < sizeof commandMenu; i++) register_clcmd(commandMenu[i], "stats_menu");
		
	for(new i; i < sizeof commandTime; i++) register_clcmd(commandTime[i], "command_time");

	for(new i; i < sizeof commandAdminTime; i++) register_clcmd(commandAdminTime[i], "command_time_admin");

	for(new i; i < sizeof commandTopTime; i++) register_clcmd(commandTopTime[i], "command_time_top");
	
	for(new i; i < sizeof commandBestStats; i++) register_clcmd(commandBestStats[i], "command_best_stats");
		
	for(new i; i < sizeof commandTopStats; i++) register_clcmd(commandTopStats[i], "command_top_stats");

	register_event("TextMsg", "hostages_rescued", "a", "2&#All_Hostages_R");

	register_message(get_user_msgid("SayText"), "say_text");

	register_message(SVC_INTERMISSION, "message_intermission");
	
	maxPlayers = get_maxplayers();
}

public plugin_cfg()
	sql_init();
	
public plugin_end()
	SQL_FreeHandle(sql);
	
public plugin_natives()
{
	register_native("cod_stats_add_kill", "_cod_stats_add_kill", 1);

	register_native("cod_get_user_time", "_cod_get_user_time", 1);
	
	register_native("cod_get_user_time_text", "_cod_get_user_time_text", 1);
}

public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id)) return;

	get_user_name(id, playerName[id], charsmax(playerName[]));

	mysql_escape_string(playerName[id], playerName[id], charsmax(playerName[]));
	
	rem_bit(id, dataLoaded);
	rem_bit(id, visitInfo);

	for(new i = 0; i <= CURRENT_DEATHS; i++) playerStats[id][i] = 0;
	
	load_stats(id);
}

public client_authorized(id)
	playerStats[id][ADMIN] = get_user_flags(id) & ADMIN_BAN ? 1 : 0;
	
public client_disconnected(id)
	save_stats(id);
	
public stats_menu(id)
{
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menu = menu_create("\wMenu \yStatow\r", "stats_menu_handle");
 
	menu_additem(menu, "\wMoj \rCzas \y(/czas)", "1");
	if(get_user_flags(id) & ADMIN_BAN) menu_additem(menu, "\wCzas \rAdminow \y(/adminczas)", "2");
	menu_additem(menu, "\wTop \rCzasu \y(/ctop15)", "3");
	menu_additem(menu, "\wNajlepsze \rStaty \y(/staty)", "4");
	menu_additem(menu, "\wTop \rStatow \y(/stop15)", "5");
    
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}  
 
public stats_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new itemData[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, itemCallback);
    
	new item = str_to_num(itemData);
    
	switch(item)
    { 
		case 1: command_time(id);
		case 2: command_time_admin(id)
		case 3: command_time_top(id);
		case 4: command_best_stats(id);
		case 5: command_top_stats(id);
	}
	
	menu_destroy(menu);

	return PLUGIN_HANDLED;
} 

public command_time(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[128], tempId[1];
	
	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT rank, count FROM (SELECT COUNT(*) as count FROM `cod_stats`) a CROSS JOIN (SELECT COUNT(*) as rank FROM `cod_stats` WHERE `time` > '%i' ORDER BY `time` DESC) b", playerStats[id][TIME]);
	SQL_ThreadQuery(sql, "show_time", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_time(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if(failState) 
	{
		log_to_file("cod_mod.log", "SQL Error: %s (%d)", error, errorNum);
		
		return PLUGIN_HANDLED;
	}
	
	new id = tempId[0];
	
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	new rank = SQL_ReadResult(query, 0) + 1, players = SQL_ReadResult(query, 1), seconds = (playerStats[id][TIME] + get_user_time(id)), minutes, hours;
	
	while(seconds >= 60)
	{
		seconds -= 60;
		minutes++;
	}
	while(minutes >= 60)
	{
		minutes -= 60;
		hours++;
	}
	
	cod_print_chat(id, "Spedziles na serwerze lacznie^x04 %i h %i min %i s^x01.", hours, minutes, seconds);
	cod_print_chat(id, "Zajmujesz^x04 %i/%i^x01 miejsce w rankingu czasu gry.", rank, players);
	
	return PLUGIN_HANDLED;
}

public command_time_admin(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN) || !is_user_connected(id)) return PLUGIN_HANDLED;


	new queryData[128], tempData[2];
	
	tempData[0] = id;
	tempData[1] = 1;

	formatex(queryData, charsmax(queryData), "SELECT name, time FROM `cod_stats` WHERE admin = '1' ORDER BY time DESC");
	SQL_ThreadQuery(sql, "show_top_time", queryData, tempData, sizeof(tempData));

	return PLUGIN_HANDLED;
}

public command_time_top(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[128], tempId[2];
	
	tempId[0] = id;
	tempId[0] = 0;

	formatex(queryData, charsmax(queryData), "SELECT name, time FROM `cod_stats` ORDER BY time DESC LIMIT 15");
	SQL_ThreadQuery(sql, "show_top_time", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_top_time(failState, Handle:query, error[], errorNum, tempData[], dataSize)
{
	if(failState) 
	{
		log_to_file("cod_mod.log", "SQL Error: %s (%d)", error, errorNum);
		
		return PLUGIN_HANDLED;
	}
	
	new id = tempData[0];
	
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	static motdData[2048], userName[64], motdLength, rank = 0, seconds = 0, minutes = 0, hours = 0;
	
	motdLength = format(motdData, charsmax(motdData), "<body bgcolor=#000000><font color=#FFB000><pre>");
	motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1s %-22.22s %13s^n", "#", "Nick", "Czas Gry");
	
	while(SQL_MoreResults(query))
	{
		rank++;
		
		SQL_ReadResult(query, 0, userName, charsmax(userName));
		seconds = SQL_ReadResult(query, 1);
		
		replace_all(userName, charsmax(userName), "<", "");
		replace_all(userName, charsmax(userName), ">", "");
		
		while(seconds >= 60)
		{
			seconds -= 60;
			minutes++;
		}
		while(minutes >= 60)
		{
			minutes -= 60;
			hours++;
		}
		
		if(rank >= 10) motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1i %-22.22s %1ih %1imin %1is^n", rank, userName, hours, minutes, seconds);
		else motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1i %-22.22s %2ih %1imin %1is^n", rank, userName, hours, minutes, seconds);
		
		SQL_NextRow(query);
	}
	
	tempData[1] ? show_motd(id, motdData, "Czas Gry Adminow") : show_motd(id, motdData, "Top15 Czasu Gry");
	
	return PLUGIN_HANDLED;
}

public command_best_stats(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[128], tempId[1];
	
	tempId[0] = id;

	playerStats[id][CURRENT_STATS] = playerStats[id][CURRENT_KILLS]*2 + playerStats[id][CURRENT_HS_KILLS] - playerStats[id][CURRENT_DEATHS]*2;

	if(playerStats[id][CURRENT_STATS] > playerStats[id][BEST_STATS]) formatex(queryData, charsmax(queryData), "SELECT rank, count FROM (SELECT COUNT(*) as count FROM `cod_stats`) a CROSS JOIN (SELECT COUNT(*) as rank FROM `cod_stats` WHERE `beststats` > '%i' ORDER BY `beststats` DESC) b", playerStats[id][BEST_STATS]);
	else formatex(queryData, charsmax(queryData), "SELECT rank, count FROM (SELECT COUNT(*) as count FROM `cod_stats`) a CROSS JOIN (SELECT COUNT(*) as rank FROM `cod_stats` WHERE `beststats` > '%i' ORDER BY `beststats` DESC) b", playerStats[id][CURRENT_STATS]);

	SQL_ThreadQuery(sql, "show_best_stats", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_best_stats(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if(failState) 
	{
		log_to_file("cod_mod.log", "SQL Error: %s (%d)", error, errorNum);
		
		return PLUGIN_HANDLED;
	}
	
	new id = tempId[0];
	
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	new rank = SQL_ReadResult(query, 0), players = SQL_ReadResult(query, 1);
	
	if(playerStats[id][CURRENT_STATS] > playerStats[id][BEST_STATS]) cod_print_chat(id, "Twoje najlepsze staty to^x04 %i^x01 zabic (w tym^x04 %i^x01 z HS) i^x04 %i^x01 zgonow^x01.", playerStats[id][CURRENT_KILLS], playerStats[id][CURRENT_HS_KILLS], playerStats[id][CURRENT_DEATHS]);
	else cod_print_chat(id, "Twoje najlepsze staty to^x04 %i^x01 zabic (w tym^x04 %i^x01 z HS) i^x04 %i^x01 zgonow^x01.", playerStats[id][BEST_KILLS], playerStats[id][BEST_HS_KILLS], playerStats[id][BEST_DEATHS]);
		
	cod_print_chat(id, "Zajmujesz^x04 %i/%i^x01 miejsce w rankingu najlepszych statystyk.", rank, players);
	
	return PLUGIN_HANDLED;
}

public command_top_stats(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[128], tempId[1];
	
	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT name, bestkills, besths, bestdeaths FROM `cod_stats` ORDER BY beststats DESC LIMIT 15");
	SQL_ThreadQuery(sql, "show_top_stats", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_top_stats(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if(failState) 
	{
		log_to_file("cod_mod.log", "SQL Error: %s (%d)", error, errorNum);
		
		return PLUGIN_HANDLED;
	}
	
	new id = tempId[0];
	
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	static motdData[2048], userName[64], motdLength, rank = 0, kills = 0, hs = 0, deaths = 0;
	
	motdLength = format(motdData, charsmax(motdData), "<body bgcolor=#000000><font color=#FFB000><pre>");
	motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1s %-22.22s %19s %4s^n", "#", "Nick", "Zabojstwa", "Zgony");
	
	while(SQL_MoreResults(query))
	{
		rank++;
		
		SQL_ReadResult(query, 0, userName, charsmax(userName));

		kills = SQL_ReadResult(query, 1);
		hs = SQL_ReadResult(query, 2);
		deaths = SQL_ReadResult(query, 3);
		
		replace_all(userName, charsmax(userName), "<", "");
		replace_all(userName, charsmax(userName), ">", "");
		
		if(rank >= 10) motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1i %-22.22s %1d (%i HS) %12d^n", rank, userName, kills, hs, deaths);
		else motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%1i %-22.22s %2d (%i HS) %12d^n", rank, userName, kills, hs, deaths);
		
		SQL_NextRow(query);
	}
	
	show_motd(id, motdData, "Top15 Statystyk");
	
	return PLUGIN_HANDLED;
}

public check_time(id)
{
	id -= TASK_TIME;
	
	if(get_bit(id, visitInfo)) return;
	
	if(get_bit(id, dataLoaded))
	{ 
		set_task(3.0, "check_time", id + TASK_TIME);

		return;
	}
	
	set_bit(id, visitInfo);
	
	new currentYear, lastYear, currentMonth, lastMonth, currentDay, lastDay, hour, minute, second, time = get_systime();
	
	UnixToTime(time, currentYear, currentMonth, currentDay, hour, minute, second, UT_TIMEZONE_SERVER);
	
	cod_print_chat(id, "Aktualnie jest godzina^x03 %02d:%02d:%02d (Data: %02d.%02d.%02d)^x01.", hour, minute, second, currentDay, currentMonth, currentYear);
	
	if(playerStats[id][FIRST_VISIT] == playerStats[id][LAST_VISIT]) cod_print_chat(id, "To twoja^x03 pierwsza wizyta^x01 na serwerze. Zyczymy milej gry!" );
	else 
	{
		UnixToTime(playerStats[id][LAST_VISIT], lastYear, lastMonth, lastDay, hour, minute, second, UT_TIMEZONE_SERVER);
		
		if(currentYear == lastYear && currentMonth == lastMonth && currentDay == lastDay) cod_print_chat(id, "Twoja ostatnia wizyta miala miejsce^x04 dzisiaj^x01 o^x03 %02d:%02d:%02d^x01. Zyczymy milej gry!", hour, minute, second);
		else if(currentYear == lastYear && currentMonth == lastMonth && (currentDay - 1) == lastDay) cod_print_chat(id, "Twoja ostatnia wizyta miala miejsce^x04 wczoraj^x01 o^x03 %02d:%02d:%02d^x01. Zyczymy milej gry!", hour, minute, second);
		else cod_print_chat(id, "Twoja ostatnia wizyta:^x03 %02d:%02d:%02d (Data: %02d.%02d.%02d)^x01. Zyczymy milej gry!", hour, minute, second, lastDay, lastMonth, lastYear);
	}
}

public cod_spawned(id)
	if(get_bit(id, visitInfo)) set_task(5.0, "check_time", id + TASK_TIME);

public first_round()
	blockCount = false;

public round_restart()
	round = 0;

public cod_new_round()
{
	showedOneAndOnly = false;

	if(!round)
	{
		set_task(30.0, "first_round");

		blockCount = true;
	}

	round++;

	new bestId, bestFrags, tempFrags, bestDeaths, tempDeaths;

	for(new id = 1; id <= MAX_PLAYERS; id++) 
	{
		if(!is_user_connected(id) || is_user_bot(id) || is_user_hltv(id)) continue;

		tempFrags = get_user_frags(id);
		tempDeaths = get_user_deaths(id);

		if(tempFrags > 0 && tempFrags > bestFrags)
		{
			bestFrags = tempFrags;
			bestDeaths = tempDeaths;
			bestId = id;
		}
	}

	if(is_user_connected(bestId)) 
	{
		new bestName[64];

		get_user_name(bestId, bestName, charsmax(bestName));

		cod_print_chat(0, "^x03 %s^x01 prowadzi w grze z^x04 %i^x01 fragami i^x04 %i^x01 zgonami.", bestName, bestFrags, bestDeaths);
	}
}

public cod_killed(killer, victim, weaponId, hitPlace)
{
	playerStats[victim][CURRENT_DEATHS]++;

	playerStats[killer][CURRENT_KILLS]++;
	playerStats[killer][KILLS]++;
		
	if(hitPlace == HIT_HEAD) playerStats[killer][CURRENT_HS_KILLS]++;

	new killerName[64];

	get_user_name(killer, killerName, charsmax(killerName));

	cod_print_chat(victim, "Zostales zabity przez^x03 %s^x01, ktoremu zostalo^x04 %i^x01 HP.", killerName, get_user_health(killer));

	if(weaponId == CSW_KNIFE)
	{
		for(new i = 1; i <= MAX_PLAYERS; i++)
		{
			if(!is_user_connected(i)) continue;

			if(pev(i, pev_iuser2) == victim || i == victim) client_cmd(i, "spk %s", codSounds[SOUND_HUMILIATION]);
		}
	}

	if(blockCount) return;

	new tCount, ctCount, lastT, lastCT;

	for(new i = 1; i <= MAX_PLAYERS; i++)
	{
		if(!is_user_alive(i)) continue;

		switch(get_user_team(i))
		{
			case 1: 
			{
				tCount++;
				lastT = i;
			}
			case 2: 
			{
				ctCount++;
				lastCT = i;
			}
		}
	}
	
	if(tCount == 1 && ctCount == 1)
	{
		for(new i = 1; i <= MAX_PLAYERS; i++)
		{
			if(!is_user_connected(i)) continue;

			if(pev(i, pev_iuser2) == lastT || pev(i, pev_iuser2) == lastCT || i == lastT || i == lastCT) client_cmd(i, "spk %s", codSounds[SOUND_FORCE]);
		}

		new lastTName[32], lastCTName[32], hudData[64];

		get_user_name(lastT, lastTName, charsmax(lastTName));
		get_user_name(lastCT, lastCTName, charsmax(lastCTName));

		formatex(hudData, charsmax(hudData), "%s vs. %s", lastTName, lastCTName);

		cod_show_hud(0, hudData, TYPE_DHUD, 255, 128, 0, -1.0, 0.30, 0, 5.0, 5.0, 0.5, 0.15);
	}
	if(tCount == 1 && ctCount > 1 && !showedOneAndOnly)
	{
		showedOneAndOnly = true;

		for(new i = 1; i <= MAX_PLAYERS; i++)
		{
			if(!is_user_connected(i)) continue;

			if((is_user_alive(i) && get_user_team(i) == 2) || (!is_user_alive(i) && get_user_team(pev(i, pev_iuser2)) == 2)) client_cmd(i, "spk %s", codSounds[SOUND_LAST]);

			if(pev(i, pev_iuser2) == lastT || i == lastT) client_cmd(i, "spk %s", codSounds[SOUND_ONE]);
		}

		new hudData[16];

		formatex(hudData, charsmax(hudData), "%i vs %i", tCount, ctCount);

		cod_show_hud(0, hudData, TYPE_DHUD, 255, 128, 0, -1.0, 0.30, 0, 5.0, 5.0, 0.5, 0.15);
	}
	if(tCount > 1 && ctCount == 1 && !showedOneAndOnly)
	{
		showedOneAndOnly = true;

		for(new i = 1; i <= MAX_PLAYERS; i++)
		{
			if(!is_user_connected(i)) continue;
			
			if((is_user_alive(i) && get_user_team(i) == 1) || (!is_user_alive(i) && get_user_team(pev(i, pev_iuser2)) == 1)) client_cmd(i, "spk %s", codSounds[SOUND_LAST]);

			if(pev(i, pev_iuser2) == lastCT || i == lastCT) client_cmd(i, "spk %s", codSounds[SOUND_ONE]);
		}

		new hudData[16];

		formatex(hudData, charsmax(hudData), "%i vs %i", ctCount, tCount);

		cod_show_hud(0, hudData, TYPE_DHUD, 255, 128, 0, -1.0, 0.30, 0, 5.0, 5.0, 0.5, 0.15);
	}
}

public bomb_planted(planter)
{
	for(new i = 1; i <= MAX_PLAYERS; i++)
	{
		if(!is_user_connected(i)) continue;

		if((is_user_alive(i) && get_user_team(i) == 2) || (!is_user_alive(i) && get_user_team(pev(i, pev_iuser2)) == 2)) client_cmd(i, "spk %s", codSounds[SOUND_BOMB]);
	}
}

public message_intermission() 
{
	new playersList[32], id, players;

	get_players(playersList, players, "h");
	
	if(!players) return PLUGIN_CONTINUE;

	for (new i = 0; i < players; i++)
	{
		id = playersList[i];
		
		if(!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id)) continue;
		
		save_stats(id, 1);
	}

	return PLUGIN_CONTINUE;
}

public say_text(msgId, msgDest, msgEnt)
{
	new id = get_msg_arg_int(1);
	
	if(is_user_connected(id))
	{
		new tempMessage[192], message[192], chatPrefix[16], stats[8], body[8], rank;
		
		get_msg_arg_string(2, tempMessage, charsmax(tempMessage));
		rank = get_user_stats(id, stats, body);

		if(rank > 3) return PLUGIN_CONTINUE;
			
		switch(rank)
		{
			case 1: formatex(chatPrefix, charsmax(chatPrefix), "^x04[TOP1]");
			case 2: formatex(chatPrefix, charsmax(chatPrefix), "^x04[TOP2]");
			case 3: formatex(chatPrefix, charsmax(chatPrefix), "^x04[TOP3]");
		}
		
		if(!equal(tempMessage, "#Cstrike_Chat_All"))
		{
			add(message, charsmax(message), chatPrefix);
			add(message, charsmax(message), " ");
			add(message, charsmax(message), tempMessage);
		}
		else
		{
			add(message, charsmax(message), chatPrefix);
			add(message, charsmax(message), "^x03 %s1^x01 :  %s2");
		}
		
		set_msg_arg_string(2, message);
	}

	return PLUGIN_CONTINUE;
}

public bomb_explode(planter, defuser) 
	playerStats[planter][KILLS] += 3;

public bomb_defused(defuser)
	playerStats[defuser][KILLS] += 3;

public hostages_rescued()
	playerStats[get_loguser_index()][KILLS] += 3;
	
public sql_init()
{
	new host[32], user[32], pass[32], db[32], queryData[512], error[128], errorNum;
	
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
	
	formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_stats` (`name` varchar(35) NOT NULL, `admin` INT NOT NULL, `kills` INT NOT NULL, ");
	add(queryData, charsmax(queryData), "`time` INT NOT NULL, `firstvisit` INT NOT NULL, `lastvisit` INT NOT NULL, `bestkills` INT NOT NULL, ");
	add(queryData, charsmax(queryData), "`bestdeaths` INT NOT NULL, `besths` INT NOT NULL, `beststats` INT NOT NULL, PRIMARY KEY (`name`));");

	new Handle:query = SQL_PrepareQuery(connectHandle, queryData);

	SQL_Execute(query);
	
	SQL_FreeHandle(query);
	SQL_FreeHandle(connectHandle);
}

public load_stats(id)
{
	if(!is_user_connected(id)) return;

	new queryData[128], tempId[1];
	
	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT * FROM `cod_stats` WHERE name = '%s'", playerName[id]);
	SQL_ThreadQuery(sql, "load_stats_handle", queryData, tempId, sizeof(tempId));
}

public load_stats_handle(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if(failState) 
	{
		log_to_file("cod_mod.log", "SQL Error: %s (%d)", error, errorNum);
		
		return;
	}
	
	new id = tempId[0];
	
	if(!is_user_connected(id)) return;
	
	if(SQL_NumRows(query))
	{
		playerStats[id][KILLS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "kills"));
		playerStats[id][TIME] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "time"));
		playerStats[id][FIRST_VISIT] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "firstvisit"));
		playerStats[id][LAST_VISIT] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "lastvisit"));
		playerStats[id][BEST_STATS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "beststats"));
		playerStats[id][BEST_KILLS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "bestkills"));
		playerStats[id][BEST_HS_KILLS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "besths"));
		playerStats[id][BEST_DEATHS] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "bestdeaths"));
	}
	else
	{
		new queryData[128];
		
		formatex(queryData, charsmax(queryData), "INSERT IGNORE INTO `cod_stats` (`name`) VALUES ('%s')", playerName[id]);
		
		SQL_ThreadQuery(sql, "ignore_handle", queryData);
	}
	
	set_bit(id, dataLoaded);
}

save_stats(id, end = 0)
{
	if(!get_bit(id, dataLoaded)) return;

	new queryData[256], queryTemp[128];
		
	playerStats[id][CURRENT_STATS] = playerStats[id][CURRENT_KILLS]*2 + playerStats[id][CURRENT_HS_KILLS] - playerStats[id][CURRENT_DEATHS]*2;
	
	if(playerStats[id][CURRENT_STATS] > playerStats[id][BEST_STATS])
	{			
		formatex(queryTemp, charsmax(queryTemp), ", `bestkills` = %d, `besths` = %d, `bestdeaths` = %d, `beststats` = %d", 
		playerStats[id][CURRENT_KILLS], playerStats[id][CURRENT_HS_KILLS], playerStats[id][CURRENT_DEATHS], playerStats[id][CURRENT_STATS]);
	}

	playerStats[id][TIME] += get_user_time(id);

	formatex(queryData, charsmax(queryData), "UPDATE `cod_stats` SET `admin` = %i, `kills` = %i, `time` = %i, `lastvisit` = %i%s WHERE name = '%s' AND `time` <= %i", 
	playerStats[id][ADMIN], playerStats[id][KILLS], playerStats[id][TIME], get_systime(), queryTemp, playerName[id], playerStats[id][TIME]);
		
	switch(end)
	{
		case 0: SQL_ThreadQuery(sql, "ignore_handle", queryData);
		case 1:
		{
			new error[128], errorNum, Handle:sqlConnection, Handle:query;
			
			sqlConnection = SQL_Connect(sql, errorNum, error, charsmax(error));

			if(!sqlConnection)
			{
				log_to_file("cod_mod.log", "Save - Could not connect to SQL database.  [%d] %s", error, error);
				
				SQL_FreeHandle(sqlConnection);
				
				return;
			}
			
			query = SQL_PrepareQuery(sqlConnection, queryData);
			
			if(!SQL_Execute(query))
			{
				errorNum = SQL_QueryError(query, error, charsmax(error));
				
				log_to_file("cod_mod.log", "Save Query Nonthreaded failed. [%d] %s", errorNum, error);
				
				SQL_FreeHandle(query);
				SQL_FreeHandle(sqlConnection);
				
				return;
			}

			SQL_FreeHandle(query);
			SQL_FreeHandle(sqlConnection);
		}
	}
	
	if(end) rem_bit(id, dataLoaded);
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

public _cod_stats_add_kill(id)
{
	if(!is_user_valid(id)) return;
	
	playerStats[id][CURRENT_KILLS]++;
	playerStats[id][KILLS]++;
}

public _cod_get_user_time(id)
{
	if(!is_user_valid(id)) return 0;

	return playerStats[id][TIME] + get_user_time(id);
}

public _cod_get_user_time_text(id, dataReturn[], dataLength)
{
	if(!is_user_valid(id)) return;

	new tempData[64], seconds = (playerStats[id][TIME] + get_user_time(id)), minutes, hours;
	
	while(seconds >= 60)
	{
		seconds -= 60;
		minutes++;
	}
	while(minutes >= 60)
	{
		minutes -= 60;
		hours++;
	}
	
	param_convert(2);
	
	formatex(tempData, charsmax(tempData), "%i h %i min %i s", hours, minutes, seconds);

	copy(dataReturn, dataLength, tempData);
}

stock get_loguser_index()
{
	new userLog[80], userName[32];
	read_logargv(0, userLog, charsmax(userLog));
	parse_loguser(userLog, userName, charsmax(userName));

	return get_user_index(userName);
}