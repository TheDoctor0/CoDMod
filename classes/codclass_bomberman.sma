#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Bomberman"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Bomberman"
#define DESCRIPTION  "Ma 2 dynamity, ktore moze podkladac i detonowac. Ma i polowe mniejsza grawitacje"
#define FRACTION     ""
#define WEAPONS      (1<<CSW_UMP45)|(1<<CSW_FIVESEVEN)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      20
#define CONDITION    0

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_dynamites(id, 2, CLASS);

	cod_set_user_gravity(id, 0.5, CLASS);
}

public cod_class_skill_used(id)
	cod_use_user_dynamite(id);