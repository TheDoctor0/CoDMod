#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Promien Slonca"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Promien Slonca"
#define DESCRIPTION "Masz 1/%s szansy na oslepienie przeciwnika przy trafieniu"
#define RANDOM_MIN  5
#define RANDOM_MAX  7
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
	cod_random_upgrade(itemValue[id], .valueMin = VALUE_MIN);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits & DMG_BULLET && random_num(1, itemValue[attacker]) == 1) {
		cod_display_fade(victim, 2, 2, 0x0000, 255, 155, 50, 230);
	}
}
