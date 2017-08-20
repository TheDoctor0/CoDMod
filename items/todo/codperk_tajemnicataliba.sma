/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Tajemnica Taliba";
new const perk_desc[] = "Masz 1/LW na zabicie z deagle'a";

new bool:ma_perk[33], wartosc_perku[33]

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc, 4, 6);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_DEAGLE);
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_take_weapon(id, CSW_DEAGLE);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(!ma_perk[idattacker])
		return HAM_IGNORED;

	if(get_user_weapon(idattacker) == CSW_DEAGLE && get_user_team(this) != get_user_team(idattacker) && random_num(1, wartosc_perku[idattacker]) == 1 && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
