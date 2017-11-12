#include <amxmodx>
#include <cod>
#include <fakemeta>

#define PLUGIN "CoD Item Naboje Lowcy Glow"
#define VERSION "1.0.10"
#define AUTHOR "O'Zone"

#define NAME        "Naboje Lowcy Glow"
#define DESCRIPTION "Zadajesz o %s procent wieksze obrazenia przy trafieniu w glowe"
#define RANDOM_MIN  50
#define RANDOM_MAX  75
#define UPGRADE_MIN -3
#define UPGRADE_MAX 5
#define VALUE_MAX   100

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
	itemValue[id] = value;

public cod_item_upgrade(id)
	return cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

public cod_item_value(id)
	return itemValue[id];

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (damageBits & DMG_BULLET && hitPlace & HIT_HEAD) damage *= (1.0 + (itemValue[attacker] / 100.0));