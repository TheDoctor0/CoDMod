#include <amxmodx>
#include <hamsandwich>
#include <amxmisc>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Plaszcz Chucka Norrisa";
new const perk_desc[] = "Otrzymujesz SW% obrazen mniej";
new bool:ma_perk[33];
new wartosc_perku[33] = 0;

public plugin_init()
{
	register_plugin(perk_name, "1.0", "O'Zone")

	cod_register_perk(perk_name, perk_desc, 20, 20);

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
}

public cod_perk_enabled(id, wartosc){
	wartosc_perku[id] = wartosc;
	ma_perk[id] = true
}

public cod_perk_disabled(id)
	ma_perk[id] = false

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(idattacker) || !is_user_connected(idattacker) || !ma_perk[this])
		return HAM_IGNORED

	SetHamParamFloat(4, damage-damage*(float(wartosc_perku[this])/100.0));
	return HAM_HANDLED;
}
