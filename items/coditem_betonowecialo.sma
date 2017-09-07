#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Item Betonowe Cialo"
#define VERSION "1.0.4"
#define AUTHOR "O'Zone"

#define TASK_ITEM 90342

#define NAME        "Betonowe Cialo"
#define DESCRIPTION "Po aktywacji przez %ss otrzymujesz obrazenia jedynie od strzalow w glowe"
#define RANDOM_MIN  10
#define RANDOM_MAX  15
#define UPGRADE_MIN -2
#define UPGRADE_MAX 3

new itemValue[MAX_PLAYERS + 1], itemUsed, itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);

	register_forward(FM_TraceLine, "trace_line");
}

public cod_item_enabled(id, value)
{
	rem_bit(id, itemUsed);

	itemValue[id] = value;
}

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);
	
public cod_item_value(id)
	return itemValue[id];

public cod_item_spawned(id)
{
	remove_task(id + TASK_ITEM);

	rem_bit(id, itemActive);
	rem_bit(id, itemUsed);
}

public cod_item_skill_used(id)
{
	set_bit(id, itemActive);
	set_bit(id, itemUsed);

	set_task(float(itemValue[id]), "deactivate_item", id + TASK_ITEM);
}

public deactivate_item(id)
	rem_bit(id - TASK_ITEM, itemActive);

public trace_line(Float:startVector[3], Float:endVector[3], conditions, id)
{
	if(!is_user_alive(id) || !(get_bit(id, itemActive))) return FMRES_IGNORED;
        
	static ent; ent = get_tr(TR_pHit);

	if(!is_user_alive(ent) || id == ent) return FMRES_IGNORED;

	if(get_tr(TR_iHitgroup) != 1) 
	{
		set_tr(TR_flFraction, 1.0);

		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}
