#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Boskie P90"
#define VERSION "1.0.9"
#define AUTHOR "O'Zone"

#define NAME        "Boskie P90"
#define DESCRIPTION "Dostajesz P90, ktore ma nieskonczona amunicje i brak rozrzutu"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
{
	cod_give_weapon(id, CSW_P90);

	cod_set_user_unlimited_ammo(id, true, ITEM, CSW_P90);
	cod_set_user_recoil_eliminator(id, true, ITEM, CSW_P90);
}

public cod_item_disabled(id)
	cod_take_weapon(id, CSW_P90);
