#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Adrenalina"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Adrenalina"
#define DESCRIPTION "Za kazdego fraga dostajesz +%s HP"
#define RANDOM_MIN  40
#define RANDOM_MAX  60
#define UPGRADE_MIN -3
#define UPGRADE_MAX 6
#define VALUE_MAX   100

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
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

public cod_item_kill(killer, victim, hitPlace)
	cod_add_user_health(killer, itemValue[killer]);