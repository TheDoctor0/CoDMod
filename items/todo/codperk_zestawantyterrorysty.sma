/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <codmod>

new const perk_name[] = "Zestaw anty-terrorysty";
new const perk_desc[] = "Dostajesz m4(1/10 z niego) oraz five-seven(1/5 z niego)";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_M4A1);
	cod_give_weapon(id, CSW_FIVESEVEN);
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_M4A1);
	cod_take_weapon(id, CSW_FIVESEVEN);
	ma_perk[id] = false;
}
	
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(get_user_weapon(idattacker) == CSW_M4A1 && random_num(1,10) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	if(get_user_weapon(idattacker) == CSW_FIVESEVEN && random_num(1,5) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	return HAM_IGNORED;
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
