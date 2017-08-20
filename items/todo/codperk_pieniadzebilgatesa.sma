/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <fun>
#include <cstrike>

new const perk_name[] = "Pieniadze Bil Gates'a";
new const perk_desc[] = "Dostajesz 16000$ co runde";
new bool:ma_perk[33];

public plugin_init()
{
        register_plugin(perk_name, "1.0", "bulka_z_maslem");
  
        cod_register_perk(perk_name, perk_desc);
}
public cod_perk_enabled(id)
{
	new kasa = cs_get_user_money(id)

	cs_set_user_money(id, kasa + 16000) 	
        ma_perk[id] = true;
}
public cod_perk_disabled(id)
{
	new kasa = cs_get_user_money(id)

	cs_set_user_money(id, kasa - 16000) 
        ma_perk[id] = false;
}
	
/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1045{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
