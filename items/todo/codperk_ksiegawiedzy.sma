/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>

new const perk_name[] = "Ksiega wiedzy";
new const perk_desc[] = "+50 do kazdej statystyki";

public plugin_init()
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");

	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
{
	cod_set_user_bonus_stamina(id, cod_get_user_stamina(id, 0, 0)+50);
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0)+50);
	cod_set_user_bonus_intelligence(id, cod_get_user_intelligence(id, 0, 0)+50);
	cod_set_user_bonus_health(id, cod_get_user_health(id, 0, 0)+50);
}

public cod_perk_disabled(id)
{
	cod_set_user_bonus_stamina(id, cod_get_user_stamina(id, 0, 0)-50);
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0)-50);
	cod_set_user_bonus_intelligence(id, cod_get_user_intelligence(id, 0, 0)-50);
	cod_set_user_bonus_health(id, cod_get_user_health(id, 0, 0)-50);
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
