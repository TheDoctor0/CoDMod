#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Saper"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Saper"
#define DESCRIPTION  "Ma 2 miny i nieco zmniejszona grawitacje. Jest mniej widoczny z P90."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_P90)|(1<<CSW_FIVESEVEN)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     20
#define STAMINA      0
#define CONDITION    0

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_mines(id, 2, CLASS);

	cod_set_user_render(id, 120, CLASS, RENDER_ALWAYS, CSW_P90);

	cod_set_user_gravity(id, -0.3, CLASS);
}

public cod_class_skill_used(id)
	cod_use_user_mine(id);
