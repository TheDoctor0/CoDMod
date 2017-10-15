#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Amadeusz"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Amadeusz"
#define DESCRIPTION  "Dodatkowe 5 (+int) obrazenia z MP5. Posiada jedna rakiete."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_MP5NAVY)|(1<<CSW_USP)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      10
#define CONDITION    10

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
	cod_set_user_rockets(id, 1, CLASS);

public cod_class_skill_used(id)
	cod_use_user_rocket(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (weapon == CSW_MP5NAVY && damageBits & DMG_BULLET) damage += (5.0 + 0.05 * cod_get_user_intelligence(attacker));
