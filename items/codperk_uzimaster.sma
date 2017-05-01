#include <amxmodx>
#include <hamsandwich>
#include <amxmisc>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Uzi Master";
new const perk_desc[] = "Dostajesz Uzi, masz z niego +20(+int) obrazen";
new bool:ma_perk[33];
new wartosc_perku[33] = 0;

public plugin_init()
{
	register_plugin(perk_name, "1.0", "O'Zone")

	cod_register_perk(perk_name, perk_desc, 20, 20);

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	wartosc_perku[id] = wartosc;
	cod_give_weapon(id, CSW_MAC10);
	ma_perk[id] = true
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_MAC10);
	ma_perk[id] = false
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(idattacker) || !is_user_connected(idattacker) || !ma_perk[idattacker])
		return HAM_IGNORED

	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_MAC10 && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, float(wartosc_perku[idattacker]), 0.2, idinflictor, damagebits);

	return HAM_IGNORED;
}
