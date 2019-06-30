#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <cod>

#define PLUGIN "CoD Class Replikant"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Replikant"
#define DESCRIPTION  "Ma trzy repliki odbijajace polowe obrazen, podwojny skok i teleport."
#define FRACTION     "Premium"
#define WEAPONS      (1<<CSW_AK47)|(1<<CSW_DEAGLE)
#define HEALTH       25
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      10
#define CONDITION    15
#define FLAG         ADMIN_LEVEL_D

#define REPLICAS     3

new itemLastUse[MAX_PLAYERS + 1], itemUse[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION, FLAG);

	RegisterHam(Ham_TakeDamage, "info_target", "take_damage");
}

public client_disconnected(id)
	cod_remove_ents(id, "replica");

public cod_class_enabled(id, promotion)
{
	cod_set_user_teleports(id, 1, CLASS);
	cod_set_user_multijumps(id, 1, CLASS);

	itemUse[id] = REPLICAS;
}

public cod_class_spawned(id, respawn)
{
	if (!respawn) {
		itemUse[id] = REPLICAS;
	}
}

public cod_new_round()
	cod_remove_ents(0, "replica");

public cod_class_skill_used(id)
{
	if (!itemUse[id]) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Juz wykorzystales wszystkie repliki!");

		return PLUGIN_CONTINUE;
	}

	if (itemLastUse[id] + 5.0 > get_gametime()) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Replike mozesz postawic raz na 5 sekund!");

		return PLUGIN_CONTINUE;
	}

	if (!(pev(id, pev_flags) & FL_ONGROUND)) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Musisz stac na podlozu, zeby postawic replike!");

		return PLUGIN_CONTINUE;
	}

	new Float:entOrigin[3];

	if (!get_origin_in_distance(id, entOrigin, 45.0)) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Musisz odsunac sie nieco dalej od przeszkody, aby postawic replike!");

		return PLUGIN_CONTINUE;
	}

	new entModel[64], playerModel[32], Float:entAngle[3], entSequence = entity_get_int(id, EV_INT_gaitsequence);

	entSequence = (entSequence == 3 || entSequence == 4) ? 1 : entSequence;

	cs_get_user_model(id, playerModel, charsmax(playerModel));

	format(entModel, charsmax(playerModel), "models/player/%s/%s.mdl", playerModel, playerModel);

	entity_get_vector(id, EV_VEC_angles, entAngle);

	entAngle[0] = 0.0;
	entOrigin[2] -= distance_to_floor(id, entOrigin);

	new ent = create_entity("info_target");

	entity_set_string(ent, EV_SZ_classname, "replica");
	entity_set_model(ent, entModel);
	entity_set_vector(ent, EV_VEC_origin, entOrigin);
	entity_set_vector(ent, EV_VEC_angles, entAngle);
	entity_set_vector(ent, EV_VEC_v_angle, entAngle);
	entity_set_int(ent, EV_INT_sequence, entSequence);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_float(ent, EV_FL_health, 300.0);
	entity_set_float(ent, EV_FL_takedamage, DAMAGE_YES);
	entity_set_size(ent, Float:{-16.0, -16.0, -36.0}, Float:{16.0, 16.0, 36.0});
	entity_set_int(ent, EV_INT_iuser1, id);

	if (!cod_is_enough_space(ent, 150.0)) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Nie mozesz postawic repliki w przejsciu!");

		remove_entity(ent);

		return PLUGIN_CONTINUE;
	}

	itemLastUse[id] = floatround(get_gametime());
	itemUse[id]--;

	emit_sound(id, CHAN_WEAPON, codSounds[SOUND_ACTIVATE], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_CONTINUE;
}

public take_damage(victim, inflictor, attacker, Float:damage, damageBits)
{
	if (!is_user_alive(attacker)) return HAM_IGNORED;

	new className[32];

	entity_get_string(victim, EV_SZ_classname, className, charsmax(className));

	if (!equal(className, "replica")) return HAM_IGNORED;

	new owner = entity_get_int(victim, EV_INT_iuser1);

	if (get_user_team(owner) == get_user_team(attacker)) return HAM_SUPERCEDE;

	new itemName[32], bool:knifeUsed = cod_get_user_weapon(attacker) == CSW_KNIFE;

	cod_get_user_item_name(attacker, itemName, charsmax(itemName));

	if (equal(itemName, "Pogromca Replik")) {
		damage *= 2;
	} else if (!knifeUsed) {
		cod_inflict_damage(owner, attacker, damage * 0.5, 0.0, damageBits);
	}

	if (damage > entity_get_float(victim, EV_FL_health)) {
		if (!knifeUsed) {
			cod_make_explosion(victim, 190, 1);
		} else {
			cod_make_explosion(victim, 190, 1, 190.0, 50.0, 0.0);
		}
	}

	return HAM_IGNORED;
}

stock get_origin_in_distance(id, Float:origin[3], Float:distance)
{
	new Float:playerAngle[3], Float:playerOrigin[3], trace;

	entity_get_vector(id, EV_VEC_origin, playerOrigin);
	entity_get_vector(id, EV_VEC_v_angle, playerAngle);

	playerAngle[0] *= -1;

	origin[0] = playerOrigin[0] + distance * floatcos(playerAngle[1], degrees);
	origin[1] = playerOrigin[1] + distance * floatsin(playerAngle[1], degrees);
	origin[2] = playerOrigin[2];

	engfunc(EngFunc_TraceHull, origin, origin, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, trace);

	if (engfunc(EngFunc_PointContents, origin) != CONTENTS_EMPTY || get_tr2(trace, TR_StartSolid) || get_tr2(trace, TR_AllSolid)) return false;

	return true;
}

stock Float:distance_to_floor(id, Float:origin[3])
{
	new Float:start[3], Float:end[3];

	start[0] = origin[0];
	start[1] = origin[1];
	start[2] = -8191.0;

	engfunc(EngFunc_TraceLine, origin, start, 1, 0, 0);

	get_tr2(0, TR_vecEndPos, end);

	start[2] = origin[2];

	return floatmax(0.0, origin[2] - end[2] - (pev(id, pev_flags) & FL_DUCKING ? 18.0 : 36.0));
}