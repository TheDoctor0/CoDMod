#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Elektryk"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Elektryk";
new const nameFirst[] = "Zaawansowany Elektryk";
new const nameSecond[] = "Elitarny Elektryk";
new const nameThird[] = "Mistrzowski Elektryk";
new const description[] = "Posiada 3 blyskawice. Ma 10% szansy ma podpalenie przeciwnika po trafieniu USP.";
new const descriptionFirst[] = "Posiada 4 blyskawice. Ma 10% szansy ma podpalenie przeciwnika po trafieniu USP.";
new const descriptionSecond[] = "Posiada 5 blyskawic. Ma 10% szansy ma podpalenie przeciwnika po trafieniu USP.";
new const descriptionThird[] = "Posiada 5 blyskawic. Ma 10% szansy ma podpalenie przeciwnika po trafieniu USP.";
new const fraction[] = "";
new const weapons = (1<<CSW_M4A1)|(1<<CSW_USP);
new const weaponsFirst = (1<<CSW_M4A1)|(1<<CSW_AK47)|(1<<CSW_USP);
new const health = 30;
new const intelligence = 0;
new const strength = 0;
new const stamina = 10;
new const condition = 0;

new classPromotion[MAX_PLAYERS + 1];

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);

	cod_register_promotion(nameFirst, descriptionFirst, name, 25, PROMOTION_FIRST, weaponsFirst, health, intelligence, strength, stamina, condition);
	cod_register_promotion(nameSecond, descriptionSecond, name, 50, PROMOTION_SECOND, weapons, health, intelligence, strength, stamina, condition);
	cod_register_promotion(nameThird, descriptionThird, name, 150, PROMOTION_THIRD, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
{
	classPromotion[id] = promotion;

	switch(promotion)
	{
		case PROMOTION_NONE: cod_add_user_thunders(id, 3, CLASS);
		case PROMOTION_FIRST: cod_add_user_thunders(id, 4, CLASS);
		case PROMOTION_SECOND: cod_add_user_thunders(id, 5, CLASS);
		case PROMOTION_THIRD: cod_add_user_thunders(id, 6, CLASS);
	}
}
	
public cod_class_skill_used(id) 
	cod_use_user_thunder(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
	if(weapon == CSW_USP && random_num(1, 10)) cod_repeating_damage(attacker, victim, 2.0, 0.2, 10, DMG_BURN, FIRE);