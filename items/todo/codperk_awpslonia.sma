#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <codmod>
#include <engine>

#define DMG_BULLET (1<<1)

new const perk_name[] = "AWP Slonia";
new const perk_desc[] = "Masz 1/1 z AWP, +SW HP na start, twoja widocznosc spada do 50.";

new bool:ma_perk[33];
new wartosc_perku[33] = 0;

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 50, 50);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	RegisterHam(Ham_Spawn,"player","Spawn");
}

public cod_perk_enabled(id, wartosc)
{
	cod_give_weapon(id, CSW_AWP);
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	cod_set_user_bonus_health(id, wartosc_perku[id]);
	set_user_rendering(id, kRenderFxNone, 0,0,0, kRenderTransAlpha, 32);
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_AWP);
	ma_perk[id] = false;
	cod_set_user_bonus_health(id, 0);
	set_user_rendering(id, kRenderFxNone, 0,0,0, kRenderTransAlpha, 255);
}
	
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_AWP && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}

public Spawn(id){
	if(ma_perk[id])
		set_task(1.0,"UstawRender",id)
	return PLUGIN_CONTINUE;
}
public UstawRender(id)
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 50);
