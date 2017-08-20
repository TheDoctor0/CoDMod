/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <engine>

#define FALL_VELOCITY 350.0

new const perk_name[] = "Mocne nogi";
new const perk_desc[] = "Nie tracisz HP spadajac z wysokosci";


new bool:ma_perk[33];
new bool:falling[33];

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
	ma_perk[id] = false;

public client_PreThink(id) 
{
	if(ma_perk[id] && is_user_alive(id) && is_user_connected(id)) 
	{
		if(entity_get_float(id, EV_FL_flFallVelocity) >= FALL_VELOCITY) 
		{
			falling[id] = true;
		} 
		else 
		{
			falling[id] = false;
		}
	}
}

public client_PostThink(id) 
{
	if(ma_perk[id] && is_user_alive(id) && is_user_connected(id)) 
	{
		if(falling[id]) {
			entity_set_int(id, EV_INT_watertype, -3);
		}
	}
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
