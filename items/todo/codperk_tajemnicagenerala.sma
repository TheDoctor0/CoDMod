#include <amxmodx>
#include <hamsandwich>
#include <codmod>

#define DMG_HEGRENADE (1<<24)

new const perk_name[] = "Tajemnica Generala";
new const perk_desc[] = "Zadajesz SW(+inteligencja) obrazen z HE";

new wartosc_perku[33]=0;
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 100, 100);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_HEGRENADE);
	wartosc_perku[id] = wartosc;
}
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_take_weapon(id, CSW_HEGRENADE);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(!ma_perk[idattacker])
		return HAM_IGNORED;

	if(damagebits & DMG_HEGRENADE && get_user_team(this) != get_user_team(idattacker))
		cod_inflict_damage(idattacker, this, float(wartosc_perku[idattacker])-damage, 1.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
