#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
        
new const nazwa[]   = "Bogdaniec";
new const opis[]    = "Aug , Famas , 2 apteczki";
new const bronie    = (1<<CSW_AUG)|(1<<CSW_FAMAS);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;
    
new sprite_white_apteczki;
new ilosc_apteczek_gracza[33];


public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_think("medkit", "Think_Apteczki");

	RegisterHam(Ham_Spawn, "player", "fwSpawn_Apteczki", 1);

}

public plugin_precache()
{

	sprite_white_apteczki = precache_model("sprites/white.spr");
	precache_model("models/w_medkit.mdl");

}

public client_disconnect(id)
{

	new entApteczki = find_ent_by_class(0, "medkit");
	while(entApteczki > 0)
	{
		if (entity_get_edict(entApteczki, EV_ENT_owner) == id)
			remove_entity(entApteczki);
		entApteczki = find_ent_by_class(entApteczki, "medkit");
	}

}

public cod_class_enabled(id)
{

	ilosc_apteczek_gracza[id] = 2;

}

public cod_class_skill_used(id)
{
        
	if (!ilosc_apteczek_gracza[id])
	{
		client_print(id, print_center, "Masz tylko 2 apteczki na runde!");
	}
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
	if (is_user_alive(id))
		ilosc_apteczek_gracza[id] = 2;
}


public Think_Apteczki(ent)
{
	if (!is_valid_ent(ent))
		return PLUGIN_CONTINUE;

	new id = entity_get_edict(ent, EV_ENT_owner);
	new dist = 300;
	new heal = 5+floatround(cod_get_user_intelligence(id)*0.5);

	if (entity_get_edict(ent, EV_ENT_euser2) == 1)
	{
		new Float:forigin[3];
		entity_get_vector(ent, EV_VEC_origin, forigin);

		new entlist[33];
		new numfound = find_sphere_class(0,"player", float(dist),entlist, 32,forigin);

		for (new i=0; i < numfound; i++)
		{
			new pid = entlist[i];

			if (get_user_team(pid) != get_user_team(id))
				continue;

			new maksymalne_zdrowie = 100+cod_get_user_health(pid);
			new zdrowie = get_user_health(pid);
			new Float:nowe_zdrowie = (zdrowie+heal<maksymalne_zdrowie)?zdrowie+heal+0.0:maksymalne_zdrowie+0.0;
			if (is_user_alive(pid)) entity_set_float(pid, EV_FL_health, nowe_zdrowie);
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
	write_coord( iOrigin[1] + dist );
	write_coord( iOrigin[2] + dist );
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

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
