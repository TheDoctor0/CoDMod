#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Noz Medyka"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Noz Medyka"
#define DESCRIPTION "Na nozu regenerujesz %s HP co sekunde"
#define RANDOM_MIN  2
#define RANDOM_MAX  3

new itemValue[MAX_PLAYERS + 1], itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	set_bit(id, itemActive);

	if (cod_get_user_weapon(id) == CSW_KNIFE) {
		cod_repeat_damage(id, id, float(itemValue[id]), 3.0, 0, HEAL, 0);
	}
}

public cod_item_disabled(id)
{
	cod_repeat_damage(id, id);

	rem_bit(id, itemActive);
}

public cod_weapon_deploy(id, weapon, ent)
{
	if (get_bit(id, itemActive)) {
		cod_repeat_damage(id, id);

		if (cod_get_user_weapon(id) == CSW_KNIFE) {
			cod_repeat_damage(id, id, float(itemValue[id]), 3.0, 0, HEAL, 0);
		}
	}
}

public cod_item_spawned(id, respawn)
{
	if (cod_get_user_weapon(id) == CSW_KNIFE) {
		cod_repeat_damage(id, id, float(itemValue[id]), 1.0, 0, HEAL, 0);
	}
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
{
	cod_repeat_damage(id, id);
	cod_random_upgrade(itemValue[id]);

	if (cod_get_user_weapon(id) == CSW_KNIFE) {
		cod_repeat_damage(id, id, float(itemValue[id]), 1.0, 0, HEAL, 0);
	}
}
