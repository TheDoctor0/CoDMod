#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Pierscien Skoczka"
#define VERSION "1.0.7"
#define AUTHOR "O'Zone"

#define NAME        "Pierscien Skoczka"
#define DESCRIPTION "Masz %s dodatkowe skoki w powietrzu"
#define RANDOM_MIN  2
#define RANDOM_MAX  3
#define UPGRADE_MIN -1
#define UPGRADE_MAX 1

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	cod_set_user_multijumps(id, itemValue[id], ITEM);
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
{
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);

	cod_set_user_multijumps(id, itemValue[id], ITEM);
}