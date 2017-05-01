#include <amxmodx>
#include <codmod>

new const perk_name[] = "Dawka LSD";
new const perk_desc[] = "Dostajesz +SW punktow do wszystkich statystyk";

new wartosc_perku[33] = 0;
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 40, 40);
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	cod_set_user_bonus_stamina(id, wartosc_perku[id]);
	cod_set_user_bonus_trim(id, wartosc_perku[id]);
	cod_set_user_bonus_health(id, wartosc_perku[id]);
	cod_set_user_bonus_intelligence(id, wartosc_perku[id]);
}

public cod_perk_disabled(id){
	ma_perk[id] = false;
	cod_set_user_bonus_stamina(id, 0);
	cod_set_user_bonus_trim(id, 0);
	cod_set_user_bonus_health(id, 0);
	cod_set_user_bonus_intelligence(id, 0);
}
