#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Autodestrukcja"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Autodestrukcja"
#define DESCRIPTION "Natychmiastowa smierc twoja i wrogow w twoim bliskim otoczeniu"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_skill_used(id)
	cod_make_explosion(id, 300, 1, 300.0, 999.9, 0.0, 1);
