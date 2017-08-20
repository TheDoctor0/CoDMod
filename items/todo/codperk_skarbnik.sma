#include <amxmodx>
#include <cstrike>
#include <codmod>

new const perk_name[] = "Skarbnik";
new const perk_desc[] = "1/3 szans na kradzez 1000 $ gdy trafisz przeciwnika";

new bool:ma_perk[33]

public plugin_init() 
{
   register_plugin(perk_name, "1.0", "RiviT");
   
   cod_register_perk(perk_name, perk_desc);
   
   register_event("Damage", "Damage", "b", "2!0")
}

public cod_perk_enabled(id)
   ma_perk[id] = true;

public cod_perk_disabled(id)
   ma_perk[id] = false;

public Damage(id)
{
   if (is_user_connected(id))
   {
      new attacker_id = get_user_attacker(id) 

      if (is_user_connected(attacker_id) && attacker_id != id && ma_perk[attacker_id])
         dodaj_kase(id,attacker_id)
   }
}
public dodaj_kase(id,attacker)
{
      if (!random(3))
      {
            new kasa = cs_get_user_money(id)
         if (kasa >= 1000)
         {
            cs_set_user_money(id,kasa-1000)
            cs_set_user_money(attacker, min(16000, cs_get_user_money(attacker) + 1000))
         }
         
         else
         {
            cs_set_user_money(attacker, min(16000, cs_get_user_money(attacker) + kasa))
            cs_set_user_money(id,0)
         }
   }
}