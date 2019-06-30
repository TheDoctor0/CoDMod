#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item MAC10 Ducha"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define NAME        "MAC10 Ducha"
#define DESCRIPTION "Dostajesz MAC10, z ktorym jestes niemal niewidzialny"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
{
	cod_give_weapon(id, CSW_MAC10);

	cod_set_user_render(id, 35, ITEM, RENDER_ALWAYS, 1<<CSW_MAC10);
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_MAC10);