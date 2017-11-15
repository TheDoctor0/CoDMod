#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Kamuflarz"
#define VERSION "1.0.10"
#define AUTHOR "O'Zone"

#define NAME        "Kamuflarz"
#define DESCRIPTION "Twoja widocznosc spada do %s procent"
#define RANDOM_MIN  25
#define RANDOM_MAX  35
#define UPGRADE_MIN -3
#define UPGRADE_MAX 4
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

	cod_set_user_render(id, floatround(255 * (float(itemValue[id]) / 100.0)), ITEM);
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
{
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

	cod_set_user_render(id, floatround(255 * (float(itemValue[id]) / 100.0)), ITEM);
}