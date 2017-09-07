#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Adrenalina"
#define VERSION "1.0.1"
#define AUTHOR "O'Zone"

new const name[] = "Adrenalina";
new const description[] = "Za kazdego fraga dostajesz +%s HP";
new const randomMin = 40;
new const randomMax = 55;
new const upgradeMin = -3;
new const upgradeMax = 6;

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description, randomMin, randomMax);
}

public cod_item_enabled(id, value)
	itemValue[id] = value;

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], upgradeMin, upgradeMax);

public cod_item_value(id)
	return itemValue[id];

public cod_item_kill(killer, victim)
	cod_add_user_health(killer, itemValue[killer]);