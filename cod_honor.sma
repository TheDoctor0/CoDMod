#include <amxmodx>
#include <sqlx>
#include <fakemeta>
#include <cod>

#define PLUGIN	"CoD Honor System"
#define AUTHOR	"O'Zone"
#define VERSION	"1.1.0"

new cvarMinPlayers, cvarKill, cvarKillHS, cvarWinRound, cvarBombPlanted, cvarBombDefused, cvarRescueHostage, cvarKillHostage, Float:cvarVIPMultiplier;

new playerName[MAX_PLAYERS + 1][MAX_SAFE_NAME], playerHonor[MAX_PLAYERS + 1], Handle:sql, Handle:connection, bool:sqlConnected, dataLoaded;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	bind_pcvar_num(create_cvar("cod_honor_min_players", "4"), cvarMinPlayers);
	bind_pcvar_num(create_cvar("cod_honor_kill", "1"), cvarKill);
	bind_pcvar_num(create_cvar("cod_honor_killhs", "1"), cvarKillHS);
	bind_pcvar_num(create_cvar("cod_honor_winround", "1"), cvarWinRound);
	bind_pcvar_num(create_cvar("cod_honor_bombplanted", "2"), cvarBombPlanted);
	bind_pcvar_num(create_cvar("cod_honor_bombdefused", "2"), cvarBombDefused);
	bind_pcvar_num(create_cvar("cod_honor_rescuehostage", "2"), cvarRescueHostage);
	bind_pcvar_num(create_cvar("cod_honor_killhostage", "4"), cvarKillHostage);
	bind_pcvar_float(create_cvar("cod_honor_vip_multiplier", "1.5"), cvarVIPMultiplier);

	register_event("SendAudio", "t_win_round" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "ct_win_round", "a", "2&%!MRAD_ct_win_round");

	register_logevent("hostage_rescued", 3, "1=triggered", "2=Rescued_A_Hostage");
	register_logevent("hostage_killed", 3, "1=triggered", "2=Killed_A_Hostage");
}

public plugin_cfg()
	sql_init();

public plugin_natives()
{
	register_native("cod_get_user_honor", "_cod_get_user_honor", 1);
	register_native("cod_set_user_honor", "_cod_set_user_honor", 1);
	register_native("cod_add_user_honor", "_cod_add_user_honor", 1);
}

public plugin_end()
{
	SQL_FreeHandle(sql);
	SQL_FreeHandle(connection);
}

public client_putinserver(id)
{
	playerHonor[id] = 0;

	rem_bit(id, dataLoaded);

	if (is_user_bot(id) || is_user_hltv(id)) return;

	get_user_name(id, playerName[id], charsmax(playerName[]));

	cod_sql_string(playerName[id], playerName[id], charsmax(playerName[]));

	set_task(0.1, "load_honor", id);
}

public client_disconnected(id)
	remove_task(id);

public cod_killed(killer, victim, weaponId, hitPlace)
{
	if (get_playersnum() < cvarMinPlayers) return;

	playerHonor[killer] += get_user_bonus(killer, cvarKill);

	if (hitPlace == HIT_HEAD) playerHonor[killer] += get_user_bonus(killer, cvarKillHS);

	save_honor(killer);
}

public t_win_round()
	round_winner(1);

public ct_win_round()
	round_winner(2);

public round_winner(team)
{
	if (get_playersnum() < cvarMinPlayers) return;

	for (new id = 1; id < MAX_PLAYERS; id++) {
		if (!cod_get_user_class(id) || get_user_team(id) != team) continue;

		playerHonor[id] += get_user_bonus(id, cvarWinRound);

		save_honor(id);
	}
}

public bomb_planted(id)
{
	if (get_playersnum() < cvarMinPlayers || !cod_get_user_class(id)) return;

	playerHonor[id] += get_user_bonus(id, cvarBombPlanted);

	save_honor(id);
}

public bomb_defused(id)
{
	if (get_playersnum() < cvarMinPlayers || !cod_get_user_class(id)) return;

	playerHonor[id] += get_user_bonus(id, cvarBombDefused);

	save_honor(id);
}

public hostage_rescued()
{
	if (get_playersnum() < cvarMinPlayers) return;

	new id = get_loguser_index();

	if (!cod_get_user_class(id)) return;

	playerHonor[id] += get_user_bonus(id, cvarRescueHostage);

	save_honor(id);
}

public hostage_killed()
{
	if (get_playersnum() < cvarMinPlayers) return;

	new id = get_loguser_index();

	if (!cod_get_user_class(id)) return;

	playerHonor[id] -= cod_get_user_vip(id) ? floatround(cvarKillHostage / cvarVIPMultiplier) : cvarKillHostage;

	save_honor(id);
}

public cod_end_map()
{
	for (new id = 1; id < MAX_PLAYERS; id++) {
		if (!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id)) continue;

		save_honor(id, 1);
	}

	return PLUGIN_CONTINUE;
}

public sql_init()
{
	new host[64], user[64], pass[64], db[64], queryData[128], error[128], errorNum;

	get_cvar_string("cod_sql_host", host, charsmax(host));
	get_cvar_string("cod_sql_user", user, charsmax(user));
	get_cvar_string("cod_sql_pass", pass, charsmax(pass));
	get_cvar_string("cod_sql_db", db, charsmax(db));

	sql = SQL_MakeDbTuple(host, user, pass, db);

	connection = SQL_Connect(sql, errorNum, error, charsmax(error));

	if (errorNum) {
		cod_log_error(PLUGIN, "SQL Error: %s", error);

		set_task(5.0, "sql_init");

		return;
	}

	formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_honor` (`name` VARCHAR(%i), `honor` INT(11) NOT NULL, PRIMARY KEY(`name`));", MAX_SAFE_NAME);

	new Handle:query = SQL_PrepareQuery(connection, queryData);

	SQL_Execute(query);

	SQL_FreeHandle(query);

	sqlConnected = true;
}

public load_honor(id)
{
	if (!sqlConnected) {
		set_task(1.0, "load_honor", id);

		return;
	}

	new queryData[128], tempId[1];

	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT * FROM `cod_honor` WHERE name = ^"%s^"", playerName[id]);
	SQL_ThreadQuery(sql, "load_honor_handle", queryData, tempId, sizeof(tempId));
}

public load_honor_handle(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if (failState) {
		log_to_file("cod_mod.log", "[CoD Honor] SQL Error: %s (%d)", error, errorNum);

		return;
	}

	new id = tempId[0];

	if (SQL_MoreResults(query)) playerHonor[id] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "honor"));
	else {
		new queryData[128];

		formatex(queryData, charsmax(queryData), "INSERT IGNORE INTO `cod_honor` (`name`) VALUES (^"%s^")", playerName[id]);

		SQL_ThreadQuery(sql, "ignore_handle", queryData);
	}

	set_bit(id, dataLoaded);
}

stock save_honor(id, end = 0)
{
	if (!get_bit(id, dataLoaded)) return;

	new queryData[128];

	formatex(queryData, charsmax(queryData), "UPDATE `cod_honor` SET honor = '%i' WHERE name = ^"%s^"", playerHonor[id], playerName[id]);

	switch (end) {
		case 0: SQL_ThreadQuery(sql, "ignore_handle", queryData);
		case 1: {
			new error[128], errorNum, Handle:query;

			query = SQL_PrepareQuery(connection, queryData);

			if (!SQL_Execute(query)) {
				errorNum = SQL_QueryError(query, error, charsmax(error));

				cod_log_error(PLUGIN, "Non-threaded query failed. Error: %s (%d)", PLUGIN, error, errorNum);
			}

			SQL_FreeHandle(query);
		}
	}

	if (end) rem_bit(id, dataLoaded);
}

public ignore_handle(failState, Handle:query, error[], errorNum, data[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) cod_log_error(PLUGIN, "Could not connect to SQL database. Error: %s (%d)", error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) cod_log_error(PLUGIN, "Threaded query failed. Error: %s (%d)", error, errorNum);
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
	playerHonor[id] = max(0, playerHonor[id] + amount);

	save_honor(id);
}

stock get_user_bonus(id, bonus)
{
	return cod_get_user_vip(id) ? floatround(bonus * cvarVIPMultiplier) : bonus;
}

stock get_loguser_index()
{
	new userLog[96], userName[MAX_NAME];

	read_logargv(0, userLog, charsmax(userLog));
	parse_loguser(userLog, userName, charsmax(userName));

	return get_user_index(userName);
}