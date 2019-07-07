#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Podrecznik Szpiega"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Podrecznik Szpiega"
#define DESCRIPTION "Masz 1/%s szansy na natychmiastowe zabicie z HE"
#define RANDOM_MIN  3
#define RANDOM_MAX  6

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	cod_give_weapon(id, CSW_HEGRENADE);

	itemValue[id] = value;
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_HEGRENADE);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id]);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits & DMG_HEGRENADE && random_num(1, itemValue[attacker])) {
		damage = cod_kill_player(attacker, victim, damageBits);
	}
}
