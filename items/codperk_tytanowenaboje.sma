#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Tytanowe Naboje";
new const perk_desc[] = "Zadajesz SW(+int) obrazen wiecej";

new Float:wartosc_perku[33]=0.0;
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 5, 5);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = num_to_float(wartosc);
}
	
public cod_perk_disabled(id)
	ma_perk[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
		cod_inflict_damage(idattacker, this, wartosc_perku[idattacker], 0.25, idinflictor, damagebits);

	return HAM_IGNORED;
}

stock Float:num_to_float(value)
{
    new Float:value2;
    value2=Float:value;
    new string[32];
    num_to_str(value,string,31);
    value2=str_to_float(string);
    return value2;
}
