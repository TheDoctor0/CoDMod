#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Morderca"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Morderca"
#define DESCRIPTION  "Ma 1/6 zabicie z AK47/M4A1, posiada 2 miny, niemal niewidoczny podczas kucania."
#define FRACTION     "SuperPremium"
#define WEAPONS      (1<<CSW_AK47)|(1<<CSW_M4A1)|(1<<CSW_DEAGLE)
#define HEALTH       30
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      0
#define CONDITION    20
#define FLAG         ADMIN_LEVEL_G

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION, FLAG);
}

public cod_class_enabled(id)
{
	cod_set_user_render(id, 35, CLASS, RENDER_DUCK);

	cod_set_user_mines(id, 2, CLASS);
}

public cod_class_skill_used(id)
	cod_use_user_mine(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if ((weapon == CSW_M4A1 || weapon == CSW_AK47) && damageBits & DMG_BULLET && random_num(1, 6) == 1) damage = cod_kill_player(attacker, victim, damageBits);