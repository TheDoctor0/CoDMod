#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <codmod>
#include <cstrike>

#define DMG_HEGRENADE (1<<24)

new const perk_name[] = "Granatnik Rock'a";
new const perk_desc[] = "Dostajesz 5 HE, masz z nich 1/SW szansy na zabicie, masz ciche buty";

new bool:ma_perk[33];
new wartosc_perku[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 5, 5);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	register_event("ResetHUD", "ResetHUD", "abe");
}


public cod_perk_enabled(id, wartosc)
{
	cod_give_weapon(id, CSW_HEGRENADE);
	set_task(0.1, "Granaty", id);
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	set_user_footsteps(id, 1);
}
	
public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_HEGRENADE);
	cs_set_user_bpammo(id, CSW_HEGRENADE, 0);
	ma_perk[id] = false;
	set_user_footsteps(id, 0);
}

public ResetHUD(id)
	set_task(0.1, "Granaty", id);

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
		
	if(get_user_team(this) != get_user_team(idattacker) && damagebits & DMG_HEGRENADE && random_num(1, wartosc_perku[idattacker]) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 1.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}

public Granaty(id)
{
	if(!is_user_alive(id)) 
		return;

	if(!ma_perk[id]) 
		return;
		
	cod_give_weapon(id, CSW_HEGRENADE);
	cs_set_user_bpammo(id, CSW_HEGRENADE, 5);
}
