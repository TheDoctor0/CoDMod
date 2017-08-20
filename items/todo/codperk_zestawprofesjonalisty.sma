/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>

new const perk_name[] = "Zestaw profesjonalisty";
new const perk_desc[] = "Dostajesz awp, m4 i ak";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_AWP);
	cod_give_weapon(id, CSW_M4A1);
	cod_give_weapon(id, CSW_AK47);
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_AWP);
	cod_take_weapon(id, CSW_M4A1);
	cod_take_weapon(id, CSW_AK47);
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
