/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <fakemeta>

new const perk_name[] = "Jumper";
new const perk_desc[] = "Masz 5 skokow oraz co 5 sek modul";

new bool:ma_perk[33];
new skoki[33];
new Float:modul[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem")
	cod_register_perk(perk_name, perk_desc);
	
	register_forward(FM_CmdStart, "CmdStart");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
}
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}

public cod_perk_used(id)
{
	new flags = pev(id, pev_flags);
	
	if(flags & FL_ONGROUND && get_gametime() > modul[id]+5.0)
	{
		modul[id] = get_gametime();
		new Float:velocity[3];
		velocity_by_aim(id, 666+cod_get_user_intelligence(id), velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity, velocity);
	}
}

public CmdStart(id, uc_handle)
{
	if(!is_user_alive(id) || !ma_perk[id])
		return FMRES_IGNORED;
	
	new flags = pev(id, pev_flags);
	
	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id])
	{
		skoki[id]--;
		new Float:velocity[3];
		pev(id, pev_velocity,velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity,velocity);
	}
	else if(flags & FL_ONGROUND)
		skoki[id] = 4;
	
	return FMRES_IGNORED;
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1250\\ deff0\\ deflang1045{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
