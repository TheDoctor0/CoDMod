#include <amxmodx>
#include <fun>
#include <hamsandwich>
#include <codmod>

#define CZAS_GODMOD 3 //SEKUND

new const perk_name[] = "Straszydlo";
new const perk_desc[] = "Masz 1/5 na wyrzucenie broni przeciwnika, 3s niesmiertelnosci";

new bool:wykorzystal[33];
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	register_event("ResetHUD", "ResetHUD", "abe");
	register_event("Damage", "Damage_Wyrzucenie", "b", "2!0");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	ResetHUD(id);
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public cod_perk_used(id)
{
	if(!is_user_alive(id))
		return;
		
	if(wykorzystal[id])
	{
		client_print(id, print_center, "Wykorzystales juz swoja niesmiertelnosc.");
		return;
	}
	
	wykorzystal[id] = true;
	
	set_user_godmode(id, 1);
	set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0);
	set_task(CZAS_GODMOD.0, "WylaczGod", id);
}

public WylaczGod(id)
{
	if(!is_user_connected(id)) return;
	
	set_user_godmode(id, 0);
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0);
	cod_refresh_rendering(id)
}

public ResetHUD(id)
	wykorzystal[id] = false;

public Damage_Wyrzucenie(id)
{
	new idattacker = get_user_attacker(id);

	if(!is_user_alive(idattacker) || id == idattacker)
		return;

	if(!ma_perk[idattacker])
		return;

	if(!random(5))
	{
            new wpnname[33]
            get_weaponname(get_user_weapon(id), wpnname, charsmax(wpnname))
		engclient_cmd(id, "drop", wpnname);
      }
}
