/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
 
#include <amxmodx>
#include <codmod>
#include <cstrike>
 
new const perk_name[] = "Granaty";
new const perk_desc[] = "Co runde dostajesz 10 granatow kazdego rodzaju";
 
new bool:ma_perk[33];
 
public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc);
	register_event("ResetHUD", "ResetHUD", "abe");
}
 
public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_HEGRENADE);
	cod_give_weapon(id, CSW_SMOKEGRENADE);
	cod_give_weapon(id, CSW_FLASHBANG);
	ma_perk[id] = true;
}
 
public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_HEGRENADE);
	cod_take_weapon(id, CSW_SMOKEGRENADE);
	cod_take_weapon(id, CSW_FLASHBANG);
	ma_perk[id] = false;
}
 
public ResetHUD(id)
	set_task(0.1, "ResetHUDx", id);
	
public ResetHUDx(id)
{
	if(!is_user_connected(id)) return;
	
	if(!ma_perk[id]) return;
	
	cs_set_user_bpammo(id, CSW_HEGRENADE, 10);
	cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 10);
	cs_set_user_bpammo(id, CSW_FLASHBANG, 10);
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
