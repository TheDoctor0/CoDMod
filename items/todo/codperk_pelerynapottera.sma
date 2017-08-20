/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <engine>

new const perk_name[] = "Peleryna Pottera";
new const perk_desc[] = "Gdy stoisz w miejscu jestes niewidzialny";

new ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc);
}
public cod_perk_enabled(id)
{
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}
public client_PreThink ( id ) 
{	
	new button2 = get_user_button(id);
	
	if (ma_perk[id] && get_entity_flags(id) & FL_ONGROUND && (!(button2 & (IN_FORWARD+IN_BACK+IN_MOVELEFT+IN_MOVERIGHT)) && is_user_alive(id)))
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 1);
	}
	else set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	
	return PLUGIN_CONTINUE		
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
