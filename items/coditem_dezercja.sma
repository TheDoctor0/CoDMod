#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Dezercja"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

#define NAME        "Dezercja"
#define DESCRIPTION "Masz 1/%s na odrodzenie na respie wroga, masz M4A1 lub AK47 w zaleznosci od druzyny i +10 obrazen z tej broni."
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
	itemValue[id] = value;

	cod_set_user_model(id, true, ITEM);

	cod_give_weapon(id, get_user_team(id) == 1 ? CSW_M4A1 : CSW_AK47);
}

public cod_item_disabled(id)
	cod_take_weapon(id, get_user_team(id) == 1 ? CSW_M4A1 : CSW_AK47);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], .valueMin = VALUE_MIN);

public cod_item_spawned(id, respawn)
{
	cod_take_weapon(id, CSW_M4A1);
	cod_take_weapon(id, CSW_AK47);

	cod_give_weapon(id, get_user_team(id) == 1 ? CSW_M4A1 : CSW_AK47);

	if (random_num(1, itemValue[id]) == 1) cod_teleport_to_spawn(id, 1);
}

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (damageBits == DMG_BULLET && ((get_user_team(attacker) == 1 && weapon == CSW_AK47) || (get_user_team(attacker) == 2 && weapon == CSW_M4A1))) damage += 10.0;