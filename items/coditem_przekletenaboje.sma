#include <amxmodx>
#include <cod>
#include <fakemeta>

#define PLUGIN "CoD Item Przeklete Naboje"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

new const name[] = "Przeklete Naboje";
new const description[] = "Masz 1/%s szansy na wyrzucenie przeciwnika w powietrze przy trafieniu";

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);
}

public cod_item_enabled(id, value)
	itemValue[id] = value == -1 ? random_num(6, 9): value;

public cod_item_upgrade(id)
	itemValue[id] = max(2, itemValue[id] + random_num(-1, 1));

public cod_item_value(id)
	return itemValue[id] <= 2 ? COD_STOP : itemValue[id];

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