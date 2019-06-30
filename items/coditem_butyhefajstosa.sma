#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Buty Hefajstosa"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Buty Hefajstosa"
#define DESCRIPTION "Nie otrzymujesz obrazen od upadku. Dostajesz +%s kondycji"
#define RANDOM_MIN  20
#define RANDOM_MAX  25
#define UPGRADE_MIN -2
#define UPGRADE_MAX 4
#define VALUE_MAX   100

new itemActive, itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	set_bit(id, itemActive);

	itemValue[id] = value;

	cod_add_user_bonus_condition(id, itemValue[id]);
}

public cod_item_disabled(id)
{
	rem_bit(id, itemActive);

	cod_add_user_bonus_condition(id, -itemValue[id]);
}

public cod_item_upgrade(id)
{
	cod_add_user_bonus_condition(id, -itemValue[id]);

	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

	cod_add_user_bonus_condition(id, itemValue[id]);
}

public cod_damage_pre(attacker, victim, weapon, Float:damage, damageBits, hitPlace)
{
	if (damageBits == DMG_FALL && get_bit(victim, itemActive)) {
		damage = COD_BLOCK;
	}
}

public cod_item_value(id)
	return itemValue[id];