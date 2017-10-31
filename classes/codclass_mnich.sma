#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Mnich"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Mnich"
#define DESCRIPTION  "Posiada 3 teleporty, ktorych moze uzyc co 15 sekund."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_AK47)|(1<<CSW_P228)
#define HEALTH       15
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      5
#define CONDITION    10

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
	cod_set_user_teleports(id, 3, CLASS);

public cod_class_skill_used(id)
	cod_use_user_teleport(id);
