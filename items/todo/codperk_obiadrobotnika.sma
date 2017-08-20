#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Obiad Robotnika";
new const perk_desc[] = "Zadajesz SW obrazen wiecej, +50 HP na poczatku kazdej rundy, +15 punktow wytrzymalosci.";

new wartosc_perku[33]=0;
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 10, 10);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	cod_set_user_bonus_health(id, 50);
	cod_set_user_bonus_stamina(id, 15);
}
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_set_user_bonus_health(id, 0);
	cod_set_user_bonus_stamina(id, 0);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
		cod_inflict_damage(idattacker, this, float(wartosc_perku[idattacker]), 0.0, idinflictor, damagebits);

	return HAM_IGNORED;
}
