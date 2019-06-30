#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Tajemnica Generala"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Tajemnica Generala"
#define DESCRIPTION "Natychmiastowe zabicie z HE"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_give_weapon(id, CSW_HEGRENADE);

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_HEGRENADE);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits & DMG_HEGRENADE) {
        damage = cod_kill_player(attacker, victim, damageBits);
    }
}
