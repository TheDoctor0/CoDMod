/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <engine>

new const perk_name[] = "Grawitacja";
new const perk_desc[] = "Masz 300/800 grawitacji";

new bool:ma_perk[33]

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem")
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_class_enabled(id, wartosc)
{
	ma_perk[id] = true;
	entity_set_float(id, EV_FL_gravity, 300.0/800.0);
}
public cod_class_disabled(id)
{
	ma_perk[id] = false;
	entity_set_float(id, EV_FL_gravity, 800.0/800.0);
}

public ResetHUD(id)
{
	if(ma_perk[id])
		entity_set_float(id, EV_FL_gravity, 300.0/800.0);
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
