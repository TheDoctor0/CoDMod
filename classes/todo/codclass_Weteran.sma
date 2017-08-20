#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>

new const nazwa[]   = "Weteran";
new const opis[]    = "150 widocznosci, 1 dynamit";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_GALIL);
new const zdrowie   = 20;
new const kondycja  = -10;
new const inteligencja = 5;
new const wytrzymalosc = 30;

new ilosc_dynamitow_gracza[33], sprite_blast_dynamit, sprite_white_dynamit, bool:ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Darmowe");
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Dynamit", 1);
}

public plugin_precache()
{
	sprite_blast_dynamit = precache_model("sprites/dexplo.spr");
	sprite_white_dynamit = precache_model("sprites/white.spr");
	precache_model("models/QTM_CodMod/dynamite.mdl");
}

public cod_class_enabled(id)
{
	cod_set_user_rendering(id, 150)
	ilosc_dynamitow_gracza[id] = 1;
	ma_klase[id] = true;
}

public cod_class_disabled(id)
{
	cod_remove_user_rendering(id)
	ma_klase[id] = false;
}

public cod_class_skill_used(id)
{
		if(!ilosc_dynamitow_gracza[id])
			client_print(id, print_center, "Wykorzystales juz wszystkie dynamity!");

		else
		{
			
			static dynamit_gracza[33];
			if(is_valid_ent(dynamit_gracza[id]))
			{
				ilosc_dynamitow_gracza[id]--;
				
				new Float:fOrigin[3];
				entity_get_vector(dynamit_gracza[id], EV_VEC_origin, fOrigin);
				
				new iOrigin[3];
				for(new i=0;i<3;i++)
					iOrigin[i] = floatround(fOrigin[i]);
				
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
				write_byte(TE_EXPLOSION);
				write_coord(iOrigin[0]);
				write_coord(iOrigin[1]);
				write_coord(iOrigin[2]);
				write_short(sprite_blast_dynamit);
				write_byte(32);
				write_byte(20);
				write_byte(0);
				message_end();
				
				message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
				write_byte( TE_BEAMCYLINDER );
				write_coord( iOrigin[0] );
				write_coord( iOrigin[1] );
				write_coord( iOrigin[2] );
				write_coord( iOrigin[0] );
				write_coord( iOrigin[1] + 250 );
				write_coord( iOrigin[2] + 250 );
				write_short( sprite_white_dynamit );
				write_byte( 0 );
				write_byte( 0 );
				write_byte( 10 );
				write_byte( 10 );
				write_byte( 255 );
				write_byte( 255 );
				write_byte( 100 );
				write_byte( 100 );
				write_byte( 128 );
				write_byte( 0 );
				message_end();
				
				new entlist[33];
				iOrigin[0] = find_sphere_class(dynamit_gracza[id], "player", 250.0 , entlist, 32);
				
				for (new i=0; i < iOrigin[0]; i++)
				{               
					if (is_user_alive(entlist[i]) && get_user_team(id) != get_user_team(entlist[i]))
						cod_inflict_damage(id, entlist[i], 95.0, 0.8, dynamit_gracza[id], (1<<24));
				}
				remove_entity(dynamit_gracza[id]);
			}
			else
			{
				
				new Float:origin[3];
				entity_get_vector(id, EV_VEC_origin, origin);
				
				dynamit_gracza[id] = create_entity("info_target");
				entity_set_string(dynamit_gracza[id], EV_SZ_classname, "dynamite");
				entity_set_edict(dynamit_gracza[id], EV_ENT_owner, id);
				entity_set_int(dynamit_gracza[id], EV_INT_movetype, MOVETYPE_TOSS);
				entity_set_origin(dynamit_gracza[id], origin);
				entity_set_int(dynamit_gracza[id], EV_INT_solid, SOLID_BBOX);
				
				entity_set_model(dynamit_gracza[id], "models/QTM_CodMod/dynamite.mdl");
				entity_set_size(dynamit_gracza[id], Float:{-16.0,-16.0,0.0}, Float:{16.0,16.0,2.0});
				
				drop_to_floor(dynamit_gracza[id]);
			}
		}
}

public fwSpawn_Dynamit(id)
{
	ilosc_dynamitow_gracza[id] = 1;
}