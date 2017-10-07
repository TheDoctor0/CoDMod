#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Item Sokole Oko"
#define VERSION "1.0.11"
#define AUTHOR "O'Zone"

#define NAME        "Sokole Oko"
#define DESCRIPTION "Widzisz wszystkich niewidzialnych"

new itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);

	register_forward(FM_AddToFullPack, "add_to_full_pack", 1)
}

public cod_item_enabled(id, value)
	set_bit(id, itemActive);

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public add_to_full_pack(handle, e, ent, host, hostFlags, player, pSet)
{
	if (!is_user_connected(host) || !is_user_connected(ent) || !get_bit(host, itemActive)) return FMRES_IGNORED;
		
	set_es(handle, ES_RenderAmt, 255.0);

	return FMRES_IGNORED;
}