#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Nano Kamizelka"
#define VERSION "1.0.11"
#define AUTHOR "O'Zone"

#define NAME        "Nano Kamizelka"
#define DESCRIPTION "Jestes odporny na umiejetnosci klas i itemow zadajace obrazenia"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_set_user_resistance(id, true);

public cod_item_disabled(id)
	cod_set_user_resistance(id, false);