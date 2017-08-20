/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <fakemeta>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Twardy Baniak";
new const perk_desc[] = "Nie dostajesz obrazen w glowe";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_forward(FM_TraceLine, "TraceLine");
}
	

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}

public TraceLine(Float:start[3], Float:end[3], conditions, id, trace)
{	
	if(get_tr2(trace, TR_iHitgroup) != HIT_HEAD)
		return FMRES_IGNORED;
		
	new iHit = get_tr2(trace, TR_pHit);
	
	if(!is_user_connected(iHit))
		return FMRES_IGNORED;

	if(!ma_perk[iHit])
		return FMRES_IGNORED;
		
	set_tr2(trace, TR_iHitgroup, 8);
	
	return FMRES_IGNORED;
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
