/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <fun>
#include <codmod>

new nazwa[] = "Adidaski"
new opis[] = "Dostajesz 50 kondycji oraz nie slychac twoich krokow"


public plugin_init() 
{
	register_plugin(nazwa, "1.0", "bulka_z_maslem");
	
	cod_register_perk(nazwa, opis);
}

public cod_perk_enabled(id)
{
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0)+50);
	set_user_footsteps(id, 1);
}
	
public cod_perk_disabled(id)
{
	set_user_footsteps(id, 0);
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0)-50);
}
	
/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
