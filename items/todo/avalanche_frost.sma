#include <amxmodx>
#include <engine>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>

#define RADIUS 250.0
#define FROST_DURATION 4.0
#define FROST_CODE 3245879
#define ice_model "models/dd_iceblock.mdl"
#define V_MODEL "models/zombie_plague/v_grenade_frost.mdl"

new have_frost[33], iceent[33], g_glassSpr, g_msgScreenFade, grenadetrail, frostgib, g_explosfr, g_exploSpr, g_msgDamage
public plugin_init()
{
	register_plugin("Avalanche Frost" , "1.0" , "maTT_hArdy")
	register_cvar("fros", "hardy", FCVAR_SERVER|FCVAR_SPONLY)
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_Touch, "fw_Touch")
	RegisterHam(Ham_Item_Deploy,"weapon_flashbang", "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Killed, "player", "player_dead")
	g_msgDamage = get_user_msgid("Damage")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	register_clcmd("say /get2", "give_avalfrost")
}

public plugin_precache()
{
	grenadetrail = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
	g_explosfr = precache_model("sprites/frost_exp.spr")
	g_exploSpr = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
	frostgib = precache_model("sprites/frostgib.spr")
	g_glassSpr = engfunc(EngFunc_PrecacheModel, "models/glassgibs.mdl")
	engfunc(EngFunc_PrecacheModel, ice_model)
	engfunc(EngFunc_PrecacheModel, V_MODEL)
	engfunc(EngFunc_PrecacheSound, "warcraft3/frostnova.wav")
	engfunc(EngFunc_PrecacheSound, "warcraft3/impalehit.wav")
	engfunc(EngFunc_PrecacheSound, "warcraft3/impalelaunch1.wav")
}

public client_putinserver(id)
{	
	new g_Ham_Bot

	if(!g_Ham_Bot && is_user_bot(id))
	{
		g_Ham_Bot = 1
		set_task(0.1, "Do_RegisterHam_Bot", id)
	}
}

public Do_RegisterHam_Bot(id)
{
	RegisterHamFromEntity(Ham_Killed, id, "player_dead")
}

public fw_Item_Deploy_Post(weapon_ent)
{
	static id; id = fm_cs_get_weapon_ent_owner(weapon_ent)
	if (!pev_valid(id))
		return
	
	if(!have_frost[id])
		return
		
	set_pev(id, pev_viewmodel2, V_MODEL)
}

public fw_Touch(pfn, ptd)
{
	if(!pev_valid(pfn))
		return
		
	static Classname[32]; pev(pfn, pev_classname, Classname, sizeof(Classname))
	if(equal(Classname, "grenade"))
	{
		if(pev(pfn, pev_iuser2) != FROST_CODE)
			return

		frost_explode(pfn)
		
		set_pev(pfn, pev_iuser2, 0)
		
		engfunc(EngFunc_RemoveEntity, pfn)
	}
}

frost_explode(ent)
{
	// Get origin
	static Float:originF[3], Owner
	pev(ent, pev_origin, originF)
	Owner = pev(ent, pev_owner)
	// Make the explosion
	create_blast(originF)
	
	// Fire nade explode sound
	emit_sound(ent, CHAN_WEAPON, "warcraft3/frostnova.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	static Float:PlayerOrigin[3]
	for(new i = 0; i < get_maxplayers(); i++)
	{
		if(!is_user_alive(i))
			continue
		if(cs_get_user_team(i) == cs_get_user_team(Owner))
			continue
		pev(i, pev_origin, PlayerOrigin)
		if(get_distance_f(originF, PlayerOrigin) > RADIUS)
			continue
			
		if(!is_user_connected(Owner)) Owner = i
		ami_frozen(i)
		
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, i)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_DROWN) // damage type - DMG_FREEZE
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
		
		emit_sound(i, CHAN_BODY, "warcraft3/impalehit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		message_begin(MSG_ONE, g_msgScreenFade, _, i)
		write_short(0) // duration
		write_short(0) // hold time
		write_short(0x0004) // fade type
		write_byte(0) // red
		write_byte(50) // green
		write_byte(200) // blue
		write_byte(100) // alpha
		message_end()
				
		set_task(FROST_DURATION, "remove_freeze", i)
	}
}

public remove_freeze(id)
{
	// Not alive or not frozen anymore
	if (!is_user_alive(id))
		return;
		
	// Gradually remove screen's blue tint
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short((1<<12)) // duration
	write_short(0) // hold time
	write_short(0x0000) // fade type
	write_byte(0) // red
	write_byte(50) // green
	write_byte(200) // blue
	write_byte(100) // alpha
	message_end()
	
	ice_entity( id, 0 )
	
	// Broken glass sound
	emit_sound(id, CHAN_BODY, "warcraft3/impalelaunch1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get player's origin
	static origin2[3]
	get_user_origin(id, origin2)
	
	// Glass shatter
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
	write_byte(TE_BREAKMODEL) // TE id
	write_coord(origin2[0]) // x
	write_coord(origin2[1]) // y
	write_coord(origin2[2]+24) // z
	write_coord(16) // size x
	write_coord(16) // size y
	write_coord(16) // size z
	write_coord(random_num(-50, 50)) // velocity x
	write_coord(random_num(-50, 50)) // velocity y
	write_coord(25) // velocity z
	write_byte(10) // random velocity
	write_short(g_glassSpr) // model
	write_byte(10) // count
	write_byte(25) // life
	write_byte(0x01) // flags
	message_end()
}

public fw_SetModel(entity, const model[])
{
	// We don't care
	if (strlen(model) < 8)
		return;
	
	if (model[9] == 'f' && model[10] == 'l' && model[11] == 'a' && model[12] == 's' && model[13] == 'h' && model[14] == 'b' && have_frost[pev(entity, pev_owner)]) // Napalm Grenade
	{
		// Give it a glow
		fm_set_rendering(entity, kRenderFxGlowShell, 84, 231, 247, kRenderNormal, 16);
		
		set_pev(entity, pev_iuser2, FROST_CODE)
		have_frost[pev(entity, pev_owner)] = 0
		
		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(grenadetrail) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(0) // r
		write_byte(191) // g
		write_byte(255) // b
		write_byte(200) // brightness
		message_end()
	}
}

public give_avalfrost(id)
{
	fm_give_item( id, "weapon_flashbang" )
	have_frost[id] = 1
}

public Event_NewRound()
{
	for(new i = 0; i < get_maxplayers(); i++)
	{
		ice_entity( i, 0 )
	}
}

public player_dead(id)
{
	ice_entity( id, 0 )
}

public ami_frozen(id)
{
	ice_entity( id, 1 ) 
}

stock ice_entity( id, status ) 
{
	if(status)
	{
		static ent, Float:o[3]
		if(!is_user_alive(id))
		{
			ice_entity( id, 0 )
			return
		}
		
		if( is_valid_ent(iceent[id]) )
		{
			if( pev( iceent[id], pev_iuser3 ) != id )
			{
				if( pev(iceent[id], pev_team) == 6969 ) remove_entity(iceent[id])
			}
			else
			{
				pev( id, pev_origin, o )
				if( pev( id, pev_flags ) & FL_DUCKING  ) o[2] -= 15.0
				else o[2] -= 35.0
				entity_set_origin(iceent[id], o)
				return
			}
		}
		
		pev( id, pev_origin, o )
		if( pev( id, pev_flags ) & FL_DUCKING  ) o[2] -= 15.0
		else o[2] -= 35.0
		ent = create_entity("info_target")
		set_pev( ent, pev_classname, "DareDevil" )
		
		entity_set_model(ent, ice_model)
		dllfunc(DLLFunc_Spawn, ent)
		set_pev(ent, pev_solid, SOLID_BBOX)
		set_pev(ent, pev_movetype, MOVETYPE_FLY)
		entity_set_origin(ent, o)
		entity_set_size(ent, Float:{ -3.0, -3.0, -3.0 }, Float:{ 3.0, 3.0, 3.0 } )
		set_pev( ent, pev_iuser3, id )
		set_pev( ent, pev_team, 6969 )
		set_rendering(ent, kRenderFxNone, 255, 255, 255, kRenderTransAdd, 255)
		iceent[id] = ent
	}
	else
	{
		if( is_valid_ent(iceent[id]) )
		{
			if( pev(iceent[id], pev_team) == 6969 ) remove_entity(iceent[id])
			iceent[id] = -1
		}
	}
}

create_blast(const Float:originF[3])
{
    // Medium ring
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
    write_byte(TE_BEAMCYLINDER) // TE id
    engfunc(EngFunc_WriteCoord, originF[0]) // x
    engfunc(EngFunc_WriteCoord, originF[1]) // y
    engfunc(EngFunc_WriteCoord, originF[2]) // z
    engfunc(EngFunc_WriteCoord, originF[0]) // x axis
    engfunc(EngFunc_WriteCoord, originF[1]) // y axis
    engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
    write_short(g_exploSpr) // sprite
    write_byte(0) // startframe
    write_byte(0) // framerate
    write_byte(4) // life
    write_byte(60) // width
    write_byte(0) // noise
    write_byte(0) // red
    write_byte(191) // green
    write_byte(255) // blue
    write_byte(200) // brightness
    write_byte(0) // speed
    message_end()
    
    // Largest ring
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
    write_byte(TE_BEAMCYLINDER) // TE id
    engfunc(EngFunc_WriteCoord, originF[0]) // x
    engfunc(EngFunc_WriteCoord, originF[1]) // y
    engfunc(EngFunc_WriteCoord, originF[2]) // z
    engfunc(EngFunc_WriteCoord, originF[0]) // x axis
    engfunc(EngFunc_WriteCoord, originF[1]) // y axis
    engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
    write_short(g_exploSpr) // sprite
    write_byte(0) // startframe
    write_byte(0) // framerate
    write_byte(4) // life
    write_byte(60) // width
    write_byte(0) // noise
    write_byte(0) // red
    write_byte(191) // green
    write_byte(255) // blue
    write_byte(200) // brightness
    write_byte(0) // speed
    message_end()
    
    // Luz Dinamica
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
    write_byte(TE_DLIGHT) // TE id
    engfunc(EngFunc_WriteCoord, originF[0]) // x
    engfunc(EngFunc_WriteCoord, originF[1]) // y
    engfunc(EngFunc_WriteCoord, originF[2]) // z
    write_byte(50) // radio
    write_byte(0) // red
    write_byte(191) // green
    write_byte(255) // blue
    write_byte(30) // vida en 0.1, 30 = 3 segundos
    write_byte(30) // velocidad de decaimiento
    message_end()

    engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, originF, 0)
    write_byte(TE_EXPLOSION)
    engfunc(EngFunc_WriteCoord, originF[0]) // x axis
    engfunc(EngFunc_WriteCoord, originF[1]) // y axis
    engfunc(EngFunc_WriteCoord, originF[2]+10) // z axis
    write_short(g_explosfr)
    write_byte(17)
    write_byte(15)
    write_byte(TE_EXPLFLAG_NOSOUND)
    message_end();
    
    
    engfunc(EngFunc_MessageBegin, MSG_BROADCAST,SVC_TEMPENTITY, originF, 0)
    write_byte(TE_SPRITETRAIL) // TE ID
    engfunc(EngFunc_WriteCoord, originF[0]) // x axis
    engfunc(EngFunc_WriteCoord, originF[1]) // y axis
    engfunc(EngFunc_WriteCoord, originF[2] + 40) // z axis
    engfunc(EngFunc_WriteCoord, originF[0]) // x axis
    engfunc(EngFunc_WriteCoord, originF[1]) // y axis
    engfunc(EngFunc_WriteCoord, originF[2]) // z axis
    write_short(frostgib) // Sprite Index
    write_byte(30) // Count
    write_byte(10) // Life
    write_byte(4) // Scale
    write_byte(50) // Velocity Along Vector
    write_byte(10) // Rendomness of Velocity
    message_end();
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	if (pev_valid(ent) != 2)
		return -1
	
	return get_pdata_cbase(ent, 41, 4)
}