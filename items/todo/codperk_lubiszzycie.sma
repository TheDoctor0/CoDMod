#include <amxmodx>
#include <codmod>

public plugin_init() 
{
      new const perk_name[] = "Lubisz zycie?";
      new const perk_desc[] = "Dostajesz 120 Zdrowia";

	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
	cod_add_user_bonus_health(id, 120);

public cod_perk_disabled(id)
	cod_add_user_bonus_health(id, -120);