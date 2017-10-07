#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Duch"
#define VERSION "1.0.9"
#define AUTHOR "O'Zone"

#define NAME        "Duch"
#define DESCRIPTION "Jestes calkowicie niewidzialny i nie slychac twoich krokow, ale masz tylko 1 HP"

new itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);

	register_event("Health", "Health", "be");
}

public cod_item_enabled(id, value)
{
	cod_set_user_render(id, 0, ITEM);

	cod_set_user_footsteps(id, true, ITEM);

	cod_set_user_health(id, 1);

	set_bit(id, itemActive);
}

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public cod_item_spawned(id)
	cod_set_user_health(id, 1);

public Health(id)
	if (get_bit(id, itemActive) && is_user_alive(id) && read_data(1) > 1) cod_set_user_health(id, 1);
