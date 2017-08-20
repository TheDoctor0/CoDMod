#include <amxmodx>
#include <codmod>
#include <engine>

#define OBRAZENIA 50 //tu mozesz zmienic wartosc zadawanych obrazen
#define ILOSC_FAL 3

new const perk_name[] = "Fala smierci";
new const perk_desc[] = "Masz 2 fale, ktore po uzyciu, zadaja przeciwnikom 50(+int) obrazen";

new ilosc_fal[33],
sprite_white

public plugin_init() 
{
	register_plugin("codperk_falasmierci", "1.0", "MarWit")
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("ResetHUD", "ResetHUD", "abe");
}

public plugin_precache()
	sprite_white = precache_model("sprites/white.spr");
	
public cod_perk_enabled(id)
{
	ilosc_fal[id] = ILOSC_FAL
}

public cod_perk_disabled(id)
{
	ilosc_fal[id] = 0
}

public cod_perk_used(id)
{
	if(!ilosc_fal[id])
	{	
		client_print(id, print_center, "Wykorzystales wszystkie fale!")
		return PLUGIN_CONTINUE
	}
		
	ilosc_fal[id]--;
	
	new iOrigin[3];
	get_user_origin(id, iOrigin);
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 300 );
	write_coord( iOrigin[2] + 300 );
	write_short( sprite_white );
	write_byte( 0 ); 
	write_byte( 0 ); 
	write_byte( 10 ); 
	write_byte( 120 ); 
	write_byte( 255 ); 
	write_byte( 0 ); 
	write_byte( 0 );
	write_byte( 255 ); 
	write_byte( 100 ); 
	write_byte( 4 ); 
	message_end();
	
	new entlist[33];
	iOrigin[0] = find_sphere_class(id, "player", 300.0, entlist, 32);
		
	for (new i=0; i < iOrigin[0]; i++)
	{		
		if (is_user_alive(entlist[i]) && get_user_team(id) != get_user_team(entlist[i]))
			cod_inflict_damage(id, entlist[i], 50.0, 1.0, id, (1<<24))
	}
	
	return PLUGIN_CONTINUE;
}

public ResetHUD(id)
	ilosc_fal[id] = ILOSC_FAL