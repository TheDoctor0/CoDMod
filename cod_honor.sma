#include <amxmodx>
#include <sqlx>
#include <fakemeta>
#include <cod>

#define PLUGIN	"CoD Honor System"
#define AUTHOR	"O'Zone"
#define VERSION	"1.0"
	
enum _:events { KILL, KILL_HS, WIN_ROUND, BOMB_DEFUSE, BOMB_PLANT, HOST_RESCUE, HOST_KILL };

new cvarMinPlayers, cvarKill, cvarKillHS, cvarWinRound, cvarBombPlated, cvarBombDefused, cvarRescueHostage, cvarKillHostage;

new playerName[MAX_PLAYERS + 1][64], playerHonor[MAX_PLAYERS + 1], Handle:sql, honorEvent[events], minPlayers, dataLoaded;

public plugin_init()
{	
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cvarMinPlayers = register_cvar("cod_honor_minplayers", "4");
	cvarKill = register_cvar("cod_honor_kill", "1");
	cvarKillHS = register_cvar("cod_honor_killhs", "1");
	cvarWinRound = register_cvar("cod_honor_winround", "1");
	cvarBombPlated = register_cvar("cod_honor_bombplanted", "2");
	cvarBombDefused = register_cvar("cod_honor_bombdefused", "2");
	cvarRescueHostage = register_cvar("cod_honor_rescuehostage", "1");
	cvarKillHostage = register_cvar("cod_honor_killhostage", "4");
	
	register_event("SendAudio", "t_win_round" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "ct_win_round", "a", "2&%!MRAD_ct_win_round");

	register_logevent("hostage_rescued", 3, "1=triggered", "2=Rescued_A_Hostage");
	register_logevent("hostage_killed", 3, "1=triggered", "2=Killed_A_Hostage");
	
	register_message(SVC_INTERMISSION, "message_intermission");
}

public plugin_cfg()
{
	minPlayers = get_pcvar_num(cvarMinPlayers);

	honorEvent[KILL] = get_pcvar_num(cvarKill);
	honorEvent[KILL_HS] = get_pcvar_num(cvarKillHS);
	honorEvent[WIN_ROUND] = get_pcvar_num(cvarWinRound);
	honorEvent[BOMB_PLANT] = get_pcvar_num(cvarBombPlated);
	honorEvent[BOMB_DEFUSE] = get_pcvar_num(cvarBombDefused);
	honorEvent[HOST_RESCUE] = get_pcvar_num(cvarRescueHostage);
	honorEvent[HOST_KILL] = get_pcvar_num(cvarKillHostage);

	sql_init();
}

public plugin_natives()
{
	register_native("cod_get_user_honor", "_cod_get_user_honor", 1);
	register_native("cod_set_user_honor", "_cod_set_user_honor", 1);
	register_native("cod_add_user_honor", "_cod_add_user_honor", 1);
}

public plugin_end()
	SQL_FreeHandle(sql);

public client_connect(id)
{
	playerHonor[id] = 0;
	
	rem_bit(id, dataLoaded);

	if(is_user_bot(id) || is_user_hltv(id)) return;

	get_user_name(id, playerName[id], charsmax(playerName[]));

	mysql_escape_string(playerName[id], playerName[id], charsmax(playerName[]));
	
	load_honor(id);
}

public client_disconnected(id)
	save_honor(id);

public cod_killed(killer, victim, weaponId, hitPlace)
{
	if(get_playersnum() < minPlayers) return;
		
	playerHonor[killer] += cod_get_user_vip(killer) ? honorEvent[KILL] * 2 : honorEvent[KILL];
	
	if(hitPlace == HIT_HEAD) playerHonor[killer] += cod_get_user_vip(killer) ? honorEvent[KILL_HS] * 2 : honorEvent[KILL_HS];
	
	save_honor(killer);
}

public t_win_round()
	round_winner(1);
	
public ct_win_round()
	round_winner(2);

public round_winner(team)
{
	if(get_playersnum() < minPlayers) return;

	for(new id = 1; id < MAX_PLAYERS; id++) 
	{
		if(!cod_get_user_class(id) || get_user_team(id) != team) continue;

		playerHonor[id] += cod_get_user_vip(id) ? honorEvent[WIN_ROUND] * 2 : honorEvent[WIN_ROUND];

		save_honor(id);
	}
}

public bomb_planted(id)
{
	if(get_playersnum() < minPlayers || !cod_get_user_class(id)) return;

	playerHonor[id] += cod_get_user_vip(id) ? honorEvent[BOMB_PLANT] * 2 : honorEvent[BOMB_PLANT];

	save_honor(id);
}

public bomb_defused(id)
{
	if(get_playersnum() < minPlayers || !cod_get_user_class(id)) return;

	playerHonor[id] += cod_get_user_vip(id) ? honorEvent[BOMB_DEFUSE] * 2 : honorEvent[BOMB_DEFUSE];

	save_honor(id);
}

public hostage_rescued()
{
	if(get_playersnum() < minPlayers) return;

	new id = get_loguser_index();

	if(!cod_get_user_class(id)) return;
	
	playerHonor[id] += cod_get_user_vip(id) ? honorEvent[HOST_RESCUE] * 2 : honorEvent[HOST_RESCUE];

	save_honor(id);
}

public hostage_killed() 
{
	if(get_playersnum() < minPlayers) return;

	new id = get_loguser_index();

	if(!cod_get_user_class(id)) return;
	
	playerHonor[id] -= cod_get_user_vip(id) ? honorEvent[HOST_KILL] / 2 : honorEvent[HOST_KILL];

	save_honor(id);
}

public message_intermission() 
{
	for(new id = 1; id < MAX_PLAYERS; id++)
	{
		if(!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id)) continue;
		
		save_honor(id, 1);
	}

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
	
	formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_honor` (`name` VARCHAR(35), `honor` INT(11) NOT NULL, PRIMARY KEY(`name`));");

	new Handle:query = SQL_PrepareQuery(connectHandle, queryData);

	SQL_Execute(query);
	
	SQL_FreeHandle(query);
	SQL_FreeHandle(connectHandle);
}

public load_honor(id)
{
	new queryData[128], tempId[1];
	
	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT * FROM `cod_honor` WHERE name = '%s'", playerName[id]);
	SQL_ThreadQuery(sql, "load_honor_handle", queryData, tempId, sizeof(tempId));
} 

public load_honor_handle(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if(failState) 
	{
		log_to_file("cod_mod.log", "SQL Error: %s (%d)", error, errorNum);
		
		return;
	}
	
	new id = tempId[0];
	
	if(SQL_MoreResults(query)) playerHonor[id] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "honor"));
	else
	{
		new queryData[128];
		
		//formatex(queryData, charsmax(queryData), "INSERT IGNORE INTO `cod_honor` (`name`) VALUES ('%s')", playerName[id]);
		formatex(queryData, charsmax(queryData), "INSERT IGNORE INTO `cod_honor` (`name`, `honor`) VALUES ('%s', '10000')", playerName[id]);
		
		SQL_ThreadQuery(sql, "ignore_handle", queryData);

		//TESTY
		playerHonor[id] = 10000;
	}
	
	set_bit(id, dataLoaded);
}

stock save_honor(id, end = 0)
{
	if(!get_bit(id, dataLoaded)) return;

	new queryData[128];
		
	formatex(queryData, charsmax(queryData), "UPDATE `cod_honor` SET honor = '%i' WHERE name = '%s'", playerHonor[id], playerName[id]);
		
	switch(end)
	{
		case 0: SQL_ThreadQuery(sql, "ignore_handle", queryData);
		case 1:
		{
			new error[128], errorNum, Handle:sqlConnection, Handle:query;
			
			sqlConnection = SQL_Connect(sql, errorNum, error, charsmax(error));

			if(!sqlConnection)
			{
				log_to_file("cod_mod.log", "Save - Could not connect to SQL database. [%d] %s", error, error);
				
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

public _cod_get_user_honor(id)
	return playerHonor[id];

public _cod_set_user_honor(id, amount)
{
	playerHonor[id] = max(0, amount);
	
	save_honor(id);
}

public _cod_add_user_honor(id, amount)
{
	playerHonor[id] += max(0, amount);
	
	save_honor(id);
}


stock get_loguser_index()
{
	new userLog[96], userName[32];
	
	read_logargv(0, userLog, charsmax(userLog));
	parse_loguser(userLog, userName, charsmax(userName));

	return get_user_index(userName);
}