#include <amxmodx>
#include <codmod>
#include <fakemeta>

new nazwa[] = "Buty Komandosa"
new opis[] = "Dostajesz SW kondycji"

new wartosc_perku[33] = 0;
new komandos_id;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "O'Zone");
	
	komandos_id = cod_get_classid("Komandos");
	
	cod_register_perk(nazwa, opis, 60, 60);
}

public cod_perk_enabled(id, wartosc)
{
	if(cod_get_user_class(id) == komandos_id)
		return COD_STOP;
		
	wartosc_perku[id] = wartosc;
	cod_set_user_bonus_trim(id, wartosc_perku[id]);
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
	cod_set_user_bonus_trim(id, 0);

