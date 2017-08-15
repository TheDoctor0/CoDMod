#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Adrenalina"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

new const name[] = "Adrenalina";
new const description[] = "Za kazdego fraga dostajesz +%s HP";

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);
}

public cod_item_enabled(id, value)
	itemValue[id] = value == -1 ? random_num(35, 65): value;

public cod_item_upgrade(id)
	itemValue[id] = max(0, itemValue[id] + random_num(-4, 9));

public cod_item_value(id)
	return itemValue[id];

public cod_item_kill(killer, victim)
	cod_add_user_health(killer, itemValue[killer]);