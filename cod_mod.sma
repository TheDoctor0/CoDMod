#include <amxmodx>
#include <cod>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <fun>
#include <sqlx>
#include <dhudmessage>

#define PLUGIN "CoD Mod"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define MAX_NAME 64
#define MAX_DESC 256

#define TASK_SHOW_INFO 672
#define TASK_SHOW_AD 768
#define TASK_SET_SPEED 832
#define TASK_END_KILL_STREAK 979

#define	FL_WATERJUMP (1<<11)
#define	FL_ONGROUND	(1<<9)

new const iMaxAmmo[31] = { 0, 52, 0, 90, 1, 31, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 31, 90, 120, 90, 2, 35, 90, 90,0, 100 };

new const iPoints[] = { 1, 3, 5, 10, 25, -1 };

new const szCommandClass[][] = { "klasa", "say /klasa", "say_team /klasa", "say /class", "say_team /class", "say /k", "say_team /k", "say /c", "say_team /c" };
new const szCommandClasses[][] = { "klasy", "say /klasy", "say_team /klasy", "say /classes", "say_team /classes", "say /ky", "say_team /ky", "say /cs", "say_team /cs" };
new const szCommandItem[][] = { "item", "say /item", "say_team /item", "say /przedmiot", "say_team /przedmiot", "say /i", "say_team /i", "say /p", "say_team /p" };
new const szCommandItems[][] = { "itemy", "say /itemy", "say_team /itemy", "say /przedmioty", "say_team /przedmioty", "say /iy", "say_team /iy", "say /py", "say_team /py" };
new const szCommandDrop[][] = { "wyrzuc", "say /wyrzuc", "say_team /wyrzuc", "say /drop", "say_team /drop", "say /w", "say_team /w", "say /d", "say_team /d" };
new const szCommandReset[][] = { "reset", "say /reset", "say_team /reset", "say /r", "say_team /r" };
new const szCommandPoints[][] = { "staty", "say /staty", "say_team /staty", "say /punkty", "say_team /punkty", "say /s", "say_team /s", "say /p", "say_team /p" };
new const szCommandHUD[][] = { "hud", "say /hud", "say_team /hud", "say /zmienhud", "say_team /zmienhud", "say /changehud", "say_team /changehud" };
new const szCommandBlock[][] = { "fullupdate", "cl_autobuy", "cl_rebuy", "cl_setautobuy", "rebuy", "autobuy", "hegren", "sgren", "flash", "-rocket", "-mine", "-dynamite", "-medkit" };

enum _:eSounds { SOUND_SELECT, SOUND_SELECT2, SOUND_START, SOUND_START2, SOUND_LVLUP, SOUND_LVLUP2, SOUND_LVLUP3 };

new const szSounds[eSounds][] =
{
	"CoDMod/select.wav",
	"CoDMod/select2.wav",
	"CoDMod/start.wav",
	"CoDMod/start2.wav",
	"CoDMod/levelup.wav",
	"CoDMod/levelup2.wav",
	"CoDMod/levelup3.wav"
};

enum _:eModels { MODEL_ROCKET, MODEL_MINE, MODEL_DYNAMITE, MODEL_MEDKIT };

new const szModels[eModels][] =
{
	"models/CoDMod/rocket.mdl",
	"models/CoDMod/mine.mdl",
	"models/CoDMod/dynamite.mdl",
	"models/CoDMod/medkit.mdl"
};

enum _:eSprites { SPRITE_EXPLOSION, SPRITE_WHITE };

new const szSprites[eSprites][] =
{
	"sprites/dexplo.spr",
	"sprites/white.spr"
};

new iSprites[sizeof szSprites];

new iTeamWeapons[] = { 0, 1<<CSW_GLOCK18, 1<<CSW_USP },
	iAllowedWeapons = 1<<CSW_KNIFE | 1<<CSW_C4;

enum _:eItemInfo { ITEM_NAME[MAX_NAME], ITEM_DESC[MAX_DESC], ITEM_PLUGIN, ITEM_GIVE, ITEM_DROP, 
	ITEM_SPAWNED, ITEM_KILLED, ITEM_SKILL_USED, ITEM_UPGRADE, ITEM_DAMAGE_ATTACKER, ITEM_DAMAGE_VICTIM };

enum _:eClassInfo { CLASS_NAME[MAX_NAME], CLASS_DESC[MAX_DESC], CLASS_FRACTION[MAX_NAME], CLASS_HEALTH, CLASS_WEAPONS, CLASS_PLUGIN, 
	CLASS_ENABLED, CLASS_DISABLED, CLASS_SPAWNED, CLASS_KILLED, CLASS_SKILL_USED, CLASS_DAMAGE_VICTIM, CLASS_DAMAGE_ATTACKER };

enum _:ePlayerClassInfo { PCLASS_LEVEL, PCLASS_EXP, PCLASS_HEAL, PCLASS_INT, PCLASS_STAM, PCLASS_STR, PCLASS_COND, PCLASS_POINTS };

enum _:eForwards { FORWARD_CLASS_CHANGED, FORWARD_ITEM_CHANGED, FORWARD_RENDER_CHANGED, FORWARD_GRAVITY_CHANGED, FORWARD_DAMAGE_PRE, FORWARD_DAMAGE_POST, 
	FORWARD_WEAPON_DEPLOY, FORWARD_KILLED, FORWARD_SPAWNED, FORWARD_CMD_START, FORWARD_NEW_ROUND, FORWARD_START_ROUND, FORWARD_END_ROUND };

enum ePlayerInfo { PLAYER_CLASS, PLAYER_NEW_CLASS, PLAYER_LEVEL, PLAYER_GAINED_LEVEL, PLAYER_EXP, PLAYER_GAINED_EXP, PLAYER_HEAL, 
	PLAYER_INT, PLAYER_STAM, PLAYER_STR, PLAYER_COND, PLAYER_POINTS, PLAYER_POINTS_SPEED, PLAYER_EXTR_HEAL, PLAYER_EXTR_INT, 
	PLAYER_EXTR_STAM, PLAYER_EXTR_STR, PLAYER_EXTR_COND, PLAYER_EXTR_WPNS, PLAYER_ITEM, PLAYER_ITEM_DURA, PLAYER_MAX_HP, PLAYER_SPEED, 
	PLAYER_GRAVITY, PLAYER_DMG_REDUCE, PLAYER_ROCKETS, PLAYER_LAST_ROCKET, PLAYER_MINES, PLAYER_LAST_MINE, PLAYER_DYNAMITE, 
	PLAYER_DYNAMITES, PLAYER_LAST_DYNAMITE, PLAYER_MEDKITS, PLAYER_LAST_MEDKIT, PLAYER_JUMPS, PLAYER_LEFT_JUMPS, PLAYER_KS, 
	PLAYER_TIME_KS, PLAYER_HUD, PLAYER_HUD_RED, PLAYER_HUD_GREEN, PLAYER_HUD_BLUE, PLAYER_HUD_POSX, PLAYER_HUD_POSY, PLAYER_NAME[MAX_NAME] };
	
new gPlayer[MAX_PLAYERS + 1][ePlayerInfo];
	
enum eSave { NORMAL, DISCONNECT, MAP_END };

enum _:eHUD { TYPE_HUD, TYPE_DHUD };

new iKillExp, iKillHSExp, iDamageExp, iWinExp, iPlantExp, iDefuseExp, iRescueExp, iLevelLimit, iLevelRatio, 
	iKillStreakTime, iMinPlayers, iMinBonusPlayers, iMaxDurability, iMinDamageDurability, iMaxDamageDurability;

new cKillExp, cKillHSExp, cDamageExp, cWinExp, cPlantExp, cDefuseExp, cRescueExp, cLevelLimit, cLevelRatio, 
	cKillStreakTime, cMinPlayers, cMinBonusPlayers, cMaxDurability, cMinDamageDurability, cMaxDamageDurability;

new Array:gItems, Array:gClasses, Array:gFractions, Array:gPlayersClasses[MAX_PLAYERS + 1], gForwards[eForwards];

new iPlayers, iResistance, iBunnyHop, iLoaded, iReset, iLastInfo;

new bool:bFreezeTime, Handle:hSqlHook, sHudSync;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);	
	
	register_cvar("cod_sql_host", "sql.pukawka.pl", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_sql_user", "299081", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_sql_pass", "t993KU5garchck1x", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_sql_db", "299081_cod", FCVAR_SPONLY|FCVAR_PROTECTED);
	
	cKillExp = register_cvar("cod_killxp", "10");
	cKillHSExp = register_cvar("cod_hsxp", "5");
	cDamageExp = register_cvar("cod_damagexp", "3");
	cWinExp = register_cvar("cod_winxp", "25");
	cPlantExp = register_cvar("cod_bombxp", "15");
	cDefuseExp = register_cvar("cod_defusexp", "15");
	cRescueExp = register_cvar("cod_hostxp", "15");
	cLevelLimit = register_cvar("cod_maxlevel", "500");
	cLevelRatio = register_cvar("cod_levelratio", "35");
	cKillStreakTime = register_cvar("cod_killstreaktime", "15");
	cMinPlayers = register_cvar("cod_minplayers", "5");
	cMinBonusPlayers = register_cvar("cod_minbonusplayers", "10");
	cMaxDurability = register_cvar("cod_maxdurability", "100"); 
	cMinDamageDurability = register_cvar("cod_mindamagedurability", "20");
	cMaxDamageDurability = register_cvar("cod_maxdamagedurability", "35");
	
	for(new i; i < sizeof szCommandClass; i++) register_clcmd(szCommandClass[i], "SelectFraction");

	for(new i; i < sizeof szCommandClasses; i++) register_clcmd(szCommandClasses[i], "ClassDesc");

	for(new i; i < sizeof szCommandItem; i++) register_clcmd(szCommandItem[i], "ItemDesc");
	
	for(new i; i < sizeof szCommandItems; i++) register_clcmd(szCommandItems[i], "ItemsDesc");

	for(new i; i < sizeof szCommandDrop; i++) register_clcmd(szCommandDrop[i], "DropItem");

	for(new i; i < sizeof szCommandReset; i++) register_clcmd(szCommandReset[i], "ResetStats");

	for(new i; i < sizeof szCommandPoints; i++) register_clcmd(szCommandPoints[i], "AssignPoints");
	
	for(new i; i < sizeof szCommandHUD; i++) register_clcmd(szCommandHUD[i], "ChangeHUD");

	for(new i; i < sizeof szCommandBlock; i++) register_clcmd(szCommandBlock[i], "BlockCommand");

	register_clcmd("+rocket", "UseRocket");
	register_clcmd("+mine", "UseMine");
	register_clcmd("+dynamite", "UseDynamite");
	register_clcmd("+medkit", "UseMedkit");
	
	register_impulse(100, "UseItem");
	register_impulse(201, "UseSkill");
	
	register_touch("rocket", "*" , "TouchRocket");
	register_touch("mine", "player" , "TouchMine");
	
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamagePost", 1);
	RegisterHam(Ham_Touch, "armoury_entity", "TouchWeapon");
	RegisterHam(Ham_Touch, "weapon_shield", "TouchWeapon");
	RegisterHam(Ham_Touch, "weaponbox", "TouchWeapon");
	RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "PlayerResetMaxSpeed", 1);
	
	register_logevent("RoundStart", 2, "1=Round_Start");
	register_logevent("RoundEnd", 2, "1=Round_End");	
	
	register_event("HLTV", "NewRound", "a", "1=0", "2=0");
	register_event("Health", "MessageHealth", "be", "1!255");
	register_event("SendAudio", "TTWin" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "CTWin", "a", "2&%!MRAD_ctwin");
	register_event("TextMsg", "HostagesRescue", "a", "2&#All_Hostages_R");
	
	register_forward(FM_CmdStart, "CmdStart");
	
	register_message(SVC_INTERMISSION, "MsgIntermission");
	
	sHudSync = CreateHudSyncObj();
	
	gForwards[FORWARD_CLASS_CHANGED] = CreateMultiForward("cod_class_changed", ET_CONTINUE, FP_CELL, FP_CELL);
	gForwards[FORWARD_ITEM_CHANGED] = CreateMultiForward("cod_item_changed", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL);
	gForwards[FORWARD_RENDER_CHANGED] = CreateMultiForward("cod_render_changed", ET_IGNORE, FP_CELL);
	gForwards[FORWARD_GRAVITY_CHANGED] = CreateMultiForward("cod_gravity_changed", ET_IGNORE, FP_CELL);
	gForwards[FORWARD_DAMAGE_PRE] = CreateMultiForward ("cod_damage_pre", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	gForwards[FORWARD_DAMAGE_POST] = CreateMultiForward ("cod_damage_post", ET_IGNORE, FP_CELL, FP_CELL, FP_ARRAY);
	gForwards[FORWARD_WEAPON_DEPLOY] = CreateMultiForward("cod_weapon_deploy", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL);
	gForwards[FORWARD_KILLED] = CreateMultiForward("cod_killed", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL);
	gForwards[FORWARD_SPAWNED] = CreateMultiForward("cod_spawned", ET_IGNORE, FP_CELL);
	gForwards[FORWARD_CMD_START] = CreateMultiForward("cod_cmd_start", ET_IGNORE, FP_CELL);
	gForwards[FORWARD_NEW_ROUND] = CreateMultiForward("cod_new_round", ET_IGNORE);
	gForwards[FORWARD_START_ROUND] = CreateMultiForward("cod_start_round", ET_IGNORE);
	gForwards[FORWARD_END_ROUND] = CreateMultiForward("cod_end_round", ET_IGNORE);
	
	gItems = ArrayCreate(eItemInfo);
	gClasses = ArrayCreate(eClassInfo);
	gFractions = ArrayCreate();
	
	for(new i = 1; i < MAX_PLAYERS + 1; i++) gPlayersClasses[i] = ArrayCreate(ePlayerClassInfo);
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
	
	register_native("cod_set_user_resistance", "_cod_set_user_resistance", 1);
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
	new szConfig[64], aItem[eItemInfo], aClass[eClassInfo];
	
	get_localinfo("amxx_configsdir", szConfig, charsmax(szConfig));
	
	server_cmd("exec %s/cod_mod.cfg", szConfig);
	server_exec();
	
	formatex(aItem[ITEM_NAME], charsmax(aItem[ITEM_NAME]), "Brak");
	formatex(aItem[ITEM_DESC], charsmax(aItem[ITEM_DESC]), "Zabij kogos, aby zdobyc przedmiot");
	
	ArrayPushArray(gItems, aItem);
	
	formatex(aClass[CLASS_NAME], charsmax(aClass[CLASS_NAME]), "Brak");
	
	ArrayPushArray(gClasses, aClass);
	
	SqlInit();
	SetCvars();
}

public plugin_end()
{
	SQL_FreeHandle(hSqlHook);
	
	ArrayDestroy(gItems);
	ArrayDestroy(gClasses);
	ArrayDestroy(gFractions);
	
	for(new i = 1; i < MAX_PLAYERS + 1; i++) ArrayDestroy(gPlayersClasses[i]);
}

public plugin_precache()
{	
	for(new i = 0; i < sizeof szSounds; i++) precache_sound(szSounds[i]);

	for(new i = 0; i < sizeof szModels; i++) precache_model(szModels[i]);
	
	for(new i = 0; i < sizeof szSprites; i++) iSprites[i] = precache_model(szSprites[i]);
}

public client_connect(id)
{	
	ResetPlayer(id);
	
	if(is_user_bot(id) || is_user_hltv(id)) return;
	
	cmd_execute(id, "bind z +rocket");
	cmd_execute(id, "bind x +mine");
	cmd_execute(id, "bind c +dynamite");
	cmd_execute(id, "bind n +medkit");
	
	get_user_name(id, gPlayer[id][PLAYER_NAME], charsmax(gPlayer[]));
	
	mysql_escape_string(gPlayer[id][PLAYER_NAME], gPlayer[id][PLAYER_NAME], charsmax(gPlayer[]));
	
	LoadData(id);
}

public client_putinserver(id)
{
	iPlayers++;
	
	ShowBonusExpInfo();
	
	if(is_user_bot(id) || is_user_hltv(id)) return;
	
	cmd_execute(id, "bind z +rocket");
	cmd_execute(id, "bind x +mine");
	cmd_execute(id, "bind c +dynamite");
	cmd_execute(id, "bind v +medkit");
	
	set_task(20.0, "ShowAdvertisement", id + TASK_SHOW_AD);
	
	set_task(0.2, "ShowInfo", id + TASK_SHOW_INFO, _, _, "b");
}

public client_disconnect(id)
{
	iPlayers--;
	
	ShowBonusExpInfo();
	
	SaveData(id, DISCONNECT);

	RemoveTasks(id);
	
	RemoveEnts(id);
}

public SelectFraction(id)
{
	if(!Get(id, iLoaded))
	{
		cod_print_chat(id, "Trwa wczytywanie twoich klas...");
		
		return;
	}
	
	if(ArraySize(gFractions))
	{
		new szFraction[MAX_NAME];
	
		new menu = menu_create("\wWybierz \rFrakcje:", "SelectFraction_Handle");
	
		for(new i = 0; i < ArraySize(gFractions); i++)
		{
			ArrayGetString(gFractions, i, szFraction, charsmax(szFraction));
		
			menu_additem(menu, szFraction, szFraction);
		}
	
		menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
		menu_setprop(menu, MPROP_BACKNAME, "Wroc");
		menu_setprop(menu, MPROP_NEXTNAME, "Dalej");

		menu_display(id, menu);
	}
	else SelectClass(id);
}
 
public SelectFraction_Handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;

	client_cmd(id, "spk %s", szSounds[SOUND_SELECT]);
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}

	new szMenu[128], szTemp[3], szData[MAX_NAME], aClass[eClassInfo], iClass, iAccess, iCallback;

	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), _, _, iCallback);
	
	menu_destroy(menu);
	
	new menu = menu_create("\wWybierz \rKlase:", "SelectClass_Handle");
	
	iClass = gPlayer[id][PLAYER_CLASS];

	for(new i = 1; i < ArraySize(gClasses); i++)
	{
		ArrayGetArray(gClasses, i, aClass);
		
		if(equali(szData, aClass[CLASS_FRACTION]))
		{
			LoadClass(id, i);
			
			formatex(szMenu, charsmax(szMenu), "%s \yPoziom: %i \d(%s)", aClass[CLASS_NAME], gPlayer[id][PLAYER_LEVEL], GetWeapons(aClass[CLASS_WEAPONS]));
			
			num_to_str(i, szTemp, charsmax(szTemp));
			menu_additem(menu, szMenu, szTemp);
		}
	}
	
	if(iClass) LoadClass(id, iClass);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public SelectClass(id)
{
	new szMenu[128], szTemp[3], aClass[eClassInfo], iClass;
	
	new menu = menu_create("\wWybierz \rKlase:", "SelectClass_Handle");
	
	iClass = gPlayer[id][PLAYER_CLASS];

	for(new i = 1; i < ArraySize(gClasses); i++)
	{
		ArrayGetArray(gClasses, i, aClass);

		LoadClass(id, i);

		formatex(szMenu, charsmax(szMenu), "%s \yPoziom: %i \d(%s)", aClass[CLASS_NAME], gPlayer[id][PLAYER_LEVEL], GetWeapons(aClass[CLASS_WEAPONS]));

		num_to_str(i, szTemp, charsmax(szTemp));
		menu_additem(menu, szMenu, szTemp);
	}
	
	if(iClass) LoadClass(id, iClass);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public SelectClass_Handle(id, menu, item)
{
	client_cmd(id, "spk %s", szSounds[SOUND_SELECT]);
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}       
	
	new szData[64], iAccess, iCallback;
	
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), _, _, iCallback);
	
	item = str_to_num(szData);

	LoadClass(id, gPlayer[id][PLAYER_CLASS]);
	
	if(item == gPlayer[id][PLAYER_CLASS] && !gPlayer[id][PLAYER_NEW_CLASS]) return PLUGIN_CONTINUE;
	
	gPlayer[id][PLAYER_NEW_CLASS] = item;
	
	if(gPlayer[id][PLAYER_CLASS]) cod_print_chat(id, "Klasa zostanie zmieniona w nastepnej rundzie.");
	else
	{
		SetNewClass(id);
		SetAttributes(id);
	}
	
	return PLUGIN_CONTINUE;
}

public ClassDesc(id)
{
	new szClass[MAX_NAME];
	
	new menu = menu_create("\wWybierz \rKlase:", "ClassDesc_Handle");

	for(new i = 1; i < ArraySize(gClasses); i++)
	{
		GetClassInfo(i, CLASS_NAME, szClass, charsmax(szClass));
		
		menu_additem(menu, szClass);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz", 0);
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	
	menu_display(id, menu);
}

public ClassDesc_Handle(id, menu, item)
{
	client_cmd(id, "spk %s", szSounds[SOUND_SELECT2]);
	
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}
	
	new szTemp[512], aClass[eClassInfo];
	
	ArrayGetArray(gClasses, item, aClass);
	
	format(szTemp, charsmax(szTemp), "\yKlasa: \w%s^n\yFrakcja: \w%i^n\yZycie: \w%i^n\yBronie:\w%s^n\yOpis: \w%s^n%s", aClass[CLASS_NAME], aClass[CLASS_HEALTH], GetWeapons(aClass[CLASS_WEAPONS]), aClass[CLASS_DESC], aClass[CLASS_DESC][79]);
	show_menu(id, 0, szTemp);
	
	return PLUGIN_CONTINUE;
}

public ItemDesc(id)
	ShowItemDesc(id, gPlayer[id][PLAYER_ITEM]);
	
ItemsDesc(id, page = 0)
{
	new menu = menu_create("\wWybierz \rItem:", "ItemsDesc_Handle");
	
	new szItem[MAX_NAME];
	
	for(new i = 1; i < ArraySize(gItems); i++)
	{
		GetItemInfo(i, ITEM_NAME, szItem, charsmax(szItem));
		
		menu_additem(menu, szItem);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz", 0);
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	
	menu_display(id, menu, page);
}

public ItemsDesc_Handle(id, menu, item)
{
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}
	
	client_cmd(id, "spk %s", szSounds[SOUND_SELECT2]);
	
	ShowItemDesc(id, item);
	ItemsDesc(id, (item - 1) / 7);
	
	return PLUGIN_CONTINUE;
}
	
public ShowItemDesc(id, item)
{
	new szDesc[MAX_DESC], szItem[MAX_NAME];

	GetItemInfo(item, MAX_DESC, szDesc, charsmax(szDesc));
	GetItemInfo(item, ITEM_NAME, szItem, charsmax(szItem));

	cod_print_chat(id, "Item:^x03 %s^x01.", szItem);
	cod_print_chat(id, "Opis:^x03 %s^x01.", szDesc);
}

public DropItem(id)
{
	if(gPlayer[id][PLAYER_ITEM])
	{
		new szItem[MAX_NAME];
		
		GetItemInfo(gPlayer[id][PLAYER_ITEM], ITEM_NAME, szItem, charsmax(szItem));
		
		cod_print_chat(id, "Wyrzuciles^x03 %s^x01.", szItem);
		
		SetItem(id);
	}
	else cod_print_chat(id, "Nie masz zadnego^x03 itemu^x01.");
}

public ResetStats(id)
{	
	if(!is_user_alive(id))
	{
		ResetPoints(id);
		
		return PLUGIN_CONTINUE;
	}
	
	Set(id, iReset);
	cod_print_chat(id, "Twoje umiejetnosci zostana zresetowane w kolejnej rudzie.");
	
	return PLUGIN_CONTINUE;
}

public ResetPoints(id)
{
	if(!is_user_connected(id)) return;

	client_cmd(id, "spk %s", szSounds[SOUND_SELECT]);
	
	Rem(id, iReset);
	
	gPlayer[id][PLAYER_POINTS] = (gPlayer[id][PLAYER_LEVEL] - 1)*2;
	gPlayer[id][PLAYER_INT] = 0;
	gPlayer[id][PLAYER_HEAL] = 0;
	gPlayer[id][PLAYER_COND] = 0;
	gPlayer[id][PLAYER_STAM] = 0;
	
	if(gPlayer[id][PLAYER_POINTS]) AssignPoints(id);
}

public AssignPoints(id)
	AssignPointsPage(id, 0);

public AssignPointsPage(id, page)
{
	new szMenu[128];
	
	format(szMenu, charsmax(szMenu), "\wPrzydziel \rPunkty \y(%i):", gPlayer[id][PLAYER_POINTS]);
	
	new menu = menu_create(szMenu, "AssignPoints_Handler");
	
	if(gPlayer[id][PLAYER_POINTS_SPEED] == -1) format(szMenu, charsmax(szMenu), "Ile dodawac: \rWszystko \y(Ile punktow dodac do statow)");
	else format(szMenu, charsmax(szMenu), "Ile dodawac: \r%d \y(Ile punktow dodac do statow)", iPoints[gPlayer[id][PLAYER_POINTS_SPEED]]);

	menu_additem(menu, szMenu);
	
	menu_addblank(menu, 0);
	
	format(szMenu, charsmax(szMenu), "Inteligencja: \r%i \y(Zwieksza sile itemow i umiejetnosci klasy)", GetIntelligence(id, 1, 1));
	menu_additem(menu, szMenu);
	
	format(szMenu, charsmax(szMenu), "Zdrowie: \r%i \y(Zwieksza ilosc zycia)", GetHealth(id, 0, 1, 1));
	menu_additem(menu, szMenu);
	
	format(szMenu, charsmax(szMenu), "Wytrzymalosc: \r%i \y(Zmniejsza otrzymywane obrazenia)", GetStamina(id, 1, 1));
	menu_additem(menu, szMenu);
	
	format(szMenu, charsmax(szMenu), "Sila: \r%i \y(Zwieksza zadawane obrazenia)", GetStrength(id, 1, 1));
	menu_additem(menu, szMenu);
	
	format(szMenu, charsmax(szMenu), "Kondycja: \r%i \y(Zwieksza predkosc poruszania)", GetCondition(id, 1, 1));
	menu_additem(menu, szMenu);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz", 0);
	
	menu_display(id, menu);
}

public AssignPoints_Handler(id, menu, item) 
{
	client_cmd(id, "spk %s", szSounds[SOUND_SELECT]);

	if(item == MENU_EXIT) 
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}
	
	if(gPlayer[id][PLAYER_POINTS] < 1) return PLUGIN_CONTINUE;

	new iPointsAmount = (iPoints[gPlayer[id][PLAYER_POINTS_SPEED]] > gPlayer[id][PLAYER_POINTS]) ? gPlayer[id][PLAYER_POINTS] : gPlayer[id][PLAYER_POINTS_SPEED];
	
	switch(item) 
	{ 
		case 0: if(++gPlayer[id][PLAYER_POINTS_SPEED] >= charsmax(iPoints)) gPlayer[id][PLAYER_POINTS_SPEED] = 0;      
		case 1: 
		{       
			if(gPlayer[id][PLAYER_INT] < iLevelLimit/5) 
			{
				if(iPointsAmount > iLevelLimit/5 - gPlayer[id][PLAYER_INT]) iPointsAmount = iLevelLimit/5 - gPlayer[id][PLAYER_INT];

				gPlayer[id][PLAYER_INT] += iPointsAmount;
				gPlayer[id][PLAYER_POINTS] -= iPointsAmount;

			} 
			else cod_print_chat(id, "Maksymalny poziom inteligencji osiagniety!");                       
		}
		case 2: 
		{       
			if(gPlayer[id][PLAYER_HEAL] < iLevelLimit/5) 
			{
				if(iPointsAmount > iLevelLimit/5 - gPlayer[id][PLAYER_HEAL]) iPointsAmount = iLevelLimit/5 - gPlayer[id][PLAYER_HEAL];

				gPlayer[id][PLAYER_HEAL] += iPointsAmount;
				gPlayer[id][PLAYER_POINTS] -= iPointsAmount;
			}
			else cod_print_chat(id, "Maksymalny poziom sily osiagniety!");
		}
		case 3: 
		{       
			if(gPlayer[id][PLAYER_STAM] < iLevelLimit/5) 
			{
				if(iPointsAmount > iLevelLimit/5 - gPlayer[id][PLAYER_STAM]) iPointsAmount = iLevelLimit/5 - gPlayer[id][PLAYER_STAM];

				gPlayer[id][PLAYER_STAM] += iPointsAmount;
				gPlayer[id][PLAYER_POINTS] -= iPointsAmount;
			} 
			else cod_print_chat(id, "Maksymalny poziom wytrzymalosci osiagniety!");
		}
		case 4: 
		{       
			if(gPlayer[id][PLAYER_STR] < iLevelLimit/5) 
			{
				if(iPointsAmount > iLevelLimit/5 - gPlayer[id][PLAYER_STR]) iPointsAmount = iLevelLimit/5 - gPlayer[id][PLAYER_STR];

				gPlayer[id][PLAYER_STR] += iPointsAmount;
				gPlayer[id][PLAYER_POINTS] -= iPointsAmount;
			} 
			else cod_print_chat(id, "Maksymalny poziom sily osiagniety!");
		}
		case 5: 
		{       
			if(gPlayer[id][PLAYER_COND] < iLevelLimit/5) 
			{
				if(iPointsAmount > iLevelLimit/5 - gPlayer[id][PLAYER_COND]) iPointsAmount = iLevelLimit/5 - gPlayer[id][PLAYER_COND];

				gPlayer[id][PLAYER_COND] += iPointsAmount;
				gPlayer[id][PLAYER_POINTS] -= iPointsAmount;
			} 
			else cod_print_chat(id, "Maksymalny poziom kondycji osiagniety!");
		}
	}

	if(gPlayer[id][PLAYER_POINTS] > 0) AssignPointsPage(id, item/7);

	return PLUGIN_CONTINUE;
}

public ChangeHUD(id)
{
	new szMenu[128], menu = menu_create("\yCoD Mod: \rKonfiguracja HUD", "ChangeHUD_Handle");
	
	format(szMenu, charsmax(szMenu), "\wSposob \yWyswietlania: \r%s", gPlayer[id][PLAYER_HUD] > TYPE_HUD ? "DHUD" : "HUD");
	menu_additem(menu, szMenu);
	
	format(szMenu, charsmax(szMenu), "\wKolor \yCzerwony: \r%i", gPlayer[id][PLAYER_HUD_RED]);
	menu_additem(menu, szMenu);
	
	format(szMenu, charsmax(szMenu), "\wKolor \yZielony: \r%i", gPlayer[id][PLAYER_HUD_GREEN]);
	menu_additem(menu, szMenu);
	
	format(szMenu, charsmax(szMenu), "\wKolor \yNiebieski: \r%i", gPlayer[id][PLAYER_HUD_BLUE]);
	menu_additem(menu, szMenu);
	
	format(szMenu, charsmax(szMenu), "\wPolozenie \yOs X: \r%i%%", gPlayer[id][PLAYER_HUD_POSX]);
	menu_additem(menu, szMenu);
	
	format(szMenu, charsmax(szMenu), "\wPolozenie \yOs Y: \r%i%%^n", gPlayer[id][PLAYER_HUD_POSY]);
	menu_additem(menu, szMenu);
	
	format(szMenu, charsmax(szMenu), "\yDomyslne \rUstawienia");
	menu_additem(menu, szMenu);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz", 0);
	
	menu_display(id, menu);
}

public hud_menu_handle(id, menu, item) 
{
	if(item == MENU_EXIT) 
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0: if(++gPlayer[id][PLAYER_HUD] > TYPE_DHUD) gPlayer[id][PLAYER_HUD] = TYPE_HUD;
		case 1: if((gPlayer[id][PLAYER_HUD_RED] += 15) > 255) gPlayer[id][PLAYER_HUD_RED] = 0;
		case 2: if((gPlayer[id][PLAYER_HUD_GREEN] += 15) > 255) gPlayer[id][PLAYER_HUD_GREEN] = 0;
		case 3: if((gPlayer[id][PLAYER_HUD_BLUE] += 15) > 255) gPlayer[id][PLAYER_HUD_BLUE] = 0;
		case 4: if((gPlayer[id][PLAYER_HUD_POSX] += 3) > 100) gPlayer[id][PLAYER_HUD_POSX] = 0;
		case 5: if((gPlayer[id][PLAYER_HUD_POSY] += 3) > 100) gPlayer[id][PLAYER_HUD_POSY] = 0;
		case 6:
		{
			gPlayer[id][PLAYER_HUD] = TYPE_HUD;
			gPlayer[id][PLAYER_HUD_RED] = 0;
			gPlayer[id][PLAYER_HUD_GREEN] = 255;
			gPlayer[id][PLAYER_HUD_BLUE] = 0;
			gPlayer[id][PLAYER_HUD_POSX] = 66;
			gPlayer[id][PLAYER_HUD_POSY] = 6;
		}
	}
	
	ChangeHUD(id);
	
	//SaveHUD(id);
	
	return PLUGIN_CONTINUE;
}

public BlockCommand()
	return PLUGIN_HANDLED;
	
public UseRocket(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED;

	if(!gPlayer[id][PLAYER_ROCKETS])
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie rakiety!");
		
		return PLUGIN_HANDLED;
	}
	
	if(gPlayer[id][PLAYER_LAST_ROCKET] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Rakiet mozesz uzywac co 3 sekundy!");
		
		return PLUGIN_HANDLED;
	}
	
	gPlayer[id][PLAYER_LAST_ROCKET] = floatround(get_gametime());
	gPlayer[id][PLAYER_ROCKETS]--;

	new Float:fOrigin[3], Float:fAngle[3], Float:fVelocity[3];

	entity_get_vector(id, EV_VEC_v_angle, fAngle);
	entity_get_vector(id, EV_VEC_origin, fOrigin);

	new ent = create_entity("info_target");
	
	entity_set_string(ent, EV_SZ_classname, "rocket");
	entity_set_model(ent, szModels[MODEL_ROCKET]);

	fAngle[0] *= -1.0;

	entity_set_origin(ent, fOrigin);
	entity_set_vector(ent, EV_VEC_angles, fAngle);

	entity_set_int(ent, EV_INT_effects, 2);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_edict(ent, EV_ENT_owner, id);

	VelocityByAim(id, 1000, fVelocity);
	
	entity_set_vector(ent, EV_VEC_velocity, fVelocity);
	
	return PLUGIN_HANDLED;
}

public TouchRocket(ent)
{
	if(!is_valid_ent(ent)) return;

	new iEntList[33], id = entity_get_edict(ent, EV_ENT_owner);

	MakeExplosion(ent);

	new iFound = find_sphere_class(ent, "player", 190.0, iEntList, MAX_PLAYERS);

	for(new i = 0; i < iFound; i++)
	{
		new player = iEntList[i];

		if(!is_user_alive(player) || get_user_team(id) == get_user_team(player)) continue;

		_cod_inflict_damage(id, player, 65.0, 0.5, DMG_HEGRENADE);
	}
	
	remove_entity(ent);
}

public UseMine(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED;

	if(!gPlayer[id][PLAYER_MINES])
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie miny!");
		
		return PLUGIN_HANDLED;
	}
	
	if(gPlayer[id][PLAYER_LAST_MINE] + 3.0 > get_gametime())
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
	
	gPlayer[id][PLAYER_LAST_MINE] = floatround(get_gametime());
	gPlayer[id][PLAYER_MINES]--;

	new Float:fOrigin[3];
	
	entity_get_vector(id, EV_VEC_origin, fOrigin);

	new ent = create_entity("info_target");
	
	entity_set_string(ent, EV_SZ_classname, "mine");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, fOrigin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);

	entity_set_model(ent, szModels[MODEL_MINE]);
	entity_set_size(ent, Float:{ -16.0, -16.0, 0.0 }, Float:{ 16.0, 16.0, 2.0 });

	drop_to_floor(ent);

	set_rendering(ent, kRenderFxNone, 0, 0, 0, kRenderTransTexture, 50);

	return PLUGIN_HANDLED;
}

public TouchMine(ent, victim)
{
	if(!is_valid_ent(ent)) return;

	new iEntList[33], id = entity_get_edict(ent, EV_ENT_owner);
	
	if(get_user_team(victim) != get_user_team(id)) return;

	MakeExplosion(ent);
	
	new iFound = find_sphere_class(ent, "player", 90.0, iEntList, MAX_PLAYERS);

	for(new i = 0; i < iFound; i++)
	{
		new player = iEntList[i];

		if(!is_user_alive(player) || get_user_team(id) == get_user_team(player)) continue;

		_cod_inflict_damage(id, player, 75.0, 0.5, DMG_HEGRENADE);
	}
	
	remove_entity(ent);
}

public UseDynamite(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE;

	if(is_valid_ent(gPlayer[id][PLAYER_DYNAMITE]))
	{
		MakeExplosion(gPlayer[id][PLAYER_DYNAMITE], 250);
		
		new iEntList[33];
	
		new iFound = find_sphere_class(gPlayer[id][PLAYER_DYNAMITE], "player", 250.0, iEntList, MAX_PLAYERS);

		for(new i = 0; i < iFound; i++)
		{
			new player = iEntList[i];

			if(!is_user_alive(player) || get_user_team(id) == get_user_team(player)) continue;

			_cod_inflict_damage(id, player, 70.0, 0.5, DMG_HEGRENADE);
		}
		
		remove_entity(gPlayer[id][PLAYER_DYNAMITE]);
		
		gPlayer[id][PLAYER_DYNAMITE] = 0;
		
		return PLUGIN_HANDLED;
	}
	
	if(!gPlayer[id][PLAYER_DYNAMITES])
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie dynamity!");
		
		return PLUGIN_HANDLED;
	}
	
	if(gPlayer[id][PLAYER_LAST_DYNAMITE] + 3.0 > get_gametime())
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
	
	gPlayer[id][PLAYER_LAST_DYNAMITE] = floatround(get_gametime());
	gPlayer[id][PLAYER_DYNAMITES]--;

	new Float:fOrigin[3];
	
	entity_get_vector(id, EV_VEC_origin, fOrigin);

	new ent = create_entity("info_target");
	
	gPlayer[id][PLAYER_DYNAMITE] = ent;
	
	entity_set_string(ent, EV_SZ_classname, "dynamite");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, fOrigin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	entity_set_model(ent, szModels[MODEL_DYNAMITE]);
	entity_set_size(ent, Float:{ -16.0, -16.0, 0.0 }, Float:{ 16.0, 16.0, 2.0 });
	
	drop_to_floor(ent);
	
	return PLUGIN_HANDLED;
}

public UseMedkit(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED;

	if(!gPlayer[id][PLAYER_MEDKITS])
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie apteczki!");
		
		return PLUGIN_HANDLED;
	}
	
	if(gPlayer[id][PLAYER_LAST_MEDKIT] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Apteczki mozesz klasc co 3 sekundy!");
		
		return PLUGIN_HANDLED;
	}
	
	gPlayer[id][PLAYER_LAST_MEDKIT] = floatround(get_gametime());
	gPlayer[id][PLAYER_MEDKITS]--;

	new Float:fOrigin[3];
	
	entity_get_vector(id, EV_VEC_origin, fOrigin);

	new ent = create_entity("info_target");
	
	entity_set_string(ent, EV_SZ_classname, "medkit");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, fOrigin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + 7 + 0.1);

	entity_set_model(ent, szModels[MODEL_MEDKIT]);
	set_rendering(ent, kRenderFxGlowShell, 255,0,0, kRenderFxNone, 255);
	drop_to_floor(ent);

	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);

	return PLUGIN_HANDLED;
}

public ThinkMedkit(ent)
{
	if(!is_valid_ent(ent)) return PLUGIN_CONTINUE;

	new id = entity_get_edict(ent, EV_ENT_owner);
	new iHeal = 5 + floatround(gPlayer[id][PLAYER_INT] * 0.5);
	new iDistance = 300;

	if(entity_get_edict(ent, EV_ENT_euser2) == 1)
	{
		new Float:fOrigin[3], iEntList[33];
		
		entity_get_vector(ent, EV_VEC_origin, fOrigin);

		new iFound = find_sphere_class(0, "player", float(iDistance), iEntList, MAX_PLAYERS, fOrigin);

		for (new i = 0; i < iFound; i++)
		{
			new player = iEntList[i];

			if (get_user_team(player) != get_user_team(player)) continue;

			new iHealth = (get_user_health(player) + iHeal < GetHealth(player, 1, 1, 1)) ? iHeal : get_user_health(player);
			
			if(is_user_alive(player)) entity_set_float(player, EV_FL_health, float(iHealth));
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

	MakeExplosion(ent, iDistance, 0);

	entity_set_edict(ent, EV_ENT_euser2, 1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);

	return PLUGIN_CONTINUE;
}

public UseItem(id)
{
	if(!is_user_alive(id) || !gPlayer[id][PLAYER_ITEM]) return PLUGIN_HANDLED;
	
	ExecuteForwardIgnoreIntOneParam(GetItemInfo(gPlayer[id][PLAYER_ITEM], ITEM_SKILL_USED), id);
	
	return PLUGIN_HANDLED;
}

public UseSkill(id)
{
	if(!is_user_alive(id) || !gPlayer[id][PLAYER_CLASS]) return PLUGIN_HANDLED;
	
	ExecuteForwardIgnoreIntOneParam(GetClassInfo(gPlayer[id][PLAYER_CLASS], CLASS_SKILL_USED), id);

	return PLUGIN_HANDLED;
}

public PlayerSpawn(id)
{	
	if(gPlayer[id][PLAYER_NEW_CLASS]) SetNewClass(id);
	
	if(!gPlayer[id][PLAYER_CLASS])
	{
		SelectFraction(id);
		
		return PLUGIN_CONTINUE;
	}
	
	if(Get(id, iReset)) ResetPoints(id);
	
	SetAttributes(id);
	
	if(gPlayer[id][PLAYER_POINTS] > 0) AssignPoints(id);
	
	if(gPlayer[id][PLAYER_CLASS]) ExecuteForwardIgnoreIntOneParam(GetClassInfo(gPlayer[id][PLAYER_CLASS], CLASS_SPAWNED), id);
	
	if(gPlayer[id][PLAYER_ITEM]) ExecuteForwardIgnoreIntOneParam(GetItemInfo(gPlayer[id][PLAYER_ITEM], ITEM_SPAWNED), id);
	
	ExecuteForwardIgnoreIntOneParam(gForwards[FORWARD_SPAWNED], id);

	return PLUGIN_CONTINUE;
}

public TakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamagebits)
{
	if(!is_user_connected(iAttacker) || !is_user_connected(iVictim) || !is_user_alive(iAttacker) || get_user_team(iVictim) == get_user_team(iAttacker)) return HAM_IGNORED;

	SetHamParamFloat(4, fDamage*(1.0 - Float:gPlayer[iVictim][PLAYER_DMG_REDUCE]));

	return HAM_IGNORED;
}

public TakeDamagePost(iVictim, iInflictor, iAttacker, Float:fDamage, iDamagebits)
{
	if(!is_user_connected(iAttacker) || !is_user_connected(iVictim) || !gPlayer[iAttacker][PLAYER_CLASS] || get_user_team(iVictim) == get_user_team(iAttacker)) return HAM_IGNORED;
	
	while(fDamage > 20)
	{
		fDamage -= 20;

		gPlayer[iAttacker][PLAYER_GAINED_EXP] += GetExpBonus(iAttacker, iDamageExp);
	}
	
	CheckLevel(iAttacker);
	
	return HAM_IGNORED;
}

public client_death(iKiller, iVictim, iWpnIndex, iHitPlace, iTeamKill)
{	
	if(!is_user_connected(iKiller) || !is_user_connected(iVictim) || !is_user_alive(iKiller) || get_user_team(iVictim) == get_user_team(iKiller)) return PLUGIN_CONTINUE;
	
	if(gPlayer[iKiller][PLAYER_CLASS])
	{
		new iExp = GetExpBonus(iKiller, iKillExp);
		
		if(gPlayer[iVictim][PLAYER_LEVEL] > gPlayer[iKiller][PLAYER_LEVEL]) iExp += GetExpBonus(iKiller, (gPlayer[iVictim][PLAYER_LEVEL] - gPlayer[iKiller][PLAYER_LEVEL]) * (iKillExp/10));

		gPlayer[iKiller][PLAYER_GAINED_EXP] += iExp;
		
		set_dhudmessage(255, 212, 0, 0.50, 0.31, 0, 0.0, 1.0, 0.0, 0.0)
		show_dhudmessage(iKiller, "+%i XP", iExp);
		
		if(iHitPlace == HIT_HEAD)
		{
			iExp = GetExpBonus(iKiller, iKillHSExp);

			gPlayer[iKiller][PLAYER_GAINED_EXP] += iExp;
	
			set_dhudmessage(38, 218, 116, 0.50, 0.36, 0, 0.0, 1.0, 0.0, 0.0);
			show_dhudmessage(iKiller, "HeadShot! +%i XP", iExp);
		}
		
		if(!gPlayer[iKiller][PLAYER_ITEM]) SetItem(iKiller, -1, -1);
		
		gPlayer[iKiller][PLAYER_KS]++;
		gPlayer[iKiller][PLAYER_TIME_KS] = iKillStreakTime;
		
		if(task_exists(iKiller + TASK_END_KILL_STREAK)) remove_task(iKiller + TASK_END_KILL_STREAK);

		set_task(1.0, "EndKillStreak", iKiller + TASK_END_KILL_STREAK, _, _, "b");
	}
	
	CheckLevel(iKiller);
	
	if(gPlayer[iVictim][PLAYER_CLASS]) ExecuteForwardIgnoreIntOneParam(GetClassInfo(gPlayer[iVictim][PLAYER_CLASS], CLASS_KILLED), iVictim);
	
	if(!gPlayer[iVictim][PLAYER_ITEM]) return PLUGIN_CONTINUE;
	
	ExecuteForwardIgnoreIntOneParam(GetItemInfo(gPlayer[iVictim][PLAYER_ITEM], ITEM_KILLED), iVictim);
	
	gPlayer[iVictim][PLAYER_ITEM_DURA] -= random_num(iMinDamageDurability, iMaxDamageDurability);
	
	if(!gPlayer[iVictim][PLAYER_ITEM_DURA])
	{
		SetItem(iVictim);
		
		cod_print_chat(iVictim, "Twoj item ulegl zniszczeniu.");
	}
	else cod_print_chat(iVictim, "Pozostala wytrzymalosc twojego itemu to^x03 %i^x01/^x03%i^x01.", gPlayer[iVictim][PLAYER_ITEM_DURA], iMaxDurability);
	
	return HAM_IGNORED;
}

public TouchWeapon(weapon, id)
{
	if(!is_user_connected(id)) return HAM_IGNORED;

	new szModel[23];
	
	pev(weapon, pev_model, szModel, charsmax(szModel));
	
	if(containi(szModel, "w_backpack") != -1) return HAM_IGNORED;

	new iTeam = get_user_team(id);
	
	if(iTeam > 2) return HAM_IGNORED;

	pev(weapon, pev_classname, szModel, 2);
	
	new iWeapon = ((szModel[0] == 'a') ? cs_get_armoury_type(weapon): cs_get_weaponbox_type(weapon));

	if((1 << iWeapon) & (GetClassInfo(gPlayer[id][PLAYER_CLASS], CLASS_WEAPONS) | gPlayer[id][PLAYER_EXTR_WPNS] | iTeamWeapons[iTeam] | iAllowedWeapons)) return HAM_IGNORED;

	return HAM_SUPERCEDE;
}
	
public PlayerResetMaxSpeed(id)
{
	if(!is_user_alive(id) || !bFreezeTime || !gPlayer[id][PLAYER_CLASS]) return;

	new Float:fSpeed = get_user_maxspeed(id) + gPlayer[id][PLAYER_SPEED];
	
	set_pev(id, pev_maxspeed, fSpeed);
	set_user_maxspeed(id, fSpeed);
}

public NewRound()
{
	RemoveEnts();
	
	SetCvars();
	
	bFreezeTime = true;
	
	ExecuteForwardIgnoreIntNoParam(gForwards[FORWARD_NEW_ROUND]);
}

public RoundStart()	
{
	bFreezeTime = false;
	
	for(new id = 0; id <= 32; id++)
	{
		if(!is_user_alive(id)) continue;

		DisplayFade(id, 1<<9, 1<<9, 1<<12, 0, 255, 70, 100);
		
		switch(get_user_team(id))
		{
			case 1: client_cmd(id, "spk %s", szSounds[SOUND_START2]);
			case 2: client_cmd(id, "spk %s", szSounds[SOUND_START]);
		}
		
		gPlayer[id][PLAYER_TIME_KS] = 0;
		gPlayer[id][PLAYER_KS] = 0;
		
		if(task_exists(id + TASK_END_KILL_STREAK)) remove_task(id + TASK_END_KILL_STREAK)

		if(cs_get_user_team(id) == CS_TEAM_CT) cs_set_user_defuse(id, 1);
	}
	
	ExecuteForwardIgnoreIntNoParam(gForwards[FORWARD_START_ROUND]);
}

public RoundEnd()
	ExecuteForwardIgnoreIntNoParam(gForwards[FORWARD_END_ROUND]);

public MessageHealth(id) 
{ 
	if(read_data(1) > 255)
	{
		message_begin(MSG_ONE, get_user_msgid("Health"), {0, 0, 0}, id);
		write_byte(255);
		message_end(); 
	} 
}
	
public TTWin()
	RoundWinner("TERRORIST");
	
public CTWin()
	RoundWinner("CT");

public RoundWinner(const szTeam[])
{
	new szPlayers[32], iPlayers, id;
	
	get_players(szPlayers, iPlayers, "aeh", szTeam);
	
	if(get_playersnum() < iMinPlayers) return;

	for (new i = 0; i < iPlayers; i++) 
	{
		id = szPlayers[i];
		
		if(!gPlayer[id][PLAYER_CLASS]) continue;

		new iExp = GetExpBonus(id, iWinExp);
		
		gPlayer[id][PLAYER_GAINED_EXP] += iExp;
		
		cod_print_chat(id, "Dostales^x03 %i^x01 doswiadczenia za wygrana runde.", iExp);
		
		CheckLevel(id);
	}
}

public bomb_planted(planter)
{
	if(get_playersnum() < iMinPlayers) return;

	new iExp = GetExpBonus(planter, iPlantExp);
	
	gPlayer[planter][PLAYER_GAINED_EXP] += iExp;
	
	cod_print_chat(planter, "Dostales^x03 %i^x01 doswiadczenia za podlozenie bomby.", iExp);
	
	CheckLevel(planter);
}

public bomb_defused(defuser)
{
	if(get_playersnum() < iMinPlayers) return;
	
	new iExp = GetExpBonus(defuser, iDefuseExp);
	
	gPlayer[defuser][PLAYER_GAINED_EXP] += iExp;
	
	cod_print_chat(defuser, "Dostales^x03 %i^x01 doswiadczenia za rozbrojenie bomby.", iExp);
	
	CheckLevel(defuser);
}

public HostagesRescue()
{
	if(get_playersnum() < iMinPlayers) return;

	new rescuer = get_loguser_index();
	
	new iExp = GetExpBonus(rescuer, iRescueExp);
	
	gPlayer[rescuer][PLAYER_GAINED_EXP] += iExp;
	
	cod_print_chat(rescuer, "Dostales^x03 %i^x01 doswiadczenia za uratowanie zakladnikow.", iExp);
	
	CheckLevel(rescuer);
}

public CmdStart(id, uc_handle)
{		
	if(!is_user_alive(id)) return FMRES_IGNORED;
	
	ExecuteForwardIgnoreIntOneParam(gForwards[FORWARD_CMD_START], id);

	new Float:fVelocity[3], Float:fSpeed;
	
	pev(id, pev_velocity, fVelocity);
	
	fSpeed = vector_length(fVelocity);

	if(Float:gPlayer[id][PLAYER_SPEED] > fSpeed * 1.8) set_pev(id, pev_flTimeStepSound, 300);

	if(!gPlayer[id][PLAYER_JUMPS]) return FMRES_IGNORED;

	new iFlags = pev(id, pev_flags);

	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(iFlags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && gPlayer[id][PLAYER_LEFT_JUMPS])
	{
		gPlayer[id][PLAYER_LEFT_JUMPS]--;
		
		pev(id, pev_velocity, fVelocity);
		
		fVelocity[2] = random_float(265.0, 285.0);
		
		set_pev(id, pev_velocity, fVelocity);
	}
	else if(iFlags & FL_ONGROUND) gPlayer[id][PLAYER_LEFT_JUMPS] = gPlayer[id][PLAYER_JUMPS];

	return FMRES_IGNORED;
}

public client_PreThink(id)
{
	if(!is_user_alive(id) || !Get(id, iBunnyHop)) return PLUGIN_CONTINUE;

	entity_set_float(id, EV_FL_fuser2, 0.0);

	if(entity_get_int(id, EV_INT_button) & 2) 
	{
		new flags = entity_get_int(id , EV_INT_flags);

		if (flags & FL_WATERJUMP || entity_get_int(id, EV_INT_waterlevel) >= 2 || !(flags & FL_ONGROUND)) return PLUGIN_CONTINUE;

		new Float:fVelocity[3];
		
		entity_get_vector(id, EV_VEC_velocity, fVelocity);
		
		fVelocity[2] += 250.0;
		
		entity_set_vector(id, EV_VEC_velocity, fVelocity);

		entity_set_int(id, EV_INT_gaitsequence, 6);
	}
	
	return PLUGIN_CONTINUE;
}

public MsgIntermission()
	set_task(0.25, "SavePlayers");

public SavePlayers()
{
	new szPlayers[32], id, iNum;
	
	get_players(szPlayers, iNum, "h");
	
	if(!iNum) return PLUGIN_CONTINUE;

	for (new i = 0; i < iNum; i++)
	{
		id = szPlayers[i];
		
		if(!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id)) continue;

		SaveData(id, MAP_END);
	}
	
	return PLUGIN_CONTINUE;
}

public ShowInfo(id) 
{
	id -= TASK_SHOW_INFO;
	
	if(!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id))
	{
		remove_task(id + TASK_SHOW_INFO);
		
		return PLUGIN_CONTINUE;
	}
	
	static szInfo[512], szClass[MAX_NAME], szItem[MAX_NAME], Float:fPercent, iExp, target;
	
	target = id;
	
	if(!is_user_alive(id))
	{
		new target = pev(id, pev_iuser2);
		
		if (!gPlayer[target][PLAYER_HUD]) set_hudmessage(255, 255, 255, 0.6, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 4);
		else set_dhudmessage(255, 255, 255, 0.6, -1.0, 0, 0.0, 0.3, 0.0, 0.0);
	}
	else
	{
		if (!gPlayer[target][PLAYER_HUD]) set_hudmessage(gPlayer[target][PLAYER_HUD_RED], gPlayer[target][PLAYER_HUD_GREEN], gPlayer[target][PLAYER_HUD_BLUE], float(gPlayer[target][PLAYER_HUD_POSX]) / 100.0, float(gPlayer[target][PLAYER_HUD_POSY]) / 100.0, 0, 0.0, 0.3, 0.0, 0.0, 4);
		else set_dhudmessage(gPlayer[target][PLAYER_HUD_RED], gPlayer[target][PLAYER_HUD_GREEN], gPlayer[target][PLAYER_HUD_BLUE], float(gPlayer[target][PLAYER_HUD_POSX]) / 100.0, float(gPlayer[target][PLAYER_HUD_POSY]) / 100.0, 0, 0.0, 0.3, 0.0, 0.0);
	}
	
	if(!target) return PLUGIN_CONTINUE;
	
	GetClassInfo(gPlayer[target][PLAYER_CLASS], CLASS_NAME, szClass, charsmax(szClass));
	GetItemInfo(gPlayer[target][PLAYER_ITEM], ITEM_NAME, szItem, charsmax(szItem));

	iExp = gPlayer[target][PLAYER_LEVEL] - 1 >= 0 ? GetLevelExp(gPlayer[target][PLAYER_LEVEL] - 1) : 0;
	fPercent = (float((gPlayer[target][PLAYER_EXP] - iExp)) / float((GetLevelExp(gPlayer[target][PLAYER_LEVEL]) - iExp))) * 100.0;
	
	formatex(szInfo, charsmax(szInfo), "[Klasa : %s]^n[Doswiadczenie : %0.1f%%]^n[Poziom : %i]^n[Item: %s (%i/%i)]^n[Honor: %i]", szClass, fPercent, gPlayer[target][PLAYER_LEVEL], szItem, gPlayer[target][PLAYER_ITEM_DURA], iMaxDurability, cod_get_user_honor(target));
	
	if(GetExpBonus(target, 1) > 1) format(szInfo, charsmax(szInfo), "%s^n[Exp: %i%%]", szInfo, GetExpBonus(target, 1) * 100);

	if(gPlayer[target][PLAYER_KS]) format(szInfo, charsmax(szInfo), "%s^n[KillStreak: %i (%i s)]", szInfo, gPlayer[target][PLAYER_KS], gPlayer[target][PLAYER_TIME_KS]);

	switch(gPlayer[target][PLAYER_HUD])
	{
		case TYPE_HUD: ShowSyncHudMsg(id, sHudSync, szInfo);
		case TYPE_DHUD: show_dhudmessage(id, szInfo);
	}
	
	return PLUGIN_CONTINUE;
} 

public ShowAdvertisement(id)
{
	id -= TASK_SHOW_AD;
	
	cod_print_chat(id, "Witaj na serwerze Call of Duty Mod stworzonym przez^x03 O'Zone^x01.");
	cod_print_chat(id, "W celu uzyskania informacji o komendach wpisz^x03 /menu^x01 (klawisz^x03 ^"v^"^x01).");
}

public SetNewClass(id)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
	
	new iRet;
	
	ExecuteForward(GetClassInfo(gPlayer[id][PLAYER_NEW_CLASS], CLASS_ENABLED), iRet, id);
	
	if(iRet == COD_STOP)	
	{
		gPlayer[id][PLAYER_NEW_CLASS] = 0;
		
		SelectFraction(id);
		
		return PLUGIN_CONTINUE;
	}
	
	if(gPlayer[id][PLAYER_CLASS]) 
	{
		SaveData(id, NORMAL);
		
		ExecuteForwardIgnoreIntOneParam(GetClassInfo(gPlayer[id][PLAYER_CLASS], CLASS_DISABLED), id);
	}
	
	ExecuteForwardIgnoreIntTwoParam(gForwards[FORWARD_CLASS_CHANGED], id, gPlayer[id][PLAYER_NEW_CLASS]);
	
	gPlayer[id][PLAYER_CLASS] = gPlayer[id][PLAYER_NEW_CLASS];
	gPlayer[id][PLAYER_NEW_CLASS] = 0;
	
	LoadClass(id, gPlayer[id][PLAYER_CLASS]);
	
	return PLUGIN_CONTINUE;
}

SetItem(id, item = 0, value = 0)
{
	if(!ArraySize(gItems) || !is_user_connected(id)) return PLUGIN_CONTINUE;
	
	item = (item == -1) ? random_num(1, ArraySize(gItems) - 1): item;
	
	new iRet;
	
	ExecuteForward(GetItemInfo(item, ITEM_GIVE), iRet, id, item, value);
	
	if(iRet == COD_STOP)
	{
		SetItem(id, -1, -1);
		
		return PLUGIN_CONTINUE;
	}
	
	if(gPlayer[id][PLAYER_ITEM]) ExecuteForwardIgnoreIntTwoParam(GetItemInfo(gPlayer[id][PLAYER_ITEM], ITEM_DROP), id, gPlayer[id][PLAYER_ITEM]);	
	
	gPlayer[id][PLAYER_ITEM] = item;

	ExecuteForwardIgnoreIntTwoParam(gForwards[FORWARD_ITEM_CHANGED], id, gPlayer[id][PLAYER_ITEM]);	

	new szItem[MAX_NAME];

	GetItemInfo(gPlayer[id][PLAYER_ITEM], ITEM_NAME, szItem, charsmax(szItem));
	
	cod_print_chat(id, "Zdobyles^x03 %s^x01.", szItem);

	return PLUGIN_CONTINUE;
}

public CheckLevel(id)
{	
	if(!is_user_connected(id) || !gPlayer[id][PLAYER_CLASS]) return;
	
	new iLevel = 0;
	
	while((gPlayer[id][PLAYER_GAINED_EXP] + gPlayer[id][PLAYER_EXP]) >= GetLevelExp(gPlayer[id][PLAYER_LEVEL]) && gPlayer[id][PLAYER_LEVEL] < iLevelLimit)
	{
		gPlayer[id][PLAYER_LEVEL]++;
		iLevel++;
	}
	
	if(!iLevel)
	{
		while((gPlayer[id][PLAYER_GAINED_EXP] + gPlayer[id][PLAYER_EXP]) < GetLevelExp(gPlayer[id][PLAYER_LEVEL] - 1))
		{
			gPlayer[id][PLAYER_LEVEL]--;
			iLevel--;
		}
	}

	if(iLevel)
	{
		gPlayer[id][PLAYER_POINTS] = (gPlayer[id][PLAYER_LEVEL] - 1) * 2 - gPlayer[id][PLAYER_INT] - gPlayer[id][PLAYER_HEAL] - gPlayer[id][PLAYER_STAM] - gPlayer[id][PLAYER_STR] - gPlayer[id][PLAYER_COND];
		
		set_dhudmessage(212, 255, 85, 0.31, 0.32, 0, 0.0, 1.5, 0.0, 0.0);
		show_dhudmessage(id, "Awansowales do %i poziomu!", gPlayer[id][PLAYER_LEVEL]);

		switch(random_num(1, 3))
		{
			case 1: client_cmd(id, "spk %s", szSounds[SOUND_LVLUP]);
			case 2: client_cmd(id, "spk %s", szSounds[SOUND_LVLUP2]);
			case 3: client_cmd(id, "spk %s", szSounds[SOUND_LVLUP3]);
		}
	}
	
	if(iLevel < 0)
	{
		ResetPoints(id);
		
		set_dhudmessage(212, 255, 85, 0.31, 0.32, 0, 0.0, 1.5, 0.0, 0.0);
		show_dhudmessage(id, "Spadles do %i poziomu!", gPlayer[id][PLAYER_LEVEL]);
	}
	
	gPlayer[id][PLAYER_GAINED_LEVEL] += iLevel;
	
	SaveData(id, NORMAL);
}

public SetAttributes(id)
{
	gPlayer[id][PLAYER_DMG_REDUCE] = _:(0.7 * (1.0 - floatpower(1.1, -0.112311341 * GetStamina(id, 1, 1))));
	
	gPlayer[id][PLAYER_MAX_HP] = _:(GetHealth(id, 1, 1, 1));
	
	gPlayer[id][PLAYER_SPEED] = _:(GetCondition(id, 1, 1) * 2);
	
	set_pev(id, pev_health, Float:gPlayer[id][PLAYER_MAX_HP]);
	
	entity_set_float(id, EV_FL_gravity, float(gPlayer[id][PLAYER_GRAVITY]));
	
	new szWeapons[32], szWeaponName[22], iWeapons, iWeapon = GetClassInfo(gPlayer[id][PLAYER_CLASS], CLASS_WEAPONS);
	
	for(new i = 1; i < 32; i++)
	{
		if((1<<i) & (iWeapon | gPlayer[id][PLAYER_EXTR_WPNS]))
		{
			get_weaponname(i, szWeaponName, charsmax(szWeaponName));
			give_item(id, szWeaponName);
		}
	}
	
	get_user_weapons(id, szWeapons, iWeapons);
	
	for(new i = 0; i < iWeapons; i++) if(is_user_alive(id) && iMaxAmmo[szWeapons[i]] > 0) cs_set_user_bpammo(id, szWeapons[i], iMaxAmmo[szWeapons[i]]);
}

public ResetPlayer(id)
{
	Rem(id, iLoaded);
	Rem(id, iResistance);
	
	RemoveTasks(id);
	
	gPlayer[id][PLAYER_CLASS] = 0;
	gPlayer[id][PLAYER_NEW_CLASS] = 0;
	gPlayer[id][PLAYER_LEVEL] = 0;
	gPlayer[id][PLAYER_GAINED_LEVEL] = 0;
	gPlayer[id][PLAYER_EXP] = 0;
	gPlayer[id][PLAYER_GAINED_EXP] = 0;
	gPlayer[id][PLAYER_HEAL] = 0;
	gPlayer[id][PLAYER_INT] = 0;
	gPlayer[id][PLAYER_STAM] = 0;
	gPlayer[id][PLAYER_STR] = 0;
	gPlayer[id][PLAYER_COND] = 0;
	gPlayer[id][PLAYER_POINTS] = 0;
	gPlayer[id][PLAYER_EXTR_HEAL] = 0;
	gPlayer[id][PLAYER_EXTR_INT] = 0;
	gPlayer[id][PLAYER_EXTR_STAM] = 0;
	gPlayer[id][PLAYER_EXTR_STR] = 0;
	gPlayer[id][PLAYER_EXTR_COND] = 0;
	gPlayer[id][PLAYER_EXTR_WPNS] = 0;
	gPlayer[id][PLAYER_ITEM] = 0;
	gPlayer[id][PLAYER_ITEM_DURA] = 0;
	gPlayer[id][PLAYER_MAX_HP] = _:0.0;
	gPlayer[id][PLAYER_SPEED] = _:0.0;
	gPlayer[id][PLAYER_GRAVITY] = _:0;
	gPlayer[id][PLAYER_DMG_REDUCE] = _:0.0;
	gPlayer[id][PLAYER_ROCKETS] = 0;
	gPlayer[id][PLAYER_LAST_ROCKET] = _:0.0;
	gPlayer[id][PLAYER_MINES] = 0;
	gPlayer[id][PLAYER_LAST_MINE] = _:0.0;
	gPlayer[id][PLAYER_DYNAMITE] = 0;
	gPlayer[id][PLAYER_DYNAMITES] = 0;
	gPlayer[id][PLAYER_LAST_DYNAMITE] = _:0.0;
	gPlayer[id][PLAYER_JUMPS] = 0;
	gPlayer[id][PLAYER_LEFT_JUMPS] = 0;
	gPlayer[id][PLAYER_KS] = 0;
	gPlayer[id][PLAYER_TIME_KS] = 0;
	gPlayer[id][PLAYER_HUD] = 0;
	gPlayer[id][PLAYER_HUD_RED] = 0;
	gPlayer[id][PLAYER_HUD_BLUE] = 0;
	gPlayer[id][PLAYER_HUD_GREEN] = 0;
	gPlayer[id][PLAYER_HUD_POSX] = 0;
	gPlayer[id][PLAYER_HUD_POSY] = 0;
	
	SetNewClass(id);
	SetItem(id);
}

public EndKillStreak(id)
{
	id -= TASK_END_KILL_STREAK;
	
	if(!is_user_connected(id))
	{
		remove_task(id + TASK_END_KILL_STREAK);
		
		return PLUGIN_CONTINUE;
	}

	if(--gPlayer[id][PLAYER_TIME_KS] == 0)
	{
		gPlayer[id][PLAYER_TIME_KS] = 0;
		gPlayer[id][PLAYER_KS] = 0;
		
		remove_task(id + TASK_END_KILL_STREAK);
	}
	
	return PLUGIN_CONTINUE;
}

public RemoveTasks(id)
{
	remove_task(id + TASK_SHOW_INFO);
	remove_task(id + TASK_SHOW_AD);	
	remove_task(id + TASK_SET_SPEED);
	remove_task(id + TASK_END_KILL_STREAK);
}

RemoveEnts(id = 0)
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

public ShowBonusExpInfo()
{
	if(GetPlayersAmount() > 0 && iLastInfo + 3.0 > get_gametime())
	{
		if(GetPlayersAmount() == iMinBonusPlayers) cod_print_chat(0, "Serwer jest pelny, a to oznacza^x03 exp x 2^x01!");
		else cod_print_chat(0, "Do pelnego serwera brakuje^x03 %i osob^x01. Exp jest wiekszy o^x03 %i%%^x01!", iMinBonusPlayers - GetPlayersAmount(), GetPlayersAmount() * 10);
		
		iLastInfo = floatround(get_gametime());
	}
}

public GetLevelExp(level)
	return power(level, 2) * iLevelRatio;
	
public GetHealth(id, class_health, gained_health, bonus_health)
{
	new iHealth;
	
	if(class_health) iHealth += GetClassInfo(gPlayer[id][PLAYER_CLASS], CLASS_HEALTH);
	if(gained_health) iHealth += gPlayer[id][PLAYER_HEAL];
	if(bonus_health) iHealth += gPlayer[id][PLAYER_EXTR_HEAL];

	return iHealth;
}

public GetIntelligence(id, gained_intelligence, bonus_intelligence)
{
	new iIntelligence;
	
	if(gained_intelligence) iIntelligence += gPlayer[id][PLAYER_INT];
	if(bonus_intelligence) iIntelligence += gPlayer[id][PLAYER_EXTR_INT];
	
	return iIntelligence;
}

public GetStamina(id, gained_stamina, bonus_stamina)
{
	new iStamina;
	
	if(gained_stamina) iStamina += gPlayer[id][PLAYER_STAM];
	if(bonus_stamina) iStamina += gPlayer[id][PLAYER_EXTR_STAM];
	
	return iStamina;
}

public GetStrength(id, gained_strength, bonus_strength)
{
	new iStrength;
	
	if(gained_strength) iStrength += gPlayer[id][PLAYER_STR];
	if(bonus_strength) iStrength += gPlayer[id][PLAYER_EXTR_STR];
	
	return iStrength;
}

public GetCondition(id, gained_condition, bonus_condition)
{
	new iCondition;
	
	if(gained_condition) iCondition += gPlayer[id][PLAYER_COND];
	if(bonus_condition) iCondition += gPlayer[id][PLAYER_EXTR_COND];
	
	return iCondition;
}

public SetCvars()
{
	iLevelLimit = get_pcvar_num(cLevelLimit);
	iLevelRatio = get_pcvar_num(cLevelRatio);
	
	iMinPlayers = get_pcvar_num(cMinPlayers);
	iMinBonusPlayers = get_pcvar_num(cMinBonusPlayers);
	iKillStreakTime = get_pcvar_num(cKillStreakTime);
	
	iKillExp = get_pcvar_num(cKillExp);
	iKillHSExp = get_pcvar_num(cKillHSExp);
	iDamageExp = get_pcvar_num(cDamageExp);
	iWinExp = get_pcvar_num(cWinExp);
	iPlantExp = get_pcvar_num(cPlantExp);
	iDefuseExp = get_pcvar_num(cDefuseExp);
	iRescueExp = get_pcvar_num(cRescueExp);
	
	iMaxDurability = get_pcvar_num(cMaxDurability);
	iMinDamageDurability = get_pcvar_num(cMinDamageDurability);
	iMaxDamageDurability = get_pcvar_num(cMaxDamageDurability);
}

public SqlInit()
{
	new szHost[32], szUser[32], szPass[32], szDatabase[32], szTemp[512], szError[128], iError;
	
	get_cvar_string("cod_sql_host", szHost, charsmax(szHost));
	get_cvar_string("cod_sql_user", szUser, charsmax(szUser));
	get_cvar_string("cod_sql_pass", szPass, charsmax(szPass));
	get_cvar_string("cod_sql_database", szDatabase, charsmax(szDatabase));
	
	hSqlHook = SQL_MakeDbTuple(szHost, szUser, szPass, szDatabase);

	new Handle:hConnect = SQL_Connect(hSqlHook, iError, szError, charsmax(szError));
	
	if(iError)
	{
		log_to_file("addons/amxmodx/logs/cod_mod.log", "Error: %s", szError);
		
		return;
	}
	
	formatex(szTemp, charsmax(szTemp), "CREATE TABLE IF NOT EXISTS `cod_mod` (name VARCHAR(35) NOT NULL, class VARCHAR(64) NOT NULL, exp INT UNSIGNED NOT NULL DEFAULT 0, lvl INT UNSIGNED NOT NULL DEFAULT 1, PRIMARY KEY(name, class), ");
	add(szTemp,  charsmax(szTemp), "intelligence INT UNSIGNED NOT NULL DEFAULT 0, health INT UNSIGNED NOT NULL DEFAULT 0, stamina INT UNSIGNED NOT NULL DEFAULT 0, condition INT UNSIGNED NOT NULL DEFAULT 0, strength INT UNSIGNED NOT NULL DEFAULT 0)");	

	new Handle:hQuery = SQL_PrepareQuery(hConnect, szTemp);

	SQL_Execute(hQuery);
	
	SQL_FreeHandle(hQuery);
	SQL_FreeHandle(hConnect);
}

public LoadData(id)
{
	new szData[1], szTemp[128];
	
	szData[0] = id;
	
	formatex(szTemp, charsmax(szTemp), "SELECT * FROM `cod_mod` WHERE name = '%s'", gPlayer[id][PLAYER_NAME]);
	SQL_ThreadQuery(hSqlHook, "LoadData_Handle", szTemp, szData, sizeof(szData));
}

public LoadData_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState) 
	{
		log_to_file("addons/amxmodx/logs/cod_mod.log", "SQL Error: %s (%d)", szError, iError);
		
		return;
	}
	
	new id = szData[0];
	
	new szClass[MAX_NAME], aClass[ePlayerClassInfo], iClass;
	
	while(SQL_MoreResults(hQuery))
	{
		SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "class"), szClass, charsmax(szClass));
		
		iClass = GetClassID(szClass);

		if(iClass)
		{
			aClass[PCLASS_LEVEL] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "lvl"));
			aClass[PCLASS_EXP] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "exp"));
			aClass[PCLASS_INT] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "intelligence"));
			aClass[PCLASS_HEAL] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "health"));
			aClass[PCLASS_STAM] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "stamina"));
			aClass[PCLASS_STR] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "strength"));
			aClass[PCLASS_COND] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "condition"));
			
			ArraySetArray(gPlayersClasses[id], iClass, aClass);
		}

		SQL_NextRow(hQuery);
	}
	
	Set(id, iLoaded);
	
	if(is_user_alive(id)) SelectFraction(id);
}

public SaveData(id, end)
{
	if(!gPlayer[id][PLAYER_CLASS] || !Get(id, iLoaded)) return;

	new szTemp[256], szClass[MAX_NAME];
	GetClassInfo(gPlayer[id][PLAYER_CLASS], CLASS_NAME, szClass, charsmax(szClass));
	
	formatex(szTemp, charsmax(szTemp), "UPDATE `cod_mod` SET exp = (`exp` + %d), lvl = (`lvl` + %d), intelligence = '%d', health = '%d', stamina = '%d', strength = '%d', condition = '%d' WHERE name = '%s' AND class = '%s'", 
	gPlayer[id][PLAYER_GAINED_EXP], gPlayer[id][PLAYER_GAINED_LEVEL], gPlayer[id][PLAYER_INT], gPlayer[id][PLAYER_HEAL], gPlayer[id][PLAYER_STAM], gPlayer[id][PLAYER_STR], gPlayer[id][PLAYER_COND], gPlayer[id][PLAYER_NAME], szClass);
	
	switch(end)
	{
		case NORMAL, DISCONNECT: SQL_ThreadQuery(hSqlHook, "Ignore_Handle", szTemp);
		case MAP_END:
		{
			new szError[128], iError, Handle:hSqlConnection, Handle:hQuery;
			
			hSqlConnection = SQL_Connect(hSqlHook, iError, szError, charsmax(szError));

			if(!hSqlConnection)
			{
				log_to_file("addons/amxmodx/logs/cod_stats.txt", "Save - Could not connect to SQL database.  [%d] %s", szError, szError);
				
				SQL_FreeHandle(hSqlConnection);
				
				return;
			}
			
			hQuery = SQL_PrepareQuery(hSqlConnection, szTemp);
			
			if(!SQL_Execute(hQuery))
			{
				iError = SQL_QueryError(hQuery, szError, charsmax(szError));
				
				log_to_file("addons/amxmodx/logs/cod_stats.txt", "Save Query Nonthreaded failed. [%d] %s", iError, szError);
				
				SQL_FreeHandle(hQuery);
				SQL_FreeHandle(hSqlConnection);
				
				return;
			}
	
			SQL_FreeHandle(hQuery);
			SQL_FreeHandle(hSqlConnection);
		}
	}
	
	gPlayer[id][PLAYER_EXP] += gPlayer[id][PLAYER_GAINED_EXP];
	gPlayer[id][PLAYER_GAINED_EXP] = 0;
	
	gPlayer[id][PLAYER_LEVEL] += gPlayer[id][PLAYER_GAINED_LEVEL];
	gPlayer[id][PLAYER_GAINED_LEVEL] = 0;
	
	new aClass[ePlayerClassInfo];
	
	aClass[PCLASS_LEVEL] = gPlayer[id][PLAYER_LEVEL];
	aClass[PCLASS_EXP] = gPlayer[id][PLAYER_EXP];
	aClass[PCLASS_INT] = gPlayer[id][PLAYER_INT];
	aClass[PCLASS_HEAL] = gPlayer[id][PLAYER_HEAL];
	aClass[PCLASS_STAM] = gPlayer[id][PLAYER_STAM];
	aClass[PCLASS_STR] = gPlayer[id][PLAYER_STR];
	aClass[PCLASS_COND] = gPlayer[id][PLAYER_COND];
	
	ArraySetArray(gPlayersClasses[id], gPlayer[id][PLAYER_CLASS], aClass);
	
	if(end) Rem(id, iLoaded);
}

public LoadClass(id, class)
{
	if(!class || !Get(id, iLoaded)) return;

	new aClass[ePlayerClassInfo];
	
	ArrayGetArray(gPlayersClasses[id], class, aClass);

	gPlayer[id][PLAYER_GAINED_EXP] = 0;
	gPlayer[id][PLAYER_GAINED_LEVEL] = 0;
	gPlayer[id][PLAYER_LEVEL] = max(1, aClass[PCLASS_LEVEL]);
	gPlayer[id][PLAYER_EXP] = aClass[PCLASS_EXP];
	gPlayer[id][PLAYER_INT] = aClass[PCLASS_INT];
	gPlayer[id][PLAYER_HEAL] = aClass[PCLASS_HEAL];
	gPlayer[id][PLAYER_STAM] = aClass[PCLASS_STAM];
	gPlayer[id][PLAYER_STR] = aClass[PCLASS_STR];
	gPlayer[id][PLAYER_COND] = aClass[PCLASS_COND];

	if(!gPlayer[id][PLAYER_LEVEL])
	{
		gPlayer[id][PLAYER_LEVEL] = 1;
		aClass[PCLASS_LEVEL] = 1;
		
		ArraySetArray(gPlayersClasses[id], class, aClass);
		
		new szTemp[256], szClass[MAX_NAME];
		
		GetClassInfo(class, CLASS_NAME, szClass, charsmax(szClass));
		
		formatex(szTemp, charsmax(szTemp), "INSERT INTO `cod_mod` (`name`, `class`) VALUES ('%s', '%s') ON DUPLICATE KEY UPDATE name = name", gPlayer[id][PLAYER_NAME], szClass);
		SQL_ThreadQuery(hSqlHook, "Ignore_Handle", szTemp);
	}
	
	gPlayer[id][PLAYER_POINTS] = (gPlayer[id][PLAYER_LEVEL] - 1)*2 - gPlayer[id][PLAYER_INT] - gPlayer[id][PLAYER_HEAL] - gPlayer[id][PLAYER_STAM] - gPlayer[id][PLAYER_STR] - gPlayer[id][PLAYER_COND];
} 

public Ignore_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iSize)
{
	if (iFailState) 
	{
		if(iFailState == TQUERY_CONNECT_FAILED) log_to_file("addons/amxmodx/logs/cod_mod.log", "Could not connect to SQL database.  [%d] %s", iError, szError);
		else if (iFailState == TQUERY_QUERY_FAILED) log_to_file("addons/amxmodx/logs/cod_mod.log", "Query failed. [%d] %s", iError, szError);
	}
	
	return PLUGIN_CONTINUE;
}
	
public _cod_get_user_exp(id)
	return gPlayer[id][PLAYER_EXP];

public _cod_set_user_exp(id, value)
{
	gPlayer[id][PLAYER_GAINED_EXP] = value;
	
	CheckLevel(id);
}

public _cod_get_user_bonus_exp(id, value)
	return GetExpBonus(id, value);

public _cod_get_user_level(id)
	return gPlayer[id][PLAYER_LEVEL];
	
public _cod_get_user_highest_level(id)
{
	new iLevel, aClass[eClassInfo];
	
	for(new i = 1; i < ArraySize(gPlayersClasses[id]); i++)
	{
		ArrayGetArray(gPlayersClasses[id], i, aClass);
		
		if(aClass[PCLASS_LEVEL] > iLevel) iLevel = aClass[PCLASS_LEVEL];
	}
	
	return iLevel;
}

public _cod_get_user_class(id)
	return gPlayer[id][PLAYER_CLASS];

public _cod_set_user_class(id, class, force)
{
	gPlayer[id][PLAYER_NEW_CLASS] = class;
	
	if(force)
	{
		SetNewClass(id);
		SetAttributes(id);
	}
}

public _cod_get_classid(szClass[])
{
	param_convert(1);
	
	return GetClassID(szClass);
}

public _cod_get_class_name(class, szReturn[], iLen)
{
	//if(class < ArraySize(gClasses))
	//{
	//	new aClass[eClassInfo];
	//	
	//	ArrayGetArray(gClasses, class, aClass);
	//	
	//	param_convert(2);
	//	
	//	copy(szReturn, iLen, aClass[CLASS_NAME]);
	//}
	param_convert(2);
	
	GetClassInfo(class, CLASS_NAME, szReturn, charsmax(iLen));
}

public _cod_get_class_desc(class, szReturn[], iLen)
{
	//if(class < ArraySize(gClasses))
	//{
	//	new aClass[eClassInfo];
	//	
	//	ArrayGetArray(gClasses, class, aClass);
	//	
	//	param_convert(2);
	//	
	//	copy(szReturn, iLen, aClass[CLASS_DESC]);
	//}
	param_convert(2);
	
	GetClassInfo(class, CLASS_DESC, szReturn, charsmax(iLen));
}

public _cod_get_class_health(class)
{
	//if(class < ArraySize(gClasses)) return GetClassInfo(class, CLASS_HEALTH);
	//return 0;
	return GetClassInfo(class, CLASS_HEALTH);
}

public _cod_get_classes_num()
	return ArraySize(gClasses);

public _cod_get_user_item(id, &value)
{
	new pFunc = get_func_id("cod_get_item_value", GetItemInfo(gPlayer[id][PLAYER_ITEM], ITEM_PLUGIN));

	if(pFunc != -1)
	{
		callfunc_begin_i(pFunc, GetItemInfo(gPlayer[id][PLAYER_ITEM], ITEM_PLUGIN))
		callfunc_push_int(id);
		callfunc_push_int(value);
		callfunc_end();
	}

	return gPlayer[id][PLAYER_ITEM];
}

public _cod_set_user_item(id, item, value)
	SetItem(id, item, value);

public _cod_upgrade_user_item(id)
{
	if(!ArraySize(gItems)) return;
	
	switch(random_num(1, 4))
	{
		case 1:
		{
			new iDurability = random_num(iMinDamageDurability, iMaxDamageDurability);
			
			gPlayer[id][PLAYER_ITEM_DURA] -= iDurability;
	
			if(!gPlayer[id][PLAYER_ITEM_DURA])
			{
				SetItem(id);
		
				cod_print_chat(id, "Ulepszenie^x03 nieudane^x01! Twoj item ulegl^x03 zniszczeniu^x01.");
				
				return;
			}
			
			cod_print_chat(id, "Ulepszenie^x03 nieudane^x01! Straciles^x03 %i^x01 wytrzymalosci itemu.", iDurability);
		}
		case 2:
		{
			SetItem(id);
		
			cod_print_chat(id, "Ulepszenie^x03 nieudane^x01! Twoj item ulegl^x03 zniszczeniu^x01.");
		}
		case 3, 4:
		{
			new iForwardHandle = CreateOneForward(GetItemInfo(gPlayer[id][PLAYER_ITEM], ITEM_PLUGIN), "cod_item_upgrade", FP_CELL);
	
			ExecuteForward(iForwardHandle, id, id);
			DestroyForward(iForwardHandle);	
		}
	}
}

public _cod_get_itemid(szItem[])
{
	param_convert(1);
	
	new aItem[eClassInfo];
	
	for(new i = 1; i < ArraySize(gItems); i++)
	{
		ArrayGetArray(gItems, i, aItem);
		
		if(equali(aItem[ITEM_NAME], szItem)) return i;
	}
	
	return 0;
}

public _cod_get_item_name(item, szReturn[], iLen)
{
	//if(item < ArraySize(gItems))
	//{
	//	new aItem[eItemInfo];
	//	
	//	ArrayGetArray(gClasses, item, aItem);
	//	
	//	param_convert(2);
	//	
	//	copy(szReturn, iLen, aItem[ITEM_NAME]);
	//}
	param_convert(2);
	
	GetItemInfo(item, ITEM_NAME, szReturn, charsmax(iLen));
}

public _cod_get_item_desc(item, szReturn[], iLen)
{
	//if(item < ArraySize(gItems))
	//{
	//	new aItem[eItemInfo];
	//	
	//	ArrayGetArray(gClasses, item, aItem);
	//	
	//	param_convert(2);
	//	copy(szReturn, iLen, aItem[ITEM_DESC]);
	//}
	param_convert(2);
	
	GetItemInfo(item, ITEM_DESC, szReturn, charsmax(iLen));
}

public _cod_get_items_num()
	return ArraySize(gItems);
	
public _cod_get_item_durability(id)
	return gPlayer[id][PLAYER_ITEM_DURA];
	
public _cod_set_item_durability(id, value)
	gPlayer[id][PLAYER_ITEM_DURA] = min(value, iMaxDurability);

public _cod_max_item_durability(id)
	return iMaxDurability;

public _cod_get_user_bonus_health(id)
	return gPlayer[id][PLAYER_EXTR_HEAL];

public _cod_get_user_bonus_int(id)
	return gPlayer[id][PLAYER_EXTR_INT];
	
public _cod_get_user_bonus_stamina(id)
	return gPlayer[id][PLAYER_EXTR_STAM];
	
public _cod_get_user_bonus_strength(id)
	return gPlayer[id][PLAYER_EXTR_STR];
	
public _cod_get_user_bonus_condition(id)
	return gPlayer[id][PLAYER_EXTR_COND];

public _cod_set_user_bonus_health(id, value)
	gPlayer[id][PLAYER_EXTR_HEAL] = max(0, gPlayer[id][PLAYER_EXTR_HEAL] + value);
	
public _cod_set_user_bonus_int(id, value)
	gPlayer[id][PLAYER_EXTR_INT] = max(0, gPlayer[id][PLAYER_EXTR_INT] + value);

public _cod_set_user_bonus_stamina(id, value)
{
	gPlayer[id][PLAYER_EXTR_STAM] = max(0, gPlayer[id][PLAYER_EXTR_STAM] + value);
	
	gPlayer[id][PLAYER_DMG_REDUCE] = _:(0.7 * (1.0 - floatpower(1.1, -0.112311341 * GetStamina(id, 1, 1))));
}

public _cod_set_user_bonus_strength(id, value)
	gPlayer[id][PLAYER_EXTR_STR] = max(0, gPlayer[id][PLAYER_EXTR_STR] + value);

public _cod_set_user_bonus_condition(id, value)
{
	gPlayer[id][PLAYER_EXTR_COND] = max(0, gPlayer[id][PLAYER_EXTR_COND] + value);
	
	gPlayer[id][PLAYER_SPEED] = _:(GetCondition(id, 1, 1) * 2);
}

public _cod_get_user_health(id, class_health, gained_health, bonus_health)
	return GetHealth(id, class_health, gained_health, bonus_health);

public _cod_get_user_int(id, gained_intelligence, bonus_intelligence)
	return GetIntelligence(id, gained_intelligence, bonus_intelligence);

public _cod_get_user_stamina(id, gained_stamina, bonus_stamina)
	return GetStamina(id, gained_stamina, bonus_stamina);

public _cod_get_user_strength(id, gained_strength, bonus_strength)
	return GetStrength(id, gained_strength, bonus_strength);
	
public _cod_get_user_condition(id, gained_condition, bonus_condition)
	return GetCondition(id, gained_condition, bonus_condition);

public _cod_add_user_health(id, value)
	set_user_health(id, min(get_user_health(id) + value, GetHealth(id, 1, 1, 1)));

public _cod_get_user_rockets(id)
	return gPlayer[id][PLAYER_ROCKETS];

public _cod_get_user_mines(id)
	return gPlayer[id][PLAYER_MINES];

public _cod_get_user_dynamites(id)
	return gPlayer[id][PLAYER_DYNAMITES];
	
public _cod_get_user_medkits(id)
	return gPlayer[id][PLAYER_MEDKITS];
	
public _cod_get_user_multijump(id)
	return gPlayer[id][PLAYER_JUMPS];
	
public _cod_get_user_gravity(id)
	return gPlayer[id][PLAYER_GRAVITY];

public _cod_set_user_rockets(id, value)
	gPlayer[id][PLAYER_ROCKETS] = max(0, value);

public _cod_set_user_mines(id, value)
	gPlayer[id][PLAYER_MINES] = max(0, value);

public _cod_set_user_dynamites(id, value)
	gPlayer[id][PLAYER_DYNAMITES] = max(0, value);
	
public _cod_set_user_medkits(id, value)
	gPlayer[id][PLAYER_MEDKITS] = max(0, value);

public _cod_set_user_multijump(id, value)
	gPlayer[id][PLAYER_LEFT_JUMPS] = gPlayer[id][PLAYER_JUMPS] = max(0, value);
	
public _cod_set_user_gravity(id, value)
{
	gPlayer[id][PLAYER_GRAVITY] = _:floatmax(0.1, float(value));
	
	entity_set_float(id, EV_FL_gravity, float(gPlayer[id][PLAYER_GRAVITY]));
}
	
public _cod_add_user_rockets(id, value)
	gPlayer[id][PLAYER_ROCKETS] = max(0, gPlayer[id][PLAYER_ROCKETS] + value);

public _cod_add_user_mines(id, value)
	gPlayer[id][PLAYER_MINES] = max(0, gPlayer[id][PLAYER_MINES] + value);

public _cod_add_user_dynamites(id, value)
	gPlayer[id][PLAYER_DYNAMITES] = max(0, gPlayer[id][PLAYER_DYNAMITES] + value);
	
public _cod_add_user_medkits(id, value)
	gPlayer[id][PLAYER_MEDKITS] = max(0, gPlayer[id][PLAYER_MEDKITS] + value);
	
public _cod_add_user_multijump(id, value)
	gPlayer[id][PLAYER_LEFT_JUMPS] = gPlayer[id][PLAYER_JUMPS] = max(0, gPlayer[id][PLAYER_JUMPS] + value);
	
public _cod_add_user_gravity(id, value)
{
	gPlayer[id][PLAYER_GRAVITY] = _:floatmax(0.1, float(gPlayer[id][PLAYER_GRAVITY] + value));
	
	entity_set_float(id, EV_FL_gravity, float(gPlayer[id][PLAYER_GRAVITY]));
}

public _cod_get_user_resistance(id, value)
	return Get(id, iResistance);
	
public _cod_get_user_bunnyhop(id, value)
	return Get(id, iBunnyHop);
	
public _cod_get_user_footsteps(id)
	get_user_footsteps(id);
	
public _cod_set_user_resistance(id, value)
	value ? Set(id, iResistance) : Rem(id, iResistance);

public _cod_set_user_bunnyhop(id, value)
	value ? Set(id, iBunnyHop) : Rem(id, iBunnyHop);

public _cod_set_user_footsteps(id, value)
	set_user_footsteps(id, value);

public _cod_give_weapon(id, weapon)
{
	new szWeaponName[22];
	
	gPlayer[id][PLAYER_EXTR_WPNS] |= (1<<weapon);
	
	get_weaponname(weapon, szWeaponName, charsmax(szWeaponName));
	
	return give_item(id, szWeaponName);
}

public _cod_take_weapon(id, weapon)
{
	gPlayer[id][PLAYER_EXTR_WPNS] &= ~(1<<weapon);
	
	if((1<<weapon) & (iAllowedWeapons | iTeamWeapons[get_user_team(id)] | GetClassInfo(gPlayer[id][PLAYER_CLASS], CLASS_WEAPONS))) return;
	
	new szWeaponName[22];
	
	get_weaponname(weapon, szWeaponName, charsmax(szWeaponName));
	
	if(!((1<<weapon) & (1<<CSW_HEGRENADE | 1<<CSW_SMOKEGRENADE | 1<<CSW_FLASHBANG))) engclient_cmd(id, "drop", szWeaponName);
}

public _cod_display_fade(id, duration, holdtime, fadetype, red, green, blue, alpha)
	DisplayFade(id, duration * (1<<12), holdtime * (1<<12), fadetype, red, green, blue, alpha);
	
public _cod_screen_shake(id, amplitude, duration, frequency)
	ScreenShake(id, amplitude, duration, frequency);
	
public _cod_make_explosion(ent, distance)
	MakeExplosion(ent, distance);
	
public _cod_make_bartimer(id, duration)
	MakeBarTimer(id, duration);

public _cod_inflict_damage(iAttacker, iVictim, Float:fDamage, Float:fIntelligence, iFlags)
	if(!Get(iVictim, iResistance)) ExecuteHam(Ham_TakeDamage, iVictim, iAttacker, iAttacker, fDamage + GetIntelligence(iAttacker, 1, 1) * fIntelligence, (1<<31) | iFlags);
	
public _cod_kill_player(iKiller, iVictim, iFlags)
{
	if(is_user_alive(iVictim))
	{
		cs_set_user_armor(iVictim, 0, CS_ARMOR_NONE);
		
		_cod_inflict_damage(iKiller, iVictim, float(get_user_health(iVictim) + 1), 0.0, iFlags);
	}
}
	
public _cod_register_item(iPlugin, iParams)
{
	if(iParams != 2) return PLUGIN_CONTINUE;

	new aItem[eItemInfo];
	
	get_string(1, aItem[ITEM_NAME], charsmax(aItem[ITEM_NAME]));
	get_string(2, aItem[ITEM_DESC], charsmax(aItem[ITEM_DESC]));
	
	aItem[ITEM_PLUGIN] = iPlugin;
	
	aItem[ITEM_GIVE] = CreateOneForward(iPlugin, "cod_item_enabled", FP_CELL, FP_CELL, FP_CELL);
	aItem[ITEM_DROP] = CreateOneForward(iPlugin, "cod_item_disabled", FP_CELL);
	aItem[ITEM_SPAWNED] = CreateOneForward(iPlugin, "cod_item_spawned", FP_CELL);
	aItem[ITEM_KILLED] = CreateOneForward(iPlugin, "cod_item_killed", FP_CELL);
	aItem[ITEM_SKILL_USED] = CreateOneForward(iPlugin, "cod_item_skill_used", FP_CELL);
	aItem[ITEM_UPGRADE] = CreateOneForward(iPlugin, "cod_item_upgrade", FP_CELL);
	
	aItem[ITEM_DAMAGE_ATTACKER] = get_func_id("cod_item_damage_attacker", iPlugin);
	aItem[ITEM_DAMAGE_VICTIM] = get_func_id("cod_item_damage_victim", iPlugin);
	
	ArrayPushArray(gItems, aItem);
	
	return PLUGIN_CONTINUE;
}

public _cod_register_class(iPlugin, iParams)
{
	if(iParams != 5) return PLUGIN_CONTINUE;

	new aClass[eClassInfo];
	
	get_string(1, aClass[CLASS_NAME], charsmax(aClass[CLASS_NAME]));
	get_string(2, aClass[CLASS_DESC], charsmax(aClass[CLASS_DESC]));
	
	get_string(3, aClass[CLASS_FRACTION], charsmax(aClass[CLASS_FRACTION]));
	
	if(!equal(aClass[CLASS_FRACTION], "")) CheckFraction(aClass[CLASS_FRACTION]);
	
	aClass[CLASS_WEAPONS] = get_param(4);
	aClass[CLASS_HEALTH] = get_param(5);

	aClass[CLASS_PLUGIN] = iPlugin;
	
	aClass[CLASS_ENABLED] = CreateOneForward(iPlugin, "cod_class_enabled", FP_CELL);
	aClass[CLASS_DISABLED] = CreateOneForward(iPlugin, "cod_class_disabled", FP_CELL);
	aClass[CLASS_SPAWNED] = CreateOneForward(iPlugin, "cod_class_spawned",FP_CELL);
	aClass[CLASS_KILLED] = CreateOneForward(iPlugin, "cod_class_killed", FP_CELL);
	aClass[CLASS_SKILL_USED] = CreateOneForward(iPlugin, "cod_class_skill_used", FP_CELL);

	aClass[CLASS_DAMAGE_VICTIM] = get_func_id("cod_class_damage_victim", iPlugin);
	aClass[CLASS_DAMAGE_ATTACKER] = get_func_id("cod_class_damage_attacker", iPlugin);
	
	ArrayPushArray(gClasses, aClass);

	return PLUGIN_CONTINUE;
}

stock GetExpBonus(id, exp)
{
	new Float:iBonus = 1.0;
	
	if(cod_get_user_vip(id)) iBonus += 0.5;

	iBonus += floatmin(gPlayer[id][PLAYER_KS] * 0.2, 1.0);
	
	iBonus += GetPlayersAmount() * 0.1;
	
	return floatround(exp * iBonus);
}

stock GetPlayersAmount()
{
	if(get_maxplayers() - iPlayers <= iMinBonusPlayers) return (get_maxplayers() - iPlayers);

	return 0;
}

stock CheckFraction(szFraction[])
{
	new szName[MAX_NAME], bool:bFraction;
	
	for(new i = 0; i < ArraySize(gFractions); i++)
	{
		ArrayGetString(gFractions, i, szName, charsmax(szName));
		
		if(equali(szName, szFraction)) bFraction = true;
	}
	
	if(!bFraction) ArrayPushString(gFractions, szFraction);
}

stock GetWeapons(weapons)
{
	new szWeapons[96], szWeapon[22];
	
	for(new i = 1, j = 1; i <= 32; i++)
	{
		if((1<<i) & weapons)
		{
			get_weaponname(i, szWeapon, charsmax(szWeapon));
			replace_all(szWeapon, charsmax(szWeapon), "weapon_", "");
			
			if(equal(szWeapon, "hegrenade")) szWeapon = "he";
			if(equal(szWeapon, "flashbang")) szWeapon = "flash";
			if(equal(szWeapon, "smokegrenade")) szWeapon = "smoke";
			
			strtoupper(szWeapon);
			
			if(j > 1) add(szWeapons, charsmax(szWeapons), ", ");
			
			add(szWeapons, charsmax(szWeapons), szWeapon);
			
			j++;
		}
	}
	
	return szWeapons;
}

stock ExecuteForwardIgnoreIntNoParam(fForwardHandle)
{
	static iRet;
	
	return ExecuteForward(fForwardHandle, iRet);
}

stock ExecuteForwardIgnoreIntOneParam(fForwardHandle, iParam)
{
	static iRet;
	
	return ExecuteForward(fForwardHandle, iRet, iParam);
}

stock ExecuteForwardIgnoreIntTwoParam(fForwardHandle, iParamOne, iParamTwo)
{
	static iRet;
	
	return ExecuteForward(fForwardHandle, iRet, iParamOne, iParamTwo);
}

stock GetClassInfo(class, info, szReturn[] = "", iLen = 0)
{
	new aClass[eClassInfo];
	
	ArrayGetArray(gClasses, class, aClass);
	
	if(info == CLASS_NAME || info == CLASS_DESC || info == CLASS_FRACTION)
	{
		copy(szReturn, iLen, aClass[info]);
		
		return 0;
	}
	
	return aClass[info];
}

stock GetClassID(szClass[])
{
	new aClass[eClassInfo];
	
	for(new i = 1; i < ArraySize(gClasses); i++)
	{
		ArrayGetArray(gClasses, i, aClass);
		
		if(equali(aClass[CLASS_NAME], szClass)) return i;
	}
	
	return 0;
}

stock GetItemInfo(item, info, szReturn[] = "", iLen = 0)
{
	new aItem[eItemInfo];
	
	ArrayGetArray(gItems, item, aItem);
	
	if(info == ITEM_NAME || info == ITEM_DESC)
	{
		copy(szReturn, iLen, aItem[info]);
		
		return 0;
	}
	
	return aItem[info];
}

stock MakeExplosion(ent, distance = 0, explosion = 1)
{
	new Float:fOrigin[3], iOrigin[3];
	
	entity_get_vector(ent, EV_VEC_origin, fOrigin);

	for(new i = 0; i < 3; i++) iOrigin[i] = floatround(fOrigin[i]);

	if(explosion)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_short(iSprites[SPRITE_EXPLOSION]);
		write_byte(32);
		write_byte(20);
		write_byte(0);
		message_end();
	}
	
	if(distance)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iOrigin);
		write_byte(TE_BEAMCYLINDER);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1] + distance);
		write_coord(iOrigin[2] + distance);
		write_short(iSprites[SPRITE_WHITE]);
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

stock MakeBarTimer(id, duration)
{
	static gmsgBartimer;
	
	if(!gmsgBartimer) gmsgBartimer = get_user_msgid("BarTime");
	
	message_begin(id ? MSG_ONE : MSG_ALL , gmsgBartimer, {0, 0, 0}, id);
	write_byte(duration); 
	write_byte(0);
	message_end();
}

stock DisplayFade(id, duration, holdtime, fadetype, red, green, blue, alpha)
{
	if(!pev_valid(id)) return;

	static gmsgScreenFade;
	
	if(!gmsgScreenFade) gmsgScreenFade = get_user_msgid("ScreenFade");

	message_begin(MSG_ONE, gmsgScreenFade, {0, 0, 0}, id);
	write_short(duration);
	write_short(holdtime);
	write_short(fadetype);
	write_byte(red);	
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	message_end();
}

stock ScreenShake(id, amplitude, duration, frequency)
{
	if(!pev_valid(id)) return;
	
	static gmsgScreenShake;
	
	if(!gmsgScreenShake) gmsgScreenShake = get_user_msgid("ScreenShake");
	
	message_begin(MSG_ONE, gmsgScreenShake, {0, 0, 0}, id);
	write_short(amplitude);
	write_short(duration);
	write_short(frequency);
	message_end();
}

stock get_loguser_index()
{
	new szLogUser[96], szName[32];
	
	read_logargv(0, szLogUser, charsmax(szLogUser));
	parse_loguser(szLogUser, szName, charsmax(szName));

	return get_user_index(szName);
}

stock cs_get_weaponbox_type(iWeaponBox)
{
	new iWeapon, cWeaponBox[6] = { 34 , 35 , ... };
	
	for(new i = 1; i <= 5; i++) 
	{
		iWeapon = get_pdata_cbase(iWeaponBox, cWeaponBox[i], 4);
		
		if(iWeapon > 0) return cs_get_weapon_id(iWeapon);
	}
	
	return 0;
}

stock is_enough_space(id)
{
	new Float:fPosition[3], Float:fStart[3], Float:fEnd[3];
	
	pev(id, pev_origin, fPosition);
 
	fStart[0] = fEnd[0] = fPosition[0];
	fStart[1] = fEnd[1] = fPosition[1];
	fStart[2] = fEnd[2] = fPosition[2];

	fStart[0] += 135.0;
	fEnd[0] -= 135.0;
 
	if(is_wall_between_points(fStart, fEnd, id)) return 0;
 
	fStart[0] -= 135.0;
	fEnd[0] += 135.0;
	fStart[1] += 135.0;
	fEnd[1] -= 135.0;
 
	if(is_wall_between_points(fStart, fEnd, id)) return 0;
 
	return 1;
}
 
stock is_wall_between_points(Float:fStart[3], Float:fEnd[3], ent)
{
	engfunc(EngFunc_TraceLine, fStart, fEnd, IGNORE_GLASS, ent, 0);
 
	new Float:fFraction;
	
	get_tr2(0, TR_flFraction, fFraction);
 
	if(fFraction != 1.0) return 1;
	
	return 0;
}

stock mysql_escape_string(const szSource[], szDest[], iLen)
{
	copy(szDest, iLen, szSource);
	
	replace_all(szDest, iLen, "\\", "\\\\");
	replace_all(szDest, iLen, "\0", "\\0");
	replace_all(szDest, iLen, "\n", "\\n");
	replace_all(szDest, iLen, "\r", "\\r");
	replace_all(szDest, iLen, "\x1a", "\Z");
	replace_all(szDest, iLen, "'", "\'");
	replace_all(szDest, iLen, "`", "\`");
	replace_all(szDest, iLen, "^"", "\^"");
}

stock cmd_execute(id, const szText[], any:...) 
{
	#pragma unused szText

	new szMessage[256];

	format_args(szMessage, charsmax(szMessage), 1);

	message_begin(id == 0 ? MSG_ALL : MSG_ONE, SVC_DIRECTOR, _, id);
	write_byte(strlen(szMessage) + 2);
	write_byte(10);
	write_string(szMessage);
	message_end();
}