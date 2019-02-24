#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>
#include <nvault>
#include <cod>

#define PLUGIN  "CoD Icons"
#define VERSION "1.3.1"
#define AUTHOR  "O'Zone"

// Uncomment to enable lite version of icons.
// Plugin will use sprites with smaller size.
// This will prevent server crashes on maps with big .bsp files.
// Those sprites have no distance indicator that are used in full version.
//#define LITE

#define TASK_PLANT      6583
#define TASK_PLANTED    7603
#define TASK_DROPPED    8931
#define TASK_REMOVE     9548

#define UNITS_PER_METER 39.37

new const commandIcons[][] = { "ikony", "say /ikona", "say_team /ikona", "say /ikony", "say_team /ikony", "say /icon", "say_team /icon", "say /icons", "say_team /icons" };

#if defined LITE
new const iconSprite[icons][] = {
	"sprites/CoDMod/bs_a_lite.spr",
	"sprites/CoDMod/bs_b_lite.spr",
	"sprites/CoDMod/dropped_lite.spr",
	"sprites/CoDMod/planted_lite.spr",
	"sprites/CoDMod/explode_lite.spr",
	"sprites/CoDMod/box_lite.spr"
};
#else
new const iconSprite[icons][] = {
	"sprites/CoDMod/bs_a.spr",
	"sprites/CoDMod/bs_b.spr",
	"sprites/CoDMod/dropped.spr",
	"sprites/CoDMod/planted.spr",
	"sprites/CoDMod/explode.spr",
	"sprites/CoDMod/box.spr"
};
#endif

new playerName[MAX_PLAYERS + 1][MAX_NAME], bombEntity[icons], iconEntity[icons], playerTeam[MAX_PLAYERS + 1],bool:mapEnd,
	bool:roundStarted, dataLoaded, iconBombSites, iconDropped, iconPlanted, iconBox, bombTimer, cvarC4, iconsVault;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	new mapName[12], bsBombSiteA, bsBombSiteB;

	get_mapname(mapName, charsmax(mapName));

	if (equal(mapName, "de_chateau") || equal(mapName, "de_dust2") || equal(mapName, "de_train") || equal(mapName, "de_alexandra")) {
		bsBombSiteA = BOMBSITE_B;
		bsBombSiteB = BOMBSITE_A;
	} else {
		bsBombSiteA = BOMBSITE_A;
		bsBombSiteB = BOMBSITE_B;
	}

	bombEntity[bsBombSiteA] = find_ent_by_class(NONE, "func_bomb_target");
	bombEntity[bsBombSiteB] = find_ent_by_class(bombEntity[bsBombSiteA], "func_bomb_target");

	if (!pev_valid(bombEntity[bsBombSiteA])) {
		bombEntity[bsBombSiteA] = find_ent_by_class(NONE, "info_bomb_target");
		bombEntity[bsBombSiteB] = find_ent_by_class(bombEntity[bsBombSiteA], "info_bomb_target");
	}

	if (pev_valid(bombEntity[bsBombSiteA])) {
		spawn_sprite(bombEntity[bsBombSiteA], bsBombSiteA);
		spawn_sprite(bombEntity[bsBombSiteB], bsBombSiteB);
	}

	iconsVault = nvault_open("cod_icons");

	if (iconsVault == INVALID_HANDLE) set_fail_state("[COD] Nie mozna otworzyc pliku cod_icons.vault");

	for (new i; i < sizeof(commandIcons); i++) register_clcmd(commandIcons[i], "change_icons");

	cvarC4 = get_cvar_pointer("mp_c4timer");

	register_forward(FM_AddToFullPack, "fm_fullpack", 1);
	register_forward(FM_CheckVisibility, "check_visible");
}

public plugin_natives()
	register_native("cod_spawn_icon", "_cod_spawn_icon", 1);

public plugin_precache()
	for (new i; i < sizeof(iconSprite); i++) precache_model(iconSprite[i]);

public plugin_end()
	nvault_close(iconsVault);

public client_putinserver(id)
{
	rem_bit(id, dataLoaded);
	rem_bit(id, iconBombSites);
	rem_bit(id, iconDropped);
	rem_bit(id, iconPlanted);
	rem_bit(id, iconBox);

	if (is_user_bot(id) || is_user_hltv(id)) return;

	load_icons(id);
}

public cod_end_map()
	mapEnd = true;

public cod_reset_all_data()
{
	for (new i = 1; i <= MAX_PLAYERS; i++) rem_bit(i, dataLoaded);

	mapEnd = true;

	nvault_prune(iconsVault, 0, get_systime() + 1);
}

public cod_team_assign(id, team)
	playerTeam[id] = team;

public cod_bomb_dropped(id)
	set_task(0.2, "bomb_drop", TASK_DROPPED, .flags = "a", .repeat = 5);

public bomb_drop()
{
	remove_icon(iconEntity[BOMB_DROP], BOMB_DROP);

	new bombEnt;

	if ((bombEnt = fm_find_ent_by_model(NONE, "weaponbox", "models/w_backpack.mdl"))) spawn_sprite(bombEnt, BOMB_DROP);
}

public cod_bomb_picked(id)
{
	remove_task(TASK_DROPPED);

	remove_icon(iconEntity[BOMB_DROP], BOMB_DROP);
}

public cod_bomb_planted(id)
{
	bombTimer = get_pcvar_num(cvarC4);

	set_task(1.0, "bomb_timer", TASK_PLANTED, "", 0, "b");
	set_task(0.2, "bomb_plant", TASK_PLANT, .flags = "a", .repeat = 5);
}

public bomb_plant()
{
	remove_icon(iconEntity[BOMB_PLANT], BOMB_PLANT);

	new bombEnt;

	if ((bombEnt = fm_find_ent_by_model(NONE, "grenade", "models/w_c4.mdl"))) spawn_sprite(bombEnt, BOMB_PLANT);
}

public bomb_timer()
{
	if (bombTimer < 0) {
		remove_task(TASK_PLANTED);

		return;
	}

	if (--bombTimer == 10) {
		remove_icon(iconEntity[BOMB_PLANT], BOMB_PLANT);

		spawn_sprite(bombEntity[BOMB_PLANT], BOMB_EXPLODE);
	}
}

public cod_box_dropped(ent)
	spawn_sprite(ent, BOX);

public cod_start_round()
	roundStarted = true;

public cod_new_round()
{
	remove_icon(iconEntity[BOMB_DROP], BOMB_DROP);
	remove_icon(iconEntity[BOMB_PLANT], BOMB_PLANT);
	remove_icon(iconEntity[BOMB_EXPLODE], BOMB_EXPLODE);

	roundStarted = true;
}

public cod_end_round()
{
	bombTimer = NONE;

	roundStarted = false;

	bombEntity[BOMB_PLANT] = 0;

	remove_icon(iconEntity[BOMB_DROP], BOMB_DROP);
	remove_icon(iconEntity[BOMB_PLANT], BOMB_PLANT);
	remove_icon(iconEntity[BOMB_EXPLODE], BOMB_EXPLODE);

	new ent = NONE;

	while ((ent = find_ent_by_class(ent, iconSprite[BOX]))) {
		if (pev_valid(ent)) remove_entity(ent);
	}

	remove_task(TASK_PLANT);
	remove_task(TASK_PLANTED);
	remove_task(TASK_DROPPED);
}

public spawn_sprite(entity, sprite)
{
	if (!pev_valid(entity)) return;

	static ent, Float:origin[3];

	if (sprite == BOMBSITE_A || sprite == BOMBSITE_B) get_brush_entity_origin(entity, origin);
	else pev(entity, pev_origin, origin);

	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

	if (!pev_valid(ent)) return;

	if (sprite != BOX) iconEntity[sprite] = ent;
	if (sprite == BOMB_PLANT) bombEntity[sprite] = entity;
	if (sprite != BOMBSITE_A && sprite != BOMBSITE_B) origin[2] += sprite == BOX ? 35.0 : 25.0;

	set_pev(ent, pev_classname, iconSprite[sprite]);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_iuser1, entity);
	set_pev(entity, pev_iuser1, ent);

	engfunc(EngFunc_SetModel, ent, iconSprite[sprite]);

	fm_set_rendering(ent, kRenderFxNone, 0, 0, 0, kRenderTransAdd, 240);

	set_pev(ent, pev_solid, SOLID_NOT);
	set_pev(ent, pev_movetype, MOVETYPE_NONE);
}

public check_visible(ent, pSet)
{
	if (!pev_valid(ent)) return FMRES_IGNORED;

	static className[32];

	pev(ent, pev_classname, className, charsmax(className));

	if (!check_classname(className)) return FMRES_IGNORED;

	if (!roundStarted) return FMRES_IGNORED;

	forward_return(FMV_CELL, 1);

	return FMRES_SUPERCEDE;
}

public fm_fullpack(es, e, ent, host, hostflags, player, pSet)
{
	if (!is_user_connected(host) || !pev_valid(ent) || !pev_valid(pev(ent, pev_iuser1))) return FMRES_IGNORED;

	static className[32];

	pev(ent, pev_classname, className, charsmax(className));

	if (!check_classname(className)) return FMRES_IGNORED;

	set_es(es, ES_Effects, get_es(es, ES_Effects) | EF_NODRAW);

	if (!roundStarted || !is_user_alive(host)) return FMRES_IGNORED;

	if ((equal(className, iconSprite[BOMBSITE_A]) || equal(className, iconSprite[BOMBSITE_B])) && (!get_bit(host, iconBombSites) || is_valid_ent(bombEntity[BOMB_PLANT]))) return FMRES_IGNORED;
	if ((equal(className, iconSprite[BOMB_PLANT]) || equal(className, iconSprite[BOMB_EXPLODE])) && !get_bit(host, iconPlanted)) return FMRES_IGNORED;
	if (equal(className, iconSprite[BOMB_DROP]) && (!get_bit(host, iconDropped) || playerTeam[host] != 1)) return FMRES_IGNORED;
	if (equal(className, iconSprite[BOX]) && !get_bit(host, iconBox)) return FMRES_IGNORED;

	static Float:hostOrigin[3], Float:targetOrigin[3], Float:middleOirgin[3], Float:wallOffset[3], Float:spriteOffset[3], Float:hitPoint[3], Float:distanceToWall, Float:distance;

	pev(ent, pev_origin, targetOrigin);

	if (!is_in_viewcone(host, targetOrigin)) return FMRES_IGNORED;

	set_es(es, ES_Effects, get_es(es, ES_Effects) & ~EF_NODRAW);

	pev(host, pev_origin, hostOrigin);

	distance = get_distance_f(hostOrigin, targetOrigin) / UNITS_PER_METER;

	#if !defined LITE
	if (distance > 1.0 && distance <= 100.0) set_es(es, ES_Frame, 100.0 - floatround(distance));
	else set_es(es, ES_Frame, 100.0);
	#endif

	xs_vec_sub(targetOrigin, hostOrigin, middleOirgin);

	trace_line(NONE, hostOrigin, targetOrigin, hitPoint);

	distanceToWall = vector_distance(hostOrigin, hitPoint) - 10.0;

	normalize(middleOirgin, wallOffset, distanceToWall);

	xs_vec_add(wallOffset, hostOrigin, spriteOffset);

	if (equal(className, iconSprite[BOMB_DROP]) || equal(className, iconSprite[BOMB_PLANT]) || equal(className, iconSprite[BOMB_EXPLODE])) spriteOffset[2] += 25.0;
	if (equal(className, iconSprite[BOX])) spriteOffset[2] += 35.0;

	set_es(es, ES_Origin, spriteOffset);
	set_es(es, ES_Scale, distance < 10.0 ? 1.0 : floatmin(floatmax(0.3, 0.0025 * distanceToWall), 1.25));

	return FMRES_IGNORED;
}

public change_icons(id, sound)
{
	if (!cod_check_account(id)) return PLUGIN_HANDLED;

	if (!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[64], menu = menu_create("\yUstawienia \rIkon\w:", "change_icons_handle");

	formatex(menuData, charsmax(menuData), "\wBomb \ySite \w[\r%s\w]", get_bit(id, iconBombSites) ? "Wlaczona" : "Wylaczona");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "\wWyrzucona \yBomba \w[\r%s\w]", get_bit(id, iconDropped) ? "Wlaczona" : "Wylaczona");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "\wPodlozona \yBomba \w[\r%s\w]", get_bit(id, iconPlanted) ? "Wlaczona" : "Wylaczona");
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "\wBonusowa \ySkrzynka \w[\r%s\w]", get_bit(id, iconBox) ? "Wlaczona" : "Wylaczona");
	menu_additem(menu, menuData);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public change_icons_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	switch (item) {
		case 0: get_bit(id, iconBombSites) ? rem_bit(id, iconBombSites) : set_bit(id, iconBombSites);
		case 1: get_bit(id, iconDropped) ? rem_bit(id, iconDropped) : set_bit(id, iconDropped);
		case 2: get_bit(id, iconPlanted) ? rem_bit(id, iconPlanted) : set_bit(id, iconPlanted);
		case 3: get_bit(id, iconBox) ? rem_bit(id, iconBox) : set_bit(id, iconBox);
	}

	save_icons(id);

	change_icons(id, 1);

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public save_icons(id)
{
	if (!get_bit(id, dataLoaded) || mapEnd) return PLUGIN_CONTINUE;

	new vaultKey[MAX_NAME], vaultData[16];

	formatex(vaultKey, charsmax(vaultKey), "%s-cod_icons", playerName[id]);
	formatex(vaultData, charsmax(vaultData), "%d %d %d %d", get_bit(id, iconBombSites), get_bit(id, iconDropped), get_bit(id, iconPlanted), get_bit(id, iconBox));

	nvault_set(iconsVault, vaultKey, vaultData);

	return PLUGIN_CONTINUE;
}

public load_icons(id)
{
	if (mapEnd) return PLUGIN_CONTINUE;

	new vaultKey[MAX_NAME], vaultData[16], iconsData[4][4];

	get_user_name(id, playerName[id], charsmax(playerName[]));

	formatex(vaultKey, charsmax(vaultKey), "%s-cod_icons", playerName[id]);

	if (nvault_get(iconsVault, vaultKey, vaultData, charsmax(vaultData))) {
		parse(vaultData, iconsData[0], charsmax(iconsData), iconsData[1], charsmax(iconsData), iconsData[2], charsmax(iconsData), iconsData[3], charsmax(iconsData));

		if (str_to_num(iconsData[0])) set_bit(id, iconBombSites);
		if (str_to_num(iconsData[1])) set_bit(id, iconDropped);
		if (str_to_num(iconsData[2])) set_bit(id, iconPlanted);
		if (str_to_num(iconsData[3])) set_bit(id, iconBox);
	} else {
		set_bit(id, iconBombSites);
		set_bit(id, iconDropped);
		set_bit(id, iconPlanted);
		set_bit(id, iconBox);

		save_icons(id);
	}

	set_bit(id, dataLoaded);

	return PLUGIN_CONTINUE;
}

public _cod_spawn_icon(ent, type)
	spawn_sprite(ent, type);

stock normalize(Float:originIn[3], Float:originOut[3], Float:multiplier)
{
	new Float:fLen = xs_vec_len(originIn);

	xs_vec_copy(originIn, originOut);

	originOut[0] /= fLen, originOut[1] /= fLen, originOut[2] /= fLen;
	originOut[0] *= multiplier, originOut[1] *= multiplier, originOut[2] *= multiplier;
}

stock check_classname(const className[])
{
	for (new i = 0; i < sizeof iconSprite; i++) if (equal(className, iconSprite[i])) return true;

	return false;
}

stock remove_icon(ent, sprite)
{
	if (pev_valid(ent)) {
		remove_entity(ent);

		iconEntity[sprite] = 0;
	}
}
