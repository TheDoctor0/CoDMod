#include <amxmodx>
#include <codmod>

new const perk_name[] = "Rozbrajacz";
new const perk_desc[] = "Masz 1/LW szans na wyrzucenie broni wroga";

new bool:ma_perk[33];
new wartosc_perku[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 3, 5);
	
	register_event("Damage", "Damage", "b", "2!=0");	
	
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}

public Damage(id)
{
	new idattacker = get_user_attacker(id);
	
	if(!is_user_connected(idattacker) || get_user_team(id) == get_user_team(idattacker))
		return PLUGIN_CONTINUE;
	
	if(ma_perk[idattacker] && random_num(1, wartosc_perku[idattacker]) == 1)
		client_cmd(id, "drop");
	
	return PLUGIN_CONTINUE;
}
