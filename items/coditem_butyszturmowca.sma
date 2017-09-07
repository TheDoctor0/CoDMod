#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Buty Szturmowca"
#define VERSION "1.0.3"
#define AUTHOR "O'Zone"

#define NAME        "Buty Szturmowca"
#define DESCRIPTION "Nie slychac twoich krokow"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_set_user_footsteps(id, 1, ITEM);