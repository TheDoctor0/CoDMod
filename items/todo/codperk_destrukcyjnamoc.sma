#include <amxmodx>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Destrukcyjna moc";
new const perk_desc[] = "Masz 1/LW na zniszczenie perku wroga po zabiciu go";

new bool:ma_perk[33],
wartosc_perku[33];

public plugin_init() 
{
   register_plugin(perk_name, "1.0", "RiviT");
   
   cod_register_perk(perk_name, perk_desc, 7, 11)
 
   RegisterHam(Ham_Killed, "player", "Ham_KilledPost", 1)
}

public cod_perk_enabled(id, wartosc)
{
   ma_perk[id] = true;
   wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
   ma_perk[id] = false;

public Ham_KilledPost(vid, kid)
{
      if(is_user_connected(kid) && get_user_team(vid) != get_user_team(kid) && ma_perk[kid] && !random(wartosc_perku[kid]))
      {
            new nazwa[33];
            get_user_name(kid, nazwa, 32)
         
            cod_set_user_perk(vid, 0, 0, 0);
            client_print(vid, print_center, "%s zniszczyl Ci perk", nazwa)
            get_user_name(vid, nazwa, 32)
            client_print(kid, print_center, "Zniszczyles perk %s", nazwa)
      }
}