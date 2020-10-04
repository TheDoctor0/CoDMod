#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Class Lowca"
#define AUTHOR "O'Zone"

#define NAME         "Lowca"
#define DESCRIPTION  "Dostaje kusze (R na nozu) i 10 beltow, ktore zabijaja po trafieniu. Ma dwie miny."
#define FRACTION     "Premium"
#define WEAPONS      (1<<CSW_AK47)|(1<<CSW_FIVESEVEN)
#define HEALTH       15
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      20
#define CONDITION    5
#define FLAG         ADMIN_LEVEL_D

#define BELTS        10

new const classModels[][] = { "models/CoDMod/crossbow.mdl", "models/CoDMod/crossbow2.mdl", "models/CoDMod/belt.mdl" };

enum { V_CROSSBOW, P_CROSSBOW, BELT };

new crossbowBelts[MAX_PLAYERS + 1], lastCrossbowBelt[MAX_PLAYERS + 1], crossbowActive, classActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION, FLAG);

	register_touch("belt", "*" , "touch_belt");

	register_forward(FM_EmitSound, "sound_emit");
}

public plugin_precache()
{
	for (new i = 0; i < sizeof(classModels); i++) {
		precache_model(classModels[i]);
	}
}

public client_disconnected(id)
	cod_remove_ents(id, "belt");

public cod_class_enabled(id, promotion)
{
	cod_set_user_mines(id, 2, CLASS);

	set_bit(id, classActive);

	crossbowBelts[id] = BELTS;
}

public cod_class_disabled(id)
{
	rem_bit(id, classActive);
	rem_bit(id, crossbowActive);

	crossbowBelts[id] = 0;
}

public cod_class_spawned(id, respawn)
{
	rem_bit(id, crossbowActive);

	if (!respawn) {
		crossbowBelts[id] = BELTS;
	}
}

public cod_class_skill_used(id)
	cod_use_user_mine(id);

public cod_new_round()
	cod_remove_ents(0, "belt");

public cod_weapon_deploy(id, weapon, ent)
	rem_bit(id, crossbowActive);

public cod_cmd_start(id, button, oldButton, flags, playerState)
{
	if (!get_bit(id, classActive)) return;

	if (!get_bit(id, crossbowActive) && button & IN_RELOAD && !(oldButton & IN_RELOAD) && cod_get_user_weapon(id) == CSW_KNIFE) {
		set_bit(id, crossbowActive);

		entity_set_string(id, EV_SZ_viewmodel, classModels[V_CROSSBOW]);
		entity_set_string(id, EV_SZ_weaponmodel, classModels[P_CROSSBOW]);
	}

	if (button & IN_ATTACK && !(oldButton & IN_ATTACK)) {
		static modelName[32];

		entity_get_string(id, EV_SZ_viewmodel, modelName, charsmax(modelName));

		if (equal(modelName, classModels[V_CROSSBOW])) shoot_belt(id);
	}
}

public shoot_belt(id)
{
	if (!is_user_alive(id)) return;

	if (!crossbowBelts[id]) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Juz wykorzystales wszystkie belty!");

		return;
	}

	if (!get_bit(id, crossbowActive)) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Przeladuj kusze na R!");

		return;
	}

	if (lastCrossbowBelt[id] + 3.0 > get_gametime()) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Belt mozesz wystrzelic raz na 3 sekundy!");

		return;
	}

	rem_bit(id, crossbowActive);

	lastCrossbowBelt[id] = floatround(get_gametime());
	crossbowBelts[id]--;

	new Float:origin[3], Float:angle[3], Float:velocity[3];

	entity_get_vector(id, EV_VEC_v_angle, angle);
	entity_get_vector(id, EV_VEC_origin, origin);

	new ent = create_entity("info_target");

	entity_set_string(ent, EV_SZ_classname, "belt");
	entity_set_model(ent, classModels[BELT]);

	angle[0] *= -1.0;

	entity_set_origin(ent, origin);
	entity_set_vector(ent, EV_VEC_angles, angle);
	entity_set_int(ent, EV_INT_effects, 2);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_edict(ent, EV_ENT_owner, id);

	set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 56);

	VelocityByAim(id, 1500, velocity);

	entity_set_vector(ent, EV_VEC_velocity, velocity);

	cod_emit_sound(id, SOUND_DEPLOY, VOLUME_NORMAL, CHAN_ITEM);
}

public touch_belt(ent)
{
	if (!is_valid_ent(ent)) return;

	new owner = entity_get_edict(ent, EV_ENT_owner), entList[33], playersFound = find_sphere_class(ent, "player", 15.0, entList, 32), player;

	for (new i = 0; i < playersFound; i++) {
		player = entList[i];

		if (!is_user_alive(player) || get_user_team(owner) == get_user_team(player)) continue;

		cod_kill_player(owner, player, DMG_CODSKILL);
	}

	remove_entity(ent);
}

public sound_emit(ent, channel, const sample[])
{
	if (!is_user_alive(ent) || !get_bit(ent, classActive)) return FMRES_IGNORED;

	static modelName[32];

	entity_get_string(ent, EV_SZ_viewmodel, modelName, charsmax(modelName));

	if (equal(modelName, classModels[V_CROSSBOW])) {
		if (equal(sample,"weapons/knife_slash1.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_slash2.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_deploy1.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_hitwall1.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_hit1.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_hit2.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_hit3.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_hit4.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_stab.wav")) return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}