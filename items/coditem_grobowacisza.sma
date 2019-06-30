#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Grobowa Cisza"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Grobowa Cisza"
#define DESCRIPTION "Po smierci wybuchasz zadajac %s (+int) obrazen wrogom w poblizu"
#define RANDOM_MIN  150
#define RANDOM_MAX  175
#define UPGRADE_MIN -5
#define UPGRADE_MAX 7

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
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);

public cod_item_killed(killer, victim, hitPlace)
	cod_make_explosion(victim, 250, 1, 250.0, float(itemValue[victim]), 0.5);
