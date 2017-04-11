#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Test"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new item;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item("Test", "Testowy item");
}

public cod_item_enabled(id, value)
	set_bit(id, item);

public cod_item_disabled(id)
	rem_bit(id, item);
