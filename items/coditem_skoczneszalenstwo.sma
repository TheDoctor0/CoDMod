#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Skoczne Szalenstwo"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Skoczne Szalenstwo"
#define DESCRIPTION "Masz BunnyHopa, mniejsza widocznosc na nozu i 1/%s na zabicie z kosy"
#define RANDOM_MIN  3
#define RANDOM_MAX  5
#define VALUE_MIN   2

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	cod_set_user_bunnyhop(id, true, ITEM);
	cod_set_user_render(id, 50, ITEM, 1<<CSW_KNIFE);
}

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], .valueMin = VALUE_MIN);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (weapon == CSW_KNIFE && random_num(1, itemValue[attacker]) == 1) {
        damage = cod_kill_player(attacker, victim, damageBits);
    }
}
