#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Wyposazenie Wsparcia"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Wyposazenie Wsparcia"
#define DESCRIPTION "Co runde dostajesz %s rakiety"
#define RANDOM_MIN  1
#define RANDOM_MAX  3

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	cod_set_user_rockets(id, itemValue[id], ITEM);
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
{
	cod_random_upgrade(itemValue[id]);

	cod_set_user_rockets(id, itemValue[id], ITEM);
}
