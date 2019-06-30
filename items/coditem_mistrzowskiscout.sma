#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Mistrzowski Scout"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Mistrzowski Scout"
#define DESCRIPTION "Natychmiastowe zabicie ze Scouta"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_give_weapon(id, CSW_SCOUT);

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_SCOUT);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (weapon == CSW_SCOUT && damageBits & DMG_BULLET) {
        damage = cod_kill_player(attacker, victim, damageBits);
    }
}
