#include <amxmodx>
#include <codmod>
#include <hamsandwich>

new const perk_name[] = "Mroczne Kule";
new const perk_desc[] = "+7 dmg, 1/10 na wziecie sobie 120 expa od przeciwnika";

new bool:ma_perk[33]

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 1)
}

public cod_perk_enabled(id)
        ma_perk[id] = true

public cod_perk_disabled(id)
        ma_perk[id] = false

public TakeDamage(this, idinflictor, idattacker, Float:damage)
{		
	if(is_user_connected(idattacker) && get_user_team(idattacker) != get_user_team(this) && ma_perk[idattacker])
	{
            if(!random(10) && cod_get_user_xp(this) >= 120)
            {
                  cod_add_user_xp(this, -120)
                  cod_add_user_xp(idattacker, 120)
		}

            SetHamParamFloat(4, damage + 7.0)
            
		return HAM_HANDLED
	}
		
	return HAM_IGNORED
}