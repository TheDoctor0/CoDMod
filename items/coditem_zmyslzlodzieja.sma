#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Zmysl Zlodzieja"
#define VERSION "1.0.10"
#define AUTHOR "O'Zone"

#define NAME        "Zmysl Zlodzieja"
#define DESCRIPTION "20 procent szansy na kradziez %s$ po trafieniu przeciwnika. Uzyj, aby zamienic pieniadze na zycie"
#define RANDOM_MIN  500
#define RANDOM_MAX  1000
#define UPGRADE_MIN -75
#define UPGRADE_MAX 150

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
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (cod_percent_chance(20) && cod_get_user_money(attacker) < MAX_MONEY) {
		new money = min(cod_get_user_money(victim), itemValue[attacker]), neededMoney = MAX_MONEY - cod_get_user_money(attacker);

		if (neededMoney < money) money = neededMoney;

		if (money) {
			cod_add_user_money(attacker, money);
			cod_add_user_money(victim, -money);
		}
	}
}

public cod_item_skill_used(id)
{
	if (cod_get_user_health(id) >= cod_get_user_max_health(id)) return;

	if (cod_get_user_money(id) < 1000)
	{
		cod_show_hud(id, TYPE_DHUD, 255, 0, 0, -1.0, 0.45, 0, 0.0, 1.25, 0.0, 0.0, "Nie masz wystarczajaco pieniedzy na ich wymiane na zycie.");

		return;
	}

	cod_add_user_money(id, -1000);
		
	cod_add_user_health(id, 10);	
	
	cod_display_fade(id, 1, 1, 0x0000, 255, 0, 0, 15);
}
