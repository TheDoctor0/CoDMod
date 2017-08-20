#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Naboje Ninjy";
new const perk_desc[] = "Twoje zdrowie regeneruje sie o LW procent zadanych obrazen";

new bool:ma_perk[33];
new wartosc_perku[33];
public plugin_init() 
{
	register_plugin(perk_name, "1.0", "QTM_Peyote");
	
	cod_register_perk(perk_name, perk_desc, 22, 30);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamagePost", 1);
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public TakeDamagePost(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(idattacker))
		return HAM_IGNORED;
		
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	new Float:maksymalne_zdrowie = 100.0 + cod_get_user_health(idattacker);
	new Float:nowe_zdrowie = damage * (wartosc_perku[idattacker]/100) + pev(idattacker, pev_health);
	
	set_pev(idattacker, pev_health, (nowe_zdrowie < maksymalne_zdrowie)? nowe_zdrowie: maksymalne_zdrowie);
	
	return HAM_IGNORED;
}
