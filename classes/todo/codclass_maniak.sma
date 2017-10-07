#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fun>

new const nazwa[]   = "Maniak";
new const opis[]    = "Dostaje HE|AK|M249 jest mniej widzialny i bardzo szybki na nozu oraz posiada 3 dynamity moze uzyc co 3sek.";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_M249)|(1<<CSW_AK47);
new const zdrowie   = 0;
new const kondycja  = 60;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new dynamit_gracza[33];
new ilosc_dynamitow_gracza[33];
new Float:poprzedni_dynamit_gracza[33];

new sprite_blast_dynamit, sprite_white_dynamit;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("CurWeapon", "eventKnife_Niewidzialnosc", "be", "1=1");
	
	register_event("HLTV", "NowaRunda_Dynamit", "a", "1=0", "2=0");
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Dynamit", 1);
	
}

public plugin_precache()
{
	
	sprite_blast_dynamit = precache_model("sprites/dexplo.spr");
	sprite_white_dynamit = precache_model("sprites/white.spr");
	precache_model("models/QTM_CodMod/dynamite.mdl");
	
}

public client_disconnect(id)
{
	
	new entDynamit = find_ent_by_class(0, "dynamite");
	while(entDynamit > 0)
	{
		if (entity_get_edict(entDynamit, EV_ENT_owner) == id)
			remove_entity(entDynamit);
		entDynamit = find_ent_by_class(entDynamit, "dynamite");
	}
	
}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_C))
	{
		client_print(id, print_chat, "[] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	ilosc_dynamitow_gracza[id] = 3;
	give_item(id, "weapon_hegrenade");
	ma_klase[id] = true;
	
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	ma_klase[id] = false;
	
}

public cod_class_skill_used(id)
{
	
	if (is_user_alive(id)){
		if (!ilosc_dynamitow_gracza[id])
		{
			client_print(id, print_center, "Wykorzystales juz wszystkie dynamity!");
		}
		if (poprzedni_dynamit_gracza[id] + 2.0 > get_gametime()) 
		{
			client_print(id, print_center, "Dynamitow mozesz uzywac co 2 sekundy!");
			return PLUGIN_CONTINUE; 
		}
		else{
			
			static dynamit_gracza[33];
			if (is_valid_ent(dynamit_gracza[id]))
			{
				poprzedni_dynamit_gracza[id] = get_gametime();
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
				new numfound = find_sphere_class(dynamit_gracza[id], "player", 250.0 , entlist, 32);
				
				for (new i=0; i < numfound; i++)
				{               
					new pid = entlist[i];
					
					if (is_user_alive(pid) && get_user_team(id) != get_user_team(pid))
						cod_inflict_damage(id, pid, 95.0, 0.8, dynamit_gracza[id], (1<<24));
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
	
}

public eventKnife_Niewidzialnosc(id)
{
	if (!ma_klase[id])
		return;
	
	if ( read_data(2) == CSW_KNIFE )
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 100);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}

public fwSpawn_Dynamit(id)
{
	client_disconnect(id);
	ilosc_dynamitow_gracza[id] = 3;
}


public NowaRunda_Dynamit()
{
	new ent = find_ent_by_class(-1, "dynamite");
	while(ent > 0)
	{
		remove_entity(ent);
		ent = find_ent_by_class(ent, "dynamite");
	}
}
