#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Notatki Kapitana"
#define VERSION "1.0.12"
#define AUTHOR "O'Zone"

#define NAME        "Notatki Kapitana"
#define DESCRIPTION "Masz 1/%s szansy na odbicie pocisku po trafieniu w ciebie"
#define RANDOM_MIN  2
#define RANDOM_MAX  3
#define VALUE_MAX   5

new itemValue[MAX_PLAYERS + 1], itemUse[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
	itemUse[id] = itemValue[id] = value;

public cod_item_spawned(id, respawn)
	if (!respawn) itemUse[id] = itemValue[id];

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], .valueMax = VALUE_MAX);

public cod_item_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits == DMG_BULLET && random_num(1, itemValue[victim]) == 1 && itemUse[victim]) {
		damage = COD_BLOCK;

		itemUse[victim]--;
	}
}
