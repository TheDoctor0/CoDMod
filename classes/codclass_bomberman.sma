#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Bomberman"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Bomberman"
#define DESCRIPTION  "Ma 50 procent grawitacji, 2 smoki i 2 dynamity, ktore moze podkladac i detonowac."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_UMP45)|(1<<CSW_FIVESEVEN)|(1<<CSW_FLASHBANG)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      0
#define CONDITION    20

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_dynamites(id, 2, CLASS);
	cod_set_user_gravity(id, 0.5, CLASS);

	cod_give_weapon(id, CSW_SMOKEGRENADE, 2);
}

public cod_class_spawned(id, respawn)
	if (!respawn) cod_give_weapon(id, CSW_SMOKEGRENADE, 2);

public cod_class_skill_used(id)
	cod_use_user_dynamite(id);
