#include amxmodx
#include codmod
#include <cstrike>
#include <hamsandwich>
#include <engine>
#include <fakemeta>

#pragma tabsize 0

new sprite_blast;

new PobraneOrigin[3];

public plugin_init()
{
      new nazwa[] = "Nalot"
      new opis[] = "Mozesz jednorazowo wezwac nalot na wskazane miejsce"
      
      register_plugin(nazwa, "1.0", "RiviT")
      
      cod_register_perk(nazwa, opis)
      
      register_touch("bomb", "*", "touchedrocket");
	
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	
	precache_model("models/p_hegrenade.mdl");
      precache_sound("jet_fly1.wav");
	precache_model("models/cod_plane.mdl");
}

public cod_perk_used(id)
{
      set_task(1.0, "CreateBombs", id+997, _, _, "a", 3);
      CreatePlane(id);
            
      cod_set_user_perk(id, 0)
}

public CreateBombs(taskid)
{	
	new id = (taskid-997);
	
	new radlocation[3];
	PobraneOrigin[0] += random_num(-300,300);
	PobraneOrigin[1] += random_num(-300,300);
	PobraneOrigin[2] += 50;
	
	for(new i=0; i<15; i++) 
	{
		radlocation[0] = PobraneOrigin[0]+1*random_num(-150,150); 
		radlocation[1] = PobraneOrigin[1]+1*random_num(-150,150); 
		radlocation[2] = PobraneOrigin[2]; 
		
		new Float:LocVec[3]; 
		IVecFVec(radlocation, LocVec); 
		create_ent(id, "bomb", "models/p_hegrenade.mdl", 2, 10, LocVec);
	}
}  

public CreatePlane(id)
{
	new Float:Origin[3], Float:Angle[3], Float:Velocity[3], ent;
	
	get_user_origin(id, PobraneOrigin, 3);
	
	velocity_by_aim(id, 1500, Velocity);
	entity_get_vector(id, EV_VEC_origin, Origin);
	entity_get_vector(id, EV_VEC_v_angle, Angle);
	
	Angle[0] = Velocity[2] = 0.0;
	Origin[2] += 290.0;
	
	ent = create_ent(id, "samolot", "models/cod_plane.mdl", 2, 8, Origin);
	
	entity_set_vector(ent, EV_VEC_velocity, Velocity);
	entity_set_vector(ent, EV_VEC_angles, Angle);
	
      emit_sound(ent, CHAN_ITEM, "jet_fly1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);

	set_task(4.5, "del_plane", ent+5731);
}

public del_plane(taskid)
	remove_entity(taskid-5731);

public touchedrocket(ent, id)
{
	if(!is_valid_ent(ent))
		return PLUGIN_CONTINUE;
	
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	
	new Float:entOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, entOrigin);
	entOrigin[2] += 1.0;
	
	new entlist[33];
	new numfound = find_sphere_class(ent, "player", 150.0, entlist, 32);	
	for(new i=0; i < numfound; i++)
	{			
		if(!is_user_alive(entlist[i]) || get_user_team(attacker) == get_user_team(entlist[i]))
			continue;
			
            KillPlayer(entlist[i], attacker, attacker, (1<<24))
	}
	Sprite_Blast(entOrigin);
	remove_entity(ent);
	
	return PLUGIN_CONTINUE
}

stock create_ent(id, szName[], szModel[], iSolid, iMovetype, Float:fOrigin[3])
{
	new ent = create_entity("info_target");
	entity_set_string(ent, EV_SZ_classname, szName);
	entity_set_model(ent, szModel);
	entity_set_int(ent, EV_INT_solid, iSolid);
	entity_set_int(ent, EV_INT_movetype, iMovetype);
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_origin(ent, fOrigin);
	return ent;
}

stock Sprite_Blast(Float:iOrigin[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	write_coord(floatround(iOrigin[0]));
	write_coord(floatround(iOrigin[1])); 
	write_coord(floatround(iOrigin[2]));
	write_short(sprite_blast);
	write_byte(32);
	write_byte(20); 
	write_byte(0);
	message_end();
}

KillPlayer(id, inflictor, attacker, damagebits)
{
	static DeathMsgId
	
	new msgblock, effect
	if (!DeathMsgId)	DeathMsgId = get_user_msgid("DeathMsg")
	
	msgblock = get_msg_block(DeathMsgId)
	set_msg_block(DeathMsgId, BLOCK_ONCE)
	
	set_pdata_int(id, 75, HIT_CHEST , 5)
	set_pdata_int(id, 76, damagebits, 5)
	
	ExecuteHamB(Ham_Killed, id, attacker, 1)
	
	set_pev(id, pev_dmg_inflictor, inflictor)
	
	effect = pev(id, pev_effects)
	if(effect & 128)	set_pev(id, pev_effects, effect-128)
	
	set_msg_block(DeathMsgId, msgblock)

	message_begin(MSG_ALL, DeathMsgId)
	write_byte(attacker)
	write_byte(id)
	write_byte(0)
      write_string("grenade")
	message_end()
}

public NowaRunda()
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new i = 0; i < num; i++)
	{
		if(task_exists(players[i]+997))
			remove_task(players[i]+997);
	}
}