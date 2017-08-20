/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>

new const perk_name[] = "Wyrzutnik(premium)";
new const perk_desc[] = "Masz 1/LW szans na wyrzucenie broni przeciwnika oraz dostajesz 30 hp";

new bool:ma_perk[33], wartosc_perku[33]

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc, 2, 4);
	
	register_event("Damage", "Damage", "b", "2!=0");	
}

public cod_perk_enabled(id, wartosc)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_B))
	    {
			    client_print(id, print_center, "[Wyrzutnik(premium)] Nie masz uprawnien, aby uzywac tego perku.");
			    return COD_STOP;
	    }
	cod_set_user_bonus_health(id, cod_get_user_health(id, 0, 0)+30);
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	cod_set_user_bonus_health(id, cod_get_user_health(id, 0, 0)-30);
	ma_perk[id] = false;
}
	
public Damage(id)
{
	new idattacker = get_user_attacker(id);
	
	if(!is_user_alive(idattacker))
		return;
	
	if(!ma_perk[idattacker])
		return;
		
	if(random_num(1, wartosc_perku[idattacker]) != 1)
		return;
	
	client_cmd(id, "drop");
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
