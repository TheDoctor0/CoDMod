#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <codmod>

#define DMG_BULLET (1<<1)
#define DMG_AWP (1<<4)

new const perk_name[] = "Przyczajony Sniper";
new const perk_desc[] = "Jestes prawie niewidzialny i masz 1/4 na natychmiastowe zabicie z AWP";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Pas");
	
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_perk_enabled(id)
{
	client_print(id, print_chat, "Perk %s zostal stworzony przez Pas", perk_name);
	cod_give_weapon(id, CSW_AWP);
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	set_user_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 255);
	cod_take_weapon(id, CSW_AWP);
	ma_perk[id] = false;
}
	
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(damagebits & DMG_AWP && !random(4))
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}
public ResetHUD(id)
{
	if(ma_perk[id])
		set_task(0.5, "UstawStalker", id)
}


public UstawStalker(id)
{
	if(is_user_connected(id))
	{
		set_user_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 35);
	}
}
