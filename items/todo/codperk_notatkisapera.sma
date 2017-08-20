#include <amxmodx>
#include <engine>
#include <codmod>

new const nazwa[] = "Notatki Sapera";
new const opis[] = "Masz SW miny co runde";

new wartosc_perku[33] = 0;
new bool:ma_perk[33];
new ilosc_min_gracza[33];

new sprite_blast;
new saper_id;

new const model[] = "models/QTM_CodMod/mine.mdl"

public plugin_init()
 {
	register_plugin(nazwa, "1.0", "O'Zone");
	
	cod_register_perk(nazwa, opis, 2, 2);
	
	saper_id = cod_get_classid("Saper");
	
	register_event("ResetHUD", "ResetHUD", "abe");
	register_touch("mine", "*" , "DotykMiny");
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model(model);
}

public cod_perk_enabled(id, wartosc)
{
	if(cod_get_user_class(id) == saper_id)
		return COD_STOP;
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	ilosc_min_gracza[id] = wartosc_perku[id];
	return COD_CONTINUE;
}

public cod_perk_disabled(id){
	ma_perk[id] = false;
	ilosc_min_gracza[id]= 0;
}
	
public cod_perk_used(id)
{		
	if (!ilosc_min_gracza[id])
	{
		client_print(id, print_center, "Wykorzystales juz wszystkie miny!");
		return PLUGIN_CONTINUE;
	}
	
	ilosc_min_gracza[id]--;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
		
	new ent = create_entity("info_target");
	entity_set_string(ent ,EV_SZ_classname, "mine");
	entity_set_edict(ent ,EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, origin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	entity_set_model(ent, model);
	entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});
	
	drop_to_floor(ent);
	
	set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,50);
	
	
	return PLUGIN_CONTINUE;
}


public DotykMiny(ent, id)
{
	if(!is_valid_ent(ent))
		return;
		
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	if (get_user_team(attacker) != get_user_team(id))
	{
		new Float:fOrigin[3];
		entity_get_vector( ent, EV_VEC_origin, fOrigin);
	
		new iOrigin[3];
		for(new i=0;i<3;i++)
			iOrigin[i] = floatround(fOrigin[i]);
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_short(sprite_blast);
		write_byte(32); 
		write_byte(20); 
		write_byte(0);
		message_end();
		
		new entlist[33];
		new numfound = find_sphere_class(ent,"player", 90.0 ,entlist, 32);
		
		for (new i=0; i < numfound; i++)
		{		
			new pid = entlist[i];
			
			if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid))
				continue;
				
			cod_inflict_damage(attacker, pid, 70.0, 1.0, ent, (1<<24));
		}
		remove_entity(ent);
	}
}	

public ResetHUD(id)
	ilosc_min_gracza[id] = wartosc_perku[id];

public NowaRunda()
{
	new ent = find_ent_by_class(-1, "mine");
	while(ent > 0) 
	{
		remove_entity(ent);
		ent = find_ent_by_class(ent, "mine");	
	}
}

public client_disconnect(id)
{
	new ent = find_ent_by_class(0, "mine");
	while(ent > 0)
	{
		if(entity_get_edict(id, EV_ENT_owner) == id)
			remove_entity(ent);
		ent = find_ent_by_class(ent, "mine");
	}
}
