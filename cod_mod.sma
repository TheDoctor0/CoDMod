#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <fun>
#include <xs>
#include <csx>
#include <sqlx>
#include <cod>

#define PLUGIN "CoD Mod"
#define VERSION "1.5.1"
#define AUTHOR "O'Zone"

#pragma dynamic              65536

#define TASK_SHOW_INFO       3357
#define TASK_SHOW_AD         4268
#define TASK_SHOW_HELP       5456
#define TASK_SPEED_LIMIT     6144
#define TASK_SET_SPEED       7532
#define TASK_END_KILL_STREAK 8779
#define TASK_RENDER          9611
#define TASK_GLOW            10932
#define TASK_DAMAGE          11342
#define TASK_BLOCK           12731
#define TASK_BLOCK_INFO      13935
#define TASK_RESPAWN         14294
#define TASK_DEATH           15907

#define LOG_FILE             "cod_mod.log"

#define RESET_FLAG			 ADMIN_ADMIN

new const commandClass[][] = { "klasa", "say /klasa", "say_team /klasa", "say /class", "say_team /class", "say /k", "say_team /k", "say /c", "say_team /c" };
new const commandClasses[][] = { "klasy", "say /klasy", "say_team /klasy", "say /classes", "say_team /classes", "say /ky", "say_team /ky", "say /cs", "say_team /cs" };
new const commandItem[][] = { "item", "say /item", "say_team /item", "say /przedmiot", "say_team /przedmiot", "say /perk", "say_team /perk", "say /i", "say_team /i", "say /p", "say_team /p" };
new const commandItems[][] = { "itemy", "say /itemy", "say_team /itemy", "say /items", "say_team /items", "say /przedmioty", "say_team /przedmioty", "say /perks", "say_team /perks", "say /perki", "say_team /perki", "say /perks", "say_team /perks", "say /iy", "say_team /iy", "say /py", "say_team /py" };
new const commandDrop[][] = { "wyrzuc", "say /wyrzuc", "say_team /wyrzuc", "say /drop", "say_team /drop", "say /w", "say_team /w", "say /d", "say_team /d" };
new const commandReset[][] = { "resetuj", "say /resetuj", "say_team /resetuj", "say /r", "say_team /r" };
new const commandPoints[][] = { "punkty", "say /statystyki", "say_team /statystyki", "say /punkty", "say_team /punkty", "say /s", "say_team /s", "say /p", "say_team /p" };
new const commandHud[][] = { "hud", "say /hud", "say_team /hud", "say /zmienhud", "say_team /zmienhud", "say /change_hud", "say_team /change_hud" };
new const commandBinds[][] = { "bindy", "binny", "say /bind", "say_team /bind", "say /bindy", "say_team /bindy", "say /binds", "say_team /binds" };
new const commandTop[][] = { "top", "say /toplvl", "say_team /toplvl", "say /toplevel", "say_team /toplevel", "say /toppoziom", "say_team /toppoziom", "say /ltop15", "say_team /ltop15", "say /ptop15", "say_team /ptop15" };
new const commandBlock[][] = { "fullupdate", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "rebuy", "autobuy", "hegren", "sgren", "flash", "-rocket", "-mine", "-dynamite", "-medkit", "-poison", "-teleport", "-class", "-item" };

new const weapons[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
		"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil",
		"weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1",
		"weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90" };

new const excludedWeapons = (1<<CSW_HEGRENADE) | (1<<CSW_SMOKEGRENADE) | (1<<CSW_FLASHBANG) | (1<<CSW_KNIFE) | (1<<CSW_C4);
new const allowedWeapons = (1<<CSW_KNIFE) | (1<<CSW_C4);

new const maxClipAmmo[] = { -1, 13, -1, 10, 1, 7, 1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 };
new const maxBpAmmo[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 32, 90, 120, 90, 1, 35, 90, 90, -1, 100 }

new const pointsDistribution[] = { 1, 3, 5, 10, 25, FULL };

enum _:models { MODEL_ROCKET, MODEL_MINE, MODEL_DYNAMITE, MODEL_MEDKIT, MODEL_POISON };

new const codModels[models][] = {
	"models/CoDMod/rocket.mdl",
	"models/CoDMod/mine.mdl",
	"models/CoDMod/dynamite.mdl",
	"models/CoDMod/medkit.mdl",
	"models/CoDMod/poison.mdl"
};

enum _:sprites { SPRITE_EXPLOSION, SPRITE_WHITE, SPRITE_THUNDER, SPRITE_FIRE, SPRITE_SMOKE };

new const codSprites[sprites][] = {
	"sprites/dexplo.spr",
	"sprites/white.spr",
	"sprites/lgtning.spr",
	"sprites/fire.spr",
	"sprites/steam1.spr",
};

new codSprite[sizeof codSprites];

enum _:save { NORMAL, FINAL, MAP_END };

enum _:repeatingData { ATTACKER, VICTIM, DAMAGE, COUNTER, FLAGS };

enum _:weaponSlots { PRIMARY = 1, SECONDARY, KNIFE, GRENADES, C4 };

enum _:forwards { CLASS_CHANGED, ITEM_CHANGED, RENDER_CHANGED, GRAVITY_CHANGED, SPEED_CHANGED, DAMAGE_PRE, DAMAGE_POST,
	DAMAGE_INFLICT, WEAPON_DEPLOY, CUR_WEAPON, KILLED, SPAWNED, CMD_START, BOMB_DROPPED, BOMB_PICKED, BOMB_PLANTING,
	BOMB_PLANTED, BOMB_DEFUSING, BOMB_DEFUSED, BOMB_EXPLODED, HOSTAGE_KILLED, HOSTAGE_RESCUED, HOSTAGES_RESCUED,
	TEAM_ASSIGN, NEW_ROUND, START_ROUND, RESTART_ROUND, END_ROUND, WIN_ROUND, END_MAP, MEDKIT_HEAL, POISON_INFECT,
	ROCKET_EXPLODE, MINE_EXPLODE, DYNAMITE_EXPLODE, THUNDER_REACH, TELEPORT_USED, RESET_DATA, RESET_STATS_DATA,
	RESET_ALL_DATA, FLAGS_CHANGED };

enum _:itemInfo { ITEM_NAME[MAX_NAME], ITEM_DESC[MAX_DESC], ITEM_PLUGIN, ITEM_RANDOM_MIN, ITEM_RANDOM_MAX, ITEM_FLAG, ITEM_GIVE, ITEM_DROP,
	ITEM_SPAWNED, ITEM_KILL, ITEM_KILLED, ITEM_SKILL_USED, ITEM_UPGRADE, ITEM_VALUE, ITEM_CHECK, ITEM_DAMAGE_ATTACKER, ITEM_DAMAGE_VICTIM };

enum _:classInfo { CLASS_NAME[MAX_NAME], CLASS_DESC[MAX_DESC], CLASS_FRACTION[MAX_NAME], CLASS_HEAL, CLASS_INT, CLASS_STR,
	CLASS_COND, CLASS_STAM, CLASS_WEAPONS, CLASS_PROMOTION, CLASS_DEGREE, CLASS_LEVEL, CLASS_FLAG, CLASS_PLUGIN, CLASS_ENABLED,
	CLASS_DISABLED, CLASS_SPAWNED, CLASS_KILL, CLASS_KILLED, CLASS_SKILL_USED, CLASS_DAMAGE_VICTIM, CLASS_DAMAGE_ATTACKER };

enum _:playerClassInfo { PCLASS_LEVEL, PCLASS_EXP, PCLASS_HEAL, PCLASS_INT, PCLASS_STAM, PCLASS_STR, PCLASS_COND, PCLASS_POINTS };

enum _:renderInfo { RENDER_TYPE, RENDER_VALUE, RENDER_STATUS, RENDER_WEAPON };

enum _:playerInfo { PLAYER_CLASS, PLAYER_NEW_CLASS, PLAYER_PROMOTION_ID, PLAYER_PROMOTION, PLAYER_LEVEL, PLAYER_GAINED_LEVEL, PLAYER_EXP, PLAYER_GAINED_EXP, PLAYER_HEAL, PLAYER_INT, PLAYER_STAM,
	PLAYER_STR, PLAYER_COND, PLAYER_POINTS, PLAYER_POINTS_SPEED, PLAYER_EXTRA_HEAL, PLAYER_EXTRA_INT, PLAYER_EXTRA_STAM, PLAYER_EXTRA_STR, PLAYER_EXTRA_COND, PLAYER_EXTRA_WEAPONS, PLAYER_WEAPON,
	PLAYER_WEAPONS, PLAYER_STATUS, PLAYER_ITEM, PLAYER_ITEM_DURA, PLAYER_DYNAMITE, PLAYER_LEFT_JUMPS, PLAYER_SPAWNED, PLAYER_DAMAGE_TAKEN, PLAYER_DAMAGE_GIVEN, PLAYER_RENDER, PLAYER_KS,
	PLAYER_TIME_KS, PLAYER_ALIVE, PLAYER_FLAGS, Float:PLAYER_LAST_ROCKET, Float:PLAYER_LAST_MINE, Float:PLAYER_LAST_DYNAMITE, Float:PLAYER_LAST_MEDKIT, Float:PLAYER_LAST_POISON, Float:PLAYER_LAST_THUNDER,
	Float:PLAYER_LAST_TELEPORT, PLAYER_HUD_RED, PLAYER_HUD_GREEN, PLAYER_HUD_BLUE, PLAYER_HUD_POSX, PLAYER_HUD_POSY, SKILL_USE, HIT_PLACE[MAX_PLAYERS + 1], PLAYER_ROCKETS[ALL + 1], PLAYER_MINES[ALL + 1], PLAYER_DYNAMITES[ALL + 1],
	PLAYER_MEDKITS[ALL + 1], PLAYER_POISONS[ALL + 1], PLAYER_THUNDERS[ALL + 1], PLAYER_TELEPORTS[ALL + 1], PLAYER_JUMPS[ALL + 1], PLAYER_BUNNYHOP[ALL + 1], PLAYER_FOOTSTEPS[ALL + 1], PLAYER_MODEL[ALL + 1],
	PLAYER_RESISTANCE[ALL + 1], PLAYER_GODMODE[ALL + 1], PLAYER_NOCLIP[ALL + 1], PLAYER_UNLIMITED_AMMO[ALL + 1], PLAYER_UNLIMITED_AMMO_WEAPONS[ALL + 1], PLAYER_ELIMINATOR[ALL + 1], PLAYER_ELIMINATOR_WEAPONS[ALL + 1],
	PLAYER_REDUCER[ALL + 1], PLAYER_REDUCER_WEAPONS[ALL + 1], Float:PLAYER_GRAVITY[ALL + 1], Float:PLAYER_SPEED[ALL + 1], PLAYER_NAME[MAX_NAME], PLAYER_SAFE_NAME[MAX_SAFE_NAME] };

new codPlayer[MAX_PLAYERS + 1][playerInfo];

new cvarExpKill, cvarExpKillHS, cvarExpDamage, cvarExpDamagePer, cvarExpWinRound, cvarExpPlant, cvarExpDefuse, cvarExpRescue, cvarVipExpBonus, cvarNightExpEnabled, cvarNightExpFrom, cvarNightExpTo,
	cvarNightExpBonus, cvarLevelLimit, cvarLevelRatio, cvarPointsPerLevel, cvarPointsLimitEnabled, cvarKillStreakTime, cvarMinPlayers, cvarMinBonusPlayers, cvarBonusPlayersPer,
	cvarMaxDurability, cvarMinDamageDurability, cvarMaxDamageDurability, cvarBlockSkillsTime;

new Array:codItems, Array:codClasses, Array:codPromotions, Array:codFactions, Array:codPlayerClasses[MAX_PLAYERS + 1], Array:codPlayerRender[MAX_PLAYERS + 1], codForwards[forwards];

new Handle:sql, Handle:connection, bool:sqlConnected, bool:skillsBlocked, bool:nightExp, bool:mapEnd, bool:freezeTime = true,
	hudInfo, hudSync, hudSync2, dataLoaded, hudLoaded, resetStats, renderTimer, glowActive, roundStart, lastInfo;

forward amxbans_admin_connect(id);
forward client_admin(id, flags);

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	create_arrays();

	register_dictionary("cod.txt");

	create_cvar("cod_sql_host", "127.0.0.1", FCVAR_SPONLY | FCVAR_PROTECTED);
	create_cvar("cod_sql_user", "user", FCVAR_SPONLY | FCVAR_PROTECTED);
	create_cvar("cod_sql_pass", "password", FCVAR_SPONLY | FCVAR_PROTECTED);
	create_cvar("cod_sql_db", "database", FCVAR_SPONLY | FCVAR_PROTECTED);

	bind_pcvar_num(create_cvar("cod_kill_exp", "30"), cvarExpKill);
	bind_pcvar_num(create_cvar("cod_hs_exp", "10"), cvarExpKillHS);
	bind_pcvar_num(create_cvar("cod_damage_exp", "3"), cvarExpDamage);
	bind_pcvar_num(create_cvar("cod_damage_exp_per", "50"), cvarExpDamagePer);
	bind_pcvar_num(create_cvar("cod_win_exp", "25"), cvarExpWinRound);
	bind_pcvar_num(create_cvar("cod_bomb_exp", "25"), cvarExpPlant);
	bind_pcvar_num(create_cvar("cod_defuse_exp", "25"), cvarExpDefuse);
	bind_pcvar_num(create_cvar("cod_host_exp", "25"), cvarExpRescue);
	bind_pcvar_num(create_cvar("cod_vip_exp_bonus", "25"), cvarVipExpBonus);
	bind_pcvar_num(create_cvar("cod_night_exp", "1"), cvarNightExpEnabled);
	bind_pcvar_num(create_cvar("cod_night_exp_from", "22"), cvarNightExpFrom);
	bind_pcvar_num(create_cvar("cod_night_exp_to", "8"), cvarNightExpTo);
	bind_pcvar_num(create_cvar("cod_night_exp_bonus", "100"), cvarNightExpBonus);
	bind_pcvar_num(create_cvar("cod_max_level", "501"), cvarLevelLimit);
	bind_pcvar_num(create_cvar("cod_level_ratio", "20"), cvarLevelRatio);
	bind_pcvar_num(create_cvar("cod_points_per_level", "1"), cvarPointsPerLevel);
	bind_pcvar_num(create_cvar("cod_points_limit", "1"), cvarPointsLimitEnabled);
	bind_pcvar_num(create_cvar("cod_killstreak_time", "15"), cvarKillStreakTime);
	bind_pcvar_num(create_cvar("cod_min_players", "4"), cvarMinPlayers);
	bind_pcvar_num(create_cvar("cod_min_bonus_players", "10"), cvarMinBonusPlayers);
	bind_pcvar_num(create_cvar("cod_bonus_players_per", "10"), cvarBonusPlayersPer);
	bind_pcvar_num(create_cvar("cod_max_durability", "100"), cvarMaxDurability);
	bind_pcvar_num(create_cvar("cod_min_damage_durability", "20"), cvarMinDamageDurability);
	bind_pcvar_num(create_cvar("cod_max_damage_durability", "30"), cvarMaxDamageDurability);
	bind_pcvar_num(create_cvar("cod_block_skills_time", "5"), cvarBlockSkillsTime);

	register_cvar("cod_version", VERSION, FCVAR_SERVER);

	for (new i; i < sizeof commandClass; i++) register_clcmd(commandClass[i], "select_faction");
	for (new i; i < sizeof commandClasses; i++) register_clcmd(commandClasses[i], "display_classes_description");
	for (new i; i < sizeof commandItem; i++) register_clcmd(commandItem[i], "display_item_description");
	for (new i; i < sizeof commandItems; i++) register_clcmd(commandItems[i], "display_items_description");
	for (new i; i < sizeof commandDrop; i++) register_clcmd(commandDrop[i], "drop_item");
	for (new i; i < sizeof commandReset; i++) register_clcmd(commandReset[i], "reset_stats");
	for (new i; i < sizeof commandPoints; i++) register_clcmd(commandPoints[i], "assign_points");
	for (new i; i < sizeof commandHud; i++) register_clcmd(commandHud[i], "change_hud");
	for (new i; i < sizeof commandBinds; i++) register_clcmd(commandBinds[i], "show_binds");
	for (new i; i < sizeof commandTop; i++) register_clcmd(commandTop[i], "level_top");
	for (new i; i < sizeof commandBlock; i++) register_clcmd(commandBlock[i], "block_command");

	register_clcmd("cod_reset_data", "reset_data");
	register_clcmd("cod_reset_stats_data", "reset_stats_data");
	register_clcmd("cod_reset_all_data", "reset_all_data");

	register_clcmd("+rocket", "bind_use_rocket");
	register_clcmd("+mine", "bind_use_mine");
	register_clcmd("+dynamite", "bind_use_dynamite");
	register_clcmd("+medkit", "bind_use_medkit");
	register_clcmd("+poison", "bind_use_poison");
	register_clcmd("+thunder", "bind_use_thunder");
	register_clcmd("+teleport", "bind_use_teleport");
	register_clcmd("+class", "use_class");
	register_clcmd("+item", "use_item");

	register_impulse(100, "use_item");

	register_touch("rocket", "*" , "touch_rocket");
	register_touch("mine", "player" , "touch_mine");
	register_think("medkit", "think_medkit");
	register_think("poison", "think_poison");

	RegisterHam(Ham_Spawn, "player", "player_spawn", 1);
	RegisterHam(Ham_TakeDamage, "player", "player_take_damage_pre", 0);
	RegisterHam(Ham_TakeDamage, "player", "player_take_damage_post", 1);
	RegisterHam(Ham_Touch, "armoury_entity", "touch_weapon");
	RegisterHam(Ham_Touch, "weapon_shield", "touch_weapon");
	RegisterHam(Ham_Touch, "weaponbox", "touch_weapon");
	RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "speed_change", 1);
	RegisterHam(Ham_Spawn, "func_buyzone", "block_buyzone");

	for (new i = 1; i < sizeof weapons; i++) {
		if (weapons[i][0]) {
			RegisterHam(Ham_Item_Deploy, weapons[i], "weapon_deploy_post", 1);

			if (!(excludedWeapons & (1<<get_weaponid(weapons[i])))) RegisterHam(Ham_Weapon_PrimaryAttack, weapons[i], "weapon_primary_attack_post", 1);
		}
	}

	register_logevent("start_round", 2, "1=Round_Start");
	register_logevent("end_round", 2, "1=Round_End");
	register_logevent("hostage_rescued", 3, "2=Rescued_A_Hostage");
	register_logevent("hostage_killed", 3, "1=triggered", "2=Killed_A_Hostage");
	register_logevent("bomb_dropped", 3, "2=Dropped_The_Bomb");
	register_logevent("bomb_picked", 3, "2=Got_The_Bomb");

	register_event("TeamInfo", "team_assign", "a");
	register_event("HLTV", "new_round", "a", "1=0", "2=0");
	register_event("Health", "message_health", "be", "1!255");
	register_event("CurWeapon","cur_weapon", "be", "1=1");
	register_event("SendAudio", "t_win_round" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "ct_win_round", "a", "2&%!MRAD_ct_win_round");
	register_event("TextMsg", "hostages_rescued", "a", "2&#All_Hostages_R");
	register_event("TextMsg", "restart_round", "a", "2&#Game_C", "2&#Game_w");

	register_forward(FM_CmdStart, "cmd_start");
	register_forward(FM_EmitSound, "sound_emit");

	register_message(get_user_msgid("SayText"), "say_text");
	register_message(get_user_msgid("AmmoX"), "message_ammo");
	register_message(SVC_INTERMISSION, "message_intermission");

	hudSync = CreateHudSyncObj();
	hudSync2 = CreateHudSyncObj();
	hudInfo = CreateHudSyncObj();

	codForwards[CLASS_CHANGED] = CreateMultiForward("cod_class_changed", ET_IGNORE, FP_CELL, FP_CELL);
	codForwards[ITEM_CHANGED] = CreateMultiForward("cod_item_changed", ET_IGNORE, FP_CELL, FP_CELL);
	codForwards[RENDER_CHANGED] = CreateMultiForward("cod_render_changed", ET_IGNORE, FP_CELL, FP_CELL);
	codForwards[GRAVITY_CHANGED] = CreateMultiForward("cod_gravity_changed", ET_IGNORE, FP_CELL, FP_FLOAT);
	codForwards[SPEED_CHANGED] = CreateMultiForward("cod_speed_changed", ET_IGNORE, FP_CELL, FP_FLOAT);
	codForwards[DAMAGE_PRE] = CreateMultiForward("cod_damage_pre", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL, FP_CELL);
	codForwards[DAMAGE_POST] = CreateMultiForward("cod_damage_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL, FP_CELL);
	codForwards[DAMAGE_INFLICT] = CreateMultiForward("cod_damage_inflict", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT, FP_FLOAT, FP_CELL);
	codForwards[WEAPON_DEPLOY] = CreateMultiForward("cod_weapon_deploy", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	codForwards[CUR_WEAPON] = CreateMultiForward("cod_cur_weapon", ET_IGNORE, FP_CELL, FP_CELL);
	codForwards[TEAM_ASSIGN] = CreateMultiForward("cod_team_assign", ET_IGNORE, FP_CELL, FP_CELL);
	codForwards[KILLED] = CreateMultiForward("cod_killed", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	codForwards[SPAWNED] = CreateMultiForward("cod_spawned", ET_IGNORE, FP_CELL, FP_CELL);
	codForwards[CMD_START] = CreateMultiForward("cod_cmd_start", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	codForwards[FLAGS_CHANGED] = CreateMultiForward("cod_flags_changed", ET_CONTINUE, FP_CELL, FP_CELL);
	codForwards[BOMB_PLANTING] = CreateMultiForward("cod_bomb_planting", ET_IGNORE, FP_CELL);
	codForwards[BOMB_PLANTED] = CreateMultiForward("cod_bomb_planted", ET_IGNORE, FP_CELL);
	codForwards[BOMB_DEFUSING] = CreateMultiForward("cod_bomb_defusing", ET_IGNORE, FP_CELL);
	codForwards[BOMB_DEFUSED] = CreateMultiForward("cod_bomb_defused", ET_IGNORE, FP_CELL);
	codForwards[BOMB_EXPLODED] = CreateMultiForward("cod_bomb_exploded", ET_IGNORE, FP_CELL, FP_CELL);
	codForwards[BOMB_DROPPED] = CreateMultiForward("cod_bomb_dropped", ET_IGNORE, FP_CELL);
	codForwards[BOMB_PICKED] = CreateMultiForward("cod_bomb_picked", ET_IGNORE, FP_CELL);
	codForwards[HOSTAGE_KILLED] = CreateMultiForward("cod_hostage_killed", ET_IGNORE, FP_CELL);
	codForwards[HOSTAGE_RESCUED] = CreateMultiForward("cod_hostage_rescued", ET_IGNORE, FP_CELL);
	codForwards[HOSTAGES_RESCUED] = CreateMultiForward("cod_hostages_rescued", ET_IGNORE, FP_CELL);
	codForwards[NEW_ROUND] = CreateMultiForward("cod_new_round", ET_IGNORE);
	codForwards[START_ROUND] = CreateMultiForward("cod_start_round", ET_IGNORE);
	codForwards[RESTART_ROUND] = CreateMultiForward("cod_restart_round", ET_IGNORE);
	codForwards[END_ROUND] = CreateMultiForward("cod_end_round", ET_IGNORE);
	codForwards[WIN_ROUND] = CreateMultiForward("cod_win_round", ET_IGNORE, FP_CELL);
	codForwards[END_MAP] = CreateMultiForward("cod_end_map", ET_IGNORE);
	codForwards[MEDKIT_HEAL] = CreateMultiForward("cod_medkit_heal", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT);
	codForwards[POISON_INFECT] = CreateMultiForward("cod_poison_infect", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT);
	codForwards[ROCKET_EXPLODE] = CreateMultiForward("cod_rocket_explode", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT);
	codForwards[MINE_EXPLODE] = CreateMultiForward("cod_mine_explode", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT);
	codForwards[DYNAMITE_EXPLODE] = CreateMultiForward("cod_dynamite_explode", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT);
	codForwards[THUNDER_REACH] = CreateMultiForward("cod_thunder_reach", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT);
	codForwards[TELEPORT_USED] = CreateMultiForward("cod_teleport_used", ET_CONTINUE, FP_CELL);
	codForwards[RESET_DATA] = CreateMultiForward("cod_reset_data", ET_IGNORE);
	codForwards[RESET_STATS_DATA] = CreateMultiForward("cod_reset_stats_data", ET_IGNORE);
	codForwards[RESET_ALL_DATA] = CreateMultiForward("cod_reset_all_data", ET_IGNORE);
}

public plugin_natives()
{
	register_native("cod_get_user_exp", "_cod_get_user_exp", 1);
	register_native("cod_set_user_exp", "_cod_set_user_exp", 1);
	register_native("cod_get_user_bonus_exp", "_cod_get_user_bonus_exp", 1);
	register_native("cod_get_level_exp", "_cod_get_level_exp", 1);
	register_native("cod_get_user_level", "_cod_get_user_level", 1);
	register_native("cod_get_user_highest_level", "_cod_get_user_highest_level", 1);

	register_native("cod_get_user_class", "_cod_get_user_class", 1);
	register_native("cod_get_user_class_name", "_cod_get_user_class_name", 1);
	register_native("cod_set_user_class", "_cod_set_user_class", 1);
	register_native("cod_get_class_id", "_cod_get_class_id", 1);
	register_native("cod_get_class_name", "_cod_get_class_name", 1);
	register_native("cod_get_class_desc", "_cod_get_class_desc", 1);
	register_native("cod_get_class_health", "_cod_get_class_health", 1);
	register_native("cod_get_class_intelligence", "_cod_get_class_intelligence", 1);
	register_native("cod_get_class_stamina", "_cod_get_class_stamina", 1);
	register_native("cod_get_class_strength", "_cod_get_class_strength", 1);
	register_native("cod_get_class_condition", "_cod_get_class_condition", 1);
	register_native("cod_get_classes_num", "_cod_get_classes_num", 1);

	register_native("cod_get_user_promotion", "_cod_get_user_promotion", 1);
	register_native("cod_get_user_promotion_id", "_cod_get_user_promotion_id", 1);

	register_native("cod_get_user_item", "_cod_get_user_item", 1);
	register_native("cod_get_user_item_value", "_cod_get_user_item_value", 1);
	register_native("cod_get_user_item_name", "_cod_get_user_item_name", 1);
	register_native("cod_set_user_item", "_cod_set_user_item", 1);
	register_native("cod_upgrade_user_item", "_cod_upgrade_user_item", 1);
	register_native("cod_check_item", "_cod_check_item", 1);
	register_native("cod_get_item_id", "_cod_get_item_id", 1);
	register_native("cod_get_item_name", "_cod_get_item_name", 1);
	register_native("cod_get_item_desc", "_cod_get_item_desc", 1);
	register_native("cod_get_items_num", "_cod_get_items_num", 1);

	register_native("cod_get_item_durability", "_cod_get_item_durability", 1);
	register_native("cod_set_item_durability", "_cod_set_item_durability", 1);
	register_native("cod_max_item_durability", "_cod_max_item_durability", 1);

	register_native("cod_get_user_max_health", "_cod_get_user_max_health", 1);
	register_native("cod_get_user_health", "_cod_get_user_health", 1);
	register_native("cod_set_user_health", "_cod_set_user_health", 1);
	register_native("cod_add_user_health", "_cod_add_user_health", 1);

	register_native("cod_get_user_health", "_cod_get_user_health", 1);
	register_native("cod_get_user_intelligence", "_cod_get_user_intelligence", 1);
	register_native("cod_get_user_stamina", "_cod_get_user_stamina", 1);
	register_native("cod_get_user_strength", "_cod_get_user_strength", 1);
	register_native("cod_get_user_condition", "_cod_get_user_condition", 1);

	register_native("cod_get_user_bonus_health", "_cod_get_user_bonus_health", 1);
	register_native("cod_get_user_bonus_intelligence", "_cod_get_user_bonus_intelligence", 1);
	register_native("cod_get_user_bonus_stamina", "_cod_get_user_bonus_stamina", 1);
	register_native("cod_get_user_bonus_strength", "_cod_get_user_bonus_strength", 1);
	register_native("cod_get_user_bonus_condition", "_cod_get_user_bonus_condition", 1);

	register_native("cod_set_user_bonus_health", "_cod_set_user_bonus_health", 1);
	register_native("cod_set_user_bonus_intelligence", "_cod_set_user_bonus_intelligence", 1);
	register_native("cod_set_user_bonus_stamina", "_cod_set_user_bonus_stamina", 1);
	register_native("cod_set_user_bonus_strength", "_cod_set_user_bonus_strength", 1);
	register_native("cod_set_user_bonus_condition", "_cod_set_user_bonus_condition", 1);

	register_native("cod_add_user_bonus_health", "_cod_add_user_bonus_health", 1);
	register_native("cod_add_user_bonus_intelligence", "_cod_add_user_bonus_intelligence", 1);
	register_native("cod_add_user_bonus_stamina", "_cod_add_user_bonus_stamina", 1);
	register_native("cod_add_user_bonus_strength", "_cod_add_user_bonus_strength", 1);
	register_native("cod_add_user_bonus_condition", "_cod_add_user_bonus_condition", 1);

	register_native("cod_get_user_rockets", "_cod_get_user_rockets", 1);
	register_native("cod_get_user_mines", "_cod_get_user_mines", 1);
	register_native("cod_get_user_dynamites", "_cod_get_user_dynamites", 1);
	register_native("cod_get_user_thunders", "_cod_get_user_thunders", 1);
	register_native("cod_get_user_medkits", "_cod_get_user_medkits", 1);
	register_native("cod_get_user_poisons", "_cod_get_user_poisons", 1);
	register_native("cod_get_user_teleports", "_cod_get_user_teleports", 1);
	register_native("cod_get_user_multijumps", "_cod_get_user_multijumps", 1);
	register_native("cod_get_user_gravity", "_cod_get_user_gravity", 1);
	register_native("cod_get_user_speed", "_cod_get_user_speed", 1);
	register_native("cod_get_user_armor", "_cod_get_user_armor", 1);

	register_native("cod_set_user_rockets", "_cod_set_user_rockets", 1);
	register_native("cod_set_user_mines", "_cod_set_user_mines", 1);
	register_native("cod_set_user_dynamites", "_cod_set_user_dynamites", 1);
	register_native("cod_set_user_thunders", "_cod_set_user_thunders", 1);
	register_native("cod_set_user_medkits", "_cod_set_user_medkits", 1);
	register_native("cod_set_user_poisons", "_cod_set_user_poisons", 1);
	register_native("cod_set_user_teleports", "_cod_set_user_teleports", 1);
	register_native("cod_set_user_multijumps", "_cod_set_user_multijumps", 1);
	register_native("cod_set_user_gravity", "_cod_set_user_gravity", 1);
	register_native("cod_set_user_speed", "_cod_set_user_speed", 1);
	register_native("cod_set_user_armor", "_cod_set_user_armor", 1);

	register_native("cod_add_user_rockets", "_cod_add_user_rockets", 1);
	register_native("cod_add_user_mines", "_cod_add_user_mines", 1);
	register_native("cod_add_user_dynamites", "_cod_add_user_dynamites", 1);
	register_native("cod_add_user_thunders", "_cod_add_user_thunders", 1);
	register_native("cod_add_user_medkits", "_cod_add_user_medkits", 1);
	register_native("cod_add_user_poisons", "_cod_add_user_poisons", 1);
	register_native("cod_add_user_teleports", "_cod_add_user_teleports", 1);
	register_native("cod_add_user_multijumps", "_cod_add_user_multijumps", 1);
	register_native("cod_add_user_gravity", "_cod_add_user_gravity", 1);
	register_native("cod_add_user_speed", "_cod_add_user_speed", 1);
	register_native("cod_add_user_armor", "_cod_add_user_armor", 1);

	register_native("cod_use_user_rocket", "_cod_use_user_rocket", 1);
	register_native("cod_use_user_mine", "_cod_use_user_mine", 1);
	register_native("cod_use_user_dynamite", "_cod_use_user_dynamite", 1);
	register_native("cod_use_user_thunder", "_cod_use_user_thunder", 1);
	register_native("cod_use_user_medkit", "_cod_use_user_medkit", 1);
	register_native("cod_use_user_poison", "_cod_use_user_poison", 1);
	register_native("cod_use_user_teleport", "_cod_use_user_teleport", 1);

	register_native("cod_get_user_bunnyhop", "_cod_get_user_bunnyhop", 1);
	register_native("cod_get_user_footsteps", "_cod_get_user_footsteps", 1);
	register_native("cod_get_user_model", "_cod_get_user_model", 1);
	register_native("cod_get_user_resistance", "_cod_get_user_resistance", 1);
	register_native("cod_get_user_godmode", "_cod_get_user_godmode", 1);
	register_native("cod_get_user_noclip", "_cod_get_user_noclip", 1);
	register_native("cod_get_user_unlimited_ammo", "_cod_get_user_unlimited_ammo", 1);
	register_native("cod_get_user_recoil_eliminator", "_cod_get_user_recoil_eliminator", 1);
	register_native("cod_get_user_recoil_reducer", "_cod_get_user_recoil_reducer", 1);

	register_native("cod_set_user_bunnyhop", "_cod_set_user_bunnyhop", 1);
	register_native("cod_set_user_footsteps", "_cod_set_user_footsteps", 1);
	register_native("cod_set_user_model", "_cod_set_user_model", 1);
	register_native("cod_set_user_resistance", "_cod_set_user_resistance", 1);
	register_native("cod_set_user_godmode", "_cod_set_user_godmode", 1);
	register_native("cod_set_user_noclip", "_cod_set_user_noclip", 1);
	register_native("cod_set_user_unlimited_ammo", "_cod_set_user_unlimited_ammo", 1);
	register_native("cod_set_user_recoil_eliminator", "_cod_set_user_recoil_eliminator", 1);
	register_native("cod_set_user_recoil_reducer", "_cod_set_user_recoil_reducer", 1);

	register_native("cod_give_weapon", "_cod_give_weapon", 1);
	register_native("cod_take_weapon", "_cod_take_weapon", 1);
	register_native("cod_get_user_weapon", "_cod_get_user_weapon", 1);

	register_native("cod_get_user_render", "_cod_get_user_render", 1);
	register_native("cod_set_user_render", "_cod_set_user_render", 1);
	register_native("cod_set_user_glow", "_cod_set_user_glow", 1);

	register_native("cod_get_user_flags", "_cod_get_user_flags", 1);
	register_native("cod_set_user_flags", "_cod_set_user_flags", 1);

	register_native("cod_print_chat", "_cod_print_chat", 1);
	register_native("cod_log_error", "_cod_log_error", 1);
	register_native("cod_show_hud", "_cod_show_hud", 1);
	register_native("cod_cmd_execute", "_cod_cmd_execute", 1);
	register_native("cod_sql_string", "_cod_sql_string", 1);
	register_native("cod_make_bartimer", "_cod_make_bartimer", 1);
	register_native("cod_display_fade", "_cod_display_fade", 1);
	register_native("cod_display_icon", "_cod_display_icon", 1);
	register_native("cod_screen_shake", "_cod_screen_shake", 1);
	register_native("cod_drop_weapon", "_cod_drop_weapon", 1);
	register_native("cod_refill_ammo", "_cod_refill_ammo", 1);
	register_native("cod_make_explosion", "_cod_make_explosion", 1);
	register_native("cod_repeat_damage", "_cod_repeat_damage", 1);
	register_native("cod_inflict_damage", "_cod_inflict_damage", 1);
	register_native("cod_kill_player", "_cod_kill_player", 1);
	register_native("cod_respawn_player", "_cod_respawn_player", 1);
	register_native("cod_teleport_to_spawn", "_cod_teleport_to_spawn", 1);
	register_native("cod_random_upgrade", "_cod_random_upgrade", 1);
	register_native("cod_percent_chance", "_cod_percent_chance", 1);
	register_native("cod_is_enough_space", "_cod_is_enough_space", 1);
	register_native("cod_remove_ents", "_cod_remove_ents", 1);

	register_native("cod_register_item", "_cod_register_item");
	register_native("cod_register_class", "_cod_register_class");
	register_native("cod_register_promotion", "_cod_register_promotion");
}

public plugin_cfg()
{
	new configPath[64];

	get_localinfo("amxx_configsdir", configPath, charsmax(configPath));

	server_cmd("exec %s/cod_mod.cfg", configPath);
	server_exec();

	server_cmd("sv_maxspeed 500");

	if (get_level_exp(cvarLevelLimit - 1) < 0) {
		new failState[192];

		formatex(failState, charsmax(failState), "%L", LANG_SERVER, "CORE_EXP_ERROR");

		set_fail_state(failState);
	}

	sql_init();

	if (cvarNightExpEnabled) {
		set_task(5.0, "check_time", _, _, _, "b");
		set_task(300.0, "night_exp_info", _, _, _, "b");
	}

	log_amx("Call of Duty Mod by O'Zone (v%s).", VERSION);
	log_amx("Loaded %i classes and %i items.", ArraySize(codClasses) - 1, ArraySize(codItems) - 1);
}

public plugin_end()
{
	if (sql != Empty_Handle) SQL_FreeHandle(sql);
	if (connection != Empty_Handle) SQL_FreeHandle(connection);

	for (new i = 0; i < sizeof codForwards; i++) DestroyForward(i);
	for (new i = 0; i < ArraySize(codItems); i++) for (new j = ITEM_GIVE; j <= ITEM_UPGRADE; j++) DestroyForward(get_item_info(i, j));
	for (new i = 0; i < ArraySize(codClasses); i++) for (new j = CLASS_ENABLED; j <= CLASS_SKILL_USED; j++) DestroyForward(get_class_info(i, j));

	ArrayDestroy(codItems);
	ArrayDestroy(codClasses);
	ArrayDestroy(codPromotions);
	ArrayDestroy(codFactions);

	for (new i = 1; i <= MAX_PLAYERS; i++)
	{
		ArrayDestroy(codPlayerClasses[i]);
		ArrayDestroy(codPlayerRender[i]);
	}
}

public plugin_precache()
{
	for (new i = 0; i < sizeof codSounds; i++) precache_sound(codSounds[i]);
	for (new i = 0; i < sizeof codModels; i++) precache_model(codModels[i]);
	for (new i = 0; i < sizeof codSprites; i++) codSprite[i] = precache_model(codSprites[i]);
}

public client_connect(id)
{
	reset_player(id);

	if (is_user_bot(id) || is_user_hltv(id)) return;

	codPlayer[id][SKILL_USE] = NONE;

	ArrayClear(codPlayerClasses[id]);

	new codPlayerClass[playerClassInfo];

	for (new i = 0; i < ArraySize(codClasses); i++) ArrayPushArray(codPlayerClasses[id], codPlayerClass);

	get_user_name(id, codPlayer[id][PLAYER_NAME], charsmax(codPlayer[][PLAYER_NAME]));

	sql_string(codPlayer[id][PLAYER_NAME], codPlayer[id][PLAYER_SAFE_NAME], charsmax(codPlayer[][PLAYER_SAFE_NAME]));

	set_task(0.1, "load_data", id);
}

public client_putinserver(id)
{
	show_bonus_info();

	if (is_user_bot(id) || is_user_hltv(id)) return;

	set_task(20.0, "show_advertisement", id + TASK_SHOW_AD);
	set_task(5.0, "set_speed_limit", id + TASK_SPEED_LIMIT);
	set_task(90.0, "show_help", id + TASK_SHOW_HELP, .flags = "b");
	set_task(0.1, "show_info", id + TASK_SHOW_INFO, .flags = "b");
}

public amxbans_admin_connect(id)
	update_user_flags(id, get_user_flags(id));

public client_authorized(id)
	update_user_flags(id, get_user_flags(id));

public client_admin(id, flags)
	update_user_flags(id, flags);

public client_disconnected(id)
{
	save_data(id, mapEnd ? MAP_END : FINAL);

	remove_tasks(id);
	remove_ents(id);

	if (!mapEnd) {
		if (codPlayer[id][PLAYER_CLASS]) execute_forward_ignore_one_param(get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_DISABLED), id);
		if (codPlayer[id][PLAYER_ITEM]) execute_forward_ignore_one_param(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_DROP), id);
	}
}

public create_arrays()
{
	new codItem[itemInfo], codClass[classInfo], codRender[renderInfo];

	codItems = ArrayCreate(itemInfo);
	codClasses = ArrayCreate(classInfo);
	codPromotions = ArrayCreate(classInfo);
	codFactions = ArrayCreate(MAX_NAME);

	for (new i = 1; i <= MAX_PLAYERS; i++) {
		codPlayerClasses[i] = ArrayCreate(playerClassInfo);
		codPlayerRender[i] = ArrayCreate(renderInfo);
	}

	formatex(codItem[ITEM_NAME], charsmax(codItem[ITEM_NAME]), "%L", LANG_SERVER, "CORE_NONE");
	formatex(codItem[ITEM_DESC], charsmax(codItem[ITEM_DESC]), "%L", LANG_SERVER, "CORE_NO_ITEM");

	ArrayPushArray(codItems, codItem);

	formatex(codClass[CLASS_NAME], charsmax(codClass[CLASS_NAME]), "%L", LANG_SERVER, "CORE_NONE");

	ArrayPushArray(codClasses, codClass);

	codRender[RENDER_VALUE] = 256;

	for (new i = 1; i <= MAX_PLAYERS; i++) {
		for (new j = CLASS; j <= ADDITIONAL; j++) {
			codRender[RENDER_TYPE] = j;

			ArrayPushArray(codPlayerRender[i], codRender);
		}
	}
}

public reset_data(id)
{
	if (!(codPlayer[id][PLAYER_FLAGS] & RESET_FLAG)) return PLUGIN_HANDLED;

	log_to_file(LOG_FILE,  "[%s] Admin %s forced a data reset.", PLUGIN, codPlayer[id][PLAYER_NAME]);

	chat_print(0, "%L", LANG_PLAYER, "CORE_RESET_DATA");
	chat_print(0, "%L", LANG_PLAYER, "CORE_MAP_RESTART");

	clear_database(id);

	execute_forward_ignore(codForwards[RESET_DATA]);

	return PLUGIN_HANDLED;
}

public reset_stats_data(id)
{
	if (!(codPlayer[id][PLAYER_FLAGS] & RESET_FLAG)) return PLUGIN_HANDLED;

	log_to_file(LOG_FILE,  "[%s] Admin %s forced a stats reset.", PLUGIN, codPlayer[id][PLAYER_NAME]);

	chat_print(0, "%L", LANG_PLAYER, "CORE_RESET_STATS");
	chat_print(0, "%L", LANG_PLAYER, "CORE_MAP_RESTART");

	execute_forward_ignore(codForwards[RESET_STATS_DATA]);

	set_task(10.0, "restart_map");

	return PLUGIN_HANDLED;
}

public reset_all_data(id)
{
	if (!(codPlayer[id][PLAYER_FLAGS] & RESET_FLAG)) return PLUGIN_HANDLED;

	log_to_file(LOG_FILE,  "[%s] Admin %s forced a full data reset.", PLUGIN, codPlayer[id][PLAYER_NAME]);

	chat_print(0, "%L", LANG_PLAYER, "CORE_RESET_FULL");
	chat_print(0, "%L", LANG_PLAYER, "CORE_MAP_RESTART");

	clear_database(id);

	execute_forward_ignore(codForwards[RESET_ALL_DATA]);

	return PLUGIN_HANDLED;
}

public clear_database(id)
{
	for (new i = 1; i <= MAX_PLAYERS; i++) rem_bit(i, dataLoaded);

	sqlConnected = false;

	new tempData[32];

	formatex(tempData, charsmax(tempData), "DROP TABLE `cod_mod`;");

	SQL_ThreadQuery(sql, "ignore_handle", tempData);

	set_task(10.0, "restart_map");
}

public restart_map()
{
	new currentMap[64];

	get_mapname(currentMap, charsmax(currentMap));

	server_cmd("changelevel ^"%s^"", currentMap);
}

public select_faction(id)
{
	if (!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	if (!get_bit(id, dataLoaded)) {
		chat_print(id, "%L", id, "CORE_LOADING_DATA");

		return PLUGIN_HANDLED;
	}

	if (ArraySize(codFactions)) {
		client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

		new menuData[128], factionName[MAX_NAME];

		formatex(menuData, charsmax(menuData), "%L", id, "CORE_SELECT_FACTION");

		new menu = menu_create(menuData, "select_faction_handle");

		for (new i = 0; i < ArraySize(codFactions); i++) {
			ArrayGetString(codFactions, i, factionName, charsmax(factionName));

			menu_additem(menu, factionName, factionName);
		}

		formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
		menu_setprop(menu, MPROP_EXITNAME, menuData);

		formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
		menu_setprop(menu, MPROP_BACKNAME, menuData);

		formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
		menu_setprop(menu, MPROP_NEXTNAME, menuData);

		menu_display(id, menu);
	} else select_class(id);

	return PLUGIN_HANDLED;
}

public select_faction_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128], menuClassName[MAX_NAME], menuClassId[5], itemData[MAX_NAME], classId = codPlayer[id][PLAYER_CLASS], codClass[classInfo], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, itemCallback);

	menu_destroy(menu);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_SELECT_CLASS");

	new menu = menu_create(menuData, "select_class_confirm");

	for (new i = 1; i < ArraySize(codClasses); i++) {
		ArrayGetArray(codClasses, i, codClass);

		if (equal(itemData, codClass[CLASS_FRACTION])) {
			load_class(id, i);

			if (codPlayer[id][PLAYER_PROMOTION]) get_user_class_info(id, i, CLASS_NAME, menuClassName, charsmax(menuClassName));
			else formatex(menuClassName, charsmax(menuClassName), codClass[CLASS_NAME]);

			formatex(menuData, charsmax(menuData), "%L", id, "CORE_SELECT_CLASS_ITEM", menuClassName, codPlayer[id][PLAYER_LEVEL], get_weapons(codPlayer[id][PLAYER_WEAPONS]));

			num_to_str(i, menuClassId, charsmax(menuClassId));

			menu_additem(menu, menuData, menuClassId);
		}
	}

	load_class(id, classId);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public select_class(id)
{
	if (!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128], menuClassName[MAX_NAME], menuClassId[5], codClass[classInfo], classId = codPlayer[id][PLAYER_CLASS];

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_SELECT_CLASS");

	new menu = menu_create(menuData, "select_class_confirm");

	for (new i = 1; i < ArraySize(codClasses); i++) {
		ArrayGetArray(codClasses, i, codClass);

		load_class(id, i);

		if (codPlayer[id][PLAYER_PROMOTION]) get_user_class_info(id, i, CLASS_NAME, menuClassName, charsmax(menuClassName));
		else formatex(menuClassName, charsmax(menuClassName), codClass[CLASS_NAME]);

		formatex(menuData, charsmax(menuData), "%L", id, "CORE_SELECT_CLASS_ITEM", menuClassName, codPlayer[id][PLAYER_LEVEL], get_weapons(codPlayer[id][PLAYER_WEAPONS]));

		num_to_str(i, menuClassId, charsmax(menuClassId));

		menu_additem(menu, menuData, menuClassId);
	}

	load_class(id, classId);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	menu_display(id, menu);

	return PLUGIN_CONTINUE;
}

public select_class_confirm(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[512], codClass[classInfo], itemData[5], itemAccess, itemCallback, classId = codPlayer[id][PLAYER_CLASS];

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, itemCallback);

	new class = str_to_num(itemData);

	menu_destroy(menu);

	if (class == codPlayer[id][PLAYER_CLASS] && codPlayer[id][PLAYER_NEW_CLASS] == NONE) {
		chat_print(id, "%L", id, "CORE_CLASS_SAME");

		return PLUGIN_CONTINUE;
	}

	new flag = get_class_info(class, CLASS_FLAG);

	if (flag != NONE && !(codPlayer[id][PLAYER_FLAGS] & flag)) {
		chat_print(id, "%L", id, "CORE_CLASS_NO_ACCESS");

		return PLUGIN_CONTINUE;
	}

	load_class(id, class);

	if (codPlayer[id][PLAYER_PROMOTION]) ArrayGetArray(codPromotions, codPlayer[id][PLAYER_PROMOTION_ID], codClass);
	else ArrayGetArray(codClasses, class, codClass);

	new classDesc[64][32], descFirstLine[75], descSecondLine[75], descWords;

	descWords = explode_string(codClass[CLASS_DESC], " ", classDesc, charsmax(classDesc), charsmax(classDesc[]));

	formatex(descSecondLine, charsmax(descSecondLine), "^n");

	for (new i = 0; i < descWords; i++) {
		if (strlen(descFirstLine) + strlen(classDesc[i]) < charsmax(descFirstLine)) format(descFirstLine, charsmax(descFirstLine), "%s%s%s", descFirstLine, strlen(descFirstLine) ? " " : "", classDesc[i]);
		else format(descSecondLine, charsmax(descSecondLine), "%s%s%s", descSecondLine, strlen(descSecondLine) > 2 ? " " : "", classDesc[i]);
	}

	format(menuData, charsmax(menuData), "%L", id, "CORE_CLASS_DATA", codClass[CLASS_NAME], get_weapons(codClass[CLASS_WEAPONS]), codClass[CLASS_HEAL],
		codClass[CLASS_INT], codClass[CLASS_STR], codClass[CLASS_STAM], codClass[CLASS_COND], descFirstLine, descSecondLine);

	menu = menu_create(menuData, "select_class_confirm_handle");

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_CLASS_PLAY");
	menu_additem(menu, menuData, itemData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_BACK");
	menu_additem(menu, menuData);

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);

	load_class(id, classId);

	return PLUGIN_HANDLED;
}

public select_class_confirm_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	if (item) select_faction(id);
	else {
		client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

		new itemData[5], itemAccess, itemCallback;

		menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, itemCallback);

		new class = str_to_num(itemData);

		codPlayer[id][PLAYER_NEW_CLASS] = class;

		if (codPlayer[id][PLAYER_CLASS]) chat_print(id, "%L", id, "CORE_CLASS_SELECTED");
		else set_new_class(id);
	}

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public display_classes_description(id, class, sound)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128], className[MAX_NAME * 2], classId[5];

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_SELECT_CLASS");

	new menu = menu_create(menuData, "display_classes_description_handle");

	for (new i = 1; i < ArraySize(codClasses); i++) {
		get_class_info(i, CLASS_NAME, className, charsmax(className));

		if (ArraySize(codFactions)) {
			static classFraction[MAX_NAME];

			get_class_info(i, CLASS_FRACTION, classFraction, charsmax(classFraction));

			format(className, charsmax(className), "%s \y(%s)", className, classFraction);
		}

		num_to_str(i, classId, charsmax(classId));

		menu_additem(menu, className, classId);
	}

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	menu_display(id, menu, class / 7);

	return PLUGIN_HANDLED;
}

public display_classes_description_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[512], codClass[classInfo], classId[5], promotionData[10], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, classId, charsmax(classId), _, _, itemCallback);

	new class = str_to_num(classId), promotion = find_class_promotion(class);

	menu_destroy(menu);

	ArrayGetArray(codClasses, class, codClass);

	new classDesc[64][32], descFirstLine[75], descSecondLine[75], descWords;

	descWords = explode_string(codClass[CLASS_DESC], " ", classDesc, charsmax(classDesc), charsmax(classDesc[]));

	formatex(descSecondLine, charsmax(descSecondLine), "^n");

	for (new i = 0; i < descWords; i++) {
		if (strlen(descFirstLine) + strlen(classDesc[i]) < charsmax(descFirstLine)) format(descFirstLine, charsmax(descFirstLine), "%s%s%s", descFirstLine, strlen(descFirstLine) ? " " : "", classDesc[i]);
		else format(descSecondLine, charsmax(descSecondLine), "%s%s%s", descSecondLine, strlen(descSecondLine) > 2 ? " " : "", classDesc[i]);
	}

	format(menuData, charsmax(menuData), "%L", id, "CORE_CLASS_DATA", codClass[CLASS_NAME], get_weapons(codClass[CLASS_WEAPONS]), codClass[CLASS_HEAL],
		codClass[CLASS_INT], codClass[CLASS_STR], codClass[CLASS_STAM], codClass[CLASS_COND], descFirstLine, descSecondLine);

	menu = menu_create(menuData, "classes_description_handle");

	if (promotion > PROMOTION_NONE) {
		new menuData[128], className[MAX_NAME];

		formatex(promotionData, charsmax(promotionData), "%i#%i", class, promotion);

		get_class_promotion_info(class, promotion, CLASS_NAME, className, charsmax(className));

		formatex(menuData, charsmax(menuData), "%L", id, "CORE_SHOW_PROMOTION", className, get_class_promotion_info(class, promotion, CLASS_LEVEL));

		menu_additem(menu, menuData, promotionData);
	}

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_BACK");
	menu_additem(menu, menuData, classId);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_additem(menu, menuData);

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public classes_description_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new itemData[10], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, itemCallback);

	if (!itemData[0]) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	menu_destroy(menu);

	if (containi(itemData, "#") != NONE) {
		new classId[5], promotionId[5];

		strtok(itemData, classId, charsmax(classId), promotionId, charsmax(promotionId), '#');

		display_promotions_description(id, str_to_num(classId), str_to_num(promotionId));
	} else display_classes_description(id, str_to_num(itemData), 1);

	return PLUGIN_HANDLED;
}

public display_promotions_description(id, class, promotion)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new classDesc[64][32], codClass[classInfo], menuData[512], descFirstLine[75], descSecondLine[75], promotionData[10], classId[5], descWords;

	num_to_str(class, classId, charsmax(classId));

	ArrayGetArray(codPromotions, get_class_promotion_info(class, promotion, CLASS_PROMOTION), codClass);

	descWords = explode_string(codClass[CLASS_DESC], " ", classDesc, charsmax(classDesc), charsmax(classDesc[]));

	formatex(descSecondLine, charsmax(descSecondLine), "^n");

	for (new i = 0; i < descWords; i++) {
		if (strlen(descFirstLine) + strlen(classDesc[i]) < charsmax(descFirstLine)) format(descFirstLine, charsmax(descFirstLine), "%s%s%s", descFirstLine, strlen(descFirstLine) ? " " : "", classDesc[i]);
		else format(descSecondLine, charsmax(descSecondLine), "%s%s%s", descSecondLine, strlen(descSecondLine) > 2 ? " " : "", classDesc[i]);
	}

	format(menuData, charsmax(menuData), "%L", id, "CORE_CLASS_DATA", codClass[CLASS_NAME], get_weapons(codClass[CLASS_WEAPONS]), codClass[CLASS_HEAL],
		codClass[CLASS_INT], codClass[CLASS_STR], codClass[CLASS_STAM], codClass[CLASS_COND], descFirstLine, descSecondLine);

	new menu = menu_create(menuData, "classes_description_handle"), classPromotion = find_class_promotion(class, promotion);

	if (classPromotion > PROMOTION_NONE) {
		new menuData[128], className[MAX_NAME];

		formatex(promotionData, charsmax(promotionData), "%i#%i", class, classPromotion);

		get_class_promotion_info(class, classPromotion, CLASS_NAME, className, charsmax(className));

		formatex(menuData, charsmax(menuData), "%L", id, "CORE_SHOW_PROMOTION", className, get_class_promotion_info(class, classPromotion, CLASS_LEVEL));

		menu_additem(menu, menuData, promotionData);
	}

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_BACK");
	menu_additem(menu, menuData, classId);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_additem(menu, menuData);

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public display_item_description(id)
{
	show_item_description(id, codPlayer[id][PLAYER_ITEM], 0);

	return PLUGIN_HANDLED;
}

public display_items_description(id, page, sound)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128], itemName[MAX_NAME];

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_SELECT_ITEM");

	new menu = menu_create(menuData, "display_items_description_handle");

	for (new i = 1; i < ArraySize(codItems); i++) {
		get_item_info(i, ITEM_NAME, itemName, charsmax(itemName));

		menu_additem(menu, itemName);
	}

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	menu_display(id, menu, page);

	return PLUGIN_HANDLED;
}

public display_items_description_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	menu_destroy(menu);

	show_item_description(id, item + 1, 1);

	display_items_description(id, item / 7, 1);

	return PLUGIN_HANDLED;
}

public show_item_description(id, item, info)
{
	new itemDescription[MAX_DESC], itemName[MAX_NAME];

	if (!item) {
		formatex(itemName, charsmax(itemName), "%L", id, "CORE_NONE");
		chat_print(id, "%L", id, "CORE_ITEM", itemName);

		formatex(itemDescription, charsmax(itemDescription), "%L", id, "CORE_NO_ITEM");
		chat_print(id, "%L", id, "CORE_ITEM_DESC", itemDescription);

		return PLUGIN_HANDLED;
	}

	new valueRandom[MAX_NAME / 4];

	get_item_info(item, ITEM_DESC, itemDescription, charsmax(itemDescription));
	get_item_info(item, ITEM_NAME, itemName, charsmax(itemName));

	new valueMin = get_item_info(item, ITEM_RANDOM_MIN), valueMax = get_item_info(item, ITEM_RANDOM_MAX);

	chat_print(id, "%L", id, "CORE_ITEM", itemName);

	if (get_item_info(item, ITEM_VALUE) > 0) {
		if (!info) {
			new itemValue[6], itemTempValue = _cod_get_user_item_value(id);

			num_to_str(itemTempValue, itemValue, charsmax(itemValue));

			format(itemDescription, charsmax(itemDescription), itemDescription, itemValue);
		} else {
			if (valueMin & valueMax) formatex(valueRandom, charsmax(valueRandom), "%i-%i", valueMin, valueMax);
			else if (valueMin) formatex(valueRandom, charsmax(valueRandom), "%i", valueMin);
			else valueRandom = "x";

			format(itemDescription, charsmax(itemDescription), itemDescription, valueRandom);
		}
	}

	chat_print(id, "%L", id, "CORE_ITEM_DESC", itemDescription);

	return PLUGIN_HANDLED;
}

public drop_item(id)
{
	if (codPlayer[id][PLAYER_ITEM]) {
		new itemName[MAX_NAME];

		get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_NAME, itemName, charsmax(itemName));

		chat_print(id, "%L", id, "CORE_ITEM_DROPPED", itemName);

		set_item(id);
	} else chat_print(id, "%L", id, "CORE_ITEM_NONE");

	return PLUGIN_HANDLED;
}

public reset_stats(id)
{
	if (!cod_check_account(id)) return PLUGIN_HANDLED;

	if (!is_user_alive(id)) {
		reset_points(id);

		return PLUGIN_CONTINUE;
	}

	set_bit(id, resetStats);

	chat_print(id, "%L", id, "CORE_STATS_RESET");

	return PLUGIN_HANDLED;
}

public reset_points(id)
{
	if (!is_user_connected(id)) return;

	rem_bit(id, resetStats);

	codPlayer[id][PLAYER_POINTS] = (codPlayer[id][PLAYER_LEVEL] - 1) * cvarPointsPerLevel;
	codPlayer[id][PLAYER_INT] = 0;
	codPlayer[id][PLAYER_HEAL] = 0;
	codPlayer[id][PLAYER_COND] = 0;
	codPlayer[id][PLAYER_STR] = 0;
	codPlayer[id][PLAYER_STAM] = 0;

	if (codPlayer[id][PLAYER_POINTS]) assign_points(id, 0);
}

public assign_points(id, sound)
{
	if (!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	if (!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128];

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_POINTS_ASSIGN", codPlayer[id][PLAYER_POINTS]);

	new menu = menu_create(menuData, "assign_points_handler");

	if (pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]] == FULL) formatex(menuData, charsmax(menuData), "%L", id, "CORE_POINTS_ALL");
	else formatex(menuData, charsmax(menuData), "%L", id, "CORE_POINTS_ADD", pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]]);

	menu_additem(menu, menuData);

	menu_addblank(menu, 0);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_POINTS_HEALTH", get_health(id, 1, 1, 1, 0), get_health(id, 1, 1, 1, 0));
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_POINTS_INTELLIGENCE",  get_intelligence(id), get_intelligence(id) / 2.0, "%");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_POINTS_STRENGTH", get_strength(id), get_strength(id) / 10.0);
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_POINTS_STAMINA", get_stamina(id), get_stamina(id) / 4.0, "%");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_POINTS_CONDITION", get_condition(id), get_condition(id) * 0.85 / 250.0 * 100.0, "%");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public assign_points_handler(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	if (!codPlayer[id][PLAYER_POINTS]) return PLUGIN_CONTINUE;

	new statsLimit = cvarPointsLimitEnabled ? (cvarLevelLimit * cvarPointsPerLevel / 5) : 0;

	new pointsDistributionAmount = (pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]] == FULL) ? codPlayer[id][PLAYER_POINTS] :
		(pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]] > codPlayer[id][PLAYER_POINTS] ? codPlayer[id][PLAYER_POINTS] : pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]]);

	switch (item) {
		case 0: {
			if (++codPlayer[id][PLAYER_POINTS_SPEED] >= sizeof pointsDistribution) {
				codPlayer[id][PLAYER_POINTS_SPEED] = 0;
			}
		} case 1: {
			if (!statsLimit || codPlayer[id][PLAYER_HEAL] < statsLimit) {
				if (statsLimit && pointsDistributionAmount > statsLimit - codPlayer[id][PLAYER_HEAL]) pointsDistributionAmount = statsLimit - codPlayer[id][PLAYER_HEAL];

				codPlayer[id][PLAYER_HEAL] += pointsDistributionAmount;
				codPlayer[id][PLAYER_POINTS] -= pointsDistributionAmount;
			} else chat_print(id, "%L", id, "CORE_POINTS_HEALTH_MAX");
		} case 2: {
			if (!statsLimit || codPlayer[id][PLAYER_INT] < statsLimit) {
				if (statsLimit && pointsDistributionAmount > statsLimit - codPlayer[id][PLAYER_INT]) pointsDistributionAmount = statsLimit - codPlayer[id][PLAYER_INT];

				codPlayer[id][PLAYER_INT] += pointsDistributionAmount;
				codPlayer[id][PLAYER_POINTS] -= pointsDistributionAmount;

			} else chat_print(id, "%L", id, "CORE_POINTS_INTELLIGENCE_MAX");
		} case 3: {
			if (!statsLimit || codPlayer[id][PLAYER_STR] < statsLimit) {
				if (statsLimit && pointsDistributionAmount > statsLimit - codPlayer[id][PLAYER_STR]) pointsDistributionAmount = statsLimit - codPlayer[id][PLAYER_STR];

				codPlayer[id][PLAYER_STR] += pointsDistributionAmount;
				codPlayer[id][PLAYER_POINTS] -= pointsDistributionAmount;
			} else chat_print(id, "%L", id, "CORE_POINTS_STRENGTH_MAX");
		} case 4: {
			if (!statsLimit || codPlayer[id][PLAYER_STAM] < statsLimit) {
				if (statsLimit && pointsDistributionAmount > statsLimit - codPlayer[id][PLAYER_STAM]) pointsDistributionAmount = statsLimit - codPlayer[id][PLAYER_STAM];

				codPlayer[id][PLAYER_STAM] += pointsDistributionAmount;
				codPlayer[id][PLAYER_POINTS] -= pointsDistributionAmount;
			} else chat_print(id, "%L", id, "CORE_POINTS_STAMINA_MAX");
		} case 5: {
			if (!statsLimit || codPlayer[id][PLAYER_COND] < statsLimit) {
				if (statsLimit && pointsDistributionAmount > statsLimit - codPlayer[id][PLAYER_COND]) pointsDistributionAmount = statsLimit - codPlayer[id][PLAYER_COND];

				codPlayer[id][PLAYER_COND] += pointsDistributionAmount;
				codPlayer[id][PLAYER_POINTS] -= pointsDistributionAmount;
			} else chat_print(id, "%L", id, "CORE_POINTS_CONDITION_MAX");
		}
	}

	if (item) save_data(id, NORMAL);

	menu_destroy(menu);

	if (codPlayer[id][PLAYER_POINTS] > 0) assign_points(id, 1);

	return PLUGIN_HANDLED;
}

public change_hud(id, sound)
{
	if (!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	if (!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128];

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_HUD_TITLE");

	new menu = menu_create(menuData, "change_hud_handle");

	format(menuData, charsmax(menuData), "%L", id, "CORE_HUD_RED", codPlayer[id][PLAYER_HUD_RED]);
	menu_additem(menu, menuData);

	format(menuData, charsmax(menuData), "%L", id, "CORE_HUD_GREEN", codPlayer[id][PLAYER_HUD_GREEN]);
	menu_additem(menu, menuData);

	format(menuData, charsmax(menuData), "%L", id, "CORE_HUD_BLUE", codPlayer[id][PLAYER_HUD_BLUE]);
	menu_additem(menu, menuData);

	format(menuData, charsmax(menuData), "%L", id, "CORE_HUD_POSITION_X", codPlayer[id][PLAYER_HUD_POSX]);
	menu_additem(menu, menuData);

	format(menuData, charsmax(menuData), "%L", id, "CORE_HUD_POSITION_Y", codPlayer[id][PLAYER_HUD_POSY]);
	menu_additem(menu, menuData);

	format(menuData, charsmax(menuData), "%L", id, "CORE_HUD_DEFAULT");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public change_hud_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	switch (item) {
		case 0: if ((codPlayer[id][PLAYER_HUD_RED] += 15) > 255) codPlayer[id][PLAYER_HUD_RED] = 0;
		case 1: if ((codPlayer[id][PLAYER_HUD_GREEN] += 15) > 255) codPlayer[id][PLAYER_HUD_GREEN] = 0;
		case 2: if ((codPlayer[id][PLAYER_HUD_BLUE] += 15) > 255) codPlayer[id][PLAYER_HUD_BLUE] = 0;
		case 3: if ((codPlayer[id][PLAYER_HUD_POSX] += 3) > 100) codPlayer[id][PLAYER_HUD_POSX] = 0;
		case 4: if ((codPlayer[id][PLAYER_HUD_POSY] += 3) > 100) codPlayer[id][PLAYER_HUD_POSY] = 0;
		case 5: {
			codPlayer[id][PLAYER_HUD_RED] = 0;
			codPlayer[id][PLAYER_HUD_GREEN] = 255;
			codPlayer[id][PLAYER_HUD_BLUE] = 0;
			codPlayer[id][PLAYER_HUD_POSX] = 70;
			codPlayer[id][PLAYER_HUD_POSY] = 6;
		}
	}

	menu_destroy(menu);

	save_hud(id);

	change_hud(id, 1);

	return PLUGIN_CONTINUE;
}

public save_hud(id)
{
	new tempData[256];

	if (!get_bit(id, hudLoaded)) {
		formatex(tempData, charsmax(tempData), "INSERT IGNORE INTO `cod_mod` (`name`, `class`, `level`, `exp`, `intelligence`, `health`, `stamina`) VALUES (^"%s^", 'hud', '%i', '%i', '%i', '%i', '%i')",
			codPlayer[id][PLAYER_NAME], codPlayer[id][PLAYER_HUD_RED], codPlayer[id][PLAYER_HUD_GREEN], codPlayer[id][PLAYER_HUD_BLUE], codPlayer[id][PLAYER_HUD_POSX], codPlayer[id][PLAYER_HUD_POSY]);
	} else {
		formatex(tempData, charsmax(tempData), "UPDATE `cod_mod` SET `level` = '%i', `exp` = '%i', `intelligence` = '%i', `health` = '%i', `stamina` = '%i' WHERE `class` = 'hud' AND `name` = ^"%s^"",
			codPlayer[id][PLAYER_HUD_RED], codPlayer[id][PLAYER_HUD_GREEN], codPlayer[id][PLAYER_HUD_BLUE], codPlayer[id][PLAYER_HUD_POSX], codPlayer[id][PLAYER_HUD_POSY], codPlayer[id][PLAYER_NAME]);
	}

	SQL_ThreadQuery(sql, "ignore_handle", tempData);
}

public show_binds(id, sound)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128];

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_TITLE");

	new menu = menu_create(menuData, "show_binds_handle");

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_ROCKET");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_MINE");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_DYNAMITE");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_THUNDER");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_MEDKIT");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_POISON");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_TELEPORT");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_CLASS");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_ITEM");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_INFO");
	menu_addtext(menu, menuData, 0);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_INFO2");
	menu_addtext(menu, menuData, 0);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_INFO3");
	menu_addtext(menu, menuData, 0);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_BINDS_INFO4");
	menu_addtext(menu, menuData, 0);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public show_binds_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	show_binds(id, 0);

	menu_destroy(menu);

	return PLUGIN_CONTINUE;
}

public level_top(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[128], tempId[1];

	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT name, class, level, exp FROM `cod_mod` ORDER BY exp DESC LIMIT 15");

	SQL_ThreadQuery(sql, "show_level_top", queryData, tempId, sizeof tempId);

	return PLUGIN_HANDLED;
}

public show_level_top(failState, Handle:query, error[], errorNum, tempData[], dataSize)
{
	if (failState)  {
		if (failState == TQUERY_CONNECT_FAILED) log_to_file(LOG_FILE, "[%s] Could not connect to SQL database. Error: %s (%d)", PLUGIN, error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) log_to_file(LOG_FILE, "[%s] Threaded query failed. Error: %s (%d)", PLUGIN, error, errorNum);

		return PLUGIN_HANDLED;
	}

	new id = tempData[0];

	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new const rankColors[][] = { "#FFCC33", "#CCFFFF", "#8B4513" };

	static motdData[2048], name[MAX_NAME], class[MAX_NAME], motdLength, rank, level, exp;

	rank = 0;

	motdLength = format(motdData, charsmax(motdData), "<html><body bgcolor=^"#666666^"><center><table style=^"color:#FFFFFF;width:600%^">");
	motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "%L", id, "CORE_TOP15_TABLE");

	while (SQL_MoreResults(query)) {
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "name"), name, charsmax(name));
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "class"), class, charsmax(class));

		level = SQL_ReadResult(query, SQL_FieldNameToNum(query, "level"));
		exp = SQL_ReadResult(query, SQL_FieldNameToNum(query, "exp"));

		replace_all(name, charsmax(name), "<", "");
		replace_all(name, charsmax(name), ">", "");

		if (rank < sizeof rankColors) motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "<tr style=color:%s;font-weight:bold;><td>%i.<td>%s<td>%s<td>%i<td>%i", rankColors[rank], rank + 1, name, class, level, exp);
		else motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "<tr><td>%i.<td>%s<td>%s<td>%i<td>%i", rank + 1, name, class, level, exp);

		rank++;

		SQL_NextRow(query);
	}

	formatex(name, charsmax(name), "%L", id, "CORE_TOP15_TITLE");

	show_motd(id, motdData, name);

	return PLUGIN_HANDLED;
}

public block_command()
	return PLUGIN_HANDLED;

public bind_use_rocket(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id) || codPlayer[id][SKILL_USE] > NONE) return PLUGIN_HANDLED;

	use_rocket(id);

	return PLUGIN_HANDLED;
}

public use_rocket(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id)) return PLUGIN_HANDLED;

	if (!codPlayer[id][PLAYER_ROCKETS][ALL]) {
		set_dhudmessage(0, 255, 210, -1.0, 0.2, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_ROCKETS_USED");

		return PLUGIN_HANDLED;
	}

	if (codPlayer[id][PLAYER_LAST_ROCKET] + 3.0 > get_gametime()) {
		set_dhudmessage(0, 255, 210, -1.0, 0.2, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_ROCKETS_TIME");

		return PLUGIN_HANDLED;
	}

	codPlayer[id][SKILL_USE] = 0;

	codPlayer[id][PLAYER_LAST_ROCKET] = get_gametime();
	codPlayer[id][PLAYER_ROCKETS][ALL]--;
	codPlayer[id][PLAYER_ROCKETS][USED]++;

	new Float:origin[3], Float:angle[3], Float:velocity[3];

	entity_get_vector(id, EV_VEC_v_angle, angle);
	entity_get_vector(id, EV_VEC_origin, origin);

	new ent = create_entity("info_target");

	entity_set_string(ent, EV_SZ_classname, "rocket");
	entity_set_model(ent, codModels[MODEL_ROCKET]);

	angle[0] *= -1.0;

	entity_set_origin(ent, origin);
	entity_set_vector(ent, EV_VEC_angles, angle);

	entity_set_int(ent, EV_INT_effects, 2);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_edict(ent, EV_ENT_owner, id);

	VelocityByAim(id, 1000, velocity);

	entity_set_vector(ent, EV_VEC_velocity, velocity);

	emit_sound(id, CHAN_WEAPON, codSounds[SOUND_DEPLOY], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_HANDLED;
}

public touch_rocket(ent)
{
	if (!is_valid_ent(ent)) return;

	make_explosion(ent, 0, 1, 190.0, 65.0, 0.5, _, ROCKET_EXPLODE);

	remove_entity(ent);
}

public bind_use_mine(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id) || codPlayer[id][SKILL_USE] > NONE) return PLUGIN_HANDLED;

	use_mine(id);

	return PLUGIN_HANDLED;
}

public use_mine(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id)) return PLUGIN_HANDLED;

	if (!codPlayer[id][PLAYER_MINES][ALL]) {
		set_dhudmessage(0, 255, 210, -1.0, 0.23, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_MINES_USED");

		return PLUGIN_HANDLED;
	}

	if (codPlayer[id][PLAYER_LAST_MINE] + 3.0 > get_gametime()) {
		set_dhudmessage(0, 255, 210, -1.0, 0.23, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_MINES_TIME");

		return PLUGIN_HANDLED;
	}

	if (!(pev(id, pev_flags) & FL_ONGROUND)) {
		set_dhudmessage(0, 255, 210, -1.0, 0.23, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_MINES_GROUND");

		return PLUGIN_HANDLED;
	}

	if (!is_enough_space(id, 80.0)) {
		set_dhudmessage(0, 255, 210, -1.0, 0.23, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_MINES_PASSAGE");

		return PLUGIN_HANDLED;
	}

	codPlayer[id][SKILL_USE] = 0;

	codPlayer[id][PLAYER_LAST_MINE] = get_gametime();
	codPlayer[id][PLAYER_MINES][ALL]--;
	codPlayer[id][PLAYER_MINES][USED]++;

	new Float:origin[3], ent = create_entity("info_target");

	entity_get_vector(id, EV_VEC_origin, origin);

	entity_set_string(ent, EV_SZ_classname, "mine");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, origin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);

	entity_set_model(ent, codModels[MODEL_MINE]);
	entity_set_size(ent, Float:{ -16.0, -16.0, 0.0 }, Float:{ 16.0, 16.0, 2.0 });

	drop_to_floor(ent);

	set_rendering(ent, kRenderFxNone, 0, 0, 0, kRenderTransTexture, 50);

	emit_sound(id, CHAN_WEAPON, codSounds[SOUND_ACTIVATE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_HANDLED;
}

public touch_mine(ent, victim)
{
	if (!is_valid_ent(ent)) return;

	new id = entity_get_edict(ent, EV_ENT_owner);

	if (get_user_team(victim) == get_user_team(id)) return;

	make_explosion(ent, 0, 1, 90.0, 75.0, 0.5, _, MINE_EXPLODE);

	remove_entity(ent);
}

public bind_use_dynamite(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id) || codPlayer[id][SKILL_USE] > NONE) return PLUGIN_HANDLED;

	use_dynamite(id);

	return PLUGIN_HANDLED;
}

public use_dynamite(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id)) return PLUGIN_HANDLED;

	if (is_valid_ent(codPlayer[id][PLAYER_DYNAMITE])) {
		make_explosion(codPlayer[id][PLAYER_DYNAMITE], 250, 1, 250.0, 70.0, 0.5, _, DYNAMITE_EXPLODE);

		remove_entity(codPlayer[id][PLAYER_DYNAMITE]);

		codPlayer[id][SKILL_USE] = 0;
		codPlayer[id][PLAYER_DYNAMITE] = 0;

		return PLUGIN_HANDLED;
	}

	if (!codPlayer[id][PLAYER_DYNAMITES][ALL]) {
		set_dhudmessage(0, 255, 210, -1.0, 0.26, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_DYNAMITES_USED");

		return PLUGIN_HANDLED;
	}

	if (codPlayer[id][PLAYER_LAST_DYNAMITE] + 3.0 > get_gametime()) {
		set_dhudmessage(0, 255, 210, -1.0, 0.26, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_DYNAMITES_TIME");

		return PLUGIN_HANDLED;
	}

	if (!(pev(id, pev_flags) & FL_ONGROUND)) {
		set_dhudmessage(0, 255, 210, -1.0, 0.26, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_DYNAMITES_GROUND");

		return PLUGIN_HANDLED;
	}

	codPlayer[id][SKILL_USE] = 0;

	codPlayer[id][PLAYER_LAST_DYNAMITE] = get_gametime();
	codPlayer[id][PLAYER_DYNAMITES][ALL]--;
	codPlayer[id][PLAYER_DYNAMITES][USED]++;

	new Float:origin[3], ent = create_entity("info_target");

	entity_get_vector(id, EV_VEC_origin, origin);

	codPlayer[id][PLAYER_DYNAMITE] = ent;

	entity_set_string(ent, EV_SZ_classname, "dynamite");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, origin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);

	entity_set_model(ent, codModels[MODEL_DYNAMITE]);
	entity_set_size(ent, Float:{ -16.0, -16.0, 0.0 }, Float:{ 16.0, 16.0, 2.0 });

	drop_to_floor(ent);

	emit_sound(id, CHAN_WEAPON, codSounds[SOUND_ACTIVATE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_HANDLED;
}

public bind_use_medkit(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id) || codPlayer[id][SKILL_USE] > NONE) return PLUGIN_HANDLED;

	use_medkit(id);

	return PLUGIN_HANDLED;
}

public use_medkit(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id)) return PLUGIN_HANDLED;

	if (!codPlayer[id][PLAYER_MEDKITS][ALL]) {
		set_dhudmessage(0, 255, 210, -1.0, 0.29, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_MEDKITS_USED");

		return PLUGIN_HANDLED;
	}

	if (codPlayer[id][PLAYER_LAST_MEDKIT] + 3.0 > get_gametime()) {
		set_dhudmessage(0, 255, 210, -1.0, 0.29, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_MEDKITS_TIME");

		return PLUGIN_HANDLED;
	}

	codPlayer[id][SKILL_USE] = 0;

	codPlayer[id][PLAYER_LAST_MEDKIT] = get_gametime();
	codPlayer[id][PLAYER_MEDKITS][ALL]--;
	codPlayer[id][PLAYER_MEDKITS][USED]++;

	new Float:origin[3], ent = create_entity("info_target");

	entity_get_vector(id, EV_VEC_origin, origin);

	entity_set_string(ent, EV_SZ_classname, "medkit");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + 7 + 0.1);

	entity_set_model(ent, codModels[MODEL_MEDKIT]);
	set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderFxNone, 120);
	drop_to_floor(ent);

	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);

	emit_sound(id, CHAN_WEAPON, codSounds[SOUND_ACTIVATE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_HANDLED;
}

public think_medkit(ent)
{
	if (!is_valid_ent(ent)) return PLUGIN_CONTINUE;

	new id = entity_get_edict(ent, EV_ENT_owner);

	if (entity_get_edict(ent, EV_ENT_euser2) == 1) {
		new Float:origin[3];

		entity_get_vector(ent, EV_VEC_origin, origin);

		make_explosion(ent, 300, 0, 300.0, -5.0, 0.5, _, MEDKIT_HEAL);

		entity_set_edict(ent, EV_ENT_euser2, 0);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.25);

		return PLUGIN_CONTINUE;
	}

	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id)) {
		remove_entity(ent);

		return PLUGIN_CONTINUE;
	}

	if (entity_get_float(ent, EV_FL_ltime) - 0.5 < halflife_time()) {
		set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAlpha, 100);
	}

	make_explosion(ent, 300, 0);

	entity_set_edict(ent, EV_ENT_euser2, 1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);

	return PLUGIN_CONTINUE;
}

public bind_use_poison(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id) || codPlayer[id][SKILL_USE] > NONE) return PLUGIN_HANDLED;

	use_poison(id);

	return PLUGIN_HANDLED;
}

public use_poison(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id)) return PLUGIN_HANDLED;

	if (!codPlayer[id][PLAYER_POISONS][ALL]) {
		set_dhudmessage(0, 255, 210, -1.0, 0.32, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_POISONS_USED");

		return PLUGIN_HANDLED;
	}

	if (codPlayer[id][PLAYER_LAST_POISON] + 3.0 > get_gametime()) {
		set_dhudmessage(0, 255, 210, -1.0, 0.32, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_POISONS_TIME");

		return PLUGIN_HANDLED;
	}

	codPlayer[id][SKILL_USE] = 0;

	codPlayer[id][PLAYER_LAST_POISON] = get_gametime();
	codPlayer[id][PLAYER_POISONS][ALL]--;
	codPlayer[id][PLAYER_POISONS][USED]++;

	new Float:origin[3], ent = create_entity("info_target");

	entity_get_vector(id, EV_VEC_origin, origin);

	entity_set_string(ent, EV_SZ_classname, "poison");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + 7 + 0.1);

	entity_set_model(ent, codModels[MODEL_POISON]);
	set_rendering(ent, kRenderFxGlowShell, 0, 255, 0, kRenderFxNone, 120);
	drop_to_floor(ent);

	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);

	emit_sound(id, CHAN_WEAPON, codSounds[SOUND_ACTIVATE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_HANDLED;
}

public think_poison(ent)
{
	if (!is_valid_ent(ent)) return PLUGIN_CONTINUE;

	new id = entity_get_edict(ent, EV_ENT_owner);

	if (entity_get_edict(ent, EV_ENT_euser2) == 1) {
		new Float:origin[3];

		entity_get_vector(ent, EV_VEC_origin, origin);

		make_explosion(ent, 300, 0, 300.0, 1.0, 0.5, _, POISON_INFECT);

		entity_set_edict(ent, EV_ENT_euser2, 0);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.25);

		return PLUGIN_CONTINUE;
	}

	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id)) {
		remove_entity(ent);

		return PLUGIN_CONTINUE;
	}

	if (entity_get_float(ent, EV_FL_ltime) - 0.5 < halflife_time()) {
		set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAlpha, 100);
	}

	make_explosion(ent, 300, 0, .type=POISON_INFECT);

	entity_set_edict(ent, EV_ENT_euser2, 1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);

	return PLUGIN_CONTINUE;
}

public bind_use_thunder(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id) || codPlayer[id][SKILL_USE] > NONE) return PLUGIN_HANDLED;

	use_thunder(id);

	return PLUGIN_HANDLED;
}

public use_thunder(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id)) return PLUGIN_HANDLED;

	if (!codPlayer[id][PLAYER_THUNDERS][ALL]) {
		set_dhudmessage(0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_THUNDERS_USED");

		return PLUGIN_HANDLED;
	}

	new victim, body, ret;

	get_user_aiming(id, victim, body);

	if (!is_user_alive(victim) || get_user_team(victim) == get_user_team(id)) return PLUGIN_HANDLED;

	if (codPlayer[id][PLAYER_LAST_THUNDER] + 3.0 > get_gametime()) {
		set_dhudmessage(0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_THUNDERS_TIME");

		return PLUGIN_HANDLED;
	}

	codPlayer[id][SKILL_USE] = 0;

	codPlayer[id][PLAYER_LAST_THUNDER] = get_gametime();
	codPlayer[id][PLAYER_THUNDERS][ALL]--;
	codPlayer[id][PLAYER_THUNDERS][USED]++;

	new ent = create_entity("info_target");

	entity_set_string(ent, EV_SZ_classname, "thunder");

	remove_entity(ent);

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMENTS);
	write_short(id);
	write_short(victim);
	write_short(codSprite[SPRITE_THUNDER]);
	write_byte(0);
	write_byte(10);
	write_byte(5);
	write_byte(150);
	write_byte(5);
	write_byte(200);
	write_byte(200);
	write_byte(200);
	write_byte(200);
	write_byte(10);
	message_end();

	emit_sound(id, CHAN_WEAPON, codSounds[SOUND_THUNDER], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	emit_sound(victim, CHAN_WEAPON, codSounds[SOUND_THUNDER], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	ExecuteForward(codForwards[THUNDER_REACH], ret, id, victim, 65.0 + get_intelligence(id) * 0.5);

	if (float(ret) != COD_BLOCK) {
		_cod_inflict_damage(id, victim, 65.0, 0.5, DMG_CODSKILL | DMG_THUNDER);

		codPlayer[id][PLAYER_LAST_THUNDER] += ret;
	}

	return PLUGIN_HANDLED;
}

public bind_use_teleport(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id) || codPlayer[id][SKILL_USE] > NONE) return PLUGIN_HANDLED;

	use_teleport(id);

	return PLUGIN_HANDLED;
}

public use_teleport(id)
{
	if (!is_user_alive(id) || freezeTime || skills_blocked(id)) return PLUGIN_HANDLED;

	if (codPlayer[id][PLAYER_TELEPORTS][ALL] == 0) {
		set_dhudmessage(0, 255, 210, -1.0, 0.38, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_TELEPORTS_USED");

		return PLUGIN_HANDLED;
	}

	if (roundStart + 15.0 > get_gametime()) {
		set_dhudmessage(0, 255, 210, -1.0, 0.38, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_TELEPORTS_ROUND");

		return PLUGIN_HANDLED;
	}

	if (codPlayer[id][PLAYER_LAST_TELEPORT] + 15.0 > get_gametime()) {
		set_dhudmessage(0, 255, 210, -1.0, 0.38, 0, 0.0, 1.25, 0.0, 0.0);
		show_dhudmessage(id, "%L", id, "CORE_TELEPORTS_TIME");

		return PLUGIN_HANDLED;
	}

	new Float:start[3], Float:view[3], Float:end[3];
	pev(id, pev_origin, start);

	pev(id, pev_view_ofs, view);
	xs_vec_add(start, view, start);

	pev(id, pev_v_angle, end);
	engfunc(EngFunc_MakeVectors, end);
	global_get(glb_v_forward, end);
	xs_vec_mul_scalar(end, 2500.0, end);
	xs_vec_add(start, end, end);

	engfunc(EngFunc_TraceLine, start, end, 0, id, 0);

	new Float:dest[3];
	get_tr2(0, TR_vecEndPos, dest);

	if (engfunc(EngFunc_PointContents, dest) == CONTENTS_SKY) return PLUGIN_HANDLED;

	codPlayer[id][SKILL_USE] = 0;
	codPlayer[id][PLAYER_LAST_TELEPORT] = get_gametime();

	if (codPlayer[id][PLAYER_TELEPORTS][ALL] != FULL) {
		codPlayer[id][PLAYER_TELEPORTS][ALL]--;
		codPlayer[id][PLAYER_TELEPORTS][USED]++;
	}

	new Float:normal[3];
	get_tr2(0, TR_vecPlaneNormal, normal);

	xs_vec_mul_scalar(normal, 50.0, normal);
	xs_vec_add(dest, normal, dest);

	set_pev(id, pev_origin, dest);

	check_if_player_stuck(id);

	new ret;

	ExecuteForward(codForwards[TELEPORT_USED], ret, id);

	if (ret > 0) codPlayer[id][PLAYER_LAST_TELEPORT] += ret;

	return PLUGIN_HANDLED;
}

public use_item(id)
{
	if (!is_user_alive(id) || !codPlayer[id][PLAYER_ITEM] || freezeTime || skills_blocked(id)) return PLUGIN_HANDLED;

	execute_forward_ignore_one_param(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_SKILL_USED), id);

	return PLUGIN_HANDLED;
}

public use_class(id)
{
	if (!is_user_alive(id) || !codPlayer[id][PLAYER_CLASS] || freezeTime || skills_blocked(id)) return PLUGIN_CONTINUE;

	execute_forward_ignore_one_param(get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_SKILL_USED), id);

	return PLUGIN_CONTINUE;
}

public skills_blocked(id)
{
	if (skillsBlocked) {
		set_task(0.1, "show_block_info", id + TASK_BLOCK_INFO, .flags = "b");

		return true;
	} else if (task_exists(id + TASK_BLOCK_INFO)) {
		client_print(id, print_center, "");

		remove_task(id + TASK_BLOCK_INFO);
	}

	return false;
}

public show_block_info(id)
{
	id -= TASK_BLOCK_INFO;

	new Float:currentTime = (roundStart + cvarBlockSkillsTime) - get_gametime();

	if (currentTime <= 0.0) {
		client_print(id, print_center, "");

		remove_task(id + TASK_BLOCK_INFO);

		return;
	}

	client_print(id, print_center, "%L", id, "CORE_BLOCK_INFO", currentTime);
}

public player_spawn(id)
{
	codPlayer[id][PLAYER_ALIVE] = true;

	if (!cod_check_account(id)) return PLUGIN_HANDLED;

	if (codPlayer[id][PLAYER_NEW_CLASS] != NONE) set_new_class(id);

	if (!codPlayer[id][PLAYER_CLASS]) {
		select_faction(id);

		return PLUGIN_CONTINUE;
	}

	if (!codPlayer[id][PLAYER_SPAWNED]) reset_attributes(id, ROUND);

	if (get_bit(id, resetStats)) reset_points(id);

	if (codPlayer[id][PLAYER_POINTS] > 0) assign_points(id, 0);

	if (codPlayer[id][PLAYER_CLASS]) execute_forward_ignore_two_params(get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_SPAWNED), id, codPlayer[id][PLAYER_SPAWNED]);
	if (codPlayer[id][PLAYER_ITEM]) execute_forward_ignore_two_params(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_SPAWNED), id, codPlayer[id][PLAYER_SPAWNED]);

	execute_forward_ignore_two_params(codForwards[SPAWNED], id, codPlayer[id][PLAYER_SPAWNED]);

	codPlayer[id][PLAYER_SPAWNED] = true;

	set_task(0.1, "set_attributes", id);

	return PLUGIN_CONTINUE;
}

public player_take_damage_pre(victim, inflictor, attacker, Float:damage, damageBits)
{
	if (!is_user_connected(attacker) || !is_user_connected(victim) || get_user_team(attacker) == get_user_team(victim)) return HAM_IGNORED;

	static function, weapon, hitPlace, Float:baseDamage;

	weapon = codPlayer[attacker][PLAYER_WEAPON];

	if (!(0 < inflictor <= MAX_PLAYERS)) weapon = CSW_HEGRENADE;

	hitPlace = get_pdata_int(victim, 75, 5);
	codPlayer[victim][HIT_PLACE][attacker] = hitPlace;

	if (codPlayer[victim][PLAYER_CLASS]) {
		damage -= damage * (get_stamina(victim) / 4.0) / 100.0;

		function = get_class_info(codPlayer[victim][PLAYER_CLASS], CLASS_DAMAGE_VICTIM);

		if (function != NONE) {
			callfunc_begin_i(function, get_class_info(codPlayer[victim][PLAYER_CLASS], CLASS_PLUGIN));
			callfunc_push_int(attacker);
			callfunc_push_int(victim);
			callfunc_push_int(weapon);
			callfunc_push_floatrf(damage);
			callfunc_push_int(damageBits);
			callfunc_push_int(hitPlace);
			callfunc_end();

			if (damage == COD_BLOCK) {
				SetHamParamFloat(4, 0.0);

				return HAM_SUPERCEDE;
			}
		}
	}

	if (codPlayer[victim][PLAYER_ITEM]) {
		function = get_item_info(codPlayer[victim][PLAYER_ITEM], ITEM_DAMAGE_VICTIM);

		if (function != NONE) {
			callfunc_begin_i(function, get_item_info(codPlayer[victim][PLAYER_ITEM], ITEM_PLUGIN));
			callfunc_push_int(attacker);
			callfunc_push_int(victim);
			callfunc_push_int(weapon);
			callfunc_push_floatrf(damage);
			callfunc_push_int(damageBits);
			callfunc_push_int(hitPlace);
			callfunc_end();

			if (damage == COD_BLOCK) {
				SetHamParamFloat(4, 0.0);

				return HAM_SUPERCEDE;
			}
		}
	}

	if (codPlayer[attacker][PLAYER_CLASS]) {
		baseDamage = damage += get_strength(attacker) / 10.0;

		function = get_class_info(codPlayer[attacker][PLAYER_CLASS], CLASS_DAMAGE_ATTACKER);

		if (function != NONE) {
			callfunc_begin_i(function, get_class_info(codPlayer[attacker][PLAYER_CLASS], CLASS_PLUGIN));
			callfunc_push_int(attacker);
			callfunc_push_int(victim);
			callfunc_push_int(weapon);
			callfunc_push_floatrf(damage);
			callfunc_push_int(damageBits);
			callfunc_push_int(hitPlace);
			callfunc_end();

			if (damage == COD_BLOCK) {
				SetHamParamFloat(4, 0.0);

				return HAM_SUPERCEDE;
			} else if (codPlayer[victim][PLAYER_RESISTANCE][ALL]) {
				damage = baseDamage;
			}
		}
	}

	if (codPlayer[attacker][PLAYER_ITEM]) {
		baseDamage = damage;

		function = get_item_info(codPlayer[attacker][PLAYER_ITEM], ITEM_DAMAGE_ATTACKER);

		if (function != NONE) {
			callfunc_begin_i(function, get_item_info(codPlayer[attacker][PLAYER_ITEM], ITEM_PLUGIN));
			callfunc_push_int(attacker);
			callfunc_push_int(victim);
			callfunc_push_int(weapon);
			callfunc_push_floatrf(damage);
			callfunc_push_int(damageBits);
			callfunc_push_int(hitPlace);
			callfunc_end();

			if (damage == COD_BLOCK) {
				SetHamParamFloat(4, 0.0);

				return HAM_SUPERCEDE;
			} else if (codPlayer[victim][PLAYER_RESISTANCE][ALL]) {
				damage = baseDamage;
			}
		}
	}

	static ret;

	ExecuteForward(codForwards[DAMAGE_PRE], ret, attacker, victim, weapon, damage, damageBits, hitPlace);

	if (damage <= 0.0 || float(ret) == COD_BLOCK) {
		SetHamParamFloat(4, 0.0);

		return HAM_SUPERCEDE;
	}

	SetHamParamFloat(4, damage);

	return HAM_HANDLED;
}

public player_take_damage_post(victim, inflictor, attacker, Float:damage, damageBits)
{
	if (!is_user_connected(attacker) || !is_user_connected(victim) || !codPlayer[attacker][PLAYER_CLASS] || !codPlayer[victim][PLAYER_ALIVE] || get_user_team(victim) == get_user_team(attacker) || damage <= 0.0) return HAM_IGNORED;

	static ret, weapon, hitPlace;

	weapon = codPlayer[attacker][PLAYER_WEAPON];

	if (!(0 < inflictor <= MAX_PLAYERS)) weapon = CSW_HEGRENADE;

	hitPlace = get_pdata_int(victim, 75, 5);
	codPlayer[victim][HIT_PLACE][attacker] = hitPlace;

	ExecuteForward(codForwards[DAMAGE_POST], ret, attacker, victim, weapon, damage, damageBits, hitPlace);

	while (cvarExpDamagePer && damage > cvarExpDamagePer) {
		damage -= cvarExpDamagePer;

		codPlayer[attacker][PLAYER_GAINED_EXP] += get_exp_bonus(attacker, cvarExpDamage);
	}

	if (!codPlayer[victim][PLAYER_ALIVE]) return HAM_IGNORED;

	check_level(attacker);

	if (get_user_health(victim) <= 0) {
		codPlayer[victim][PLAYER_ALIVE] = false;

		player_death(attacker, victim, weapon, hitPlace);
	} else if (!codPlayer[victim][PLAYER_DAMAGE_TAKEN]) {
		codPlayer[victim][PLAYER_DAMAGE_TAKEN] = true;

		reset_attributes(victim, DAMAGE_TAKEN);
	}

	if (!codPlayer[attacker][PLAYER_DAMAGE_GIVEN]) {
		codPlayer[attacker][PLAYER_DAMAGE_GIVEN] = true;

		reset_attributes(attacker, DAMAGE_GIVEN);
	}

	return HAM_IGNORED;
}

public player_death(killer, victim, weapon, hitPlace)
{
	remove_task(victim + TASK_DEATH);

	new className[MAX_NAME], itemName[MAX_NAME];

	if (codPlayer[killer][PLAYER_CLASS] && get_playersnum() > cvarMinPlayers) {
		if (cvarExpKill || cvarExpKillHS) {
			new exp = get_exp_bonus(killer, hitPlace == HIT_HEAD ? (cvarExpKill + cvarExpKillHS) : cvarExpKill);

			if (codPlayer[victim][PLAYER_LEVEL] > codPlayer[killer][PLAYER_LEVEL]) exp += get_exp_bonus(killer, (codPlayer[victim][PLAYER_LEVEL] - codPlayer[killer][PLAYER_LEVEL]) * (cvarExpKill / 10));

			codPlayer[killer][PLAYER_GAINED_EXP] += exp;

			get_user_class_info(victim, codPlayer[victim][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));

			chat_print(killer, "Zabiles%s gracza^x03 %s^x04 (%s - %i)^x01, dostajesz^x03 %i^x01 doswiadczenia.", hitPlace == HIT_HEAD ? " z HS" : "", codPlayer[victim][PLAYER_NAME], className, codPlayer[victim][PLAYER_LEVEL], exp);

			set_dhudmessage(255, 206, 85, -1.0, 0.6, 0, 0.0, 2.0, 0.0, 0.0);
			show_dhudmessage(killer, "+%i XP", exp);
		}

		if (cvarKillStreakTime) {
			codPlayer[killer][PLAYER_KS]++;
			codPlayer[killer][PLAYER_TIME_KS] = cvarKillStreakTime;

			if (task_exists(killer + TASK_END_KILL_STREAK)) remove_task(killer + TASK_END_KILL_STREAK);

			set_task(1.0, "end_kill_streak", killer + TASK_END_KILL_STREAK, _, _, "b");
		}
	} else {
		get_user_class_info(victim, codPlayer[victim][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));

		chat_print(killer, "Zabiles%s gracza^x03 %s^x04 (%s - %i)^x01.", hitPlace == HIT_HEAD ? " z HS" : "", codPlayer[victim][PLAYER_NAME], className, codPlayer[victim][PLAYER_LEVEL]);
	}

	get_user_class_info(killer, codPlayer[killer][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));

	if (!codPlayer[killer][PLAYER_ITEM]) {
		set_item(killer, RANDOM, RANDOM);

		chat_print(victim, "Zostales zabity przez^x03 %s^x04 (%s - %i)^x01, ktoremu zostalo^x04 %i^x01 HP.", codPlayer[killer][PLAYER_NAME], className, codPlayer[killer][PLAYER_LEVEL], get_user_health(killer));
	} else {
		get_item_info(codPlayer[killer][PLAYER_ITEM], ITEM_NAME, itemName, charsmax(itemName));

		chat_print(victim, "Zostales zabity przez^x03 %s^x04 (%s - %i - %s)^x01, ktoremu zostalo^x04 %i^x01 HP.", codPlayer[killer][PLAYER_NAME], className, codPlayer[killer][PLAYER_LEVEL], itemName, get_user_health(killer));
	}

	check_level(killer);

	if (codPlayer[killer][PLAYER_CLASS]) execute_forward_ignore_three_params(get_class_info(codPlayer[killer][PLAYER_CLASS], CLASS_KILL), killer, victim, hitPlace);
	if (codPlayer[killer][PLAYER_ITEM]) execute_forward_ignore_three_params(get_item_info(codPlayer[killer][PLAYER_ITEM], ITEM_KILL), killer, victim, hitPlace);
	if (codPlayer[victim][PLAYER_CLASS]) execute_forward_ignore_three_params(get_class_info(codPlayer[victim][PLAYER_CLASS], CLASS_KILLED), killer, victim, hitPlace);

	if (codPlayer[victim][PLAYER_ITEM]) {
		execute_forward_ignore_three_params(get_item_info(codPlayer[victim][PLAYER_ITEM], ITEM_KILLED), killer, victim, hitPlace);

		if (cvarMaxDurability) {
			codPlayer[victim][PLAYER_ITEM_DURA] -= random_num(cvarMinDamageDurability, cvarMaxDamageDurability);

			if (codPlayer[victim][PLAYER_ITEM_DURA] <= 0) {
				set_item(victim);

				chat_print(victim, "Twoj przedmiot ulegl zniszczeniu.");
			} else chat_print(victim, "Pozostala wytrzymalosc twojego przedmiotu to^x03 %i^x01/^x03%i^x01.", codPlayer[victim][PLAYER_ITEM_DURA], cvarMaxDurability);
		}
	}

	reset_attributes(victim, DEATH);

	new ret;

	ExecuteForward(codForwards[KILLED], ret, killer, victim, weapon, hitPlace);

	return PLUGIN_CONTINUE;
}

public touch_weapon(weapon, id)
{
	if (!is_user_connected(id)) return HAM_IGNORED;

	new modelName[23];

	pev(weapon, pev_model, modelName, charsmax(modelName));

	if (containi(modelName, "w_backpack") != NONE) return HAM_IGNORED;

	new playerTeam = get_user_team(id);

	if (playerTeam > 2) return HAM_IGNORED;

	pev(weapon, pev_classname, modelName, charsmax(modelName));

	new weaponType = ((modelName[0] == 'a') ? cs_get_armoury_type(weapon): cs_get_weaponbox_type(weapon));

	if ((1<<weaponType) & (codPlayer[id][PLAYER_WEAPONS] | codPlayer[id][PLAYER_EXTRA_WEAPONS] | allowedWeapons)) return HAM_IGNORED;

	return HAM_SUPERCEDE;
}

public speed_change(id)
{
	if (!is_user_alive(id) || freezeTime) return HAM_IGNORED;

	new Float:speed = Float:codPlayer[id][PLAYER_SPEED][ALL] == COD_FREEZE ? COD_FREEZE : (get_user_maxspeed(id) + Float:codPlayer[id][PLAYER_SPEED][ALL]);

	set_user_maxspeed(id, speed);

	static ret;

	ExecuteForward(codForwards[SPEED_CHANGED], ret, id, speed);

	return HAM_IGNORED;
}

public block_buyzone()
	return HAM_SUPERCEDE;

public weapon_deploy_post(ent)
{
	if (pev_valid(ent) != 2) return HAM_IGNORED;

	static id; id = get_pdata_cbase(ent, 41, 4);

	if (!is_user_alive(id)) return HAM_IGNORED;

	new weapon = codPlayer[id][PLAYER_WEAPON] = cs_get_weapon_id(ent);

	execute_forward_ignore_three_params(codForwards[WEAPON_DEPLOY], id, weapon, ent);

	render_change(id);

	return HAM_IGNORED;
}

public weapon_primary_attack_post(ent)
{
	if (pev_valid(ent) != 2) return HAM_IGNORED;

	new id = get_pdata_cbase(ent, 41, 4);

	if (!is_user_alive(id)) return HAM_IGNORED;

	if (codPlayer[id][PLAYER_ELIMINATOR][ALL] && (codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][ALL] == FULL || 1<<codPlayer[id][PLAYER_WEAPON] & codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][ALL])) {
		set_pev(id, pev_punchangle, {0.0, 0.0, 0.0});
	} else if (codPlayer[id][PLAYER_REDUCER][ALL] && (codPlayer[id][PLAYER_REDUCER_WEAPONS][ALL] == FULL || 1<<codPlayer[id][PLAYER_WEAPON] & codPlayer[id][PLAYER_REDUCER_WEAPONS][ALL])) {
		new Float:punchAngle[3];

		pev(id, pev_punchangle, punchAngle);

		for (new i = 0; i < 3; i++) punchAngle[i] *= 0.5;

		set_pev(id, pev_punchangle, punchAngle);
	}

	return HAM_IGNORED;
}

public team_assign()
{
	new teamName[16], id = read_data(1), team = 0;

	read_data(2, teamName, charsmax(teamName));

	if (equal(teamName, "UNASSIGNED")) team = 0;
	else if (equal(teamName, "TERRORIST")) team = 1;
	else if (equal(teamName, "CT")) team = 2;
	else if (equal(teamName, "SPECTATOR")) team = 3;

	execute_forward_ignore_two_params(codForwards[TEAM_ASSIGN], id, team);
}

public new_round()
{
	freezeTime = true;
	skillsBlocked = true;

	remove_ents();

	for (new i = 1; i <= MAX_PLAYERS; i++) {
		if (get_bit(i, glowActive)) reset_glow(i);

		codPlayer[i][PLAYER_SPAWNED] = false;

		for (new j = 1; j <= MAX_PLAYERS; j++) {
			remove_task(i + j + TASK_DAMAGE);

			codPlayer[i][HIT_PLACE][j] = HIT_GENERIC;
			codPlayer[j][HIT_PLACE][i] = HIT_GENERIC;
		}
	}

	execute_forward_ignore(codForwards[NEW_ROUND]);
}

public start_round()
{
	freezeTime = false;

	roundStart = floatround(get_gametime());

	remove_task(TASK_BLOCK);

	set_task(float(cvarBlockSkillsTime), "unblock_skills", TASK_BLOCK);

	for (new id = 1; id <= MAX_PLAYERS; id++) {
		if (!is_user_alive(id)) continue;

		display_fade(id, 1<<9, 1<<9, 1<<12, 0, 255, 70, 100);

		client_cmd(id, "spk %s", get_user_team(id) == 1 ? codSounds[SOUND_START2] : codSounds[SOUND_START]);

		if (cs_get_user_team(id) == CS_TEAM_CT) cs_set_user_defuse(id, 1);
	}

	execute_forward_ignore(codForwards[START_ROUND]);
}

public restart_round()
	execute_forward_ignore(codForwards[RESTART_ROUND]);

public end_round()
{
	execute_forward_ignore(codForwards[END_ROUND]);

	remove_task(TASK_BLOCK);
}

public unblock_skills()
	skillsBlocked = false;

public message_health(id)
{
	if (read_data(1) > 255) {
		message_begin(MSG_ONE, get_user_msgid("Health"), {0, 0, 0}, id);
		write_byte(255);
		message_end();
	}
}

public cur_weapon(id)
{
	if (!is_user_alive(id)) return;

	new weapon = read_data(2);

	if (!weapon || excludedWeapons & (1<<weapon)) return;

	execute_forward_ignore_two_params(codForwards[CUR_WEAPON], id, weapon);

	if (codPlayer[id][PLAYER_UNLIMITED_AMMO][ALL] && (codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][ALL] == FULL || 1<<codPlayer[id][PLAYER_WEAPON] & codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][ALL])) {
		set_pdata_int(get_pdata_cbase(id, 373), 51, maxClipAmmo[weapon], 4);
	}
}

public t_win_round()
	round_winner(1);

public ct_win_round()
	round_winner(2);

public round_winner(team)
{
	execute_forward_ignore_one_param(codForwards[WIN_ROUND], team);

	if (get_playersnum() < cvarMinPlayers || !cvarExpWinRound) return;

	for (new id = 1; id <= MAX_PLAYERS; id++) {
		if (!codPlayer[id][PLAYER_CLASS] || get_user_team(id) != team) continue;

		new exp = get_exp_bonus(id, cvarExpWinRound);

		codPlayer[id][PLAYER_GAINED_EXP] += exp;

		chat_print(id, "Dostales^x03 %i^x01 doswiadczenia za wygrana runde.", exp);

		check_level(id);
	}
}

public bomb_planting(id)
	execute_forward_ignore_one_param(codForwards[BOMB_PLANTING], id);

public bomb_planted(id)
{
	execute_forward_ignore_one_param(codForwards[BOMB_PLANTED], id);

	if (get_playersnum() < cvarMinPlayers || !codPlayer[id][PLAYER_CLASS] || !cvarExpPlant) return;

	new exp = get_exp_bonus(id, cvarExpPlant);

	codPlayer[id][PLAYER_GAINED_EXP] += exp;

	chat_print(id, "Dostales^x03 %i^x01 doswiadczenia za podlozenie bomby.", exp);

	check_level(id);
}

public bomb_defusing(id)
	execute_forward_ignore_one_param(codForwards[BOMB_DEFUSING], id);

public bomb_defused(id)
{
	execute_forward_ignore_one_param(codForwards[BOMB_DEFUSED], id);

	if (get_playersnum() < cvarMinPlayers || !codPlayer[id][PLAYER_CLASS] || !cvarExpDefuse) return;

	new exp = get_exp_bonus(id, cvarExpDefuse);

	codPlayer[id][PLAYER_GAINED_EXP] += exp;

	chat_print(id, "Dostales^x03 %i^x01 doswiadczenia za rozbrojenie bomby.", exp);

	check_level(id);
}

public bomb_explode(planter, defuser)
	execute_forward_ignore_two_params(codForwards[BOMB_EXPLODE], planter, defuser);

public bomb_dropped()
{
	new id = get_loguser_index();

	execute_forward_ignore_one_param(codForwards[BOMB_DROPPED], id);
}

public bomb_picked()
{
	new id = get_loguser_index();

	execute_forward_ignore_one_param(codForwards[BOMB_PICKED], id);
}

public hostage_killed()
{
	new id = get_loguser_index();

	execute_forward_ignore_one_param(codForwards[HOSTAGE_KILLED], id);
}

public hostage_rescued()
{
	new id = get_loguser_index();

	execute_forward_ignore_one_param(codForwards[HOSTAGE_RESCUED], id);

	if (get_playersnum() < cvarMinPlayers || !codPlayer[id][PLAYER_CLASS] || !cvarExpRescue) return;

	new exp = get_exp_bonus(id, cvarExpRescue);

	codPlayer[id][PLAYER_GAINED_EXP] += exp;

	chat_print(id, "Dostales^x03 %i^x01 doswiadczenia za uratowanie zakladnika.", exp);

	check_level(id);
}

public hostages_rescued()
{
	new id = get_loguser_index();

	execute_forward_ignore_one_param(codForwards[HOSTAGES_RESCUED], id);
}

stock render_change(id, playerStatus = NONE)
{
	if (!is_user_alive(id) || (codPlayer[id][PLAYER_STATUS] == playerStatus && playerStatus != NONE) || get_bit(id, renderTimer) || get_bit(id, glowActive)) return;

	if (playerStatus != NONE) codPlayer[id][PLAYER_STATUS] = playerStatus;

	static renderAmount; renderAmount = render_count(id);

	if (renderAmount != codPlayer[id][PLAYER_RENDER]) {
		codPlayer[id][PLAYER_RENDER] = renderAmount;

		set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, codPlayer[id][PLAYER_RENDER]);

		execute_forward_ignore_two_params(codForwards[RENDER_CHANGED], id, codPlayer[id][PLAYER_RENDER]);
	}
}

stock render_count(id, type = NONE)
{
	new render = 255, codRender[renderInfo];

	if (get_bit(id, glowActive)) return render;

	if (type == NONE) {
		for (new i = CLASS; i <= ADDITIONAL; i++) {
			ArrayGetArray(codPlayerRender[id], i, codRender);

			if (codRender[RENDER_VALUE] < 256 && (codPlayer[id][PLAYER_STATUS] & codRender[RENDER_STATUS]) && (codRender[RENDER_WEAPON] <= 0 || (1<<codPlayer[id][PLAYER_WEAPON] & codRender[RENDER_WEAPON])))
				render = codRender[RENDER_VALUE] < 0 ? (render - codRender[RENDER_VALUE]) : (codRender[RENDER_VALUE] < render ? codRender[RENDER_VALUE] : render);
		}

		for (new i = ROUND; i < ArraySize(codPlayerRender[id]); i++) {
			ArrayGetArray(codPlayerRender[id], i, codRender);

			if (codPlayer[id][PLAYER_STATUS] & codRender[RENDER_STATUS] && (codRender[RENDER_WEAPON] <= 0 || (1<<codPlayer[id][PLAYER_WEAPON] & codRender[RENDER_WEAPON])))
			render = codRender[RENDER_VALUE] < 0 ? (render - codRender[RENDER_VALUE]) : (codRender[RENDER_VALUE] < render ? codRender[RENDER_VALUE] : render);
		}
	} else {
		for (new i = 0; i < ArraySize(codPlayerRender[id]); i++) {
			ArrayGetArray(codPlayerRender[id], i, codRender);

			if (type != ALL && type != codRender[RENDER_TYPE]) continue;

			if (codRender[RENDER_VALUE] < 256 && codPlayer[id][PLAYER_STATUS] & codRender[RENDER_STATUS] && (codRender[RENDER_WEAPON] <= 0 || (1<<codPlayer[id][PLAYER_WEAPON] & codRender[RENDER_WEAPON])))
				render = codRender[RENDER_VALUE] < 0 ? (render - codRender[RENDER_VALUE]) : (codRender[RENDER_VALUE] < render ? codRender[RENDER_VALUE] : render);
		}
	}

	return max(0, render);
}

public cmd_start(id, ucHandle)
{
	if (!is_user_alive(id) || freezeTime || !codPlayer[id][PLAYER_CLASS]) return FMRES_IGNORED;

	if (codPlayer[id][SKILL_USE] > NONE) {
		if (codPlayer[id][SKILL_USE]++ > 128) {
			codPlayer[id][SKILL_USE] = NONE;
		}
	}

	static Float:velocity[3], Float:speed, button, oldButton, playerState, ret, flags;

	button = get_uc(ucHandle, UC_Buttons);
	oldButton = pev(id, pev_oldbuttons);
	flags = pev(id, pev_flags);
	playerState = RENDER_ALWAYS;

	pev(id, pev_velocity, velocity);

	speed = vector_length(velocity);

	if (get_user_maxspeed(id) > speed * 1.8) set_pev(id, pev_flTimeStepSound, 300);

	if (speed == 0.0) playerState |= RENDER_STAND;
	else playerState |= RENDER_MOVE;

	if (button & IN_DUCK) playerState |= RENDER_DUCK;

	if (pev(id, pev_gaitsequence) == 3) playerState |= RENDER_SHIFT;

	ExecuteForward(codForwards[CMD_START], ret, id, button, oldButton, flags, playerState);

	render_change(id, playerState);

	if (codPlayer[id][PLAYER_JUMPS][ALL]) {
		if ((button & IN_JUMP) && !(flags & FL_ONGROUND) && !(oldButton & IN_JUMP) && codPlayer[id][PLAYER_LEFT_JUMPS]) {
			codPlayer[id][PLAYER_LEFT_JUMPS]--;

			pev(id, pev_velocity, velocity);

			velocity[2] = random_float(265.0, 285.0);

			set_pev(id, pev_velocity, velocity);
		} else if (flags & FL_ONGROUND) codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS][ALL];
	}

	if (codPlayer[id][PLAYER_BUNNYHOP][ALL]) {
		entity_set_float(id, EV_FL_fuser2, 0.0);

		if (!(button & IN_JUMP) || flags & FL_WATERJUMP || entity_get_int(id, EV_INT_waterlevel) >= 2 || !(flags & FL_ONGROUND)) return FMRES_IGNORED;

		new Float:velocity[3];

		entity_get_vector(id, EV_VEC_velocity, velocity);

		velocity[2] += 250.0;

		entity_set_vector(id, EV_VEC_velocity, velocity);

		entity_set_int(id, EV_INT_gaitsequence, 6);
	}

	return FMRES_IGNORED;
}

public sound_emit(id, channel, sound[], Float:volume, Float:attn, flags, pitch)
{
	if (!is_user_alive(id) || !codPlayer[id][PLAYER_CLASS]) return FMRES_IGNORED;

	if (equal(sound, "common/wpn_denyselect.wav")) {
		use_class(id);

		return FMRES_SUPERCEDE;
	}

	if (equal(sound, "items/ammopickup2.wav")) {
		cs_set_user_armor(id, 0, CS_ARMOR_NONE);

		return FMRES_SUPERCEDE;
	}

	if (equal(sound, "items/equip_nvg.wav")) {
		cs_set_user_nvg(id, 0);

		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public say_text(msgId, msgDest, msgEnt)
{
	new id = get_msg_arg_int(1);

	if (is_user_connected(id) && codPlayer[id][PLAYER_CLASS]) {
		new tempMessage[192], message[192], chatPrefix[64];

		get_msg_arg_string(2, tempMessage, charsmax(tempMessage));

		get_user_class_info(id, codPlayer[id][PLAYER_CLASS], CLASS_NAME, chatPrefix, charsmax(chatPrefix));

		format(chatPrefix, charsmax(chatPrefix), "^x04[%s - %i]", chatPrefix, codPlayer[id][PLAYER_LEVEL]);

		if (!equal(tempMessage, "#Cstrike_Chat_All")) {
			add(message, charsmax(message), chatPrefix);
			add(message, charsmax(message), " ");
			add(message, charsmax(message), tempMessage);
		} else {
			get_msg_arg_string(4, tempMessage, charsmax(tempMessage));
			set_msg_arg_string(4, "");

			add(message, charsmax(message), chatPrefix);
			add(message, charsmax(message), "^x03 ");
			add(message, charsmax(message), codPlayer[id][PLAYER_NAME]);
			add(message, charsmax(message), "^x01 :  ");
			add(message, charsmax(message), tempMessage);
		}

		set_msg_arg_string(2, message);
	}

	return PLUGIN_CONTINUE;
}

public message_ammo(msgId, msgDest, id)
{
	new weapon = get_user_weapon(id);

	if (weapon && !(excludedWeapons & (1<<weapon))) cs_set_user_bpammo(id, weapon, maxBpAmmo[weapon]);
}

public message_intermission()
{
	mapEnd = true;

	execute_forward_ignore(codForwards[END_MAP]);

	set_task(1.0, "save_players");
}

public save_players()
{
	for (new id = 1; id <= MAX_PLAYERS; id++) {
		if (!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id)) continue;

		save_data(id, FINAL);
	}

	return PLUGIN_CONTINUE;
}

public show_info(id)
{
	id -= TASK_SHOW_INFO;

	if (!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id)) {
		remove_task(id + TASK_SHOW_INFO);

		return PLUGIN_CONTINUE;
	}

	static hudData[512], className[MAX_NAME], itemName[MAX_NAME], clanName[MAX_NAME], missionProgress[MAX_NAME], gameTime[MAX_NAME], itemDurability[16], Float:levelPercent, exp, target;

	clanName = ""; missionProgress = "", itemDurability = "";

	formatex(className, charsmax(className), "%L", id, "CORE_NONE");
	formatex(itemName, charsmax(itemName), "%L", id, "CORE_NONE");

	target = id;

	if (!is_user_alive(id)) {
		target = pev(id, pev_iuser2);

		set_hudmessage(255, 255, 255, 0.6, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 4);
	} else set_hudmessage(codPlayer[id][PLAYER_HUD_RED], codPlayer[id][PLAYER_HUD_GREEN], codPlayer[id][PLAYER_HUD_BLUE], float(codPlayer[id][PLAYER_HUD_POSX]) / 100.0, float(codPlayer[id][PLAYER_HUD_POSY]) / 100.0, 0, 0.0, 0.3, 0.0, 0.0, 4);

	if (!target) return PLUGIN_CONTINUE;

	if (sql == Empty_Handle) {
		set_hudmessage(255, 15, 15, -1.0, 0.3, 0, 0.0, 0.3, 0.0, 0.0, 4);

		formatex(hudData, charsmax(hudData), "Wystapil blad przy probie nawiazania polaczenia z baza danych!");

		ShowSyncHudMsg(id, hudInfo, hudData);

		return PLUGIN_CONTINUE;
	}

	if (codPlayer[target][PLAYER_CLASS]) {
		get_user_class_info(target, codPlayer[target][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));
	}

	if (codPlayer[target][PLAYER_ITEM]) {
		get_item_info(codPlayer[target][PLAYER_ITEM], ITEM_NAME, itemName, charsmax(itemName));
	}

	if (cod_get_user_clan(target)) {
		cod_get_clan_name(cod_get_user_clan(target), clanName, charsmax(clanName));

		format(clanName, charsmax(clanName), "%L", id, "CORE_HUD_CLAN", clanName);
	}

	if (cod_get_user_mission(target) > NONE) {
		formatex(missionProgress, charsmax(missionProgress), "%L", id, "CORE_HUD_MISSION", cod_get_user_mission_progress(target),
			cod_get_user_mission_need(target), float(cod_get_user_mission_progress(target)) / float(cod_get_user_mission_need(target)) * 100.0, "%%");
	}

	cod_get_user_time_text(target, gameTime, charsmax(gameTime), id);

	exp = codPlayer[target][PLAYER_LEVEL] - 1 >= 0 ? get_level_exp(codPlayer[target][PLAYER_LEVEL] - 1) : 0;
	levelPercent = codPlayer[target][PLAYER_LEVEL] < cvarLevelLimit ? (float((codPlayer[target][PLAYER_EXP] - exp)) / float((get_level_exp(codPlayer[target][PLAYER_LEVEL]) - exp))) * 100.0 : 0.0;

	if (cvarMaxDurability) {
		formatex(itemDurability, charsmax(itemDurability), " (%0.0f%s)", codPlayer[target][PLAYER_ITEM_DURA] * 100.0 / cvarMaxDurability, "%%");
	}

	formatex(hudData, charsmax(hudData), "%L", id, "CORE_HUD_MAIN", className, clanName, codPlayer[target][PLAYER_LEVEL],
		levelPercent, "%%", itemName, itemDurability, missionProgress, get_user_health(target), cod_get_user_honor(target), gameTime);

	if (get_exp_bonus(target, NONE)) format(hudData, charsmax(hudData), "%L", id, "CORE_HUD_EXP_BONUS", hudData, get_exp_bonus(target, NONE), "%%");

	if (codPlayer[target][PLAYER_KS]) format(hudData, charsmax(hudData), "%L", id, "CORE_HUD_KILL_STREAK", hudData, codPlayer[target][PLAYER_KS], codPlayer[target][PLAYER_TIME_KS]);

	ShowSyncHudMsg(id, hudInfo, hudData);

	return PLUGIN_CONTINUE;
}

public show_advertisement(id)
{
	id -= TASK_SHOW_AD;

	chat_print(id, "Witaj na serwerze^x03 Call of Duty Mod^x01 stworzonym przez^x03 O'Zone^x01.");
	chat_print(id, "W celu uzyskania informacji o komendach wpisz^x03 /menu^x01 (klawisz^x03 ^"v^"^x01).");
}

public show_help(id)
{
	id -= TASK_SHOW_HELP;

	set_dhudmessage(0, 255, 0, -1.0, 0.7, 0, 5.0, 5.0, 0.1, 0.5);

	switch (random_num(1, cvarMinPlayers ? 17 : 16)) {
		case 1: show_dhudmessage(id, "Aby uzyc umiejetnosci klasy wcisnij klawisz E. Przedmiotow uzywa sie klawiszem F.");
		case 2: show_dhudmessage(id, "Chcialbys zalozyc klan lub do niego dolaczyc? Wpisz komende /klan.");
		case 3: show_dhudmessage(id, "Sposobem na zdobywanie wiekszej ilosci doswiadczenia sa /misje.");
		case 4: show_dhudmessage(id, "Wpisz komende /bind, aby sprawdzic bindy wszystkich umiejetnosci.");
		case 5: show_dhudmessage(id, "Sprzedaj niechciany przedmiot zamiast go wyrzucac. Zajrzyj na /rynek.");
		case 6: show_dhudmessage(id, "Mozesz dowolnie konfigurowac wyswietlanie HUD uzywajac komendy /hud.");
		case 7: show_dhudmessage(id, "Chcesz sprobowac swojego szczescia? Sprawdz /kasyno.");
		case 8: show_dhudmessage(id, "Zajrzyj do /sklep, aby kupic dodatki, exp, jak i wymienic kase na honor.");
		case 9: show_dhudmessage(id, "Aby wylaczyc/wlaczyc pokazujace sie znaczniki uzyj komendy /ikony.");
		case 10: show_dhudmessage(id, "Noze dodaja bonusy do statystyk, mozesz zmienic swoj wpisujac /noz.");
		case 11: show_dhudmessage(id, "Jesli chcesz przelac komus kase lub honor uzyj komendy /przelew.");
		case 12: show_dhudmessage(id, "Oddaj przedmiot komenda /daj lub uzyj /wymien do wymiany z innym graczem.");
		case 13: show_dhudmessage(id, "Aby zarzadzac swoim kontem - w tym zmienic haslo, wpisz komende /konto.");
		case 14: show_dhudmessage(id, "Glowne menu serwera znajdziesz pod komenda /menu lub klawiszem V.");
		case 15: show_dhudmessage(id, "Jest wiele dodatkowych statystyk, ktore znajdziesz pod komenda /statymenu.");
		case 16: {
			static info[128];

			formatex(info, charsmax(info), "Doswiadczenie i misje sa naliczane, jesli na serwerze gra co najmniej %i graczy.", cvarMinPlayers);

			show_dhudmessage(id, info);
		}
	}
}

public check_time()
{
	static time[3], hour;

	get_time("%H", time, charsmax(time));

	hour = str_to_num(time);

	if ((cvarNightExpFrom > cvarNightExpTo && (hour >= cvarNightExpFrom || hour < cvarNightExpTo)) || (hour >= cvarNightExpFrom && hour < cvarNightExpTo)) nightExp = true;
	else nightExp = false;
}

public night_exp_info()
{
	if (nightExp) chat_print(0, "Na serwerze^x03 aktywny^x01 jest nocny exp^x03 wiekszy o %i procent^x01!", cvarNightExpBonus);
	else chat_print(0, "Od godziny^x03 %i:00^x01 do^x03 %i:00^x01 na serwerze exp jest^x03 wiekszy o %i procent^x01!", cvarNightExpFrom, cvarNightExpTo, cvarNightExpBonus);
}

public set_speed_limit(id)
{
	id -= TASK_SPEED_LIMIT;

	cmd_execute(id, "cl_forwardspeed 450");
	cmd_execute(id, "cl_backspeed 450");
	cmd_execute(id, "cl_sidespeed 450");
	cmd_execute(id, "^"cl_forwardspeed^" 450");
	cmd_execute(id, "^"cl_backspeed^" 450");
	cmd_execute(id, "^"cl_sidespeed^" 450");
	cmd_execute(id, "echo ^"^";^"cl_forwardspeed^" 450");
	cmd_execute(id, "echo ^"^";^"cl_backspeed^" 450");
	cmd_execute(id, "echo ^"^";^"cl_sidespeed^" 450");
}

public set_new_class(id)
{
	if (!is_user_connected(id)) return PLUGIN_CONTINUE;

	new ret, class = codPlayer[id][PLAYER_CLASS];

	if (codPlayer[id][PLAYER_CLASS]) {
		save_data(id, NORMAL);

		execute_forward_ignore_one_param(get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_DISABLED), id);

		reset_attributes(id, CLASS);
	}

	load_class(id, codPlayer[id][PLAYER_NEW_CLASS]);

	ExecuteForward(get_class_info(codPlayer[id][PLAYER_NEW_CLASS], CLASS_ENABLED), ret, id, codPlayer[id][PLAYER_PROMOTION]);

	if (ret == COD_STOP) {
		codPlayer[id][PLAYER_NEW_CLASS] = 0;

		load_class(id, codPlayer[id][class]);

		select_faction(id);

		return PLUGIN_CONTINUE;
	}

	codPlayer[id][PLAYER_CLASS] = codPlayer[id][PLAYER_NEW_CLASS];
	codPlayer[id][PLAYER_NEW_CLASS] = NONE;

	execute_forward_ignore_two_params(codForwards[CLASS_CHANGED], id, codPlayer[id][PLAYER_CLASS]);

	if (codPlayer[id][PLAYER_POINTS] > 0) assign_points(id, 0);

	check_level(id);

	set_task(0.1, "set_attributes", id);

	return PLUGIN_CONTINUE;
}

stock check_item(id, item)
{
	if (!ArraySize(codItems) || !is_user_connected(id) || !item) return false;

	new ret, flag = get_item_info(item, ITEM_FLAG);

	if (flag != NONE && !(codPlayer[id][PLAYER_FLAGS] & flag)) {
		return false;
	}

	if (get_item_info(item, ITEM_CHECK) > 0) {
		ExecuteForward(get_item_info(item, ITEM_CHECK), ret, id);
	}

	return ret == COD_STOP ? false : true;
}

stock set_item(id, item = 0, value = 0, force = false)
{
	if (!ArraySize(codItems) || !is_user_connected(id)) return PLUGIN_CONTINUE;

	reset_attributes(id, ITEM);

	new bool:random = (item == RANDOM);

	item = random ? random_num(1, ArraySize(codItems) - 1): item;

	if (item) {
		if (!force && !check_item(id, item)) {
			if (random) {
				set_item(id, RANDOM, RANDOM);

				return PLUGIN_CONTINUE;
			}

			return COD_STOP;
		}

		if (value == RANDOM) {
			new valueMin = get_item_info(item, ITEM_RANDOM_MIN), valueMax = get_item_info(item, ITEM_RANDOM_MAX);

			if (valueMax) value = random_num(valueMin, valueMax);
			else if (valueMin) value = valueMin;
		}

		execute_forward_ignore_two_params(get_item_info(item, ITEM_GIVE), id, value);
	}

	if (codPlayer[id][PLAYER_ITEM]) execute_forward_ignore_one_param(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_DROP), id);

	codPlayer[id][PLAYER_ITEM] = item;

	execute_forward_ignore_two_params(codForwards[ITEM_CHANGED], id, codPlayer[id][PLAYER_ITEM]);

	if (codPlayer[id][PLAYER_ITEM]) {
		codPlayer[id][PLAYER_ITEM_DURA] = cvarMaxDurability;

		new itemDescription[MAX_DESC], itemName[MAX_NAME], itemValue[6], itemTempValue = _cod_get_user_item_value(id);

		get_item_info(item, ITEM_DESC, itemDescription, charsmax(itemDescription));
		get_item_info(item, ITEM_NAME, itemName, charsmax(itemName));

		if (itemTempValue != NONE) {
			num_to_str(itemTempValue, itemValue, charsmax(itemValue));

			format(itemDescription, charsmax(itemDescription), itemDescription, itemValue);
		}

		chat_print(id, "Zdobyles^x03 %s^x01 -^x04 %s^x01.", itemName, itemDescription);
	} else codPlayer[id][PLAYER_ITEM_DURA] = 0;

	return PLUGIN_CONTINUE;
}

public check_level(id)
{
	if (!is_user_connected(id) || !codPlayer[id][PLAYER_CLASS]) return;

	if (codPlayer[id][PLAYER_GAINED_EXP] && (codPlayer[id][PLAYER_EXP] + codPlayer[id][PLAYER_GAINED_EXP]) < 0) {
		codPlayer[id][PLAYER_GAINED_EXP] = 0;

		return;
	}

	while ((codPlayer[id][PLAYER_GAINED_EXP] + codPlayer[id][PLAYER_EXP]) >= get_level_exp(codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL]) && codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL] < cvarLevelLimit) codPlayer[id][PLAYER_GAINED_LEVEL]++;

	if (!codPlayer[id][PLAYER_GAINED_LEVEL]) while ((codPlayer[id][PLAYER_GAINED_EXP] + codPlayer[id][PLAYER_EXP]) < get_level_exp(codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL] - 1)) codPlayer[id][PLAYER_GAINED_LEVEL]--;

	if (codPlayer[id][PLAYER_GAINED_LEVEL]) {
		codPlayer[id][PLAYER_POINTS] = (codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL] - 1) * cvarPointsPerLevel - codPlayer[id][PLAYER_INT] - codPlayer[id][PLAYER_HEAL] - codPlayer[id][PLAYER_STAM] - codPlayer[id][PLAYER_STR] - codPlayer[id][PLAYER_COND];

		set_dhudmessage(212, 255, 85, -1.0, 0.24, 0, 0.0, 2.5, 0.0, 0.0);
		show_dhudmessage(id, "Awansowales do %i poziomu!", codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL]);

		check_promotion(id, 1);

		switch (random_num(1, 3)) {
			case 1: client_cmd(id, "spk %s", codSounds[SOUND_LVLUP]);
			case 2: client_cmd(id, "spk %s", codSounds[SOUND_LVLUP2]);
			case 3: client_cmd(id, "spk %s", codSounds[SOUND_LVLUP3]);
		}
	}

	if (codPlayer[id][PLAYER_GAINED_LEVEL] < 0) {
		codPlayer[id][PLAYER_POINTS] = (codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL] - 1) * cvarPointsPerLevel;
		codPlayer[id][PLAYER_INT] = 0;
		codPlayer[id][PLAYER_HEAL] = 0;
		codPlayer[id][PLAYER_COND] = 0;
		codPlayer[id][PLAYER_STR] = 0;
		codPlayer[id][PLAYER_STAM] = 0;

		if (codPlayer[id][PLAYER_POINTS]) assign_points(id, 0);

		set_dhudmessage(212, 255, 85, -1.0, 0.24, 0, 0.0, 2.5, 0.0, 0.0);
		show_dhudmessage(id, "Spadles do %i poziomu!", codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL]);
	}

	save_data(id, NORMAL);
}

public reset_attributes(id, type)
{
	codPlayer[id][PLAYER_ROCKETS][type] = 0;
	codPlayer[id][PLAYER_MINES][type] = 0;
	codPlayer[id][PLAYER_DYNAMITES][type] = 0;
	codPlayer[id][PLAYER_THUNDERS][type] = 0;
	codPlayer[id][PLAYER_MEDKITS][type] = 0;
	codPlayer[id][PLAYER_POISONS][type] = 0;
	codPlayer[id][PLAYER_JUMPS][type] = 0;
	codPlayer[id][PLAYER_RESISTANCE][type] = 0;
	codPlayer[id][PLAYER_BUNNYHOP][type] = 0;
	codPlayer[id][PLAYER_NOCLIP][type] = 0;
	codPlayer[id][PLAYER_GODMODE][type] = 0;
	codPlayer[id][PLAYER_FOOTSTEPS][type] = 0;
	codPlayer[id][PLAYER_MODEL][type] = 0;
	codPlayer[id][PLAYER_UNLIMITED_AMMO][type] = 0;
	codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][type] = 0;
	codPlayer[id][PLAYER_ELIMINATOR][type] = 0;
	codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][type] = 0;
	codPlayer[id][PLAYER_REDUCER][type] = 0;
	codPlayer[id][PLAYER_REDUCER_WEAPONS][type] = 0;
	codPlayer[id][PLAYER_TELEPORTS][type] = 0;
	codPlayer[id][PLAYER_GRAVITY][type] = _:1.0;
	codPlayer[id][PLAYER_SPEED][type] = _:0.0;
	codPlayer[id][PLAYER_RENDER] = NONE;

	remove_render_type(id, type);

	model_change(id);

	set_gravity(id);

	set_speed(id);

	if (type != DAMAGE_GIVEN && type != DAMAGE_TAKEN) {
		codPlayer[id][PLAYER_DAMAGE_GIVEN] = false;
		codPlayer[id][PLAYER_DAMAGE_TAKEN] = false;
	}

	if (type != ITEM && type != DEATH && type != DAMAGE_GIVEN && type != DAMAGE_TAKEN) {
		codPlayer[id][PLAYER_ROCKETS][USED] = 0;
		codPlayer[id][PLAYER_MINES][USED] = 0;
		codPlayer[id][PLAYER_MEDKITS][USED] = 0;
		codPlayer[id][PLAYER_DYNAMITES][USED] = 0;
		codPlayer[id][PLAYER_THUNDERS][USED] = 0;
		codPlayer[id][PLAYER_POISONS][USED] = 0;
		codPlayer[id][PLAYER_TELEPORTS][USED] = 0;

		if (task_exists(id + TASK_END_KILL_STREAK)) remove_task(id + TASK_END_KILL_STREAK);

		for (new i = PLAYER_LAST_ROCKET; i <= PLAYER_LAST_TELEPORT; i++) codPlayer[id][i] = _:0.0;

		codPlayer[id][PLAYER_LEFT_JUMPS] = 0;
		codPlayer[id][PLAYER_KS] = 0;
		codPlayer[id][PLAYER_TIME_KS] = 0;
	} else {
		calculate_rockets_left(id);
		calculate_mines_left(id);
		calculate_dynamites_left(id);
		calculate_thunders_left(id);
		calculate_medkits_left(id);
		calculate_poisons_left(id);
		calculate_teleports_left(id);
	}

	codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][ALL] = 0;
	codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][ALL] = 0;
	codPlayer[id][PLAYER_REDUCER_WEAPONS][ALL] = 0;
	codPlayer[id][PLAYER_FOOTSTEPS][ALL] = 0;
	codPlayer[id][PLAYER_BUNNYHOP][ALL] = 0;
	codPlayer[id][PLAYER_RESISTANCE][ALL] = 0;
	codPlayer[id][PLAYER_NOCLIP][ALL] = 0;
	codPlayer[id][PLAYER_GODMODE][ALL] = 0;
	codPlayer[id][PLAYER_MODEL][ALL] = 0;
	codPlayer[id][PLAYER_UNLIMITED_AMMO][ALL] = 0;
	codPlayer[id][PLAYER_ELIMINATOR][ALL] = 0;
	codPlayer[id][PLAYER_REDUCER][ALL] = 0;
	codPlayer[id][PLAYER_JUMPS][ALL] = 0;

	new unlimitedWeapons, eliminatorWeapons, reductorWeapons;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_FOOTSTEPS][i]) codPlayer[id][PLAYER_FOOTSTEPS][ALL] = true;
		if (codPlayer[id][PLAYER_BUNNYHOP][i]) codPlayer[id][PLAYER_BUNNYHOP][ALL] = true;
		if (codPlayer[id][PLAYER_RESISTANCE][i]) codPlayer[id][PLAYER_RESISTANCE][ALL] = true;
		if (codPlayer[id][PLAYER_NOCLIP][i]) codPlayer[id][PLAYER_NOCLIP][ALL] = true;
		if (codPlayer[id][PLAYER_GODMODE][i]) codPlayer[id][PLAYER_GODMODE][ALL] = true;
		if (codPlayer[id][PLAYER_MODEL][i]) codPlayer[id][PLAYER_MODEL][ALL] = true;
		if (codPlayer[id][PLAYER_UNLIMITED_AMMO][i]) codPlayer[id][PLAYER_UNLIMITED_AMMO][ALL] = true;
		if (codPlayer[id][PLAYER_ELIMINATOR][i]) codPlayer[id][PLAYER_ELIMINATOR][ALL] = true;
		if (codPlayer[id][PLAYER_REDUCER][i]) codPlayer[id][PLAYER_REDUCER][ALL] = true;

		if (codPlayer[id][PLAYER_JUMPS][i]) codPlayer[id][PLAYER_JUMPS][ALL] += codPlayer[id][PLAYER_JUMPS][i];

		if (codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][i] == FULL) unlimitedWeapons = FULL;
		else if (codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][i]) unlimitedWeapons == FULL ? (unlimitedWeapons = FULL) : (unlimitedWeapons |= codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][i]);

		if (codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][i] == FULL) eliminatorWeapons = FULL;
		else if (codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][i]) eliminatorWeapons == FULL ? (eliminatorWeapons = FULL) : (eliminatorWeapons |= codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][i]);

		if (codPlayer[id][PLAYER_REDUCER_WEAPONS][i] == FULL) reductorWeapons = FULL;
		else if (codPlayer[id][PLAYER_REDUCER_WEAPONS][i]) reductorWeapons == FULL ? (reductorWeapons = FULL) : (reductorWeapons |= codPlayer[id][PLAYER_REDUCER_WEAPONS][i]);
	}

	codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][ALL] = unlimitedWeapons
	codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][ALL] = eliminatorWeapons;
	codPlayer[id][PLAYER_REDUCER_WEAPONS][ALL] = reductorWeapons;

	codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS][ALL];

	set_user_footsteps(id, codPlayer[id][PLAYER_FOOTSTEPS][ALL]);
	set_user_noclip(id, codPlayer[id][PLAYER_NOCLIP][ALL]);
	set_user_godmode(id, codPlayer[id][PLAYER_GODMODE][ALL]);
}

public set_attributes(id)
{
	if (!is_user_alive(id)) return;

	set_user_health(id, get_health(id));

	set_user_footsteps(id, codPlayer[id][PLAYER_FOOTSTEPS][ALL]);
	set_user_noclip(id, codPlayer[id][PLAYER_NOCLIP][ALL]);
	set_user_godmode(id, codPlayer[id][PLAYER_GODMODE][ALL]);

	codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS][ALL];

	calculate_rockets_left(id);
	calculate_mines_left(id);
	calculate_dynamites_left(id);
	calculate_thunders_left(id);
	calculate_medkits_left(id);
	calculate_poisons_left(id);
	calculate_teleports_left(id);

	set_gravity(id);

	set_speed(id);

	model_change(id);

	render_change(id);

	strip_weapons(id, PRIMARY);
	strip_weapons(id, SECONDARY);

	new weaponName[22];

	for (new i = 1; i < sizeof weapons; i++) {
		if ((1<<i) & (codPlayer[id][PLAYER_WEAPONS] | codPlayer[id][PLAYER_EXTRA_WEAPONS])) {
			get_weaponname(i, weaponName, charsmax(weaponName));
			give_item(id, weaponName);
		}
	}

	new playerWeapons[32], weaponsNum;

	get_user_weapons(id, playerWeapons, weaponsNum);

	for (new i = 0; i < weaponsNum; i++) {
		if (excludedWeapons & (1<<playerWeapons[i])) continue;

		cs_set_user_bpammo(id, playerWeapons[i], maxBpAmmo[playerWeapons[i]]);
	}
}

public gravity_change(id)
{
	if (!is_user_alive(id)) return PLUGIN_CONTINUE;

	set_user_gravity(id, Float:codPlayer[id][PLAYER_GRAVITY][ALL]);

	static ret;

	ExecuteForward(codForwards[GRAVITY_CHANGED], ret, id, Float:codPlayer[id][PLAYER_GRAVITY][ALL]);

	return PLUGIN_CONTINUE;
}

public set_gravity(id)
{
	new Float:gravity = 1.0;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_GRAVITY][i] >= 0.0 && codPlayer[id][PLAYER_GRAVITY][i] < gravity) gravity = codPlayer[id][PLAYER_GRAVITY][i];
		else if (codPlayer[id][PLAYER_GRAVITY][i] < 0.0) gravity += codPlayer[id][PLAYER_GRAVITY][i];
	}

	codPlayer[id][PLAYER_GRAVITY][ALL] = _:floatmax(0.01, gravity);

	gravity_change(id);
}

public set_speed(id)
{
	new Float:speed = 0.0;

	speed += (get_condition(id) * 0.85);

	for (new i = CLASS; i <= DEATH; i++) {
		if (Float:codPlayer[id][PLAYER_SPEED][i] == COD_FREEZE) {
			speed = COD_FREEZE;

			break;
		} else if (codPlayer[id][PLAYER_SPEED][i] >= 0.0 && codPlayer[id][PLAYER_SPEED][i] > speed) {
			speed = (speed > 0.0 ? codPlayer[id][PLAYER_SPEED][i] : codPlayer[id][PLAYER_SPEED][i] + speed);
		} else if (codPlayer[id][PLAYER_SPEED][i] < 0.0) {
			speed += codPlayer[id][PLAYER_SPEED][i];
		}
	}

	codPlayer[id][PLAYER_SPEED][ALL] = _:speed;

	if (!is_user_alive(id) || freezeTime) return;

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
}

public model_change(id)
{
	if (!is_user_connected(id)) return PLUGIN_CONTINUE;

	if (!codPlayer[id][PLAYER_MODEL][ALL]) cs_reset_user_model(id);
	else {
		static ctSkins[4][] = {"sas", "gsg9", "urban", "gign"}, tSkins[4][] = {"arctic", "leet", "guerilla", "terror"};

		new model = random_num(0, 3);

		cs_set_user_model(id, (cs_get_user_team(id) == CS_TEAM_T) ? ctSkins[model]: tSkins[model]);
	}

	return PLUGIN_CONTINUE;
}

public reset_player(id)
{
	rem_bit(id, dataLoaded);

	remove_tasks(id);

	clear_render(id);

	for (new i = PLAYER_CLASS; i <= PLAYER_TIME_KS; i++) codPlayer[id][i] = 0;
	for (new i = PLAYER_LAST_ROCKET; i <= PLAYER_LAST_TELEPORT; i++) codPlayer[id][i] = _:0.0;

	for (new i = CLASS; i <= ALL; i++) {
		codPlayer[id][PLAYER_GRAVITY][i] = _:1.0;
		codPlayer[id][PLAYER_SPEED][i] = _:0.0;

		codPlayer[id][PLAYER_ROCKETS][i] = 0;
		codPlayer[id][PLAYER_MINES][i] = 0;
		codPlayer[id][PLAYER_DYNAMITES][i] = 0;
		codPlayer[id][PLAYER_THUNDERS][i] = 0;
		codPlayer[id][PLAYER_MEDKITS][i] = 0;
		codPlayer[id][PLAYER_POISONS][i] = 0;
		codPlayer[id][PLAYER_TELEPORTS][i] = 0;
		codPlayer[id][PLAYER_JUMPS][i] = 0;
		codPlayer[id][PLAYER_BUNNYHOP][i] = 0;
		codPlayer[id][PLAYER_FOOTSTEPS][i] = 0;
		codPlayer[id][PLAYER_MODEL][i] = 0;
		codPlayer[id][PLAYER_ELIMINATOR][i] = 0;
		codPlayer[id][PLAYER_REDUCER][i] = 0;
		codPlayer[id][PLAYER_UNLIMITED_AMMO][i] = 0;
		codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][i] = 0;
		codPlayer[id][PLAYER_REDUCER_WEAPONS][i] = 0;
		codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][i] = 0;
	}

	codPlayer[id][PLAYER_NEW_CLASS] = NONE;

	codPlayer[id][PLAYER_HUD_RED] = 0;
	codPlayer[id][PLAYER_HUD_GREEN] = 255;
	codPlayer[id][PLAYER_HUD_BLUE] = 0;
	codPlayer[id][PLAYER_HUD_POSX] = 70;
	codPlayer[id][PLAYER_HUD_POSY] = 6;

	set_new_class(id);
	set_item(id);
}

public end_kill_streak(id)
{
	id -= TASK_END_KILL_STREAK;

	if (!is_user_connected(id))
	{
		remove_task(id + TASK_END_KILL_STREAK);

		return PLUGIN_CONTINUE;
	}

	if (--codPlayer[id][PLAYER_TIME_KS] == 0) {
		codPlayer[id][PLAYER_TIME_KS] = 0;
		codPlayer[id][PLAYER_KS] = 0;

		remove_task(id + TASK_END_KILL_STREAK);
	}

	return PLUGIN_CONTINUE;
}

public remove_tasks(id)
{
	remove_task(id);
	remove_task(id + TASK_SHOW_INFO);
	remove_task(id + TASK_SHOW_AD);
	remove_task(id + TASK_SHOW_HELP);
	remove_task(id + TASK_SPEED_LIMIT);
	remove_task(id + TASK_SET_SPEED);
	remove_task(id + TASK_END_KILL_STREAK);
}

stock remove_ents(id = 0, const className[] = "")
{
	if (!strlen(className)) {
		new const ents[][] = { "rocket", "mine", "dynamite", "medkit", "poison" };

		for (new i = 0; i < sizeof(ents); i++) {
			new ent = find_ent_by_class(-1, ents[i]);

			while (ent > 0) {
				if (!id || (id && entity_get_edict(ent, EV_ENT_owner) == id)) remove_entity(ent);

				ent = find_ent_by_class(ent, ents[i]);
			}
		}
	} else {
		new ent = find_ent_by_class(0, className);

		while (ent > 0) {
			if (!id || (id && entity_get_edict(ent, EV_ENT_owner) == id)) remove_entity(ent);

			ent = find_ent_by_class(ent, className);
		}
	}
}

public show_bonus_info()
{
	if (get_players_amount() > 0 && (lastInfo + 5.0 < get_gametime() || get_players_amount() == cvarMinBonusPlayers)) {
		if (get_players_amount() == cvarMinBonusPlayers) chat_print(0, "Serwer jest pelny, a to oznacza^x03 EXP wiekszy o %i procent^x01!", cvarBonusPlayersPer * cvarMinBonusPlayers);
		else {
			new playersToFull = cvarMinBonusPlayers - get_players_amount();

			chat_print(0, "Do pelnego serwera brakuj%s^x03 %i osob%s^x01. Exp jest^x03 wiekszy o %i procent^x01!", playersToFull > 1 ? (playersToFull < 5 ? "a" : "e") : "e", playersToFull, playersToFull == 1 ? "a" : (playersToFull < 5 ? "y" : ""), get_players_amount() * cvarBonusPlayersPer);
		}

		lastInfo = floatround(get_gametime());
	}
}

stock get_level_exp(level)
	return power(level, 2) * cvarLevelRatio;

stock get_health(id, class_health = 1, stats_health = 1, bonus_health = 1, base_health = 1)
{
	new health;

	if (class_health) health += get_user_class_info(id, codPlayer[id][PLAYER_CLASS], CLASS_HEAL);
	if (stats_health) health += codPlayer[id][PLAYER_HEAL];
	if (bonus_health) health += codPlayer[id][PLAYER_EXTRA_HEAL];
	if (base_health) health += 100;

	return health;
}

stock get_intelligence(id, class_intelligence = 1, stats_intelligence = 1, bonus_intelligence = 1)
{
	new intelligence;

	if (class_intelligence) intelligence += get_user_class_info(id, codPlayer[id][PLAYER_CLASS], CLASS_INT);
	if (stats_intelligence) intelligence += codPlayer[id][PLAYER_INT];
	if (bonus_intelligence) intelligence += codPlayer[id][PLAYER_EXTRA_INT];

	return intelligence;
}

stock get_strength(id, class_strength = 1, stats_strength = 1, bonus_strength = 1)
{
	new strength;

	if (class_strength) strength += get_user_class_info(id, codPlayer[id][PLAYER_CLASS], CLASS_STR);
	if (stats_strength) strength += codPlayer[id][PLAYER_STR];
	if (bonus_strength) strength += codPlayer[id][PLAYER_EXTRA_STR];

	return strength;
}

stock get_stamina(id, class_stamina = 1, stats_stamina = 1, bonus_stamina = 1)
{
	new stamina;

	if (class_stamina) stamina += get_user_class_info(id, codPlayer[id][PLAYER_CLASS], CLASS_STAM);
	if (stats_stamina) stamina += codPlayer[id][PLAYER_STAM];
	if (bonus_stamina) stamina += codPlayer[id][PLAYER_EXTRA_STAM];

	return stamina;
}

stock get_condition(id, class_condition = 1, stats_condition = 1, bonus_condition = 1)
{
	new condition;

	if (class_condition) condition += get_user_class_info(id, codPlayer[id][PLAYER_CLASS], CLASS_COND);
	if (stats_condition) condition += codPlayer[id][PLAYER_COND];
	if (bonus_condition) condition += codPlayer[id][PLAYER_EXTRA_COND];

	return condition;
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
		log_to_file(LOG_FILE, "[%s] SQL Error: %s (%d)", PLUGIN, error, errorNum);

		sql = Empty_Handle;

		set_task(5.0, "sql_init");

		return;
	}

	formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_mod` (`name` VARCHAR(%i) NOT NULL, `class` VARCHAR(64) NOT NULL, `exp` INT UNSIGNED NOT NULL DEFAULT 0, `level` INT UNSIGNED NOT NULL DEFAULT 1, `intelligence` INT UNSIGNED NOT NULL DEFAULT 0, ", MAX_SAFE_NAME);
	add(queryData,  charsmax(queryData), "`health` INT UNSIGNED NOT NULL DEFAULT 0, `stamina` INT UNSIGNED NOT NULL DEFAULT 0, `condition` INT UNSIGNED NOT NULL DEFAULT 0, `strength` INT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY(`name`, `class`));");

	new Handle:query = SQL_PrepareQuery(connection, queryData);

	SQL_Execute(query);

	SQL_FreeHandle(query);

	sqlConnected = true;
}

public load_data(id)
{
	if (!sqlConnected) {
		set_task(1.0, "load_data", id);

		return;
	}

	new playerId[1], queryData[128];

	playerId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT * FROM `cod_mod` WHERE name = ^"%s^"", codPlayer[id][PLAYER_SAFE_NAME]);

	SQL_ThreadQuery(sql, "load_data_handle", queryData, playerId, sizeof playerId);
}

public load_data_handle(failState, Handle:query, error[], errorNum, playerId[], dataSize)
{
	if (failState) {
		if (failState == TQUERY_CONNECT_FAILED) log_to_file(LOG_FILE, "[%s] Could not connect to SQL database. Error: %s (%d)", PLUGIN, error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) log_to_file(LOG_FILE, "[%s] Threaded query failed. Error: %s (%d)", PLUGIN, error, errorNum);

		return;
	}

	new id = playerId[0], className[MAX_NAME], codClass[playerClassInfo], classId;

	while (SQL_MoreResults(query)) {
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "class"), className, charsmax(className));

		if (equal(className, "hud")) {
			codPlayer[id][PLAYER_HUD_RED] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "level"));
			codPlayer[id][PLAYER_HUD_GREEN] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "exp"));
			codPlayer[id][PLAYER_HUD_BLUE] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "intelligence"));
			codPlayer[id][PLAYER_HUD_POSX] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "health"));
			codPlayer[id][PLAYER_HUD_POSY] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "stamina"));

			set_bit(id, hudLoaded);
		} else {
			classId = get_class_id(className);

			if (classId) {
				codClass[PCLASS_LEVEL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "level"));
				codClass[PCLASS_EXP] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "exp"));
				codClass[PCLASS_INT] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "intelligence"));
				codClass[PCLASS_HEAL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "health"));
				codClass[PCLASS_STAM] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "stamina"));
				codClass[PCLASS_STR] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "strength"));
				codClass[PCLASS_COND] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "condition"));

				ArraySetArray(codPlayerClasses[id], classId, codClass);
			}
		}

		SQL_NextRow(query);
	}

	set_bit(id, dataLoaded);

	if (is_user_alive(id)) select_faction(id);
}

public save_data(id, end)
{
	if (!codPlayer[id][PLAYER_CLASS] || !get_bit(id, dataLoaded)) return;

	static queryData[512], className[MAX_NAME];

	get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));

	formatex(queryData, charsmax(queryData), "UPDATE `cod_mod` SET `exp` = (`exp` + %d), `level` = (`level` + %d), `intelligence` = '%d', `health` = '%d', `stamina` = '%d', `strength` = '%d', `condition` = '%d' WHERE `name` = ^"%s^" AND `class` = '%s'",
	codPlayer[id][PLAYER_GAINED_EXP], codPlayer[id][PLAYER_GAINED_LEVEL], codPlayer[id][PLAYER_INT], codPlayer[id][PLAYER_HEAL], codPlayer[id][PLAYER_STAM], codPlayer[id][PLAYER_STR], codPlayer[id][PLAYER_COND], codPlayer[id][PLAYER_SAFE_NAME], className);

	if (end == MAP_END) {
		new error[128], errorNum, Handle:query;

		query = SQL_PrepareQuery(connection, queryData);

		if (!SQL_Execute(query)) {
			errorNum = SQL_QueryError(query, error, charsmax(error));

			log_to_file(LOG_FILE, "[%s] Non-threaded query failed. Error: %s (%d)", PLUGIN, error, errorNum);
		}

		SQL_FreeHandle(query);
	} else SQL_ThreadQuery(sql, "ignore_handle", queryData);

	codPlayer[id][PLAYER_EXP] += codPlayer[id][PLAYER_GAINED_EXP];
	codPlayer[id][PLAYER_GAINED_EXP] = 0;

	codPlayer[id][PLAYER_LEVEL] += codPlayer[id][PLAYER_GAINED_LEVEL];
	codPlayer[id][PLAYER_GAINED_LEVEL] = 0;

	static codClass[playerClassInfo];

	codClass[PCLASS_LEVEL] = codPlayer[id][PLAYER_LEVEL];
	codClass[PCLASS_EXP] = codPlayer[id][PLAYER_EXP];
	codClass[PCLASS_INT] = codPlayer[id][PLAYER_INT];
	codClass[PCLASS_HEAL] = codPlayer[id][PLAYER_HEAL];
	codClass[PCLASS_STAM] = codPlayer[id][PLAYER_STAM];
	codClass[PCLASS_STR] = codPlayer[id][PLAYER_STR];
	codClass[PCLASS_COND] = codPlayer[id][PLAYER_COND];

	ArraySetArray(codPlayerClasses[id], codPlayer[id][PLAYER_CLASS], codClass);

	if (end) rem_bit(id, dataLoaded);
}

public load_class(id, class)
{
	if (!get_bit(id, dataLoaded)) return;

	new codClass[playerClassInfo];

	ArrayGetArray(codPlayerClasses[id], class, codClass);

	codPlayer[id][PLAYER_GAINED_EXP] = 0;
	codPlayer[id][PLAYER_GAINED_LEVEL] = 0;
	codPlayer[id][PLAYER_LEVEL] = max(0, codClass[PCLASS_LEVEL]);
	codPlayer[id][PLAYER_PROMOTION] = check_promotion(id, 0, class);
	codPlayer[id][PLAYER_EXP] = codClass[PCLASS_EXP];
	codPlayer[id][PLAYER_INT] = codClass[PCLASS_INT];
	codPlayer[id][PLAYER_HEAL] = codClass[PCLASS_HEAL];
	codPlayer[id][PLAYER_STAM] = codClass[PCLASS_STAM];
	codPlayer[id][PLAYER_STR] = codClass[PCLASS_STR];
	codPlayer[id][PLAYER_COND] = codClass[PCLASS_COND];
	codPlayer[id][PLAYER_WEAPONS] = get_user_class_info(id, class, CLASS_WEAPONS);

	if (!class) return;

	if (!codPlayer[id][PLAYER_LEVEL]) {
		codPlayer[id][PLAYER_LEVEL] = codClass[PCLASS_LEVEL] = 1;

		ArraySetArray(codPlayerClasses[id], class, codClass);

		new tempData[256], className[MAX_NAME];

		get_class_info(class, CLASS_NAME, className, charsmax(className));

		formatex(tempData, charsmax(tempData), "INSERT IGNORE INTO `cod_mod` (`name`, `class`) VALUES (^"%s^", '%s')", codPlayer[id][PLAYER_SAFE_NAME], className);

		SQL_ThreadQuery(sql, "ignore_handle", tempData);
	}

	codPlayer[id][PLAYER_POINTS] = (codPlayer[id][PLAYER_LEVEL] - 1) * cvarPointsPerLevel - codPlayer[id][PLAYER_INT] - codPlayer[id][PLAYER_HEAL] - codPlayer[id][PLAYER_STAM] - codPlayer[id][PLAYER_STR] - codPlayer[id][PLAYER_COND];

	if (codPlayer[id][PLAYER_POINTS] < 0) {
		reset_points(id);

		return;
	}

	if (cvarPointsLimitEnabled) {
		new statsLimit = cvarLevelLimit * cvarPointsPerLevel / 5;

		if (codPlayer[id][PLAYER_INT] > statsLimit
			|| codPlayer[id][PLAYER_HEAL] > statsLimit
			|| codPlayer[id][PLAYER_STAM] > statsLimit
			|| codPlayer[id][PLAYER_STR] > statsLimit
			|| codPlayer[id][PLAYER_COND] > statsLimit
		) {
			reset_points(id);

			return;
		}
	}
}

public ignore_handle(failState, Handle:query, error[], errorNum, data[], dataSize)
{
	if (failState) {
		if (failState == TQUERY_CONNECT_FAILED) log_to_file(LOG_FILE, "[%s] Could not connect to SQL database. Error: %s (%d)", PLUGIN, error, errorNum);
		else if (failState == TQUERY_QUERY_FAILED) log_to_file(LOG_FILE, "[%s] Threaded query failed. Error: %s (%d)", PLUGIN, error, errorNum);
	}

	return PLUGIN_CONTINUE;
}

public _cod_get_user_exp(id)
	return codPlayer[id][PLAYER_EXP];

public _cod_set_user_exp(id, value, bonus)
{
	codPlayer[id][PLAYER_GAINED_EXP] = bonus ? get_exp_bonus(id, value) : value;

	check_level(id);
}

public _cod_get_user_bonus_exp(id, value)
	return get_exp_bonus(id, value);

public _cod_get_level_exp(level)
	return get_level_exp(level);

public _cod_get_user_level(id)
	return codPlayer[id][PLAYER_LEVEL];

public _cod_get_user_highest_level(id)
{
	new level, codClass[classInfo];

	for (new i = 1; i < ArraySize(codPlayerClasses[id]); i++) {
		ArrayGetArray(codPlayerClasses[id], i, codClass);

		if (codClass[PCLASS_LEVEL] > level) level = codClass[PCLASS_LEVEL];
	}

	return level;
}

public _cod_get_user_class(id, &promotion)
{
	param_convert(2);

	promotion = codPlayer[id][PLAYER_PROMOTION];

	return codPlayer[id][PLAYER_CLASS];
}

public _cod_get_user_class_name(id, dataReturn[], dataLength)
{
	param_convert(2);

	codPlayer[id][PLAYER_PROMOTION] ? get_class_promotion_info(codPlayer[id][PLAYER_CLASS], codPlayer[id][PLAYER_PROMOTION], CLASS_NAME, dataReturn, dataLength) : get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_NAME, dataReturn, dataLength);
}

public _cod_get_user_promotion(id)
	return codPlayer[id][PLAYER_PROMOTION];

public _cod_get_user_promotion_id(id)
	return codPlayer[id][PLAYER_PROMOTION_ID];

public _cod_set_user_class(id, class, force)
{
	codPlayer[id][PLAYER_NEW_CLASS] = class;

	if (force) set_new_class(id);
}

public _cod_get_class_id(className[])
{
	param_convert(1);

	return get_class_id(className);
}

public _cod_get_class_name(class, promotion, dataReturn[], dataLength)
{
	param_convert(3);

	promotion ? get_class_promotion_info(class, promotion, CLASS_NAME, dataReturn, dataLength) : get_class_info(class, CLASS_NAME, dataReturn, dataLength);
}

public _cod_get_class_desc(class, promotion, dataReturn[], dataLength)
{
	param_convert(3);

	promotion ? get_class_promotion_info(class, promotion, CLASS_NAME, dataReturn, dataLength) : get_class_info(class, CLASS_DESC, dataReturn, dataLength);
}

public _cod_get_class_health(class, promotion)
	return promotion ? get_class_promotion_info(class, promotion, CLASS_HEAL) : get_class_info(class, CLASS_HEAL);

public _cod_get_class_intelligence(class, promotion)
	return promotion ? get_class_promotion_info(class, promotion, CLASS_INT) : get_class_info(class, CLASS_INT);

public _cod_get_class_stamina(class, promotion)
	return promotion ? get_class_promotion_info(class, promotion, CLASS_STAM) : get_class_info(class, CLASS_STAM);

public _cod_get_class_strength(class, promotion)
	return promotion ? get_class_promotion_info(class, promotion, CLASS_STR) : get_class_info(class, CLASS_STR);

public _cod_get_class_condition(class, promotion)
	return promotion ? get_class_promotion_info(class, promotion, CLASS_COND) : get_class_info(class, CLASS_COND);

public _cod_get_classes_num()
	return ArraySize(codClasses) - 1;

public _cod_get_user_item(id, &value)
{
	param_convert(2);

	value = _cod_get_user_item_value(id);

	return codPlayer[id][PLAYER_ITEM];
}

public _cod_get_user_item_name(id, dataReturn[], dataLength)
{
	param_convert(2);

	if (!codPlayer[id][PLAYER_ITEM]) formatex(dataReturn, dataLength, "Brak");
	else get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_NAME, dataReturn, dataLength);
}

public _cod_get_user_item_value(id)
{
	new value = NONE;

	if (get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_VALUE) > 0) ExecuteForward(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_VALUE), value, id);

	return value;
}

public _cod_set_user_item(id, item, value, force)
	return set_item(id, item, value, force);

public _cod_check_item(id, item)
	return check_item(id, item);

public _cod_upgrade_user_item(id, check)
{
	if (!ArraySize(codItems)) return false;

	if (check) return get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_UPGRADE) > 0 ? true : false;

	switch (random_num(1, 10)) {
		case 1 .. 6: {
			new ret;

			ExecuteForward(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_UPGRADE), ret, id);

			if (ret == COD_STOP) return false;

			codPlayer[id][PLAYER_ITEM_DURA] = cvarMaxDurability;

			chat_print(id, "Twoj przedmiot zostal pomyslnie^x03 ulepszony^x01.");
		} case 7 .. 9: {
			new durability = random_num(cvarMinDamageDurability, cvarMaxDamageDurability);

			codPlayer[id][PLAYER_ITEM_DURA] -= durability;

			if (codPlayer[id][PLAYER_ITEM_DURA] <= 0) {
				set_item(id);

				chat_print(id, "Ulepszenie^x03 nieudane^x01! Twoj przedmiot ulegl^x03 zniszczeniu^x01.");
			} else chat_print(id, "Ulepszenie^x03 nieudane^x01! Straciles^x03 %i^x01 wytrzymalosci przedmiotu.", durability);
		} case 10: {
			set_item(id);

			chat_print(id, "Ulepszenie^x03 nieudane^x01! Twoj przedmiot ulegl^x03 zniszczeniu^x01.");
		}
	}

	return true;
}

public _cod_get_item_id(itemName[])
{
	param_convert(1);

	new codItem[classInfo];

	for (new i = 1; i < ArraySize(codItems); i++) {
		ArrayGetArray(codItems, i, codItem);

		if (equali(codItem[ITEM_NAME], itemName)) return i;
	}

	return 0;
}

public _cod_get_item_name(item, dataReturn[], dataLength)
{
	param_convert(2);

	get_item_info(item, ITEM_NAME, dataReturn, dataLength);
}

public _cod_get_item_desc(item, dataReturn[], dataLength)
{
	param_convert(2);

	get_item_info(item, ITEM_DESC, dataReturn, dataLength);
}

public _cod_get_items_num()
	return ArraySize(codItems) - 1;

public _cod_get_item_durability(id)
	return codPlayer[id][PLAYER_ITEM_DURA];

public _cod_set_item_durability(id, value)
{
	codPlayer[id][PLAYER_ITEM_DURA] = min(max(0, value), cvarMaxDurability);

	if (!codPlayer[id][PLAYER_ITEM_DURA]) {
		set_item(id);

		chat_print(id, "Twoj przedmiot ulegl^x03 zniszczeniu^x01.");
	}
}

public _cod_max_item_durability(id)
	return cvarMaxDurability;

public _cod_get_user_bonus_health(id)
	return codPlayer[id][PLAYER_EXTRA_HEAL];

public _cod_get_user_bonus_intelligence(id)
	return codPlayer[id][PLAYER_EXTRA_INT];

public _cod_get_user_bonus_stamina(id)
	return codPlayer[id][PLAYER_EXTRA_STAM];

public _cod_get_user_bonus_strength(id)
	return codPlayer[id][PLAYER_EXTRA_STR];

public _cod_get_user_bonus_condition(id)
	return codPlayer[id][PLAYER_EXTRA_COND];

public _cod_set_user_bonus_health(id, value)
	codPlayer[id][PLAYER_EXTRA_HEAL] = value;

public _cod_set_user_bonus_intelligence(id, value)
	codPlayer[id][PLAYER_EXTRA_INT] = value;

public _cod_set_user_bonus_stamina(id, value)
	codPlayer[id][PLAYER_EXTRA_STAM] = value;

public _cod_set_user_bonus_strength(id, value)
	codPlayer[id][PLAYER_EXTRA_STR] = value;

public _cod_set_user_bonus_condition(id, value)
{
	codPlayer[id][PLAYER_EXTRA_COND] = value;

	set_speed(id);
}

public _cod_add_user_bonus_health(id, value)
	codPlayer[id][PLAYER_EXTRA_HEAL] += value;

public _cod_add_user_bonus_intelligence(id, value)
	codPlayer[id][PLAYER_EXTRA_INT] += value;

public _cod_add_user_bonus_stamina(id, value)
	codPlayer[id][PLAYER_EXTRA_STAM] += value;

public _cod_add_user_bonus_strength(id, value)
	codPlayer[id][PLAYER_EXTRA_STR] += value;

public _cod_add_user_bonus_condition(id, value)
{
	codPlayer[id][PLAYER_EXTRA_COND] += value;

	set_speed(id);
}

public _cod_get_user_health(id, current_health, stats_health, class_health, bonus_health, base_health)
	return current_health ? get_user_health(id) : get_health(id, stats_health, class_health, bonus_health, base_health);

public _cod_get_user_intelligence(id, stats_intelligence, class_intelligence, bonus_intelligence)
	return get_intelligence(id, stats_intelligence, class_intelligence, bonus_intelligence);

public _cod_get_user_stamina(id, stats_stamina, class_stamina, bonus_stamina)
	return get_stamina(id, stats_stamina, class_stamina, bonus_stamina);

public _cod_get_user_strength(id, stats_strength, class_strength, bonus_strength)
	return get_strength(id, stats_strength, class_strength, bonus_strength);

public _cod_get_user_condition(id, stats_condition, class_condition, bonus_condition)
	return get_condition(id, stats_condition, class_condition, bonus_condition);

public _cod_get_user_max_health(id)
	return get_health(id);

public _cod_set_user_health(id, value, maximum)
	set_user_health(id, maximum ? min(value, get_health(id)) : value);

public _cod_add_user_health(id, value, maximum)
	set_user_health(id, maximum ? min(get_user_health(id) + value, get_health(id)) : get_user_health(id) + value);

public _cod_get_user_rockets(id, type)
{
	if (type == ALL) {
		return codPlayer[id][PLAYER_ROCKETS][ALL] + codPlayer[id][PLAYER_ROCKETS][USED];
	} else if (type == USED) {
		return codPlayer[id][PLAYER_ROCKETS][ALL];
	}

	return codPlayer[id][PLAYER_ROCKETS][type];
}

public _cod_get_user_mines(id, type)
{
	if (type == ALL) {
		return codPlayer[id][PLAYER_MINES][ALL] + codPlayer[id][PLAYER_MINES][USED];
	} else if (type == USED) {
		return codPlayer[id][PLAYER_MINES][ALL];
	}

	return codPlayer[id][PLAYER_MINES][type];
}

public _cod_get_user_dynamites(id, type)
{
	if (type == ALL) {
		return codPlayer[id][PLAYER_DYNAMITES][ALL] + codPlayer[id][PLAYER_DYNAMITES][USED];
	} else if (type == USED) {
		return codPlayer[id][PLAYER_DYNAMITES][ALL];
	}

	return codPlayer[id][PLAYER_DYNAMITES][type];
}

public _cod_get_user_thunders(id, type)
{
	if (type == ALL) {
		return codPlayer[id][PLAYER_THUNDERS][ALL] + codPlayer[id][PLAYER_THUNDERS][USED];
	} else if (type == USED) {
		return codPlayer[id][PLAYER_THUNDERS][ALL];
	}

	return codPlayer[id][PLAYER_THUNDERS][type];
}

public _cod_get_user_medkits(id, type)
{
	if (type == ALL) {
		return codPlayer[id][PLAYER_MEDKITS][ALL] + codPlayer[id][PLAYER_MEDKITS][USED];
	} else if (type == USED) {
		return codPlayer[id][PLAYER_MEDKITS][ALL];
	}

	return codPlayer[id][PLAYER_MEDKITS][type];
}

public _cod_get_user_poisons(id, type)
{
	if (type == ALL) {
		return codPlayer[id][PLAYER_POISONS][ALL] + codPlayer[id][PLAYER_POISONS][USED];
	} else if (type == USED) {
		return codPlayer[id][PLAYER_POISONS][ALL];
	}

	return codPlayer[id][PLAYER_POISONS][type];
}

public _cod_get_user_teleports(id, type)
{
	if (type == ALL) {
		return codPlayer[id][PLAYER_TELEPORTS][ALL] + codPlayer[id][PLAYER_TELEPORTS][USED];
	} else if (type == USED) {
		return codPlayer[id][PLAYER_TELEPORTS][ALL];
	}

	return codPlayer[id][PLAYER_TELEPORTS][type];
}

public _cod_get_user_multijumps(id, type)
	return codPlayer[id][PLAYER_JUMPS][type];

public Float:_cod_get_user_gravity(id, type)
	return Float:codPlayer[id][PLAYER_GRAVITY][type];

public Float:_cod_get_user_speed(id, type)
	return type == FULL? get_user_maxspeed(id) : Float:codPlayer[id][PLAYER_SPEED][type];

public _cod_get_user_armor(id, value)
	return cs_get_user_armor(id);

public _cod_set_user_rockets(id, value, type)
{
	codPlayer[id][PLAYER_ROCKETS][type] = max(0, value);

	calculate_rockets_left(id);
}

public _cod_set_user_mines(id, value, type)
{
	codPlayer[id][PLAYER_MINES][type] = max(0, value);

	calculate_mines_left(id);
}

public _cod_set_user_dynamites(id, value, type)
{
	codPlayer[id][PLAYER_DYNAMITES][type] = max(0, value);

	calculate_dynamites_left(id);
}

public _cod_set_user_thunders(id, value, type)
{
	codPlayer[id][PLAYER_THUNDERS][type] = max(0, value);

	calculate_thunders_left(id);
}

public _cod_set_user_medkits(id, value, type)
{
	codPlayer[id][PLAYER_MEDKITS][type] = max(0, value);

	calculate_medkits_left(id);
}

public _cod_set_user_poisons(id, value, type)
{
	codPlayer[id][PLAYER_POISONS][type] = max(0, value);

	calculate_poisons_left(id);
}

public _cod_set_user_teleports(id, value, type)
{
	codPlayer[id][PLAYER_TELEPORTS][type] = codPlayer[id][PLAYER_TELEPORTS][type] == FULL ? FULL : value;

	calculate_teleports_left(id);
}

public _cod_set_user_multijumps(id, value, type)
{
	codPlayer[id][PLAYER_JUMPS][type] = max(0, value);
	codPlayer[id][PLAYER_JUMPS][ALL] = 0;

	for (new i = CLASS; i <= DEATH; i++) codPlayer[id][PLAYER_JUMPS][ALL] += codPlayer[id][PLAYER_JUMPS][i];

	codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS][ALL];
}

public _cod_set_user_gravity(id, Float:value, type)
{
	codPlayer[id][PLAYER_GRAVITY][type] = _:(type == ALL ? floatmax(0.01, value) : value);

	set_gravity(id);
}

public _cod_set_user_speed(id, Float:value, type)
{
	codPlayer[id][PLAYER_SPEED][type] = _:value;

	set_speed(id);
}

public _cod_set_user_armor(id, value)
	cs_set_user_armor(id, max(0, value), CS_ARMOR_KEVLAR);

public _cod_add_user_rockets(id, value, type)
{
	codPlayer[id][PLAYER_ROCKETS][type] = max(0, codPlayer[id][PLAYER_ROCKETS][type] + value);

	calculate_rockets_left(id);
}

public _cod_add_user_mines(id, value, type)
{
	codPlayer[id][PLAYER_MINES][type] = max(0, codPlayer[id][PLAYER_MINES][type] + value);

	calculate_mines_left(id);
}

public _cod_add_user_dynamites(id, value, type)
{
	codPlayer[id][PLAYER_DYNAMITES][type] = max(0, codPlayer[id][PLAYER_DYNAMITES][type] + value);

	calculate_dynamites_left(id);
}

public _cod_add_user_thunders(id, value, type)
{
	codPlayer[id][PLAYER_THUNDERS][type] = max(0, codPlayer[id][PLAYER_THUNDERS][type] + value);

	calculate_thunders_left(id);
}

public _cod_add_user_medkits(id, value, type)
{
	codPlayer[id][PLAYER_MEDKITS][type] = max(0, codPlayer[id][PLAYER_MEDKITS][type] + value);

	calculate_medkits_left(id);
}

public _cod_add_user_poisons(id, value, type)
{
	codPlayer[id][PLAYER_POISONS][type] = max(0, codPlayer[id][PLAYER_POISONS][type] + value);

	calculate_poisons_left(id);
}

public _cod_add_user_teleports(id, value, type)
{
	codPlayer[id][PLAYER_TELEPORTS][type] = codPlayer[id][PLAYER_TELEPORTS][type] == FULL ? FULL : max(0, codPlayer[id][PLAYER_TELEPORTS][type] + value);

	calculate_teleports_left(id);
}

public _cod_add_user_multijumps(id, value, type)
{
	codPlayer[id][PLAYER_JUMPS][type] = max(0, codPlayer[id][PLAYER_JUMPS][type] + value);
	codPlayer[id][PLAYER_JUMPS][ALL] = 0;

	for (new i = CLASS; i <= DEATH; i++) codPlayer[id][PLAYER_JUMPS][ALL] += codPlayer[id][PLAYER_JUMPS][i];

	codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS][ALL];
}

public _cod_add_user_gravity(id, Float:value, type)
{
	codPlayer[id][PLAYER_GRAVITY][type] = _:(type == ALL ? floatmax(0.01, codPlayer[id][PLAYER_GRAVITY][type] + value) : codPlayer[id][PLAYER_GRAVITY][type] + value);

	set_gravity(id);
}

public _cod_add_user_speed(id, Float:value, type)
{
	codPlayer[id][PLAYER_SPEED][type] += _:value;

	set_speed(id);
}

public _cod_add_user_armor(id, value)
	cs_set_user_armor(id, max(0, cs_get_user_armor(id) + value), CS_ARMOR_KEVLAR);

public _cod_use_user_rocket(id)
	use_rocket(id);

public _cod_use_user_mine(id)
	use_mine(id);

public _cod_use_user_dynamite(id)
	use_dynamite(id);

public _cod_use_user_thunder(id)
	use_thunder(id);

public _cod_use_user_medkit(id)
	use_medkit(id);

public _cod_use_user_poison(id)
	use_poison(id);

public _cod_use_user_teleport(id)
	use_teleport(id);

public _cod_get_user_resistance(id, type)
	return codPlayer[id][PLAYER_RESISTANCE][type];

public _cod_get_user_bunnyhop(id, type)
	return codPlayer[id][PLAYER_BUNNYHOP][type];

public _cod_get_user_footsteps(id, type)
	return codPlayer[id][PLAYER_FOOTSTEPS][type];

public _cod_get_user_model(id, type)
	return codPlayer[id][PLAYER_MODEL][type];

public _cod_get_user_godmode(id, type)
	return codPlayer[id][PLAYER_GODMODE][type];

public _cod_get_user_noclip(id, type)
	return codPlayer[id][PLAYER_NOCLIP][type];

public _cod_get_user_unlimited_ammo(id, type, weapon)
{
	if (weapon) return (codPlayer[id][PLAYER_UNLIMITED_AMMO][type] && (codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][type] == FULL || 1<<weapon & codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][type]));
	else return codPlayer[id][PLAYER_UNLIMITED_AMMO][type];
}

public _cod_get_user_recoil_eliminator(id, type, weapon)
{
	if (weapon) return (codPlayer[id][PLAYER_ELIMINATOR][type] && (codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][type] == FULL || 1<<weapon & codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][type]));
	return codPlayer[id][PLAYER_ELIMINATOR][type];
}

public _cod_get_user_recoil_reducer(id, type, weapon)
{
	if (weapon) return (codPlayer[id][PLAYER_REDUCER][type] && (codPlayer[id][PLAYER_REDUCER_WEAPONS][type] == FULL || 1<<weapon & codPlayer[id][PLAYER_REDUCER_WEAPONS][type]));
	return codPlayer[id][PLAYER_REDUCER][type];
}

public _cod_set_user_resistance(id, value, type)
{
	codPlayer[id][PLAYER_RESISTANCE][type] = value;

	new bool:enabled;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_RESISTANCE][i]) enabled = true;
	}

	codPlayer[id][PLAYER_RESISTANCE][ALL] = enabled;
}

public _cod_set_user_godmode(id, value, type)
{
	codPlayer[id][PLAYER_GODMODE][type] = value;

	new bool:enabled;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_GODMODE][i]) enabled = true;
	}

	set_user_godmode(id, enabled);

	codPlayer[id][PLAYER_GODMODE][ALL] = enabled;
}

public _cod_set_user_noclip(id, value, type)
{
	codPlayer[id][PLAYER_NOCLIP][type] = value;

	new bool:enabled;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_NOCLIP][i]) enabled = true;
	}

	codPlayer[id][PLAYER_NOCLIP][ALL] = enabled;

	set_user_noclip(id, enabled);

	if (!codPlayer[id][PLAYER_NOCLIP][ALL]) check_if_player_stuck(id);
}

public _cod_set_user_bunnyhop(id, value, type)
{
	codPlayer[id][PLAYER_BUNNYHOP][type] = value;

	new bool:enabled;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_BUNNYHOP][i]) enabled = true;
	}

	codPlayer[id][PLAYER_BUNNYHOP][ALL] = enabled;
}

public _cod_set_user_footsteps(id, value, type)
{
	codPlayer[id][PLAYER_FOOTSTEPS][type] = value;

	new bool:enabled;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_FOOTSTEPS][i]) enabled = true;
	}

	codPlayer[id][PLAYER_FOOTSTEPS][ALL] = enabled;

	set_user_footsteps(id, enabled);
}

public _cod_set_user_model(id, value, type)
{
	codPlayer[id][PLAYER_MODEL][type] = value;

	new bool:enabled;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_MODEL][i]) enabled = true;
	}

	codPlayer[id][PLAYER_MODEL][ALL] = enabled;

	model_change(id);
}

public _cod_set_user_unlimited_ammo(id, value, type, weapon)
{
	codPlayer[id][PLAYER_UNLIMITED_AMMO][type] = value;

	if (weapon > 0 && codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][type] != FULL) {
		codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][type] |= weapon;
	} else {
		codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][type] = FULL;
	}

	new bool:enabled, weapons;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_UNLIMITED_AMMO][i]) enabled = true;

		if (codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][i] == FULL) weapons = FULL;
		else if (codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][i]) weapons == FULL ? (weapons = FULL) : (weapons |= codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][i]);
	}

	codPlayer[id][PLAYER_UNLIMITED_AMMO][ALL] = enabled;
	codPlayer[id][PLAYER_UNLIMITED_AMMO_WEAPONS][ALL] = weapons;
}

public _cod_set_user_recoil_eliminator(id, value, type, weapon)
{
	codPlayer[id][PLAYER_ELIMINATOR][type] = value;

	if (weapon > 0 && codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][type] != FULL) {
		codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][type] |= weapon;
	} else {
		codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][type] = FULL;
	}

	new bool:enabled, weapons;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_ELIMINATOR][i]) enabled = true;

		if (codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][i] == FULL) weapons = FULL;
		else if (codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][i]) weapons == FULL ? (weapons = FULL) : (weapons |= codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][i]);
	}

	codPlayer[id][PLAYER_ELIMINATOR][ALL] = enabled;
	codPlayer[id][PLAYER_ELIMINATOR_WEAPONS][ALL] = weapons;
}

public _cod_set_user_recoil_reducer(id, value, type, weapon)
{
	codPlayer[id][PLAYER_REDUCER][type] = value;

	if (weapon > 0 && codPlayer[id][PLAYER_REDUCER_WEAPONS][type] != FULL) {
		codPlayer[id][PLAYER_REDUCER_WEAPONS][type] |= weapon;
	} else {
		codPlayer[id][PLAYER_REDUCER_WEAPONS][type] = FULL;
	}

	new bool:enabled, weapons;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_REDUCER][i]) enabled = true;

		if (codPlayer[id][PLAYER_REDUCER_WEAPONS][i] == FULL) weapons = FULL;
		else if (codPlayer[id][PLAYER_REDUCER_WEAPONS][i]) weapons == FULL ? (weapons = FULL) : (weapons |= codPlayer[id][PLAYER_REDUCER_WEAPONS][i]);
	}

	codPlayer[id][PLAYER_REDUCER][ALL] = enabled;
	codPlayer[id][PLAYER_REDUCER_WEAPONS][ALL] = weapons;
}

public _cod_give_weapon(id, weapon, amount)
{
	new weaponName[22];

	codPlayer[id][PLAYER_EXTRA_WEAPONS] |= (1<<weapon);

	get_weaponname(weapon, weaponName, charsmax(weaponName));

	give_item(id, weaponName);

	if (amount > cs_get_user_bpammo(id, weapon)) cs_set_user_bpammo(id, weapon, amount);

	if (!(excludedWeapons & (1<<weapon))) cs_set_user_bpammo(id, weapon, maxBpAmmo[weapon]);
}

public _cod_take_weapon(id, weapon)
{
	codPlayer[id][PLAYER_EXTRA_WEAPONS] &= ~(1<<weapon);

	if ((1<<weapon) & (allowedWeapons | codPlayer[id][PLAYER_WEAPONS])) return;

	new weaponName[22];

	get_weaponname(weapon, weaponName, charsmax(weaponName));

	if (!((1<<weapon) & (1<<CSW_HEGRENADE | 1<<CSW_SMOKEGRENADE | 1<<CSW_FLASHBANG))) engclient_cmd(id, "drop", weaponName);
}

public _cod_get_user_weapon(id)
	return codPlayer[id][PLAYER_WEAPON];

public _cod_get_user_render(id, type)
	return render_count(id, type);

public _cod_set_user_render(id, value, type, status, weapon, Float:timer)
{
	if (timer == 0.0) {
		new codRender[renderInfo];

		codRender[RENDER_TYPE] = type;
		codRender[RENDER_VALUE] = max(0, min(value, 256));
		codRender[RENDER_STATUS] = status;
		codRender[RENDER_WEAPON] = weapon;

		switch (type) {
			case CLASS, ITEM, ADDITIONAL: ArraySetArray(codPlayerRender[id], type, codRender);
			case ROUND, DEATH, DAMAGE_GIVEN, DAMAGE_TAKEN: ArrayPushArray(codPlayerRender[id], codRender);
		}

		render_change(id);
	} else {
		set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, max(0, value));

		set_bit(id, renderTimer);

		set_task(timer, "reset_render", id + TASK_RENDER);

		make_bar_timer(id, floatround(timer));
	}
}

public _cod_set_user_glow(id, effect, red, green, blue, model, amount, Float:timer)
{
	set_bit(id, glowActive);

	set_user_rendering(id, effect, red, green, blue, model, amount);

	if (timer != 0.0) set_task(timer, "reset_glow", id + TASK_GLOW);
}

public reset_render(id)
{
	id -= TASK_RENDER;

	rem_bit(id, renderTimer);

	if (is_user_connected(id)) {
		set_user_rendering(id);

		codPlayer[id][PLAYER_RENDER] = NONE;

		render_change(id);
	}
}

public reset_glow(id)
{
	id -= TASK_GLOW;

	rem_bit(id, glowActive);

	if (is_user_connected(id)) {
		set_user_rendering(id);

		codPlayer[id][PLAYER_RENDER] = NONE;

		render_change(id);
	}
}

public _cod_display_fade(id, duration, holdtime, fadetype, red, green, blue, alpha)
	display_fade(id, duration * (1<<12), holdtime * (1<<12), fadetype, red, green, blue, alpha);

public _cod_display_icon(id, const icon[], enable, red, green, blue)
{
	if (!is_user_alive(id)) return;

	param_convert(2);

	static msgStatusIcon;

	if (!msgStatusIcon) msgStatusIcon = get_user_msgid("StatusIcon");

	message_begin(id ? MSG_ONE : MSG_ALL, msgStatusIcon, _, id);
	write_byte(enable);
	write_string(icon);

	if (enable) {
		write_byte(red);
		write_byte(green);
		write_byte(blue);
	}

	message_end();
}

public _cod_get_user_flags(id)
	return codPlayer[id][PLAYER_FLAGS];

public _cod_set_user_flags(id, flags)
	update_user_flags(id, get_user_flags(id) | flags);

public update_user_flags(id, flags)
{
	codPlayer[id][PLAYER_FLAGS] = flags;

	set_user_flags(id, codPlayer[id][PLAYER_FLAGS]);

	execute_forward_ignore_two_params(codForwards[FLAGS_CHANGED], id, flags);

	if (!codPlayer[id][PLAYER_CLASS]) return;

	new flag = get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_FLAG);

	if (flag != NONE && !(flags & flag)) {
		chat_print(id, "Nie posiadasz uprawnien do korzystania z tej klasy i zostanie ona zmieniona w nastepnej rundzie!");

		codPlayer[id][PLAYER_NEW_CLASS] = 0;

		return;
	}
}

public _cod_print_chat(id, const text[], any:...)
{
	static message[192];

	for (new i = 2; i <= numargs(); i++) param_convert(i);

	if (numargs() == 2) copy(message, charsmax(message), text);
	else vformat(message, charsmax(message), text, 3);

	chat_print(id, message);
}

public _cod_log_error(const plugin[], const text[], any:...)
{
	static error[512];

	for (new i = 1; i <= numargs(); i++) param_convert(i);

	if (numargs() == 2) copy(error, charsmax(error), text);
	else vformat(error, charsmax(error), text, 3);

	log_to_file(LOG_FILE, "[%s] %s", plugin, error);
}

public _cod_show_hud(id, type, red, green, blue, Float:x, Float:y, effects, Float:fxtime, Float:holdtime, Float:fadeintime, Float:fadeouttime, const text[], any:...)
{
	static message[192];

	for (new i = 13; i <= numargs(); i++) param_convert(i);

	if (numargs() == 13) copy(message, charsmax(message), text);
	else vformat(message, charsmax(message), text, 14);

	show_hud(id, message, type, red, green, blue, Float:x, Float:y, effects, Float:fxtime, Float:holdtime, Float:fadeintime, Float:fadeouttime);
}

public _cod_cmd_execute(id, const text[], any:...)
{
	static message[192];

	for (new i = 2; i <= numargs(); i++) param_convert(i);

	if (numargs() == 2) copy(message, charsmax(message), text);
	else vformat(message, charsmax(message), text, 3);

	cmd_execute(id, message);
}

public _cod_sql_string(const source[], dest[], length)
{
	param_convert(1);
	param_convert(2);

	sql_string(source, dest, length);
}

public _cod_screen_shake(id, amplitude, duration, frequency)
	screen_shake(id, amplitude, duration, frequency);

public _cod_refill_ammo(id)
	set_user_clip(id);

public _cod_make_explosion(ent, distance, explosion, Float:damageDistance, Float:damage, Float:factor, suicide)
	make_explosion(ent, distance, explosion, damageDistance, damage, factor, suicide);

public _cod_make_bartimer(id, duration, start)
	make_bar_timer(id, duration, start);

public _cod_drop_weapon(id, weaponName[])
{
	param_convert(2);

	new dropWeaponName[32];

	if (!strlen(weaponName)) {
		new weapon = get_user_weapon(id);

		if (!weapon || excludedWeapons & (1<<weapon)) return;

		get_weaponname(weapon, dropWeaponName, charsmax(dropWeaponName));
	} else {
		copy(dropWeaponName, charsmax(dropWeaponName), weaponName);
	}

	engclient_cmd(id, "drop", dropWeaponName);
}

public _cod_repeat_damage(attacker, victim, Float:damage, Float:time, counter, flags, instant)
{
	new data[5];

	data[ATTACKER] = attacker;
	data[VICTIM] = victim;
	data[DAMAGE] = floatround(damage);
	data[COUNTER] = counter;
	data[FLAGS] = flags;

	remove_task(victim + attacker + TASK_DAMAGE);

	if (damage > 0.0 && time > 0.0) {
		set_task(time, "repeat_damage", victim + attacker + TASK_DAMAGE, data, sizeof(data), counter ? "a" : "b", counter - instant);

		if (instant) repeat_damage(data);
	}
}

public repeat_damage(data[])
{
	if (!is_user_alive(data[VICTIM]) || !is_user_connected(data[ATTACKER])) {
		remove_task(data[VICTIM] + data[ATTACKER] + TASK_DAMAGE);

		return;
	}

	if (data[COUNTER]) data[COUNTER]--;

	switch (data[FLAGS]) {
		case FIRE: {
			new origin[3], flags = pev(data[VICTIM], pev_flags);

			get_user_origin(data[VICTIM], origin);

			if (flags & FL_INWATER || data[COUNTER] == 0) {
				message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
				write_byte(TE_SMOKE);
				write_coord(origin[0]);
				write_coord(origin[1]);
				write_coord(origin[2] - 50);
				write_short(codSprite[SPRITE_SMOKE]);
				write_byte(random_num(15, 20));
				write_byte(random_num(10, 20));
				message_end();

				remove_task(data[VICTIM] + data[ATTACKER] + TASK_DAMAGE);

				return;
			}

			message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
			write_byte(TE_SPRITE);
			write_coord(origin[0] + random_num(-5, 5));
			write_coord(origin[1] + random_num(-5, 5));
			write_coord(origin[2] + random_num(-10, 10));
			write_short(codSprite[SPRITE_FIRE]);
			write_byte(random_num(5, 10));
			write_byte(200);
			message_end();

			display_fade(data[VICTIM], (1<<12), (1<<12), 0x0000, 255, 165, 0, 80);

			data[FLAGS] = DMG_BURN;
		} case POISON: {
			display_fade(data[VICTIM], (1<<12), (1<<12), 0x0000, 0, 150, 60, 120);

			data[FLAGS] = DMG_NERVEGAS;
		} case HEAL: {
			if (get_user_health(data[VICTIM]) < cod_get_user_max_health(data[VICTIM])) {
				display_fade(data[VICTIM], (1<<12), (1<<12), 0x0000, 250, 0, 0, 40);

				cod_add_user_health(data[VICTIM], data[DAMAGE], 1);
			}

			return;
		}
	}

	_cod_inflict_damage(data[ATTACKER], data[VICTIM], float(data[DAMAGE]), 0.0, data[FLAGS] | DMG_CODSKILL | DMG_REPEAT);
}

public _cod_inflict_damage(attacker, victim, Float:damage, Float:factor, flags)
{
	if (!is_user_alive(victim) || !codPlayer[victim][PLAYER_ALIVE] || get_user_health(victim) <= 0 || codPlayer[victim][PLAYER_GODMODE][ALL]) {
		return;
	}

	if (!codPlayer[victim][PLAYER_RESISTANCE][ALL] || (codPlayer[victim][PLAYER_RESISTANCE][ALL] && !(flags & DMG_CODSKILL))) {
		new ret;

		ExecuteForward(codForwards[DAMAGE_INFLICT], ret, attacker, victim, Float:damage, Float:factor, flags);

		if (float(ret) == COD_BLOCK || damage <= 0.0) return;

		ExecuteHam(Ham_TakeDamage, victim, attacker, attacker, damage + get_intelligence(attacker) * factor, DMG_CODSKILL | flags);

		new data[3];

		data[0] = attacker;
		data[1] = victim;
		data[2] = codPlayer[victim][HIT_PLACE][attacker];

		remove_task(victim + TASK_DEATH);

		set_task(0.1, "check_player_death", victim + TASK_DEATH, data, sizeof(data));
	}
}

public check_player_death(data[])
{
	new victim = data[1], attacker = data[0];

	if (!is_user_connected(victim) || !is_user_connected(attacker) || !codPlayer[victim][PLAYER_ALIVE]) return;

	if (get_user_health(victim) <= 0) {
		codPlayer[victim][PLAYER_ALIVE] = false;

		player_death(attacker, victim, HIT_GENERIC, data[2]);
	} else if (!codPlayer[victim][PLAYER_DAMAGE_TAKEN]) {
		codPlayer[victim][PLAYER_DAMAGE_TAKEN] = true;

		reset_attributes(victim, DAMAGE_TAKEN);
	}

	if (!codPlayer[attacker][PLAYER_DAMAGE_GIVEN]) {
		codPlayer[attacker][PLAYER_DAMAGE_GIVEN] = true;

		reset_attributes(attacker, DAMAGE_GIVEN);
	}
}

public Float:_cod_kill_player(killer, victim, flags)
{
	if (is_user_alive(victim) && !codPlayer[victim][PLAYER_GODMODE][ALL]) {
		cs_set_user_armor(victim, 0, CS_ARMOR_NONE);

		_cod_inflict_damage(killer, victim, float(get_user_health(victim) + 1), 0.0, flags | DMG_KILL);
	}

	return COD_BLOCK;
}

public _cod_respawn_player(id, enemy, Float:time)
{
	if (!is_user_alive(id)) {
		if (enemy) set_task(time, "respawn_player_enemy_spawn", id + TASK_RESPAWN);
		else set_task(time, "respawn_player", id + TASK_RESPAWN);
	}
}

public respawn_player(id)
	ExecuteHamB(Ham_CS_RoundRespawn, id - TASK_RESPAWN);

public respawn_player_enemy_spawn(id)
{
	id -= TASK_RESPAWN;

	new CsTeams:team = cs_get_user_team(id);

	cs_set_user_team(id, (team == CS_TEAM_CT) ? CS_TEAM_T : CS_TEAM_CT);

	ExecuteHamB(Ham_CS_RoundRespawn, id);

	cs_set_user_team(id, team);

	check_if_player_stuck(id);
}

public _cod_teleport_to_spawn(id, enemy)
{
	new Float:spawnOrigin[3], Float:spawnAngle[3], team = get_user_team(id);

	find_free_spawn(enemy ? (team == 1 ? 2 : 1) : team, spawnOrigin, spawnAngle);

	set_pev(id, pev_origin, spawnOrigin);
	set_pev(id, pev_angles, spawnAngle);

	check_if_player_stuck(id);
}

public _cod_random_upgrade(&value, upgradeMin, upgradeMax, valueMin, valueMax)
{
	param_convert(1);

	if ((valueMin != NONE && value <= valueMin) || (valueMax != NONE && value >= valueMax)) return COD_STOP;

	value = max(0, value + (((upgradeMin > 0 && upgradeMax > 0) || (upgradeMin < 0 && upgradeMax < 0)) ? random_num(upgradeMin, upgradeMax) : (random_num(0, 1) ? random_num(upgradeMin, -1) : random_num(1, upgradeMax))));

	if (valueMax != NONE) value = min(value, valueMax);
	if (valueMin != NONE) value = max(value, valueMin);

	return COD_CONTINUE;
}

public _cod_percent_chance(percent)
	return random_num(1, 100) <= percent ? true : false;

public _cod_is_enough_space(ent, Float:distance)
	return is_enough_space(ent, distance);

public _cod_remove_ents(id, className[])
{
	param_convert(2);

	remove_ents(id, className);
}

public _cod_register_item(plugin, params)
{
	if (params != 5) return PLUGIN_CONTINUE;

	new codItem[itemInfo];

	get_string(1, codItem[ITEM_NAME], charsmax(codItem[ITEM_NAME]));
	get_string(2, codItem[ITEM_DESC], charsmax(codItem[ITEM_DESC]));

	codItem[ITEM_RANDOM_MIN] = get_param(3);
	codItem[ITEM_RANDOM_MAX] = get_param(4);
	codItem[ITEM_FLAG] = get_param(5);

	codItem[ITEM_PLUGIN] = plugin;

	codItem[ITEM_GIVE] = CreateOneForward(plugin, "cod_item_enabled", FP_CELL, FP_CELL);
	codItem[ITEM_DROP] = CreateOneForward(plugin, "cod_item_disabled", FP_CELL);
	codItem[ITEM_SPAWNED] = CreateOneForward(plugin, "cod_item_spawned", FP_CELL, FP_CELL);
	codItem[ITEM_KILL] = CreateOneForward(plugin, "cod_item_kill", FP_CELL, FP_CELL, FP_CELL);
	codItem[ITEM_KILLED] = CreateOneForward(plugin, "cod_item_killed", FP_CELL, FP_CELL, FP_CELL);
	codItem[ITEM_SKILL_USED] = CreateOneForward(plugin, "cod_item_skill_used", FP_CELL);
	codItem[ITEM_UPGRADE] = CreateOneForward(plugin, "cod_item_upgrade", FP_CELL);
	codItem[ITEM_VALUE] = CreateOneForward(plugin, "cod_item_value", FP_CELL);
	codItem[ITEM_CHECK] = CreateOneForward(plugin, "cod_item_check", FP_CELL);
	codItem[ITEM_DAMAGE_ATTACKER] = get_func_id("cod_item_damage_attacker", plugin);
	codItem[ITEM_DAMAGE_VICTIM] = get_func_id("cod_item_damage_victim", plugin);

	ArrayPushArray(codItems, codItem);

	return ArraySize(codItems) - 1;
}

public _cod_register_class(plugin, params)
{
	if (params != 10) return PLUGIN_CONTINUE;

	new codClass[classInfo];

	get_string(1, codClass[CLASS_NAME], charsmax(codClass[CLASS_NAME]));
	get_string(2, codClass[CLASS_DESC], charsmax(codClass[CLASS_DESC]));
	get_string(3, codClass[CLASS_FRACTION], charsmax(codClass[CLASS_FRACTION]));

	if (!equal(codClass[CLASS_FRACTION], "")) check_faction(codClass[CLASS_FRACTION]);
	else codClass[CLASS_FRACTION] = "Brak";

	codClass[CLASS_WEAPONS] = get_param(4);
	codClass[CLASS_HEAL] = get_param(5);
	codClass[CLASS_INT] = get_param(6);
	codClass[CLASS_STR] = get_param(7);
	codClass[CLASS_STAM] = get_param(8);
	codClass[CLASS_COND] = get_param(9);
	codClass[CLASS_FLAG] = get_param(10);

	codClass[CLASS_PLUGIN] = plugin;

	codClass[CLASS_ENABLED] = CreateOneForward(plugin, "cod_class_enabled", FP_CELL, FP_CELL);
	codClass[CLASS_DISABLED] = CreateOneForward(plugin, "cod_class_disabled", FP_CELL);
	codClass[CLASS_SPAWNED] = CreateOneForward(plugin, "cod_class_spawned", FP_CELL, FP_CELL);
	codClass[CLASS_KILL] = CreateOneForward(plugin, "cod_class_kill", FP_CELL, FP_CELL, FP_CELL);
	codClass[CLASS_KILLED] = CreateOneForward(plugin, "cod_class_killed", FP_CELL, FP_CELL, FP_CELL);
	codClass[CLASS_SKILL_USED] = CreateOneForward(plugin, "cod_class_skill_used", FP_CELL);
	codClass[CLASS_DAMAGE_VICTIM] = get_func_id("cod_class_damage_victim", plugin);
	codClass[CLASS_DAMAGE_ATTACKER] = get_func_id("cod_class_damage_attacker", plugin);

	ArrayPushArray(codClasses, codClass);

	return ArraySize(codClasses) - 1;
}

public _cod_register_promotion(plugin, params)
{
	if (params != 12) return PLUGIN_CONTINUE;

	new codPromotion[classInfo], className[MAX_NAME];

	get_string(1, codPromotion[CLASS_NAME], charsmax(codPromotion[CLASS_NAME]));
	get_string(2, codPromotion[CLASS_DESC], charsmax(codPromotion[CLASS_DESC]));
	get_string(3, className, charsmax(className));

	codPromotion[CLASS_PROMOTION] = get_class_id(className);

	if (!codPromotion[CLASS_PROMOTION]) return PLUGIN_CONTINUE;

	new codClass[classInfo];

	ArrayGetArray(codClasses, codPromotion[CLASS_PROMOTION], codClass);

	codPromotion[CLASS_LEVEL] = get_param(4);
	codPromotion[CLASS_DEGREE] = get_param(5);

	codPromotion[CLASS_WEAPONS] = get_param(6) == NONE ? codClass[CLASS_WEAPONS] : get_param(6);
	codPromotion[CLASS_HEAL] = get_param(7) == NONE ? codClass[CLASS_HEAL] : get_param(7);
	codPromotion[CLASS_INT] = get_param(8) == NONE ? codClass[CLASS_INT] : get_param(8);
	codPromotion[CLASS_STR] = get_param(9) == NONE ? codClass[CLASS_STR] : get_param(9);
	codPromotion[CLASS_STAM] = get_param(10) == NONE ? codClass[CLASS_STAM] : get_param(10);
	codPromotion[CLASS_COND] = get_param(11) == NONE ? codClass[CLASS_COND] : get_param(11);
	codPromotion[CLASS_FLAG] = get_param(12) == NONE ? codClass[CLASS_FLAG] : get_param(12);

	ArrayPushArray(codPromotions, codPromotion);

	return ArraySize(codPromotions) - 1;
}

stock get_exp_bonus(id, exp)
{
	new Float:bonus = 1.0;

	if (cod_get_user_vip(id)) bonus += (cvarVipExpBonus / 100.0);

	if (nightExp) bonus += cvarNightExpBonus / 100.0;

	bonus += floatmin(codPlayer[id][PLAYER_KS] * 0.2, 1.0);
	bonus += get_players_amount() * cvarBonusPlayersPer / 100.0;
	bonus += cod_get_user_clan_bonus(id) / 100.0;

	return exp == NONE ? floatround((bonus - 1.0) * 100) : floatround(exp * bonus);
}

stock get_players_amount()
{
	if (get_maxplayers() - get_playersnum() <= cvarMinBonusPlayers) return (cvarMinBonusPlayers - (get_maxplayers() - get_playersnum()));

	return 0;
}

stock check_promotion(id, info = 0, class = 0)
{
	if (!class && codPlayer[id][PLAYER_PROMOTION] == PROMOTION_THIRD) return codPlayer[id][PLAYER_PROMOTION];

	new codPromotion[classInfo], promotionId, promotion;

	for (new i = 0; i < ArraySize(codPromotions); i++) {
		ArrayGetArray(codPromotions, i, codPromotion);

		if (codPromotion[CLASS_PROMOTION] == (class ? class : codPlayer[id][PLAYER_CLASS]) && codPlayer[id][PLAYER_LEVEL] >= codPromotion[CLASS_LEVEL]) {
			promotionId = i;
			promotion = codPromotion[CLASS_DEGREE];
		}
	}

	if (promotion > codPlayer[id][PLAYER_PROMOTION]) {
		codPlayer[id][PLAYER_PROMOTION] = promotion;
		codPlayer[id][PLAYER_PROMOTION_ID] = promotionId;

		if (info) {
			new className[MAX_NAME];

			codPlayer[id][PLAYER_NEW_CLASS] = codPlayer[id][PLAYER_CLASS];

			get_user_class_info(id, codPlayer[id][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));

			set_dhudmessage(0, 255, 34, -1.0, 0.45, 0, 0.0, 2.5, 0.0, 0.0);
			show_dhudmessage(id, "Awansowales! Twoja klasa to teraz %s!", className);
		}
	}

	return promotion;
}

stock check_faction(const factionName[])
{
	new tempFactionName[MAX_NAME], bool:foundFaction;

	for (new i = 0; i < ArraySize(codFactions); i++) {
		ArrayGetString(codFactions, i, tempFactionName, charsmax(tempFactionName));

		if (equali(tempFactionName, factionName)) foundFaction = true;
	}

	if (!foundFaction) ArrayPushString(codFactions, factionName);
}

stock get_weapons(weapons)
{
	new weaponsList[128], weaponName[22];

	for (new i = 1, j = 1; i <= 32; i++) {
		if ((1<<i) & weapons) {
			get_weaponname(i, weaponName, charsmax(weaponName));

			replace_all(weaponName, charsmax(weaponName), "weapon_", "");

			if (equal(weaponName, "hegrenade")) weaponName = "he";
			if (equal(weaponName, "flashbang")) weaponName = "flash";
			if (equal(weaponName, "smokegrenade")) weaponName = "smoke";

			strtoupper(weaponName);

			if (j > 1) add(weaponsList, charsmax(weaponsList), ", ");

			add(weaponsList, charsmax(weaponsList), weaponName);

			j++;
		}
	}

	return weaponsList;
}

stock calculate_rockets_left(id)
{
	codPlayer[id][PLAYER_ROCKETS][ALL] = 0;

	for (new i = CLASS; i <= DEATH; i++) codPlayer[id][PLAYER_ROCKETS][ALL] += codPlayer[id][PLAYER_ROCKETS][i];

	codPlayer[id][PLAYER_ROCKETS][ALL] = max(0, codPlayer[id][PLAYER_ROCKETS][ALL] - codPlayer[id][PLAYER_ROCKETS][USED]);
}

stock calculate_mines_left(id)
{
	codPlayer[id][PLAYER_MINES][ALL] = 0;

	for (new i = CLASS; i <= DEATH; i++) codPlayer[id][PLAYER_MINES][ALL] += codPlayer[id][PLAYER_MINES][i];

	codPlayer[id][PLAYER_MINES][ALL] = max(0, codPlayer[id][PLAYER_MINES][ALL] - codPlayer[id][PLAYER_MINES][USED]);
}

stock calculate_dynamites_left(id)
{
	codPlayer[id][PLAYER_DYNAMITES][ALL] = 0;

	for (new i = CLASS; i <= DEATH; i++) codPlayer[id][PLAYER_DYNAMITES][ALL] += codPlayer[id][PLAYER_DYNAMITES][i];

	codPlayer[id][PLAYER_DYNAMITES][ALL] = max(0, codPlayer[id][PLAYER_DYNAMITES][ALL] - codPlayer[id][PLAYER_DYNAMITES][USED]);
}

stock calculate_thunders_left(id)
{
	codPlayer[id][PLAYER_THUNDERS][ALL] = 0;

	for (new i = CLASS; i <= DEATH; i++) codPlayer[id][PLAYER_THUNDERS][ALL] += codPlayer[id][PLAYER_THUNDERS][i];

	codPlayer[id][PLAYER_THUNDERS][ALL] = max(0, codPlayer[id][PLAYER_THUNDERS][ALL] - codPlayer[id][PLAYER_THUNDERS][USED]);
}

stock calculate_medkits_left(id)
{
	codPlayer[id][PLAYER_MEDKITS][ALL] = 0;

	for (new i = CLASS; i <= DEATH; i++) codPlayer[id][PLAYER_MEDKITS][ALL] += codPlayer[id][PLAYER_MEDKITS][i];

	codPlayer[id][PLAYER_MEDKITS][ALL] = max(0, codPlayer[id][PLAYER_MEDKITS][ALL] - codPlayer[id][PLAYER_MEDKITS][USED]);
}

stock calculate_poisons_left(id)
{
	codPlayer[id][PLAYER_POISONS][ALL] = 0;

	for (new i = CLASS; i <= DEATH; i++) codPlayer[id][PLAYER_POISONS][ALL] += codPlayer[id][PLAYER_POISONS][i];

	codPlayer[id][PLAYER_POISONS][ALL] = max(0, codPlayer[id][PLAYER_POISONS][ALL] - codPlayer[id][PLAYER_POISONS][USED]);
}

stock calculate_teleports_left(id)
{
	codPlayer[id][PLAYER_TELEPORTS][ALL] = 0;

	for (new i = CLASS; i <= DEATH; i++) {
		if (codPlayer[id][PLAYER_TELEPORTS][i] == FULL) {
			codPlayer[id][PLAYER_TELEPORTS][ALL] = FULL;

			break;
		} else {
			codPlayer[id][PLAYER_TELEPORTS][ALL] += codPlayer[id][PLAYER_TELEPORTS][i];
		}
	}

	codPlayer[id][PLAYER_TELEPORTS][ALL] = codPlayer[id][PLAYER_TELEPORTS][ALL] == FULL ? FULL : max(0, codPlayer[id][PLAYER_TELEPORTS][ALL] - codPlayer[id][PLAYER_TELEPORTS][USED]);
}

stock execute_forward_ignore(forwardHandle)
{
	if (forwardHandle < COD_CONTINUE) return PLUGIN_HANDLED;

	static ret;

	return ExecuteForward(forwardHandle, ret);
}

stock execute_forward_ignore_one_param(forwardHandle, param)
{
	if (forwardHandle < COD_CONTINUE) return PLUGIN_HANDLED;

	static ret;

	return ExecuteForward(forwardHandle, ret, param);
}

stock execute_forward_ignore_two_params(forwardHandle, paramOne, paramTwo)
{
	if (forwardHandle < COD_CONTINUE) return PLUGIN_HANDLED;

	static ret;

	return ExecuteForward(forwardHandle, ret, paramOne, paramTwo);
}

stock execute_forward_ignore_three_params(forwardHandle, paramOne, paramTwo, paramThree)
{
	if (forwardHandle < COD_CONTINUE) return PLUGIN_HANDLED;

	static ret;

	return ExecuteForward(forwardHandle, ret, paramOne, paramTwo, paramThree);
}

stock get_class_info(class, info, dataReturn[] = "", dataLength = 0)
{
	new codClass[classInfo];

	ArrayGetArray(codClasses, class, codClass);

	if (info == CLASS_NAME || info == CLASS_DESC || info == CLASS_FRACTION) {
		copy(dataReturn, dataLength, codClass[info]);

		return 0;
	}

	return codClass[info];
}

stock get_class_id(className[])
{
	static codClass[classInfo];

	for (new i = 1; i < ArraySize(codClasses); i++) {
		ArrayGetArray(codClasses, i, codClass);

		if (equali(codClass[CLASS_NAME], className)) return i;
	}

	return 0;
}

stock get_item_info(item, info, dataReturn[] = "", dataLength = 0)
{
	static codItem[itemInfo];

	ArrayGetArray(codItems, item, codItem);

	if (info == ITEM_NAME || info == ITEM_DESC) {
		copy(dataReturn, dataLength, codItem[info]);

		return 0;
	}

	return codItem[info];
}

stock get_promotion_info(promotion, info, dataReturn[] = "", dataLength = 0)
{
	static codPromotion[classInfo];

	ArrayGetArray(codPromotions, promotion, codPromotion);

	if (info == CLASS_NAME || info == CLASS_DESC) {
		copy(dataReturn, dataLength, codPromotion[info]);

		return 0;
	}

	return codPromotion[info];
}

stock get_class_promotion_info(class, promotion, info, dataReturn[] = "", dataLength = 0)
{
	static codPromotion[classInfo];

	for (new i = 0; i < ArraySize(codPromotions); i++) {
		ArrayGetArray(codPromotions, i, codPromotion);

		if (codPromotion[CLASS_PROMOTION] == class && codPromotion[CLASS_DEGREE] == promotion) {
			if (info == CLASS_PROMOTION) return i;

			if (info == CLASS_NAME || info == CLASS_DESC) {
				copy(dataReturn, dataLength, codPromotion[info]);

				return 0;
			}

			return codPromotion[info];
		}
	}

	return 0;
}

stock find_class_promotion(class, promotion = PROMOTION_NONE)
{
	new classPromotion = PROMOTION_NONE;

	static codPromotion[classInfo];

	for (new i = 0; i < ArraySize(codPromotions); i++) {
		ArrayGetArray(codPromotions, i, codPromotion);

		if (codPromotion[CLASS_PROMOTION] == class && codPromotion[CLASS_DEGREE] > classPromotion && codPromotion[CLASS_DEGREE] > promotion) return classPromotion = codPromotion[CLASS_DEGREE];
	}

	return classPromotion;
}

stock get_user_class_info(id, class, info, dataReturn[] = "", dataLength = 0)
	return codPlayer[id][PLAYER_PROMOTION] ? get_promotion_info(codPlayer[id][PLAYER_PROMOTION_ID], info, dataReturn, dataLength) : get_class_info(class, info, dataReturn, dataLength);

stock clear_render(id)
	for (new i = CLASS; i <= DEATH; i++) remove_render_type(id, i);

stock remove_render_type(id, type)
{
	static codRender[renderInfo];

	for (new i = 0; i < ArraySize(codPlayerRender[id]); i++) {
		ArrayGetArray(codPlayerRender[id], i, codRender);

		if (codRender[RENDER_TYPE] == type) {
		 	if (type == ROUND || type == DEATH || type == DAMAGE_GIVEN || type == DAMAGE_TAKEN) {
		 		ArrayDeleteItem(codPlayerRender[id], i);
		 	} else {
				codRender[RENDER_VALUE] = 256;
				codRender[RENDER_STATUS] = 0;
				codRender[RENDER_WEAPON] = 0;

				ArraySetArray(codPlayerRender[id], i, codRender);
			}
		}
	}

	render_change(id);
}

stock make_explosion(ent, distance = 0, explosion = 1, Float:damageDistance = 0.0, Float:damage = 0.0, Float:factor = 0.5, suicide = 0, type = NONE)
{
	new Float:tempOrigin[3], origin[3], id;

	if (is_user_valid(ent)) id = ent;
	else id = entity_get_edict(ent, EV_ENT_owner);

	entity_get_vector(ent, EV_VEC_origin, tempOrigin);

	for (new i = 0; i < 3; i++) origin[i] = floatround(tempOrigin[i]);

	if (explosion) {
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin);
		write_byte(TE_EXPLOSION);
		write_coord(origin[0]);
		write_coord(origin[1]);
		write_coord(origin[2]);
		write_short(codSprite[SPRITE_EXPLOSION]);
		write_byte(32);
		write_byte(20);
		write_byte(0);
		message_end();
	}

	if (distance) {
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin);
		write_byte(TE_BEAMCYLINDER);
		write_coord(origin[0]);
		write_coord(origin[1]);
		write_coord(origin[2]);
		write_coord(origin[0]);
		write_coord(origin[1] + distance);
		write_coord(origin[2] + distance);
		write_short(codSprite[SPRITE_WHITE]);
		write_byte(0);
		write_byte(0);
		write_byte(10);
		write_byte(10);
		write_byte(255);

		if (type == POISON_INFECT) {
			write_byte(100);
			write_byte(255);
		} else {
			write_byte(255);
			write_byte(100);
		}

		write_byte(100);
		write_byte(128);
		write_byte(0);
		message_end();
	}

	if (damageDistance > 0.0) {
		new entList[MAX_PLAYERS + 1], foundPlayers = find_sphere_class(ent, "player", damageDistance, entList, MAX_PLAYERS), player, ret, flag;

		for (new i = 0; i < foundPlayers; i++) {
			player = entList[i];

			if (!is_user_alive(player) || (damage < 0.0 && get_user_team(id) != get_user_team(player)) || (damage > 0.0 && (get_user_team(id) == get_user_team(player) || codPlayer[player][PLAYER_RESISTANCE][ALL]))) continue;

			if (type != NONE) {
				ExecuteForward(codForwards[type], ret, id, player, floatabs(damage) + get_intelligence(id) * factor);

				if (float(ret) == COD_BLOCK) continue;

				switch (type) {
					case MEDKIT_HEAL: codPlayer[id][PLAYER_LAST_MEDKIT] += ret;
					case POISON_INFECT: codPlayer[id][PLAYER_LAST_POISON] += ret;
					case MINE_EXPLODE: codPlayer[id][PLAYER_LAST_MINE] += ret;
					case ROCKET_EXPLODE: codPlayer[id][PLAYER_LAST_ROCKET] += ret;
					case DYNAMITE_EXPLODE: codPlayer[id][PLAYER_LAST_DYNAMITE] += ret;
				}
			}

			if (damage < 0.0) {
				cod_add_user_health(player, floatround(floatabs(damage) + codPlayer[id][PLAYER_INT] * factor), 1);
			} else if (type == POISON_INFECT) {
				_cod_repeat_damage(id, player, 5.0 + get_intelligence(id) * 0.02, 1.0, 10, POISON, 1);
			} else {
				switch (type) {
					case MINE_EXPLODE: flag = DMG_MINE;
					case ROCKET_EXPLODE: flag = DMG_ROCKET;
					case DYNAMITE_EXPLODE: flag = DMG_DYNAMITE;
				}

				_cod_inflict_damage(id, player, damage, factor, DMG_CODSKILL | flag);
			}
		}
	}

	if (suicide) user_silentkill(id);
}

stock make_bar_timer(id, duration = 0, start = 0)
{
	if (!is_user_alive(id)) return;

	static msgBartimer;

	if (!msgBartimer) msgBartimer = get_user_msgid("BarTime2");

	message_begin(id ? MSG_ONE : MSG_ALL, msgBartimer, _, id);
	write_short(duration);
	write_short(start);
	message_end();
}

stock chat_print(id, const text[], any:...)
{
	new message[192];

	if (numargs() == 2) copy(message, charsmax(message), text);
	else vformat(message, charsmax(message), text, 3);

	client_print_color(id, id, "%L", id, "CORE_MESSAGE", message);
}

stock show_hud(id, const text[], type=0, red=255, green=255, blue=255, Float:x=-1.0, Float:y=0.35, effects=0, Float:fxtime=6.0, Float:holdtime=12.0, Float:fadeintime=0.1, Float:fadeouttime=0.2)
{
	if (!is_user_connected(id)) return;

	if (type) {
		set_dhudmessage(red, green, blue, x, y, effects, fxtime, holdtime, fadeintime, fadeouttime);
		show_dhudmessage(id, text);
	} else {
		static counter;

		if (++counter > 1) counter = 0;

		set_hudmessage(red, green, blue, x, y, effects, fxtime, holdtime, fadeintime, fadeouttime);
		ShowSyncHudMsg(id, counter ? hudSync2 : hudSync, text);
	}
}

stock cmd_execute(id, const text[], any:...)
{
	#pragma unused text

	new message[192];

	format_args(message, charsmax(message), 1);

	message_begin(id == 0 ? MSG_ALL : MSG_ONE, SVC_DIRECTOR, _, id);
	write_byte(strlen(message) + 2);
	write_byte(10);
	write_string(message);
	message_end();
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

stock display_fade(id, duration, holdtime, fadetype, red, green, blue, alpha)
{
	if (!is_user_connected(id)) return;

	static msgScreenFade;

	if (!msgScreenFade) msgScreenFade = get_user_msgid("ScreenFade");

	message_begin(id ? MSG_ONE : MSG_ALL, msgScreenFade, {0, 0, 0}, id);
	write_short(duration);
	write_short(holdtime);
	write_short(fadetype);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	message_end();
}

stock screen_shake(id, amplitude, duration, frequency)
{
	if (!is_user_alive(id)) return;

	static msgScreenShake;

	if (!msgScreenShake) msgScreenShake = get_user_msgid("ScreenShake");

	message_begin(MSG_ONE, msgScreenShake, {0, 0, 0}, id);
	write_short(amplitude);
	write_short(duration);
	write_short(frequency);
	message_end();
}

stock set_user_clip(id)
{
	if (!is_user_alive(id)) return;

	new weaponName[32], weaponId = -1, weapon = codPlayer[id][PLAYER_WEAPON];

	get_weaponname(weapon, weaponName, charsmax(weaponName));

	while ((weaponId = engfunc(EngFunc_FindEntityByString, weaponId, "classname", weaponName)) != 0) {
		if (pev(weaponId, pev_owner) == id && !(excludedWeapons & (1<<weaponId))) set_pdata_int(weaponId, 51, maxClipAmmo[weapon], 4);
	}
}

stock get_loguser_index()
{
	new userLog[96], userName[32];

	read_logargv(0, userLog, charsmax(userLog));

	parse_loguser(userLog, userName, charsmax(userName));

	return get_user_index(userName);
}

stock cs_get_weaponbox_type(weaponTypeBox)
{
	new weaponType, weaponBox[6] = { 34 , 35 , ... };

	for (new i = 1; i <= 5; i++) {
		weaponType = get_pdata_cbase(weaponTypeBox, weaponBox[i], 4);

		if (weaponType > 0) return cs_get_weapon_id(weaponType);
	}

	return 0;
}

stock strip_weapons(id, type, bool:switchIfActive = true)
{
	if (is_user_alive(id)) {
		new ent, weapon;

		while ((weapon = get_weapon_from_slot(id, type, ent)) > 0) ham_strip_user_weapon(id, weapon, type, switchIfActive);
	}
}

stock get_weapon_from_slot(id, slot, &ent)
{
	if (!(1 <= slot <= 5)) return 0;

	ent = get_pdata_cbase(id, 367 + slot , 5);

	return (ent > 0) ? get_pdata_int(ent, 43 , 4) : 0;
}

stock ham_strip_user_weapon(id, weaponId, slot = 0, bool:switchIfActive = true)
{
	static const weaponsSlots[] = { -1, 2, -1, 1, 4, 1, 5, 1, 1, 4, 2, 2, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 4, 2, 1, 1, 3, 1 };

	new weapon;

	if (!slot) slot = weaponsSlots[weaponId];

	weapon = get_pdata_cbase(id, 367 + slot, 5);

	while (weapon > 0) {
		if (get_pdata_int(weapon, 43, 4) == weaponId) break;

		weapon = get_pdata_cbase(weapon, 42, 4);
	}

	if (weapon > 0) {
		if (switchIfActive && get_pdata_cbase(id, 373, 5) == weapon) ExecuteHamB(Ham_Weapon_RetireWeapon, weapon);

		if (ExecuteHamB(Ham_RemovePlayerItem, id, weapon)) {
			user_has_weapon(id, weaponId, 0);

			ExecuteHamB(Ham_Item_Kill, weapon);

			return 1;
		}
	}

	return 0;
}

stock bool:is_enough_space(ent, Float:limit = 120.0)
{
	new Float:origin[3], Float:start[3], Float:end[3];

	pev(ent, pev_origin, origin);

	start[0] = end[0] = origin[0];
	start[1] = end[1] = origin[1];
	start[2] = end[2] = origin[2];

	start[0] += limit;
	end[0] -= limit;

	if (engfunc(EngFunc_PointContents, start) != CONTENTS_EMPTY && engfunc(EngFunc_PointContents, end) != CONTENTS_EMPTY) return false;

	start[0] -= limit;
	end[0] += limit;
	start[1] += limit;
	end[1] -= limit;

	if (engfunc(EngFunc_PointContents, start) != CONTENTS_EMPTY && engfunc(EngFunc_PointContents, end) != CONTENTS_EMPTY) return false;

	return true;
}

stock check_if_player_stuck(id)
{
	if (!is_user_alive(id)) return PLUGIN_HANDLED;

	new Float:origin[3];

	pev(id, pev_origin, origin);

	if (!is_hull_vacant(origin, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id) && !get_user_noclip(id) && !(pev(id, pev_solid) & SOLID_NOT)) unstuck_player(id);

	return PLUGIN_HANDLED;
}

stock unstuck_player(id)
{
	enum coords { Float:x, Float:y, Float:z };

	static Float:originalOrigin[coords], Float:newOrigin[coords];
	static attempts, distance;

	pev(id, pev_origin, originalOrigin);

	distance = 32;

	while (distance < 1000) {
		attempts = 128;

		while (attempts--) {
			newOrigin[x] = random_float(originalOrigin[x] - distance, originalOrigin[x] + distance);
			newOrigin[y] = random_float(originalOrigin[y] - distance, originalOrigin[y] + distance);
			newOrigin[z] = random_float(originalOrigin[z] - distance, originalOrigin[z] + distance);

			engfunc(EngFunc_TraceHull, newOrigin, newOrigin, DONT_IGNORE_MONSTERS, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0);

			if (get_tr2(0, TR_InOpen) && !get_tr2(0, TR_AllSolid) && !get_tr2(0, TR_StartSolid)) {
				engfunc(EngFunc_SetOrigin, id, newOrigin);

				return;
			}
		}

		distance += 32;
	}
}

stock bool:is_hull_vacant(const Float:origin[3], hull, id)
{
	static trace;

	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, trace);

	if (!get_tr2(trace, TR_StartSolid) || !get_tr2(trace, TR_AllSolid)) return true;

	return false;
}

stock const spawnEntString[2][] = {"info_player_start", "info_player_deathmatch"}

stock find_free_spawn(team, Float:spawnOrigin[3], Float:spawnAngle[3])
{
	const maxSpawns = 128;

	new spawnPoints[maxSpawns], bool:spawnChecked[maxSpawns], entList[1], spawnPoint, spawnNum, ent = -1, spawnsFound = 0, i;

	while ((ent = find_ent_by_class(ent, spawnEntString[team == 2 ? 0 : 1])) && spawnsFound < maxSpawns) spawnPoints[spawnsFound++] = ent;

	for (i = 0; i < maxSpawns; i++) spawnChecked[i] = false;

	i = 0;

	while (i++ < spawnsFound * 10) {
		spawnNum = random(spawnsFound);
		spawnPoint = spawnPoints[spawnNum];

		if (spawnPoint && !spawnChecked[spawnNum]) {
			spawnChecked[spawnNum] = true;

			pev(spawnPoint, pev_origin, spawnOrigin);

			if (!find_sphere_class(0, "player", 100.0, entList, sizeof entList, spawnOrigin)) {
				pev(spawnPoint, pev_angles, spawnAngle);

				return spawnPoint;
			}
		}
	}

	return 0;
}