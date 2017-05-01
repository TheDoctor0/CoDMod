#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Class Komandos"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Komandos";
new const description[] = "Natychmiastowe zabicie z noza(PPM), 1/10 z Deagle, podwojny skok";
new const fraction[] = "";
new const weapons = 1<<CSW_DEAGLE;
new const health = 40;
new const intelligence = 0;
new const strength = 0;
new const stamina = 0;
new const condition = 40;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
	cod_set_user_multijumps(id, 1);

public cod_class_spawned(id)
	cod_add_user_multijumps(id, 1);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(weapon == CSW_KNIFE && !(pev(attacker, pev_button) & IN_ATTACK))
	{
		damage = COD_BLOCK;

		cod_kill_player(attacker, victim, damageBits);

		log_to_file("cod_mod.log", "Komandos PPM");
	}

	if(weapon == CSW_DEAGLE && damageBits & DMG_BULLET && random_num(1, 10) == 1)
	{
		damage = COD_BLOCK;

		cod_kill_player(attacker, victim, damageBits);
	}
}