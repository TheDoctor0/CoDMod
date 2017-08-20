/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>

new const perk_name[] = "Geniusz(premium)";
new const perk_desc[] = "Dostajesz 100 inteligencji";

public plugin_init()
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");

	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_B))
	    {
			    client_print(id, print_center, "[Geniusz(premium)] Nie masz uprawnien, aby uzywac tego perku.");
			    return COD_STOP;
	    }
	cod_set_user_bonus_intelligence(id, cod_get_user_intelligence(id, 0, 0)+100);
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	cod_set_user_bonus_intelligence(id, cod_get_user_intelligence(id, 0, 0)-100);
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
