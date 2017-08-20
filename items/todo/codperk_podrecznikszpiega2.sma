#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <codmod>

#define DMG_HEGRENADE (1<<24)

new const perk_name[] = "Podrecznik Szpiega";
new const perk_desc[] = "Masz 1/LW szans na zadanie 100(+int) obrazen z HE. Posiadasz ubranie wroga";

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"};

new bool:ma_perk[33],
wartosc_perku[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc, 1, 3);

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}


public cod_perk_enabled(id, wartosc)
{
	cs_set_user_model(id, (get_user_team(id) == 1)? CT_Skins[random_num(0,3)]: Terro_Skins[random_num(0,3)]);
	cod_give_weapon(id, CSW_HEGRENADE);
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}
	
public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_HEGRENADE);
	if (is_user_connected(id)) cs_reset_user_model(id);
	ma_perk[id] = false;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
		
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
		
	if(damagebits & DMG_HEGRENADE && !random(wartosc_perku[idattacker]))
	{
		SetHamParamFloat(4, 100+float(cod_get_user_intelligence(idattacker, 1, 1, 1)))
		return HAM_HANDLED
      }
		
	return HAM_IGNORED;
}

public Spawn(id)
{
	if(ma_perk[id])
		cs_set_user_model(id, (get_user_team(id) == 1)? CT_Skins[random_num(0,3)]: Terro_Skins[random_num(0,3)]);
}
