#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Piwo K1X.'a";
new const perk_desc[] = "Zadajesz o SW wiecej obrazen, +50 HP na start, 20 punktow kondycji, ciche buty";

new bool:ma_perk[33];
new wartosc_perku[33]=0;

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 5, 5);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	cod_set_user_bonus_health(id, 50);
	cod_set_user_bonus_trim(id, 20);
	set_user_footsteps(id, 1);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_set_user_bonus_health(id, 0);
	cod_set_user_bonus_trim(id, 0);
	set_user_footsteps(id, 0);
}
	
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
		cod_inflict_damage(idattacker, this, float(wartosc_perku[idattacker]), 0.0, idinflictor, damagebits);

	return HAM_IGNORED;
}

