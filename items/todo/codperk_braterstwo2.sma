#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <engine>

new bool:ma_perk[33];

#define nazwa "Braterstwo"
#define opis "Bedac niedaleko drugiej osoby z druzyny, zadajesz o 50%% wieksze obrazenia"

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);
	
	RegisterHam(Ham_TakeDamage, "player", "fw_Tdmg");
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
	ma_perk[id] = false;
	
public fw_Tdmg(this, ini, id, Float:damage)
{
	if(!is_user_connected(id))
		return HAM_IGNORED;
		
	if(!ma_perk[id]) return HAM_IGNORED;
		
	new ents[1];
	find_sphere_class(id, "player", 60.0, ents, 1);
	
	if(!is_user_alive(ents[0]))
		return HAM_IGNORED;
		
	SetHamParamFloat(4, damage*1.5);

	return HAM_HANDLED;
}