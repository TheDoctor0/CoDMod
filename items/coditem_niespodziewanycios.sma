#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <cod>

#define PLUGIN "CoD Item Niespodziewany Cios"
#define VERSION "1.2"
#define AUTHOR "O'Zone"

#define NAME        "Niespodziewany Cios"
#define DESCRIPTION "Przy trafieniu masz 1/%s szansy na teleport za gracza"
#define RANDOM_MIN  5
#define RANDOM_MAX  7
#define VALUE_MIN 3

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
	itemValue[id] = value;

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id],.valueMin = VALUE_MIN);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits & DMG_BULLET && random_num(1, itemValue[attacker]) == 1) {
		teleport_behind(attacker, victim);
	}
}

public teleport_behind(id, target)
{
	if (!is_user_alive(id) || !is_user_alive(target)) return;

	new Float:vector[3], Float:origin[3], Float:oldOrigin[3], Float:newOrigin[3], Float:length;

	velocity_by_aim(target, 1, vector);

	length = floatsqroot(vector[0] * vector[0] + vector[1] * vector[1]);

	pev(target, pev_origin, origin);
	pev(id, pev_origin, oldOrigin);

	newOrigin[0] = origin[0] - vector[0] * 50.0 / length;
	newOrigin[1] = origin[1] - vector[1] * 50.0 / length;
	newOrigin[2] = origin[2] + 5.0;

	set_pev(id, pev_origin, newOrigin);

	if (is_player_stuck(id)) {
		set_pev(id, pev_origin, oldOrigin);

		return;
	}

	xs_vec_set(newOrigin, -newOrigin[0], -newOrigin[1], -newOrigin[2]);
	xs_vec_add(newOrigin, origin, newOrigin);
	vector_to_angle(newOrigin, newOrigin);

	set_pev(id, pev_angles, newOrigin);
	set_pev(id, pev_fixangle, 1);
}

stock bool:is_player_stuck(id)
{
	static Float:origin[3];

	pev(id, pev_origin, origin);

	engfunc(EngFunc_TraceHull, origin, origin, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0);

	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen)) return true;

	return false;
}