#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <codmod>

#define DMG_HEGRENADE (1<<24)

new const perk_name[] = "Podrecznik Szpiega";
new const perk_desc[] = "Masz 1/LW szans na zadanie 100(+inteligencja) obrazen z HE. Posiadasz ubranie wroga";

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"};

new bool:ma_perk[33];
new wartosc_perku[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "QTM_Peyote");
	
	cod_register_perk(perk_name, perk_desc, 1, 3);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}


public cod_perk_enabled(id, wartosc)
{
	ZmienUbranie(id, 0);
	cod_give_weapon(id, CSW_HEGRENADE);
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}
	
public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_HEGRENADE);
	ZmienUbranie(id, 1);
	ma_perk[id] = false;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
		
	if(get_user_team(this) != get_user_team(idattacker) && damagebits & DMG_HEGRENADE && random_num(1, wartosc_perku[idattacker]) == 1)
		cod_inflict_damage(idattacker, this, 101.0-damage, 1.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}

public ZmienUbranie(id,reset)
{
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	if (reset)
		cs_reset_user_model(id);
	else
	{
		new num = random_num(0,3);
		cs_set_user_model(id, (get_user_team(id) == 1)? CT_Skins[num]: Terro_Skins[num]);
	}
	
	return PLUGIN_CONTINUE;
}

public Spawn(id)
{
	if(ma_perk[id])
		ZmienUbranie(id, 0);
}
