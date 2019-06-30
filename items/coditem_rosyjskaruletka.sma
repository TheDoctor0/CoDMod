#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Rosyjska Ruletka"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Rosyjska Ruletka"
#define DESCRIPTION "Masz 5/6 szansy na natychmiastowe zabicie i 1/6 za samobojstwo przy trafieniu przeciwnika z Deagle."

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_give_weapon(id, CSW_DEAGLE);

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_DEAGLE);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (weapon != CSW_DEAGLE || (!damageBits & DMG_BULLET)) return;

	if (random_num(1, 6) == 1) {
		user_silentkill(attacker);
	} else {
		damage = cod_kill_player(attacker, victim, damageBits);
	}
}
