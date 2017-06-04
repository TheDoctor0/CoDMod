#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Item Bezglowie"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Bezglowie";
new const description[] = "Jestes odporny na strzaly w glowe";

new hasItem;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);

	register_forward(FM_TraceLine, "trace_line");
}

public cod_item_enabled(id, value)
	set_bit(id, hasItem);

public cod_item_disabled(id)
	rem_bit(id, hasItem);

public trace_line(Float:startVector[3], Float:endVector[3], conditions, id, trace)
{
	if(!is_user_alive(id) || !(get_bit(id, hasItem))) return FMRES_IGNORED;
        
	static ent; ent = get_tr(TR_pHit);

	if(!is_user_alive(ent) || id == ent) return FMRES_IGNORED;

	set_tr2(trace, TR_iHitgroup, 8);

	return FMRES_IGNORED;
}
