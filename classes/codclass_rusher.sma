#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Rusher"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Rusher"
#define DESCRIPTION  "Posiada podwojny skok i zadaje +5 obrazen. Ma 1/8 na zabicie wroga z M3 i 1/12 z XM1014."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_M3)|(1<<CSW_XM1014)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      0
#define CONDITION    30

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id)
	cod_set_user_multijumps(id, 1, CLASS);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if((weapon == CSW_M3 && random_num(1, 8) == 1) || (weapon == CSW_XM1014 && random_num(1, 10) == 1))
	{
		damage = COD_BLOCK;

		cod_kill_player(attacker, victim, damageBits);
	}
	else damage += 5.0;
}