#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include cstrike

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin("Wyposazenie snipera", "1.0", "Vasto_Lorde")

	cod_register_perk("Wyposazenie snipera", "Dostajesz AWP +40 dmg z niej, 2xFB");
	
	RegisterHam(Ham_TakeDamage, "player", "DMG");
      RegisterHam(Ham_Spawn, "player", "fwSpawn_Rakiety", 1);
}

public fwSpawn_Rakiety(id)
{
      if(ma_perk[id])
            cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
}

public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_AWP);
	cod_give_weapon(id, CSW_FLASHBANG);
	cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
	ma_perk[id]=true;
}
public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_AWP);
	cod_take_weapon(id, CSW_FLASHBANG);
	ma_perk[id]=false;
}

public DMG(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(this)==get_user_team(idattacker))
		return HAM_IGNORED; 
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(get_user_weapon(idattacker) == CSW_AWP && damagebits & (1<<1))
	{
            SetHamParamFloat(4, damage+40)
            return HAM_HANDLED
      }
	
	return HAM_IGNORED;
}
