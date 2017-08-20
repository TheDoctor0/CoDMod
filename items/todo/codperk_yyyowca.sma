#include <amxmodx>
#include <codmod>

new const perk_name[] = "Auto Snajper II";
new const perk_desc[] = "Dostajesz SG550";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
	cod_give_weapon(id, CSW_SG550);
	
public cod_perk_disabled(id)
	cod_take_weapon(id, CSW_SG550);