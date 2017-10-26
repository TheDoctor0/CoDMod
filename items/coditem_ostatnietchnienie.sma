#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Ostatnie Tchnienie"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define NAME        "Ostatnie Tchnienie"
#define DESCRIPTION "Gdy masz zginac stajesz sie niesmiertelny na %s sekund, potem umierasz"
#define RANDOM_MIN  2
#define RANDOM_MAX  3
#define VALUE_MAX   5

#define TASK_DEATH  7382

new itemValue[MAX_PLAYERS + 1], itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	set_bit(id, itemActive);

	itemValue[id] = value;
}

public cod_item_disabled(id)
{
	rem_bit(id, itemActive);

	remove_task(id + TASK_DEATH);
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id]);

public cod_damage_pre(attacker, victim, weapon, Float:damage, damageBits, hitPlace)
{
	if (!get_bit(victim, itemActive)) return COD_CONTINUE;

	if (task_exists(victim + TASK_DEATH)) return _:COD_BLOCK;

	if (cod_get_user_health(victim) < damage) {
		new data[3];

		data[0] = attacker;
		data[1] = victim;
		data[2] = damageBits;

		set_task(float(itemValue[victim]), "deactivate_item", victim + TASK_DEATH, data, sizeof data);

		return _:COD_BLOCK;
	}

	return COD_CONTINUE;
}

public deactivate_item(data[])
	if (is_user_connected(data[0]) && is_user_alive(data[1])) cod_kill_player(data[0], data[1], data[2]);