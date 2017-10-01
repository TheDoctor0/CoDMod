#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Ogranicznik Rozrzutu"
#define VERSION "1.0.4"
#define AUTHOR "O'Zone"

#define NAME        "Ogranicznik Rozrzutu"
#define DESCRIPTION "Masz zmniejszony rozrzut we wszystkich broniach"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_set_user_recoil_reducer(id, true, ITEM);