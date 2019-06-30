#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Skrytobojca"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Skrytobojca"
#define DESCRIPTION  "Po uzyciu mocy klasy jest niemal niewidzialny przez 10s. Posiada podwojny skok."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_UMP45)|(1<<CSW_USP)
#define HEALTH       0
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      20
#define CONDITION    10

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
{
	if (!respawn) {
		rem_bit(id, classUsed);
	}
}

public cod_class_skill_used(id)
{
	if (get_bit(id, classUsed)) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Niewidzialnosc mozesz aktywowac tylko raz na runde!");

		return PLUGIN_CONTINUE;
	}

	set_bit(id, classUsed);

	cod_set_user_render(id, 20, CLASS, .timer = 10.0);

	return PLUGIN_CONTINUE;
}
