#include <amxmodx>
#include <codmod>
#include <fun>
#include <hamsandwich>
#include <fakemeta>

new const perk_name[] = "Intelekt O'Zone";
new const perk_desc[] = "Masz 1/SW szansy na zmiane trajektorii lotu kuli na glowe przy trafieniu, +40 kondycji, masz ciche buty";

new wartosc_perku[33] = 0;
new bool:ma_perk[33];

native cod_item_status(id);

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 3, 4);
	
	register_forward(FM_TraceLine, "fw_traceline");
	register_forward(FM_TraceHull, "fw_tracehull", 1);
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	set_user_footsteps(id, 1);
	cod_set_user_bonus_trim(id, 40);
}

public cod_perk_disabled(id){
	ma_perk[id] = false;
	set_user_footsteps(id, 0);
	cod_set_user_bonus_trim(id, 0);
}

public fw_traceline(Float:start[3], Float:end[3], conditions, id, ptr)
	return process_trace(id, ptr)

public fw_tracehull(Float:start[3], Float:end[3], conditions, hull, id, ptr)
	return process_trace(id, ptr)

public process_trace(id, ptr)
{
	if (!is_user_alive(id) || !ma_perk[id]) 
		return FMRES_IGNORED
	
	if(random_num(1, wartosc_perku[id]) != 1)
		return FMRES_IGNORED
	
	new target = get_tr2(ptr, TR_pHit)
	
	if (!is_user_alive(target)) 
		return FMRES_IGNORED
	
	new perk_name[33];
	cod_get_perk_name(target, perk_name, 32);
	if(containi(perk_name, "Helm"))
		return FMRES_IGNORED
		
	if(cod_item_status(target))
		return FMRES_IGNORED
		
	new Float:origin[3], Float:angles[3]
	engfunc(EngFunc_GetBonePosition, target, 8, origin, angles)
	set_tr2(ptr, TR_vecEndPos, origin)
	set_tr2(ptr, TR_iHitgroup, HIT_HEAD)
	
	return FMRES_IGNORED
}
