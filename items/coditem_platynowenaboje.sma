#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Platynowe Naboje"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define NAME        "Platynowe Naboje"
#define DESCRIPTION "Zadajesz o %s wieksze obrazenia"
#define RANDOM_MIN  10
#define RANDOM_MAX  20
#define UPGRADE_MIN -2
#define UPGRADE_MAX 2
#define VALUE_MAX   30

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
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (damageBits & DMG_BULLET) damage += float(itemValue[attacker]);