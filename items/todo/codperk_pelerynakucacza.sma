/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <engine>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Peleryna Kucacza";
new const perk_desc[] = "Podczas kucania z nozem jestes slabo widoczny";

new bool:ma_perk[33];

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

public client_PreThink(id)
{
	if(!ma_perk[id])
		return;
		
	if(get_user_button(id) & IN_DUCK && get_user_weapon(id) == CSW_KNIFE)
		set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 10);
	else
		set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255);
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
