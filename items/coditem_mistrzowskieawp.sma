#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Mistrzowskie AWP"
#define VERSION "1.0.13"
#define AUTHOR "O'Zone"

#define NAME        "Mistrzowskie AWP"
#define DESCRIPTION "Natychmiastowe zabicie z AWP"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_give_weapon(id, CSW_AWP);

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_AWP);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
	if(weapon == CSW_AWP) damage = cod_kill_player(attacker, victim, damageBits);
