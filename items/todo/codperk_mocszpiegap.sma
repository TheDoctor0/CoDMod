/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <cstrike>

new const perk_name[] = "Moc szpiega(premium)";
new const perk_desc[] = "Szansa ze odrodzisz sie u wroga 1/LW. Dostajesz 30 wytrzymalosci";

new bool:ma_perk[33], wartosc_perku[33]

public plugin_init()
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc, 1, 3);
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public cod_perk_enabled(id, wartosc)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_B))
	    {
			    client_print(id, print_center, "[Moc szpiega(premium)] Nie masz uprawnien, aby uzywac tego perku.");
			    return COD_STOP;
	    }
	cod_set_user_bonus_stamina(id, cod_get_user_stamina(id, 0, 0)+30);
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	cod_set_user_bonus_stamina(id, cod_get_user_stamina(id, 0, 0)-30);
	ma_perk[id] = false;
}

public Spawn(id)
{
	cod_perk_used(id);
}

public cod_perk_used(id)
{
	if(!is_user_alive(id))
		return;
	
	if(!ma_perk[id])
		return;
	
	if(!random(wartosc_perku[id]))
	{
		new CsTeams:team = cs_get_user_team(id);
		
		cs_set_user_team(id, (team == CS_TEAM_CT)? CS_TEAM_T: CS_TEAM_CT);
		ExecuteHam(Ham_CS_RoundRespawn, id);
		
		cs_set_user_team(id, team);
	}
	
	
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
