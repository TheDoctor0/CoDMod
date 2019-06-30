#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Betonowe Cialo"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Betonowe Cialo"
#define DESCRIPTION "Po aktywacji przez %ss otrzymujesz obrazenia jedynie od strzalow w glowe"
#define RANDOM_MIN  10
#define RANDOM_MAX  15
#define UPGRADE_MIN -2
#define UPGRADE_MAX 3

#define TASK_ITEM 90342

new itemValue[MAX_PLAYERS + 1], itemUsed, itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	rem_bit(id, itemUsed);

	itemValue[id] = value;
}

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);

public cod_item_value(id)
	return itemValue[id];

public cod_item_spawned(id, respawn)
{
	remove_task(id + TASK_ITEM);

	rem_bit(id, itemActive);

	if (!respawn) {
		rem_bit(id, itemUsed);
	}
}

public cod_item_skill_used(id)
{
	if (get_bit(id, itemUsed)) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.45, 0, 0.0, 1.25, 0.0, 0.0, "Betonowego Ciala mozesz uzyc tylko raz na runde!");

		return;
	}

	set_bit(id, itemActive);
	set_bit(id, itemUsed);

	cod_make_bartimer(id, itemValue[id]);

	set_task(float(itemValue[id]), "deactivate_item", id + TASK_ITEM);
}

public deactivate_item(id)
	rem_bit(id - TASK_ITEM, itemActive);

public cod_item_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits & DMG_BULLET && get_bit(victim, itemActive) && hitPlace != HIT_HEAD) {
		damage = COD_BLOCK;
	}
}
