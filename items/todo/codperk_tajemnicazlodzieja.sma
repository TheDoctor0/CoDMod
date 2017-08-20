/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>

new const perk_name[] = "Tajemnica Zlodzieja"
new const perk_desc[] = "1/LW na zabranie perku swojej ofierze"

new bool:ma_perk[33], wartosc_perku[33]

public plugin_init()
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem")
	
	cod_register_perk(perk_name, perk_desc, 4, 6)
	
	RegisterHam(Ham_Killed, "player", "Kill")
}
public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true
	wartosc_perku[id] = wartosc;
}
public cod_perk_disabled(id)
{	
	ma_perk[id] = false
}
public Kill(a, b, idattacker)
{
	if(ma_perk[b] && cod_get_user_perk(a) != 0 && random_num(1, wartosc_perku[idattacker])==1)
	{
		cod_set_user_perk(b, cod_get_user_perk(a))
		cod_set_user_perk(a, 0)
	}
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
