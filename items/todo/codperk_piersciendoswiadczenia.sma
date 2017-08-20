#include <amxmodx>
#include <codmod>
#include <fakemeta>


new const perk_name[] = "Pierscien Doswiadczenie";
new const perk_desc[] = "Za kadego fraga dostajesz +SW wiecej expa";

new wartosc_perku[33] = 0;
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 50, 50);
	
	register_event("DeathMsg", "Death", "ade");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public Death()
{
	new attacker = read_data(1);
	new id = read_data(2);
	if(!is_user_connected(attacker))
		return PLUGIN_CONTINUE;
	
	if(!ma_perk[attacker])
		return PLUGIN_CONTINUE;
		
	if(get_user_team(id) != get_user_team(attacker))
		cod_set_user_xp(id, wartosc_perku[id]);
	
	return PLUGIN_CONTINUE;
}
