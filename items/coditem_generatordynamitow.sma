#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Generator Dynamitow"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define NAME        "Generator Dynamitow"
#define DESCRIPTION "Co %s sekund dostajesz dynamit."
#define RANDOM_MIN  10
#define RANDOM_MAX  15
#define UPGRADE_MIN -3
#define UPGRADE_MAX 2

#define TASK_ITEM 57842

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	remove_task(id + TASK_ITEM);

	set_task(float(itemValue[id]), "generate_item", id + TASK_ITEM, .flags = "b");

	itemValue[id] = value;
}

public cod_item_disabled(id)
	remove_task(id + TASK_ITEM);

public cod_item_upgrade(id)
{
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);

	remove_task(id + TASK_ITEM);

	set_task(float(itemValue[id]), "generate_item", id + TASK_ITEM, .flags = "b");
}
	
public cod_item_value(id)
	return itemValue[id];

public cod_item_spawned(id, respawn)
{
	cod_set_user_dynamites(id, 0, ITEM);

	remove_task(id + TASK_ITEM);

	set_task(float(itemValue[id]), "generate_item", id + TASK_ITEM, .flags = "b");
}

public generate_item(id)
{
	id -= TASK_ITEM;

	cod_add_user_dynamites(id, 1, ITEM);
}