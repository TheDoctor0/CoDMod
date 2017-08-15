//Bf2 Rank Mod effects File
//Contains subroutines for all graphical features.

#if defined effects_included
  #endinput
#endif
#define effects_included

// Creates an icon above target players head. Used to displays rank icon
stock Create_TE_PLAYERATTACHMENT(id, entity, vOffset, iSprite, life)
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id);
	write_byte(TE_PLAYERATTACHMENT);
	write_byte(entity);			// entity
	write_coord(vOffset);			// vertical offset ( attachment origin.z = player origin.z + vertical offset )
	write_short(iSprite);			// model index
	write_short(life);			// (life * 10 )
	message_end();
}

// Makes the users screen flash given colour
public screen_flash(id, red, green, blue, alpha)
{
	message_begin(MSG_ONE_UNRELIABLE, gmsgScreenFade, _, id);
	write_short(1<<12);
	write_short(1<<12);
	write_short(1<<12);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	message_end();
}

//Makes a player glow the given colour
public player_glow(id, red, green, blue)
{
	fm_set_rendering(id, kRenderFxGlowShell, red, green, blue, kRenderNormal, 16);
	set_task(1.0, "player_noglow", id + TASK_GLOW);
}

//Resets player to not glowing
public player_noglow(id)
{
	id -= TASK_GLOW;
	
	if(!is_user_connected(id))
		return;
		
	fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 16);
	set_invis(id);
}

//Makes player in ice cube
public set_freeze(id)
{
	if(gFrozen[id] || !is_user_alive(id) || !(pev(id, pev_flags) & FL_ONGROUND))
		return;
		
	gFrozen[id] = true;
	
	static origin[3];
	get_user_origin(id, origin);
	
	message_begin(MSG_ONE_UNRELIABLE, gmsgDamage, _, id);
	write_byte(0); // damage save
	write_byte(0); // damage take
	write_long(DMG_DROWN); // damage type - DMG_FREEZE
	write_coord(0); // x
	write_coord(0); // y
	write_coord(0); // z
	message_end();
	
	emit_sound(id, CHAN_BODY, gSoundFrost, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	set_speed(id);
	
	create_icecube(id);
	
	ApplyFrozenGravity(id);
	
	set_task(0.5, "remove_freeze", id + TASK_FROST);
}

//Remove frost effect
public remove_freeze(id)
{
	id -= TASK_FROST;
	
	gFrozen[id] = false;
	
	if(pev_valid(gIceEnt[id]))
	{
		remove_entity(gIceEnt[id]);
		gIceEnt[id] = 0;
	}
	
	if(!is_user_alive(id))
		return;
	
	set_speed(id);
	
	set_pev(id, pev_gravity, gFrozenGravity[id]);
	
	emit_sound(id, CHAN_BODY, gSoundBreak, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	static origin[3];
	get_user_origin(id, origin);
	
	// Glass shatter
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin);
	write_byte(TE_BREAKMODEL); // TE id
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]+24); // z
	write_coord(16); // size x
	write_coord(16); // size y
	write_coord(16); // size z
	write_coord(random_num(-50, 50)); // velocity x
	write_coord(random_num(-50, 50)); // velocity y
	write_coord(25); // velocity z
	write_byte(10); // random velocity
	write_short(gGlassSpr); // model
	write_byte(10); // count
	write_byte(25); // life
	write_byte(0x01); // flags
	message_end();
}

#define GRAVITY_HIGH 999.9

//Add frozen gravity
public ApplyFrozenGravity(id)
{
	if(!is_user_alive(id))
		return;
		
	new Float:gravity = get_user_gravity(id)
	
	if (gravity == GRAVITY_HIGH)
		return;
	
	gFrozenGravity[id] = gravity
	
	set_user_gravity(id, GRAVITY_HIGH)
}

public create_icecube(id)
{	
	gIceEnt[id] = create_entity("info_target");
	
	if(!pev_valid(gIceEnt[id])) 
		return;
	
	new Float:origin[3];
	pev(id, pev_origin, origin);
	if(pev(id, pev_flags) & FL_DUCKING) 
		origin[2] -= 15.0;
	else 
		origin[2] -= 35.0;
	entity_set_origin(gIceEnt[id], origin);
	
	entity_set_model(gIceEnt[id], gModelIceCube);
	set_pev(gIceEnt[id], pev_solid, SOLID_NOT);
	set_pev(gIceEnt[id], pev_movetype, MOVETYPE_FLY);
	entity_set_size(gIceEnt[id], Float:{ -3.0, -3.0, -3.0 }, Float:{ 3.0, 3.0, 3.0 } );
	set_rendering(gIceEnt[id], kRenderFxNone, 255, 255, 255, kRenderTransAdd, 255);
	dllfunc(DLLFunc_Spawn, gIceEnt[id]);
}