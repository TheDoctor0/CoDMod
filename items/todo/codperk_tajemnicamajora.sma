#include <amxmodx>
#include <hamsandwich>
#include <fun>
#include <codmod>

#define DMG_HEGRENADE (1<<24)

new const perk_name[] = "Tajemnica Majora";
new const perk_desc[] = "Zadajesz 70(+int) obrazen z HE, oraz dostajesz 20 HP za kazdego fraga.";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
	register_event("DeathMsg", "Death", "ade");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_HEGRENADE);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_take_weapon(id, CSW_HEGRENADE);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
		
	if(!ma_perk[idattacker])
		return HAM_IGNORED;

	if(damagebits & DMG_HEGRENADE)
	{
		SetHamParamFloat(4, float(70+cod_get_user_intelligence(idattacker, 1, 1, 1)))
		return HAM_HANDLED
      }
	
	return HAM_IGNORED;
}

public Death()
{
	new attacker = read_data(1);
	
	if(!is_user_connected(attacker))
		return PLUGIN_CONTINUE;
		
	if(!ma_perk[attacker])
		return PLUGIN_CONTINUE;
		
	new cur_health = get_user_health(attacker);
	new max_health = 100+cod_get_user_health(attacker);
	new new_health = cur_health+20<max_health? cur_health+20: max_health;
	set_user_health(attacker, new_health);
	
	return PLUGIN_CONTINUE;
}
