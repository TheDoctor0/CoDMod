#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Mysliwy"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Mysliwy";
new const description[] = "1/1 ze scouta, mala widocznosc na nozu, podwojny skok i 1 dynamit";
new const fraction[] = "SuperPremium";
new const weapons = (1<<CSW_DEAGLE)|(1<<CSW_SCOUT);
new const health = 25;
new const intelligence = 0;
new const strength = 0;
new const stamina = 5;
new const condition = 20;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id)
{
	cod_set_user_render(id, CLASS, 40, RENDER_ALWAYS, CSW_KNIFE);

	cod_add_user_multijumps(id, 1);

	cod_add_user_dynamites(id, 1);
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(weapon == CSW_SCOUT && damageBits & DMG_BULLET)
	{
		damage = COD_BLOCK;

		cod_kill_player(attacker, victim, damageBits);
	}
}

public cod_class_spawned(id)
{
	cod_add_user_multijumps(id, 1);

	cod_add_user_dynamites(id, 1);
}
