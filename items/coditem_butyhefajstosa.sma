#include <amxmodx>
#include <hamsandwich>
#include <cod>

#define PLUGIN "CoD Item Buty Hefajstosa"
#define VERSION "1.0.3"
#define AUTHOR "O'Zone"

#define NAME        "Buty Hefajstosa"
#define DESCRIPTION "Nie otrzymujesz obrazen od upadku"

new itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);

	RegisterHam(Ham_TakeDamage, "player", "take_damage");
}

public cod_item_enabled(id, value)
	set_bit(id, itemActive);

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public take_damage(victim, inflictor, attacker, Float:damage, damageBits)
{
	if(damageBits == DMG_FALL && get_bit(victim, itemActive)) {
		SetHamReturnInteger(0);

		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}