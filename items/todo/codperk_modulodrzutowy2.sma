#include <amxmodx>
#include <fakemeta>
#include <codmod>

new const perk_name[] = "Modul Odrzutowy";
new const perk_desc[] = "Wyrzuca cie z sila 666(+int), modul laduje sie co 4 sekundy";

new Float:ostatni_skok[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_used(id)
{
	if(pev(id, pev_flags) & FL_ONGROUND && get_gametime() > ostatni_skok[id]+4.0)
	{
		ostatni_skok[id] = get_gametime();
		new Float:velocity[3];
		velocity_by_aim(id, 666+cod_get_user_intelligence(id), velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity, velocity);
	}
}
