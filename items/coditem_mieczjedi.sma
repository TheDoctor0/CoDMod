#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Miecz Jedi"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define NAME        "Miecz Jedi"
#define DESCRIPTION "1/2 na natychmiastowe zabicie z kosy i 1/%s na odbicie pocisku na nozu"
#define RANDOM_MIN  4
#define RANDOM_MAX  5
#define VALUE_MIN   2

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
	cod_random_upgrade(itemValue[id], .valueMin = VALUE_MIN);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (weapon == CSW_KNIFE && cod_percent_chance(50)) damage = cod_kill_player(attacker, victim, damageBits);

public cod_item_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits == DMG_BULLET && random_num(1, itemValue[victim]) == 1 && get_user_weapon(victim) == CSW_KNIFE) {
		damage = COD_BLOCK;

		cod_inflict_damage(victim, attacker, damage, 0.0, DMG_BULLET);
	}
}
