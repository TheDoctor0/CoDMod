#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Technik"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Technik"
#define DESCRIPTION  "Posiada 1 rakiete, 1 apteczke, 1/8 z Deagle i wszystkie granaty."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_FLASHBANG)|(1<<CSW_HEGRENADE)
#define HEALTH       10
#define INTELLIGENCE 10
#define STRENGTH     0
#define STAMINA      0
#define CONDITION    10

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_rockets(id, 1, CLASS);
	cod_set_user_medkits(id, 1, CLASS);
}

public cod_class_skill_used(id)
{
	if(cod_get_user_rockets(id)) cod_use_user_rocket(id);
	else cod_use_user_medkit(id);
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
	if(weapon == CSW_DEAGLE && damageBits & DMG_BULLET && random_num(1, 8) == 1) damage = cod_kill_player(attacker, victim, damageBits);