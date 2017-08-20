#include <amxmodx>
#include <hamsandwich>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Zestaw DreameR'a";
new const perk_desc[] = "Dostajesz MP5 i Glocka. Masz 1/9 szans na zabicie z MP5 i 1/SW z Glocka.";

new bool:ma_perk[33];
new wartosc_perku[33] = 0;

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 6, 6);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	cod_give_weapon(id, CSW_GLOCK18);
	cod_give_weapon(id, CSW_MP5NAVY);
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_GLOCK18);
	cod_take_weapon(id, CSW_MP5NAVY);
	ma_perk[id] = false;
}
	
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_MP5NAVY && damagebits & DMG_BULLET && random_num(1, 9) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_AWP && damagebits & DMG_BULLET && random_num(1, wartosc_perku[idattacker]) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}

