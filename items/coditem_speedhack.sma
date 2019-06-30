#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Speedhack"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Speedhack"
#define DESCRIPTION "Dostajesz %s kondycji"
#define RANDOM_MIN  75
#define RANDOM_MAX  100
#define UPGRADE_MIN -5
#define UPGRADE_MAX 7
#define VALUE_MAX   150

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	cod_add_user_bonus_condition(id, itemValue[id]);
}

public cod_item_disabled(id)
	cod_add_user_bonus_condition(id, -itemValue[id]);

public cod_item_upgrade(id)
{
	cod_add_user_bonus_condition(id, -itemValue[id]);

	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

	cod_add_user_bonus_condition(id, itemValue[id]);
}

public cod_item_value(id)
	return itemValue[id];
