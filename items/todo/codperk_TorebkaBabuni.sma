#include <amxmodx>
#include <codmod>
#include <cstrike>
#include <hamsandwich>

new const perk_name[] = "Torebka Babuni";
new const perk_desc[] = "Co runde dostajesz +8000$";

new bool:ma_perk[33];

public plugin_init()
{
      register_plugin(perk_name, "1.0", "aQn");

      cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Dynamit", 1);
}

public cod_perk_enabled(id)
      ma_perk[id] = true;

public cod_perk_disabled(id)
      ma_perk[id] = false;

public fwSpawn_Dynamit(id)
{
      if(is_user_alive(id) && ma_perk[id])
            cs_set_user_money(id, min(16000, cs_get_user_money(id) + 8000))
}