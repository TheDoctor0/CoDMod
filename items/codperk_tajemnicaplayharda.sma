#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#include <fun>

new const perk_name[] = "Tajemnica PlayHard'a";
new const perk_desc[] = "Zadajesz LW obrazen wiecej, nie slychac twoich krokow";

new wartosc_perku[33]=0;
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 10, 15);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	set_user_footsteps(id, 1);
}
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	set_user_footsteps(id, 0);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
		cod_inflict_damage(idattacker, this, float(wartosc_perku[idattacker]), 0.0, idinflictor, damagebits);

	return HAM_IGNORED;
}
