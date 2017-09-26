#include <amxmodx>
#include <engine>
#include <cod>

#define PLUGIN "CoD Item Braterstwo"
#define VERSION "1.0.11"
#define AUTHOR "O'Zone"

#define NAME        "Braterstwo"
#define DESCRIPTION "Bedac niedaleko osoby z druzyny zadajesz o %s procent wieksze obrazenia"
#define RANDOM_MIN  15
#define RANDOM_MAX  20
#define UPGRADE_MIN -2
#define UPGRADE_MAX 3
#define VALUE_MAX   50

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
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, _, VALUE_MAX);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	new entList[32], player, numFound = find_sphere_class(attacker, "player", 100.0, entList, charsmax(entList));
	
	for(new i = 0; i < numFound; i++) {
		player = entList[i];

		if(!is_user_alive(player) || attacker == player || get_user_team(player) != get_user_team(attacker)) continue;

		damage *= (itemValue[attacker] / 100.0);

		break;
	}
}