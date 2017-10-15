#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Pakiet Granatow"
#define VERSION "1.0.16"
#define AUTHOR "O'Zone"

#define NAME        "Pakiet Granatow"
#define DESCRIPTION "Dostajesz pelny zestaw granatow"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
{
	cod_give_weapon(id, CSW_FLASHBANG, 2);
	cod_give_weapon(id, CSW_HEGRENADE, 1);
	cod_give_weapon(id, CSW_SMOKEGRENADE, 1);
}

public cod_item_respawn(id, respawn)
{
	cod_give_weapon(id, CSW_FLASHBANG, 2);
	cod_give_weapon(id, CSW_HEGRENADE, 1);
	cod_give_weapon(id, CSW_SMOKEGRENADE, 1);
}
