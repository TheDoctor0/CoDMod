#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Aimer"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Aimer"
#define DESCRIPTION  "Ma 1/4 szansy na natychmiastowe zabicie z HeadShota"
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_M4A1)|(1<<CSW_P228)
#define HEALTH       20
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      0
#define CONDITION    5

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
	if(damageBits & DMG_BULLET && random_num(1, 4)) damage = cod_kill_player(attacker, victim, damageBits);