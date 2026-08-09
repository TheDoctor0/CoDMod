#include <amxmodx>
#include <sqlx>
#include <cod>

#define PLUGIN "CoD Database"
#define AUTHOR "O'Zone"

#define TASK_LOAD  6120

#define MAX_QUERY  1024
#define MAX_STEAM  34

#define LOG_FILE   "cod_mod.log"

/**
 * Every migration is applied once and then recorded in `cod_migrations`, the
 * same way Laravel does it. Adding a new schema change means appending a name
 * here and a matching case to run_migration() - never editing an old one, since
 * servers that already ran it will not run it again.
 */
new const migrations[][] = {
	"2026_08_08_000001_rename_legacy_tables",
	"2026_08_08_000002_create_cod_players_table",
	"2026_08_08_000003_add_hud_columns_to_cod_players_table",
	"2026_08_08_000004_create_cod_classes_table",
	"2026_08_08_000005_create_cod_stats_table",
	"2026_08_08_000006_create_cod_missions_table",
	"2026_08_08_000007_create_cod_clans_table",
	"2026_08_08_000008_create_cod_clans_members_table",
	"2026_08_08_000009_create_cod_clans_applications_table",
	"2026_08_08_000010_create_cod_clans_wars_table",
	"2026_08_08_000011_import_legacy_players",
	"2026_08_08_000012_import_legacy_classes",
	"2026_08_08_000013_import_legacy_stats",
	"2026_08_08_000014_import_legacy_clans"
};

/**
 * Legacy table name, table it is renamed to, and a column that only exists in
 * the reworked schema. A table is only moved aside when that column is missing,
 * so re-running against an already reworked database is a no-op.
 */
new const legacyTables[][][] = {
	{ "cod_accounts", "cod_legacy_accounts", "player_id" },
	{ "cod_honor", "cod_legacy_honor", "player_id" },
	{ "cod_mod", "cod_legacy_mod", "player_id" },
	{ "cod_stats", "cod_legacy_stats", "player_id" },
	{ "cod_clans", "cod_legacy_clans", "clan_honor" },
	{ "cod_clans_members", "cod_legacy_clans_members", "member_clan_id" },
	{ "cod_clans_applications", "cod_legacy_clans_applications", "player_id" },
	{ "cod_clans_wars", "cod_legacy_clans_wars", "war_attacker_clan_id" }
};

/**
 * Tables wiped by cod_reset_all_data, children before parents.
 */
new const dataTables[][] = {
	"cod_clans_wars",
	"cod_clans_applications",
	"cod_clans_members",
	"cod_clans",
	"cod_missions",
	"cod_stats",
	"cod_classes",
	"cod_players"
};

new const playerColumns[codPlayerField][] = {
	"player_admin",
	"player_honor",
	"player_knife",
	"player_bonus",
	"player_exchange",
	"player_hud_red",
	"player_hud_green",
	"player_hud_blue",
	"player_hud_pos_x",
	"player_hud_pos_y"
};

enum _:forwards { FWD_READY, FWD_PLAYER_LOADED };

enum _:playerInfo { PLAYER_DB_ID, NAME[MAX_NAME], SAFE_NAME[MAX_SAFE_NAME], STEAM_ID[MAX_STEAM], PASSWORD[MAX_PASSWORD * 2] };

new playerData[MAX_PLAYERS + 1][playerInfo], playerFields[MAX_PLAYERS + 1][codPlayerField],
	Handle:sql, Handle:connection, bool:migrated, dataLoaded, codForwards[forwards];

/**
 * The database layer stays free of cod_mod natives so it can boot on its own,
 * before any gameplay plugin is loaded.
 */
stock db_log_error(const text[], any:...)
{
	static message[512];

	vformat(message, charsmax(message), text, 2);

	log_to_file(LOG_FILE, "[%s] %s", PLUGIN, message);
}

stock sql_string(const source[], dest[], length)
{
	copy(dest, length, source);

	replace_all(dest, length, "\\", "\\\\");
	replace_all(dest, length, "\0", "\\0");
	replace_all(dest, length, "\n", "\\n");
	replace_all(dest, length, "\r", "\\r");
	replace_all(dest, length, "\x1a", "\Z");
	replace_all(dest, length, "'", "\'");
	replace_all(dest, length, "`", "\`");
	replace_all(dest, length, "^"", "\^"");
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	// Registering an existing cvar returns the existing pointer, so this only
	// matters when the database plugin runs without the mod core.
	create_cvar("cod_sql_host", "127.0.0.1", FCVAR_SPONLY | FCVAR_PROTECTED);
	create_cvar("cod_sql_user", "user", FCVAR_SPONLY | FCVAR_PROTECTED);
	create_cvar("cod_sql_pass", "password", FCVAR_SPONLY | FCVAR_PROTECTED);
	create_cvar("cod_sql_db", "database", FCVAR_SPONLY | FCVAR_PROTECTED);

	codForwards[FWD_READY] = CreateMultiForward("cod_database_ready", ET_IGNORE);
	codForwards[FWD_PLAYER_LOADED] = CreateMultiForward("cod_player_loaded", ET_IGNORE, FP_CELL, FP_CELL);
}

public plugin_natives()
{
	register_native("cod_db_ready", "_cod_db_ready", 1);
	register_native("cod_db_execute", "_cod_db_execute", 1);
	register_native("cod_db_execute_now", "_cod_db_execute_now", 1);
	register_native("cod_get_user_db_id", "_cod_get_user_db_id", 1);
	register_native("cod_get_user_safe_name", "_cod_get_user_safe_name", 1);
	register_native("cod_get_player_field", "_cod_get_player_field", 1);
	register_native("cod_set_player_field", "_cod_set_player_field", 1);
	register_native("cod_get_player_password", "_cod_get_player_password", 1);
	register_native("cod_set_player_password", "_cod_set_player_password", 1);
	register_native("cod_delete_player", "_cod_delete_player", 1);
}

public plugin_cfg()
	sql_init();

public plugin_end()
{
	if (connection != Empty_Handle) SQL_FreeHandle(connection);
	if (sql != Empty_Handle) SQL_FreeHandle(sql);

	DestroyForward(codForwards[FWD_READY]);
	DestroyForward(codForwards[FWD_PLAYER_LOADED]);
}

public client_putinserver(id)
{
	reset_player(id);

	if (is_user_bot(id) || is_user_hltv(id)) return;

	get_user_name(id, playerData[id][NAME], charsmax(playerData[][NAME]));
	get_user_authid(id, playerData[id][STEAM_ID], charsmax(playerData[][STEAM_ID]));

	sql_string(playerData[id][NAME], playerData[id][SAFE_NAME], charsmax(playerData[][SAFE_NAME]));

	set_task(0.1, "load_player", id + TASK_LOAD);
}

public client_disconnected(id)
{
	remove_task(id + TASK_LOAD);

	reset_player(id);
}

stock reset_player(id)
{
	rem_bit(id, dataLoaded);

	playerData[id][PLAYER_DB_ID] = 0;
	playerData[id][PASSWORD] = "";

	for (new field; field < codPlayerField; field++) playerFields[id][field] = 0;
}

/**
 * Connection and migrations
 */
public sql_init()
{
	new host[64], user[64], pass[64], db[64], error[128], errorNum;

	get_cvar_string("cod_sql_host", host, charsmax(host));
	get_cvar_string("cod_sql_user", user, charsmax(user));
	get_cvar_string("cod_sql_pass", pass, charsmax(pass));
	get_cvar_string("cod_sql_db", db, charsmax(db));

	sql = SQL_MakeDbTuple(host, user, pass, db);

	connection = SQL_Connect(sql, errorNum, error, charsmax(error));

	if (errorNum) {
		db_log_error("SQL Query Error. [%d] %s", errorNum, error);

		SQL_FreeHandle(sql);

		sql = Empty_Handle;
		connection = Empty_Handle;

		set_task(5.0, "sql_init");

		return;
	}

	run_migrations();

	migrated = true;

	new returnValue;

	ExecuteForward(codForwards[FWD_READY], returnValue);

	for (new id = 1; id <= MAX_PLAYERS; id++) {
		if (!is_user_connected(id) || is_user_bot(id) || is_user_hltv(id)) continue;

		load_player(id + TASK_LOAD);
	}
}

stock run_migrations()
{
	new queryData[MAX_QUERY];

	formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_migrations` (`id` INT UNSIGNED NOT NULL AUTO_INCREMENT, ");
	add(queryData, charsmax(queryData), "`migration` VARCHAR(255) NOT NULL, `batch` INT UNSIGNED NOT NULL, `ran_at` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(queryData, charsmax(queryData), "PRIMARY KEY (`id`), UNIQUE KEY `cod_migrations_migration` (`migration`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

	run_query(queryData);

	new batch = fetch_number("SELECT IFNULL(MAX(`batch`), 0) FROM `cod_migrations`;") + 1, applied;

	for (new i; i < sizeof migrations; i++) {
		formatex(queryData, charsmax(queryData), "SELECT COUNT(*) FROM `cod_migrations` WHERE `migration` = '%s';", migrations[i]);

		if (fetch_number(queryData)) continue;

		run_migration(i);

		formatex(queryData, charsmax(queryData), "INSERT INTO `cod_migrations` (`migration`, `batch`, `ran_at`) VALUES ('%s', '%d', '%d');", migrations[i], batch, get_systime());

		run_query(queryData);

		applied++;

		server_print("[%s] Migrated: %s", PLUGIN, migrations[i]);
	}

	if (applied) server_print("[%s] Applied %d migration(s) in batch %d.", PLUGIN, applied, batch);
	else server_print("[%s] Nothing to migrate.", PLUGIN);
}

stock run_migration(migration)
{
	new queryData[MAX_QUERY];

	switch (migration) {
		case 0: {
			for (new i; i < sizeof legacyTables; i++) {
				if (!table_exists(legacyTables[i][0]) || column_exists(legacyTables[i][0], legacyTables[i][2])) continue;
				if (table_exists(legacyTables[i][1])) continue;

				formatex(queryData, charsmax(queryData), "RENAME TABLE `%s` TO `%s`;", legacyTables[i][0], legacyTables[i][1]);

				run_query(queryData);
			}
		}
		case 1: {
			formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_players` (`player_id` INT UNSIGNED NOT NULL AUTO_INCREMENT, ");
			add(queryData, charsmax(queryData), "`player_admin` INT UNSIGNED NOT NULL DEFAULT 0, ");
			formatex(queryData[strlen(queryData)], charsmax(queryData) - strlen(queryData), "`player_steamid` VARCHAR(%i) NOT NULL DEFAULT '', `player_name` VARCHAR(%i) NOT NULL, `player_password` VARCHAR(%i) NOT NULL DEFAULT '', ", MAX_STEAM, MAX_SAFE_NAME, MAX_PASSWORD * 2);
			add(queryData, charsmax(queryData), "`player_honor` INT NOT NULL DEFAULT 0, `player_knife` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`player_bonus` INT UNSIGNED NOT NULL DEFAULT 0, `player_exchange` INT UNSIGNED NOT NULL DEFAULT 1, ");
			add(queryData, charsmax(queryData), "PRIMARY KEY (`player_id`), UNIQUE KEY `cod_players_name` (`player_name`), KEY `cod_players_steamid` (`player_steamid`), ");
			add(queryData, charsmax(queryData), "KEY `cod_players_honor` (`player_honor`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

			run_query(queryData);
		}
		case 2: {
			// The HUD colour and position used to live in a fake `hud` class row.
			add_column("cod_players", "player_hud_red", "INT NOT NULL DEFAULT 0");
			add_column("cod_players", "player_hud_green", "INT NOT NULL DEFAULT 0");
			add_column("cod_players", "player_hud_blue", "INT NOT NULL DEFAULT 0");
			add_column("cod_players", "player_hud_pos_x", "INT NOT NULL DEFAULT 0");
			add_column("cod_players", "player_hud_pos_y", "INT NOT NULL DEFAULT 0");
		}
		case 3: {
			formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_classes` (`class_id` INT UNSIGNED NOT NULL AUTO_INCREMENT, ");
			formatex(queryData[strlen(queryData)], charsmax(queryData) - strlen(queryData), "`player_id` INT UNSIGNED NOT NULL, `class_name` VARCHAR(%i) NOT NULL, ", MAX_NAME);
			add(queryData, charsmax(queryData), "`class_experience` INT UNSIGNED NOT NULL DEFAULT 0, `class_level` INT UNSIGNED NOT NULL DEFAULT 1, ");
			add(queryData, charsmax(queryData), "`class_intelligence` INT UNSIGNED NOT NULL DEFAULT 0, `class_health` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`class_stamina` INT UNSIGNED NOT NULL DEFAULT 0, `class_condition` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`class_strength` INT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`, `class_name`), ");
			add(queryData, charsmax(queryData), "UNIQUE KEY `cod_classes_id` (`class_id`), KEY `cod_classes_experience` (`class_experience`), ");
			add(queryData, charsmax(queryData), "CONSTRAINT `cod_classes_player` FOREIGN KEY (`player_id`) REFERENCES `cod_players` (`player_id`) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

			run_query(queryData);
		}
		case 4: {
			formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_stats` (`player_id` INT UNSIGNED NOT NULL, ");
			add(queryData, charsmax(queryData), "`stats_kills` INT UNSIGNED NOT NULL DEFAULT 0, `stats_time` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`stats_first_visit` INT UNSIGNED NOT NULL DEFAULT 0, `stats_last_visit` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`stats_medals_bronze` INT UNSIGNED NOT NULL DEFAULT 0, `stats_medals_silver` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`stats_medals_gold` INT UNSIGNED NOT NULL DEFAULT 0, `stats_medals` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`stats_best_kills` INT UNSIGNED NOT NULL DEFAULT 0, `stats_best_hs` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`stats_best_deaths` INT UNSIGNED NOT NULL DEFAULT 0, `stats_best_stats` INT NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "PRIMARY KEY (`player_id`), KEY `cod_stats_time` (`stats_time`), KEY `cod_stats_medals` (`stats_medals`), ");
			add(queryData, charsmax(queryData), "KEY `cod_stats_best` (`stats_best_stats`), ");
			add(queryData, charsmax(queryData), "CONSTRAINT `cod_stats_player` FOREIGN KEY (`player_id`) REFERENCES `cod_players` (`player_id`) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

			run_query(queryData);
		}
		case 5: {
			formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_missions` (`player_id` INT UNSIGNED NOT NULL, `class_id` INT UNSIGNED NOT NULL, ");
			add(queryData, charsmax(queryData), "`mission_id` INT NOT NULL DEFAULT 0, `mission_type` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`mission_additional` INT NOT NULL DEFAULT 0, `mission_progress` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`mission_chapter` INT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`, `class_id`), ");
			add(queryData, charsmax(queryData), "KEY `cod_missions_class` (`class_id`), ");
			add(queryData, charsmax(queryData), "CONSTRAINT `cod_missions_player` FOREIGN KEY (`player_id`) REFERENCES `cod_players` (`player_id`) ON DELETE CASCADE, ");
			add(queryData, charsmax(queryData), "CONSTRAINT `cod_missions_class_id` FOREIGN KEY (`class_id`) REFERENCES `cod_classes` (`class_id`) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

			run_query(queryData);
		}
		case 6: {
			formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_clans` (`clan_id` INT UNSIGNED NOT NULL AUTO_INCREMENT, ");
			formatex(queryData[strlen(queryData)], charsmax(queryData) - strlen(queryData), "`clan_name` VARCHAR(%i) NOT NULL, ", MAX_SAFE_NAME);
			add(queryData, charsmax(queryData), "`clan_honor` INT NOT NULL DEFAULT 0, `clan_kills` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`clan_level` INT UNSIGNED NOT NULL DEFAULT 1, `clan_wins` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`clan_health` INT UNSIGNED NOT NULL DEFAULT 0, `clan_gravity` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`clan_damage` INT UNSIGNED NOT NULL DEFAULT 0, `clan_experience` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "PRIMARY KEY (`clan_id`), UNIQUE KEY `cod_clans_name` (`clan_name`), KEY `cod_clans_kills` (`clan_kills`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

			run_query(queryData);
		}
		case 7: {
			formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_clans_members` (`player_id` INT UNSIGNED NOT NULL, ");
			add(queryData, charsmax(queryData), "`member_clan_id` INT UNSIGNED NOT NULL, `member_flag` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`member_donations` INT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (`player_id`), ");
			add(queryData, charsmax(queryData), "KEY `cod_clans_members_clan` (`member_clan_id`), KEY `cod_clans_members_donations` (`member_donations`), ");
			add(queryData, charsmax(queryData), "CONSTRAINT `cod_clans_members_player` FOREIGN KEY (`player_id`) REFERENCES `cod_players` (`player_id`) ON DELETE CASCADE, ");
			add(queryData, charsmax(queryData), "CONSTRAINT `cod_clans_members_clan_id` FOREIGN KEY (`member_clan_id`) REFERENCES `cod_clans` (`clan_id`) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

			run_query(queryData);
		}
		case 8: {
			formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_clans_applications` (`player_id` INT UNSIGNED NOT NULL, ");
			add(queryData, charsmax(queryData), "`clan_id` INT UNSIGNED NOT NULL, `text` VARCHAR(255) NOT NULL DEFAULT '', ");
			add(queryData, charsmax(queryData), "PRIMARY KEY (`player_id`, `clan_id`), KEY `cod_clans_applications_clan` (`clan_id`), ");
			add(queryData, charsmax(queryData), "CONSTRAINT `cod_clans_applications_player` FOREIGN KEY (`player_id`) REFERENCES `cod_players` (`player_id`) ON DELETE CASCADE, ");
			add(queryData, charsmax(queryData), "CONSTRAINT `cod_clans_applications_clan_id` FOREIGN KEY (`clan_id`) REFERENCES `cod_clans` (`clan_id`) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

			run_query(queryData);
		}
		case 9: {
			formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_clans_wars` (`war_id` INT UNSIGNED NOT NULL AUTO_INCREMENT, ");
			add(queryData, charsmax(queryData), "`war_attacker_clan_id` INT UNSIGNED NOT NULL, `war_defender_clan_id` INT UNSIGNED NOT NULL, ");
			add(queryData, charsmax(queryData), "`war_attacker_progress` INT UNSIGNED NOT NULL DEFAULT 0, `war_defender_progress` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`war_duration` INT UNSIGNED NOT NULL DEFAULT 0, `war_reward` INT UNSIGNED NOT NULL DEFAULT 0, ");
			add(queryData, charsmax(queryData), "`war_started` INT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY (`war_id`), ");
			add(queryData, charsmax(queryData), "KEY `cod_clans_wars_attacker` (`war_attacker_clan_id`), KEY `cod_clans_wars_defender` (`war_defender_clan_id`), ");
			add(queryData, charsmax(queryData), "CONSTRAINT `cod_clans_wars_attacker_id` FOREIGN KEY (`war_attacker_clan_id`) REFERENCES `cod_clans` (`clan_id`) ON DELETE CASCADE, ");
			add(queryData, charsmax(queryData), "CONSTRAINT `cod_clans_wars_defender_id` FOREIGN KEY (`war_defender_clan_id`) REFERENCES `cod_clans` (`clan_id`) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

			run_query(queryData);
		}
		case 10: {
			import_players("cod_legacy_accounts");
			import_players("cod_legacy_honor");
			import_players("cod_legacy_stats");
			import_players("cod_legacy_clans_members");

			if (table_exists("cod_legacy_mod")) {
				run_query("INSERT IGNORE INTO `cod_players` (`player_name`) SELECT DISTINCT `name` FROM `cod_legacy_mod` WHERE `class` <> 'hud' AND `name` <> '';");

				run_query("UPDATE `cod_players` p JOIN `cod_legacy_mod` m ON m.`name` = p.`player_name` AND m.`class` = 'hud' \
					SET p.`player_hud_red` = m.`level`, p.`player_hud_green` = m.`exp`, p.`player_hud_blue` = m.`intelligence`, \
					p.`player_hud_pos_x` = m.`health`, p.`player_hud_pos_y` = m.`stamina`;");
			}

			if (table_exists("cod_legacy_accounts")) {
				run_query("UPDATE `cod_players` p JOIN `cod_legacy_accounts` a ON a.`name` = p.`player_name` SET p.`player_password` = a.`pass`;");
			}

			if (table_exists("cod_legacy_honor")) {
				run_query("UPDATE `cod_players` p JOIN `cod_legacy_honor` h ON h.`name` = p.`player_name` SET p.`player_honor` = h.`honor`;");
			}

			if (table_exists("cod_legacy_stats")) {
				run_query("UPDATE `cod_players` p JOIN `cod_legacy_stats` s ON s.`name` = p.`player_name` SET p.`player_admin` = s.`admin`;");
			}
		}
		case 11: {
			if (!table_exists("cod_legacy_mod")) return;

			run_query("INSERT IGNORE INTO `cod_classes` (`player_id`, `class_name`, `class_experience`, `class_level`, `class_intelligence`, \
				`class_health`, `class_stamina`, `class_condition`, `class_strength`) \
				SELECT p.`player_id`, m.`class`, m.`exp`, m.`level`, m.`intelligence`, m.`health`, m.`stamina`, m.`condition`, m.`strength` \
				FROM `cod_legacy_mod` m JOIN `cod_players` p ON p.`player_name` = m.`name` WHERE m.`class` <> 'hud';");
		}
		case 12: {
			if (!table_exists("cod_legacy_stats")) return;

			run_query("INSERT IGNORE INTO `cod_stats` (`player_id`, `stats_kills`, `stats_time`, `stats_first_visit`, `stats_last_visit`, \
				`stats_medals_bronze`, `stats_medals_silver`, `stats_medals_gold`, `stats_medals`, `stats_best_kills`, `stats_best_hs`, \
				`stats_best_deaths`, `stats_best_stats`) \
				SELECT p.`player_id`, s.`kills`, s.`time`, s.`firstvisit`, s.`lastvisit`, s.`bronze`, s.`silver`, s.`gold`, s.`medals`, \
				s.`bestkills`, s.`besths`, s.`bestdeaths`, s.`beststats` \
				FROM `cod_legacy_stats` s JOIN `cod_players` p ON p.`player_name` = s.`name`;");
		}
		case 13: {
			if (table_exists("cod_legacy_clans")) {
				run_query("INSERT IGNORE INTO `cod_clans` (`clan_id`, `clan_name`, `clan_honor`, `clan_kills`, `clan_level`, `clan_wins`, \
					`clan_health`, `clan_gravity`, `clan_damage`, `clan_experience`) \
					SELECT c.`id`, c.`name`, c.`honor`, c.`kills`, GREATEST(c.`level`, 1), c.`wins`, c.`health`, c.`gravity`, c.`damage`, c.`exp` \
					FROM `cod_legacy_clans` c WHERE c.`name` <> '';");
			}

			if (table_exists("cod_legacy_clans_members")) {
				run_query("INSERT IGNORE INTO `cod_clans_members` (`player_id`, `member_clan_id`, `member_flag`, `member_donations`) \
					SELECT p.`player_id`, m.`clan`, m.`flag`, m.`honor` FROM `cod_legacy_clans_members` m \
					JOIN `cod_players` p ON p.`player_name` = m.`name` JOIN `cod_clans` c ON c.`clan_id` = m.`clan`;");
			}

			if (table_exists("cod_legacy_clans_applications")) {
				run_query("INSERT IGNORE INTO `cod_clans_applications` (`player_id`, `clan_id`) \
					SELECT p.`player_id`, a.`clan` FROM `cod_legacy_clans_applications` a \
					JOIN `cod_players` p ON p.`player_name` = a.`name` JOIN `cod_clans` c ON c.`clan_id` = a.`clan`;");
			}

			if (table_exists("cod_legacy_clans_wars")) {
				run_query("INSERT IGNORE INTO `cod_clans_wars` (`war_id`, `war_attacker_clan_id`, `war_defender_clan_id`, \
					`war_attacker_progress`, `war_defender_progress`, `war_duration`, `war_reward`, `war_started`) \
					SELECT w.`id`, w.`clan`, w.`clan2`, w.`progress`, w.`progress2`, w.`duration`, w.`reward`, w.`started` \
					FROM `cod_legacy_clans_wars` w JOIN `cod_clans` a ON a.`clan_id` = w.`clan` JOIN `cod_clans` d ON d.`clan_id` = w.`clan2`;");
			}
		}
	}
}

stock import_players(const table[])
{
	if (!table_exists(table)) return;

	new queryData[MAX_QUERY];

	formatex(queryData, charsmax(queryData), "INSERT IGNORE INTO `cod_players` (`player_name`) SELECT DISTINCT `name` FROM `%s` WHERE `name` <> '';", table);

	run_query(queryData);
}

stock add_column(const table[], const column[], const definition[])
{
	if (column_exists(table, column)) return;

	new queryData[MAX_QUERY];

	formatex(queryData, charsmax(queryData), "ALTER TABLE `%s` ADD COLUMN `%s` %s;", table, column, definition);

	run_query(queryData);
}

stock bool:table_exists(const table[])
{
	new queryData[MAX_QUERY];

	formatex(queryData, charsmax(queryData), "SHOW TABLES LIKE '%s';", table);

	return has_results(queryData);
}

stock bool:column_exists(const table[], const column[])
{
	if (!table_exists(table)) return false;

	new queryData[MAX_QUERY];

	formatex(queryData, charsmax(queryData), "SHOW COLUMNS FROM `%s` LIKE '%s';", table, column);

	return has_results(queryData);
}

stock bool:has_results(const query[])
{
	new Handle:handle = SQL_PrepareQuery(connection, query), bool:found;

	if (!SQL_Execute(handle)) log_query_error(handle, query);
	else found = SQL_MoreResults(handle) ? true : false;

	SQL_FreeHandle(handle);

	return found;
}

stock fetch_number(const query[])
{
	new Handle:handle = SQL_PrepareQuery(connection, query), result;

	if (!SQL_Execute(handle)) log_query_error(handle, query);
	else if (SQL_MoreResults(handle)) result = SQL_ReadResult(handle, 0);

	SQL_FreeHandle(handle);

	return result;
}

stock run_query(const query[])
{
	new Handle:handle = SQL_PrepareQuery(connection, query);

	if (!SQL_Execute(handle)) log_query_error(handle, query);

	SQL_FreeHandle(handle);
}

stock log_query_error(Handle:handle, const query[])
{
	new error[192], errorNum = SQL_QueryError(handle, error, charsmax(error));

	db_log_error("Query failed. Error: [%d] %s | Query: %s", errorNum, error, query);
}

/**
 * Player rows
 */
public load_player(id)
{
	id -= TASK_LOAD;

	if (!migrated) return;
	if (!is_user_connected(id) || get_bit(id, dataLoaded)) return;

	new queryData[MAX_QUERY], tempId[1];

	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "INSERT IGNORE INTO `cod_players` (`player_name`, `player_steamid`) VALUES (^"%s^", '%s');", playerData[id][SAFE_NAME], playerData[id][STEAM_ID]);

	SQL_ThreadQuery(sql, "ignore_handle", queryData);

	formatex(queryData, charsmax(queryData), "SELECT * FROM `cod_players` WHERE `player_name` = ^"%s^";", playerData[id][SAFE_NAME]);

	SQL_ThreadQuery(sql, "load_player_handle", queryData, tempId, sizeof tempId);
}

public load_player_handle(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if (failState) {
		log_thread_error(failState, error, errorNum);

		return;
	}

	new id = tempId[0];

	if (!is_user_connected(id)) return;

	if (!SQL_MoreResults(query)) {
		// The INSERT IGNORE is queued before this SELECT, so a miss means the
		// row could not be created at all - retry rather than run without an id.
		set_task(1.0, "load_player", id + TASK_LOAD);

		return;
	}

	playerData[id][PLAYER_DB_ID] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "player_id"));

	SQL_ReadResult(query, SQL_FieldNameToNum(query, "player_password"), playerData[id][PASSWORD], charsmax(playerData[][PASSWORD]));

	for (new field; field < codPlayerField; field++) {
		playerFields[id][field] = SQL_ReadResult(query, SQL_FieldNameToNum(query, playerColumns[field]));
	}

	set_bit(id, dataLoaded);

	update_player(id, "player_steamid", playerData[id][STEAM_ID]);

	new returnValue;

	ExecuteForward(codForwards[FWD_PLAYER_LOADED], returnValue, id, playerData[id][PLAYER_DB_ID]);
}

stock update_player(id, const column[], const value[], now = 0)
{
	if (!get_bit(id, dataLoaded)) return;

	new queryData[MAX_QUERY];

	formatex(queryData, charsmax(queryData), "UPDATE `cod_players` SET `%s` = '%s' WHERE `player_id` = '%d';", column, value, playerData[id][PLAYER_DB_ID]);

	if (now) run_query(queryData);
	else SQL_ThreadQuery(sql, "ignore_handle", queryData);
}

public ignore_handle(failState, Handle:query, error[], errorNum, data[], dataSize)
{
	if (failState) log_thread_error(failState, error, errorNum);

	return PLUGIN_CONTINUE;
}

stock log_thread_error(failState, const error[], errorNum)
{
	if (failState == TQUERY_CONNECT_FAILED) db_log_error("Could not connect to SQL database. Error: %s (%d)", error, errorNum);
	else if (failState == TQUERY_QUERY_FAILED) db_log_error("Threaded query failed. Error: %s (%d)", error, errorNum);
}

/**
 * Data resets
 */
public cod_reset_stats_data()
{
	if (!migrated) return;

	run_query("DELETE FROM `cod_stats`;");
}

public cod_reset_all_data()
{
	if (!migrated) return;

	for (new i; i < sizeof dataTables; i++) {
		new queryData[MAX_QUERY];

		formatex(queryData, charsmax(queryData), "DELETE FROM `%s`;", dataTables[i]);

		run_query(queryData);
	}

	for (new id = 1; id <= MAX_PLAYERS; id++) reset_player(id);

	for (new id = 1; id <= MAX_PLAYERS; id++) {
		if (!is_user_connected(id) || is_user_bot(id) || is_user_hltv(id)) continue;

		load_player(id + TASK_LOAD);
	}
}

/**
 * Natives
 */
public _cod_db_ready()
	return migrated ? 1 : 0;

public _cod_db_execute(const query[])
{
	param_convert(1);

	if (!migrated) {
		db_log_error("Query run before the database was ready: %s", query);

		return;
	}

	SQL_ThreadQuery(sql, "ignore_handle", query);
}

public _cod_db_execute_now(const query[])
{
	param_convert(1);

	if (!migrated) {
		db_log_error("Query run before the database was ready: %s", query);

		return;
	}

	run_query(query);
}

public _cod_get_user_db_id(id)
{
	if (!is_user_valid(id) || !get_bit(id, dataLoaded)) return 0;

	return playerData[id][PLAYER_DB_ID];
}

public _cod_get_user_safe_name(id, data[], length)
{
	param_convert(2);

	if (!is_user_valid(id)) {
		data[0] = 0;

		return;
	}

	copy(data, length, playerData[id][SAFE_NAME]);
}

public _cod_get_player_field(id, field)
{
	if (!is_user_valid(id) || !(0 <= field < codPlayerField) || !get_bit(id, dataLoaded)) return 0;

	return playerFields[id][field];
}

public _cod_set_player_field(id, field, value, now)
{
	if (!is_user_valid(id) || !(0 <= field < codPlayerField)) return;

	playerFields[id][field] = value;

	if (!get_bit(id, dataLoaded)) return;

	new queryData[MAX_QUERY];

	formatex(queryData, charsmax(queryData), "UPDATE `cod_players` SET `%s` = '%d' WHERE `player_id` = '%d';", playerColumns[field], value, playerData[id][PLAYER_DB_ID]);

	if (now) run_query(queryData);
	else SQL_ThreadQuery(sql, "ignore_handle", queryData);
}

public _cod_get_player_password(id, data[], length)
{
	param_convert(2);

	if (!is_user_valid(id)) {
		data[0] = 0;

		return;
	}

	copy(data, length, playerData[id][PASSWORD]);
}

public _cod_set_player_password(id, const password[])
{
	param_convert(2);

	if (!is_user_valid(id)) return;

	copy(playerData[id][PASSWORD], charsmax(playerData[][PASSWORD]), password);

	new safePassword[MAX_PASSWORD * 2];

	sql_string(password, safePassword, charsmax(safePassword));

	update_player(id, "player_password", safePassword);
}

public _cod_delete_player(id)
{
	if (!is_user_valid(id) || !get_bit(id, dataLoaded)) return;

	new queryData[MAX_QUERY];

	formatex(queryData, charsmax(queryData), "DELETE FROM `cod_players` WHERE `player_id` = '%d';", playerData[id][PLAYER_DB_ID]);

	run_query(queryData);

	reset_player(id);
}
