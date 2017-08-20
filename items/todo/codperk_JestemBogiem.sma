#include <amxmodx>
#include <codmod>

new nazwa[] = "Jestem Bogiem";
new opis[] = "+170 zdrowia, +100 wytrzymalosci, +50 kondycji, +25 inty";

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_perk(nazwa, opis);
}

public cod_perk_enabled(id)
{		
	cod_add_user_bonus_health(id, 170);
	cod_add_user_bonus_stamina(id, 100);
	cod_add_user_bonus_intelligence(id, 25);
	cod_add_user_bonus_trim(id, 50);
}
public cod_perk_disabled(id)
{
	cod_add_user_bonus_health(id, -170);
	cod_add_user_bonus_stamina(id, -100);
	cod_add_user_bonus_intelligence(id, -25);
	cod_add_user_bonus_trim(id, -50);
}

