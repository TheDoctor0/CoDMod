#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Zestaw Powiekszony"
#define VERSION "1.0.16"
#define AUTHOR "O'Zone"

#define NAME        "Zestaw Powiekszony"
#define DESCRIPTION "Dostajesz po %s granatow z kazdego typu"
#define RANDOM_MIN  3
#define RANDOM_MAX  5
#define VALUE_MAX   10

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	cod_give_weapon(id, CSW_FLASHBANG, itemValue[id]);
	cod_give_weapon(id, CSW_HEGRENADE, itemValue[id]);
	cod_give_weapon(id, CSW_SMOKEGRENADE, itemValue[id]);
}

public cod_item_spawned(id, respawn)
{
	cod_give_weapon(id, CSW_FLASHBANG, itemValue[id]);
	cod_give_weapon(id, CSW_HEGRENADE, itemValue[id]);
	cod_give_weapon(id, CSW_SMOKEGRENADE, itemValue[id]);
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], .valueMax = VALUE_MAX);
