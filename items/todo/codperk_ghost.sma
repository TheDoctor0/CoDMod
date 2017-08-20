#include <amxmodx>
#include <engine>
#include <codmod>
#include <fun>
#include <hamsandwich>

new const perk_name[] = "Ghost";
new const perk_desc[] = "Posiadasz 1 hp i jestes calkowicie niewidzialny";

new wartosc_perku[33]=0;
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 15, 15);
	
	register_event("Health", "Health", "be")
	
	RegisterHam(Ham_Spawn,"player","Spawn");
}

public cod_perk_enabled(id, wartosc){
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	set_user_health(id, 1);
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 1);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	new hp = 100 + cod_get_user_health(id, 1, 1, 1);
	set_user_health(id, hp);
}

public Health(id)
{
	if(ma_perk[id] && is_user_alive(id) && read_data(1) > 1)
	{
		set_user_health(id, 1);
	}
	return PLUGIN_CONTINUE;
}

public Spawn(id){
	if(ma_perk[id])
		set_task(1.0,"UstawRender",id)
	return PLUGIN_CONTINUE;
}
public UstawRender(id)
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 1);
