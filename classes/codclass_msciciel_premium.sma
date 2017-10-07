#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Class Msciciel"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Msciciel"
#define DESCRIPTION  "1/2 z AWP, 1/2 z noza (PPM), mniej widoczny podczas kucania, mniejsza grawitacja."
#define FRACTION     "Premium"
#define WEAPONS      (1<<CSW_AWP)|(1<<CSW_USP)
#define HEALTH       20
#define INTELLIGENCE 0
#define STRENGTH     5
#define STAMINA      20
#define CONDITION    5

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id)
{
	cod_add_user_gravity(id, 0.45, CLASS);

	cod_set_user_render(id, 120, CLASS, RENDER_DUCK);
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if((weapon == CSW_AWP && damageBits & DMG_BULLET && random_num(1, 2)) || (weapon == CSW_KNIFE && random_num(1, 2) && !(pev(attacker, pev_button) & IN_ATTACK))) damage = cod_kill_player(attacker, victim, damageBits);