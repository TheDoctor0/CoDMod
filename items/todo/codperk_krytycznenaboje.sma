#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Krytyczne Naboje";
new const perk_desc[] = "Masz 1/SW szans na zadanie przeciwnikowi 2 razy wiekszych obrazen";

new wartosc_perku[33] = 0;
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 3, 3);
	
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
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
		
	if(random_num(1, wartosc_perku[idattacker]) == 1)
		cod_inflict_damage(idattacker, this, damage*2, 0.0, idinflictor, damagebits)

	return HAM_IGNORED;
}
