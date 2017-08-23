#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Adrenalina"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define RANDOM_MIN 35
#define RANDOM_MAX 55
#define UPGRADE_MIN -3
#define UPGRADE_MAX 6
#define VALUE_MIN 0

new const name[] = "Adrenalina";
new const description[] = "Za kazdego fraga dostajesz +%s HP";

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);
}

public cod_item_enabled(id, value)
	itemValue[id] = value == RANDOM ? random_num(RANDOM_MIN, RANDOM_MAX): value;

public cod_item_upgrade(id)
{
	if(itemValue[id] <= VALUE_MIN && VALUE_MIN > 0) return COD_STOP;
	
	itemValue[id] = max(VALUE_MIN, itemValue[id] + random_num(UPGRADE_MIN, UPGRADE_MAX));
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_kill(killer, victim)
	cod_add_user_health(killer, itemValue[killer]);