#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Test2"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Test2";
new const description[] = "Natychmiastowe zabicie z noza(PPM)";
new const fraction[] = "Testy";
new const weapons = 1<<CSW_DEAGLE;
new const health = 40;
new const intelligence = 0;
new const strength = 10;
new const stamina = 0;
new const condition = 50;

new class, classPromotion;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
{
	set_bit(id, class);

	classPromotion = promotion;

	if(classPromotion == PROMOTION_THIRD) cod_set_user_multijumps(id, 2);
}
	
public cod_class_disabled(id, promotion)
	rem_bit(id, class);

public cod_class_spawned(id)
	if(classPromotion == PROMOTION_THIRD) cod_set_user_multijumps(id, 2);

public cod_item_damage_attacker(attacker, victim, Float:damage, damageBits)
	if(get_user_weapon(attacker) == CSW_KNIFE && damageBits & DMG_BULLET && damage > 20 && get_bit(attacker, class))
		cod_kill_player(attacker, victim, damageBits);
