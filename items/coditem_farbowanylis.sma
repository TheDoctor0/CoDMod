#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Farbowany Lis"
#define VERSION "1.0.13"
#define AUTHOR "O'Zone"

#define NAME        "Farbowany Lis"
#define DESCRIPTION "Masz 1/%s szansy na odrodzenie na respie wroga. Posiadasz ubranie wroga."
#define RANDOM_MIN  4
#define RANDOM_MAX  6
#define VALUE_MIN   2

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	cod_set_user_model(id, true, ITEM);
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], .valueMin = VALUE_MIN);

public cod_item_spawned(id)
	if (random_num(1, itemValue[id]) == 1) cod_teleport_to_spawn(id, 1);