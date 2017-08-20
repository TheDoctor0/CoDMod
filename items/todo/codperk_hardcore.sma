#include <amxmodx>
#include <codmod>

new const perk_name[] = "Hardcore";
new const perk_desc[] = "Dostajesz M4A1, oraz +40 wytrzymalosci";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Hajto !");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_M4A1);
	cod_add_user_bonus_stamina(id, 40);
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_M4A1);
	cod_add_user_bonus_stamina(id, -40);
}