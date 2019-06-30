#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Bezlik Amunicji"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Bezlik Amunicji"
#define DESCRIPTION "Twoja amunicja sie nie konczy"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_set_user_unlimited_ammo(id, true, ITEM);