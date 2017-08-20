#include <amxmodx>
#include <codmod>

public plugin_init() 
{
      new nazwa[] = "Buty Komandosa"
      new opis[] = "Dostajesz 60 kondycji"

	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);
}

public cod_perk_enabled(id)
	cod_add_user_bonus_trim(id, 60);

public cod_perk_disabled(id)
	cod_add_user_bonus_trim(id, -60);

