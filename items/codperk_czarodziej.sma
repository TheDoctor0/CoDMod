#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <codmod>

new const perk_name[] = "Czarodziej";
new const perk_desc[] = "Gdy kucasz jestes praktycznie niewidzialny";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_forward(FM_PlayerPreThink, "Niewidzialnosc", 1);
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	ma_perk[id] = false;
}

public Niewidzialnosc(id)
{
	if(!ma_perk[id])
		return;

	new button = get_user_button(id);
	if(button & IN_DUCK){
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 20);
	}
	else{
		new render = cod_get_user_invisible(id, 1, 1, 1);
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255-render);
	}
}
