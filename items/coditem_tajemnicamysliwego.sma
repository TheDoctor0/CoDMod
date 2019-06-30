#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Tajemnica Mysliwego"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Tajemnica Mysliwego"
#define DESCRIPTION "Masz 50 procent szansy na natychmiastowe na zabicie ze Scouta i dostajesz +%s kondycji"
#define RANDOM_MIN  20
#define RANDOM_MAX  30
#define UPGRADE_MIN -3
#define UPGRADE_MAX 5
#define VALUE_MAX   100

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	cod_add_user_bonus_condition(id, itemValue[id]);

	cod_give_weapon(id, CSW_SCOUT);
}

public cod_item_disabled(id)
{
	cod_add_user_bonus_condition(id, -itemValue[id]);

	cod_take_weapon(id, CSW_SCOUT);
}

public cod_item_upgrade(id)
{
	cod_add_user_bonus_condition(id, -itemValue[id]);

	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

	cod_add_user_bonus_condition(id, itemValue[id]);
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (weapon == CSW_SCOUT && damageBits & DMG_BULLET && cod_percent_chance(50)) {
		damage = cod_kill_player(attacker, victim, damageBits);
	}
}
