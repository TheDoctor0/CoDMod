#include <amxmodx>
#include <hamsandwich>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Notatki Kapitana";
new const perk_desc[] = "Odbijasz LW pociskow na runde";

new bool:ma_perk[33],
wartosc_perku[33],
pozostale_strzaly[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc, 1, 4);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	pozostale_strzaly[id] = (wartosc_perku[id] = wartosc);
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker) && !ma_perk[this])
		return HAM_IGNORED;

	if(pozostale_strzaly[this] && damagebits & DMG_BULLET)
	{
		pozostale_strzaly[this]--;
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public Spawn(id)
	pozostale_strzaly[id] = wartosc_perku[id];
