#include <amxmodx>
#include <codmod>

new const perk_name[] = "Naszyjnik wytrzymalosci";
new const perk_desc[] = "Dostajesz 90 wytrzymalosci";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
	cod_add_user_bonus_stamina(id, 90);

public cod_perk_disabled(id)
	cod_add_user_bonus_stamina(id, -90);
