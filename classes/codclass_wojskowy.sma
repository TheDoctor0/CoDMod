#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Wojskowy"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Wojskowy"
#define DESCRIPTION  "Ma 1/7 na oslepienie przeciwnika przy trafieniu. Posiada 3 rakiety."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_FAMAS)|(1<<CSW_XM1014)|(1<<CSW_P228)
#define HEALTH       20
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
	cod_set_user_rockets(id, 3, CLASS);

public cod_class_skill_used(id)
	cod_use_user_rocket(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (damageBits & DMG_BULLET && random_num(1, 7) == 1) cod_display_fade(victim, 2, 2, 0x0000, 255, 155, 50, 230);
