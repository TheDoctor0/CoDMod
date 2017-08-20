#include <amxmodx>
#include <codmod>
#include <fakemeta>

new const perk_name[] = "Apteczka";
new const perk_desc[] = "Raz na runde mozesz sie calkowicie uleczyc";

new bool:perk_uzyty[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);

	register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_perk_enabled(id)
	perk_uzyty[id] = false;
	
public cod_perk_used(id)
{
	if(perk_uzyty[id])
	{
		client_print(id, print_center, "Apteczki mozna uzyc raz na runde");
		return PLUGIN_CONTINUE;
	}
		
	new Float:max_health = 100.0+cod_get_user_health(id);
	
	if(get_user_health(id) >= max_health)
		return PLUGIN_CONTINUE;
		
	set_pev(id, pev_health, max_health);
	perk_uzyty[id] = true;
	
	return PLUGIN_CONTINUE;
}

public ResetHUD(id)
	perk_uzyty[id] = false;
