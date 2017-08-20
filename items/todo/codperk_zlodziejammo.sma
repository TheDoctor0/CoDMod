#include <amxmodx>
#include <cstrike>
#include <codmod>
#include <hamsandwich>

new const perk_name[] = "Zlodziej ammo";
new const perk_desc[] = "Masz 1/LW na kradziez amunicji wrogowi";

new wartosc_perku[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Mentos");
	
	cod_register_perk(perk_name, perk_desc, 4, 9);
	
      RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 1);
}

public cod_perk_enabled(id, wartosc)
	wartosc_perku[id] = wartosc;

public cod_perk_disabled(id)
	wartosc_perku[id] = 0;

public TakeDamage(this, idinflictor, idattacker)
{
    if(!is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker))
        return HAM_IGNORED;

    if(!wartosc_perku[idattacker])
        return HAM_IGNORED;
 
    if(!random(wartosc_perku[idattacker]))
      return HAM_IGNORED;
      
      new wpn = get_user_weapon(this)
      if(wpn != CSW_KNIFE)
            cs_set_user_bpammo(this, wpn, 0)
        
    return HAM_IGNORED    
}
