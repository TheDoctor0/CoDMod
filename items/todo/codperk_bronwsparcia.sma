#include <amxmodx>
#include <codmod>
#include <hamsandwich>

new const perk_name[] = "Bron Wsparcia";
new const perk_desc[] = "Dostajesz Mp5 i +8dmg z niego.";

new bool:ma_perk[33]

public plugin_init()
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0)	
}

public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_MP5NAVY)
	ma_perk[id] = true
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_MP5NAVY)
	ma_perk[id] = false
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker] && get_user_weapon(idattacker) == CSW_MP5NAVY && damagebits & (1<<1))
	{
		SetHamParamFloat(4, damage+8)
		return HAM_HANDLED
	}
		
	return HAM_IGNORED
}
