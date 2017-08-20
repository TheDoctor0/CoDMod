#include <amxmodx>
#include <codmod>
#include <fun>
#include cstrike
#include <engine>
#include <hamsandwich>
#include fakemeta_util


#define TASK_WYSZKOLENIE_SANITARNE 736

new const nazwa[]   = "Terminator [SP]";
new const opis[]    = "Ma 2 apteczki, co 5 sekund +7 hp, +30 hp za frag";
new const bronie    = (1<<CSW_DEAGLE)|(1<<CSW_FAMAS)|(1<<CSW_FLASHBANG)|(1<<CSW_HEGRENADE);
new const zdrowie   = 25;
new const kondycja  = 25;
new const inteligencja = 15;
new const wytrzymalosc = 25;

new sprite_white_apteczki, ilosc_apteczek_gracza[33], bool:ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Super Premium");
	
      register_think("medkit", "Think_Apteczki");

	RegisterHam(Ham_Spawn, "player", "fwSpawn_Apteczki", 1);
	
      register_event("DeathMsg", "Death", "ade");
}

public plugin_precache()
{
	sprite_white_apteczki = precache_model("sprites/white.spr");
	precache_model("models/w_medkit.mdl");
}

public cod_class_enabled(id)
{
	if(!(cod_get_user_status(id) & STATUS_SPREMIUM))
	{
		client_print(id, print_chat, "[%s] Nie masz super premium, zeby grac ta klasa!", nazwa)
		return COD_STOP;
	}

	ma_klase[id] = true;

	set_task(0.2, "fwSpawn_Apteczki", id)
      set_task(5.0, "WyszkolenieSanitarne", id+TASK_WYSZKOLENIE_SANITARNE);

	return COD_CONTINUE
}

public Death()
{
	new attacker = read_data(1);
	
	if(!is_user_connected(attacker))
		return PLUGIN_CONTINUE;
		
	if(!ma_klase[attacker])
		return PLUGIN_CONTINUE;
		
	new cur_health = get_user_health(attacker);
	new max_health = 100+cod_get_user_health(attacker);
	new new_health = cur_health+30<max_health? cur_health+30: max_health;
	set_user_health(attacker, new_health);
	
	return PLUGIN_CONTINUE;
}

public cod_class_disabled(id)
	ma_klase[id] = false;

public cod_class_skill_used(id)
{
	if (!ilosc_apteczek_gracza[id])
		client_print(id, print_center, "Masz 2 apteczki na runde!");
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
      if(ma_klase[id])
      {
            ilosc_apteczek_gracza[id] = 2;
            cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
      }
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
		new numfound = find_sphere_class(0,"player", float(250),entlist, 32,forigin);
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
	write_coord( iOrigin[1] + 250 );
	write_coord( iOrigin[2] + 250 );
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

public WyszkolenieSanitarne(id)
{
	id -= TASK_WYSZKOLENIE_SANITARNE;
	
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	if(ma_klase[id])
	{
		set_task(5.0, "WyszkolenieSanitarne", id+TASK_WYSZKOLENIE_SANITARNE);
		
		if(is_user_alive(id))
		{
			new cur_health = get_user_health(id);
			new max_health = 100+cod_get_user_health(id);
			new new_health = cur_health+7<max_health? cur_health+7: max_health;
			set_user_health(id, new_health);
		}
	}
	return PLUGIN_CONTINUE;
}