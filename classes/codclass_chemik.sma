#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Chemik"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Chemik"
#define DESCRIPTION  "Ma 15 procent na zatrucie przeciwnika po trafieniu. Ma jedna apteczke."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_M4A1)|(1<<CSW_DEAGLE)
#define HEALTH       25
#define INTELLIGENCE 0
#define STRENGTH     5
#define STAMINA      10
#define CONDITION    0

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
	cod_set_user_medkits(id, 1, CLASS);

public cod_class_skill_used(id)
	cod_use_user_medkit(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (damageBits & DMG_BULLET && cod_percent_chance(15)) cod_repeat_damage(attacker, victim, 3.0 + cod_get_user_intelligence(attacker) * 0.02, 0.5, 10, POISON);