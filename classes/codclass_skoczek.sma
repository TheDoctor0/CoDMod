#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Skoczek"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Skoczek"
#define DESCRIPTION  "Ma BunnyHop i dodatkowy skok."
#define FRACTION     ""
#define WEAPONS      (1<<CSW_UMP45)|(1<<CSW_FIVESEVEN)
#define HEALTH       0
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      10
#define CONDITION    10

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_bunnyhop(id, 1, CLASS);

	cod_set_user_multijumps(id, 1, CLASS);
}