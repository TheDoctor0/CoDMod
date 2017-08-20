#include <amxmodx>
#include <codmod>
#include cstrike
#include hamsandwich

new const perk_name[] = "Wyposazenie SWAT";
new const perk_desc[] = "Dostajesz Famasa i 2x Flashbang";

new bool:ma_perk[33];
public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");

	cod_register_perk(perk_name, perk_desc);
	
      RegisterHam(Ham_Spawn, "player", "fwSpawn_Rakiety", 1);
}

public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_FAMAS)
	cod_give_weapon(id, CSW_FLASHBANG)
      cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
      ma_perk[id] = true
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_FAMAS)
      cod_take_weapon(id, CSW_FLASHBANG)
      ma_perk[id] = false
}

public fwSpawn_Rakiety(id)
{
      if(ma_perk[id])
            cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
}
