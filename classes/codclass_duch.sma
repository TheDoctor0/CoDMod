#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Duch"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Duch"
#define DESCRIPTION  "Po trzymaniu obrazen znika na sekunde. Ma 1 rakiete."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_MP5NAVY)|(1<<CSW_USP)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      5
#define CONDITION    15

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
	cod_set_user_rockets(id, 1, CLASS);

public cod_class_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	cod_set_user_render(victim, 0, .timer = 1.0);