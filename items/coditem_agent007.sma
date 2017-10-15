#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Item Agent 007"
#define VERSION "1.0.9"
#define AUTHOR "O'Zone"

#define NAME        "Agent 007"
#define DESCRIPTION "Masz 1/%s na natychmiastowe zabicie z USP z zalozonym tlumikiem"
#define RANDOM_MIN  4
#define RANDOM_MAX  6
#define VALUE_MIN   2

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	cod_give_weapon(id, CSW_USP);

	itemValue[id] = value;
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_USP);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], .valueMin = VALUE_MIN);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (weapon == CSW_USP && damageBits & DMG_BULLET && random_num(1, itemValue[attacker]) == 1 && get_pdata_int(get_pdata_cbase(attacker, 373, 5), 74, 4) & 1) damage = cod_kill_player(attacker, victim, damageBits);