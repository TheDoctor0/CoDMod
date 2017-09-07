#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Kucacz"
#define VERSION "1.0.2"
#define AUTHOR "O'Zone"

#define NAME        "Kucacz"
#define DESCRIPTION "Gdy kucasz jestes praktycznie niewidzialny"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_set_user_render(id, 20, ITEM, RENDER_DUCK);