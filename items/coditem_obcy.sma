#include <amxmodx>
#include <cod>
#include <fakemeta>
#include <engine>

#define PLUGIN "CoD Item Obcy"
#define VERSION "1.1"
#define AUTHOR "O'Zone"

#define NAME        "Obcy"
#define DESCRIPTION "Zabicie przeciwnika powoduje jego eksplozje zadajaca %s (+int) obrazen"
#define RANDOM_MIN  100
#define RANDOM_MAX  150
#define UPGRADE_MIN -5
#define UPGRADE_MAX 9

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
	itemValue[id] = value;

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);

public cod_item_kill(killer, victim, hitPlace)
{
	new Float:origin[3];

	entity_get_vector(victim, EV_VEC_origin, origin);

	new ent = create_entity("info_target");

	set_pev(ent, pev_owner, killer);

	entity_set_origin(ent, origin);

	set_pev(ent, pev_mins, Float:{ -10.0, -10.0, 0.0 });
	set_pev(ent, pev_maxs, Float:{ 10.0, 10.0, 50.0 });
	set_pev(ent, pev_size, Float:{ -1.0, -3.0, 0.0, 1.0, 1.0, 10.0 });
	engfunc(EngFunc_SetSize, ent, Float:{ -1.0, -3.0, 0.0 }, Float:{ 1.0, 1.0, 10.0 });

	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	set_pev(ent, pev_movetype, MOVETYPE_FLY);

	cod_make_explosion(ent, 200, 1, 200.0, float(itemValue[killer]) + cod_get_user_intelligence(killer));

	remove_entity(ent);
}
