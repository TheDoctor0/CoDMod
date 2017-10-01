#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Tajemnica Komandosa"
#define VERSION "1.0.6"
#define AUTHOR "O'Zone"

#define NAME        "Tajemnica Komandosa"
#define DESCRIPTION "Dostajesz +%s kondycji i +25 zdrowia"
#define RANDOM_MIN  25
#define RANDOM_MAX  40
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
	cod_add_user_bonus_health(id, 25);
}

public cod_item_disabled(id)
{
	cod_add_user_bonus_condition(id, -itemValue[id]);
	cod_add_user_bonus_health(id, -25);
}

public cod_item_upgrade(id)
{
	cod_add_user_bonus_condition(id, -itemValue[id]);

	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, _, VALUE_MAX);

	cod_add_user_bonus_condition(id, itemValue[id]);
}

public cod_item_value(id)
	return itemValue[id];