#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Item Bezglowie"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define TASK_ITEM 783426

#define RANDOM_MIN 15
#define RANDOM_MAX 20
#define UPGRADE_MIN -2
#define UPGRADE_MAX 3
#define VALUE_MIN 0

new const name[] = "Bezglowie";
new const description[] = "Po aktywacji przez %ss jestes odporny na strzaly w glowe";

new itemValue[MAX_PLAYERS + 1], canUseItem;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);

	register_forward(FM_TraceLine, "trace_line");
}

public cod_item_enabled(id, value)
{
	rem_bit(id, itemUsed);

	itemValue[id] = value == RANDOM ? random_num(RANDOM_MIN, RANDOM_MAX): value;
}

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public cod_item_spawned(id)
{
	remove_task(id + TASK_ITEM);

	rem_bit(id, itemActive);
	rem_bit(id, itemUsed);
}

public cod_item_upgrade(id)
{
	if(itemValue[id] <= VALUE_MIN && VALUE_MIN > 0) return COD_STOP;
	
	itemValue[id] = max(VALUE_MIN, itemValue[id] + random_num(UPGRADE_MIN, UPGRADE_MAX));
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_skill_used(id)
{
	set_bit(id, itemActive);
	set_bit(id, itemUsed);

	set_task(float(itemValue[id]), "deactivate_item", id + TASK_ITEM);
}

public deactivate_item(id)
	rem_bit(id - TASK_ITEM, itemActive);

public trace_line(Float:startVector[3], Float:endVector[3], conditions, id, trace)
{
	if(!is_user_alive(id) || !(get_bit(id, itemActive))) return FMRES_IGNORED;
        
	static ent; ent = get_tr(TR_pHit);

	if(!is_user_alive(ent) || id == ent) return FMRES_IGNORED;

	set_tr2(trace, TR_iHitgroup, 8);

	return FMRES_IGNORED;
}
