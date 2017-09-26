#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Pociski Spowalniajace"
#define VERSION "1.0.9"
#define AUTHOR "O'Zone"

#define NAME        "Pociski Spowalniajace"
#define DESCRIPTION "Masz 1/%s szansy na spowolnienia przeciwnika na 3 sekundy przy trafieniu"
#define RANDOM_MIN  7
#define RANDOM_MAX  9
#define UPGRADE_MIN -1
#define UPGRADE_MAX 1
#define VALUE_MIN   2

#define TASK_SLOW 34921

new itemValue[MAX_PLAYERS + 1], Float:oldSpeed[MAX_PLAYERS + 1];

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
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, VALUE_MIN);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(damageBits == DMG_BULLET && random_num(1, itemValue[attacker]) == 1) {
		remove_task(victim + TASK_SLOW);

		cod_display_icon(victim, 255, 0, 0, "dmg_chem", 1);

		oldSpeed[victim] = cod_get_user_speed(victim, ITEM);

		cod_set_user_speed(victim, -220.0, ITEM);

		set_task(3.0, "remove_slow_effect", victim + TASK_SLOW);
	}
}

public cod_new_round()
	for(new id = 1; id <= MAX_PLAYERS; id++) remove_task(id + TASK_SLOW);

public remove_slow_effect(id)
{
	id -= TASK_SLOW;

	if(is_user_connected(id))
	{
		cod_display_icon(id, 255, 0, 0, "dmg_chem", 0);

		cod_set_user_speed(id, oldSpeed[id], ITEM);
	}
}