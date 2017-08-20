#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Pancerz Neomexowy";
new const perk_desc[] = "Masz 1/LW szans na odbicie pocisku";

new bool:ma_perk[33],
wartosc_perku[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc, 4, 7);

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(idattacker) == get_user_team(this))
		return HAM_IGNORED;
		
	if(ma_perk[this] && !random(wartosc_perku[this]))
            cod_inflict_damage(this, idattacker, damage, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
