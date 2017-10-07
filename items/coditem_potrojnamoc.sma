#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Potrojna Moc"
#define VERSION "1.0.15"
#define AUTHOR "O'Zone"

#define TASK_ITEM 87432

#define NAME        "Potrojna Moc"
#define DESCRIPTION "Po uzyciu przez %s sekund zadajesz potrojne obrazenia"
#define RANDOM_MIN  3
#define RANDOM_MAX  5
#define VALUE_MAX   10

new itemValue[MAX_PLAYERS + 1], itemUsed, itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	rem_bit(id, itemUsed);
}

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public cod_item_spawned(id, respawn)
{
	cod_make_bartimer(id, 0);

	remove_task(id + TASK_ITEM);

	rem_bit(id, itemActive);

	if (!respawn) rem_bit(id, itemUsed);
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], .valueMax = VALUE_MAX);
	
public cod_item_skill_used(id)
{
	if (get_bit(id, itemUsed)) {
		cod_show_hud(id, TYPE_DHUD, 218, 40, 67, -1.0, 0.42, 0, 0.0, 2.0, 0.0, 0.0, "Potrojnej Mocy mozesz uzyc tylko raz na runde!");

		return;
	}

	set_bit(id, itemActive);
	set_bit(id, itemUsed);

	cod_make_bartimer(id, itemValue[id]);

	set_task(float(itemValue[id]), "deactivate_item", id + TASK_ITEM);
}

public deactivate_item(id)
	rem_bit(id - TASK_ITEM, itemActive);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (get_bit(attacker, itemActive) && damageBits & DMG_BULLET) damage *= 3.0;