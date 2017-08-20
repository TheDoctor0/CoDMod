#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#include <engine>

new const perk_name[] = "Tajemnica Ninjy";
new const perk_desc[] = "Zmniejszona grawitacja i mniejsza widocznosc na nozu";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("CurWeapon", "Niewidzialnosc", "be", "1=1");
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
 	entity_set_float(id, EV_FL_gravity, 400.0/800.0);
}
	
public cod_perk_disabled(id){
	ma_perk[id] = false;
 	entity_set_float(id, EV_FL_gravity, 1.0);
}

public Spawn(id)
{
	if(!is_user_alive(id))
		return HAM_IGNORED;
		
	if(ma_perk[id])
		entity_set_float(id, EV_FL_gravity, 400.0/800.0);
	
	return HAM_IGNORED;
}

public Niewidzialnosc(id)
{
	if(!ma_perk[id])
		return;

	new render = cod_get_user_invisible(id, 1, 1, 1);
	if( read_data(2) == CSW_KNIFE )
	{
		if(render>74)
			render = 74;
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 75-render);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255-render);
	}
}
