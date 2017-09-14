#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Szturmowiec"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Szturmowiec"
#define DESCRIPTION  "Zadaje o 3 (+inteligencja) zwiekszone obrazenia z M4A1. Ma 1 rakiete i nie slychac jego krokow."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_M4A1)|(1<<CSW_DEAGLE)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      0
#define CONDITION    10

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_footsteps(id, 1, CLASS);

	cod_set_user_rockets(id, 1, CLASS);
}

public cod_class_skill_used(id)
	cod_use_user_rocket(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
	if(weapon == CSW_M4A1) damage += (3.0 + 0.05 * cod_get_user_intelligence(attacker));
