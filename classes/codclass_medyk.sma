#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Medyk"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Medyk"
#define DESCRIPTION  "Ma 3 apteczki, ktorymi moze leczyc siebie i innych."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_M4A1)|(1<<CSW_GLOCK18)
#define HEALTH       20
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      10
#define CONDITION    0

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
	cod_set_user_medkits(id, 3, CLASS);

public cod_class_skill_used(id)
	cod_use_user_medkit(id);