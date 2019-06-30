#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Peleryna Niewidka"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Peleryna Niewidka"
#define DESCRIPTION "Po uzyciu jestes niewidzialny do momentu zadania lub otrzymania obrazen"

new itemUsed;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	rem_bit(id, itemUsed);

public cod_item_spawned(id, respawn)
{
	cod_set_user_render(id, 256, ITEM);

	if (!respawn) {
		rem_bit(id, itemUsed);
	}
}

public cod_item_skill_used(id)
{
	if (get_bit(id, itemUsed)) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.45, 0, 0.0, 1.25, 0.0, 0.0, "Peleryny mozesz uzyc tylko raz na runde!");

		return COD_CONTINUE;
	}

	cod_set_user_render(id, 0, ITEM, RENDER_ALWAYS);

	set_bit(id, itemUsed);

	return COD_CONTINUE;
}

public cod_item_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	cod_set_user_render(victim, 256, ITEM);

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	cod_set_user_render(attacker, 256, ITEM);