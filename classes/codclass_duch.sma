#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Duch"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Duch"
#define DESCRIPTION  "Po trzymaniu obrazen znika na sekunde. Ma 1 rakiete."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE)
#define HEALTH       20
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      0
#define CONDITION    10

#define TASK_CLASS 3487

new classActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
	cod_set_user_rockets(id, 1, CLASS);

public cod_class_disabled(id)
	rem_bit(id, classActive);

public cod_class_skill_used(id)
	cod_use_user_rocket(id);

public cod_class_spawned(id, respawn)
{
	remove_task(id + TASK_CLASS);

	rem_bit(id, classActive);
}

public cod_class_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (!get_bit(victim, classActive)) {
		cod_set_user_render(victim, 0, .timer = 1.0);

		set_bit(victim, classActive);

		set_task(1.0, "deactivate_class", victim + TASK_CLASS);
	}
}

public deactivate_class(id)
	rem_bit(id - TASK_CLASS, classActive);