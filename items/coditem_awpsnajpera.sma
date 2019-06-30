#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item AWP Snajpera"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "AWP Snajpera"
#define DESCRIPTION "Zadajesz %s (+int) procent obrazen z AWP"
#define RANDOM_MIN  150
#define RANDOM_MAX  160
#define UPGRADE_MIN -4
#define UPGRADE_MAX 6

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	cod_give_weapon(id, CSW_AWP);
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_AWP);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (weapon == CSW_AWP && damageBits & DMG_BULLET) {
        damage *= (1.0 + ((itemValue[attacker] + (cod_get_user_intelligence(attacker) * 0.2)) / 100.0));
    }
}
