#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Policjant"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Policjant"
#define DESCRIPTION  "Ma podwojny skok, 20 procent na zabicie z USP/Glocka, +20 obrazen z Deagle."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
#define HEALTH       30
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      10
#define CONDITION    0

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
	cod_set_user_multijumps(id, 1, CLASS);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits & DMG_BULLET) {
		if (weapon == CSW_DEAGLE) damage += 20.0;

		if ((weapon == CSW_USP || weapon == CSW_GLOCK18) && cod_percent_chance(20)) damage = cod_kill_player(attacker, victim, damageBits);
	}
}
