#include <amxmodx>
#include <codmod>
#include <fakemeta>

new const perk_name[] = "Maksymalne skupienie";
new const perk_desc[] = "Za kazdego fraga dostajesz dodatkowe 400 doswiadczenia";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("DeathMsg", "Death", "ade");
}

public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
	ma_perk[id] = false;

public Death()
{
	new kid = read_data(1);
	if(!is_user_connected(kid) || get_user_team(read_data(2)) == get_user_team(kid))
		return PLUGIN_CONTINUE;
	
	if(!ma_perk[kid])
		return PLUGIN_CONTINUE;
		
      cod_add_user_xp(kid, 400);
	
	return PLUGIN_CONTINUE;
}
