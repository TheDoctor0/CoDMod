#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Msciciel"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Msciciel";
new const description[] = "1/1 z awp, 1/2 z noża (PPM), mniejsza widocznosc podczas kucania, zmniejszona grawitacja";
new const fraction[] = "Premium";
new const weapons = (1<<CSW_USP)|(1<<CSW_AWP);
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
	cod_add_user_gravity(id, CLASS, -0.25);

	cod_set_user_render(id, CLASS, 150, RENDER_DUCK);
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if((weapon == CSW_SCOUT && damageBits & DMG_BULLET) || (weapon == CSW_KNIFE && random_num(1, 2) && !(pev(attacker, pev_button) & IN_ATTACK)))
	{
		damage = COD_BLOCK;

		cod_kill_player(attacker, victim, damageBits);
	}
}