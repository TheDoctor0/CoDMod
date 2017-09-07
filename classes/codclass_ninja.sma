#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Skrytobojca"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Skrytobojca"
#define DESCRIPTION  "Po uzyciu mocy klasy jest niewidzialny przez 15s. Ma podwojny skok i 1/2 na zabicie z noza (PPM)."
#define FRACTION     ""
#define WEAPONS      (1<<CSW_DEAGLE)|(1<<CSW_UMP45)
#define HEALTH       -10
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      5
#define CONDITION    25

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
	cod_set_user_multijumps(id, 1, CLASS);

public cod_class_spawned(id)
	cod_add_user_multijumps(id, 1, CLASS);

public cod_class_skill_used(id)
	cod_set_user_render(id, 0, CLASS, RENDER_ALWAYS, 0, 15.0);
