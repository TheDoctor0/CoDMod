/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Pro naboje(premium)";
new const perk_desc[] = "Zadajesz 60 procent obrazen wiecej";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_B))
	    {
			    client_print(id, print_center, "[Pro naboje(premium)] Nie masz uprawnien, aby uzywac tego perku.");
			    return COD_STOP;
	    }
	ma_perk[id] = true;
	return COD_CONTINUE;
}
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}


public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
		cod_inflict_damage(idattacker, this, damage*0.6, 0.0, idinflictor, damagebits);

	return HAM_IGNORED;
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
