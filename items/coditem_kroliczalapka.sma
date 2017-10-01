#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Krolicza Lapka"
#define VERSION "1.0.8"
#define AUTHOR "O'Zone"

#define NAME        "Krolicza Lapka"
#define DESCRIPTION "Masz automatycznego BunnyHopa - przytrzymaj spacje"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_set_user_bunnyhop(id, true, ITEM);