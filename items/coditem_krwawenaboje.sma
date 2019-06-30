#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Krwawe Naboje"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Krwawe Naboje"
#define DESCRIPTION "Wraz ze spadkiem twojego zycia rosna zadawane obrazenia (-1% zycia = +1% obrazen)"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	new health = cod_get_user_health(attacker, 1), maxHealth = cod_get_user_max_health(attacker);

	if (health < maxHealth) {
        damage *= (1.0 + 1.0 - float(health / maxHealth));
    }
}
