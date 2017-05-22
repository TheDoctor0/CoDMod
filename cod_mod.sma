#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <nvault>
#include <fun>
#include <xs>
#include <csx>
#include <sqlx>
#include <stripweapons>
#include <cod>

#define PLUGIN "CoD Mod"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define MAX_NAME 64
#define MAX_DESC 256

#define TASK_SHOW_INFO 3357
#define TASK_SHOW_AD 4268
#define TASK_SHOW_HELP 5456
#define TASK_SPEED_LIMIT 6144
#define TASK_SET_SPEED 7532
#define TASK_END_KILL_STREAK 8779
#define TASK_RENDER 9611

#define	FL_WATERJUMP (1<<11)
#define	FL_ONGROUND	(1<<9)

new const maxAmmo[] = { 0, 52, 0, 90, 1, 31, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 31, 90, 120, 90, 2, 35, 90, 90,0, 100 };
new const maxBpAmmo[] = { 0, 30, 90, 200, 90, 32, 100, 100, 35, 52, 120 };

new const pointsDistribution[] = { 1, 3, 5, 10, 25, -1 };

new const commandClass[][] = { "klasa", "say /klasa", "say_team /klasa", "say /class", "say_team /class", "say /k", "say_team /k", "say /c", "say_team /c" };
new const commandClasses[][] = { "klasy", "say /klasy", "say_team /klasy", "say /classes", "say_team /classes", "say /ky", "say_team /ky", "say /cs", "say_team /cs" };
new const commandItem[][] = { "item", "say /item", "say_team /item", "say /przedmiot", "say_team /przedmiot", "say /perk", "say_team /perk", "say /i", "say_team /i", "say /p", "say_team /p" };
new const commandItems[][] = { "itemy", "say /itemy", "say_team /itemy", "say /przedmioty", "say_team /przedmioty", "say /perks", "say_team /perks", "say /perki", "say_team /perki", "say /perks", "say_team /perks", "say /iy", "say_team /iy", "say /py", "say_team /py" };
new const commandDrop[][] = { "wyrzuc", "say /wyrzuc", "say_team /wyrzuc", "say /drop", "say_team /drop", "say /w", "say_team /w", "say /d", "say_team /d" };
new const commandReset[][] = { "reset", "say /reset", "say_team /reset", "say /r", "say_team /r" };
new const commandPoints[][] = { "punkty", "say /statystyki", "say_team /statystyki", "say /punkty", "say_team /punkty", "say /s", "say_team /s", "say /p", "say_team /p" };
new const commandHud[][] = { "hud", "say /hud", "say_team /hud", "say /zmienhud", "say_team /zmienhud", "say /change_hud", "say_team /change_hud" };
new const commandBinds[][] = { "bindy", "say /bind", "say_team /bind", "say /bindy", "say_team /bindy", "say /binds", "say_team /binds" };
new const commandTop[][] = { "top", "say /toplvl", "say_team /toplvl", "say /toplevel", "say_team /toplevel", "say /toppoziom", "say_team /toppoziom", "say /ltop15", "say_team /ltop15", "say /ptop15", "say_team /ptop15" };
new const commandBlock[][] = { "fullupdate", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "rebuy", "autobuy", "hegren", "sgren", "flash", "-rocket", "-mine", "-dynamite", "-medkit", "-teleport" };

new const codPromotions[promotions][] =
{
	"Brak",
	"Zaawansowany",
	"Elitarny",
	"Mistrzowski"
};

enum _:models { MODEL_ROCKET, MODEL_MINE, MODEL_DYNAMITE, MODEL_MEDKIT };

new const codModels[models][] =
{
	"models/CoDMod/rocket.mdl",
	"models/CoDMod/mine.mdl",
	"models/CoDMod/dynamite.mdl",
	"models/CoDMod/medkit.mdl"
};

enum _:sprites { SPRITE_EXPLOSION, SPRITE_WHITE };

new const codSprites[sprites][] =
{
	"sprites/dexplo.spr",
	"sprites/white.spr"
};

new codSprite[sizeof codSprites];

new allowedWeapons = 1<<CSW_KNIFE | 1<<CSW_C4;

enum _:itemInfo { ITEM_NAME[MAX_NAME], ITEM_DESC[MAX_DESC], ITEM_PLUGIN, ITEM_GIVE, ITEM_DROP, ITEM_SPAWNED, 
	ITEM_KILL, ITEM_KILLED, ITEM_SKILL_USED, ITEM_UPGRADE, ITEM_VALUE, ITEM_DAMAGE_ATTACKER, ITEM_DAMAGE_VICTIM };

enum _:classInfo { CLASS_NAME[MAX_NAME], CLASS_DESC[MAX_DESC], CLASS_FRACTION[MAX_NAME], CLASS_HEAL, 
	CLASS_INT, CLASS_STR, CLASS_COND, CLASS_STAM, CLASS_WEAPONS, CLASS_PLUGIN, CLASS_ENABLED, CLASS_DISABLED, 
	CLASS_SPAWNED, CLASS_KILL, CLASS_KILLED, CLASS_SKILL_USED, CLASS_DAMAGE_VICTIM, CLASS_DAMAGE_ATTACKER };

enum _:playerClassInfo { PCLASS_LEVEL, PCLASS_EXP, PCLASS_HEAL, PCLASS_INT, PCLASS_STAM, PCLASS_STR, PCLASS_COND, PCLASS_POINTS };

enum _:renderInfo { RENDER_TYPE, RENDER_VALUE, RENDER_STATUS, RENDER_WEAPON };

enum _:forwards { CLASS_CHANGED, ITEM_CHANGED, RENDER_CHANGED, GRAVITY_CHANGED, DAMAGE_PRE, 
	DAMAGE_POST, WEAPON_DEPLOY, KILLED, SPAWNED, CMD_START, NEW_ROUND, START_ROUND, END_ROUND };

enum _:playerInfo { PLAYER_CLASS, PLAYER_NEW_CLASS, PLAYER_PROMOTION, PLAYER_LEVEL, PLAYER_GAINED_LEVEL, PLAYER_EXP, PLAYER_GAINED_EXP, PLAYER_HEAL, PLAYER_INT, 
	PLAYER_STAM, PLAYER_STR, PLAYER_COND, PLAYER_POINTS, PLAYER_POINTS_SPEED, PLAYER_EXTR_HEAL, PLAYER_EXTR_INT, PLAYER_EXTR_STAM, PLAYER_EXTR_STR, PLAYER_EXTR_COND, 
	PLAYER_EXTR_WPNS, PLAYER_ITEM, PLAYER_ITEM_DURA, PLAYER_MAX_HP, PLAYER_SPEED, PLAYER_WEAPON, PLAYER_STATUS, PLAYER_GRAVITY, PLAYER_ROCKETS, PLAYER_LAST_ROCKET, 
	PLAYER_MINES, PLAYER_LAST_MINE, PLAYER_DYNAMITE, PLAYER_DYNAMITES, PLAYER_LAST_DYNAMITE, PLAYER_MEDKITS, PLAYER_LAST_MEDKIT, PLAYER_TELEPORTS, PLAYER_LAST_TELEPORT, 
	PLAYER_JUMPS, PLAYER_LEFT_JUMPS, PLAYER_KS, PLAYER_TIME_KS, PLAYER_RESISTANCE, PLAYER_HUD, PLAYER_HUD_RED, PLAYER_HUD_GREEN, PLAYER_HUD_BLUE, PLAYER_HUD_POSX, 
	PLAYER_HUD_POSY, PLAYER_BUNNYHOP[ALL + 1], PLAYER_MODEL[ALL + 1], PLAYER_FOOTSTEPS[ALL + 1], PLAYER_NAME[MAX_NAME] };

new codPlayer[MAX_PLAYERS + 1][playerInfo];
	
enum _:save { NORMAL, DISCONNECT, MAP_END };

new expKill, expKillHS, expDamage, expWinRound, expPlant, expDefuse, expRescue, nightExpEnabled, nightExpFrom, nightExpTo, levelLimit, levelRatio, levelPromotionFirst, 
	levelPromotionSecond, levelPromotionThird, killStreakTime, minPlayers, minBonusPlayers, maxDurability, minDamageDurability, maxDamageDurability;

new cvarExpKill, cvarExpKillHS, cvarExpDamage, cvarExpWinRound, cvarExpPlant, cvarExpDefuse, cvarExpRescue, cvarNightExpEnabled, 
	cvarNightExpFrom, cvarNightExpTo, cvarLevelLimit, cvarLevelRatio, cvarLevelPromotionFirst, cvarLevelPromotionSecond, cvarLevelPromotionThird, 
	cvarKillStreakTime, cvarMinPlayers, cvarMinBonusPlayers, cvarMaxDurability, cvarMinDamageDurability, cvarMaxDamageDurability;

new Array:codItems, Array:codClasses, Array:codFractions, Array:codPlayerClasses[MAX_PLAYERS + 1], Array:codPlayerRender[MAX_PLAYERS + 1], codForwards[forwards];

new Handle:sql, bool:freezeTime, bool:nightExp, hudInfo, hudSync, hudSync2, hudVault, playersNum, dataLoaded, resetStats, userConnected, renderTimer, roundStart, lastInfo;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	create_arrays();
	
	register_cvar("cod_sql_host", "sql.pukawka.pl", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_sql_user", "590489", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_sql_pass", "rIMxucY8RIMUEv", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_sql_db", "590489_cod", FCVAR_SPONLY|FCVAR_PROTECTED);
	
	cvarExpKill = register_cvar("cod_kill_exp", "20");
	cvarExpKillHS = register_cvar("cod_hs_exp", "10");
	cvarExpDamage = register_cvar("cod_damage_exp", "3");
	cvarExpWinRound = register_cvar("cod_win_exp", "25");
	cvarExpPlant = register_cvar("cod_bomb_exp", "25");
	cvarExpDefuse = register_cvar("cod_defuse_exp", "25");
	cvarExpRescue = register_cvar("cod_host_exp", "25");
	cvarNightExpEnabled = register_cvar("cod_night_exp", "1");
	cvarNightExpFrom = register_cvar("cod_night_exp_from", "22");
	cvarNightExpTo = register_cvar("cod_night_exp_to", "8");
	cvarLevelLimit = register_cvar("cod_max_level", "501");
	cvarLevelRatio = register_cvar("cod_level_ratio", "25");
	cvarLevelPromotionFirst = register_cvar("cod_level_promotion_first", "50");
	cvarLevelPromotionSecond = register_cvar("cod_level_promotion_second", "150");
	cvarLevelPromotionThird = register_cvar("cod_level_promotion_third", "300");
	cvarKillStreakTime = register_cvar("cod_killstreak_time", "15");
	cvarMinPlayers = register_cvar("cod_min_players", "4");
	cvarMinBonusPlayers = register_cvar("cod_min_bonus_players", "10");
	cvarMaxDurability = register_cvar("cod_max_durability", "100"); 
	cvarMinDamageDurability = register_cvar("cod_min_damage_durability", "10");
	cvarMaxDamageDurability = register_cvar("cod_max_damage_durability", "25");
	
	for(new i; i < sizeof commandClass; i++) register_clcmd(commandClass[i], "select_fraction");
	for(new i; i < sizeof commandClasses; i++) register_clcmd(commandClasses[i], "display_classes_description");
	for(new i; i < sizeof commandItem; i++) register_clcmd(commandItem[i], "display_item_description");
	for(new i; i < sizeof commandItems; i++) register_clcmd(commandItems[i], "display_items_description");
	for(new i; i < sizeof commandDrop; i++) register_clcmd(commandDrop[i], "drop_item");
	for(new i; i < sizeof commandReset; i++) register_clcmd(commandReset[i], "reset_stats");
	for(new i; i < sizeof commandPoints; i++) register_clcmd(commandPoints[i], "assign_points");
	for(new i; i < sizeof commandHud; i++) register_clcmd(commandHud[i], "change_hud");
	for(new i; i < sizeof commandBinds; i++) register_clcmd(commandBinds[i], "show_binds");
	for(new i; i < sizeof commandTop; i++) register_clcmd(commandTop[i], "level_top");
	for(new i; i < sizeof commandBlock; i++) register_clcmd(commandBlock[i], "block_command");

	register_clcmd("+rocket", "use_rocket");
	register_clcmd("+mine", "use_mine");
	register_clcmd("+dynamite", "use_dynamite");
	register_clcmd("+medkit", "use_medkit");
	register_clcmd("+teleport", "use_teleport");
	
	register_impulse(100, "use_item");
	
	register_touch("rocket", "*" , "touch_rocket");
	register_touch("mine", "player" , "touch_mine");
	register_think("medkit", "think_medkit");
	
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1);
	RegisterHam(Ham_TakeDamage, "player", "player_take_damage_pre", 0);
	RegisterHam(Ham_TakeDamage, "player", "player_take_damage_post", 1);
	RegisterHam(Ham_Touch, "armoury_entity", "touch_weapon");
	RegisterHam(Ham_Touch, "weapon_shield", "touch_weapon");
	RegisterHam(Ham_Touch, "weaponbox", "touch_weapon");
	RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "player_reset_max_speed", 1);
	RegisterHam(Ham_Spawn, "func_buyzone", "block_buyzone");

	new const weapons[][] = { "weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", 
		"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_galil", 
		"weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", 
		"weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", "weapon_knife", "weapon_p90" };
	
	for (new i = 0; i < sizeof weapons; i++) RegisterHam(Ham_Item_Deploy, weapons[i], "weapon_deploy_post", 1);
	
	register_logevent("round_start", 2, "1=Round_Start");
	register_logevent("round_end", 2, "1=Round_End");	
	
	register_event("HLTV", "new_round", "a", "1=0", "2=0");
	register_event("Health", "message_health", "be", "1!255");
	register_event("SendAudio", "t_win_round" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "ct_win_round", "a", "2&%!MRAD_ct_win_round");
	register_event("TextMsg", "hostages_rescued", "a", "2&#All_Hostages_R");
	
	register_forward(FM_CmdStart, "cmd_start");
	register_forward(FM_EmitSound, "sound_emit");
	
	register_message(get_user_msgid("SayText"), "say_text");
	register_message(get_user_msgid("AmmoX"), "message_ammo");
	register_message(SVC_INTERMISSION, "message_intermission");
	
	hudSync = CreateHudSyncObj();
	hudSync2 = CreateHudSyncObj();
	hudInfo = CreateHudSyncObj();

	hudVault = nvault_open("cod_hud");
	
	if(hudVault == INVALID_HANDLE) set_fail_state("[COD] Nie mozna otworzyc pliku cod_hud.vault");
	
	codForwards[CLASS_CHANGED] = CreateMultiForward("cod_class_changed", ET_CONTINUE, FP_CELL, FP_CELL);
	codForwards[ITEM_CHANGED] = CreateMultiForward("cod_item_changed", ET_CONTINUE, FP_CELL, FP_CELL);
	codForwards[RENDER_CHANGED] = CreateMultiForward("cod_render_changed", ET_IGNORE, FP_CELL);
	codForwards[GRAVITY_CHANGED] = CreateMultiForward("cod_gravity_changed", ET_IGNORE, FP_CELL);
	codForwards[DAMAGE_PRE] = CreateMultiForward ("cod_damage_pre", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL);
	codForwards[DAMAGE_POST] = CreateMultiForward ("cod_damage_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL);
	codForwards[WEAPON_DEPLOY] = CreateMultiForward("cod_weapon_deploy", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	codForwards[KILLED] = CreateMultiForward("cod_killed", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	codForwards[SPAWNED] = CreateMultiForward("cod_spawned", ET_IGNORE, FP_CELL);
	codForwards[CMD_START] = CreateMultiForward("cod_cmd_start", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	codForwards[NEW_ROUND] = CreateMultiForward("cod_new_round", ET_IGNORE);
	codForwards[START_ROUND] = CreateMultiForward("cod_start_round", ET_IGNORE);
	codForwards[END_ROUND] = CreateMultiForward("cod_end_round", ET_IGNORE);
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
	register_native("cod_set_user_class", "_cod_set_user_class", 1);
	register_native("cod_get_classid", "_cod_get_classid", 1);
	register_native("cod_get_class_name", "_cod_get_class_name", 1);
	register_native("cod_get_class_desc", "_cod_get_class_desc", 1);
	register_native("cod_get_class_health", "_cod_get_class_health", 1);
	register_native("cod_get_class_intelligence", "_cod_get_class_intelligence", 1);
	register_native("cod_get_class_stamina", "_cod_get_class_stamina", 1);
	register_native("cod_get_class_strength", "_cod_get_class_strength", 1);
	register_native("cod_get_class_condition", "_cod_get_class_condition", 1);
	register_native("cod_get_classes_num", "_cod_get_classes_num", 1);
	
	register_native("cod_get_user_item", "_cod_get_user_item", 1);
	register_native("cod_set_user_item", "_cod_set_user_item", 1);
	register_native("cod_upgrade_user_item", "_cod_upgrade_user_item", 1)
	register_native("cod_get_itemid", "_cod_get_itemid", 1);
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
	
	register_native("cod_get_user_rockets", "_cod_get_user_rockets", 1);
	register_native("cod_get_user_mines", "_cod_get_user_mines", 1);
	register_native("cod_get_user_dynamites", "_cod_get_user_dynamites", 1);
	register_native("cod_get_user_medkits", "_cod_get_user_medkits", 1);
	register_native("cod_get_user_teleports", "_cod_get_user_teleports", 1);
	register_native("cod_get_user_multijumps", "_cod_get_user_multijumps", 1);
	register_native("cod_get_user_gravity", "_cod_get_user_gravity", 1);
	register_native("cod_get_user_armor", "_cod_get_user_armor", 1);
	
	register_native("cod_set_user_rockets", "_cod_set_user_rockets", 1);
	register_native("cod_set_user_mines", "_cod_set_user_mines", 1);
	register_native("cod_set_user_dynamites", "_cod_set_user_dynamites", 1);
	register_native("cod_set_user_medkits", "_cod_set_user_medkits", 1);
	register_native("cod_set_user_teleports", "_cod_set_user_teleports", 1);
	register_native("cod_set_user_multijumps", "_cod_set_user_multijumps", 1);
	register_native("cod_set_user_gravity", "_cod_set_user_gravity", 1);
	register_native("cod_set_user_armor", "_cod_set_user_armor", 1);
	
	register_native("cod_add_user_rockets", "_cod_add_user_rockets", 1);
	register_native("cod_add_user_mines", "_cod_add_user_mines", 1);
	register_native("cod_add_user_dynamites", "_cod_add_user_dynamites", 1);
	register_native("cod_add_user_medkits", "_cod_add_user_medkits", 1);
	register_native("cod_add_user_teleports", "_cod_add_user_teleports", 1);
	register_native("cod_add_user_multijumps", "_cod_add_user_multijumps", 1);
	register_native("cod_add_user_gravity", "_cod_add_user_gravity", 1);
	register_native("cod_add_user_armor", "_cod_add_user_armor", 1);

	register_native("cod_use_user_rocket", "_cod_use_user_rocket", 1);
	register_native("cod_use_user_mine", "_cod_use_user_mine", 1);
	register_native("cod_use_user_dynamite", "_cod_use_user_dynamite", 1);
	register_native("cod_use_user_medkit", "_cod_use_user_medkit", 1);
	register_native("cod_use_user_teleport", "_cod_use_user_teleport", 1);
	
	register_native("cod_get_user_resistance", "_cod_get_user_resistance", 1);
	register_native("cod_get_user_bunnyhop", "_cod_get_user_bunnyhop", 1);
	register_native("cod_get_user_footsteps", "_cod_get_user_footsteps", 1);
	register_native("cod_get_user_model", "_cod_get_user_model", 1);
	
	register_native("cod_set_user_resistance", "_cod_set_user_resistance", 1);
	register_native("cod_set_user_bunnyhop", "_cod_set_user_bunnyhop", 1);
	register_native("cod_set_user_footsteps", "_cod_set_user_footsteps", 1);
	register_native("cod_set_user_model", "_cod_set_user_model", 1);
	
	register_native("cod_give_weapon", "_cod_give_weapon", 1);
	register_native("cod_take_weapon", "_cod_take_weapon", 1);

	register_native("cod_get_user_render", "_cod_get_user_render", 1);
	register_native("cod_set_user_render", "_cod_set_user_render", 1);
	register_native("cod_set_user_glow", "_cod_set_user_glow", 1);
	
	register_native("cod_show_hud", "_cod_show_hud", 1);
	register_native("cod_make_bartimer", "_cod_make_bartimer", 1);
	register_native("cod_display_fade", "_cod_display_fade", 1);
	register_native("cod_screen_shake", "_cod_screen_shake", 1);
	register_native("cod_make_explosion", "_cod_make_explosion", 1);
	register_native("cod_inflict_damage", "_cod_inflict_damage", 1);
	register_native("cod_kill_player", "_cod_kill_player", 1);
	
	register_native("cod_register_item", "_cod_register_item");
	register_native("cod_register_class", "_cod_register_class");
}

public plugin_cfg()
{
	new configPath[64];
	
	get_localinfo("amxx_configsdir", configPath, charsmax(configPath));
	
	server_cmd("exec %s/cod_mod.cfg", configPath);
	server_exec();

	server_cmd("sv_maxspeed 500");

	set_cvars();
	
	sql_init();

	if(nightExpEnabled)
	{
		set_task(5.0, "check_time", _, _, _, "b");
		set_task(240.0, "night_exp_info", _, _, _, "b");
	}
}

public plugin_end()
{
	SQL_FreeHandle(sql);

	for(new i = 0; i < sizeof codForwards; i++) DestroyForward(i);

	for(new i = 0; i < ArraySize(codItems); i++) for(new j = ITEM_GIVE; j <= ITEM_UPGRADE; j++) DestroyForward(get_item_info(i, j));

	for(new i = 0; i < ArraySize(codClasses); i++) for(new j = CLASS_ENABLED; j <= CLASS_SKILL_USED; j++) DestroyForward(get_class_info(i, j));
	
	ArrayDestroy(codItems);
	ArrayDestroy(codClasses);
	ArrayDestroy(codFractions);
	
	for(new i = 1; i <= MAX_PLAYERS; i++)
	{
		ArrayDestroy(codPlayerClasses[i]);
		ArrayDestroy(codPlayerRender[i]);
	}
}

public plugin_precache()
{	
	for(new i = 0; i < sizeof codSounds; i++) precache_sound(codSounds[i]);

	for(new i = 0; i < sizeof codModels; i++) precache_model(codModels[i]);
	
	for(new i = 0; i < sizeof codSprites; i++) codSprite[i] = precache_model(codSprites[i]);
}

public client_connect(id)
{	
	reset_player(id);
	
	if(is_user_bot(id) || is_user_hltv(id)) return;

	ArrayClear(codPlayerClasses[id]);

	new codPlayerClass[playerClassInfo];

	for(new i = 0; i < ArraySize(codClasses); i++) ArrayPushArray(codPlayerClasses[id], codPlayerClass);
	
	get_user_name(id, codPlayer[id][PLAYER_NAME], charsmax(codPlayer[]));
	
	mysql_escape_string(codPlayer[id][PLAYER_NAME], codPlayer[id][PLAYER_NAME], charsmax(codPlayer[]));
	
	load_data(id);
}

public client_putinserver(id)
{
	playersNum++;

	set_bit(id, userConnected);
	
	show_bonus_info();
	
	if(is_user_bot(id) || is_user_hltv(id)) return;
	
	set_task(20.0, "show_advertisement", id + TASK_SHOW_AD);

	set_task(5.0, "set_speed_limit", id + TASK_SPEED_LIMIT);

	set_task(90.0, "show_help", id + TASK_SHOW_HELP, _, _, "b");
	
	set_task(0.1, "show_info", id + TASK_SHOW_INFO, _, _, "b");
}

public client_disconnected(id)
{
	if(get_bit(id, userConnected)) playersNum--;
	
	save_data(id, DISCONNECT);

	remove_tasks(id);
	
	remove_ents(id);
}

public create_arrays()
{
	new codItem[itemInfo], codClass[classInfo], codRender[renderInfo];

	codItems = ArrayCreate(itemInfo);
	codClasses = ArrayCreate(classInfo);
	codFractions = ArrayCreate(MAX_NAME);
	
	for(new i = 1; i <= MAX_PLAYERS; i++)
	{
		codPlayerClasses[i] = ArrayCreate(playerClassInfo);
		codPlayerRender[i] = ArrayCreate(renderInfo);
	}

	formatex(codItem[ITEM_NAME], charsmax(codItem[ITEM_NAME]), "Brak");
	formatex(codItem[ITEM_DESC], charsmax(codItem[ITEM_DESC]), "Zabij kogos, aby zdobyc przedmiot");
	
	ArrayPushArray(codItems, codItem);
	
	formatex(codClass[CLASS_NAME], charsmax(codClass[CLASS_NAME]), "Brak");

	ArrayPushArray(codClasses, codClass);

	codRender[RENDER_VALUE] = 256;
	codRender[RENDER_TYPE] = CLASS;

	for(new i = 1; i <= MAX_PLAYERS; i++) ArrayPushArray(codPlayerRender[i], codRender);

	codRender[RENDER_TYPE] = ITEM;

	for(new i = 1; i <= MAX_PLAYERS; i++) ArrayPushArray(codPlayerRender[i], codRender);
}

public select_fraction(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	if(!get_bit(id, dataLoaded))
	{
		cod_print_chat(id, "Trwa wczytywanie twoich klas...");
		
		return PLUGIN_HANDLED;
	}
	
	if(ArraySize(codFractions))
	{
		client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

		new fractionName[MAX_NAME], menu = menu_create("\yWybierz \rFrakcje\w:", "select_fraction_handle");
	
		for(new i = 0; i < ArraySize(codFractions); i++)
		{
			ArrayGetString(codFractions, i, fractionName, charsmax(fractionName));
		
			menu_additem(menu, fractionName, fractionName);
		}
	
		menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
		menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
		menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");

		menu_display(id, menu);
	}
	else select_class(id);

	return PLUGIN_HANDLED;
}
 
public select_fraction_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128], menuClassName[64], menuClassId[5], itemData[MAX_NAME], classId = codPlayer[id][PLAYER_CLASS], codClass[classInfo], itemAccess, menuCallback;

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, menuCallback);
	
	menu_destroy(menu);
	
	new menu = menu_create("\yWybierz \rKlase\w:", "select_class_handle");

	for(new i = 1; i < ArraySize(codClasses); i++)
	{
		ArrayGetArray(codClasses, i, codClass);
		
		if(equal(itemData, codClass[CLASS_FRACTION]))
		{
			load_class(id, i);

			if(codPlayer[id][PLAYER_PROMOTION] > PROMOTION_NONE) formatex(menuClassName, charsmax(menuClassName), "%s %s", codPromotions[codPlayer[id][PLAYER_PROMOTION]], codClass[CLASS_NAME]);
			else formatex(menuClassName, charsmax(menuClassName), codClass[CLASS_NAME]);
			
			formatex(menuData, charsmax(menuData), "%s \yPoziom: %i \d(%s)", menuClassName, codPlayer[id][PLAYER_LEVEL], get_weapons(codClass[CLASS_WEAPONS]));
			
			num_to_str(i, menuClassId, charsmax(menuClassId));

			menu_additem(menu, menuData, menuClassId);
		}
	}
	
	load_class(id, classId);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public select_class(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	if(!cod_check_account(id)) return PLUGIN_HANDLED;
		
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128], menuClassName[64], menuClassId[5], codClass[classInfo], classId = codPlayer[id][PLAYER_CLASS], menu = menu_create("\yWybierz \rKlase\w:", "select_class_confirm");

	for(new i = 1; i < ArraySize(codClasses); i++)
	{
		ArrayGetArray(codClasses, i, codClass);

		load_class(id, i);

		formatex(menuClassName, charsmax(menuClassName), codClass[CLASS_NAME]);

		if(codPlayer[id][PLAYER_PROMOTION] > PROMOTION_NONE) formatex(menuClassName, charsmax(menuClassName), "%s %s", codPromotions[codPlayer[id][PLAYER_PROMOTION]], codClass[CLASS_NAME]);
		else formatex(menuClassName, charsmax(menuClassName), codClass[CLASS_NAME]);

		formatex(menuData, charsmax(menuData), "%s \yPoziom: %i \d(%s)", menuClassName, codPlayer[id][PLAYER_LEVEL], get_weapons(codClass[CLASS_WEAPONS]));

		num_to_str(i, menuClassId, charsmax(menuClassId));

		menu_additem(menu, menuData, menuClassId);
	}
	
	load_class(id, classId);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public select_class_confirm(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[192], codClass[classInfo], classFraction[64], itemData[5], itemAccess, menuCallback;
	
	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, menuCallback);

	new class = str_to_num(itemData);

	if(class == codPlayer[id][PLAYER_CLASS] && !codPlayer[id][PLAYER_NEW_CLASS])
	{
		cod_print_chat(id, "To twoja aktualnie wybrana klasa.");

		return PLUGIN_CONTINUE;
	}

	menu_destroy(menu);
	
	ArrayGetArray(codClasses, class, codClass);

	if(codClass[CLASS_FRACTION][0]) formatex(classFraction, charsmax(classFraction), "^n\yFrakcja: \w%s", codClass[CLASS_FRACTION]);
	
	format(menuData, charsmax(menuData), "\wOpis \rKlasy^n^n\yKlasa: \w%s%s^n\yZycie: \w%i^n\yBronie:\w %s^n\yOpis: \w%s^n%s", codClass[CLASS_NAME], classFraction, 100 + codClass[CLASS_HEAL], get_weapons(codClass[CLASS_WEAPONS]), codClass[CLASS_DESC], codClass[CLASS_DESC][79]);

	menu = menu_create(menuData, "select_class_confirm_handle");

	menu_additem(menu, "Zagraj ta klasa", itemData);
	menu_additem(menu, "Wybierz inna klase");

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public select_class_confirm_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	if(item) select_fraction(id);
	else
	{
		client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
		
		new itemData[5], itemAccess, menuCallback;
		
		menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, menuCallback);
		
		new class = str_to_num(itemData);
		
		codPlayer[id][PLAYER_NEW_CLASS] = class;
		
		if(codPlayer[id][PLAYER_CLASS]) cod_print_chat(id, "Klasa zostanie zmieniona w nastepnej rundzie.");
		else set_new_class(id);
	}

	menu_destroy(menu);
	
	return PLUGIN_HANDLED;
}

public display_classes_description(id, class, sound)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
		
	if(sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new className[MAX_NAME], classId[5], menu = menu_create("\yWybierz \rKlase\w:", "display_classes_description_handle");

	for(new i = 1; i < ArraySize(codClasses); i++)
	{
		get_class_info(i, CLASS_NAME, className, charsmax(className));

		num_to_str(i, classId, charsmax(classId));
		
		menu_additem(menu, className, classId);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu, class / 7);

	return PLUGIN_HANDLED;
}

public display_classes_description_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[192], codClass[classInfo], classId[5], itemAccess, menuCallback;
	
	menu_item_getinfo(menu, item, itemAccess, classId, charsmax(classId), _, _, menuCallback);
	
	new class = str_to_num(classId);

	menu_destroy(menu);
	
	ArrayGetArray(codClasses, class, codClass);
	
	format(menuData, charsmax(menuData), "\wOpis \rKlasy^n^n\yKlasa: \w%s^n\yFrakcja: \w%s^n\yZycie: \w%i^n\yBronie:\w %s^n\yOpis: \w%s^n%s", codClass[CLASS_NAME], codClass[CLASS_FRACTION], 100 + codClass[CLASS_HEAL], get_weapons(codClass[CLASS_WEAPONS]), codClass[CLASS_DESC], codClass[CLASS_DESC][79]);

	menu = menu_create(menuData, "classes_description_handle");

	menu_additem(menu, "Powrot", classId);
	menu_additem(menu, "Wyjscie");

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public classes_description_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == 1)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new classId[5], itemAccess, menuCallback;
	
	menu_item_getinfo(menu, item, itemAccess, classId, charsmax(classId), _, _, menuCallback);

	menu_destroy(menu);

	display_classes_description(id, str_to_num(classId), 1);

	return PLUGIN_HANDLED;
}

public display_item_description(id)
{
	show_item_description(id, codPlayer[id][PLAYER_ITEM], 0);

	return PLUGIN_HANDLED;
}
	
public display_items_description(id, page, sound)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new itemName[MAX_NAME], menu = menu_create("\yWybierz \rPrzedmiot\w:", "display_items_description_handle");
	
	for(new i = 1; i < ArraySize(codItems); i++)
	{
		get_item_info(i, ITEM_NAME, itemName, charsmax(itemName));
		
		menu_additem(menu, itemName);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu, page);

	return PLUGIN_HANDLED;
}

public display_items_description_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
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

	get_item_info(item, ITEM_DESC, itemDescription, charsmax(itemDescription));
	get_item_info(item, ITEM_NAME, itemName, charsmax(itemName));

	cod_print_chat(id, "Przedmiot:^x03 %s^x01.", itemName);

	if(get_item_info(item, ITEM_VALUE) > 0)
	{
		if(!info)
		{
			new itemValue[6], itemTempValue = get_user_item_value(id);

			num_to_str(itemTempValue, itemValue, charsmax(itemValue));

			format(itemDescription, charsmax(itemDescription), itemDescription, itemValue);

			cod_print_chat(id, "Opis:^x03 %s^x01.", itemDescription);
		}
		else
		{
			format(itemDescription, charsmax(itemDescription), itemDescription, "x");

			cod_print_chat(id, "Opis:^x03 %s^x01.", itemDescription);
		}
	}
	else cod_print_chat(id, "Opis:^x03 %s^x01.", itemDescription);

	return PLUGIN_HANDLED;
}

public drop_item(id)
{
	if(codPlayer[id][PLAYER_ITEM])
	{
		new itemName[MAX_NAME];
		
		get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_NAME, itemName, charsmax(itemName));
		
		cod_print_chat(id, "Wyrzuciles przedmiot:^x03 %s^x01.", itemName);
		
		set_item(id);
	}
	else cod_print_chat(id, "Nie masz zadnego^x03 przedmiotu^x01.");

	return PLUGIN_HANDLED;
}

public reset_stats(id)
{
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	if(!is_user_alive(id))
	{
		reset_points(id);
		
		return PLUGIN_CONTINUE;
	}
	
	set_bit(id, resetStats);

	cod_print_chat(id, "Twoje umiejetnosci zostana zresetowane w kolejnej rudzie.");
	
	return PLUGIN_CONTINUE;
}

public reset_points(id)
{
	if(!is_user_connected(id)) return;
	
	rem_bit(id, resetStats);
	
	codPlayer[id][PLAYER_POINTS] = (codPlayer[id][PLAYER_LEVEL] - 1);
	codPlayer[id][PLAYER_INT] = 0;
	codPlayer[id][PLAYER_HEAL] = 0;
	codPlayer[id][PLAYER_COND] = 0;
	codPlayer[id][PLAYER_STR] = 0;
	codPlayer[id][PLAYER_STAM] = 0;
	
	if(codPlayer[id][PLAYER_POINTS]) assign_points(id, 0);
}

public assign_points(id, sound)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	if(!cod_check_account(id)) return PLUGIN_HANDLED;
	
	if(!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128];
	
	format(menuData, charsmax(menuData), "\yPrzydziel \rPunkty \y(\r%i\y)\w:", codPlayer[id][PLAYER_POINTS]);
	
	new menu = menu_create(menuData, "assign_points_handler");
	
	if(pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]] == -1) format(menuData, charsmax(menuData), "Ile dodawac: \rWszystko \y(Ile punktow dodac do statystyk)");
	else format(menuData, charsmax(menuData), "Ile dodawac: \r%d \y(Ile punktow dodac do statystyk)", pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]]);

	menu_additem(menu, menuData);
	
	menu_addblank(menu, 0);

	format(menuData, charsmax(menuData), "Zdrowie: \r%i \y(Zwieksza o %i liczbe punktow zycia)", get_health(id, 1, 1, 1, 0), get_health(id, 1, 1, 1, 0));
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "Inteligencja: \r%i \y(Zwieksza o %0.1f%s sile itemow i umiejetnosci klas)",  get_intelligence(id, 1, 1, 1), get_intelligence(id, 1, 1, 1) / 2.0, "%");
	menu_additem(menu, menuData);

	format(menuData, charsmax(menuData), "Sila: \r%i \y(Zwieksza o %0.1f zadawane obrazenia)", get_strength(id, 1, 1, 1), get_strength(id, 1, 1, 1) / 10.0);
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "Wytrzymalosc: \r%i \y(Zmniejsza o %0.1f%s otrzymywane obrazenia)", get_stamina(id, 1, 1, 1), get_stamina(id, 1, 1, 1) / 4.0, "%");
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "Kondycja: \r%i \y(Zwieksza o %0.1f%s predkosc poruszania)", get_condition(id, 1, 1, 1), get_condition(id, 1, 1, 1) * 0.85 / 250.0 * 100.0, "%");
	menu_additem(menu, menuData);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public assign_points_handler(id, menu, item) 
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	if(codPlayer[id][PLAYER_POINTS] < 1) return PLUGIN_CONTINUE;

	new pointsDistributionAmount = (pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]] == -1) ? codPlayer[id][PLAYER_POINTS] 
	: (pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]] > codPlayer[id][PLAYER_POINTS] ? codPlayer[id][PLAYER_POINTS] : pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]]);
	
	switch(item) 
	{ 
		case 0: if(++codPlayer[id][PLAYER_POINTS_SPEED] >= sizeof(pointsDistribution)) codPlayer[id][PLAYER_POINTS_SPEED] = 0;     
		case 1: 
		{
			if(codPlayer[id][PLAYER_HEAL] < levelLimit/5) 
			{
				if(pointsDistributionAmount > levelLimit/5 - codPlayer[id][PLAYER_HEAL]) pointsDistributionAmount = levelLimit/5 - codPlayer[id][PLAYER_HEAL];

				codPlayer[id][PLAYER_HEAL] += pointsDistributionAmount;
				codPlayer[id][PLAYER_POINTS] -= pointsDistributionAmount;
			}
			else cod_print_chat(id, "Maksymalny poziom sily osiagniety!");
		} 
		case 2: 
		{       
			if(codPlayer[id][PLAYER_INT] < levelLimit/5) 
			{
				if(pointsDistributionAmount > levelLimit/5 - codPlayer[id][PLAYER_INT]) pointsDistributionAmount = levelLimit/5 - codPlayer[id][PLAYER_INT];

				codPlayer[id][PLAYER_INT] += pointsDistributionAmount;
				codPlayer[id][PLAYER_POINTS] -= pointsDistributionAmount;

			} 
			else cod_print_chat(id, "Maksymalny poziom inteligencji osiagniety!");                       
		}
		case 3: 
		{       
			if(codPlayer[id][PLAYER_STR] < levelLimit/5) 
			{
				if(pointsDistributionAmount > levelLimit/5 - codPlayer[id][PLAYER_STR]) pointsDistributionAmount = levelLimit/5 - codPlayer[id][PLAYER_STR];

				codPlayer[id][PLAYER_STR] += pointsDistributionAmount;
				codPlayer[id][PLAYER_POINTS] -= pointsDistributionAmount;
			} 
			else cod_print_chat(id, "Maksymalny poziom sily osiagniety!");
		}
		case 4: 
		{       
			if(codPlayer[id][PLAYER_STAM] < levelLimit/5) 
			{
				if(pointsDistributionAmount > levelLimit/5 - codPlayer[id][PLAYER_STAM]) pointsDistributionAmount = levelLimit/5 - codPlayer[id][PLAYER_STAM];

				codPlayer[id][PLAYER_STAM] += pointsDistributionAmount;
				codPlayer[id][PLAYER_POINTS] -= pointsDistributionAmount;
			} 
			else cod_print_chat(id, "Maksymalny poziom wytrzymalosci osiagniety!");
		}
		case 5: 
		{       
			if(codPlayer[id][PLAYER_COND] < levelLimit/5) 
			{
				if(pointsDistributionAmount > levelLimit/5 - codPlayer[id][PLAYER_COND]) pointsDistributionAmount = levelLimit/5 - codPlayer[id][PLAYER_COND];

				codPlayer[id][PLAYER_COND] += pointsDistributionAmount;
				codPlayer[id][PLAYER_POINTS] -= pointsDistributionAmount;
			} 
			else cod_print_chat(id, "Maksymalny poziom kondycji osiagniety!");
		}
	}

	if(item) save_data(id, NORMAL);

	menu_destroy(menu);

	if(codPlayer[id][PLAYER_POINTS] > 0) assign_points(id, 1);

	return PLUGIN_HANDLED;
}

public change_hud(id, sound)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	if(!cod_check_account(id)) return PLUGIN_HANDLED;
		
	if(!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[128], menu = menu_create("\yKonfiguracja \rHUD\w", "change_hud_handle");
	
	format(menuData, charsmax(menuData), "\wSposob \yWyswietlania: \r%s", codPlayer[id][PLAYER_HUD] > TYPE_HUD ? "DHUD" : "HUD");
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "\wKolor \yCzerwony: \r%i", codPlayer[id][PLAYER_HUD_RED]);
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "\wKolor \yZielony: \r%i", codPlayer[id][PLAYER_HUD_GREEN]);
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "\wKolor \yNiebieski: \r%i", codPlayer[id][PLAYER_HUD_BLUE]);
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "\wPolozenie \yOs X: \r%i%%", codPlayer[id][PLAYER_HUD_POSX]);
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "\wPolozenie \yOs Y: \r%i%%^n", codPlayer[id][PLAYER_HUD_POSY]);
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "\yDomyslne \rUstawienia");
	menu_additem(menu, menuData);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public change_hud_handle(id, menu, item) 
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	switch(item)
	{
		case 0: if(++codPlayer[id][PLAYER_HUD] > TYPE_DHUD) codPlayer[id][PLAYER_HUD] = TYPE_HUD;
		case 1: if((codPlayer[id][PLAYER_HUD_RED] += 15) > 255) codPlayer[id][PLAYER_HUD_RED] = 0;
		case 2: if((codPlayer[id][PLAYER_HUD_GREEN] += 15) > 255) codPlayer[id][PLAYER_HUD_GREEN] = 0;
		case 3: if((codPlayer[id][PLAYER_HUD_BLUE] += 15) > 255) codPlayer[id][PLAYER_HUD_BLUE] = 0;
		case 4: if((codPlayer[id][PLAYER_HUD_POSX] += 3) > 100) codPlayer[id][PLAYER_HUD_POSX] = 0;
		case 5: if((codPlayer[id][PLAYER_HUD_POSY] += 3) > 100) codPlayer[id][PLAYER_HUD_POSY] = 0;
		case 6:
		{
			codPlayer[id][PLAYER_HUD] = TYPE_HUD;
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

public show_binds(id, sound)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
		
	if(!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menu = menu_create("\yInformacje o \rBindach\w", "show_binds_handle");
	
	menu_additem(menu, "\wRakieta \y[\r+rocket\y]");
	menu_additem(menu, "\wMina \y[\r+mine\y]");
	menu_additem(menu, "\wDynamit \y[\r+dynamite\y]");
	menu_additem(menu, "\wApteczka \y[\r+medkit\y]");
	menu_additem(menu, "\wTeleport \y[\r+teleport\y]");
	menu_addtext(menu, "^nAby zbindowac uzycie \wumiejetnosci\y pod wybrany \wklawisz", 0);
	menu_addtext(menu, "\ywpisz w \wkonsoli \rbind ^"klawisz^" ^"bind^"\y, np. \rbind ^"z^" ^"+rocket^"\y.", 0);
	menu_addtext(menu, "\yMozesz zbindowac \wwiele \yumiejetnosci pod \wjeden klawisz\y.", 0);
	menu_addtext(menu, "\yWystarczy, ze wpiszesz np. \rbind ^"z^" ^"+rocket;+mine;+dynamite^"\y.", 0);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public show_binds_handle(id, menu, item) 
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
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
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	new queryData[128], tempId[1];
	
	tempId[0] = id;

	formatex(queryData, charsmax(queryData), "SELECT name, class, level, exp FROM `cod_mod` ORDER BY exp DESC LIMIT 15");
	SQL_ThreadQuery(sql, "show_level_top", queryData, tempId, sizeof(tempId));

	return PLUGIN_HANDLED;
}

public show_level_top(failState, Handle:query, error[], errorNum, tempData[], dataSize)
{
	if(failState) 
	{
		log_to_file("cod_mod.log", "SQL Error: %s (%d)", error, errorNum);
		
		return PLUGIN_HANDLED;
	}
	
	new id = tempData[0];
	
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	new const rankColors[][] = { "#FFCC33", "#CCFFFF", "#8B4513" };
	
	static motdData[2048], name[32], class[MAX_NAME], motdLength, rank, level, exp;

	rank = 0;
	
	motdLength = format(motdData, charsmax(motdData), "<html><body bgcolor=^"#666666^"><center><table style=^"color:#FFFFFF;width:600%^">");
	motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "<tr style=color:#000000;font-weight:bold;><td>#<td>Nick<td>Klasa<td>Poziom<td>Doswiadczenie");
	
	while(SQL_MoreResults(query))
	{
		SQL_ReadResult(query, 0, name, charsmax(name));
		SQL_ReadResult(query, 1, class, charsmax(class));

		level = SQL_ReadResult(query, 2);
		exp = SQL_ReadResult(query, 3);
		
		replace_all(name, charsmax(name), "<", "");
		replace_all(name, charsmax(name), ">", "");
		
		if(rank < sizeof(rankColors)) motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "<tr style=color:%s;font-weight:bold;><td>%i.<td>%s<td>%s<td>%i<td>%i", rankColors[rank], rank + 1, name, class, level, exp);
		else motdLength += format(motdData[motdLength], charsmax(motdData) - motdLength, "<tr><td>%i.<td>%s<td>%s<td>%i<td>%i", rank + 1, name, class, level, exp);
		
		rank++;

		SQL_NextRow(query);
	}
	
	show_motd(id, motdData, "Top15 Poziomow");
	
	return PLUGIN_HANDLED;
}

public block_command()
	return PLUGIN_HANDLED;
	
public use_rocket(id)
{
	if(!is_user_alive(id) || freezeTime) return PLUGIN_HANDLED;

	if(!codPlayer[id][PLAYER_ROCKETS])
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie rakiety!");
		
		return PLUGIN_CONTINUE;
	}
	
	if(codPlayer[id][PLAYER_LAST_ROCKET] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Rakiet mozesz uzywac co 3 sekundy!");
		
		return PLUGIN_CONTINUE;
	}
	
	codPlayer[id][PLAYER_LAST_ROCKET] = floatround(get_gametime());
	codPlayer[id][PLAYER_ROCKETS]--;

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

	get_velocity_by_aim(id, 1000, velocity);
	
	entity_set_vector(ent, EV_VEC_velocity, velocity);
	
	return PLUGIN_HANDLED;
}

public touch_rocket(ent)
{
	if(!is_valid_ent(ent)) return;

	make_explosion(ent, 0, 1, 190.0, 65.0, 0.5);
	
	remove_entity(ent);
}

public use_mine(id)
{
	if(!is_user_alive(id) || freezeTime) return PLUGIN_HANDLED;

	if(!codPlayer[id][PLAYER_MINES])
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie miny!");
		
		return PLUGIN_CONTINUE;
	}
	
	if(codPlayer[id][PLAYER_LAST_MINE] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Miny mozesz stawiac co 3 sekundy!");
		
		return PLUGIN_CONTINUE;
	}

	if(!(pev(id, pev_flags) & FL_ONGROUND))
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Musisz stac na podlozu, aby podlozyc mine!");

		return PLUGIN_CONTINUE;
	}
	
	if(!is_enough_space(id))
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Nie mozesz postawic miny w przejsciu!");

		return PLUGIN_CONTINUE;
	}
	
	codPlayer[id][PLAYER_LAST_MINE] = floatround(get_gametime());
	codPlayer[id][PLAYER_MINES]--;

	new Float:origin[3], ent = create_entity("info_target")
	
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

	client_cmd(id, "spk %s", codSounds[SOUND_DEPLOY]);

	return PLUGIN_HANDLED;
}

public touch_mine(ent, victim)
{
	if(!is_valid_ent(ent)) return;

	new id = entity_get_edict(ent, EV_ENT_owner);
	
	if(get_user_team(victim) == get_user_team(id)) return;

	make_explosion(ent, 0, 1, 90.0, 75.0, 0.5);
	
	remove_entity(ent);
}

public use_dynamite(id)
{
	if(!is_user_alive(id) || freezeTime) return PLUGIN_HANDLED;

	if(is_valid_ent(codPlayer[id][PLAYER_DYNAMITE]))
	{
		make_explosion(codPlayer[id][PLAYER_DYNAMITE], 250, 1, 250.0, 70.0, 0.5);
		
		remove_entity(codPlayer[id][PLAYER_DYNAMITE]);
		
		codPlayer[id][PLAYER_DYNAMITE] = 0;
		
		return PLUGIN_HANDLED;
	}
	
	if(!codPlayer[id][PLAYER_DYNAMITES])
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie dynamity!");
		
		return PLUGIN_CONTINUE;
	}
	
	if(codPlayer[id][PLAYER_LAST_DYNAMITE] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Dynamity mozesz klasc co 3 sekundy!");
		
		return PLUGIN_CONTINUE;
	}

	if(!(pev(id, pev_flags) & FL_ONGROUND))
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Musisz stac na podlozu, aby postawic dynamit!");

		return PLUGIN_CONTINUE;
	}
	
	if(!is_enough_space(id))
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Nie mozesz postawic dynamitu w przejsciu!");

		return PLUGIN_CONTINUE;
	}
	
	codPlayer[id][PLAYER_LAST_DYNAMITE] = floatround(get_gametime());
	codPlayer[id][PLAYER_DYNAMITES]--;

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

	client_cmd(id, "spk %s", codSounds[SOUND_DEPLOY]);
	
	return PLUGIN_HANDLED;
}

public use_medkit(id)
{
	if(!is_user_alive(id) || freezeTime) return PLUGIN_HANDLED;

	if(!codPlayer[id][PLAYER_MEDKITS])
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie apteczki!");
		
		return PLUGIN_CONTINUE;
	}
	
	if(codPlayer[id][PLAYER_LAST_MEDKIT] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Apteczki mozesz klasc co 3 sekundy!");
		
		return PLUGIN_CONTINUE;
	}
	
	codPlayer[id][PLAYER_LAST_MEDKIT] = floatround(get_gametime());
	codPlayer[id][PLAYER_MEDKITS]--;

	new Float:origin[3], ent = create_entity("info_target");
	
	entity_get_vector(id, EV_VEC_origin, origin);
	
	entity_set_string(ent, EV_SZ_classname, "medkit");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + 7 + 0.1);

	entity_set_model(ent, codModels[MODEL_MEDKIT]);
	set_rendering(ent, kRenderFxGlowShell, 255,0,0, kRenderFxNone, 255);
	drop_to_floor(ent);

	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);

	client_cmd(id, "spk %s", codSounds[SOUND_DEPLOY]);

	return PLUGIN_HANDLED;
}

public think_medkit(ent)
{
	if(!is_valid_ent(ent)) return PLUGIN_CONTINUE;

	new id = entity_get_edict(ent, EV_ENT_owner);

	if(entity_get_edict(ent, EV_ENT_euser2) == 1)
	{
		new Float:origin[3], bonusHealth = 5 + floatround(codPlayer[id][PLAYER_INT] * 0.5);
		
		entity_get_vector(ent, EV_VEC_origin, origin);

		new entList[33], foundPlayers = find_sphere_class(0, "player", 300.0, entList, MAX_PLAYERS, origin), player;

		for (new i = 0; i < foundPlayers; i++)
		{
			player = entList[i];

			if(get_user_team(id) != get_user_team(player) || !is_user_alive(player)) continue;

			_cod_add_user_health(player, bonusHealth, 1);
		}

		entity_set_edict(ent, EV_ENT_euser2, 0);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.5);

		return PLUGIN_CONTINUE;
	}

	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id))
	{
		remove_entity(ent);
		
		return PLUGIN_CONTINUE;
	}

	if(entity_get_float(ent, EV_FL_ltime) - 2.0 < halflife_time()) set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAlpha, 100);

	make_explosion(ent, 300, 0);

	entity_set_edict(ent, EV_ENT_euser2, 1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);

	return PLUGIN_CONTINUE;
}

public use_teleport(id)
{
	if(!is_user_alive(id) || freezeTime) return PLUGIN_HANDLED;
	
	if(codPlayer[id][PLAYER_TELEPORTS] == 0)
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie teleporty!");
		
		return PLUGIN_CONTINUE;
	}

	if(roundStart + 15.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Teleportowac mozesz sie po 15 sekundach od rozpoczecia rundy!");
		
		return PLUGIN_CONTINUE;
	}
	
	if(codPlayer[id][PLAYER_LAST_TELEPORT] + 15.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0);
		show_dhudmessage(id, "Teleportowac mozesz sie co 15 sekund!");
		
		return PLUGIN_CONTINUE;
	}

	new Float:start[3], Float:view[3], Float:end[3];
	pev(id, pev_origin, start);

	pev(id, pev_view_ofs, view);
	xs_vec_add(start, view, start);

	pev(id, pev_v_angle, end);
	engfunc(EngFunc_MakeVectors, end);
	global_get(glb_v_forward, end);
	xs_vec_mul_scalar(end, 5000.0, end);
	xs_vec_add(start, end, end);

	engfunc(EngFunc_TraceLine, start, end, 0, id, 0);
    
	new Float:dest[3];
	get_tr2(0, TR_vecEndPos, dest);
    
	if(engfunc(EngFunc_PointContents, dest) == CONTENTS_SKY) return PLUGIN_HANDLED;

	codPlayer[id][PLAYER_LAST_TELEPORT] = floatround(get_gametime());
	if(codPlayer[id][PLAYER_TELEPORTS] != -1) codPlayer[id][PLAYER_TELEPORTS]--;

	new Float:normal[3];
	get_tr2(0, TR_vecPlaneNormal, normal);
    
	xs_vec_mul_scalar(normal, 50.0, normal);
	xs_vec_add(dest, normal, dest);

	set_pev(id, pev_origin, dest);

	check_if_player_stuck(id);
	
	return PLUGIN_HANDLED;
}

public use_item(id)
{
	if(!is_user_alive(id) || !codPlayer[id][PLAYER_ITEM] || freezeTime) return PLUGIN_CONTINUE;
	
	execute_forward_ignore_one_param(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_SKILL_USED), id);
	
	return PLUGIN_CONTINUE;
}

public use_skill(id)
{
	if(!is_user_alive(id) || !codPlayer[id][PLAYER_CLASS] || freezeTime) return PLUGIN_CONTINUE;
	
	execute_forward_ignore_one_param(get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_SKILL_USED), id);

	return PLUGIN_CONTINUE;
}

public player_spawn(id)
{
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	if(codPlayer[id][PLAYER_NEW_CLASS]) set_new_class(id);
	
	if(!codPlayer[id][PLAYER_CLASS])
	{
		select_fraction(id);
		
		return PLUGIN_CONTINUE;
	}

	reset_attributes(id, ADDITIONAL);
	
	if(get_bit(id, resetStats)) reset_points(id);
	
	if(codPlayer[id][PLAYER_POINTS] > 0) assign_points(id, 0);
	
	if(codPlayer[id][PLAYER_CLASS]) execute_forward_ignore_one_param(get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_SPAWNED), id);
	
	if(codPlayer[id][PLAYER_ITEM]) execute_forward_ignore_one_param(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_SPAWNED), id);
	
	execute_forward_ignore_one_param(codForwards[SPAWNED], id);

	set_task(0.1, "set_attributes", id);

	return PLUGIN_CONTINUE;
}

public player_take_damage_pre(victim, inflictor, attacker, Float:damage, damageBits)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim) || get_user_team(victim) == get_user_team(attacker)) return HAM_IGNORED;

	static function, weapon;

	weapon = get_user_weapon(attacker);
	
	if(!(0 < inflictor <= MAX_PLAYERS)) weapon = CSW_HEGRENADE;

	if(codPlayer[victim][PLAYER_CLASS])
	{
		damage -= damage * (get_stamina(victim, 1, 1, 1) / 4.0) / 100.0;
			
		function = get_class_info(codPlayer[victim][PLAYER_CLASS], CLASS_DAMAGE_VICTIM);
		
		if(function != -1)
		{
			callfunc_begin_i(function, get_class_info(codPlayer[victim][PLAYER_CLASS], CLASS_PLUGIN));
			callfunc_push_int(attacker);
			callfunc_push_int(victim);
			callfunc_push_int(weapon);
			callfunc_push_floatrf(damage);
			callfunc_push_int(damageBits);
			callfunc_end();

			if(damage == COD_BLOCK) return HAM_SUPERCEDE;
		}
	}

	if(codPlayer[attacker][PLAYER_CLASS])
	{
		damage += get_strength(attacker, 1, 1, 1) / 10.0;

		function = get_class_info(codPlayer[attacker][PLAYER_CLASS], CLASS_DAMAGE_ATTACKER);
			
		if(function != -1 && !codPlayer[victim][PLAYER_RESISTANCE])
		{
			callfunc_begin_i(function, get_class_info(codPlayer[attacker][PLAYER_CLASS], CLASS_PLUGIN));
			callfunc_push_int(attacker);
			callfunc_push_int(victim);
			callfunc_push_int(weapon);
			callfunc_push_floatrf(damage);
			callfunc_push_int(damageBits);
			callfunc_end();

			if(damage == COD_BLOCK) return HAM_SUPERCEDE;
		}
	}

	if(codPlayer[victim][PLAYER_ITEM])
	{
		function = get_class_info(codPlayer[victim][PLAYER_ITEM], ITEM_DAMAGE_VICTIM);
			
		if(function != -1)
		{
			callfunc_begin_i(function, get_class_info(codPlayer[victim][PLAYER_ITEM], ITEM_PLUGIN));
			callfunc_push_int(attacker);
			callfunc_push_int(victim);
			callfunc_push_int(weapon);
			callfunc_push_floatrf(damage);
			callfunc_push_int(damageBits);
			callfunc_end();

			if(damage == COD_BLOCK) return HAM_SUPERCEDE;
		}
	}
		
	if(codPlayer[attacker][PLAYER_ITEM] && !codPlayer[victim][PLAYER_RESISTANCE])
	{
		function = get_class_info(codPlayer[attacker][PLAYER_ITEM], ITEM_DAMAGE_ATTACKER);
			
		if(function != -1)
		{
			callfunc_begin_i(function, get_class_info(codPlayer[attacker][PLAYER_ITEM], ITEM_PLUGIN));
			callfunc_push_int(attacker);
			callfunc_push_int(victim);
			callfunc_push_int(weapon);
			callfunc_push_floatrf(damage);
			callfunc_push_int(damageBits);
			callfunc_end();

			if(damage == COD_BLOCK) return HAM_SUPERCEDE;
		}
	}

	static ret;

	ExecuteForward(codForwards[DAMAGE_PRE], ret, attacker, victim, weapon, damage, damageBits);

	if(damage <= 0.0) return HAM_SUPERCEDE;

	SetHamParamFloat(4, damage);

	return HAM_IGNORED;
}

public player_take_damage_post(victim, inflictor, attacker, Float:damage, damageBits)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim) || !codPlayer[attacker][PLAYER_CLASS] || get_user_team(victim) == get_user_team(attacker)) return HAM_IGNORED;
	
	static ret, weapon;

	weapon = get_user_weapon(attacker);
	
	if(!(0 < inflictor <= MAX_PLAYERS)) weapon = CSW_HEGRENADE;

	ExecuteForward(codForwards[DAMAGE_POST], ret, attacker, victim, weapon, damage, damageBits);

	while(damage > 20)
	{
		damage -= 20;

		codPlayer[attacker][PLAYER_GAINED_EXP] += get_exp_bonus(attacker, expDamage);
	}
	
	check_level(attacker);
	
	return HAM_IGNORED;
}

public client_death(killer, victim, weaponId, hitPlace, teamKill)
{	
	if(!is_user_connected(killer) || !is_user_connected(victim) || !is_user_alive(killer) || get_user_team(victim) == get_user_team(killer)) return PLUGIN_CONTINUE;

	new playerName[64], className[64];
	
	if(codPlayer[killer][PLAYER_CLASS] && get_playersnum() < minPlayers)
	{
		new exp = get_exp_bonus(killer, hitPlace == HIT_HEAD ? expKill : (expKill + expKillHS));
		
		if(codPlayer[victim][PLAYER_LEVEL] > codPlayer[killer][PLAYER_LEVEL]) exp += get_exp_bonus(killer, (codPlayer[victim][PLAYER_LEVEL] - codPlayer[killer][PLAYER_LEVEL]) * (expKill/10));

		codPlayer[killer][PLAYER_GAINED_EXP] += exp;

		get_class_info(codPlayer[victim][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));

		get_user_name(victim, playerName, charsmax(playerName));

		if(codPlayer[victim][PLAYER_PROMOTION] > PROMOTION_NONE) format(className, charsmax(className), "%s %s", codPromotions[codPlayer[victim][PLAYER_PROMOTION]], className);

		cod_print_chat(killer, "Zabiles%s^x03 %s^x04 (%s - %i)^x01, dostajesz^x03 %i^x01 doswiadczenia.", hitPlace == HIT_HEAD ? " z HS" : "", playerName, className, codPlayer[victim][PLAYER_LEVEL], exp);
		
		show_dhudmessage(killer, "+%i XP", exp);
		
		codPlayer[killer][PLAYER_KS]++;
		codPlayer[killer][PLAYER_TIME_KS] = killStreakTime;
		
		if(task_exists(killer + TASK_END_KILL_STREAK)) remove_task(killer + TASK_END_KILL_STREAK);

		set_task(1.0, "end_kill_streak", killer + TASK_END_KILL_STREAK, _, _, "b");
	}
	
	if(!codPlayer[killer][PLAYER_ITEM]) set_item(killer, -1, -1);

	check_level(killer);

	get_user_name(killer, playerName, charsmax(playerName));

	get_class_info(codPlayer[killer][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));

	if(codPlayer[killer][PLAYER_PROMOTION] > PROMOTION_NONE) format(className, charsmax(className), "%s %s", codPromotions[codPlayer[killer][PLAYER_PROMOTION]], className);

	cod_print_chat(victim, "Zostales zabity przez^x03 %s^x04 (%s - %i)^x01, ktoremu zostalo^x04 %i^x01 HP.", playerName, className, codPlayer[killer][PLAYER_LEVEL], get_user_health(killer));

	if(codPlayer[killer][PLAYER_CLASS]) execute_forward_ignore_two_params(get_class_info(codPlayer[killer][PLAYER_CLASS], CLASS_KILL), killer, victim);

	if(codPlayer[killer][PLAYER_ITEM]) execute_forward_ignore_two_params(get_item_info(codPlayer[killer][PLAYER_ITEM], ITEM_KILL), killer, victim);
	
	if(codPlayer[victim][PLAYER_CLASS]) execute_forward_ignore_two_params(get_class_info(codPlayer[victim][PLAYER_CLASS], CLASS_KILLED), killer, victim);
	
	if(codPlayer[victim][PLAYER_ITEM])
	{
		execute_forward_ignore_two_params(get_item_info(codPlayer[victim][PLAYER_ITEM], ITEM_KILLED), killer, victim);
		
		codPlayer[victim][PLAYER_ITEM_DURA] -= random_num(minDamageDurability, maxDamageDurability);
		
		if(codPlayer[victim][PLAYER_ITEM_DURA] <= 0)
		{
			set_item(victim);
			
			cod_print_chat(victim, "Twoj przedmiot ulegl zniszczeniu.");
		}
		else cod_print_chat(victim, "Pozostala wytrzymalosc twojego przedmiotu to^x03 %i^x01/^x03%i^x01.", codPlayer[victim][PLAYER_ITEM_DURA], maxDurability);
	}

	new ret;

	ExecuteForward(codForwards[KILLED], ret, killer, victim, weaponId, hitPlace);
	
	return PLUGIN_CONTINUE;
}

public touch_weapon(weapon, id)
{
	if(!is_user_connected(id)) return HAM_IGNORED;

	new modelName[23];
	
	pev(weapon, pev_model, modelName, charsmax(modelName));
	
	if(containi(modelName, "w_backpack") != -1) return HAM_IGNORED;

	new playerTeam = get_user_team(id);
	
	if(playerTeam > 2) return HAM_IGNORED;

	pev(weapon, pev_classname, modelName, 2);
	
	new weaponType = ((modelName[0] == 'a') ? cs_get_armoury_type(weapon): cs_get_weaponbox_type(weapon));

	if((1 << weaponType) & (get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_WEAPONS) | codPlayer[id][PLAYER_EXTR_WPNS] | allowedWeapons)) return HAM_IGNORED;

	return HAM_SUPERCEDE;
}
	
public player_reset_max_speed(id)
{
	if(!is_user_alive(id) || freezeTime || !codPlayer[id][PLAYER_CLASS]) return HAM_IGNORED;

	new Float:speed = get_user_maxspeed(id) + Float:codPlayer[id][PLAYER_SPEED];

	set_user_maxspeed(id, speed);

	return HAM_IGNORED;
}

public block_buyzone()
    return HAM_SUPERCEDE;

public weapon_deploy_post(ent)
{
	new id = get_pdata_cbase(ent, 41, 4);

	if(!is_user_alive(id)) return HAM_IGNORED;

	new ret, weapon = codPlayer[id][PLAYER_WEAPON] = cs_get_weapon_id(ent);

	ExecuteForward(codForwards[WEAPON_DEPLOY], ret, id, weapon, ent);

	render_change(id);
	
	return HAM_IGNORED;
}

public new_round()
{
	remove_ents();
	
	set_cvars();
	
	freezeTime = true;
	
	execute_forward_ignore(codForwards[NEW_ROUND]);
}

public round_start()	
{
	freezeTime = false;

	roundStart = floatround(get_gametime());
	
	for(new id = 1; id <= MAX_PLAYERS; id++)
	{
		if(!is_user_alive(id)) continue;

		display_fade(id, 1<<9, 1<<9, 1<<12, 0, 255, 70, 100);
		
		switch(get_user_team(id))
		{
			case 1: client_cmd(id, "spk %s", codSounds[SOUND_START2]);
			case 2: client_cmd(id, "spk %s", codSounds[SOUND_START]);
		}

		if(cs_get_user_team(id) == CS_TEAM_CT) cs_set_user_defuse(id, 1);
	}
	
	execute_forward_ignore(codForwards[START_ROUND]);
}

public round_end()
	execute_forward_ignore(codForwards[END_ROUND]);

public message_health(id) 
{ 
	if(read_data(1) > 255)
	{
		message_begin(MSG_ONE, get_user_msgid("Health"), {0, 0, 0}, id);
		write_byte(255);
		message_end(); 
	} 
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
		if(!codPlayer[id][PLAYER_CLASS] || get_user_team(id) != team) continue;

		new exp = get_exp_bonus(id, expWinRound);
		
		codPlayer[id][PLAYER_GAINED_EXP] += exp;
		
		cod_print_chat(id, "Dostales^x03 %i^x01 doswiadczenia za wygrana runde.", exp);
		
		check_level(id);
	}
}

public bomb_planted(id)
{
	if(get_playersnum() < minPlayers || !codPlayer[id][PLAYER_CLASS]) return;

	new exp = get_exp_bonus(id, expPlant);
	
	codPlayer[id][PLAYER_GAINED_EXP] += exp;
	
	cod_print_chat(id, "Dostales^x03 %i^x01 doswiadczenia za podlozenie bomby.", exp);
	
	check_level(id);
}

public bomb_defused(id)
{
	if(get_playersnum() < minPlayers || !codPlayer[id][PLAYER_CLASS]) return;
	
	new exp = get_exp_bonus(id, expDefuse);
	
	codPlayer[id][PLAYER_GAINED_EXP] += exp;
	
	cod_print_chat(id, "Dostales^x03 %i^x01 doswiadczenia za rozbrojenie bomby.", exp);
	
	check_level(id);
}

public hostages_rescued()
{
	if(get_playersnum() < minPlayers) return;

	new id = get_loguser_index(), exp = get_exp_bonus(id, expRescue);

	if(!codPlayer[id][PLAYER_CLASS]) return;
	
	codPlayer[id][PLAYER_GAINED_EXP] += exp;
	
	cod_print_chat(id, "Dostales^x03 %i^x01 doswiadczenia za uratowanie zakladnikow.", exp);
	
	check_level(id);
}

stock render_change(id, playerStatus = -1)
{
	if(!is_user_alive(id) || codPlayer[id][PLAYER_STATUS] == playerStatus || get_bit(id, renderTimer)) return;

	if(playerStatus != -1) codPlayer[id][PLAYER_STATUS] = playerStatus;

	set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, render_count(id));

	execute_forward_ignore_one_param(codForwards[RENDER_CHANGED], id);
}

stock render_count(id)
{
	new render = 255, codRender[renderInfo];

	ArrayGetArray(codPlayerRender[id], CLASS, codRender);

	if(render < 256 && codRender[RENDER_STATUS] & codPlayer[id][PLAYER_STATUS] && (!codRender[RENDER_WEAPON] || codPlayer[id][PLAYER_WEAPON] & codRender[RENDER_WEAPON])) 
		render = codRender[RENDER_VALUE];

	ArrayGetArray(codPlayerRender[id], ITEM, codRender);

	if(render < 256 && codRender[RENDER_STATUS] & codPlayer[id][PLAYER_STATUS] && (!codRender[RENDER_WEAPON] || codPlayer[id][PLAYER_WEAPON] & codRender[RENDER_WEAPON])) 
		render = codRender[RENDER_VALUE] < 0 ? (render - codRender[RENDER_VALUE]) : (codRender[RENDER_VALUE] < render ? codRender[RENDER_VALUE] : render);

	for(new i = ADDITIONAL; i < ArraySize(codPlayerRender[id]); i++)
	{
		ArrayGetArray(codPlayerRender[id], i, codRender);

		if(codRender[RENDER_STATUS] & codPlayer[id][PLAYER_STATUS] && (!codRender[RENDER_WEAPON] || codPlayer[id][PLAYER_WEAPON] & codRender[RENDER_WEAPON])) 
		render = codRender[RENDER_VALUE] < 0 ? (render - codRender[RENDER_VALUE]) : (codRender[RENDER_VALUE] < render ? codRender[RENDER_VALUE] : render);
	}

	return max(0, render);
}

public render_reset(id)
{
	id -= TASK_RENDER;
	
	set_user_rendering(id);

	render_change(id);
}

public cmd_start(id, ucHandle)
{
	if(!is_user_alive(id) || freezeTime) return FMRES_IGNORED;

	static Float:velocity[3], Float:speed, button, oldButton, playerState, ret;

	button = get_uc(ucHandle, UC_Buttons);
	oldButton = pev(id, pev_oldbuttons);
	playerState = RENDER_ALWAYS;

	ExecuteForward(codForwards[CMD_START], ret, id, button, oldButton);
	
	pev(id, pev_velocity, velocity);

	speed = vector_length(velocity);

	if(get_user_maxspeed(id) > speed * 1.8) set_pev(id, pev_flTimeStepSound, 300);

	if(speed == 0.0) playerState |= RENDER_STAND;
	else playerState |= RENDER_MOVE;

	if(button & IN_DUCK) playerState |= RENDER_DUCK;

	if(pev(id, pev_gaitsequence) == 3) playerState |= RENDER_SHIFT;
	
	render_change(id, playerState);

	if(!codPlayer[id][PLAYER_JUMPS]) return FMRES_IGNORED;

	new flags = pev(id, pev_flags);

	if((button & IN_JUMP) && !(flags & FL_ONGROUND) && !(oldButton & IN_JUMP) && codPlayer[id][PLAYER_LEFT_JUMPS])
	{
		codPlayer[id][PLAYER_LEFT_JUMPS]--;
		
		pev(id, pev_velocity, velocity);
		
		velocity[2] = random_float(265.0, 285.0);
		
		set_pev(id, pev_velocity, velocity);
	}
	else if(flags & FL_ONGROUND) codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS];

	return FMRES_IGNORED;
}

public sound_emit(id, channel, sound[], Float:volume, Float:attn, flags, pitch) 
{
	if(!is_user_alive(id) || !codPlayer[id][PLAYER_CLASS]) return FMRES_IGNORED;

	if(equal(sound, "common/wpn_denyselect.wav"))
	{
		use_skill(id);

		return FMRES_SUPERCEDE;
	}

	if(equal(sound, "items/ammopickup2.wav"))
	{
		cs_set_user_armor(id, 0, CS_ARMOR_NONE);

		return FMRES_SUPERCEDE;
	}
	
	if(equal(sound, "items/equip_nvg.wav"))
	{
		cs_set_user_nvg(id, 0);

		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public client_PreThink(id)
{
	if(!is_user_alive(id) || !codPlayer[id][PLAYER_BUNNYHOP][ALL]) return PLUGIN_CONTINUE;

	entity_set_float(id, EV_FL_fuser2, 0.0);

	if(entity_get_int(id, EV_INT_button) & 2) 
	{
		new flags = entity_get_int(id , EV_INT_flags);

		if (flags & FL_WATERJUMP || entity_get_int(id, EV_INT_waterlevel) >= 2 || !(flags & FL_ONGROUND)) return PLUGIN_CONTINUE;

		new Float:velocity[3];
		
		entity_get_vector(id, EV_VEC_velocity, velocity);
		
		velocity[2] += 250.0;
		
		entity_set_vector(id, EV_VEC_velocity, velocity);

		entity_set_int(id, EV_INT_gaitsequence, 6);
	}
	
	return PLUGIN_CONTINUE;
}

public say_text(msgId, msgDest, msgEnt)
{
	new id = get_msg_arg_int(1);
	
	if(is_user_connected(id) && codPlayer[id][PLAYER_CLASS])
	{
		new tempMessage[192], message[192], chatPrefix[64];
		
		get_msg_arg_string(2, tempMessage, charsmax(tempMessage));

		get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_NAME, chatPrefix, charsmax(chatPrefix));

		if(codPlayer[id][PLAYER_PROMOTION] > PROMOTION_NONE) format(chatPrefix, charsmax(chatPrefix), "%s %s", codPromotions[codPlayer[id][PLAYER_PROMOTION]], chatPrefix);

		format(chatPrefix, charsmax(chatPrefix), "^x04[%s - %i]", chatPrefix, codPlayer[id][PLAYER_LEVEL]);
		
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

public message_ammo(msgId, msgDest, id)
{
	new weaponAmmo = get_msg_arg_int(1);

	if(is_user_alive(id) && weaponAmmo && weaponAmmo <= 10)
	{
		new weaponMaxBpAmmo = maxBpAmmo[weaponAmmo];

		if(get_msg_arg_int(2) < weaponMaxBpAmmo)
		{
			set_msg_arg_int(2, ARG_BYTE, weaponMaxBpAmmo);
			set_pdata_int(id, 376 + weaponAmmo, weaponMaxBpAmmo, 5);
		}
	}
}

public message_intermission()
	set_task(0.25, "save_players");

public save_players()
{
	for(new id = 1; id <= MAX_PLAYERS; id++)
	{
		if(!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id)) continue;

		save_data(id, MAP_END);
	}
	
	return PLUGIN_CONTINUE;
}

public show_info(id) 
{
	id -= TASK_SHOW_INFO;
	
	if(!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id))
	{
		remove_task(id + TASK_SHOW_INFO);
		
		return PLUGIN_CONTINUE;
	}
	
	static hudData[512], className[MAX_NAME], itemName[MAX_NAME], clanName[MAX_NAME], missionProgress[MAX_NAME], Float:levelPercent, exp, target;
	
	target = id;
	
	if(!is_user_alive(id))
	{
		target = pev(id, pev_iuser2);
		
		if(!codPlayer[target][PLAYER_HUD]) set_hudmessage(255, 255, 255, 0.7, 0.4, 0, 0.0, 0.3, 0.0, 0.0, 4);
		else set_dhudmessage(255, 255, 255, 0.7, 0.4, 0, 0.0, 0.3, 0.0, 0.0);
	}
	else
	{
		if (!codPlayer[target][PLAYER_HUD]) set_hudmessage(codPlayer[target][PLAYER_HUD_RED], codPlayer[target][PLAYER_HUD_GREEN], codPlayer[target][PLAYER_HUD_BLUE], float(codPlayer[target][PLAYER_HUD_POSX]) / 100.0, float(codPlayer[target][PLAYER_HUD_POSY]) / 100.0, 0, 0.0, 0.3, 0.0, 0.0, 4);
		else set_dhudmessage(codPlayer[target][PLAYER_HUD_RED], codPlayer[target][PLAYER_HUD_GREEN], codPlayer[target][PLAYER_HUD_BLUE], float(codPlayer[target][PLAYER_HUD_POSX]) / 100.0, float(codPlayer[target][PLAYER_HUD_POSY]) / 100.0, 0, 0.0, 0.3, 0.0, 0.0);
	}
	
	if(!target) return PLUGIN_CONTINUE;
	
	get_class_info(codPlayer[target][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));
	get_item_info(codPlayer[target][PLAYER_ITEM], ITEM_NAME, itemName, charsmax(itemName));
	cod_get_clan_name(cod_get_user_clan(target), clanName, charsmax(clanName));

	if(codPlayer[target][PLAYER_PROMOTION] > PROMOTION_NONE) format(className, charsmax(className), "%s %s", codPromotions[codPlayer[target][PLAYER_PROMOTION]], className);

	format(clanName, charsmax(clanName), "^n[Klan : %s]", clanName);

	if(cod_get_user_mission(id) > -1) formatex(missionProgress, charsmax(missionProgress), "^n[Misja : %i/%i (%0.1f%s)]", cod_get_user_mission_progress(id), cod_get_user_mission_need(id), float(cod_get_user_mission_progress(id))/float(cod_get_user_mission_need(id)) * 100.0, "%%");

	exp = codPlayer[target][PLAYER_LEVEL] - 1 >= 0 ? get_level_exp(codPlayer[target][PLAYER_LEVEL] - 1) : 0;
	levelPercent = codPlayer[target][PLAYER_LEVEL] < levelLimit ? (float((codPlayer[target][PLAYER_EXP] - exp)) / float((get_level_exp(codPlayer[target][PLAYER_LEVEL]) - exp))) * 100.0 : 0.0;
	
	formatex(hudData, charsmax(hudData), "[Klasa : %s]%s^n[Poziom : %i]^n[Doswiadczenie : %0.1f%s]^n[Przedmiot : %s (%i/%i)]%s^n[Zycie : %i]^n[Honor : %i]", 
	className, cod_get_user_clan(target) ? clanName : "", codPlayer[target][PLAYER_LEVEL], levelPercent, "%%", itemName, codPlayer[target][PLAYER_ITEM_DURA], maxDurability, cod_get_user_mission(id) > -1 ? missionProgress : "", get_user_health(id), cod_get_user_honor(target));
	
	if(get_exp_bonus(target, 100) > 100) format(hudData, charsmax(hudData), "%s^n[Exp Bonus : %i%s]", hudData, get_exp_bonus(target, 100) - 100, "%%");

	if(codPlayer[target][PLAYER_KS]) format(hudData, charsmax(hudData), "%s^n[KillStreak : %i (%i s)]", hudData, codPlayer[target][PLAYER_KS], codPlayer[target][PLAYER_TIME_KS]);

	switch(codPlayer[target][PLAYER_HUD])
	{
		case TYPE_HUD: ShowSyncHudMsg(id, hudInfo, hudData);
		case TYPE_DHUD: show_dhudmessage(id, hudData);
	}
	
	return PLUGIN_CONTINUE;
} 

public show_advertisement(id)
{
	id -= TASK_SHOW_AD;
	
	cod_print_chat(id, "Witaj na serwerze Call of Duty Mod stworzonym przez^x03 O'Zone^x01.");
	cod_print_chat(id, "W celu uzyskania informacji o komendach wpisz^x03 /menu^x01 (klawisz^x03 ^"v^"^x01).");
}

public show_help(id)
{
	id -= TASK_SHOW_HELP;
	
	set_hudmessage(0, 255, 0, -1.0, 0.7, 0, 5.0, 5.0, 0.1, 0.5, 11);
	
	switch(random_num(1, 16))
	{
		case 1: show_hudmessage(id, "Aby uzyc umiejetnosci klasy wcisnij klawisz E. Przedmiotow uzywa sie klawiszem F.");
		case 2: show_hudmessage(id, "Chcialbys zalozyc klan lub do niego dolaczyc? Wpisz komende /klan.");
		case 3: show_hudmessage(id, "Sposobem na zdobywanie wiekszej ilosci doswiadczenia sa /misje.");
		case 4: show_hudmessage(id, "Wpisz komende /bind, aby sprawdzic bindy wszystkich umiejetnosci.");
		case 5: show_hudmessage(id, "Sprzedaj niechciany przedmiot zamiast do wyrzucac. Zajrzyj na /rynek.");
		case 6: show_hudmessage(id, "Mozesz dowolnie konfigurowac wyswietlanie HUD uzywajac komendy /hud.");
		case 7: show_hudmessage(id, "Chcesz sprobowac swojego szczescia? Sprawdz /kasyno.");
		case 8: show_hudmessage(id, "Zajrzyj do /sklep, aby kupic dodatki, exp, jak i wymienic kase na honor.");
		case 9: show_hudmessage(id, "Aby wylaczyc/wlaczyc pokazujace sie znaczniki uzyj komendy /ikony.");
		case 10: show_hudmessage(id, "Noze dodaja bonusy do statystyk, mozesz zmienic swoj wpisujac /noz.");
		case 11: show_hudmessage(id, "Jesli chcesz przelac komus kase lub honor uzyj komendy /przelew.");
		case 12: show_hudmessage(id, "Oddaj przedmiot komenda /daj lub uzyj /wymien do wymiany z innym graczem.");
		case 13: show_hudmessage(id, "Aby zarzadzac swoim kontem - w tym zmienic haslo, wpisz komende /konto.");
		case 14: show_hudmessage(id, "Glowne menu serwera znajdziesz pod komenda /menu lub klawiszem V.");
		case 15: show_hudmessage(id, "Jesli chcesz kupic VIPa, klasy premium, exp lub honor zajrzyj do /sklepsms.");
		case 16: show_hudmessage(id, "Jest wiele dodatkowych statystyk, ktore znajdziesz pod komenda /statymenu.");
	}
}

public check_time()	
{
	static time[3], hour;

	get_time("%H", time, charsmax(time));
	
	hour = str_to_num(time);
	
	if((nightExpFrom > nightExpTo && (hour >= nightExpFrom || hour < nightExpTo)) || (hour >= nightExpFrom && hour < nightExpTo)) nightExp = true;
	else nightExp = false;	
}

public night_exp_info()
{
	if(nightExp) cod_print_chat(0, "Na serwerze wlaczony jest nocny^x03 EXP x 2^x01!");
	else cod_print_chat(0, "Od godziny^x03 %i:00^x01 do^x03 %i:00^x01 na serwerze jest^x03 EXP x 2^x01!", nightExpFrom, nightExpTo);
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
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
	
	new ret, class = codPlayer[id][PLAYER_CLASS];

	if(codPlayer[id][PLAYER_CLASS]) 
	{
		save_data(id, NORMAL);

		execute_forward_ignore_two_params(get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_DISABLED), id, codPlayer[id][PLAYER_PROMOTION]);

		reset_attributes(id, CLASS);
	}

	load_class(id, codPlayer[id][PLAYER_NEW_CLASS]);
	
	ExecuteForward(get_class_info(codPlayer[id][PLAYER_NEW_CLASS], CLASS_ENABLED), ret, id, codPlayer[id][PLAYER_PROMOTION]);
	
	if(ret == COD_STOP)	
	{
		codPlayer[id][PLAYER_NEW_CLASS] = 0;

		load_class(id, codPlayer[id][class]);
		
		select_fraction(id);
		
		return PLUGIN_CONTINUE;
	}

	codPlayer[id][PLAYER_CLASS] = codPlayer[id][PLAYER_NEW_CLASS];
	codPlayer[id][PLAYER_NEW_CLASS] = 0;

	execute_forward_ignore_two_params(codForwards[CLASS_CHANGED], id, codPlayer[id][PLAYER_CLASS]);

	if(codPlayer[id][PLAYER_POINTS] > 0) assign_points(id, 0);

	set_task(0.1, "set_attributes", id);
	
	return PLUGIN_CONTINUE;
}

stock set_item(id, item = 0, value = 0)
{
	if(!ArraySize(codItems) || !is_user_connected(id)) return PLUGIN_CONTINUE;
	
	item = (item == -1) ? random_num(1, ArraySize(codItems) - 1): item;

	new ret;
	
	if(item) ExecuteForward(get_item_info(item, ITEM_GIVE), ret, id, value);
	
	if(ret == COD_STOP)
	{
		set_item(id, -1, -1);
		
		return PLUGIN_CONTINUE;
	}

	remove_render_type(id, ITEM);
	
	if(codPlayer[id][PLAYER_ITEM]) execute_forward_ignore_one_param(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_DROP), id);	
	
	codPlayer[id][PLAYER_ITEM] = item;

	execute_forward_ignore_two_params(codForwards[ITEM_CHANGED], id, codPlayer[id][PLAYER_ITEM]);	

	if(codPlayer[id][PLAYER_ITEM])
	{
		codPlayer[id][PLAYER_ITEM_DURA] = maxDurability;

		new itemDescription[MAX_DESC], itemName[MAX_NAME], itemValue[6], itemTempValue = get_user_item_value(id);

		get_item_info(item, ITEM_DESC, itemDescription, charsmax(itemDescription));
		get_item_info(item, ITEM_NAME, itemName, charsmax(itemName));

		if(itemTempValue != -1)
		{
			num_to_str(itemTempValue, itemValue, charsmax(itemValue));

			format(itemDescription, charsmax(itemDescription), itemDescription, itemValue);
		}

		cod_print_chat(id, "Zdobyles^x03 %s^x01 -^x04 %s^x01.", itemName, itemDescription);
	}
	else codPlayer[id][PLAYER_ITEM_DURA] = 0;

	return PLUGIN_CONTINUE;
}

public check_level(id)
{	
	if(!is_user_connected(id) || !codPlayer[id][PLAYER_CLASS]) return;
	
	while((codPlayer[id][PLAYER_GAINED_EXP] + codPlayer[id][PLAYER_EXP]) >= get_level_exp(codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL]) && codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL] < levelLimit) codPlayer[id][PLAYER_GAINED_LEVEL]++;
	
	if(!codPlayer[id][PLAYER_GAINED_LEVEL]) while((codPlayer[id][PLAYER_GAINED_EXP] + codPlayer[id][PLAYER_EXP]) < get_level_exp(codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL] - 1)) codPlayer[id][PLAYER_GAINED_LEVEL]--;

	if(codPlayer[id][PLAYER_GAINED_LEVEL])
	{
		codPlayer[id][PLAYER_POINTS] = (codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL] - 1) - codPlayer[id][PLAYER_INT] - codPlayer[id][PLAYER_HEAL] - codPlayer[id][PLAYER_STAM] - codPlayer[id][PLAYER_STR] - codPlayer[id][PLAYER_COND];
		
		set_dhudmessage(212, 255, 85, 0.31, 0.32, 0, 0.0, 1.5, 0.0, 0.0);
		show_dhudmessage(id, "Awansowales do %i poziomu!", codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL]);

		check_promotion(id, 1);

		switch(random_num(1, 3))
		{
			case 1: client_cmd(id, "spk %s", codSounds[SOUND_LVLUP]);
			case 2: client_cmd(id, "spk %s", codSounds[SOUND_LVLUP2]);
			case 3: client_cmd(id, "spk %s", codSounds[SOUND_LVLUP3]);
		}
	}
	
	if(codPlayer[id][PLAYER_GAINED_LEVEL] < 0)
	{
		reset_points(id);
		
		set_dhudmessage(212, 255, 85, 0.31, 0.32, 0, 0.0, 1.5, 0.0, 0.0);
		show_dhudmessage(id, "Spadles do %i poziomu!", codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL]);
	}
	
	save_data(id, NORMAL);
}

public reset_attributes(id, type)
{
	if(task_exists(id + TASK_END_KILL_STREAK)) remove_task(id + TASK_END_KILL_STREAK);

	codPlayer[id][PLAYER_GRAVITY] = _:1.0;
	codPlayer[id][PLAYER_LAST_ROCKET] = _:0.0;
	codPlayer[id][PLAYER_LAST_MINE] = _:0.0;
	codPlayer[id][PLAYER_LAST_DYNAMITE] = _:0.0;
	codPlayer[id][PLAYER_LAST_MEDKIT] = _:0.0;
	codPlayer[id][PLAYER_LAST_TELEPORT] = _:0.0;

	codPlayer[id][PLAYER_ROCKETS] = 0;
	codPlayer[id][PLAYER_MINES] = 0;
	codPlayer[id][PLAYER_DYNAMITES] = 0;
	codPlayer[id][PLAYER_MEDKITS] = 0;
	codPlayer[id][PLAYER_TELEPORTS] = 0;
	codPlayer[id][PLAYER_JUMPS] = 0;
	codPlayer[id][PLAYER_LEFT_JUMPS] = 0;
	codPlayer[id][PLAYER_KS] = 0;
	codPlayer[id][PLAYER_TIME_KS] = 0;
	codPlayer[id][PLAYER_FOOTSTEPS][type] = 0;
	codPlayer[id][PLAYER_BUNNYHOP][type] = 0;
	codPlayer[id][PLAYER_MODEL][type] = 0;

	new bool:footstepsEnabled, bunnyHopEnabled, modelEnabled;

	for(new i = CLASS; i <= ADDITIONAL; i++) 
	{
		if(codPlayer[id][PLAYER_FOOTSTEPS][i]) footstepsEnabled = true;
		if(codPlayer[id][PLAYER_BUNNYHOP][i]) bunnyHopEnabled = true;
		if(codPlayer[id][PLAYER_MODEL][i]) modelEnabled = true;
	}

	codPlayer[id][PLAYER_FOOTSTEPS][ALL] = footstepsEnabled;
	codPlayer[id][PLAYER_BUNNYHOP][ALL] = bunnyHopEnabled;
	codPlayer[id][PLAYER_MODEL][ALL] = modelEnabled;

	remove_render_type(id, type);

	set_user_rendering(id);

	model_change(id);

	set_user_footsteps(id, codPlayer[id][PLAYER_FOOTSTEPS][ALL]);
}

public set_attributes(id)
{
	if(!is_user_alive(id)) return;

	codPlayer[id][PLAYER_MAX_HP] = _:(get_health(id, 1, 1, 1, 1));

	codPlayer[id][PLAYER_SPEED] = _:(get_condition(id, 1, 1, 1) * 0.85);
	
	set_user_health(id, codPlayer[id][PLAYER_MAX_HP]);

	set_user_footsteps(id, codPlayer[id][PLAYER_FOOTSTEPS][ALL]);
	
	gravity_change(id);

	remove_render_type(id, ADDITIONAL);

	render_change(id);

	model_change(id);

	player_reset_max_speed(id);

	StripWeapons(id, Primary);
	StripWeapons(id, Secondary);
	
	new playerWeapons[32], weaponName[22], weaponTypes, weaponType = get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_WEAPONS);
	
	for(new i = 1; i < 32; i++)
	{
		if((1<<i) & (weaponType | codPlayer[id][PLAYER_EXTR_WPNS]))
		{
			get_weaponname(i, weaponName, charsmax(weaponName));
			give_item(id, weaponName);
		}
	}
	
	get_user_weapons(id, playerWeapons, weaponTypes);
	
	for(new i = 0; i < weaponTypes; i++) if(maxAmmo[playerWeapons[i]] > 0) cs_set_user_bpammo(id, playerWeapons[i], maxAmmo[playerWeapons[i]]);
}

public gravity_change(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE;
	
	set_user_gravity(id, Float:codPlayer[id][PLAYER_GRAVITY]);

	execute_forward_ignore_one_param(codForwards[GRAVITY_CHANGED], id);
	
	return PLUGIN_CONTINUE;
}

public model_change(id)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
		
	if(!codPlayer[id][PLAYER_MODEL][ALL]) cs_reset_user_model(id);
	else
	{
		static ctSkins[4][] = {"sas","gsg9","urban","gign"}, tSkins[4][] = {"arctic","leet","guerilla","terror"};

		new model = random_num(0,3);

		cs_set_user_model(id, (cs_get_user_team(id) == CS_TEAM_T) ? ctSkins[model]: tSkins[model]);
	}

	return PLUGIN_CONTINUE;
}

public reset_player(id)
{
	rem_bit(id, dataLoaded);
	
	remove_tasks(id);

	remove_render_type(id, ITEM);
	remove_render_type(id, CLASS);
	remove_render_type(id, ADDITIONAL);

	for(new i = PLAYER_CLASS; i <= PLAYER_RESISTANCE; i++) codPlayer[id][i] = 0;

	for(new i = CLASS; i <= ALL; i++)
	{
		codPlayer[id][PLAYER_FOOTSTEPS][i] = 0;
		codPlayer[id][PLAYER_BUNNYHOP][i] = 0;
		codPlayer[id][PLAYER_MODEL][i] = 0;
	}

	codPlayer[id][PLAYER_MAX_HP] = _:0.0;
	codPlayer[id][PLAYER_SPEED] = _:0.0;
	codPlayer[id][PLAYER_LAST_ROCKET] = _:0.0;
	codPlayer[id][PLAYER_LAST_MINE] = _:0.0;
	codPlayer[id][PLAYER_LAST_DYNAMITE] = _:0.0;
	codPlayer[id][PLAYER_LAST_MEDKIT] = _:0.0;
	codPlayer[id][PLAYER_LAST_TELEPORT] = _:0.0;

	codPlayer[id][PLAYER_HUD] = TYPE_HUD;
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
	
	if(!is_user_connected(id))
	{
		remove_task(id + TASK_END_KILL_STREAK);
		
		return PLUGIN_CONTINUE;
	}

	if(--codPlayer[id][PLAYER_TIME_KS] == 0)
	{
		codPlayer[id][PLAYER_TIME_KS] = 0;
		codPlayer[id][PLAYER_KS] = 0;
		
		remove_task(id + TASK_END_KILL_STREAK);
	}
	
	return PLUGIN_CONTINUE;
}

public remove_tasks(id)
{
	remove_task(id + TASK_SHOW_INFO);
	remove_task(id + TASK_SHOW_AD);
	remove_task(id + TASK_SHOW_HELP);
	remove_task(id + TASK_SPEED_LIMIT);	
	remove_task(id + TASK_SET_SPEED);
	remove_task(id + TASK_END_KILL_STREAK);
}

stock remove_ents(id = 0)
{
	new ent = find_ent_by_class(-1, "rocket");
	
	while(ent > 0)
	{
		if(!id || entity_get_edict(ent, EV_ENT_owner) == id) remove_entity(ent);
		
		ent = find_ent_by_class(ent, "rocket");
	}
	
	ent = find_ent_by_class(-1, "mine");
	
	while(ent > 0)
	{
		if(!id || entity_get_edict(ent, EV_ENT_owner) == id) remove_entity(ent);
		
		ent = find_ent_by_class(ent, "mine");
	}
	
	ent = find_ent_by_class(-1, "dynamite");
	
	while(ent > 0)
	{
		if(!id || entity_get_edict(ent, EV_ENT_owner) == id) remove_entity(ent);
		
		ent = find_ent_by_class(ent, "dynamite");
	}
	
	ent = find_ent_by_class(-1, "medkit");
	
	while(ent > 0)
	{
		if(!id || entity_get_edict(ent, EV_ENT_owner) == id) remove_entity(ent);
		
		ent = find_ent_by_class(ent, "medkit");
	}
}

public show_bonus_info()
{
	if(get_players_amount() > 0 && (lastInfo + 5.0 < get_gametime() || get_players_amount() == minBonusPlayers))
	{
		if(get_players_amount() == minBonusPlayers) cod_print_chat(0, "Serwer jest pelny, a to oznacza^x03 EXP x 2^x01!");
		else
		{
			new playersToFull = minBonusPlayers - get_players_amount();

			cod_print_chat(0, "Do pelnego serwera brakuj%s^x03 %i osob%s^x01. Exp jest wiekszy o^x03 %i%%^x01!", playersToFull > 1 ? (playersToFull < 5 ? "a" : "e") : "e", playersToFull, playersToFull == 1 ? "a" : (playersToFull < 5 ? "y" : ""), get_players_amount() * 10);
		}
		
		lastInfo = floatround(get_gametime());
	}
}

public get_level_exp(level)
	return power(level, 2) * levelRatio;
	
public get_health(id, class_health, stats_health, bonus_health, base_health)
{
	new health;
	
	if(class_health) health += get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_HEAL);
	if(stats_health) health += codPlayer[id][PLAYER_HEAL];
	if(bonus_health) health += codPlayer[id][PLAYER_EXTR_HEAL];
	if(base_health) health += 100;

	return health;
}

public get_intelligence(id, class_intelligence, stats_intelligence, bonus_intelligence)
{
	new intelligence;
	
	if(class_intelligence) intelligence += get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_INT);
	if(stats_intelligence) intelligence += codPlayer[id][PLAYER_INT];
	if(bonus_intelligence) intelligence += codPlayer[id][PLAYER_EXTR_INT];
	
	return intelligence;
}

public get_strength(id, class_strength, stats_strength, bonus_strength)
{
	new strength;
	
	if(class_strength) strength += get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_STR);
	if(stats_strength) strength += codPlayer[id][PLAYER_STR];
	if(bonus_strength) strength += codPlayer[id][PLAYER_EXTR_STR];
	
	return strength;
}

public get_stamina(id, class_stamina, stats_stamina, bonus_stamina)
{
	new stamina;
	
	if(class_stamina) stamina += get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_STAM);
	if(stats_stamina) stamina += codPlayer[id][PLAYER_STAM];
	if(bonus_stamina) stamina += codPlayer[id][PLAYER_EXTR_STAM];
	
	return stamina;
}

public get_condition(id, class_condition, stats_condition, bonus_condition)
{
	new condition;
	
	if(class_condition) condition += get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_COND);
	if(stats_condition) condition += codPlayer[id][PLAYER_COND];
	if(bonus_condition) condition += codPlayer[id][PLAYER_EXTR_COND];
	
	return condition;
}

public set_cvars()
{
	levelLimit = get_pcvar_num(cvarLevelLimit);
	levelRatio = get_pcvar_num(cvarLevelRatio);
	levelPromotionFirst = get_pcvar_num(cvarLevelPromotionFirst);
	levelPromotionSecond = get_pcvar_num(cvarLevelPromotionSecond);
	levelPromotionThird = get_pcvar_num(cvarLevelPromotionThird);
	
	minPlayers = get_pcvar_num(cvarMinPlayers);
	minBonusPlayers = get_pcvar_num(cvarMinBonusPlayers);
	killStreakTime = get_pcvar_num(cvarKillStreakTime);
	
	expKill = get_pcvar_num(cvarExpKill);
	expKillHS = get_pcvar_num(cvarExpKillHS);
	expDamage = get_pcvar_num(cvarExpDamage);
	expWinRound = get_pcvar_num(cvarExpWinRound);
	expPlant = get_pcvar_num(cvarExpPlant);
	expDefuse = get_pcvar_num(cvarExpDefuse);
	expRescue = get_pcvar_num(cvarExpRescue);

	nightExpEnabled = get_pcvar_num(cvarNightExpEnabled);
	nightExpFrom = get_pcvar_num(cvarNightExpFrom);
	nightExpTo = get_pcvar_num(cvarNightExpTo);
	
	maxDurability = get_pcvar_num(cvarMaxDurability);
	minDamageDurability = get_pcvar_num(cvarMinDamageDurability);
	maxDamageDurability = get_pcvar_num(cvarMaxDamageDurability);
}

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
	
	formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_mod` (`name` VARCHAR(35) NOT NULL, `class` VARCHAR(64) NOT NULL, `exp` INT UNSIGNED NOT NULL DEFAULT 0, `level` INT UNSIGNED NOT NULL DEFAULT 1, `intelligence` INT UNSIGNED NOT NULL DEFAULT 0, ");
	add(queryData,  charsmax(queryData), "`health` INT UNSIGNED NOT NULL DEFAULT 0, `stamina` INT UNSIGNED NOT NULL DEFAULT 0, `condition` INT UNSIGNED NOT NULL DEFAULT 0, `strength` INT UNSIGNED NOT NULL DEFAULT 0, PRIMARY KEY(`name`, `class`));");	

	new Handle:query = SQL_PrepareQuery(connectHandle, queryData);

	SQL_Execute(query);
	
	SQL_FreeHandle(query);
	SQL_FreeHandle(connectHandle);
}

public load_data(id)
{
	load_hud(id);

	new playerId[1], queryData[128];
	
	playerId[0] = id;
	
	formatex(queryData, charsmax(queryData), "SELECT * FROM `cod_mod` WHERE name = '%s'", codPlayer[id][PLAYER_NAME]);
	
	SQL_ThreadQuery(sql, "load_data_handle", queryData, playerId, sizeof(playerId));
}

public load_data_handle(failState, Handle:query, error[], errorNum, playerId[], dataSize)
{
	if(failState) 
	{
		log_to_file("cod_mod.log", "SQL Error: %s (%d)", error, errorNum);
		
		return;
	}
	
	new id = playerId[0], className[MAX_NAME], codClass[playerClassInfo], classId;
	
	while(SQL_MoreResults(query))
	{
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "class"), className, charsmax(className));
		
		classId = get_class_id(className);

		if(classId)
		{
			codClass[PCLASS_LEVEL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "level"));
			codClass[PCLASS_EXP] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "exp"));
			codClass[PCLASS_INT] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "intelligence"));
			codClass[PCLASS_HEAL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "health"));
			codClass[PCLASS_STAM] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "stamina"));
			codClass[PCLASS_STR] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "strength"));
			codClass[PCLASS_COND] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "condition"));
			
			ArraySetArray(codPlayerClasses[id], classId, codClass);
		}

		SQL_NextRow(query);
	}
	
	set_bit(id, dataLoaded);
	
	if(is_user_alive(id)) select_fraction(id);
}

public save_data(id, end)
{
	if(!codPlayer[id][PLAYER_CLASS] || !get_bit(id, dataLoaded)) return;

	new queryData[256], className[MAX_NAME];
	get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));
	
	formatex(queryData, charsmax(queryData), "UPDATE `cod_mod` SET `exp` = (`exp` + %d), `level` = (`level` + %d), `intelligence` = '%d', `health` = '%d', `stamina` = '%d', `strength` = '%d', `condition` = '%d' WHERE `name` = '%s' AND `class` = '%s'", 
	codPlayer[id][PLAYER_GAINED_EXP], codPlayer[id][PLAYER_GAINED_LEVEL], codPlayer[id][PLAYER_INT], codPlayer[id][PLAYER_HEAL], codPlayer[id][PLAYER_STAM], codPlayer[id][PLAYER_STR], codPlayer[id][PLAYER_COND], codPlayer[id][PLAYER_NAME], className);

	switch(end)
	{
		case NORMAL, DISCONNECT: SQL_ThreadQuery(sql, "ignore_handle", queryData);
		case MAP_END:
		{
			new error[128], errorNum, Handle:connect, Handle:query;
			
			connect = SQL_Connect(sql, errorNum, error, charsmax(error));

			if(!connect)
			{
				log_to_file("addons/amxmodx/logs/cod_stats.txt", "Save - Could not connect to SQL database. [%d] %s", error, error);
				
				SQL_FreeHandle(connect);
				
				return;
			}
			
			query = SQL_PrepareQuery(connect, queryData);
			
			if(!SQL_Execute(query))
			{
				errorNum = SQL_QueryError(query, error, charsmax(error));
				
				log_to_file("addons/amxmodx/logs/cod_stats.txt", "Save Query Nonthreaded failed. [%d] %s", errorNum, error);
				
				SQL_FreeHandle(query);
				SQL_FreeHandle(connect);
				
				return;
			}
	
			SQL_FreeHandle(query);
			SQL_FreeHandle(connect);
		}
	}
	
	codPlayer[id][PLAYER_EXP] += codPlayer[id][PLAYER_GAINED_EXP];
	codPlayer[id][PLAYER_GAINED_EXP] = 0;
	
	codPlayer[id][PLAYER_LEVEL] += codPlayer[id][PLAYER_GAINED_LEVEL];
	codPlayer[id][PLAYER_GAINED_LEVEL] = 0;
	
	new codClass[playerClassInfo];
	
	codClass[PCLASS_LEVEL] = codPlayer[id][PLAYER_LEVEL];
	codClass[PCLASS_EXP] = codPlayer[id][PLAYER_EXP];
	codClass[PCLASS_INT] = codPlayer[id][PLAYER_INT];
	codClass[PCLASS_HEAL] = codPlayer[id][PLAYER_HEAL];
	codClass[PCLASS_STAM] = codPlayer[id][PLAYER_STAM];
	codClass[PCLASS_STR] = codPlayer[id][PLAYER_STR];
	codClass[PCLASS_COND] = codPlayer[id][PLAYER_COND];
	
	ArraySetArray(codPlayerClasses[id], codPlayer[id][PLAYER_CLASS], codClass);
	
	if(end) rem_bit(id, dataLoaded);
}

public save_hud(id)
{
	new vaultKey[64], vaultData[64];
	
	formatex(vaultKey, charsmax(vaultKey), "%s-cod_hud", codPlayer[id][PLAYER_NAME]);
	formatex(vaultData, charsmax(vaultData), "%d#%d#%d#%d#%d#%d", codPlayer[id][PLAYER_HUD], codPlayer[id][PLAYER_HUD_RED], codPlayer[id][PLAYER_HUD_GREEN], codPlayer[id][PLAYER_HUD_BLUE], codPlayer[id][PLAYER_HUD_POSX], codPlayer[id][PLAYER_HUD_POSY]);
	
	nvault_set(hudVault, vaultKey, vaultData);
	
	return PLUGIN_CONTINUE;
}

public load_hud(id)
{
	new vaultKey[64], vaultData[64];
	
	formatex(vaultKey, charsmax(vaultKey), "%s-cod_hud", codPlayer[id][PLAYER_NAME]);
	
	if(nvault_get(hudVault, vaultKey, vaultData, charsmax(vaultData)))
	{
		replace_all(vaultData, charsmax(vaultData), "#", " ");
	 
		new hudData[6][6];
	
		parse(vaultData, hudData[0], charsmax(hudData), hudData[1], charsmax(hudData), hudData[2], charsmax(hudData), hudData[3], charsmax(hudData), hudData[4], charsmax(hudData), hudData[5], charsmax(hudData));
	
		codPlayer[id][PLAYER_HUD] = str_to_num(hudData[0]);
		codPlayer[id][PLAYER_HUD_RED] = str_to_num(hudData[1]);
		codPlayer[id][PLAYER_HUD_GREEN] = str_to_num(hudData[2]);
		codPlayer[id][PLAYER_HUD_BLUE] = str_to_num(hudData[3]);
		codPlayer[id][PLAYER_HUD_POSX] = str_to_num(hudData[4]);
		codPlayer[id][PLAYER_HUD_POSY] = str_to_num(hudData[5]);
	}

	return PLUGIN_CONTINUE;
} 

public load_class(id, class)
{
	if(!get_bit(id, dataLoaded)) return;

	new codClass[playerClassInfo];
	
	ArrayGetArray(codPlayerClasses[id], class, codClass);

	codPlayer[id][PLAYER_GAINED_EXP] = 0;
	codPlayer[id][PLAYER_GAINED_LEVEL] = 0;
	codPlayer[id][PLAYER_LEVEL] = max(0, codClass[PCLASS_LEVEL]);
	codPlayer[id][PLAYER_EXP] = codClass[PCLASS_EXP];
	codPlayer[id][PLAYER_INT] = codClass[PCLASS_INT];
	codPlayer[id][PLAYER_HEAL] = codClass[PCLASS_HEAL];
	codPlayer[id][PLAYER_STAM] = codClass[PCLASS_STAM];
	codPlayer[id][PLAYER_STR] = codClass[PCLASS_STR];
	codPlayer[id][PLAYER_COND] = codClass[PCLASS_COND];

	check_promotion(id);

	if(!class) return;

	if(!codPlayer[id][PLAYER_LEVEL])
	{
		codPlayer[id][PLAYER_LEVEL] = codClass[PCLASS_LEVEL] = 1;
		
		ArraySetArray(codPlayerClasses[id], class, codClass);
		
		new tempData[128], className[MAX_NAME];
		
		get_class_info(class, CLASS_NAME, className, charsmax(className));
		
		//TESTY
		//formatex(tempData, charsmax(tempData), "INSERT IGNORE INTO `cod_mod` (`name`, `class`) VALUES ('%s', '%s')", codPlayer[id][PLAYER_NAME], className);
		formatex(tempData, charsmax(tempData), "INSERT IGNORE INTO `cod_mod` (`name`, `class`, `level`, `exp`) VALUES ('%s', '%s', '%i', '%i')", codPlayer[id][PLAYER_NAME], className, 49, get_level_exp(49 - 1));
		SQL_ThreadQuery(sql, "ignore_handle", tempData);
	}

	//TESTY
	if(codClass[PCLASS_LEVEL] < 49) codPlayer[id][PLAYER_LEVEL] = codClass[PCLASS_LEVEL] = 49;
	if(codClass[PCLASS_EXP] < get_level_exp(49 - 1)) codPlayer[id][PLAYER_EXP] = codClass[PCLASS_EXP] = get_level_exp(49 - 1);
	
	codPlayer[id][PLAYER_POINTS] = (codPlayer[id][PLAYER_LEVEL] - 1) - codPlayer[id][PLAYER_INT] - codPlayer[id][PLAYER_HEAL] - codPlayer[id][PLAYER_STAM] - codPlayer[id][PLAYER_STR] - codPlayer[id][PLAYER_COND];
} 

public ignore_handle(failState, Handle:query, error[], errorNum, data[], dataSize)
{
	if(failState) 
	{
		if(failState == TQUERY_CONNECT_FAILED) log_to_file("cod_mod.log", "Could not connect to SQL database. [%d] %s", errorNum, error);
		else if (failState == TQUERY_QUERY_FAILED) log_to_file("cod_mod.log", "Query failed. [%d] %s", errorNum, error);
	}
	
	return PLUGIN_CONTINUE;
}

public _cod_get_user_exp(id)
	return codPlayer[id][PLAYER_EXP];

public _cod_set_user_exp(id, value)
{
	codPlayer[id][PLAYER_GAINED_EXP] = value;

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
	
	for(new i = 1; i < ArraySize(codPlayerClasses[id]); i++)
	{
		ArrayGetArray(codPlayerClasses[id], i, codClass);
		
		if(codClass[PCLASS_LEVEL] > level) level = codClass[PCLASS_LEVEL];
	}
	
	return level;
}

public _cod_get_user_class(id)
	return codPlayer[id][PLAYER_CLASS];

public _cod_set_user_class(id, class, force)
{
	codPlayer[id][PLAYER_NEW_CLASS] = class;
	
	if(force) set_new_class(id);
}

public _cod_get_classid(className[])
{
	param_convert(1);
	
	return get_class_id(className);
}

public _cod_get_class_name(class, dataReturn[], dataLength)
{
	param_convert(2);
	
	get_class_info(class, CLASS_NAME, dataReturn, dataLength);
}

public _cod_get_class_desc(class, dataReturn[], dataLength)
{
	param_convert(2);
	
	get_class_info(class, CLASS_DESC, dataReturn, dataLength);
}

public _cod_get_class_health(class)
	return get_class_info(class, CLASS_HEAL);

public _cod_get_class_intelligence(class)
	return get_class_info(class, CLASS_INT);

public _cod_get_class_stamina(class)
	return get_class_info(class, CLASS_STAM);

public _cod_get_class_strength(class)
	return get_class_info(class, CLASS_STR);

public _cod_get_class_condition(class)
	return get_class_info(class, CLASS_COND);

public _cod_get_classes_num()
	return ArraySize(codClasses);

public _cod_get_user_item(id, &value)
{
	value = get_user_item_value(id);

	return codPlayer[id][PLAYER_ITEM];
}

public get_user_item_value(id)
{
	new value = -1;

	if(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_VALUE) > 0) ExecuteForward(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_VALUE), value, id);

	return value;
}

public _cod_set_user_item(id, item, value)
	set_item(id, item, value);

public _cod_upgrade_user_item(id, check)
{
	if(!ArraySize(codItems)) return false;

	if(check) return get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_UPGRADE) > 0 ? true : false;
	
	switch(random_num(1, 10))
	{
		case 1 .. 5:
		{
			new durability = random_num(minDamageDurability, maxDamageDurability);
			
			codPlayer[id][PLAYER_ITEM_DURA] -= durability;
	
			if(codPlayer[id][PLAYER_ITEM_DURA] <= 0)
			{
				set_item(id);
		
				cod_print_chat(id, "Ulepszenie^x03 nieudane^x01! Twoj przedmiot ulegl^x03 zniszczeniu^x01.");
			}
			else cod_print_chat(id, "Ulepszenie^x03 nieudane^x01! Straciles^x03 %i^x01 wytrzymalosci przedmiotu.", durability);
		}
		case 6:
		{
			set_item(id);
		
			cod_print_chat(id, "Ulepszenie^x03 nieudane^x01! Twoj przedmiot ulegl^x03 zniszczeniu^x01.");
		}
		case 7 .. 10:
		{
			new ret;

			ExecuteForward(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_UPGRADE), ret, id);

			if(ret == COD_STOP) return false;

			cod_print_chat(id, "Twoj przedmiot zostal pomyslnie^x03 ulepszony^x01.");
		}
	}

	return true;
}

public _cod_get_itemid(itemName[])
{
	param_convert(1);
	
	new codItem[classInfo];
	
	for(new i = 1; i < ArraySize(codItems); i++)
	{
		ArrayGetArray(codItems, i, codItem);
		
		if(equali(codItem[ITEM_NAME], itemName)) return i;
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
	return ArraySize(codItems);
	
public _cod_get_item_durability(id)
	return codPlayer[id][PLAYER_ITEM_DURA];
	
public _cod_set_item_durability(id, value)
	codPlayer[id][PLAYER_ITEM_DURA] = min(max(0, value), maxDurability);

public _cod_max_item_durability(id)
	return maxDurability;

public _cod_get_user_bonus_health(id)
	return codPlayer[id][PLAYER_EXTR_HEAL];

public _cod_get_user_bonus_intelligence(id)
	return codPlayer[id][PLAYER_EXTR_INT];

public _cod_get_user_bonus_stamina(id)
	return codPlayer[id][PLAYER_EXTR_STAM];

public _cod_get_user_bonus_strength(id)
	return codPlayer[id][PLAYER_EXTR_STR];

public _cod_get_user_bonus_condition(id)
	return codPlayer[id][PLAYER_EXTR_COND];

public _cod_set_user_bonus_health(id, value)
	codPlayer[id][PLAYER_EXTR_HEAL] = max(0, value);
	
public _cod_set_user_bonus_intelligence(id, value)
	codPlayer[id][PLAYER_EXTR_INT] = max(0, value);

public _cod_set_user_bonus_stamina(id, value)
	codPlayer[id][PLAYER_EXTR_STAM] = max(0, value);

public _cod_set_user_bonus_strength(id, value)
	codPlayer[id][PLAYER_EXTR_STR] = max(0, value);

public _cod_set_user_bonus_condition(id, value)
	codPlayer[id][PLAYER_EXTR_COND] = max(0, value);

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
	return get_health(id, 1, 1, 1, 1);

public _cod_set_user_health(id, value, maximum)
	set_user_health(id, maximum ? min(value, get_health(id, 1, 1, 1, 1)) : value);

public _cod_add_user_health(id, value, maximum)
	set_user_health(id, maximum ? min(get_user_health(id) + value, get_health(id, 1, 1, 1, 1)) : get_user_health(id) + value);

public _cod_get_user_rockets(id)
	return codPlayer[id][PLAYER_ROCKETS];

public _cod_get_user_mines(id)
	return codPlayer[id][PLAYER_MINES];

public _cod_get_user_dynamites(id)
	return codPlayer[id][PLAYER_DYNAMITES];
	
public _cod_get_user_medkits(id)
	return codPlayer[id][PLAYER_MEDKITS];

public _cod_get_user_teleports(id)
	return codPlayer[id][PLAYER_TELEPORTS];
	
public _cod_get_user_multijumps(id)
	return codPlayer[id][PLAYER_JUMPS];
	
public _cod_get_user_gravity(id)
	return codPlayer[id][PLAYER_GRAVITY] * 800;

public _cod_get_user_armor(id, value)
	return cs_get_user_armor(id);

public _cod_set_user_rockets(id, value)
	codPlayer[id][PLAYER_ROCKETS] = max(0, value);

public _cod_set_user_mines(id, value)
	codPlayer[id][PLAYER_MINES] = max(0, value);

public _cod_set_user_dynamites(id, value)
	codPlayer[id][PLAYER_DYNAMITES] = max(0, value);
	
public _cod_set_user_medkits(id, value)
	codPlayer[id][PLAYER_MEDKITS] = max(0, value);

public _cod_set_user_teleports(id, value)
	codPlayer[id][PLAYER_TELEPORTS] = codPlayer[id][PLAYER_TELEPORTS] == -1 ? -1 : value;

public _cod_set_user_multijumps(id, value)
	codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS] = max(0, value);
	
public _cod_set_user_gravity(id, value)
{
	codPlayer[id][PLAYER_GRAVITY] = _:floatmax(0.01, value/800.0);

	gravity_change(id);
}

public _cod_set_user_armor(id, value)
	cs_set_user_armor(id, value, CS_ARMOR_KEVLAR);
	
public _cod_add_user_rockets(id, value)
	codPlayer[id][PLAYER_ROCKETS] += max(0, value);

public _cod_add_user_mines(id, value)
	codPlayer[id][PLAYER_MINES] += max(0, value);

public _cod_add_user_dynamites(id, value)
	codPlayer[id][PLAYER_DYNAMITES] += max(0, value);
	
public _cod_add_user_medkits(id, value)
	codPlayer[id][PLAYER_MEDKITS] += max(0, value);

public _cod_add_user_teleports(id, value)
	codPlayer[id][PLAYER_TELEPORTS] = codPlayer[id][PLAYER_TELEPORTS] == -1 ? -1 : (codPlayer[id][PLAYER_TELEPORTS] + value);
	
public _cod_add_user_multijumps(id, value)
	codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS] += max(0, value);
	
public _cod_add_user_gravity(id, value)
{
	codPlayer[id][PLAYER_GRAVITY] = _:floatmax(0.01, Float:codPlayer[id][PLAYER_GRAVITY] + value/800.0);
	
	gravity_change(id);
}

public _cod_add_user_armor(id, value)
	cs_set_user_armor(id, cs_get_user_armor(id) + value, CS_ARMOR_KEVLAR);

public _cod_use_user_rocket(id)
	use_rocket(id);

public _cod_use_user_mine(id)
	use_mine(id);

public _cod_use_user_dynamite(id)
	use_dynamite(id);

public _cod_use_user_medkit(id)
	use_medkit(id);

public _cod_use_user_teleport(id)
	use_teleport(id);

public _cod_get_user_resistance(id)
	return codPlayer[id][PLAYER_RESISTANCE];
	
public _cod_get_user_bunnyhop(id, type)
	return type == NONE ? codPlayer[id][PLAYER_BUNNYHOP][ALL] : codPlayer[id][PLAYER_BUNNYHOP][type];

public _cod_get_user_footsteps(id, type)
	return type == NONE ? codPlayer[id][PLAYER_FOOTSTEPS][ALL] : codPlayer[id][PLAYER_FOOTSTEPS][type];

public _cod_get_user_model(id, type)
	return type == NONE ? codPlayer[id][PLAYER_MODEL][ALL] : codPlayer[id][PLAYER_MODEL][type];
	
public _cod_set_user_resistance(id, value)
	codPlayer[id][PLAYER_RESISTANCE] = value;

public _cod_set_user_bunnyhop(id, type, value)
{
	codPlayer[id][PLAYER_BUNNYHOP][type] = value;

	new bool:enabled;

	for(new i = CLASS; i <= ADDITIONAL; i++) if(codPlayer[id][PLAYER_BUNNYHOP][i]) enabled = true;

	codPlayer[id][PLAYER_BUNNYHOP][ALL] = enabled;
}

public _cod_set_user_footsteps(id, type, value)
{
	codPlayer[id][PLAYER_FOOTSTEPS][type] = value;

	new bool:enabled;

	for(new i = CLASS; i <= ADDITIONAL; i++) if(codPlayer[id][PLAYER_FOOTSTEPS][i]) enabled = true;

	codPlayer[id][PLAYER_FOOTSTEPS][ALL] = enabled;

	set_user_footsteps(id, enabled);
}

public _cod_set_user_model(id, type, value)
{
	codPlayer[id][PLAYER_MODEL][type] = value;

	new bool:enabled;

	for(new i = CLASS; i <= ADDITIONAL; i++) if(codPlayer[id][PLAYER_MODEL][i]) enabled = true;

	codPlayer[id][PLAYER_MODEL][ALL] = enabled;

	model_change(id);
}

public _cod_give_weapon(id, weapon)
{
	new weaponName[22];
	
	codPlayer[id][PLAYER_EXTR_WPNS] |= (1<<weapon);
	
	get_weaponname(weapon, weaponName, charsmax(weaponName));
	
	return give_item(id, weaponName);
}

public _cod_take_weapon(id, weapon)
{
	codPlayer[id][PLAYER_EXTR_WPNS] &= ~(1<<weapon);
	
	if((1<<weapon) & (allowedWeapons | get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_WEAPONS))) return;
	
	new weaponName[22];
	
	get_weaponname(weapon, weaponName, charsmax(weaponName));
	
	if(!((1<<weapon) & (1<<CSW_HEGRENADE | 1<<CSW_SMOKEGRENADE | 1<<CSW_FLASHBANG))) engclient_cmd(id, "drop", weaponName);
}

public _cod_get_user_render(id)
	return render_count(id);

public _cod_set_user_render(id, type, value, status, weapon, Float:timer)
{
	if(timer == 0.0)
	{
		new codRender[renderInfo];

		codRender[RENDER_TYPE] = type;
		codRender[RENDER_VALUE] = value;
		codRender[RENDER_STATUS] = status;
		codRender[RENDER_WEAPON] = weapon;

		switch(type)
		{
			case CLASS, ITEM: ArraySetArray(codPlayerRender[id], type, codRender);
			case ADDITIONAL: ArrayPushArray(codPlayerRender[id], codRender);
		}

		render_change(id);
	}
	else
	{
		set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, max(0, value));

		set_bit(id, renderTimer);

		set_task(timer, "reset_render", id + TASK_RENDER);

		if(timer != 0.0) make_bar_timer(id, floatround(timer));
	}
}

public _cod_set_user_glow(id, effect, red, green, blue, model, amount, Float:timer)
{
	set_user_rendering(id, effect, red, green, blue, model, max(0, amount));

	if(timer != 0.0)
	{
		set_bit(id, renderTimer);

		set_task(timer, "reset_render", id + TASK_RENDER);

		make_bar_timer(id, floatround(timer));
	}
}

public _cod_display_fade(id, duration, holdtime, fadetype, red, green, blue, alpha)
	display_fade(id, duration * (1<<12), holdtime * (1<<12), fadetype, red, green, blue, alpha);

public _cod_show_hud(id, type, red, green, blue, Float:x, Float:y, effects, Float:fxtime, Float:holdtime, Float:fadeintime, Float:fadeouttime, const text[], any:...)
{
	static hudText[128];

	param_convert(13);

	if(numargs() == 13) copy(hudText, charsmax(hudText), text);
	else vformat(hudText, charsmax(hudText), text, 14);

	show_hud(id, hudText, type, red, green, blue, Float:x, Float:y, effects, Float:fxtime, Float:holdtime, Float:fadeintime, Float:fadeouttime);
}
	
public _cod_screen_shake(id, amplitude, duration, frequency)
	screen_shake(id, amplitude, duration, frequency);
	
public _cod_make_explosion(ent, distance, explosion, Float:damage_distance, Float:damage, Float:factor)
	make_explosion(ent, distance);
	
public _cod_make_bartimer(id, duration, start)
	make_bar_timer(id, duration, start);

public _cod_inflict_damage(attacker, victim, Float:damage, Float:factor, flags)
	if(!codPlayer[victim][PLAYER_RESISTANCE] || (codPlayer[victim][PLAYER_RESISTANCE] && !(flags & DMG_CODSKILL))) ExecuteHam(Ham_TakeDamage, victim, attacker, attacker, damage + get_intelligence(attacker, 1, 1, 1) * factor, DMG_CODSKILL | flags);
	
public _cod_kill_player(killer, victim, flags)
{
	if(is_user_alive(victim))
	{
		cs_set_user_armor(victim, 0, CS_ARMOR_NONE);
		
		_cod_inflict_damage(killer, victim, float(get_user_health(victim) + 1), 0.0, flags);
	}
}
	
public _cod_register_item(plugin, params)
{
	if(params != 2) return PLUGIN_CONTINUE;

	new codItem[itemInfo];
	
	get_string(1, codItem[ITEM_NAME], charsmax(codItem[ITEM_NAME]));
	get_string(2, codItem[ITEM_DESC], charsmax(codItem[ITEM_DESC]));
	
	codItem[ITEM_PLUGIN] = plugin;
	
	codItem[ITEM_GIVE] = CreateOneForward(plugin, "cod_item_enabled", FP_CELL, FP_CELL);
	codItem[ITEM_DROP] = CreateOneForward(plugin, "cod_item_disabled", FP_CELL);
	codItem[ITEM_SPAWNED] = CreateOneForward(plugin, "cod_item_spawned", FP_CELL);
	codItem[ITEM_KILL] = CreateOneForward(plugin, "cod_item_kill", FP_CELL, FP_CELL);
	codItem[ITEM_KILLED] = CreateOneForward(plugin, "cod_item_killed", FP_CELL, FP_CELL);
	codItem[ITEM_SKILL_USED] = CreateOneForward(plugin, "cod_item_skill_used", FP_CELL);
	codItem[ITEM_UPGRADE] = CreateOneForward(plugin, "cod_item_upgrade", FP_CELL);
	codItem[ITEM_VALUE] = CreateOneForward(plugin, "cod_item_value", FP_CELL);
	codItem[ITEM_DAMAGE_ATTACKER] = get_func_id("cod_item_damage_attacker", plugin);
	codItem[ITEM_DAMAGE_VICTIM] = get_func_id("cod_item_damage_victim", plugin);
	
	ArrayPushArray(codItems, codItem);
	
	return PLUGIN_CONTINUE;
}

public _cod_register_class(plugin, params)
{
	if(params != 9) return PLUGIN_CONTINUE;

	new codClass[classInfo];
	
	get_string(1, codClass[CLASS_NAME], charsmax(codClass[CLASS_NAME]));
	get_string(2, codClass[CLASS_DESC], charsmax(codClass[CLASS_DESC]));
	
	get_string(3, codClass[CLASS_FRACTION], charsmax(codClass[CLASS_FRACTION]));
	
	if(!equal(codClass[CLASS_FRACTION], "")) check_fraction(codClass[CLASS_FRACTION]);
	
	codClass[CLASS_WEAPONS] = get_param(4);
	codClass[CLASS_HEAL] = get_param(5);
	codClass[CLASS_INT] = get_param(6);
	codClass[CLASS_STR] = get_param(7);
	codClass[CLASS_STAM] = get_param(8);
	codClass[CLASS_COND] = get_param(9);

	codClass[CLASS_PLUGIN] = plugin;
	
	codClass[CLASS_ENABLED] = CreateOneForward(plugin, "cod_class_enabled", FP_CELL, FP_CELL);
	codClass[CLASS_DISABLED] = CreateOneForward(plugin, "cod_class_disabled", FP_CELL, FP_CELL);
	codClass[CLASS_SPAWNED] = CreateOneForward(plugin, "cod_class_spawned", FP_CELL);
	codClass[CLASS_KILL] = CreateOneForward(plugin, "cod_class_kill", FP_CELL, FP_CELL);
	codClass[CLASS_KILLED] = CreateOneForward(plugin, "cod_class_killed", FP_CELL, FP_CELL);
	codClass[CLASS_SKILL_USED] = CreateOneForward(plugin, "cod_class_skill_used", FP_CELL);

	codClass[CLASS_DAMAGE_VICTIM] = get_func_id("cod_class_damage_victim", plugin);
	codClass[CLASS_DAMAGE_ATTACKER] = get_func_id("cod_class_damage_attacker", plugin);
	
	ArrayPushArray(codClasses, codClass);

	return PLUGIN_CONTINUE;
}

stock get_exp_bonus(id, exp)
{
	new Float:bonus = 1.0;
	
	if(cod_get_user_vip(id)) bonus += 0.25;

	if(nightExp) bonus += 1.0;

	bonus += floatmin(codPlayer[id][PLAYER_KS] * 0.2, 1.0);
	
	bonus += get_players_amount() * 0.1;
	
	return floatround(exp * bonus);
}

stock get_players_amount()
{
	if(get_maxplayers() - playersNum <= minBonusPlayers) return (minBonusPlayers - (get_maxplayers() - playersNum));

	return 0;
}

stock check_promotion(id, info = 0)
{
	new promotion = PROMOTION_NONE;
	
	if(codPlayer[id][PLAYER_PROMOTION] < PROMOTION_FIRST && codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL] >= levelPromotionFirst) promotion = PROMOTION_FIRST;

	if(codPlayer[id][PLAYER_PROMOTION] < PROMOTION_SECOND && codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL] >= levelPromotionSecond) promotion = PROMOTION_SECOND;

	if(codPlayer[id][PLAYER_PROMOTION] < PROMOTION_THIRD && codPlayer[id][PLAYER_LEVEL] + codPlayer[id][PLAYER_GAINED_LEVEL] >= levelPromotionThird) promotion = PROMOTION_THIRD;

	if(promotion > codPlayer[id][PLAYER_PROMOTION])
	{
		if(info)
		{
			new className[MAX_NAME];

			codPlayer[id][PLAYER_NEW_CLASS] = codPlayer[id][PLAYER_CLASS];

			get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));

			set_dhudmessage(0, 255, 34, 0.31, 0.52, 0, 0.0, 1.5, 0.0, 0.0);
			show_dhudmessage(id, "Awansowales! Twoja klasa to teraz %s %s!", codPromotions[codPlayer[id][PLAYER_PROMOTION]], className);
		}
	}

	codPlayer[id][PLAYER_PROMOTION] = promotion;

	return promotion;
}

stock check_fraction(const fractionName[])
{
	new tempFactionName[MAX_NAME], bool:foundFraction;
	
	for(new i = 0; i < ArraySize(codFractions); i++)
	{
		ArrayGetString(codFractions, i, tempFactionName, charsmax(tempFactionName));
		
		if(equali(tempFactionName, fractionName)) foundFraction = true;
	}
	
	if(!foundFraction) ArrayPushString(codFractions, fractionName);
}

stock get_weapons(weapons)
{
	new weaponsList[128], weaponName[22];
	
	for(new i = 1, j = 1; i <= 32; i++)
	{
		if((1<<i) & weapons)
		{
			get_weaponname(i, weaponName, charsmax(weaponName));
			replace_all(weaponName, charsmax(weaponName), "weapon_", "");
			
			if(equal(weaponName, "hegrenade")) weaponName = "he";
			if(equal(weaponName, "flashbang")) weaponName = "flash";
			if(equal(weaponName, "smokegrenade")) weaponName = "smoke";
			
			strtoupper(weaponName);
			
			if(j > 1) add(weaponsList, charsmax(weaponsList), ", ");
			
			add(weaponsList, charsmax(weaponsList), weaponName);
			
			j++;
		}
	}
	
	return weaponsList;
}

stock execute_forward_ignore(forwardHandle)
{
	static ret;
	
	return ExecuteForward(forwardHandle, ret);
}

stock execute_forward_ignore_one_param(forwardHandle, param)
{
	static ret;
	
	return ExecuteForward(forwardHandle, ret, param);
}

stock execute_forward_ignore_two_params(forwardHandle, paramOne, paramTwo)
{
	static ret;
	
	return ExecuteForward(forwardHandle, ret, paramOne, paramTwo);
}

stock get_class_info(class, info, dataReturn[] = "", dataLength = 0)
{
	new codClass[classInfo];
	
	ArrayGetArray(codClasses, class, codClass);
	
	if(info == CLASS_NAME || info == CLASS_DESC || info == CLASS_FRACTION)
	{
		copy(dataReturn, dataLength, codClass[info]);
		
		return 0;
	}
	
	return codClass[info];
}

stock get_class_id(className[])
{
	static codClass[classInfo];
	
	for(new i = 1; i < ArraySize(codClasses); i++)
	{
		ArrayGetArray(codClasses, i, codClass);
		
		if(equali(codClass[CLASS_NAME], className)) return i;
	}
	
	return 0;
}

stock get_item_info(item, info, dataReturn[] = "", dataLength = 0)
{
	static codItem[itemInfo];
	
	ArrayGetArray(codItems, item, codItem);
	
	if(info == ITEM_NAME || info == ITEM_DESC)
	{
		copy(dataReturn, dataLength, codItem[info]);
		
		return 0;
	}
	
	return codItem[info];
}

stock remove_render_type(id, type)
{
	static codRender[renderInfo];

	for(new i = 0; i < ArraySize(codPlayerRender[id]); i++)
	{
		ArrayGetArray(codPlayerRender[id], i, codRender);

		if(codRender[RENDER_TYPE] == type && type == ADDITIONAL) ArrayDeleteItem(codPlayerRender[id], i);
		else
		{
			codRender[RENDER_VALUE] = 256;

			ArraySetArray(codPlayerRender[id], i, codRender);
		}
	}
}

stock make_explosion(ent, distance = 0, explosion = 1, Float:damage_distance = 0.0, Float:damage = 0.0, Float:factor = 0.5)
{
	new Float:tempOrigin[3], origin[3];
	
	entity_get_vector(ent, EV_VEC_origin, tempOrigin);

	for(new i = 0; i < 3; i++) origin[i] = floatround(tempOrigin[i]);

	if(explosion)
	{
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
	
	if(distance)
	{
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
		write_byte(255); 
		write_byte(100);
		write_byte(100);
		write_byte(128);
		write_byte(0); 
		message_end();
	}

	if(damage_distance > 0.0)
	{
		new entList[33], id, foundPlayers = find_sphere_class(ent, "player", damage_distance, entList, MAX_PLAYERS), player;

		if(is_user_valid(ent)) id = ent;
		else id = entity_get_edict(ent, EV_ENT_owner);

		for(new i = 0; i < foundPlayers; i++)
		{
			player = entList[i];

			if(!is_user_alive(player) || get_user_team(id) == get_user_team(player)) continue;

			_cod_inflict_damage(id, player, damage, factor, DMG_CODSKILL);
		}
	}
}

stock make_bar_timer(id, duration, start = 0)
{
	if(!is_user_alive(id)) return;

	static msgBartimer;
	
	if(!msgBartimer) msgBartimer = get_user_msgid("BarTime");
	
	message_begin(id ? MSG_ONE : MSG_ALL, msgBartimer, {0, 0, 0}, id);
	write_byte(duration); 
	write_byte(start);
	message_end();
}

stock show_hud(id, const text[], type=0, red=255, green=255, blue=255, Float:x=-1.0, Float:y=0.35, effects=0, Float:fxtime=6.0, Float:holdtime=12.0, Float:fadeintime=0.1, Float:fadeouttime=0.2)
{
	if(!is_user_connected(id)) return;
	
	if(type)
	{
		set_dhudmessage(red, green, blue, x, y, effects, fxtime, holdtime, fadeintime, fadeouttime);
		show_dhudmessage(id, text);
	}
	else
	{
		static counter;

		if(++counter > 1) counter = 0;

		set_hudmessage(red, green, blue, x, y, effects, fxtime, holdtime, fadeintime, fadeouttime);
		ShowSyncHudMsg(id, counter ? hudSync2 : hudSync, text);
	}
}

stock display_fade(id, duration, holdtime, fadetype, red, green, blue, alpha)
{
	if(!is_user_alive(id)) return;

	static msgScreenFade;
	
	if(!msgScreenFade) msgScreenFade = get_user_msgid("ScreenFade");

	message_begin(MSG_ONE, msgScreenFade, {0, 0, 0}, id);
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
	if(!is_user_alive(id)) return;
	
	static msgScreenShake;
	
	if(!msgScreenShake) msgScreenShake = get_user_msgid("ScreenShake");
	
	message_begin(MSG_ONE, msgScreenShake, {0, 0, 0}, id);
	write_short(amplitude);
	write_short(duration);
	write_short(frequency);
	message_end();
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
	
	for(new i = 1; i <= 5; i++) 
	{
		weaponType = get_pdata_cbase(weaponTypeBox, weaponBox[i], 4);
		
		if(weaponType > 0) return cs_get_weapon_id(weaponType);
	}
	
	return 0;
}

stock is_enough_space(id)
{
	new Float:origin[3], Float:start[3], Float:end[3], Float:limit = 135.0;
	
	pev(id, pev_origin, origin);
 
	start[0] = end[0] = origin[0];
	start[1] = end[1] = origin[1];
	start[2] = end[2] = origin[2];

	start[0] += limit;
	end[0] -= limit;
 
	if(is_wall_between_points(start, end, id)) return 0;
 
	start[0] -= limit;
	end[0] += limit;
	start[1] += limit;
	end[1] -= limit;
 
	if(is_wall_between_points(start, end, id)) return 0;
 
	return 1;
}
 
stock is_wall_between_points(Float:start[3], Float:end[3], ent)
{
	engfunc(EngFunc_TraceLine, start, end, IGNORE_GLASS, ent, 0);
 
	new Float:fraction;
	
	get_tr2(0, TR_flFraction, fraction);
 
	if(fraction != 1.0) return 1;
	
	return 0;
}

stock check_if_player_stuck(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED;

	new Float:origin[3];

	pev(id, pev_origin, origin);

	if(!is_hull_vacant(origin, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id) && !get_user_noclip(id) && !(pev(id, pev_solid) & SOLID_NOT)) unstuck_player(id);

	return PLUGIN_HANDLED;
}

stock unstuck_player(id)
{
	enum coords { Float:x, Float:y, Float:z };

	static Float:originalOrigin[coords], Float:newOrigin[coords];
	static attempts, distance;

	pev(id, pev_origin, originalOrigin);

	distance = 32;
 
	while (distance < 1000)
	{
		attempts = 128;

		while(attempts--)
		{
			newOrigin[x] = random_float(originalOrigin[x] - distance, originalOrigin[x] + distance);
			newOrigin[y] = random_float(originalOrigin[y] - distance, originalOrigin[y] + distance);
			newOrigin[z] = random_float(originalOrigin[z] - distance, originalOrigin[z] + distance);
            
			engfunc(EngFunc_TraceHull, newOrigin, newOrigin, DONT_IGNORE_MONSTERS, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0);
            
			if(get_tr2(0, TR_InOpen) && !get_tr2(0, TR_AllSolid) && !get_tr2(0, TR_StartSolid))
			{
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