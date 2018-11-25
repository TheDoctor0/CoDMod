#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Elektryk"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Elektryk"
#define DESCRIPTION  "Posiada 3 blyskawice. Ma 20% szansy na podpalenie przeciwnika po trafieniu USP."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_M4A1)|(1<<CSW_USP)
#define HEALTH       15
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      10
#define CONDITION    5

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_thunders(id, 3, CLASS);
}

public cod_class_skill_used(id)
	cod_use_user_thunder(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (weapon == CSW_USP && damageBits & DMG_BULLET && cod_percent_chance(20)) cod_repeat_damage(attacker, victim, 5.0, 0.2, 10, DMG_BURN, FIRE);
