/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#include <fun>

#define DMG_HEGRENADE (1<<24)

new const perk_name[] = "Amulet(premium)";
new const perk_desc[] = "Zadajesz LW obrazen wiecej, 1/2 z HE";

new bool:ma_perk[33];
new wartosc_perku[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");

	cod_register_perk(perk_name, perk_desc, 25, 45);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_B))
	    {
			    client_print(id, print_center, "[Amulet(premium)] Nie masz uprawnien, aby uzywac tego perku.");
			    return COD_STOP;
	    }
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_HEGRENADE);
	wartosc_perku[id] = wartosc;
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_HEGRENADE);
	ma_perk[id] = false;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
		cod_inflict_damage(idattacker, this, float(wartosc_perku[idattacker]), 0.0, idinflictor, damagebits);

	if(damagebits & DMG_HEGRENADE && random_num(1, 2) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	return HAM_IGNORED;
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
