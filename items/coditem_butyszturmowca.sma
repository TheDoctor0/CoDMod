#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Buty Szturmowca"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

new const name[] = "Buty Szturmowca";
new const description[] = "Nie slychac twoich krokow";

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);
}

public cod_item_enabled(id, value)
	cod_set_user_footsteps(id, 1, ITEM);