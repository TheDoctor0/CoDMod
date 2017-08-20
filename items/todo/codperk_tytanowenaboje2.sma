#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Tytanowe Naboje";
new const perk_desc[] = "Zadajesz 10(+int*0.25) obrazen wiecej";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
	ma_perk[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
	{
		SetHamParamFloat(4, damage+10+cod_get_user_intelligence(idattacker, 1, 1, 1)*0.25)
		return HAM_HANDLED
      }
		
	return HAM_IGNORED;
}
