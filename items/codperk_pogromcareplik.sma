#include <amxmodx>
#include <codmod>

new const perk_name[] = "Pogromca Replik";
new const perk_desc[] = "Repliki nie odbijaja twoich kul, niszczysz je dwa razy szybciej";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
	ma_perk[id] = false;
