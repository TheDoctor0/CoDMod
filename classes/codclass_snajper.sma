#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Class Snajper"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Snajper";
new const description[] = "Ma 130 procent obrazen z AWP (+int) i 1/2 szansy na zabicie z noza(PPM)";
new const fraction[] = "";
new const weapons = (1<<CSW_AWP)|(1<<CSW_DEAGLE);
new const health = 10;
new const intelligence = 0;
new const strength = 0;
new const stamina = 30;
new const condition = 0;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(weapon == CSW_KNIFE && pev(attacker, pev_button) & IN_ATTACK2 && random_num(1, 2) == 1)
	{
		damage = COD_BLOCK;

		cod_kill_player(attacker, victim, damageBits);
	}

	if(weapon == CSW_AWP && damageBits & DMG_BULLET) damage = damage * 1.3 + 0.2 * cod_get_user_intelligence(attacker);
}