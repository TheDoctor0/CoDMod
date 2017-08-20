#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Zestaw Snajperski";
new const perk_desc[] = "Dostajesz AWP i Deagle, masz odpowiednio 1/2 i 1/SW na zabicie z nich";

#define DMG_BULLET (1<<1)

new wartosc_perku[33];
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 6, 6);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage")
}

public cod_perk_enabled(id, wartosc)
{
	wartosc_perku[id] = wartosc;
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_AWP);
	cod_give_weapon(id, CSW_DEAGLE);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_take_weapon(id, CSW_AWP);
	cod_take_weapon(id, CSW_DEAGLE);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_AWP && damagebits & DMG_BULLET && random_num(1, 2) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_DEAGLE && damagebits & DMG_BULLET && random_num(1, wartosc_perku[idattacker]) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
