/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <fakemeta>

new const perk_name[] = "Buty skoczka";
new const perk_desc[] = "Masz 5 skokow w powietrzu";

new bool:ma_perk[33]

new skoki[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem")
	
	cod_register_perk(perk_name, perk_desc);
	
	register_forward(FM_CmdStart, "CmdStart");
}

public cod_class_enabled(id, wartosc)
{
	ma_perk[id] = true;
}
public cod_class_disabled(id)
{
	ma_perk[id] = false;
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
		skoki[id] = 5;
	
	return FMRES_IGNORED;
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
