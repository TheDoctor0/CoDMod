#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Item Betonowe Cialo"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define TASK_ITEM 90342

#define VALUE_DEFAULT 15

new const name[] = "Betonowe Cialo";
new const description[] = "Po aktywacji przez %ss otrzymujesz obrazenia jedynie od strzalow w glowe";

new itemValue[MAX_PLAYERS + 1], itemUsed, itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);

	register_forward(FM_TraceLine, "trace_line");
}

public cod_item_enabled(id, value)
{
	rem_bit(id, itemUsed);

	itemValue[id] = value == -1 ? VALUE_DEFAULT : value;
}

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public cod_item_spawned(id)
{
	rem_bit(id, itemActive);
	rem_bit(id, itemUsed);
}

public cod_item_upgrade(id)
	itemValue[id] = max(0, itemValue[id] + random_num(-2, 3));

public cod_item_value(id)
	return itemValue[id];

public cod_item_skill_used(id)
{
	set_bit(id, itemActive);
	set_bit(id, itemUsed);

	set_task(float(itemValue[id]), "disactivate_item", id + TASK_ITEM);
}

public disactivate_item(id)
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
