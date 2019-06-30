#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Zabojcze MP5"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Zabojcze MP5"
#define DESCRIPTION "Dostajesz MP5, z ktorego zadajesz +%s obrazen i masz 1/2 na uzupelnienie magazynka po zabiciu"
#define RANDOM_MIN  7
#define RANDOM_MAX  12
#define UPGRADE_MIN -2
#define UPGRADE_MAX 2
#define VALUE_MAX   20

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	cod_give_weapon(id, CSW_MP5NAVY);

	itemValue[id] = value;
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_MP5NAVY);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

public cod_item_kill(killer, victim, hitPlace)
{
	if (cod_percent_chance(50)) {
		cod_refill_ammo(killer);
	}
}

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits & DMG_BULLET && weapon == CSW_MP5NAVY) {
		damage += float(itemValue[attacker]);
	}
}
