#include <amxmodx>
#include <engine>
#include <cod>

#define PLUGIN "CoD Item Braterstwo"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Braterstwo"
#define DESCRIPTION "Bedac niedaleko osoby z druzyny zadajesz o %s procent wieksze obrazenia"
#define RANDOM_MIN  35
#define RANDOM_MAX  50
#define UPGRADE_MIN -2
#define UPGRADE_MAX 3
#define VALUE_MAX   100

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
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, .valueMax = VALUE_MAX);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	new entList[MAX_PLAYERS], player, numFound = find_sphere_class(attacker, "player", 150.0, entList, charsmax(entList));

	for (new i = 0; i < numFound; i++) {
		player = entList[i];

		if (!is_user_alive(player) || attacker == player || get_user_team(player) != get_user_team(attacker)) continue;

		damage *= (1.0 + (itemValue[attacker] / 150.0));

		break;
	}
}