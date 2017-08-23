#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Duch"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

new const name[] = "Duch";
new const description[] = "Jestes calkowicie niewidzialny, ale masz 1 HP. Dodatkowo masz podwojny skok";

new hasItem;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);

	register_event("Health", "Health", "be");
}

public cod_item_enabled(id, value)
{
	cod_set_user_render(id, 0, ITEM, RENDER_ALWAYS);

	cod_set_user_multijumps(id, 1, ITEM);

	cod_set_user_health(id, 1);

	set_bit(id, hasItem);
}

public cod_item_disabled(id)
	rem_bit(id, hasItem);

public Health(id)
	if(get_bit(id, has) && is_user_alive(id) && read_data(1) > 1) cod_set_user_health(id, 1);