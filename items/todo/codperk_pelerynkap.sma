/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <engine>

new const perk_name[] = "Pelerynka(premium)";
new const perk_desc[] = "Twoja widocznosc spada do 1";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_B))
	    {
			    client_print(id, print_center, "[Pelerynka(premium)] Nie masz uprawnien, aby uzywac tego perku.");
			    return COD_STOP;
	    }
	set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 1);
	return COD_CONTINUE;
}
	
public cod_perk_disabled(id)
	set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 255);

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
