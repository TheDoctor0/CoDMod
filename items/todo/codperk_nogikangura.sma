#include <amxmodx>
#include <codmod>
#include <fakemeta>

new const perk_name[] = "Nogi kangura";
new const perk_desc[] = "Gdy trafiasz przeciwnika masz 1/2 szansy, ze podskoczy";

new bool:ma_perk[33]

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Nogi kangura");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("Damage", "Damage", "b", "2!=0");	
}

public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
	ma_perk[id] = false;

public Damage(id)
{
	new idattacker = get_user_attacker(id);
	
	if(!is_user_connected(idattacker) || get_user_team(id) == get_user_team(idattacker))
		return PLUGIN_CONTINUE;
	
	if(ma_perk[idattacker] && !random(2))
		set_pev(id, pev_velocity, Float:{0.0, 0.0, 260.0});
	
	return PLUGIN_CONTINUE;
}
