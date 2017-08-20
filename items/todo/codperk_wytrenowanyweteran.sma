#include <amxmodx>
#include <codmod>

new const perk_name[] = "Wytrenowany Weteran";
new const perk_desc[] = "Dostajesz dodatkowe SW HP i tracisz 30 punktow kondycji";

new bool:ma_perk[33];
new wartosc_perku[33] = 0;

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 100, 100);
}
public cod_perk_enabled(id, wartosc)
{
	ma_perk[id]=true;
	wartosc_perku[id] = wartosc;
	cod_set_user_bonus_trim(id, -30);
	cod_set_user_bonus_health(id, wartosc_perku[id]);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_set_user_bonus_trim(id, 0);
	cod_set_user_bonus_health(id, 0);
}
