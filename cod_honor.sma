#include <amxmodx>
#include <sqlx>
#include <fakemeta>
#include <cod>

#define PLUGIN	"CoD Honor System"
#define AUTHOR	"O'Zone"
#define VERSION	"1.3.1"

#define set_user_money(%1,%2)	set_pdata_int(%1, OFFSET_CSMONEY, %2, OFFSET_LINUX)

#define MAX_MONEY		99999

#define HONOR_LIMIT		2147483647

#define OFFSET_CSMONEY	115
#define OFFSET_LINUX	5
#define	PDATA_SAFE		2

#define TASK_LOAD 		4721
#define TASK_UPDATE 	9501

enum _:playerInfo { NAME[MAX_SAFE_NAME], HONOR, HONOR_GAINED };

new cvarMinPlayers, cvarKill, cvarKillHS, cvarKillFirst, cvarWinRound, cvarBombPlanted,
	cvarBombDefused,cvarRescueHostage, cvarKillHostage, cvarVIPBonus;

new playerData[MAX_PLAYERS + 1][playerInfo], Handle:sql, Handle:connection,
	bool:sqlConnected, bool:firstKill, dataLoaded, msgMoney;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	bind_pcvar_num(create_cvar("cod_honor_min_players", "4"), cvarMinPlayers);
	bind_pcvar_num(create_cvar("cod_honor_kill", "2"), cvarKill);
	bind_pcvar_num(create_cvar("cod_honor_kill_hs", "1"), cvarKillHS);
	bind_pcvar_num(create_cvar("cod_honor_kill_first", "1"), cvarKillFirst);
	bind_pcvar_num(create_cvar("cod_honor_win_round", "1"), cvarWinRound);
	bind_pcvar_num(create_cvar("cod_honor_bomb_planted", "5"), cvarBombPlanted);
	bind_pcvar_num(create_cvar("cod_honor_bomb_defused", "5"), cvarBombDefused);
	bind_pcvar_num(create_cvar("cod_honor_rescue_hostage", "5"), cvarRescueHostage);
	bind_pcvar_num(create_cvar("cod_honor_kill_hostage", "5"), cvarKillHostage);
	bind_pcvar_num(create_cvar("cod_honor_vip_bonus", "50"), cvarVIPBonus);

	register_event("Money", "money_update", "b");

	register_message(get_user_msgid("Money"), "message_money");

	msgMoney = get_user_msgid("Money");
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
	if (sql != Empty_Handle) SQL_FreeHandle(sql);
	if (connection != Empty_Handle) SQL_FreeHandle(connection);
}

public cod_reset_data()
	clear_database();

public cod_reset_all_data()
	clear_database();

public clear_database()
{
	for (new i = 1; i <= MAX_PLAYERS; i++) {
		playerData[i][HONOR] = 0;
		playerData[i][HONOR_GAINED] = 0;

		rem_bit(i, dataLoaded);
	}

	sqlConnected = false;

	new tempData[32];

	formatex(tempData, charsmax(tempData), "DROP TABLE `cod_honor`;");

	SQL_ThreadQuery(sql, "ignore_handle", tempData);
}

public client_putinserver(id)
{
	playerData[id][HONOR] = 0;
	playerData[id][HONOR_GAINED] = 0;

	rem_bit(id, dataLoaded);

	if (is_user_bot(id) || is_user_hltv(id)) return;

	get_user_name(id, playerData[id][NAME], charsmax(playerData[][NAME]));

	cod_sql_string(playerData[id][NAME], playerData[id][NAME], charsmax(playerData[][NAME]));

	set_task(0.1, "load_honor", id + TASK_LOAD);
}

public client_disconnected(id)
{
	remove_task(id + TASK_LOAD);
	remove_task(id + TASK_UPDATE);
}

public cod_new_round()
	firstKill = false;

public cod_spawned(id, respawn)
	update_hud(id);

public cod_killed(killer, victim, weaponId, hitPlace)
{
	if (get_playersnum() < cvarMinPlayers) return;

	if (!firstKill && cvarKillFirst) {
		firstKill = true;

		playerData[killer][HONOR_GAINED] = get_user_bonus(killer, cvarKillFirst);
	}

	if (cvarKill) playerData[killer][HONOR_GAINED] += get_user_bonus(killer, cvarKill);

	if (hitPlace == HIT_HEAD && cvarKillHS) playerData[killer][HONOR_GAINED] += get_user_bonus(killer, cvarKillHS);

	save_honor(killer);
}

public cod_win_round(team)
{
	if (get_playersnum() < cvarMinPlayers || !cvarWinRound) return;

	for (new id = 1; id < MAX_PLAYERS; id++) {
		if (!cod_get_user_class(id) || get_user_team(id) != team) continue;

		playerData[id][HONOR_GAINED] = get_user_bonus(id, cvarWinRound);

		save_honor(id);
	}
}

public cod_bomb_planted(id)
{
	if (get_playersnum() < cvarMinPlayers || !cod_get_user_class(id) || !cvarBombPlanted) {
		delayed_hud_update(id, 0);

		return;
	}

	playerData[id][HONOR_GAINED] = get_user_bonus(id, cvarBombPlanted);

	save_honor(id);
}

public cod_bomb_defused(id)
{
	if (get_playersnum() < cvarMinPlayers || !cod_get_user_class(id) || !cvarBombDefused) {
		delayed_hud_update(id, 0);

		return;
	}

	playerData[id][HONOR_GAINED] = get_user_bonus(id, cvarBombDefused);

	save_honor(id);
}

public cod_hostage_rescued(id)
{
	if (get_playersnum() < cvarMinPlayers || !cod_get_user_class(id) || !cvarRescueHostage) {
		delayed_hud_update(id, 0);

		return;
	}

	playerData[id][HONOR_GAINED] = get_user_bonus(id, cvarRescueHostage);

	save_honor(id);
}

public cod_hostage_killed(id)
{
	if (get_playersnum() < cvarMinPlayers || !cod_get_user_class(id) || !cvarKillHostage) {
		delayed_hud_update(id, 0);

		return;
	}

	playerData[id][HONOR_GAINED] = max(-playerData[id][HONOR], cod_get_user_vip(id) ? floatround(cvarKillHostage -  cvarKillHostage * (cvarVIPBonus / 100.0)) : cvarKillHostage);

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
		cod_log_error(PLUGIN, "SQL Query Error. [%d] %s", errorNum, error);

		sql = Empty_Handle;

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
	id -= TASK_LOAD;

	if (!sqlConnected) {
		set_task(1.0, "load_honor", id + TASK_LOAD);

		return;
	}

	new queryData[128], tempId[1];

	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT * FROM `cod_honor` WHERE name = ^"%s^";", playerData[id][NAME]);
	SQL_ThreadQuery(sql, "load_honor_handle", queryData, tempId, sizeof(tempId));
}

public load_honor_handle(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) cod_log_error(PLUGIN, "Could not connect to SQL database. Error: %s (%d)", error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) cod_log_error(PLUGIN, "Threaded query failed. Error: %s (%d)", error, errorNum);

		return;
	}

	new id = tempId[0];

	if (SQL_MoreResults(query)) {
		playerData[id][HONOR] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "honor"));

		if (playerData[id][HONOR] > HONOR_LIMIT) {
			playerData[id][HONOR] = HONOR_LIMIT;
		}
	} else {
		new queryData[128];

		formatex(queryData, charsmax(queryData), "INSERT IGNORE INTO `cod_honor` (`name`) VALUES (^"%s^");", playerData[id][NAME]);

		SQL_ThreadQuery(sql, "ignore_handle", queryData);
	}

	update_hud(id, playerData[id][HONOR]);

	set_bit(id, dataLoaded);
}

stock save_honor(id, end = 0)
{
	if (!get_bit(id, dataLoaded)) return;

	new queryData[128];

	delayed_hud_update(id, playerData[id][HONOR_GAINED]);

	if (playerData[id][HONOR_GAINED] && (playerData[id][HONOR] + playerData[id][HONOR_GAINED] < 0 || playerData[id][HONOR] + playerData[id][HONOR_GAINED] > HONOR_LIMIT)) {
		playerData[id][HONOR] = HONOR_LIMIT;
	} else {
		playerData[id][HONOR] += playerData[id][HONOR_GAINED];
	}

	playerData[id][HONOR_GAINED] = 0;

	formatex(queryData, charsmax(queryData), "UPDATE `cod_honor` SET honor = '%i' WHERE name = ^"%s^";", playerData[id][HONOR], playerData[id][NAME]);

	switch (end) {
		case 0: SQL_ThreadQuery(sql, "ignore_handle", queryData);
		case 1: {
			new error[128], errorNum, Handle:query;

			query = SQL_PrepareQuery(connection, queryData);

			if (!SQL_Execute(query)) {
				errorNum = SQL_QueryError(query, error, charsmax(error));

				cod_log_error(PLUGIN, "Non-threaded query failed. Error: [%d] %s", errorNum, error);
			}

			SQL_FreeHandle(query);
		}
	}

	if (end) rem_bit(id, dataLoaded);
}

public money_update(id)
	update_hud(id);

public message_money(msgId, msgDest, msgEnt)
{
	if (!is_user_connected(msgEnt)) return;

	set_msg_arg_int(1, get_msg_argtype(1), min(playerData[msgEnt][HONOR], MAX_MONEY));

	update_hud(msgEnt);
}

public delayed_hud_update(id, gained)
{
	new data[2];

	data[0] = id;
	data[1] = gained;

	if (task_exists(id + TASK_UPDATE)) remove_task(id + TASK_UPDATE);

	set_task(0.1, "update_hud_task", id + TASK_UPDATE, data, sizeof(data));
}

public update_hud_task(data[])
	update_hud(data[0], data[1]);

stock update_hud(id, gained = 0)
{
	if (!is_user_connected(id) || pev_valid(id) != PDATA_SAFE) return;

	new tempHonor = min(playerData[id][HONOR], MAX_MONEY);

	set_user_money(id, tempHonor);

	message_begin(MSG_ONE, msgMoney, _, id);
	write_long(tempHonor - gained);
	write_byte(0);
	message_end();

	message_begin(MSG_ONE, msgMoney, _, id);
	write_long(tempHonor);
	write_byte(1);
	message_end();
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
	return playerData[id][HONOR];

public _cod_set_user_honor(id, amount, bonus)
{
	playerData[id][HONOR] = min(max(0, bonus ? get_user_bonus(id, amount) : amount), HONOR_LIMIT);

	save_honor(id);
}

public _cod_add_user_honor(id, amount, bonus)
{
	playerData[id][HONOR_GAINED] = max(-playerData[id][HONOR], bonus ? get_user_bonus(id, amount) : amount);

	save_honor(id);
}

stock get_user_bonus(id, bonus)
{
	return cod_get_user_vip(id) ? floatround(bonus + bonus * (cvarVIPBonus / 100.0)) : bonus;
}