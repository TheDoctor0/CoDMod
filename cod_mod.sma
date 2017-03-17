#include <amxmodx>
#include <cod>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <fun>
#include <sqlx>

#define PLUGIN "CoD Mod"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define MAX_NAME 64
#define MAX_DESC 256

#define TASK_SHOW_INFO 657
#define TASK_SHOW_AD 768
#define TASK_SET_SPEED 832
#define TASK_END_KILL_STREAK 979

#define	FL_WATERJUMP (1<<11)
#define	FL_ONGROUND	(1<<9)

new const maxAmmo[31] = { 0, 52, 0, 90, 1, 31, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 31, 90, 120, 90, 2, 35, 90, 90,0, 100 };

new const pointsDistribution[] = { 1, 3, 5, 10, 25, -1 };

new const commandClass[][] = { "klasa", "say /klasa", "say_team /klasa", "say /class", "say_team /class", "say /k", "say_team /k", "say /c", "say_team /c" };
new const commandClasses[][] = { "klasy", "say /klasy", "say_team /klasy", "say /classes", "say_team /classes", "say /ky", "say_team /ky", "say /cs", "say_team /cs" };
new const commandItem[][] = { "item", "say /item", "say_team /item", "say /przedmiot", "say_team /przedmiot", "say /i", "say_team /i", "say /p", "say_team /p" };
new const commandItems[][] = { "itemy", "say /itemy", "say_team /itemy", "say /przedmioty", "say_team /przedmioty", "say /iy", "say_team /iy", "say /py", "say_team /py" };
new const commandDrop[][] = { "wyrzuc", "say /wyrzuc", "say_team /wyrzuc", "say /drop", "say_team /drop", "say /w", "say_team /w", "say /d", "say_team /d" };
new const commandReset[][] = { "reset", "say /reset", "say_team /reset", "say /r", "say_team /r" };
new const commandPoints[][] = { "staty", "say /staty", "say_team /staty", "say /punkty", "say_team /punkty", "say /s", "say_team /s", "say /p", "say_team /p" };
new const commandHud[][] = { "hud", "say /hud", "say_team /hud", "say /zmienhud", "say_team /zmienhud", "say /change_hud", "say_team /change_hud" };
new const commandBlock[][] = { "fullupdate", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "rebuy", "autobuy", "hegren", "sgren", "flash", "-rocket", "-mine", "-dynamite", "-medkit" };

enum _:sounds { SOUND_SELECT, SOUND_SELECT2, SOUND_START, SOUND_START2, SOUND_LVLUP, SOUND_LVLUP2, SOUND_LVLUP3 };

new const codSounds[sounds][] =
{
	"CoDMod/select.wav",
	"CoDMod/select2.wav",
	"CoDMod/start.wav",
	"CoDMod/start2.wav",
	"CoDMod/levelup.wav",
	"CoDMod/levelup2.wav",
	"CoDMod/levelup3.wav"
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

new teamWeapons[] = { 0, 1<<CSW_GLOCK18, 1<<CSW_USP },
	allowedWeapons = 1<<CSW_KNIFE | 1<<CSW_C4;

enum _:itemInfo { ITEM_NAME[MAX_NAME], ITEM_DESC[MAX_DESC], ITEM_PLUGIN, ITEM_GIVE, ITEM_DROP, 
	ITEM_SPAWNED, ITEM_KILLED, ITEM_SKILL_USED, ITEM_UPGRADE, ITEM_DAMAGE_ATTACKER, ITEM_DAMAGE_VICTIM };

enum _:classInfo { CLASS_NAME[MAX_NAME], CLASS_DESC[MAX_DESC], CLASS_FRACTION[MAX_NAME], CLASS_HEALTH, CLASS_WEAPONS, CLASS_PLUGIN, 
	CLASS_ENABLED, CLASS_DISABLED, CLASS_SPAWNED, CLASS_KILLED, CLASS_SKILL_USED, CLASS_DAMAGE_VICTIM, CLASS_DAMAGE_ATTACKER };

enum _:playerClassInfo { PCLASS_LEVEL, PCLASS_EXP, PCLASS_HEAL, PCLASS_INT, PCLASS_STAM, PCLASS_STR, PCLASS_COND, PCLASS_POINTS };

enum _:forwards { FORWARD_CLASS_CHANGED, FORWARD_ITEM_CHANGED, FORWARD_RENDER_CHANGED, FORWARD_GRAVITY_CHANGED, FORWARD_DAMAGE_PRE, FORWARD_DAMAGE_POST, 
	FORWARD_WEAPON_DEPLOY, FORWARD_KILLED, FORWARD_SPAWNED, FORWARD_CMD_START, FORWARD_NEW_ROUND, FORWARD_START_ROUND, FORWARD_END_ROUND };

enum playerInfo { PLAYER_CLASS, PLAYER_NEW_CLASS, PLAYER_LEVEL, PLAYER_GAINED_LEVEL, PLAYER_EXP, PLAYER_GAINED_EXP, PLAYER_HEAL, 
	PLAYER_INT, PLAYER_STAM, PLAYER_STR, PLAYER_COND, PLAYER_POINTS, PLAYER_POINTS_SPEED, PLAYER_EXTR_HEAL, PLAYER_EXTR_INT, 
	PLAYER_EXTR_STAM, PLAYER_EXTR_STR, PLAYER_EXTR_COND, PLAYER_EXTR_WPNS, PLAYER_ITEM, PLAYER_ITEM_DURA, PLAYER_MAX_HP, PLAYER_SPEED, 
	PLAYER_GRAVITY, PLAYER_DMG_REDUCE, PLAYER_ROCKETS, PLAYER_LAST_ROCKET, PLAYER_MINES, PLAYER_LAST_MINE, PLAYER_DYNAMITE, 
	PLAYER_DYNAMITES, PLAYER_LAST_DYNAMITE, PLAYER_MEDKITS, PLAYER_LAST_MEDKIT, PLAYER_JUMPS, PLAYER_LEFT_JUMPS, PLAYER_KS, 
	PLAYER_TIME_KS, PLAYER_HUD, PLAYER_HUD_RED, PLAYER_HUD_GREEN, PLAYER_HUD_BLUE, PLAYER_HUD_POSX, PLAYER_HUD_POSY, PLAYER_NAME[MAX_NAME] };
	
new codPlayer[MAX_PLAYERS + 1][playerInfo];
	
enum save { NORMAL, DISCONNECT, MAP_END };

enum _:hud { TYPE_HUD, TYPE_DHUD };

new expKill, expKillHS, expDamage, expWinRound, expPlant, expDefuse, expRescue, levelLimit, levelRatio, 
	killStreakTime, minPlayers, minBonusPlayers, maxDurability, minDamageDurability, maxDamageDurability;

new cvarExpKill, cvarExpKillHS, cvarExpDamage, cvarExpWinRound, cvarExpPlant, cvarExpDefuse, cvarExpRescue, cvarLevelLimit, cvarLevelRatio, 
	cvarKillStreakTime, cvarMinPlayers, cvarMinBonusPlayers, cvarMaxDurability, cvarMinDamageDurability, cvarMaxDamageDurability;

new Array:codItems, Array:codClasses, Array:codFractions, Array:codPlayerClasses[MAX_PLAYERS + 1], codForwards[forwards];

new Handle:sql, bool:freezeTime, hudSync, playersNum, itemResistance, bunnyHop, dataLoaded, resetStats, lastInfo;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);	
	
	register_cvar("cod_sql_host", "sql.pukawka.pl", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_sql_user", "299081", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_sql_pass", "t993KU5garchck1x", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_sql_db", "299081_cod", FCVAR_SPONLY|FCVAR_PROTECTED);
	
	cvarExpKill = register_cvar("cod_killxp", "10");
	cvarExpKillHS = register_cvar("cod_hsxp", "5");
	cvarExpDamage = register_cvar("cod_damagexp", "3");
	cvarExpWinRound = register_cvar("cod_winxp", "25");
	cvarExpPlant = register_cvar("cod_bombxp", "15");
	cvarExpDefuse = register_cvar("cod_defusexp", "15");
	cvarExpRescue = register_cvar("cod_hostxp", "15");
	cvarLevelLimit = register_cvar("cod_maxlevel", "500");
	cvarLevelRatio = register_cvar("cod_levelratio", "35");
	cvarKillStreakTime = register_cvar("cod_killstreaktime", "15");
	cvarMinPlayers = register_cvar("cod_minplayers", "5");
	cvarMinBonusPlayers = register_cvar("cod_minbonusplayers", "10");
	cvarMaxDurability = register_cvar("cod_maxdurability", "100"); 
	cvarMinDamageDurability = register_cvar("cod_mindamagedurability", "20");
	cvarMaxDamageDurability = register_cvar("cod_maxdamagedurability", "35");
	
	for(new i; i < sizeof commandClass; i++) register_clcmd(commandClass[i], "select_fraction");

	for(new i; i < sizeof commandClasses; i++) register_clcmd(commandClasses[i], "display_classes_description");

	for(new i; i < sizeof commandItem; i++) register_clcmd(commandItem[i], "display_item_description");
	
	for(new i; i < sizeof commandItems; i++) register_clcmd(commandItems[i], "display_items_description");

	for(new i; i < sizeof commandDrop; i++) register_clcmd(commandDrop[i], "drop_item");

	for(new i; i < sizeof commandReset; i++) register_clcmd(commandReset[i], "reset_stats");

	for(new i; i < sizeof commandPoints; i++) register_clcmd(commandPoints[i], "assign_points");
	
	for(new i; i < sizeof commandHud; i++) register_clcmd(commandHud[i], "change_hud");

	for(new i; i < sizeof commandBlock; i++) register_clcmd(commandBlock[i], "block_command");

	register_clcmd("+rocket", "use_rocket");
	register_clcmd("+mine", "use_mine");
	register_clcmd("+dynamite", "use_dynamite");
	register_clcmd("+medkit", "use_medkit");
	
	register_impulse(100, "use_item");
	register_impulse(201, "use_skill");
	
	register_touch("rocket", "*" , "touch_rocket");
	register_touch("mine", "player" , "touch_mine");
	register_think("medkit", "think_medkit");
	
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1);
	RegisterHam(Ham_TakeDamage, "player", "player_take_damage", 0);
	RegisterHam(Ham_TakeDamage, "player", "player_take_damage_post", 1);
	RegisterHam(Ham_Touch, "armoury_entity", "touch_weapon");
	RegisterHam(Ham_Touch, "weapon_shield", "touch_weapon");
	RegisterHam(Ham_Touch, "weaponbox", "touch_weapon");
	RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "player_reset_max_speed", 1);
	
	register_logevent("round_start", 2, "1=Round_Start");
	register_logevent("round_end", 2, "1=Round_End");	
	
	register_event("HLTV", "new_round", "a", "1=0", "2=0");
	register_event("Health", "message_health", "be", "1!255");
	register_event("SendAudio", "t_win_round" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "ct_win_round", "a", "2&%!MRAD_ct_win_round");
	register_event("TextMsg", "hostages_rescued", "a", "2&#All_Hostages_R");
	
	register_forward(FM_CmdStart, "cmd_start");
	
	register_message(SVC_INTERMISSION, "message_intermission");
	
	hudSync = CreateHudSyncObj();
	
	codForwards[FORWARD_CLASS_CHANGED] = CreateMultiForward("cod_class_changed", ET_CONTINUE, FP_CELL, FP_CELL);
	codForwards[FORWARD_ITEM_CHANGED] = CreateMultiForward("cod_item_changed", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL);
	codForwards[FORWARD_RENDER_CHANGED] = CreateMultiForward("cod_render_changed", ET_IGNORE, FP_CELL);
	codForwards[FORWARD_GRAVITY_CHANGED] = CreateMultiForward("cod_gravity_changed", ET_IGNORE, FP_CELL);
	codForwards[FORWARD_DAMAGE_PRE] = CreateMultiForward ("cod_damage_pre", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	codForwards[FORWARD_DAMAGE_POST] = CreateMultiForward ("cod_damage_post", ET_IGNORE, FP_CELL, FP_CELL, FP_ARRAY);
	codForwards[FORWARD_WEAPON_DEPLOY] = CreateMultiForward("cod_weapon_deploy", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	codForwards[FORWARD_KILLED] = CreateMultiForward("cod_killed", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	codForwards[FORWARD_SPAWNED] = CreateMultiForward("cod_spawned", ET_IGNORE, FP_CELL);
	codForwards[FORWARD_CMD_START] = CreateMultiForward("cod_cmd_start", ET_IGNORE, FP_CELL);
	codForwards[FORWARD_NEW_ROUND] = CreateMultiForward("cod_new_round", ET_IGNORE);
	codForwards[FORWARD_START_ROUND] = CreateMultiForward("cod_start_round", ET_IGNORE);
	codForwards[FORWARD_END_ROUND] = CreateMultiForward("cod_end_round", ET_IGNORE);
	
	codItems = ArrayCreate(itemInfo);
	codClasses = ArrayCreate(classInfo);
	codFractions = ArrayCreate();
	
	for(new i = 1; i < MAX_PLAYERS + 1; i++) codPlayerClasses[i] = ArrayCreate(playerClassInfo);
}

public plugin_natives()
{
	register_native("cod_get_user_exp", "_cod_get_user_exp", 1);
	register_native("cod_set_user_exp", "_cod_set_user_exp", 1);
	register_native("cod_get_user_bonus_exp", "_cod_get_user_bonus_exp", 1);
	
	register_native("cod_get_user_level", "_cod_get_user_level", 1);
	register_native("cod_get_user_highest_level", "_cod_get_user_highest_level", 1);
	
	register_native("cod_get_user_class", "_cod_get_user_class", 1);
	register_native("cod_set_user_class", "_cod_set_user_class", 1);
	
	register_native("cod_get_classid", "_cod_get_classid", 1);
	register_native("cod_get_class_name", "_cod_get_class_name", 1);
	register_native("cod_get_class_desc", "_cod_get_class_desc", 1);
	register_native("cod_get_class_health", "_cod_get_class_health", 1);
	register_native("cod_get_classes_num", "_cod_get_classes_num", 1);
	
	register_native("cod_get_user_item", "_cod_get_user_item", 1);
	register_native("cod_set_user_item", "_cod_set_user_item", 1);
	register_native("cod_upgrade_user_item", "_cod_upgrade_user_item", 1);
	
	register_native("cod_get_itemid", "_cod_get_itemid", 1);
	register_native("cod_get_item_name", "_cod_get_item_name", 1);
	register_native("cod_get_item_desc", "_cod_get_item_desc", 1);
	register_native("cod_get_items_num", "_cod_get_items_num", 1);
	
	register_native("cod_get_item_durability", "_cod_get_item_durability", 1);
	register_native("cod_set_item_durability", "_cod_set_item_durability", 1);
	register_native("cod_max_item_durability", "_cod_max_item_durability", 1);

	register_native("cod_get_user_bonus_health", "_cod_get_user_bonus_health", 1);
	register_native("cod_get_user_bonus_intelligence", "_cod_get_user_bonus_intelligence", 1);
	register_native("cod_get_user_bonus_stamina", "_cod_get_user_bonus_stamina", 1);
	register_native("cod_get_user_bonus_strength", "_cod_get_user_bonus_strength", 1);
	register_native("cod_get_user_bonus_condition", "_cod_get_user_bonus_condition", 1);
	
	register_native("cod_set_user_bonus_health", "_cod_set_user_bonus_health", 1);
	register_native("cod_set_user_bonus_int", "_cod_set_user_bonus_int", 1);
	register_native("cod_set_user_bonus_stamina", "_cod_set_user_bonus_stamina", 1);
	register_native("cod_set_user_bonus_strength", "_cod_set_user_bonus_strength", 1);
	register_native("cod_set_user_bonus_condition", "_cod_set_user_bonus_condition", 1);
	
	register_native("cod_get_user_health", "_cod_get_user_health", 1);
	register_native("cod_get_user_int", "_cod_get_user_int", 1);
	register_native("cod_get_user_stamina", "_cod_get_user_stamina", 1);
	register_native("cod_get_user_strength", "_cod_get_user_strength", 1);
	register_native("cod_get_user_condition", "_cod_get_user_condition", 1);
	
	register_native("cod_get_user_max_health", "_cod_get_user_max_health", 1);
	
	register_native("cod_get_user_rockets", "_cod_get_user_rockets", 1);
	register_native("cod_get_user_mines", "_cod_get_user_mines", 1);
	register_native("cod_get_user_dynamites", "_cod_get_user_dynamites", 1);
	register_native("cod_get_user_medkits", "_cod_get_user_medkits", 1);
	register_native("cod_get_user_multijump", "_cod_get_user_multijump", 1);
	register_native("cod_get_user_gravity", "_cod_get_user_gravity", 1);
	
	register_native("cod_set_user_rockets", "_cod_set_user_rockets", 1);
	register_native("cod_set_user_mines", "_cod_set_user_mines", 1);
	register_native("cod_set_user_dynamites", "_cod_set_user_dynamites", 1);
	register_native("cod_set_user_medkits", "_cod_set_user_medkits", 1);
	register_native("cod_set_user_multijump", "_cod_set_user_multijump", 1);
	register_native("cod_set_user_gravity", "_cod_set_user_gravity", 1);
	
	register_native("cod_add_user_rockets", "_cod_add_user_rockets", 1);
	register_native("cod_add_user_mines", "_cod_add_user_mines", 1);
	register_native("cod_add_user_dynamites", "_cod_add_user_dynamites", 1);
	register_native("cod_add_user_medkits", "_cod_add_user_medkits", 1);
	register_native("cod_add_user_multijump", "_cod_add_user_multijump", 1);
	register_native("cod_add_user_gravity", "_cod_add_user_gravity", 1);
	
	register_native("cod_get_user_resistance", "_cod_get_user_resistance", 1);
	register_native("cod_get_user_bunnyhop", "_cod_get_user_bunnyhop", 1);
	register_native("cod_get_user_footsteps", "_cod_get_user_footsteps", 1);
	
	register_native("cod_set_user_itemResistance", "_cod_set_user_itemResistance", 1);
	register_native("cod_set_user_bunnyhop", "_cod_set_user_bunnyhop", 1);
	register_native("cod_set_user_footsteps", "_cod_set_user_footsteps", 1);
	
	register_native("cod_give_weapon", "_cod_give_weapon", 1);
	register_native("cod_take_weapon", "_cod_take_weapon", 1);
	
	register_native("cod_display_fade", "_cod_display_fade", 1);
	register_native("cod_screen_shake", "_cod_screen_shake", 1);
	register_native("cod_make_explosion", "_cod_make_explosion", 1);
	register_native("cod_make_bartimer", "_cod_make_bartimer", 1);
	
	register_native("cod_inflict_damage", "_cod_inflict_damage", 1);
	register_native("cod_kill_player", "_cod_kill_player", 1);
	
	register_native("cod_register_item", "_cod_register_item");
	register_native("cod_register_class", "_cod_register_class");
}

public plugin_cfg()
{
	new configPath[64], codItem[itemInfo], codClass[classInfo];
	
	get_localinfo("amxx_configsdir", configPath, charsmax(configPath));
	
	server_cmd("exec %s/cod_mod.cfg", configPath);
	server_exec();
	
	formatex(codItem[ITEM_NAME], charsmax(codItem[ITEM_NAME]), "Brak");
	formatex(codItem[ITEM_DESC], charsmax(codItem[ITEM_DESC]), "Zabij kogos, aby zdobyc przedmiot");
	
	ArrayPushArray(codItems, codItem);
	
	formatex(codClass[CLASS_NAME], charsmax(codClass[CLASS_NAME]), "Brak");
	
	ArrayPushArray(codClasses, codClass);
	
	sql_init();
	set_cvars();
}

public plugin_end()
{
	SQL_FreeHandle(sql);
	
	ArrayDestroy(codItems);
	ArrayDestroy(codClasses);
	ArrayDestroy(codFractions);
	
	for(new i = 1; i < MAX_PLAYERS + 1; i++) ArrayDestroy(codPlayerClasses[i]);
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
	
	cmd_execute(id, "bind z +rocket");
	cmd_execute(id, "bind x +mine");
	cmd_execute(id, "bind c +dynamite");
	cmd_execute(id, "bind n +medkit");
	
	get_user_name(id, codPlayer[id][PLAYER_NAME], charsmax(codPlayer[]));
	
	mysql_escape_string(codPlayer[id][PLAYER_NAME], codPlayer[id][PLAYER_NAME], charsmax(codPlayer[]));
	
	load_data(id);
}

public client_putinserver(id)
{
	playersNum++;
	
	show_bonus_info();
	
	if(is_user_bot(id) || is_user_hltv(id)) return;
	
	cmd_execute(id, "bind z +rocket");
	cmd_execute(id, "bind x +mine");
	cmd_execute(id, "bind c +dynamite");
	cmd_execute(id, "bind v +medkit");
	
	set_task(20.0, "show_advertisement", id + TASK_SHOW_AD);
	
	set_task(0.2, "show_info", id + TASK_SHOW_INFO, _, _, "b");
}

public client_disconnected(id)
{
	playersNum--;
	
	show_bonus_info();
	
	save_data(id, DISCONNECT);

	remove_tasks(id);
	
	remove_ents(id);
}

public select_fraction(id)
{
	if(!get_bit(id, dataLoaded))
	{
		cod_print_chat(id, "Trwa wczytywanie twoich klas...");
		
		return;
	}
	
	if(ArraySize(codFractions))
	{
		new fractionName[MAX_NAME], menu = menu_create("\wWybierz \rFrakcje:", "select_fraction_handel");
	
		for(new i = 0; i < ArraySize(codFractions); i++)
		{
			ArrayGetString(codFractions, i, fractionName, charsmax(fractionName));
		
			menu_additem(menu, fractionName, fractionName);
		}
	
		menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
		menu_setprop(menu, MPROP_BACKNAME, "Wroc");
		menu_setprop(menu, MPROP_NEXTNAME, "Dalej");

		menu_display(id, menu);
	}
	else select_class(id);
}
 
public select_fraction_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}

	new menuData[128], tempId[3], itemData[MAX_NAME], codClass[classInfo], classId, itemAccess, menuCallback;

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, menuCallback);
	
	menu_destroy(menu);
	
	new menu = menu_create("\wWybierz \rKlase:", "select_class_handle");
	
	classId = codPlayer[id][PLAYER_CLASS];

	for(new i = 1; i < ArraySize(codClasses); i++)
	{
		ArrayGetArray(codClasses, i, codClass);
		
		if(equali(itemData, codClass[CLASS_FRACTION]))
		{
			load_class(id, i);
			
			formatex(menuData, charsmax(menuData), "%s \yPoziom: %i \d(%s)", codClass[CLASS_NAME], codPlayer[id][PLAYER_LEVEL], get_weapons(codClass[CLASS_WEAPONS]));
			
			num_to_str(i, tempId, charsmax(tempId));
			menu_additem(menu, menuData, tempId);
		}
	}
	
	if(classId) load_class(id, classId);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public select_class(id)
{
	new menuData[128], tempId[3], codClass[classInfo], classId, menu = menu_create("\wWybierz \rKlase:", "select_class_handle");
	
	classId = codPlayer[id][PLAYER_CLASS];

	for(new i = 1; i < ArraySize(codClasses); i++)
	{
		ArrayGetArray(codClasses, i, codClass);

		load_class(id, i);

		formatex(menuData, charsmax(menuData), "%s \yPoziom: %i \d(%s)", codClass[CLASS_NAME], codPlayer[id][PLAYER_LEVEL], get_weapons(codClass[CLASS_WEAPONS]));

		num_to_str(i, tempId, charsmax(tempId));
		menu_additem(menu, menuData, tempId);
	}
	
	if(classId) load_class(id, classId);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public select_class_handle(id, menu, item)
{
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}       
	
	new itemData[64], itemAccess, menuCallback;
	
	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, menuCallback);
	
	item = str_to_num(itemData);

	load_class(id, codPlayer[id][PLAYER_CLASS]);
	
	if(item == codPlayer[id][PLAYER_CLASS] && !codPlayer[id][PLAYER_NEW_CLASS]) return PLUGIN_CONTINUE;
	
	codPlayer[id][PLAYER_NEW_CLASS] = item;
	
	if(codPlayer[id][PLAYER_CLASS]) cod_print_chat(id, "Klasa zostanie zmieniona w nastepnej rundzie.");
	else
	{
		set_new_class(id);
		set_attributes(id);
	}
	
	return PLUGIN_CONTINUE;
}

public display_classes_description(id)
{
	new className[MAX_NAME], menu = menu_create("\wWybierz \rKlase:", "display_class_description_handle");

	for(new i = 1; i < ArraySize(codClasses); i++)
	{
		get_class_info(i, CLASS_NAME, className, charsmax(className));
		
		menu_additem(menu, className);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz", 0);
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	
	menu_display(id, menu);
}

public display_classes_description_handle(id, menu, item)
{
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT2]);
	
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}
	
	new menuData[256], codClass[classInfo];
	
	ArrayGetArray(codClasses, item, codClass);
	
	format(menuData, charsmax(menuData), "\yKlasa: \w%s^n\yFrakcja: \w%i^n\yZycie: \w%i^n\yBronie:\w%s^n\yOpis: \w%s^n%s", codClass[CLASS_NAME], codClass[CLASS_HEALTH], get_weapons(codClass[CLASS_WEAPONS]), codClass[CLASS_DESC], codClass[CLASS_DESC][79]);
	show_menu(id, 0, menuData);
	
	return PLUGIN_CONTINUE;
}

public display_item_description(id)
	show_item_description(id, codPlayer[id][PLAYER_ITEM]);
	
stock display_items_description(id, page = 0)
{
	new itemName[MAX_NAME], menu = menu_create("\wWybierz \rItem:", "display_items_description_handle");
	
	for(new i = 1; i < ArraySize(codItems); i++)
	{
		get_item_info(i, ITEM_NAME, itemName, charsmax(itemName));
		
		menu_additem(menu, itemName);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz", 0);
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	
	menu_display(id, menu, page);
}

public display_items_description_handle(id, menu, item)
{
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}
	
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT2]);
	
	show_item_description(id, item);
	display_items_description(id, (item - 1) / 7);
	
	return PLUGIN_CONTINUE;
}
	
public show_item_description(id, item)
{
	new itemDescription[MAX_DESC], itemName[MAX_NAME];

	get_item_info(item, MAX_DESC, itemDescription, charsmax(itemDescription));
	get_item_info(item, ITEM_NAME, itemName, charsmax(itemName));

	cod_print_chat(id, "Item:^x03 %s^x01.", itemName);
	cod_print_chat(id, "Opis:^x03 %s^x01.", itemDescription);
}

public drop_item(id)
{
	if(codPlayer[id][PLAYER_ITEM])
	{
		new itemName[MAX_NAME];
		
		get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_NAME, itemName, charsmax(itemName));
		
		cod_print_chat(id, "Wyrzuciles^x03 %s^x01.", itemName);
		
		set_item(id);
	}
	else cod_print_chat(id, "Nie masz zadnego^x03 itemu^x01.");
}

public reset_stats(id)
{	
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

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	rem_bit(id, resetStats);
	
	codPlayer[id][PLAYER_POINTS] = (codPlayer[id][PLAYER_LEVEL] - 1)*2;
	codPlayer[id][PLAYER_INT] = 0;
	codPlayer[id][PLAYER_HEAL] = 0;
	codPlayer[id][PLAYER_COND] = 0;
	codPlayer[id][PLAYER_STAM] = 0;
	
	if(codPlayer[id][PLAYER_POINTS]) assign_points(id);
}

public assign_points(id)
{
	new menuData[128];
	
	format(menuData, charsmax(menuData), "\wPrzydziel \rPunkty \y(%i):", codPlayer[id][PLAYER_POINTS]);
	
	new menu = menu_create(menuData, "assign_points_handler");
	
	if(codPlayer[id][PLAYER_POINTS_SPEED] == -1) format(menuData, charsmax(menuData), "Ile dodawac: \rWszystko \y(Ile punktow dodac do statow)");
	else format(menuData, charsmax(menuData), "Ile dodawac: \r%d \y(Ile punktow dodac do statow)", pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]]);

	menu_additem(menu, menuData);
	
	menu_addblank(menu, 0);

	format(menuData, charsmax(menuData), "Zdrowie: \r%i \y(Zwieksza ilosc zycia)", get_health(id, 0, 1, 1));
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "Inteligencja: \r%i \y(Zwieksza sile itemow i umiejetnosci klasy)", get_intelligence(id, 1, 1));
	menu_additem(menu, menuData);

	format(menuData, charsmax(menuData), "Sila: \r%i \y(Zwieksza zadawane obrazenia)", get_strength(id, 1, 1));
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "Wytrzymalosc: \r%i \y(Zmniejsza otrzymywane obrazenia)", get_stamina(id, 1, 1));
	menu_additem(menu, menuData);
	
	format(menuData, charsmax(menuData), "Kondycja: \r%i \y(Zwieksza predkosc poruszania)", get_condition(id, 1, 1));
	menu_additem(menu, menuData);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz", 0);
	
	menu_display(id, menu);
}

public assign_points_handler(id, menu, item) 
{
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	if(item == MENU_EXIT) 
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}
	
	if(codPlayer[id][PLAYER_POINTS] < 1) return PLUGIN_CONTINUE;

	new pointsDistributionAmount = (pointsDistribution[codPlayer[id][PLAYER_POINTS_SPEED]] > codPlayer[id][PLAYER_POINTS]) ? codPlayer[id][PLAYER_POINTS] : codPlayer[id][PLAYER_POINTS_SPEED];
	
	switch(item) 
	{ 
		case 0: if(++codPlayer[id][PLAYER_POINTS_SPEED] >= charsmax(pointsDistribution)) codPlayer[id][PLAYER_POINTS_SPEED] = 0;     
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

	if(codPlayer[id][PLAYER_POINTS] > 0) assign_points(id);

	return PLUGIN_CONTINUE;
}

public change_hud(id)
{
	new menuData[128], menu = menu_create("\yCoD Mod: \rKonfiguracja HUD", "change_hud_handle");
	
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

	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz", 0);
	
	menu_display(id, menu);
}

public change_hud_handle(id, menu, item) 
{
	if(item == MENU_EXIT) 
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}
	
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
			codPlayer[id][PLAYER_HUD_POSX] = 66;
			codPlayer[id][PLAYER_HUD_POSY] = 6;
		}
	}
	
	change_hud(id);
	
	return PLUGIN_CONTINUE;
}

public block_command()
	return PLUGIN_HANDLED;
	
public use_rocket(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED;

	if(!codPlayer[id][PLAYER_ROCKETS])
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie rakiety!");
		
		return PLUGIN_HANDLED;
	}
	
	if(codPlayer[id][PLAYER_LAST_ROCKET] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Rakiet mozesz uzywac co 3 sekundy!");
		
		return PLUGIN_HANDLED;
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

	make_explosion(ent);

	new entList[33], id = entity_get_edict(ent, EV_ENT_owner), foundPlayers = find_sphere_class(ent, "player", 190.0, entList, MAX_PLAYERS), player;

	for(new i = 0; i < foundPlayers; i++)
	{
		player = entList[i];

		if(!is_user_alive(player) || get_user_team(id) == get_user_team(player)) continue;

		_cod_inflict_damage(id, player, 65.0, 0.5, DMG_HEGRENADE);
	}
	
	remove_entity(ent);
}

public use_mine(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED;

	if(!codPlayer[id][PLAYER_MINES])
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie miny!");
		
		return PLUGIN_HANDLED;
	}
	
	if(codPlayer[id][PLAYER_LAST_MINE] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Miny mozesz stawiac co 3 sekundy!");
		
		return PLUGIN_HANDLED;
	}
	
	if(!is_enough_space(id))
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Miny nie mozesz postawic w przejsciu!");

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

	return PLUGIN_HANDLED;
}

public touch_mine(ent, victim)
{
	if(!is_valid_ent(ent)) return;

	new id = entity_get_edict(ent, EV_ENT_owner);
	
	if(get_user_team(victim) != get_user_team(id)) return;

	make_explosion(ent);
	
	new entList[33], foundPlayers = find_sphere_class(ent, "player", 90.0, entList, MAX_PLAYERS), player;

	for(new i = 0; i < foundPlayers; i++)
	{
		player = entList[i];

		if(!is_user_alive(player) || get_user_team(id) == get_user_team(player)) continue;

		_cod_inflict_damage(id, player, 75.0, 0.5, DMG_HEGRENADE);
	}
	
	remove_entity(ent);
}

public use_dynamite(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE;

	if(is_valid_ent(codPlayer[id][PLAYER_DYNAMITE]))
	{
		make_explosion(codPlayer[id][PLAYER_DYNAMITE], 250);
		
		new entList[33], foundPlayers = find_sphere_class(codPlayer[id][PLAYER_DYNAMITE], "player", 250.0, entList, MAX_PLAYERS), player;

		for(new i = 0; i < foundPlayers; i++)
		{
			player = entList[i];

			if(!is_user_alive(player) || get_user_team(id) == get_user_team(player)) continue;

			_cod_inflict_damage(id, player, 70.0, 0.5, DMG_HEGRENADE);
		}
		
		remove_entity(codPlayer[id][PLAYER_DYNAMITE]);
		
		codPlayer[id][PLAYER_DYNAMITE] = 0;
		
		return PLUGIN_HANDLED;
	}
	
	if(!codPlayer[id][PLAYER_DYNAMITES])
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie dynamity!");
		
		return PLUGIN_HANDLED;
	}
	
	if(codPlayer[id][PLAYER_LAST_DYNAMITE] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Dynamity mozesz klasc co 3 sekundy!");
		
		return PLUGIN_HANDLED;
	}
	
	if(!is_enough_space(id))
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Dynamitu nie mozesz postawic w przejsciu!");

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
	
	return PLUGIN_HANDLED;
}

public use_medkit(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED;

	if(!codPlayer[id][PLAYER_MEDKITS])
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie apteczki!");
		
		return PLUGIN_HANDLED;
	}
	
	if(codPlayer[id][PLAYER_LAST_MEDKIT] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Apteczki mozesz klasc co 3 sekundy!");
		
		return PLUGIN_HANDLED;
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

		new entList[33], foundPlayers = find_sphere_class(0, "player", 300.0, entList, MAX_PLAYERS, origin), player, playerHealth;

		for (new i = 0; i < foundPlayers; i++)
		{
			player = entList[i];

			if (get_user_team(player) != get_user_team(player)) continue;

			playerHealth = min(get_user_health(player) + bonusHealth, get_health(player, 1, 1, 1));
			
			if(is_user_alive(player)) entity_set_float(player, EV_FL_health, float(playerHealth));
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

	if(entity_get_float(ent, EV_FL_ltime)-2.0 < halflife_time()) set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAlpha, 100);

	make_explosion(ent, 300, 0);

	entity_set_edict(ent, EV_ENT_euser2, 1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);

	return PLUGIN_CONTINUE;
}

public use_item(id)
{
	if(!is_user_alive(id) || !codPlayer[id][PLAYER_ITEM]) return PLUGIN_HANDLED;
	
	execute_forward_ignore_one_param(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_SKILL_USED), id);
	
	return PLUGIN_HANDLED;
}

public use_skill(id)
{
	if(!is_user_alive(id) || !codPlayer[id][PLAYER_CLASS]) return PLUGIN_HANDLED;
	
	execute_forward_ignore_one_param(get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_SKILL_USED), id);

	return PLUGIN_HANDLED;
}

public player_spawn(id)
{	
	if(codPlayer[id][PLAYER_NEW_CLASS]) set_new_class(id);
	
	if(!codPlayer[id][PLAYER_CLASS])
	{
		select_fraction(id);
		
		return PLUGIN_CONTINUE;
	}
	
	if(get_bit(id, resetStats)) reset_points(id);
	
	set_attributes(id);
	
	if(codPlayer[id][PLAYER_POINTS] > 0) assign_points(id);
	
	if(codPlayer[id][PLAYER_CLASS]) execute_forward_ignore_one_param(get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_SPAWNED), id);
	
	if(codPlayer[id][PLAYER_ITEM]) execute_forward_ignore_one_param(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_SPAWNED), id);
	
	execute_forward_ignore_one_param(codForwards[FORWARD_SPAWNED], id);

	return PLUGIN_CONTINUE;
}

public player_takedamage(victim, inflictor, attacker, Float:damage, damageBits)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim) || !is_user_alive(attacker) || get_user_team(victim) == get_user_team(attacker)) return HAM_IGNORED;

	SetHamParamFloat(4, damage * (1.0 - Float:codPlayer[victim][PLAYER_DMG_REDUCE]));

	return HAM_IGNORED;
}

public player_take_damage_post(victim, inflictor, attacker, Float:damage, damageBits)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim) || !codPlayer[attacker][PLAYER_CLASS] || get_user_team(victim) == get_user_team(attacker)) return HAM_IGNORED;
	
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
	
	if(codPlayer[killer][PLAYER_CLASS])
	{
		new exp = get_exp_bonus(killer, expKill);
		
		if(codPlayer[victim][PLAYER_LEVEL] > codPlayer[killer][PLAYER_LEVEL]) exp += get_exp_bonus(killer, (codPlayer[victim][PLAYER_LEVEL] - codPlayer[killer][PLAYER_LEVEL]) * (expKill/10));

		codPlayer[killer][PLAYER_GAINED_EXP] += exp;
		
		set_dhudmessage(255, 212, 0, 0.50, 0.31, 0, 0.0, 1.0, 0.0, 0.0)
		show_dhudmessage(killer, "+%i XP", exp);
		
		if(hitPlace == HIT_HEAD)
		{
			exp = get_exp_bonus(killer, expKillHS);

			codPlayer[killer][PLAYER_GAINED_EXP] += exp;
	
			set_dhudmessage(38, 218, 116, 0.50, 0.36, 0, 0.0, 1.0, 0.0, 0.0);
			show_dhudmessage(killer, "HeadShot! +%i XP", exp);
		}
		
		if(!codPlayer[killer][PLAYER_ITEM]) set_item(killer, -1, -1);
		
		codPlayer[killer][PLAYER_KS]++;
		codPlayer[killer][PLAYER_TIME_KS] = killStreakTime;
		
		if(task_exists(killer + TASK_END_KILL_STREAK)) remove_task(killer + TASK_END_KILL_STREAK);

		set_task(1.0, "end_kill_streak", killer + TASK_END_KILL_STREAK, _, _, "b");
	}
	
	check_level(killer);
	
	if(codPlayer[victim][PLAYER_CLASS]) execute_forward_ignore_one_param(get_class_info(codPlayer[victim][PLAYER_CLASS], CLASS_KILLED), victim);
	
	if(!codPlayer[victim][PLAYER_ITEM]) return PLUGIN_CONTINUE;
	
	execute_forward_ignore_one_param(get_item_info(codPlayer[victim][PLAYER_ITEM], ITEM_KILLED), victim);
	
	codPlayer[victim][PLAYER_ITEM_DURA] -= random_num(minDamageDurability, maxDamageDurability);
	
	if(!codPlayer[victim][PLAYER_ITEM_DURA])
	{
		set_item(victim);
		
		cod_print_chat(victim, "Twoj item ulegl zniszczeniu.");
	}
	else cod_print_chat(victim, "Pozostala wytrzymalosc twojego itemu to^x03 %i^x01/^x03%i^x01.", codPlayer[victim][PLAYER_ITEM_DURA], maxDurability);
	
	return HAM_IGNORED;
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

	if((1 << weaponType) & (get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_WEAPONS) | codPlayer[id][PLAYER_EXTR_WPNS] | teamWeapons[playerTeam] | allowedWeapons)) return HAM_IGNORED;

	return HAM_SUPERCEDE;
}
	
public player_reset_max_speed(id)
{
	if(!is_user_alive(id) || !freezeTime || !codPlayer[id][PLAYER_CLASS]) return;

	new Float:speed = get_user_maxspeed(id) + codPlayer[id][PLAYER_SPEED];
	
	set_pev(id, pev_maxspeed, speed);
	set_user_maxspeed(id, speed);
}

public new_round()
{
	remove_ents();
	
	set_cvars();
	
	freezeTime = true;
	
	execute_forward_ignore(codForwards[FORWARD_NEW_ROUND]);
}

public round_start()	
{
	freezeTime = false;
	
	for(new id = 0; id <= 32; id++)
	{
		if(!is_user_alive(id)) continue;

		display_fade(id, 1<<9, 1<<9, 1<<12, 0, 255, 70, 100);
		
		switch(get_user_team(id))
		{
			case 1: client_cmd(id, "spk %s", codSounds[SOUND_START2]);
			case 2: client_cmd(id, "spk %s", codSounds[SOUND_START]);
		}
		
		codPlayer[id][PLAYER_TIME_KS] = 0;
		codPlayer[id][PLAYER_KS] = 0;
		
		if(task_exists(id + TASK_END_KILL_STREAK)) remove_task(id + TASK_END_KILL_STREAK)

		if(cs_get_user_team(id) == CS_TEAM_CT) cs_set_user_defuse(id, 1);
	}
	
	execute_forward_ignore(codForwards[FORWARD_START_ROUND]);
}

public round_end()
	execute_forward_ignore(codForwards[FORWARD_END_ROUND]);

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
	round_winner("TERRORIST");
	
public ct_win_round()
	round_winner("CT");

public round_winner(const szTeam[])
{
	new playersList[32], playersNum, id, exp;
	
	get_players(playersList, playersNum, "aeh", szTeam);
	
	if(get_playersnum() < minPlayers) return;

	for (new i = 0; i < playersNum; i++) 
	{
		id = playersList[i];
		
		if(!codPlayer[id][PLAYER_CLASS]) continue;

		exp = get_exp_bonus(id, expWinRound);
		
		codPlayer[id][PLAYER_GAINED_EXP] += exp;
		
		cod_print_chat(id, "Dostales^x03 %i^x01 doswiadczenia za wygrana runde.", exp);
		
		check_level(id);
	}
}

public bomb_planted(planter)
{
	if(get_playersnum() < minPlayers) return;

	new exp = get_exp_bonus(planter, expPlant);
	
	codPlayer[planter][PLAYER_GAINED_EXP] += exp;
	
	cod_print_chat(planter, "Dostales^x03 %i^x01 doswiadczenia za podlozenie bomby.", exp);
	
	check_level(planter);
}

public bomb_defused(defuser)
{
	if(get_playersnum() < minPlayers) return;
	
	new exp = get_exp_bonus(defuser, expDefuse);
	
	codPlayer[defuser][PLAYER_GAINED_EXP] += exp;
	
	cod_print_chat(defuser, "Dostales^x03 %i^x01 doswiadczenia za rozbrojenie bomby.", exp);
	
	check_level(defuser);
}

public hostages_rescued()
{
	if(get_playersnum() < minPlayers) return;

	new rescuer = get_loguser_index(), exp = get_exp_bonus(rescuer, expRescue);
	
	codPlayer[rescuer][PLAYER_GAINED_EXP] += exp;
	
	cod_print_chat(rescuer, "Dostales^x03 %i^x01 doswiadczenia za uratowanie zakladnikow.", exp);
	
	check_level(rescuer);
}

public cmd_start(id, uc_handle)
{		
	if(!is_user_alive(id)) return FMRES_IGNORED;
	
	execute_forward_ignore_one_param(codForwards[FORWARD_CMD_START], id);

	new Float:velocity[3], Float:speed;
	
	pev(id, pev_velocity, velocity);
	
	speed = vector_length(velocity);

	if(Float:codPlayer[id][PLAYER_SPEED] > speed * 1.8) set_pev(id, pev_flTimeStepSound, 300);

	if(!codPlayer[id][PLAYER_JUMPS]) return FMRES_IGNORED;

	new flags = pev(id, pev_flags);

	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && codPlayer[id][PLAYER_LEFT_JUMPS])
	{
		codPlayer[id][PLAYER_LEFT_JUMPS]--;
		
		pev(id, pev_velocity, velocity);
		
		velocity[2] = random_float(265.0, 285.0);
		
		set_pev(id, pev_velocity, velocity);
	}
	else if(flags & FL_ONGROUND) codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS];

	return FMRES_IGNORED;
}

public client_PreThink(id)
{
	if(!is_user_alive(id) || !get_bit(id, bunnyHop)) return PLUGIN_CONTINUE;

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

public message_intermission()
	set_task(0.25, "save_players");

public save_players()
{
	new playersList[32], id, playersNumber;
	
	get_players(playersList, playersNumber, "h");
	
	if(!playersNumber) return PLUGIN_CONTINUE;

	for (new i = 0; i < playersNumber; i++)
	{
		id = playersList[i];
		
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
	
	static hudInfo[512], className[MAX_NAME], itemName[MAX_NAME], Float:levelPercent, exp, target;
	
	target = id;
	
	if(!is_user_alive(id))
	{
		new target = pev(id, pev_iuser2);
		
		if (!codPlayer[target][PLAYER_HUD]) set_hudmessage(255, 255, 255, 0.6, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 4);
		else set_dhudmessage(255, 255, 255, 0.6, -1.0, 0, 0.0, 0.3, 0.0, 0.0);
	}
	else
	{
		if (!codPlayer[target][PLAYER_HUD]) set_hudmessage(codPlayer[target][PLAYER_HUD_RED], codPlayer[target][PLAYER_HUD_GREEN], codPlayer[target][PLAYER_HUD_BLUE], float(codPlayer[target][PLAYER_HUD_POSX]) / 100.0, float(codPlayer[target][PLAYER_HUD_POSY]) / 100.0, 0, 0.0, 0.3, 0.0, 0.0, 4);
		else set_dhudmessage(codPlayer[target][PLAYER_HUD_RED], codPlayer[target][PLAYER_HUD_GREEN], codPlayer[target][PLAYER_HUD_BLUE], float(codPlayer[target][PLAYER_HUD_POSX]) / 100.0, float(codPlayer[target][PLAYER_HUD_POSY]) / 100.0, 0, 0.0, 0.3, 0.0, 0.0);
	}
	
	if(!target) return PLUGIN_CONTINUE;
	
	get_class_info(codPlayer[target][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));
	get_item_info(codPlayer[target][PLAYER_ITEM], ITEM_NAME, itemName, charsmax(itemName));

	exp = codPlayer[target][PLAYER_LEVEL] - 1 >= 0 ? get_level_exp(codPlayer[target][PLAYER_LEVEL] - 1) : 0;
	levelPercent = (float((codPlayer[target][PLAYER_EXP] - exp)) / float((get_level_exp(codPlayer[target][PLAYER_LEVEL]) - exp))) * 100.0;
	
	formatex(hudInfo, charsmax(hudInfo), "[Klasa : %s]^n[Doswiadczenie : %0.1f%%]^n[Poziom : %i]^n[Item: %s (%i/%i)]^n[Honor: %i]", className, levelPercent, codPlayer[target][PLAYER_LEVEL], itemName, codPlayer[target][PLAYER_ITEM_DURA], maxDurability, cod_get_user_honor(target));
	
	if(get_exp_bonus(target, 1) > 1) format(hudInfo, charsmax(hudInfo), "%s^n[Exp: %i%%]", hudInfo, get_exp_bonus(target, 1) * 100);

	if(codPlayer[target][PLAYER_KS]) format(hudInfo, charsmax(hudInfo), "%s^n[KillStreak: %i (%i s)]", hudInfo, codPlayer[target][PLAYER_KS], codPlayer[target][PLAYER_TIME_KS]);

	switch(codPlayer[target][PLAYER_HUD])
	{
		case TYPE_HUD: ShowSyncHudMsg(id, hudSync, hudInfo);
		case TYPE_DHUD: show_dhudmessage(id, hudInfo);
	}
	
	return PLUGIN_CONTINUE;
} 

public show_advertisement(id)
{
	id -= TASK_SHOW_AD;
	
	cod_print_chat(id, "Witaj na serwerze Call of Duty Mod stworzonym przez^x03 O'Zone^x01.");
	cod_print_chat(id, "W celu uzyskania informacji o komendach wpisz^x03 /menu^x01 (klawisz^x03 ^"v^"^x01).");
}

public set_new_class(id)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
	
	new ret;
	
	ExecuteForward(get_class_info(codPlayer[id][PLAYER_NEW_CLASS], CLASS_ENABLED), ret, id);
	
	if(ret == COD_STOP)	
	{
		codPlayer[id][PLAYER_NEW_CLASS] = 0;
		
		select_fraction(id);
		
		return PLUGIN_CONTINUE;
	}
	
	if(codPlayer[id][PLAYER_CLASS]) 
	{
		save_data(id, NORMAL);
		
		execute_forward_ignore_one_param(get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_DISABLED), id);
	}
	
	execute_forward_ignore_two_params(codForwards[FORWARD_CLASS_CHANGED], id, codPlayer[id][PLAYER_NEW_CLASS]);
	
	codPlayer[id][PLAYER_CLASS] = codPlayer[id][PLAYER_NEW_CLASS];
	codPlayer[id][PLAYER_NEW_CLASS] = 0;
	
	load_class(id, codPlayer[id][PLAYER_CLASS]);
	
	return PLUGIN_CONTINUE;
}

set_item(id, item = 0, value = 0)
{
	if(!ArraySize(codItems) || !is_user_connected(id)) return PLUGIN_CONTINUE;
	
	item = (item == -1) ? random_num(1, ArraySize(codItems) - 1): item;
	
	new ret;
	
	ExecuteForward(get_item_info(item, ITEM_GIVE), ret, id, item, value);
	
	if(ret == COD_STOP)
	{
		set_item(id, -1, -1);
		
		return PLUGIN_CONTINUE;
	}
	
	if(codPlayer[id][PLAYER_ITEM]) execute_forward_ignore_two_params(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_DROP), id, codPlayer[id][PLAYER_ITEM]);	
	
	codPlayer[id][PLAYER_ITEM] = item;

	execute_forward_ignore_two_params(codForwards[FORWARD_ITEM_CHANGED], id, codPlayer[id][PLAYER_ITEM]);	

	new itemName[MAX_NAME];

	get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_NAME, itemName, charsmax(itemName));
	
	cod_print_chat(id, "Zdobyles^x03 %s^x01.", itemName);

	return PLUGIN_CONTINUE;
}

public check_level(id)
{	
	if(!is_user_connected(id) || !codPlayer[id][PLAYER_CLASS]) return;
	
	new level = 0;
	
	while((codPlayer[id][PLAYER_GAINED_EXP] + codPlayer[id][PLAYER_EXP]) >= get_level_exp(codPlayer[id][PLAYER_LEVEL]) && codPlayer[id][PLAYER_LEVEL] < levelLimit)
	{
		codPlayer[id][PLAYER_LEVEL]++;
		level++;
	}
	
	if(!level)
	{
		while((codPlayer[id][PLAYER_GAINED_EXP] + codPlayer[id][PLAYER_EXP]) < get_level_exp(codPlayer[id][PLAYER_LEVEL] - 1))
		{
			codPlayer[id][PLAYER_LEVEL]--;
			level--;
		}
	}

	if(level)
	{
		codPlayer[id][PLAYER_POINTS] = (codPlayer[id][PLAYER_LEVEL] - 1) * 2 - codPlayer[id][PLAYER_INT] - codPlayer[id][PLAYER_HEAL] - codPlayer[id][PLAYER_STAM] - codPlayer[id][PLAYER_STR] - codPlayer[id][PLAYER_COND];
		
		set_dhudmessage(212, 255, 85, 0.31, 0.32, 0, 0.0, 1.5, 0.0, 0.0);
		show_dhudmessage(id, "Awansowales do %i poziomu!", codPlayer[id][PLAYER_LEVEL]);

		switch(random_num(1, 3))
		{
			case 1: client_cmd(id, "spk %s", codSounds[SOUND_LVLUP]);
			case 2: client_cmd(id, "spk %s", codSounds[SOUND_LVLUP2]);
			case 3: client_cmd(id, "spk %s", codSounds[SOUND_LVLUP3]);
		}
	}
	
	if(level < 0)
	{
		reset_points(id);
		
		set_dhudmessage(212, 255, 85, 0.31, 0.32, 0, 0.0, 1.5, 0.0, 0.0);
		show_dhudmessage(id, "Spadles do %i poziomu!", codPlayer[id][PLAYER_LEVEL]);
	}
	
	codPlayer[id][PLAYER_GAINED_LEVEL] += level;
	
	save_data(id, NORMAL);
}

public set_attributes(id)
{
	codPlayer[id][PLAYER_DMG_REDUCE] = _:(0.7 * (1.0 - floatpower(1.1, -0.112311341 * get_stamina(id, 1, 1))));
	
	codPlayer[id][PLAYER_MAX_HP] = _:(get_health(id, 1, 1, 1));
	
	codPlayer[id][PLAYER_SPEED] = _:(get_condition(id, 1, 1) * 2);
	
	set_pev(id, pev_health, Float:codPlayer[id][PLAYER_MAX_HP]);
	
	entity_set_float(id, EV_FL_gravity, float(codPlayer[id][PLAYER_GRAVITY]));
	
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
	
	for(new i = 0; i < weaponTypes; i++) if(is_user_alive(id) && maxAmmo[playerWeapons[i]] > 0) cs_set_user_bpammo(id, playerWeapons[i], maxAmmo[playerWeapons[i]]);
}

public reset_player(id)
{
	rem_bit(id, dataLoaded);
	rem_bit(id, itemResistance);
	
	remove_tasks(id);
	
	codPlayer[id][PLAYER_CLASS] = 0;
	codPlayer[id][PLAYER_NEW_CLASS] = 0;
	codPlayer[id][PLAYER_LEVEL] = 0;
	codPlayer[id][PLAYER_GAINED_LEVEL] = 0;
	codPlayer[id][PLAYER_EXP] = 0;
	codPlayer[id][PLAYER_GAINED_EXP] = 0;
	codPlayer[id][PLAYER_HEAL] = 0;
	codPlayer[id][PLAYER_INT] = 0;
	codPlayer[id][PLAYER_STAM] = 0;
	codPlayer[id][PLAYER_STR] = 0;
	codPlayer[id][PLAYER_COND] = 0;
	codPlayer[id][PLAYER_POINTS] = 0;
	codPlayer[id][PLAYER_EXTR_HEAL] = 0;
	codPlayer[id][PLAYER_EXTR_INT] = 0;
	codPlayer[id][PLAYER_EXTR_STAM] = 0;
	codPlayer[id][PLAYER_EXTR_STR] = 0;
	codPlayer[id][PLAYER_EXTR_COND] = 0;
	codPlayer[id][PLAYER_EXTR_WPNS] = 0;
	codPlayer[id][PLAYER_ITEM] = 0;
	codPlayer[id][PLAYER_ITEM_DURA] = 0;
	codPlayer[id][PLAYER_MAX_HP] = _:0.0;
	codPlayer[id][PLAYER_SPEED] = _:0.0;
	codPlayer[id][PLAYER_GRAVITY] = _:0;
	codPlayer[id][PLAYER_DMG_REDUCE] = _:0.0;
	codPlayer[id][PLAYER_ROCKETS] = 0;
	codPlayer[id][PLAYER_LAST_ROCKET] = _:0.0;
	codPlayer[id][PLAYER_MINES] = 0;
	codPlayer[id][PLAYER_LAST_MINE] = _:0.0;
	codPlayer[id][PLAYER_DYNAMITE] = 0;
	codPlayer[id][PLAYER_DYNAMITES] = 0;
	codPlayer[id][PLAYER_LAST_DYNAMITE] = _:0.0;
	codPlayer[id][PLAYER_JUMPS] = 0;
	codPlayer[id][PLAYER_LEFT_JUMPS] = 0;
	codPlayer[id][PLAYER_KS] = 0;
	codPlayer[id][PLAYER_TIME_KS] = 0;
	codPlayer[id][PLAYER_HUD] = 0;
	codPlayer[id][PLAYER_HUD_RED] = 0;
	codPlayer[id][PLAYER_HUD_BLUE] = 0;
	codPlayer[id][PLAYER_HUD_GREEN] = 0;
	codPlayer[id][PLAYER_HUD_POSX] = 0;
	codPlayer[id][PLAYER_HUD_POSY] = 0;
	
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
	if(get_players_amount() > 0 && lastInfo + 3.0 > get_gametime())
	{
		if(get_players_amount() == minBonusPlayers) cod_print_chat(0, "Serwer jest pelny, a to oznacza^x03 exp x 2^x01!");
		else cod_print_chat(0, "Do pelnego serwera brakuje^x03 %i osob^x01. Exp jest wiekszy o^x03 %i%%^x01!", minBonusPlayers - get_players_amount(), get_players_amount() * 10);
		
		lastInfo = floatround(get_gametime());
	}
}

public get_level_exp(level)
	return power(level, 2) * levelRatio;
	
public get_health(id, class_health, gained_health, bonus_health)
{
	new health;
	
	if(class_health) health += get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_HEALTH);
	if(gained_health) health += codPlayer[id][PLAYER_HEAL];
	if(bonus_health) health += codPlayer[id][PLAYER_EXTR_HEAL];

	return health;
}

public get_intelligence(id, gained_intelligence, bonus_intelligence)
{
	new intelligence;
	
	if(gained_intelligence) intelligence += codPlayer[id][PLAYER_INT];
	if(bonus_intelligence) intelligence += codPlayer[id][PLAYER_EXTR_INT];
	
	return intelligence;
}

public get_strength(id, gained_strength, bonus_strength)
{
	new strength;
	
	if(gained_strength) strength += codPlayer[id][PLAYER_STR];
	if(bonus_strength) strength += codPlayer[id][PLAYER_EXTR_STR];
	
	return strength;
}

public get_stamina(id, gained_stamina, bonus_stamina)
{
	new stamina;
	
	if(gained_stamina) stamina += codPlayer[id][PLAYER_STAM];
	if(bonus_stamina) stamina += codPlayer[id][PLAYER_EXTR_STAM];
	
	return stamina;
}

public get_condition(id, gained_condition, bonus_condition)
{
	new condition;
	
	if(gained_condition) condition += codPlayer[id][PLAYER_COND];
	if(bonus_condition) condition += codPlayer[id][PLAYER_EXTR_COND];
	
	return condition;
}

public set_cvars()
{
	levelLimit = get_pcvar_num(cvarLevelLimit);
	levelRatio = get_pcvar_num(cvarLevelRatio);
	
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
	
	maxDurability = get_pcvar_num(cvarMaxDurability);
	minDamageDurability = get_pcvar_num(cvarMinDamageDurability);
	maxDamageDurability = get_pcvar_num(cvarMaxDamageDurability);
}

public sql_init()
{
	new host[32], user[32], pass[32], database[32], queryData[512], error[128], errorNum;
	
	get_cvar_string("cod_sql_host", host, charsmax(host));
	get_cvar_string("cod_sql_user", user, charsmax(user));
	get_cvar_string("cod_sql_pass", pass, charsmax(pass));
	get_cvar_string("cod_sql_database", database, charsmax(database));
	
	sql = SQL_MakeDbTuple(host, user, pass, database);

	new Handle:connectHandle = SQL_Connect(sql, errorNum, error, charsmax(error));
	
	if(errorNum)
	{
		log_to_file("addons/amxmodx/logs/cod_mod.log", "Error: %s", error);
		
		return;
	}
	
	formatex(queryData, charsmax(queryData), "CREATE TABLE IF NOT EXISTS `cod_mod` (name VARCHAR(35) NOT NULL, class VARCHAR(64) NOT NULL, exp INT UNSIGNED NOT NULL DEFAULT 0, lvl INT UNSIGNED NOT NULL DEFAULT 1, PRIMARY KEY(name, class), ");
	add(queryData,  charsmax(queryData), "intelligence INT UNSIGNED NOT NULL DEFAULT 0, health INT UNSIGNED NOT NULL DEFAULT 0, stamina INT UNSIGNED NOT NULL DEFAULT 0, condition INT UNSIGNED NOT NULL DEFAULT 0, strength INT UNSIGNED NOT NULL DEFAULT 0)");	

	new Handle:query = SQL_PrepareQuery(connectHandle, queryData);

	SQL_Execute(query);
	
	SQL_FreeHandle(query);
	SQL_FreeHandle(connectHandle);
}

public load_data(id)
{
	new tempId[1], queryData[128];
	
	tempId[0] = id;
	
	formatex(queryData, charsmax(queryData), "SELECT * FROM `cod_mod` WHERE name = '%s'", codPlayer[id][PLAYER_NAME]);
	SQL_ThreadQuery(sql, "load_data_handle", queryData, tempId, sizeof(tempId));
}

public load_data_handle(failState, Handle:query, error[], errorNum, tempId[], dataSize)
{
	if(failState) 
	{
		log_to_file("addons/amxmodx/logs/cod_mod.log", "SQL Error: %s (%d)", error, errorNum);
		
		return;
	}
	
	new id = tempId[0], className[MAX_NAME], codClass[playerClassInfo], classId;
	
	while(SQL_MoreResults(query))
	{
		SQL_ReadResult(query, SQL_FieldNameToNum(query, "class"), className, charsmax(className));
		
		classId = get_class_id(className);

		if(classId)
		{
			codClass[PCLASS_LEVEL] = SQL_ReadResult(query, SQL_FieldNameToNum(query, "lvl"));
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

	new tempId[256], className[MAX_NAME];
	get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_NAME, className, charsmax(className));
	
	formatex(tempId, charsmax(tempId), "UPDATE `cod_mod` SET exp = (`exp` + %d), lvl = (`lvl` + %d), intelligence = '%d', health = '%d', stamina = '%d', strength = '%d', condition = '%d' WHERE name = '%s' AND class = '%s'", 
	codPlayer[id][PLAYER_GAINED_EXP], codPlayer[id][PLAYER_GAINED_LEVEL], codPlayer[id][PLAYER_INT], codPlayer[id][PLAYER_HEAL], codPlayer[id][PLAYER_STAM], codPlayer[id][PLAYER_STR], codPlayer[id][PLAYER_COND], codPlayer[id][PLAYER_NAME], className);
	
	switch(end)
	{
		case NORMAL, DISCONNECT: SQL_ThreadQuery(sql, "ignore_handle", tempId);
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
			
			query = SQL_PrepareQuery(connect, tempId);
			
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

public load_class(id, class)
{
	if(!class || !get_bit(id, dataLoaded)) return;

	new codClass[playerClassInfo];
	
	ArrayGetArray(codPlayerClasses[id], class, codClass);

	codPlayer[id][PLAYER_GAINED_EXP] = 0;
	codPlayer[id][PLAYER_GAINED_LEVEL] = 0;
	codPlayer[id][PLAYER_LEVEL] = max(1, codClass[PCLASS_LEVEL]);
	codPlayer[id][PLAYER_EXP] = codClass[PCLASS_EXP];
	codPlayer[id][PLAYER_INT] = codClass[PCLASS_INT];
	codPlayer[id][PLAYER_HEAL] = codClass[PCLASS_HEAL];
	codPlayer[id][PLAYER_STAM] = codClass[PCLASS_STAM];
	codPlayer[id][PLAYER_STR] = codClass[PCLASS_STR];
	codPlayer[id][PLAYER_COND] = codClass[PCLASS_COND];

	if(!codPlayer[id][PLAYER_LEVEL])
	{
		codPlayer[id][PLAYER_LEVEL] = 1;
		codClass[PCLASS_LEVEL] = 1;
		
		ArraySetArray(codPlayerClasses[id], class, codClass);
		
		new tempId[256], className[MAX_NAME];
		
		get_class_info(class, CLASS_NAME, className, charsmax(className));
		
		formatex(tempId, charsmax(tempId), "INSERT INTO `cod_mod` (`name`, `class`) VALUES ('%s', '%s') ON DUPLICATE KEY UPDATE name = name", codPlayer[id][PLAYER_NAME], className);
		SQL_ThreadQuery(sql, "ignore_handle", tempId);
	}
	
	codPlayer[id][PLAYER_POINTS] = (codPlayer[id][PLAYER_LEVEL] - 1)*2 - codPlayer[id][PLAYER_INT] - codPlayer[id][PLAYER_HEAL] - codPlayer[id][PLAYER_STAM] - codPlayer[id][PLAYER_STR] - codPlayer[id][PLAYER_COND];
} 

public ignore_handle(failState, Handle:query, error[], errorNum, itemData[], dataSize)
{
	if (failState) 
	{
		if(failState == TQUERY_CONNECT_FAILED) log_to_file("addons/amxmodx/logs/cod_mod.log", "Could not connect to SQL database.  [%d] %s", errorNum, error);
		else if (failState == TQUERY_QUERY_FAILED) log_to_file("addons/amxmodx/logs/cod_mod.log", "Query failed. [%d] %s", errorNum, error);
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
	
	if(force)
	{
		set_new_class(id);
		set_attributes(id);
	}
}

public _cod_get_classid(className[])
{
	param_convert(1);
	
	return get_class_id(className);
}

public _cod_get_class_name(class, dataReturn[], dataLenght)
{
	param_convert(2);
	
	get_class_info(class, CLASS_NAME, dataReturn, charsmax(dataLenght));
}

public _cod_get_class_desc(class, dataReturn[], dataLenght)
{
	param_convert(2);
	
	get_class_info(class, CLASS_DESC, dataReturn, charsmax(dataLenght));
}

public _cod_get_class_health(class)
{
	return get_class_info(class, CLASS_HEALTH);
}

public _cod_get_classes_num()
	return ArraySize(codClasses);

public _cod_get_user_item(id, &value)
{
	new function = get_func_id("cod_get_item_value", get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_PLUGIN));

	if(function != -1)
	{
		callfunc_begin_i(function, get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_PLUGIN))
		callfunc_push_int(id);
		callfunc_push_int(value);
		callfunc_end();
	}

	return codPlayer[id][PLAYER_ITEM];
}

public _cod_set_user_item(id, item, value)
	set_item(id, item, value);

public _cod_upgrade_user_item(id)
{
	if(!ArraySize(codItems)) return;
	
	switch(random_num(1, 4))
	{
		case 1:
		{
			new durability = random_num(minDamageDurability, maxDamageDurability);
			
			codPlayer[id][PLAYER_ITEM_DURA] -= durability;
	
			if(!codPlayer[id][PLAYER_ITEM_DURA])
			{
				set_item(id);
		
				cod_print_chat(id, "Ulepszenie^x03 nieudane^x01! Twoj item ulegl^x03 zniszczeniu^x01.");
				
				return;
			}
			
			cod_print_chat(id, "Ulepszenie^x03 nieudane^x01! Straciles^x03 %i^x01 wytrzymalosci itemu.", durability);
		}
		case 2:
		{
			set_item(id);
		
			cod_print_chat(id, "Ulepszenie^x03 nieudane^x01! Twoj item ulegl^x03 zniszczeniu^x01.");
		}
		case 3, 4:
		{
			new forwardHandle = CreateOneForward(get_item_info(codPlayer[id][PLAYER_ITEM], ITEM_PLUGIN), "cod_item_upgrade", FP_CELL);
	
			ExecuteForward(forwardHandle, id, id);
			DestroyForward(forwardHandle);	
		}
	}
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

public _cod_get_item_name(item, dataReturn[], dataLenght)
{
	param_convert(2);
	
	get_item_info(item, ITEM_NAME, dataReturn, charsmax(dataLenght));
}

public _cod_get_item_desc(item, dataReturn[], dataLenght)
{
	param_convert(2);
	
	get_item_info(item, ITEM_DESC, dataReturn, charsmax(dataLenght));
}

public _cod_get_items_num()
	return ArraySize(codItems);
	
public _cod_get_item_durability(id)
	return codPlayer[id][PLAYER_ITEM_DURA];
	
public _cod_set_item_durability(id, value)
	codPlayer[id][PLAYER_ITEM_DURA] = min(value, maxDurability);

public _cod_max_item_durability(id)
	return maxDurability;

public _cod_get_user_bonus_health(id)
	return codPlayer[id][PLAYER_EXTR_HEAL];

public _cod_get_user_bonus_int(id)
	return codPlayer[id][PLAYER_EXTR_INT];
	
public _cod_get_user_bonus_stamina(id)
	return codPlayer[id][PLAYER_EXTR_STAM];
	
public _cod_get_user_bonus_strength(id)
	return codPlayer[id][PLAYER_EXTR_STR];
	
public _cod_get_user_bonus_condition(id)
	return codPlayer[id][PLAYER_EXTR_COND];

public _cod_set_user_bonus_health(id, value)
	codPlayer[id][PLAYER_EXTR_HEAL] = max(0, codPlayer[id][PLAYER_EXTR_HEAL] + value);
	
public _cod_set_user_bonus_int(id, value)
	codPlayer[id][PLAYER_EXTR_INT] = max(0, codPlayer[id][PLAYER_EXTR_INT] + value);

public _cod_set_user_bonus_stamina(id, value)
{
	codPlayer[id][PLAYER_EXTR_STAM] = max(0, codPlayer[id][PLAYER_EXTR_STAM] + value);
	
	codPlayer[id][PLAYER_DMG_REDUCE] = _:(0.7 * (1.0 - floatpower(1.1, -0.112311341 * get_stamina(id, 1, 1))));
}

public _cod_set_user_bonus_strength(id, value)
	codPlayer[id][PLAYER_EXTR_STR] = max(0, codPlayer[id][PLAYER_EXTR_STR] + value);

public _cod_set_user_bonus_condition(id, value)
{
	codPlayer[id][PLAYER_EXTR_COND] = max(0, codPlayer[id][PLAYER_EXTR_COND] + value);
	
	codPlayer[id][PLAYER_SPEED] = _:(get_condition(id, 1, 1) * 2);
}

public _cod_get_user_health(id, class_health, gained_health, bonus_health)
	return get_health(id, class_health, gained_health, bonus_health);

public _cod_get_user_int(id, gained_intelligence, bonus_intelligence)
	return get_intelligence(id, gained_intelligence, bonus_intelligence);

public _cod_get_user_stamina(id, gained_stamina, bonus_stamina)
	return get_stamina(id, gained_stamina, bonus_stamina);

public _cod_get_user_strength(id, gained_strength, bonus_strength)
	return get_strength(id, gained_strength, bonus_strength);
	
public _cod_get_user_condition(id, gained_condition, bonus_condition)
	return get_condition(id, gained_condition, bonus_condition);

public _cod_add_user_health(id, value)
	set_user_health(id, min(get_user_health(id) + value, get_health(id, 1, 1, 1)));

public _cod_get_user_rockets(id)
	return codPlayer[id][PLAYER_ROCKETS];

public _cod_get_user_mines(id)
	return codPlayer[id][PLAYER_MINES];

public _cod_get_user_dynamites(id)
	return codPlayer[id][PLAYER_DYNAMITES];
	
public _cod_get_user_medkits(id)
	return codPlayer[id][PLAYER_MEDKITS];
	
public _cod_get_user_multijump(id)
	return codPlayer[id][PLAYER_JUMPS];
	
public _cod_get_user_gravity(id)
	return codPlayer[id][PLAYER_GRAVITY];

public _cod_set_user_rockets(id, value)
	codPlayer[id][PLAYER_ROCKETS] = max(0, value);

public _cod_set_user_mines(id, value)
	codPlayer[id][PLAYER_MINES] = max(0, value);

public _cod_set_user_dynamites(id, value)
	codPlayer[id][PLAYER_DYNAMITES] = max(0, value);
	
public _cod_set_user_medkits(id, value)
	codPlayer[id][PLAYER_MEDKITS] = max(0, value);

public _cod_set_user_multijump(id, value)
	codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS] = max(0, value);
	
public _cod_set_user_gravity(id, value)
{
	codPlayer[id][PLAYER_GRAVITY] = _:floatmax(0.1, float(value));
	
	entity_set_float(id, EV_FL_gravity, float(codPlayer[id][PLAYER_GRAVITY]));
}
	
public _cod_add_user_rockets(id, value)
	codPlayer[id][PLAYER_ROCKETS] = max(0, codPlayer[id][PLAYER_ROCKETS] + value);

public _cod_add_user_mines(id, value)
	codPlayer[id][PLAYER_MINES] = max(0, codPlayer[id][PLAYER_MINES] + value);

public _cod_add_user_dynamites(id, value)
	codPlayer[id][PLAYER_DYNAMITES] = max(0, codPlayer[id][PLAYER_DYNAMITES] + value);
	
public _cod_add_user_medkits(id, value)
	codPlayer[id][PLAYER_MEDKITS] = max(0, codPlayer[id][PLAYER_MEDKITS] + value);
	
public _cod_add_user_multijump(id, value)
	codPlayer[id][PLAYER_LEFT_JUMPS] = codPlayer[id][PLAYER_JUMPS] = max(0, codPlayer[id][PLAYER_JUMPS] + value);
	
public _cod_add_user_gravity(id, value)
{
	codPlayer[id][PLAYER_GRAVITY] = _:floatmax(0.1, float(codPlayer[id][PLAYER_GRAVITY] + value));
	
	entity_set_float(id, EV_FL_gravity, float(codPlayer[id][PLAYER_GRAVITY]));
}

public _cod_get_user_resistance(id, value)
	return get_bit(id, itemResistance);
	
public _cod_get_user_bunnyhop(id, value)
	return get_bit(id, bunnyHop);
	
public _cod_get_user_footsteps(id)
	get_user_footsteps(id);
	
public _cod_set_user_itemResistance(id, value)
	value ? set_bit(id, itemResistance) : rem_bit(id, itemResistance);

public _cod_set_user_bunnyhop(id, value)
	value ? set_bit(id, bunnyHop) : rem_bit(id, bunnyHop);

public _cod_set_user_footsteps(id, value)
	set_user_footsteps(id, value);

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
	
	if((1<<weapon) & (allowedWeapons | teamWeapons[get_user_team(id)] | get_class_info(codPlayer[id][PLAYER_CLASS], CLASS_WEAPONS))) return;
	
	new weaponName[22];
	
	get_weaponname(weapon, weaponName, charsmax(weaponName));
	
	if(!((1<<weapon) & (1<<CSW_HEGRENADE | 1<<CSW_SMOKEGRENADE | 1<<CSW_FLASHBANG))) engclient_cmd(id, "drop", weaponName);
}

public _cod_display_fade(id, duration, holdtime, fadetype, red, green, blue, alpha)
	display_fade(id, duration * (1<<12), holdtime * (1<<12), fadetype, red, green, blue, alpha);
	
public _cod_screen_shake(id, amplitude, duration, frequency)
	screen_shake(id, amplitude, duration, frequency);
	
public _cod_make_explosion(ent, distance)
	make_explosion(ent, distance);
	
public _cod_make_bartimer(id, duration)
	make_bar_timer(id, duration);

public _cod_inflict_damage(attacker, victim, Float:damage, Float:factor, flags)
	if(!get_bit(victim, itemResistance)) ExecuteHam(Ham_TakeDamage, victim, attacker, attacker, damage + get_intelligence(attacker, 1, 1) * factor, (1<<31) | flags);
	
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
	
	codItem[ITEM_GIVE] = CreateOneForward(plugin, "cod_item_enabled", FP_CELL, FP_CELL, FP_CELL);
	codItem[ITEM_DROP] = CreateOneForward(plugin, "cod_item_disabled", FP_CELL);
	codItem[ITEM_SPAWNED] = CreateOneForward(plugin, "cod_item_spawned", FP_CELL);
	codItem[ITEM_KILLED] = CreateOneForward(plugin, "cod_item_killed", FP_CELL);
	codItem[ITEM_SKILL_USED] = CreateOneForward(plugin, "cod_item_skill_used", FP_CELL);
	codItem[ITEM_UPGRADE] = CreateOneForward(plugin, "cod_item_upgrade", FP_CELL);
	
	codItem[ITEM_DAMAGE_ATTACKER] = get_func_id("cod_item_damage_attacker", plugin);
	codItem[ITEM_DAMAGE_VICTIM] = get_func_id("cod_item_damage_victim", plugin);
	
	ArrayPushArray(codItems, codItem);
	
	return PLUGIN_CONTINUE;
}

public _cod_register_class(plugin, params)
{
	if(params != 5) return PLUGIN_CONTINUE;

	new codClass[classInfo];
	
	get_string(1, codClass[CLASS_NAME], charsmax(codClass[CLASS_NAME]));
	get_string(2, codClass[CLASS_DESC], charsmax(codClass[CLASS_DESC]));
	
	get_string(3, codClass[CLASS_FRACTION], charsmax(codClass[CLASS_FRACTION]));
	
	if(!equal(codClass[CLASS_FRACTION], "")) check_fraction(codClass[CLASS_FRACTION]);
	
	codClass[CLASS_WEAPONS] = get_param(4);
	codClass[CLASS_HEALTH] = get_param(5);

	codClass[CLASS_PLUGIN] = plugin;
	
	codClass[CLASS_ENABLED] = CreateOneForward(plugin, "cod_class_enabled", FP_CELL);
	codClass[CLASS_DISABLED] = CreateOneForward(plugin, "cod_class_disabled", FP_CELL);
	codClass[CLASS_SPAWNED] = CreateOneForward(plugin, "cod_class_spawned",FP_CELL);
	codClass[CLASS_KILLED] = CreateOneForward(plugin, "cod_class_killed", FP_CELL);
	codClass[CLASS_SKILL_USED] = CreateOneForward(plugin, "cod_class_skill_used", FP_CELL);

	codClass[CLASS_DAMAGE_VICTIM] = get_func_id("cod_class_damage_victim", plugin);
	codClass[CLASS_DAMAGE_ATTACKER] = get_func_id("cod_class_damage_attacker", plugin);
	
	ArrayPushArray(codClasses, codClass);

	return PLUGIN_CONTINUE;
}

stock get_exp_bonus(id, exp)
{
	new Float:bonus = 1.0;
	
	if(cod_get_user_vip(id)) bonus += 0.5;

	bonus += floatmin(codPlayer[id][PLAYER_KS] * 0.2, 1.0);
	
	bonus += get_players_amount() * 0.1;
	
	return floatround(exp * bonus);
}

stock get_players_amount()
{
	if(get_maxplayers() - playersNum <= minBonusPlayers) return (get_maxplayers() - playersNum);

	return 0;
}

stock check_fraction(fractionName[])
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

stock execute_forward_ignore(fForwardHandle)
{
	static ret;
	
	return ExecuteForward(fForwardHandle, ret);
}

stock execute_forward_ignore_one_param(fForwardHandle, iParam)
{
	static ret;
	
	return ExecuteForward(fForwardHandle, ret, iParam);
}

stock execute_forward_ignore_two_params(fForwardHandle, iParamOne, iParamTwo)
{
	static ret;
	
	return ExecuteForward(fForwardHandle, ret, iParamOne, iParamTwo);
}

stock get_class_info(class, info, dataReturn[] = "", dataLenght = 0)
{
	new codClass[classInfo];
	
	ArrayGetArray(codClasses, class, codClass);
	
	if(info == CLASS_NAME || info == CLASS_DESC || info == CLASS_FRACTION)
	{
		copy(dataReturn, dataLenght, codClass[info]);
		
		return 0;
	}
	
	return codClass[info];
}

stock get_class_id(className[])
{
	new codClass[classInfo];
	
	for(new i = 1; i < ArraySize(codClasses); i++)
	{
		ArrayGetArray(codClasses, i, codClass);
		
		if(equali(codClass[CLASS_NAME], className)) return i;
	}
	
	return 0;
}

stock get_item_info(item, info, dataReturn[] = "", dataLenght = 0)
{
	new codItem[itemInfo];
	
	ArrayGetArray(codItems, item, codItem);
	
	if(info == ITEM_NAME || info == ITEM_DESC)
	{
		copy(dataReturn, dataLenght, codItem[info]);
		
		return 0;
	}
	
	return codItem[info];
}

stock make_explosion(ent, distance = 0, explosion = 1)
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
}

stock make_bar_timer(id, duration)
{
	static msgBartimer;
	
	if(!msgBartimer) msgBartimer = get_user_msgid("BarTime");
	
	message_begin(id ? MSG_ONE : MSG_ALL , msgBartimer, {0, 0, 0}, id);
	write_byte(duration); 
	write_byte(0);
	message_end();
}

stock display_fade(id, duration, holdtime, fadetype, red, green, blue, alpha)
{
	if(!pev_valid(id)) return;

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
	if(!pev_valid(id)) return;
	
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
	new Float:origin[3], Float:start[3], Float:end[3];
	
	pev(id, pev_origin, origin);
 
	start[0] = end[0] = origin[0];
	start[1] = end[1] = origin[1];
	start[2] = end[2] = origin[2];

	start[0] += 135.0;
	end[0] -= 135.0;
 
	if(is_wall_between_points(start, end, id)) return 0;
 
	start[0] -= 135.0;
	end[0] += 135.0;
	start[1] += 135.0;
	end[1] -= 135.0;
 
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

stock mysql_escape_string(const dataSource[], dataDest[], dataLenght)
{
	copy(dataDest, dataLenght, dataSource);
	
	replace_all(dataDest, dataLenght, "\\", "\\\\");
	replace_all(dataDest, dataLenght, "\0", "\\0");
	replace_all(dataDest, dataLenght, "\n", "\\n");
	replace_all(dataDest, dataLenght, "\r", "\\r");
	replace_all(dataDest, dataLenght, "\x1a", "\Z");
	replace_all(dataDest, dataLenght, "'", "\'");
	replace_all(dataDest, dataLenght, "`", "\`");
	replace_all(dataDest, dataLenght, "^"", "\^"");
}