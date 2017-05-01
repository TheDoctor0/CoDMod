#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <fakemeta>

new const perk_name[] = "Tarcza SWAT";
new const perk_desc[] = "Jestes odporny na miny, rakiety oraz dynamit";

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

