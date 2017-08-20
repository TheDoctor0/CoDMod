#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <codmod>

new const perk_name[] = "Gruboskorny";
new const perk_desc[] = "Odpornosc na miny, dynamity, rakiety, 1/3 na otworzenie drzwi strzalem";

new bool:ma_perk[33];

public plugin_init() 
{
   register_plugin(perk_name, "1.0", "RiviT");

   cod_register_perk(perk_name, perk_desc);

   RegisterHam(Ham_TraceAttack, "func_door_rotating", "open_door") 
   RegisterHam(Ham_TraceAttack, "func_door", "open_door")  

   RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id) 
   ma_perk[id] = true;

public cod_perk_disabled(id)
   ma_perk[id] = false;

public TakeDamage(this, idinflictor, idattacker)
{
   if(!is_user_connected(idattacker))
      return HAM_IGNORED;
   
   if(!ma_perk[this])
      return HAM_IGNORED;
   
   new class[32];
   pev(idinflictor, pev_classname, class, 31);
   
   if(equal(class, "rocket") || equal(class, "dynamite") || equal(class, "mine"))
      return HAM_SUPERCEDE;
   
   return HAM_IGNORED;
}

public open_door(this, idattacker) 
{ 
   if(!is_user_connected(idattacker))
      return HAM_IGNORED; 
   
   if(!ma_perk[idattacker])
      return HAM_IGNORED;
   
   if(!random(3)) 
      dllfunc(DLLFunc_Use, this, idattacker) 
   
   return HAM_IGNORED;
}