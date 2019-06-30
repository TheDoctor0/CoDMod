#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Tytanowe Pociski"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Tytanowe Pociski"
#define DESCRIPTION "Zadajesz o %s (+int) wieksze obrazenia"
#define RANDOM_MIN  5
#define RANDOM_MAX  7

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
	itemValue[id] = value;

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id]);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits & DMG_BULLET) {
        damage += (float(itemValue[attacker]) + cod_get_user_intelligence(attacker) * 0.05);
    }
}
