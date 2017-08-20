#include <amxmodx>
#include <hamsandwich>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "AK47 PIELY";
new const perk_desc[] = "Dostajesz AK47 i masz z niego 1/SW szans na zabicie, dodatkowo +40 HP na start.";

new bool:ma_perk[33];
new wartosc_perku[33] = 0;

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 8, 8);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	cod_give_weapon(id, CSW_AK47);
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	cod_set_user_bonus_health(id, 40);
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_AK47);
	ma_perk[id] = false;
	cod_set_user_bonus_health(id, 0);
}
	
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_AK47 && damagebits & DMG_BULLET && random_num(1, wartosc_perku[idattacker]) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}

