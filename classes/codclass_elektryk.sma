#include <amxmodx>
#include <engine>
#include <cod>

#define PLUGIN "CoD Class Elektryk"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Elektryk";
new const name2[] = "Elitarny Elektryk";
new const description[] = "Posiada 3 blyskawice, ktore moze uzyc po wycelowaniu w przeciwnika.";
new const description2[] = "Posiada 4 blyskawice, ktore moze uzyc po wycelowaniu w przeciwnika.";
new const fraction[] = "";
new const weapons = (1<<CSW_M4A1)|(1<<CSW_USP);
new const health = 30;
new const intelligence = 0;
new const strength = 0;
new const stamina = 10;
new const condition = 0;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);

	cod_register_promotion(name2, description2, name, 25, 1, weapons, 40, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
{
	switch(promotion)
	{
		case PROMOTION_NONE: cod_add_user_thunders(id, 3, CLASS);
		case PROMOTION_FIRST: cod_add_user_thunders(id, 4, CLASS);
	}
}
	
public cod_class_skill_used(id) 
	cod_use_user_thunder(id);