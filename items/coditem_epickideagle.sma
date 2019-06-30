#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Epicki Deagle"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Epicki Deagle"
#define DESCRIPTION "Dostajesz Deagle, z ktorego masz 1/6 szansy na natychmiastowe zabicie i zadajesz +%s obrazen"
#define RANDOM_MIN  20
#define RANDOM_MAX  35
#define UPGRADE_MIN -3
#define UPGRADE_MAX 4
#define VALUE_MAX   50

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	cod_give_weapon(id, CSW_DEAGLE);

	itemValue[id] = value;
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_DEAGLE);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (weapon != CSW_DEAGLE || !(damageBits & DMG_BULLET)) return;

	if (random_num(1, 6) == 1) {
		damage = cod_kill_player(attacker, victim, damageBits);
	} else {
		damage += float(itemValue[attacker]);
	}
}
