#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Opaska Terrorysty"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Opaska Terrorysty"
#define DESCRIPTION "Zadajesz %s obrazen wiecej. Masz 50 procent szansy na natychmiastowe zabicie z HE"
#define RANDOM_MIN  6
#define RANDOM_MAX  8
#define UPGRADE_MIN -2
#define UPGRADE_MAX 3

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	cod_give_weapon(id, CSW_HEGRENADE);

	itemValue[id] = value;
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_HEGRENADE);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits & DMG_HEGRENADE && cod_percent_chance(50)) {
		damage = cod_kill_player(attacker, victim, damageBits);
	} else {
		damage += itemValue[attacker];
	}
}