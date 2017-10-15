#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Mocne AK47"
#define VERSION "1.0.10"
#define AUTHOR "O'Zone"

#define NAME        "Mocne AK47"
#define DESCRIPTION "Dostajesz AK47, z ktorego zadajesz o %s wieksze obrazenia"
#define RANDOM_MIN  8
#define RANDOM_MAX  13
#define UPGRADE_MIN -2
#define UPGRADE_MAX 2
#define VALUE_MAX   25

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	cod_give_weapon(id, CSW_AK47);

	itemValue[id] = value;
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_AK47);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (damageBits & DMG_BULLET && weapon == CSW_AK47) damage += float(itemValue[attacker]);
