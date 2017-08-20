#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Aimer"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Aimer";
new const description[] = "Ma 1/4 szansy na natychmiastowe zabicie z HeadShota";
new const fraction[] = "";
new const weapons = (1<<CSW_P228)|(1<<CSW_M4A1);
new const health = 20;
new const intelligence = 0;
new const strength = 10;
new const stamina = 0;
new const condition = 5;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(damageBits & DMG_BULLET && random_num(1, 4))
	{
		cod_kill_player(attacker, victim, damageBits);

		damage = COD_BLOCK;
	}
}