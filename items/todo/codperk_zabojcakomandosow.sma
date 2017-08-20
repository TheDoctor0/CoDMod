#include <amxmodx>
#include <hamsandwich>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Zabojca Komandosow (PejpeR TEST)";
new const perk_desc[] = "Jesli ofiara trzyma noz szanse na jej zabicie wynosza 1/1.";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "MAGNET");	
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;

	if(get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
	
	if(get_user_weapon(this) != CSW_KNIFE)
		return HAM_IGNORED;
	
	if(!(damagebits & DMG_BULLET))
		return HAM_IGNORED;
	
	cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}



