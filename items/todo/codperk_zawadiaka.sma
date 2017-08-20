#include <amxmodx>
#include <cstrike>
#include <codmod>

new const perk_name[] = "Zawadiaka";
new const perk_desc[] = "SG552 + HE, za frag +1700 kasy";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	register_event("DeathMsg", "Death", "ade");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_HEGRENADE);
	cod_give_weapon(id, CSW_SG552);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_take_weapon(id, CSW_HEGRENADE);
	cod_take_weapon(id, CSW_SG552);
}

public Death()
{
	new attacker = read_data(1);
	
	if(!is_user_connected(attacker) || !ma_perk[attacker])
		return PLUGIN_CONTINUE;

	cs_set_user_money(attacker, min(16000, cs_get_user_money(attacker)+1700), 1);
	
	return PLUGIN_CONTINUE;
}
