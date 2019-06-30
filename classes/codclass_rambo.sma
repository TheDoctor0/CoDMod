#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Rambo"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Rambo"
#define DESCRIPTION  "Zadaje 30 (+int) procent wiecej obrazen z Famasa, nie slychac jego krokow, ma 4 flashe."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_M4A1)|(1<<CSW_FAMAS)|(1<<CSW_USP)|(1<<CSW_FLASHBANG)
#define HEALTH       20
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      5
#define CONDITION    5

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
{
	cod_give_weapon(id, CSW_FLASHBANG, 4);

	cod_set_user_footsteps(id, true, CLASS);
}

public cod_class_spawned(id, respawn)
{
	if (!respawn) {
		cod_give_weapon(id, CSW_FLASHBANG, 4);
	}
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (weapon == CSW_FAMAS && damageBits & DMG_BULLET) {
		damage *= 1.3 + (0.003 * cod_get_user_intelligence(attacker));
	}
}
