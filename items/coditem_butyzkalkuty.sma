#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Buty z Kalkuty"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define RANDOM_MIN 25
#define RANDOM_MAX 40
#define UPGRADE_MIN -2
#define UPGRADE_MAX 5
#define VALUE_MIN 3

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
	itemValue[id] = value == RANDOM ? random_num(RANDOM_MIN, RANDOM_MAX): value;

	cod_add_user_bonus_condition(id, itemValue[id]);

	cod_set_user_footsteps(id, 1, ITEM);
}

public cod_item_disabled(id)
	cod_add_user_bonus_condition(id, -itemValue[id]);

public cod_item_upgrade(id)
{
	if(itemValue[id] <= VALUE_MIN && VALUE_MIN > 0) return COD_STOP;
	
	cod_add_user_bonus_condition(id, -itemValue[id]);

	itemValue[id] = max(VALUE_MIN, itemValue[id] + random_num(UPGRADE_MIN, UPGRADE_MAX));

	cod_add_user_bonus_condition(id, itemValue[id]);
}

public cod_item_value(id)
	return itemValue[id];