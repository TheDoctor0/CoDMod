#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Porazajace Naboje"
#define VERSION "1.0.12"
#define AUTHOR "O'Zone"

#define NAME        "Porazajace Naboje"
#define DESCRIPTION "Masz 1/%s szansy na zatrzesienie ekranem przeciwnika przy trafieniu"
#define RANDOM_MIN  5
#define RANDOM_MAX  7
#define VALUE_MIN   2

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
	cod_random_upgrade(itemValue[id], .valueMin = VALUE_MIN);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (damageBits == DMG_BULLET && random_num(1, itemValue[attacker]) == 1) cod_screen_shake(victim);