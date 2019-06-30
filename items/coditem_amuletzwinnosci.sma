#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Amulet Zwinnosci"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Amulet Zwinnosci"
#define DESCRIPTION "Dostajesz +%s kondycji"
#define RANDOM_MIN  25
#define RANDOM_MAX  50
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
{
	itemValue[id] = value;

	cod_add_user_bonus_condition(id, itemValue[id]);
}

public cod_item_disabled(id)
	cod_add_user_bonus_condition(id, -itemValue[id]);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
{
	cod_add_user_bonus_condition(id, -itemValue[id]);

	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

	cod_add_user_bonus_condition(id, itemValue[id]);
}