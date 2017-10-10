#include <amxmodx>
#include <reapi>
#include <cod>

#define PLUGIN "CoD Item Trojace Oslepienie"
#define VERSION "1.0.10"
#define AUTHOR "O'Zone"

#define NAME        "Trojace Oslepienie"
#define DESCRIPTION "Dostajesz 2 flashe. 1/%s na zatrucie przeciwnika po jego oslepieniu."
#define RANDOM_MIN  2
#define RANDOM_MAX  4
#define VALUE_MIN   1

new itemValue[MAX_PLAYERS + 1], itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	cod_give_weapon(id, CSW_FLASHBANG, 2);

	set_bit(id, itemActive);
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_FLASHBANG);

public PlayerBlind(const index, const inflictor, const attacker, const Float:fadeTime, const Float:fadeHold, const alpha, Float:color[3])
{
	if (index != attacker && (get_member(index, m_iTeam) != get_member(attacker, m_iTeam)) && fadeHold >= 0.5 && alpha && color[0] == 255.0 && color[1] == 255.0 && color[2] == 255.0) {
		if (get_bit(attacker, itemActive) && random_num(1, itemValue[attacker]) == 1) cod_repeat_damage(attacker, index, 5.0, 1.0, 10, POISON);
	}
}
public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], .valueMin = VALUE_MIN);
