#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Item Atak od tylu"
#define VERSION "1.0.12"
#define AUTHOR "O'Zone"

#define NAME        "Atak od tylu"
#define DESCRIPTION "Przy trafieniu masz 1/%s szansy na teleport za gracza"
#define RANDOM_MIN  6
#define RANDOM_MAX  7
#define UPGRADE_MIN -1
#define UPGRADE_MAX 1
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
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, VALUE_MIN);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(damageBits & DMG_BULLET && random_num(1, itemValue[attacker]) == 1) {
		new Float:origin[3], Float:oldOrigin[3], Float:vector[3];

		pev(attacker, pev_origin, oldOrigin);
		pev(victim, pev_origin, origin);
		pev(victim, pev_v_angle, vector); 

		vector[2] = -vector[2];
		 
		angle_vector(vector, ANGLEVECTOR_FORWARD, vector);
	 
		vector[0] *= 50.0;
		vector[1] *= 50.0;
		vector[2] *= 50.0;

		origin[0] += vector[0];
		origin[1] += vector[1] - 125.0;
		origin[2] += vector[2] + 20.0;

		set_pev(attacker, pev_origin, origin);

		if(is_player_stuck(attacker)) set_pev(attacker, pev_origin, oldOrigin);
	}
}

stock bool:is_player_stuck(id) 
{
	static Float:origin[3];

	pev(id, pev_origin, origin);

	engfunc(EngFunc_TraceHull, origin, origin, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0);

	if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen)) return true;

	return false;
}