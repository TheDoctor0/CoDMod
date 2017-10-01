#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item AWP Nevermore"
#define VERSION "1.0.14"
#define AUTHOR "O'Zone"

#define NAME        "AWP Nevermore"
#define DESCRIPTION "Masz 1/2 szansy na zabicie z AWP i 20 procent widocznosci z nim. Dostajesz +%s zycia"
#define RANDOM_MIN  20
#define RANDOM_MAX  25
#define UPGRADE_MIN -2
#define UPGRADE_MAX 4

new itemValue[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	itemValue[id] = value;

	cod_add_user_bonus_health(id, itemValue[id]);

	cod_set_user_render(id, 50, ITEM, RENDER_ALWAYS, CSW_AWP);

	cod_give_weapon(id, CSW_AWP);
}

public cod_item_disabled(id)
{
	cod_add_user_bonus_health(id, -itemValue[id]);

	cod_take_weapon(id, CSW_AWP);
}

public cod_item_upgrade(id)
{
	cod_add_user_bonus_health(id, -itemValue[id]);

	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);

	cod_add_user_bonus_health(id, itemValue[id]);
}

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if(weapon == CSW_AWP && damageBits & DMG_BULLET && random_num(1, 2) == 1) damage = cod_kill_player(attacker, victim, damageBits);
