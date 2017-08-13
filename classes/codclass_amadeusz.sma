#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Amadeusz"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Amadeusz";
new const description[] = "Dodatkowe 3 (+inteligencja) obrazenia z MP5. Posiada podwojny skok.";
new const fraction[] = "";
new const weapons = (1<<CSW_USP)|(1<<CSW_MP5NAVY);
new const health = 20;
new const intelligence = 0;
new const strength = 0;
new const stamina = 10;
new const condition = 10;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
	cod_set_user_multijumps(id, CLASS, 1);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
	if(weapon == CSW_MP5NAVY && damageBits & DMG_BULLET) damage += (3.0 + 0.2 * cod_get_user_intelligence(attacker));