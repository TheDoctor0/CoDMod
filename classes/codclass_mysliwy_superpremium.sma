#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Mysliwy"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Mysliwy"
#define DESCRIPTION  "Ma 1/2 na natychmiastowe zabicie ze Scouta, mala widocznosc na nozu, podwojny skok i 2 dynamity."
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
	cod_set_user_render(id, 50, CLASS, RENDER_ALWAYS, 1<<CSW_KNIFE);

	cod_set_user_multijumps(id, 1, CLASS);

	cod_set_user_dynamites(id, 2, CLASS);
}

public cod_class_skill_used(id)
	cod_use_user_dynamite(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (weapon == CSW_SCOUT && damageBits & DMG_BULLET && cod_percent_chance(50)) damage = cod_kill_player(attacker, victim, damageBits);