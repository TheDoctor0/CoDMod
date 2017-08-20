/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <hamsandwich>

#define ZADANIE_WSKRZES 6240

new const perk_name[] = "Niesmiertelnik(premium)";
new const perk_desc[] = "Masz 1/LW szans na odrodzenie sie po smierci, dostajesz 30 inteligencji";

new wartosc_perku[33];
new bool:ma_perk[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc, 1, 2);
	
	RegisterHam(Ham_Killed, "player", "Killed", 1);
}

public cod_perk_enabled(id, wartosc)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_B))
	    {
			    client_print(id, print_center, "[Niesmiertelnik(premium)] Nie masz uprawnien, aby uzywac tego perku.");
			    return COD_STOP;
	    }
	cod_set_user_bonus_intelligence(id, cod_get_user_intelligence(id, 0, 0)+30);
	wartosc_perku[id] = wartosc;
	ma_perk[id] = true;
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	cod_set_user_bonus_intelligence(id, cod_get_user_intelligence(id, 0, 0)-30);
	ma_perk[id] = false;
}

public Killed(id)
{
	if(ma_perk[id] && random_num(1, wartosc_perku[id]) == 1)
		set_task(0.1, "Wskrzes", id+ZADANIE_WSKRZES);
}

public Wskrzes(id)
	ExecuteHamB(Ham_CS_RoundRespawn, id-ZADANIE_WSKRZES);

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
