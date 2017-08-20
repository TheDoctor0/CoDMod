#include <amxmodx>
#include <codmod>
#include <cstrike>

new const perk_name[] = "Zadyma";
new const perk_desc[] = "Dostajesz 10 SG i 5 HE, +10 inty, +5 kondychy";

new bool:ma_perk[33];

public plugin_init() 
{
      register_plugin(perk_name, "1.0", "RiviT");
        
      cod_register_perk(perk_name, perk_desc);
      register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_perk_enabled(id)
{
	cod_add_user_bonus_intelligence(id, 10);
	cod_add_user_bonus_trim(id, 5);
      cod_give_weapon(id, CSW_HEGRENADE);
	cod_give_weapon(id, CSW_SMOKEGRENADE);
      cs_set_user_bpammo(id, CSW_HEGRENADE, 5);
	cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 10);

      ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	cod_add_user_bonus_intelligence(id, -10);
	cod_add_user_bonus_trim(id, -5);
      cod_take_weapon(id, CSW_HEGRENADE);
	cod_take_weapon(id, CSW_SMOKEGRENADE);
      ma_perk[id] = false;
}

public ResetHUD(id)
      set_task(0.1, "ResetHUDx", id);
        
public ResetHUDx(id)
{
      if(!is_user_connected(id)) return;
        
      if(!ma_perk[id]) return;
        
      cs_set_user_bpammo(id, CSW_HEGRENADE, 5);
	cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 10);
}