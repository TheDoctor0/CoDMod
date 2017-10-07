#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Skrytobojca"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Skrytobojca"
#define DESCRIPTION  "Po uzyciu mocy klasy jest niewidzialny przez 15s. Posiada podwojny skok."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_UMP45)|(1<<CSW_DEAGLE)
#define HEALTH       -10
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      5
#define CONDITION    25

new classUsed;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_multijumps(id, 1, CLASS);

	rem_bit(id, classUsed);
}

public cod_class_spawned(id, respawn)
	if (!respawn) rem_bit(id, classUsed);

public cod_class_skill_used(id)
{
	if (get_bit(id, classUsed)) {
		cod_show_hud(id, TYPE_DHUD, 218, 40, 67, -1.0, 0.42, 0, 0.0, 2.0, 0.0, 0.0, "Niewidzialnosc mozesz aktywowac tylko raz na runde!");

		return;
	}

	set_bit(id, classUsed);

	cod_set_user_render(id, 0, CLASS, RENDER_ALWAYS, 0, 15.0);
}
