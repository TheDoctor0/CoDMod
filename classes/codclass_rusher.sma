#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Rusher"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Rusher";
new const description[] = "Ma podwojny skok, zadaje +5 obrazen, ma 1/7 na zabicie wroga z M3.";
new const fraction[] = "";
new const weapons = (1<<CSW_M3)|(1<<CSW_XM1014);
new const health = 20;
new const intelligence = 0;
new const strength = 0;
new const stamina = 0;
new const condition = 25;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id)
	cod_set_user_multijumps(id, 1);

public cod_class_disabled(id)
	cod_set_user_multijumps(id, 0);

public cod_class_spawned(id)
	cod_add_user_multijumps(id, 1);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(weapon == CSW_M3 && random_num(1, 7) == 1)
	{
		damage = COD_BLOCK;

		cod_kill_player(attacker, victim, damageBits);
	}
	else damage += 5.0;
}