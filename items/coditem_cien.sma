#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Cien"
#define VERSION "1.0.9"
#define AUTHOR "O'Zone"

#define NAME        "Cien"
#define DESCRIPTION "Jestes calkowicie niewidzialny i nie slychac twoich krokow, ale masz tylko 1 HP"

#define TASK_HEALTH 98372

new itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
{
	cod_set_user_render(id, 0, ITEM);

	cod_set_user_footsteps(id, true, ITEM);

	cod_set_user_health(id, 1);

	set_bit(id, itemActive);

	set_task(0.1, "set_health", id + TASK_HEALTH, .flags = "b");
}

public cod_item_disabled(id)
{
	rem_bit(id, itemActive);

	remove_task(id + TASK_HEALTH);
}

public cod_item_spawned(id)
	cod_set_user_health(id, 1);

public set_health(id)
{
	id -= TASK_HEALTH;
	
	if (get_bit(id, itemActive) && get_user_health(id) > 1) cod_set_user_health(id, 1);
}
