#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Dawka LSD"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Dawka LSD"
#define DESCRIPTION "Dostajesz +%s do kazdej statystyki"
#define RANDOM_MIN  15
#define RANDOM_MAX  25
#define UPGRADE_MIN -2
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

	cod_add_user_bonus_health(id, itemValue[id]);
	cod_add_user_bonus_intelligence(id, itemValue[id]);
	cod_add_user_bonus_strength(id, itemValue[id]);
	cod_add_user_bonus_stamina(id, itemValue[id]);
	cod_add_user_bonus_condition(id, itemValue[id]);
}

public cod_item_disabled(id)
{
	cod_add_user_bonus_health(id, -itemValue[id]);
	cod_add_user_bonus_intelligence(id, -itemValue[id]);
	cod_add_user_bonus_strength(id, -itemValue[id]);
	cod_add_user_bonus_stamina(id, -itemValue[id]);
	cod_add_user_bonus_condition(id, -itemValue[id]);
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
{
	cod_add_user_bonus_health(id, -itemValue[id]);
	cod_add_user_bonus_intelligence(id, -itemValue[id]);
	cod_add_user_bonus_strength(id, -itemValue[id]);
	cod_add_user_bonus_stamina(id, -itemValue[id]);
	cod_add_user_bonus_condition(id, -itemValue[id]);

	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

	cod_add_user_bonus_health(id, itemValue[id]);
	cod_add_user_bonus_intelligence(id, itemValue[id]);
	cod_add_user_bonus_strength(id, itemValue[id]);
	cod_add_user_bonus_stamina(id, itemValue[id]);
	cod_add_user_bonus_condition(id, itemValue[id]);
}