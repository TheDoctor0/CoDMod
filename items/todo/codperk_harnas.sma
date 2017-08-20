#include <amxmodx>
#include <hamsandwich>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Harnas";
new const perk_desc[] = "Masz 1/SW szans na zabicie z USP, dostajesz 15 punktow kondycji";

new wartosc_perku[33] = 0;
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 6, 6);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	wartosc_perku[id] = wartosc;
	ma_perk[id] = true;
	cod_set_user_bonus_trim(id, 15);
	cod_give_weapon(id, CSW_USP);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_set_user_bonus_trim(id, 0);
	cod_take_weapon(id, CSW_USP);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(random_num(1, wartosc_perku[idattacker]) != 1)
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_USP && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}
