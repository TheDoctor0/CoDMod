#include <amxmodx>
#include <fun>
#include <codmod>

new const perk_name[] = "Wampir";
new const perk_desc[] = "Za kazde trafienie +4 hp";

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
		if (is_user_connected(attacker_id) && attacker_id != id && ma_perk[attacker_id] && attacker_id)
			set_user_health(attacker_id, get_user_health(attacker_id)+4)
	}
}
