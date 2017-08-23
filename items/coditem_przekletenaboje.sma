#include <amxmodx>
#include <cod>
#include <fakemeta>

#define PLUGIN "CoD Item Przeklete Naboje"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define RANDOM_MIN 6
#define RANDOM_MAX 9
#define UPGRADE_MIN -1
#define UPGRADE_MAX 1
#define VALUE_MIN 3

new const name[] = "Przeklete Naboje";
new const description[] = "Masz 1/%s szansy na wyrzucenie przeciwnika w powietrze przy trafieniu";

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);
}

public cod_item_enabled(id, value)
	itemValue[id] = value == RANDOM ? random_num(RANDOM_MIN, RANDOM_MAX): value;

public cod_item_upgrade(id)
{
	if(itemValue[id] <= VALUE_MIN && VALUE_MIN > 0) return COD_STOP;
	
	itemValue[id] = max(VALUE_MIN, itemValue[id] + random_num(UPGRADE_MIN, UPGRADE_MAX));
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(damageBits == DMG_BULLET && random_num(1, itemValue[attacker]) == 1)
	{
		new Float:velocity[3];

		velocity[0] = 0.0;
		velocity[1] = 0.0;
		velocity[2] = 0.0;

		set_pev(victim, pev_velocity, velocity);

		velocity[2] = random_float(400.0, 600.0);

		set_pev(victim, pev_velocity, velocity);
	}
}