#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Morfina"
#define VERSION "1.0.7"
#define AUTHOR "O'Zone"

#define NAME        "Morfina"
#define DESCRIPTION "Masz 1/%s szansy na odrodzenie po smierci"
#define RANDOM_MIN  3
#define RANDOM_MAX  5
#define UPGRADE_MIN -1
#define UPGRADE_MAX 1
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
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, VALUE_MIN);

public cod_item_killed(id)
	cod_respawn_player(id);