#include <amxmodx>
#include <codmod>
#include <cstrike>

new const perk_name[] = "Paczka HE";
new const perk_desc[] = "Co runde dostajesz 35 HE";

new bool:ma_perk[33];

public plugin_init() 
{
      register_plugin(perk_name, "1.0", "RPK. Shark");

      cod_register_perk(perk_name, perk_desc);
      register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_perk_enabled(id)
{
      cod_give_weapon(id, CSW_HEGRENADE);
      cs_set_user_bpammo(id, CSW_HEGRENADE, 35);

      ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
      cod_take_weapon(id, CSW_HEGRENADE);
      ma_perk[id] = false;
}

public ResetHUD(id)
      set_task(0.1, "ResetHUDx", id);

public ResetHUDx(id)
{
      if(!ma_perk[id])
            return;

      if(!is_user_connected(id))
            return;
        
      cs_set_user_bpammo(id, CSW_HEGRENADE, 35);
}