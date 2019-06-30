#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Obcy"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Obcy"
#define DESCRIPTION "Zabicie przeciwnika powoduje jego eksplozje zadajaca 100 (+int) obrazen"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_kill(killer, victim, hitPlace)
	cod_make_explosion(victim, 200, 1, 200.0, 100.0 + cod_get_user_intelligence(killer));
