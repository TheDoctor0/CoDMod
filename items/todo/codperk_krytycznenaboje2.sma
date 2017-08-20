#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Krytyczne Naboje";
new const perk_desc[] = "1/LW na zadanie LW razy wiekszych dmg";

new wartosc_perku[33]

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc, 2, 5);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
}

public cod_perk_enabled(id, wartosc)
	wartosc_perku[id] = wartosc
	
public cod_perk_disabled(id)
	wartosc_perku[id] = 0;

public TakeDamage(this, idinflictor, idattacker, Float:damage)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(!wartosc_perku[idattacker])
		return HAM_IGNORED;
		
	if(!random(wartosc_perku[idattacker]))
	{
		SetHamParamFloat(4, damage*wartosc_perku[idattacker])
		return HAM_HANDLED
      }

	return HAM_IGNORED;
}