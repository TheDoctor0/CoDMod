#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <cod>

#define PLUGIN "CoD Class Dezerter"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Dezerter"
#define DESCRIPTION  "Ma 1 rakiete, ubranie wroga i 1/6 szansy na odrodzenie na respie wroga."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_GALIL)|(1<<CSW_USP)
#define HEALTH       -10
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      20
#define CONDITION    10

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id)
{
	cod_set_user_rockets(id, 1, CLASS);
	
	cod_set_user_model(id, true, CLASS);
}

public cod_class_spawned(id)
	if (random_num(1, 6) == 1) cod_teleport_to_spawn(id, 1);

public cod_class_skill_used(id)
	cod_use_user_rocket(id);