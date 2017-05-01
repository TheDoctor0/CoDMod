#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Prawa reka rambo";
new const perk_desc[] = "Zadajesz SW(+inteligencja) obrazen wiecej, 18 kondycji, 5 wytrzymalosci";

new bool:ma_perk[33];
new wartosc_perku[33]=0;

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 15, 15);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	cod_set_user_bonus_trim(id, 18);
	cod_set_user_bonus_stamina(id, 5);
}
	
public cod_perk_disabled(id)
{
	cod_set_user_bonus_trim(id, 0);
	cod_set_user_bonus_stamina(id, 0);
	ma_perk[id] = false;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
		cod_inflict_damage(idattacker, this, float(wartosc_perku[idattacker]), 0.20, idinflictor, damagebits);

	return HAM_IGNORED;
}
