/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <fun>

new bool:ma_perk[33];

new const perk_name[] = "Doswiadczenie vipa";
new const perk_desc[] = "Dostajesz 30 expa za fraga";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem")
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("DeathMsg", "Death", "ade");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}
	
public Death(id)
{
		new attacker = read_data(1);
		if(!is_user_connected(attacker))
				return PLUGIN_CONTINUE;

		if(!ma_perk[attacker])
				return PLUGIN_CONTINUE;

		if(get_user_team(id) != get_user_team(attacker))
				cod_set_user_xp(id, cod_get_user_xp(id)+30);

		return PLUGIN_CONTINUE;
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
