#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Class Snajper"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Snajper"
#define DESCRIPTION  "Ma 130 procent obrazen z AWP (+int) i 1/2 na natychmiastowe zabicie z noza (PPM)."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_AWP)|(1<<CSW_DEAGLE)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      30
#define CONDITION    0

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (weapon == CSW_KNIFE && pev(attacker, pev_button) & IN_ATTACK2 && cod_percent_chance(50)) damage = cod_kill_player(attacker, victim, damageBits);

	if (weapon == CSW_AWP && damageBits & DMG_BULLET) damage = damage * (1.3 + (cod_get_user_intelligence(attacker) * 0.2 / 100.0));
}