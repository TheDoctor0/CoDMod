#include <amxmodx>
#include <codmod>

new const perk_name[] = "Kamuflaz";
new const perk_desc[] = "Twoja widocznosc spada do LW";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc, 30, 70);
}

public cod_perk_enabled(id, wartosc)
	cod_set_user_rendering(id, wartosc)
	
public cod_perk_disabled(id)
	cod_remove_user_rendering(id)
