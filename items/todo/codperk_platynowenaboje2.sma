#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Platynowe Naboje";
new const perk_desc[] = "Zadajesz LW obrazen wiecej";

new bool:ma_perk[33],
wartosc_perku[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");

	cod_register_perk(perk_name, perk_desc, 20, 35);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
	{
		SetHamParamFloat(4, damage+float(wartosc_perku[idattacker]))
		return HAM_HANDLED
      }
		
	return HAM_IGNORED;
}