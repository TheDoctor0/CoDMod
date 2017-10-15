#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Dobra Krowka"
#define VERSION "1.0.17"
#define AUTHOR "O'Zone"

#define NAME        "Dobra Krowka"
#define DESCRIPTION "Dostajesz zestaw granatow i Krowe (M249), z ktorej zadajesz o %s zwiekszone obrazenia"
#define RANDOM_MIN  6
#define RANDOM_MAX  10
#define UPGRADE_MIN -1
#define UPGRADE_MAX 1
#define VALUE_MAX   20

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	cod_give_weapon(id, CSW_M249);
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_M249);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (weapon == CSW_M249 && damageBits & DMG_BULLET) damage += float(itemValue[attacker]);
