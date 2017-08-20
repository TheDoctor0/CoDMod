#include <amxmodx>
#include <codmod>
#include <cstrike>
#include hamsandwich

new const perk_name[] = "Kameleon";
new const perk_desc[] = "Z AUG masz ubranie CT, a z Kriegiem ubranie TT";

new Ubrania_CT[4][]={"sas","gsg9","urban","gign"};
new Ubrania_Terro[4][]={"arctic","leet","guerilla","terror"};

new bool:ma_perk[33];

public plugin_init() 
{
    register_plugin(perk_name, "1.0", "RiviT")

    cod_register_perk(perk_name, perk_desc);

    register_event("CurWeapon","CurWeapon","be", "1=1");
    RegisterHam(Ham_Spawn, "player", "fwdSpawn", 1)
}

public fwdSpawn(id)
      if(is_user_alive(id)) cs_reset_user_model(id);

public cod_perk_enabled(id)
{
    ma_perk[id] = true;
    cod_give_weapon(id, CSW_SG552);
    cod_give_weapon(id, CSW_AUG);
}

public cod_perk_disabled(id)
{
    ma_perk[id] = false;
    if(is_user_connected(id)) cs_reset_user_model(id);
    cod_take_weapon(id, CSW_SG552);
    cod_take_weapon(id, CSW_AUG);
}

public CurWeapon(id)
{ 
      if(!ma_perk[id]) return PLUGIN_CONTINUE;
      
      switch(read_data(2))
      {
            case CSW_AUG: cs_set_user_model(id, Ubrania_CT[random_num(0,3)]);
            case CSW_SG552: cs_set_user_model(id, Ubrania_Terro[random_num(0,3)]);
            default: cs_reset_user_model(id);
      }

      return PLUGIN_CONTINUE;
}