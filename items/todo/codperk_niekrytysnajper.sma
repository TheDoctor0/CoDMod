#include <amxmodx>
#include <codmod>
#include <hamsandwich>
	
new const perk_name[] = "Niekryty Snajper";
new const perk_desc[] = "Masz AWP i -20 dmg z niej, 50 widocznosci do otrzymania obrazen";
    
new bool:ma_perk[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "RiviT");

	cod_register_perk(perk_name, perk_desc);

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);
}

public cod_perk_enabled(id)
{
	cod_set_user_rendering(id, 50)
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_AWP)
}

public cod_perk_disabled(id)
{
    	ma_perk[id] = false;
	cod_take_weapon(id, CSW_AWP)
	cod_remove_user_rendering(id)
}

public fwSpawn_Grawitacja(id)
{
	if(ma_perk[id])
	{
		cod_remove_user_rendering(id)
		cod_set_user_rendering(id, 50)
	}
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;

	if(ma_perk[this])
		cod_remove_user_rendering(this)

	if(ma_perk[idattacker] && get_user_weapon(idattacker) == CSW_AWP && damagebits & (1<<1))
	{
		SetHamParamFloat(4, damage-20);
		return HAM_HANDLED
      }
	
	return HAM_IGNORED;
}