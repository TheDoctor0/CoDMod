#include <amxmodx>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <xs>
#include <fakemeta>
#include hamsandwich


#define TASKID_FLAME 54322
        
new const nazwa[] = "Piroman";
new const opis[] = "Dostajesz 5 min podpalajacych";
    
new const modelMiny[] = "models/QTM_CodMod/mine.mdl"

new ilosc_min_gracza[33]
new sprite_fire

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);
	
	register_touch("minef", "player",  "DotykMiny");
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Miny", 1);
}

public plugin_precache()
{
	precache_model(modelMiny);
      sprite_fire = precache_model("sprites/fire.spr")
}

public cod_perk_enabled(id)
{
	ilosc_min_gracza[id] = 5;
}

public cod_perk_used(id)
{
	if (!ilosc_min_gracza[id])
		client_print(id, print_center, "Wykorzystales juz wszystkie miny podpalajace!");
	else
	{
		ilosc_min_gracza[id]--;

		new Float:origin[3];
		entity_get_vector(id, EV_VEC_origin, origin);

		new ent = create_entity("info_target");
		entity_set_string(ent ,EV_SZ_classname, "minef");
		entity_set_edict(ent ,EV_ENT_owner, id);
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
		entity_set_origin(ent, origin);
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);

		entity_set_model(ent, modelMiny);
		entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});

		drop_to_floor(ent);

		set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,30);
	}
}

public fwSpawn_Miny(id)
{
	if(is_user_alive(id))
	{
		ilosc_min_gracza[id] = 5;
            remove_task(id+TASKID_FLAME)
      }
}

public DotykMiny(ent, id)
{
	if(!is_valid_ent(ent))
		return;

	new attacker = entity_get_edict(ent, EV_ENT_owner);

	if (get_user_team(attacker) != get_user_team(id) && is_user_alive(attacker))
	{
            if(task_exists(id+TASKID_FLAME))
                  remove_task(id+TASKID_FLAME);

            new data[2]
		data[0] = id
		data[1] = attacker
		set_task(0.6, "burning_flame", id+TASKID_FLAME, data, 2, "a", 25);

		remove_entity(ent);
	}
}

public burning_flame(data[2])
{
	new id = data[0]
	
	if(!is_user_alive(id))
	{
		remove_task(id+TASKID_FLAME);
		return PLUGIN_CONTINUE;
	}
	
	new origin[3];
	get_user_origin(id, origin)
	
	if(pev(id, pev_flags) & FL_ONGROUND)
	{
		static Float:velocity[3]
		pev(id, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, 0.5, velocity)
		set_pev(id, pev_velocity, velocity)
	}
	
      ExecuteHam(Ham_TakeDamage, id, data[1], data[1], 1.0, 1<<3)
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE)
	write_coord(origin[0]+random_num(-5,5))
	write_coord(origin[1]+random_num(-5,5))
	write_coord(origin[2]+random_num(-10,10))
	write_short(sprite_fire)
	write_byte(random_num(5,10))
	write_byte(200)
	message_end()
	
	return PLUGIN_CONTINUE;
}