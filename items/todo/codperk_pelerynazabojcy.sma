/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <fun>
#include <codmod>

new const perk_name[] = "Peleryna zabojcy";
new const perk_desc[] = "Masz 1 hp oraz jestes niewidzialny";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc);
	register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	set_user_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 255);
	ma_perk[id] = false;
}

public ResetHUD(id)
{
	if(ma_perk[id])
		set_task(0.5, "UstawStalker", id)
}

public UstawStalker(id)
{
	if(is_user_connected(id))
	{
		set_user_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 1);
		set_user_health(id, 1);
	}
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
