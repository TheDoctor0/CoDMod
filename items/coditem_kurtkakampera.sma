#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Kurtka Kampera"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Kurtka Kampera"
#define DESCRIPTION "Jestes niewidoczny podczas bezruchu do momentu otrzymania obrazen."

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	cod_set_user_render(id, 20, ITEM, RENDER_STAND);

public cod_item_spawned(id, respawn)
{
	if (!respawn) {
		cod_set_user_render(id, 20, ITEM, RENDER_STAND);
	}
}

public cod_item_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	cod_set_user_render(victim, 256, ITEM);