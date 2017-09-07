#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Class Komandos"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Komandos"
#define DESCRIPTION  "Natychmiastowe zabicie z noza (PPM), 1/10 z Deagle, podwojny skok"
#define FRACTION     ""
#define WEAPONS      (1<<CSW_DEAGLE)
#define HEALTH       30
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      0
#define CONDITION    30

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
	cod_set_user_multijumps(id, 1, CLASS);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(weapon == CSW_KNIFE && !(pev(attacker, pev_button) & IN_ATTACK))
	{
		damage = COD_BLOCK;

		cod_kill_player(attacker, victim, damageBits);
	}

	if(weapon == CSW_DEAGLE && damageBits & DMG_BULLET && random_num(1, 10) == 1)
	{
		damage = COD_BLOCK;

		cod_kill_player(attacker, victim, damageBits);
	}
}