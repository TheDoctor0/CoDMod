#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Pociski Spowalniajace"
#define VERSION "1.0.39"
#define AUTHOR "O'Zone"

#define NAME        "Pociski Spowalniajace"
#define DESCRIPTION "Masz 1/%s szansy na spowolnienia przeciwnika na 3 sekundy przy trafieniu"
#define RANDOM_MIN  5
#define RANDOM_MAX  7
#define VALUE_MIN   2

#define TASK_SLOW 34921

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
{
	if (damageBits & DMG_BULLET && random_num(1, itemValue[attacker]) == 1) {
		remove_task(victim + TASK_SLOW);

		cod_display_icon(victim, "dmg_cold", 1, 0, 255, 255);
		cod_display_fade(victim, 3, 3, 0x0000, 0, 255, 255, 40);

		cod_set_user_speed(victim, -200.0, ITEM);

		set_task(3.0, "remove_slow_effect", victim + TASK_SLOW);
	}
}

public cod_new_round()
	for(new id = 1; id <= MAX_PLAYERS; id++) remove_task(id + TASK_SLOW);

public remove_slow_effect(id)
{
	id -= TASK_SLOW;

	if (is_user_connected(id))
	{
		cod_display_icon(id, "dmg_cold");

		cod_set_user_speed(id, 0.0, ITEM);
	}
}