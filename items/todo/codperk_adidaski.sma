#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Buty z Kalkuty"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

new const name[] = "Buty z Kalkuty";
new const description[] = "Dostajesz +%s kondycji oraz nie slychac twoich krokow";

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value == -1 ? random_num(25, 40): value;

	cod_add_user_bonus_condition(id, itemValue[id]);

	cod_set_user_footsteps(id, 1, ITEM);
}

public cod_item_upgrade(id)
{
	cod_add_user_bonus_condition(id, -itemValue[id]);

	itemValue[id] = max(0, itemValue[id] + random_num(-2, 6));

	cod_add_user_bonus_condition(id, itemValue[id]);
}

public cod_item_value(id)
	return itemValue[id];