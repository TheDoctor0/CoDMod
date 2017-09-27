#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Mysliwy"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Mysliwy"
#define DESCRIPTION  "1/1 ze Scouta, mala widocznosc na nozu, podwojny skok i 1 dynamit"
#define FRACTION     "SuperPremium"
#define WEAPONS      (1<<CSW_SCOUT)|(1<<CSW_DEAGLE)
#define HEALTH       30
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      0
#define CONDITION    20

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id)
{
	cod_set_user_render(id, 50, CLASS, RENDER_ALWAYS, CSW_KNIFE);

	cod_add_user_multijumps(id, 1, CLASS);

	cod_add_user_dynamites(id, 1, CLASS);
}

public cod_class_skill_used(id)
	cod_use_user_dynamite(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
	if(weapon == CSW_SCOUT && damageBits & DMG_BULLET) damage = cod_kill_player(attacker, victim, damageBits);