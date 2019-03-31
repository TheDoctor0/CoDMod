#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Zimne Kule"
#define VERSION "1.1.0"
#define AUTHOR "O'Zone"

#define NAME        "Zimne Kule"
#define DESCRIPTION "Masz 1/%s szansy na zamrozenie przeciwnika na 3 sekundy przy trafieniu"
#define RANDOM_MIN  5
#define RANDOM_MAX  7
#define VALUE_MIN   2

#define TASK_FREEZE 34921

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
		remove_task(victim + TASK_FREEZE);

		cod_display_icon(victim, "dmg_cold", 1, 0, 255, 255);
		cod_display_fade(victim, 3, 3, 0x0000, 0, 255, 255, 40);
		cod_set_user_glow(victim, kRenderFxGlowShell, 0, 255, 255, kRenderNormal, 20, 3.0);

		cod_set_user_speed(victim, COD_FREEZE, ITEM);

		set_task(3.0, "remove_freeze_effect", victim + TASK_FREEZE);
	}
}

public cod_new_round()
	for(new id = 1; id <= MAX_PLAYERS; id++) remove_task(id + TASK_FREEZE);

public remove_freeze_effect(id)
{
	id -= TASK_FREEZE;

	if (is_user_connected(id)) {
		cod_display_icon(id, "dmg_cold");

		cod_set_user_speed(id, 0.0, ITEM);
	}
}