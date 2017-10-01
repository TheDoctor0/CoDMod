#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Promien Slonca"
#define VERSION "1.0.9"
#define AUTHOR "O'Zone"

#define NAME        "Promien Slonca"
#define DESCRIPTION "Masz 1/%s szansy na oslepienie przeciwnika przy trafieniu"
#define RANDOM_MIN  4
#define RANDOM_MAX  6
#define UPGRADE_MIN -1
#define UPGRADE_MAX 1
#define VALUE_MIN 2

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
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, VALUE_MIN);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if(damageBits & DMG_BULLET && random_num(1, itemValue[attacker]) == 1) cod_display_fade(victim, 1<<14, 1<<14, 1<<16, 255, 155, 50, 230);