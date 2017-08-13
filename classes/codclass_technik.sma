#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Technik"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Technik";
new const description[] = "Posiada 1 rakiete, 1 apteczke, 1/8 z Deagle i wszystkie granaty.";
new const fraction[] = "";
new const weapons = (1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_FLASHBANG)|(1<<CSW_HEGRENADE);
new const health = 10;
new const intelligence = 20;
new const strength = 0;
new const stamina = 0;
new const condition = 10;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_rockets(id, 1, CLASS);
	cod_set_user_medkits(id, 1, CLASS);
}

public cod_class_skill_used(id)
{
	if(cod_get_user_rockets(id)) cod_use_user_rocket(id);
	else cod_use_user_medkit(id);
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(weapon == CSW_DEAGLE && damageBits & DMG_BULLET && random_num(1, 8) == 1)
	{
		damage = COD_BLOCK;

		cod_kill_player(attacker, victim, damageBits);
	}
}