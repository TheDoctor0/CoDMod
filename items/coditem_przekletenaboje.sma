#include <amxmodx>
#include <cod>
#include <fakemeta>

#define PLUGIN "CoD Item Przeklete Naboje"
#define VERSION "1.0.6"
#define AUTHOR "O'Zone"

#define NAME        "Przeklete Naboje"
#define DESCRIPTION "Masz 1/%s szansy na wyrzucenie przeciwnika w powietrze przy trafieniu"
#define RANDOM_MIN  6
#define RANDOM_MAX  9
#define UPGRADE_MIN -1
#define UPGRADE_MAX 1
#define VALUE_MIN   3

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
	itemValue[id] = value;

public cod_item_upgrade(id)
	return cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, VALUE_MIN);

public cod_item_value(id)
	return itemValue[id];

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(damageBits == DMG_BULLET && random_num(1, itemValue[attacker]) == 1) {
		new Float:velocity[3];

		velocity[0] = 0.0;
		velocity[1] = 0.0;
		velocity[2] = 0.0;

		set_pev(victim, pev_velocity, velocity);

		velocity[2] = random_float(400.0, 600.0);

		set_pev(victim, pev_velocity, velocity);
	}
}