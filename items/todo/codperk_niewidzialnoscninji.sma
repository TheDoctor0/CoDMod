/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <engine>

new const perk_name[] = "Niewidzialnosc ninji";
new const perk_desc[] = "Twoja widocznosc spada do LW";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc, 20, 100);
}

public cod_perk_enabled(id, wartosc)
{
	set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, wartosc);
}
	
public cod_perk_disabled(id)
	set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 255);

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
