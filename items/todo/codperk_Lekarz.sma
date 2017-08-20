#include <amxmodx>
#include <codmod>
#include <engine>
#include <hamsandwich>

new const nazwa[] = "Lekarz";
new const opis[] = "Dostajesz 3 apteczki";

new sprite_white_apteczki,
ilosc_apteczek_gracza[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "Play 4FuN");
	
	cod_register_perk(nazwa, opis);
	
	register_think("medkit", "Think_Apteczki");
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Apteczki", 1);
}

public plugin_precache()
{
	sprite_white_apteczki = precache_model("sprites/white.spr");
	precache_model("models/w_medkit.mdl");
}

public cod_perk_enabled(id)
	ilosc_apteczek_gracza[id] = 3;

public cod_perk_used(id)
{
	if (!ilosc_apteczek_gracza[id])
		client_print(id, print_center, "Masz tylko 3 apteczki na runde!");
	else
	{
		ilosc_apteczek_gracza[id]--;
		
		new Float:origin[3];
		entity_get_vector(id, EV_VEC_origin, origin);
		
		new ent = create_entity("info_target");
		entity_set_string(ent, EV_SZ_classname, "medkit");
		entity_set_edict(ent, EV_ENT_owner, id);
		entity_set_int(ent, EV_INT_solid, SOLID_NOT);
		entity_set_vector(ent, EV_VEC_origin, origin);
		entity_set_float(ent, EV_FL_ltime, halflife_time() + 7 + 0.1);
		
		
		entity_set_model(ent, "models/w_medkit.mdl");
		set_rendering ( ent, kRenderFxGlowShell, 255,0,0, kRenderFxNone, 255 )     ;
		drop_to_floor(ent);
		
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);
	}
}

public fwSpawn_Apteczki(id)
{
		ilosc_apteczek_gracza[id] = 3;
}

public Think_Apteczki(ent)
{
	if(!is_valid_ent(ent))
		return PLUGIN_CONTINUE;

	new id = entity_get_edict(ent, EV_ENT_owner);

	if (entity_get_edict(ent, EV_ENT_euser2) == 1)
	{
            new heal = 4+floatround(cod_get_user_intelligence(id)*0.3);

		new Float:forigin[3];
		entity_get_vector(ent, EV_VEC_origin, forigin);

		new entlist[33];
		new numfound = find_sphere_class(0,"player", 300.0,entlist, 32,forigin);
		new maksymalne_zdrowie, zdrowie, Float:nowe_zdrowie

		for (new i=0; i < numfound; i++)
		{
			if (get_user_team(entlist[i]) != get_user_team(id) || !is_user_alive(entlist[i]))
				continue;
				
                  maksymalne_zdrowie = 100+cod_get_user_health(entlist[i]);
                  zdrowie = get_user_health(entlist[i]);
                  nowe_zdrowie = (zdrowie+heal<maksymalne_zdrowie)?zdrowie+heal+0.0:maksymalne_zdrowie+0.0;

			entity_set_float(entlist[i], EV_FL_health, nowe_zdrowie);
		}

		entity_set_edict(ent, EV_ENT_euser2, 0);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.5);

		return PLUGIN_CONTINUE;
	}

	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id))
	{
		remove_entity(ent);
		return PLUGIN_CONTINUE;
	}

	if (entity_get_float(ent, EV_FL_ltime)-2.0 < halflife_time())
		set_rendering ( ent, kRenderFxNone, 255,255,255, kRenderTransAlpha, 100 );

	new Float:forigin[3];
	entity_get_vector(ent, EV_VEC_origin, forigin);

	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(forigin[i]);

 	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 300 );
	write_coord( iOrigin[2] + 300 );
	write_short( sprite_white_apteczki );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 0 ); // speed
	message_end();

	entity_set_edict(ent, EV_ENT_euser2 ,1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);

	return PLUGIN_CONTINUE;
}
