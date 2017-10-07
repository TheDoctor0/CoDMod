#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Item Intelekt O'Zone"
#define VERSION "1.0.14"
#define AUTHOR "O'Zone"

#define NAME        "Intelekt O'Zone"
#define DESCRIPTION "Masz 1/%s szansy na zmiane trajektorii lotu kuli na glowe przy trafieniu"
#define RANDOM_MIN  4
#define RANDOM_MAX  5
#define VALUE_MIN   2

new itemValue[MAX_PLAYERS + 1], itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);

	register_forward(FM_TraceLine, "trace_line");
	register_forward(FM_TraceHull, "trace_hull", 1);
}

public cod_item_enabled(id, value)
{
	set_bit(id, itemActive);

	itemValue[id] = value;
}

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public cod_item_upgrade(id)
	return cod_random_upgrade(itemValue[id], .valueMin = VALUE_MIN);

public cod_item_value(id)
	return itemValue[id];

public trace_line(Float:startVector[3], Float:endVector[3], conditions, id, trace)
	return process_trace(id, trace);

public trace_hull(Float:startVector[3], Float:endVector[3], conditions, hull, id, trace)
	return process_trace(id, trace);

public process_trace(id, trace)
{
	if (!is_user_alive(id) || !(get_bit(id, itemActive)) || random_num(1, itemValue[id]) != 1) return FMRES_IGNORED;
	
	static ent; ent = get_tr2(trace, TR_pHit);
	
	if (!is_user_alive(ent) || cod_get_user_item(ent) == cod_get_item_id("Bezglowie")) return FMRES_IGNORED;
		
	new Float:origin[3], Float:angles[3];

	engfunc(EngFunc_GetBonePosition, ent, 8, origin, angles);

	set_tr2(trace, TR_vecEndPos, origin);
	set_tr2(trace, TR_iHitgroup, HIT_HEAD);
	
	return FMRES_IGNORED;
}