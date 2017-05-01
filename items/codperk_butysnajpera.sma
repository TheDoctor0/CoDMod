#include <amxmodx>
#include <codmod>
#include <fakemeta>

new nazwa[] = "Buty Snajpera";
new opis[] = "Dostajesz SW kondycji";

new snajper_id;
new wartosc_perku[33] = 0;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "O'Zone");
	
	snajper_id = cod_get_classid("Snajper");
	
	cod_register_perk(nazwa, opis, 25, 25);
}

public cod_perk_enabled(id, wartosc)
{
	if(cod_get_user_class(id) == snajper_id)
		return COD_STOP;
	
	wartosc_perku[id] = wartosc;
	
	cod_set_user_bonus_trim(id, wartosc_perku[id]);
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
	cod_set_user_bonus_trim(id, 0);
