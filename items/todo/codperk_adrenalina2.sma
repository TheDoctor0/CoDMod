#include <amxmodx>
#include <codmod>
#include <fun>

new const nazwa[] = "Adrenalina";
new const opis[] = "Za kazdego fraga dostajesz +50 hp";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);
	
	register_event("DeathMsg", "Death", "ade");
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
	ma_perk[id] = false;

public Death()
{
	new attacker = read_data(1);
	
	if(!is_user_alive(attacker))
		return PLUGIN_CONTINUE;
		
	if(!ma_perk[attacker])
		return PLUGIN_CONTINUE;
		
	set_user_health(attacker, get_user_health(attacker)+50);
	
	return PLUGIN_CONTINUE;
}