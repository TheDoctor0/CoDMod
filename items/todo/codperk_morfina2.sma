#include <amxmodx>
#include <hamsandwich>
#include <codmod>

#define ZADANIE_WSKRZES 6240

new const perk_name[] = "Morfina";
new const perk_desc[] = "Masz 1/LW szans na odrodzenie sie po smierci";

new wartosc_perku[33];
new bool:ma_perk[33];

public plugin_init()
 {
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc, 2, 4);
	RegisterHam(Ham_Killed, "player", "Killed", 1);
}

public cod_perk_enabled(id, wartosc)
{
	wartosc_perku[id] = wartosc;
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public Killed(id)
{
	if(is_user_connected(id) && ma_perk[id] && !random(wartosc_perku[id]))
		set_task(0.1, "Wskrzes", id+ZADANIE_WSKRZES);
}

public Wskrzes(id)
	ExecuteHamB(Ham_CS_RoundRespawn, id-ZADANIE_WSKRZES);
