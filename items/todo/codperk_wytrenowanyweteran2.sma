#include <amxmodx>
#include <codmod>

new const perk_name[] = "Wytrenowany weteran";
new const perk_desc[] = "Dostajesz 100 zdrowia oraz tracisz 30 kondycji";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
{
	cod_add_user_bonus_trim(id, -30);
	cod_add_user_bonus_health(id, 100);
}

public cod_perk_disabled(id)
{
	cod_add_user_bonus_trim(id, 30);
	cod_add_user_bonus_health(id, -100);
}
