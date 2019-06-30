#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item AWP Weterana"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "AWP Weterana"
#define DESCRIPTION "Masz 50 procent szansy na natychmiastowe zabicie z AWP i 30 procent widocznosci z nim. Dostajesz +%s zdrowia"
#define RANDOM_MIN  20
#define RANDOM_MAX  25
#define UPGRADE_MIN -2
#define UPGRADE_MAX 4
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

	cod_add_user_bonus_health(id, itemValue[id]);

	cod_set_user_render(id, 75, ITEM, RENDER_ALWAYS, 1<<CSW_AWP);

	cod_give_weapon(id, CSW_AWP);
}

public cod_item_disabled(id)
{
	cod_add_user_bonus_health(id, -itemValue[id]);

	cod_take_weapon(id, CSW_AWP);
}

public cod_item_upgrade(id)
{
	cod_add_user_bonus_health(id, -itemValue[id]);

	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

	cod_add_user_bonus_health(id, itemValue[id]);
}

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (weapon == CSW_AWP && damageBits & DMG_BULLET && cod_percent_chance(50)) {
		damage = cod_kill_player(attacker, victim, damageBits);
	}
}
