#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Samobojca"
#define VERSION "1.0.10"
#define AUTHOR "O'Zone"

#define NAME        "Samobojca"
#define DESCRIPTION "Natychmiastowa smierc twoja i wrogow w twoim bliskim otoczeniu"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_skill_used(id)
	cod_make_explosion(id, 250, 1, 250.0, 500.0, 0.0, 1);
