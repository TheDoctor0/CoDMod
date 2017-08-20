#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>
#include <codmod>

#define PLUGIN "Wskrzeszanie medyk"
#define VERSION "0.2"
#define AUTHOR "Cypis, edited by Hleb"

#define pev_zorigin	pev_fuser4
#define seconds(%1) ((1<<12) * (%1))

new const perk_name[] = "Moc Medyka"
new const perk_desc[] = "Mozesz wskrzeszac swoich oraz bezczescic przeciwnikow LW razy"

new SOUND_START[] 	= "items/medshot4.wav"
new SOUND_FINISHED[] 	= "items/smallmedkit2.wav"
new SOUND_FAILED[] 	= "items/medshotno1.wav"

enum
{
	ICON_HIDE = 0,
	ICON_SHOW,
	ICON_FLASH
}

enum
{
	TASKID_REVIVE = 1337,
	TASKID_RESPAWN,
	TASKID_CHECKRE,
	TASKID_CHECKST,
	TASKID_ORIGIN,
	TASKID_SETUSER
}

new g_haskit[33]
new ile_ma[33]
new Float:g_revive_delay[33]
new Float:g_body_origin[33][3]
new bool:g_wasducking[33]

new g_msg_bartime,
	g_msg_statusicon,
	g_msg_screenfade,
	g_msg_clcorpse;

new cvar_revival_time,
	cvar_revival_health,
	cvar_revival_dis,
	cvar_za_zbeszczeszczenie,
	cvar_za_wskrzeszenie,
	cvar_za_hpdefiling,
	ilerazy[33];

public plugin_init()
{			
	cod_register_perk(perk_name, perk_desc, 5, 8)
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cvar_revival_time = register_cvar("cod_perk_revkit_time", "3")
	cvar_revival_health = register_cvar("cod_perk_revkit_health", "100")
	cvar_revival_dis = register_cvar("cod_perk_revkit_distance", 	"100.0")
	cvar_za_zbeszczeszczenie = register_cvar("cod_perk_revkit_xpdefiling", "20")
	cvar_za_wskrzeszenie = register_cvar("cod_perk_revkit_xpraise", "40")
	cvar_za_hpdefiling = register_cvar("cod_perk_revkit_hpdefiling", "30")
	
	register_event("HLTV", "event_hltv", "a", "1=0", "2=0")
	register_event("DeathMsg","DeathMsg","ade")  
	
	register_forward(FM_EmitSound, "fwd_emitsound")
	register_forward(FM_PlayerPostThink, "fwd_playerpostthink")
	
	g_msg_bartime = get_user_msgid("BarTime")
	g_msg_clcorpse = get_user_msgid("ClCorpse")
	g_msg_screenfade= get_user_msgid("ScreenFade")
	g_msg_statusicon = get_user_msgid("StatusIcon")
	
	register_message(g_msg_clcorpse, "message_clcorpse")
}
public cod_perk_enabled(id, wartosc)
{
	if(cod_get_user_class(id) == cod_get_classid("Medyk"))
		return COD_STOP;
		
	g_haskit[id] = 1
	ile_ma[id] = 0
	ilerazy[id] = wartosc;
	return COD_CONTINUE;
}
public cod_perk_disabled(id)
{
	g_haskit[id] = 0;
	ile_ma[id] = 0;
	remove_task(TASKID_REVIVE + id)
	Display_Icon(id, ICON_HIDE , "dmg_shock")
}
public plugin_precache()
{ 
	precache_model("models/player/arctic/arctic.mdl")
	precache_model("models/player/leet/leet.mdl")
	precache_model("models/player/guerilla/guerilla.mdl")
	precache_model("models/player/terror/terror.mdl")
	precache_model("models/player/urban/urban.mdl")
	precache_model("models/player/sas/sas.mdl")
	precache_model("models/player/gsg9/gsg9.mdl")
	precache_model("models/player/gign/gign.mdl")
	precache_model("models/player/vip/vip.mdl")
		
	precache_sound(SOUND_START)
	precache_sound(SOUND_FINISHED)
	precache_sound(SOUND_FAILED)
}

public client_connect(id)
{
	g_haskit[id] = 0
	ile_ma[id] = 0
	reset_player(id)
}

public client_disconnect(id)
{
	new ent	    
	while((ent = fm_find_ent_by_owner(ent, "fake_corpse", id)) != 0)
		fm_remove_entity(ent)
}

public DeathMsg(id)
{
	new vid = read_data(2)
		
	reset_player(vid)
	msg_bartime(id, 0)
	static Float:minsize[3]
	pev(vid, pev_mins, minsize)
	if(minsize[2] == -18.0)
		g_wasducking[vid] = true
	else
		g_wasducking[vid] = false
	
	set_task(0.5, "task_check_dead_flag", vid)
}

public event_hltv()
{
	fm_remove_entity_name("fake_corpse")
	
	static players[32], num
	get_players(players, num, "a")
	for(new i = 0; i < num; i++)
	{
		if(is_user_connected(players[i]))
		{
			reset_player(players[i])
			msg_bartime(players[i], 0)
		}
	}
}

public reset_player(id)
{
	remove_task(TASKID_REVIVE + id)
	remove_task(TASKID_RESPAWN + id)
	remove_task(TASKID_CHECKRE + id)
	remove_task(TASKID_CHECKST + id)
	remove_task(TASKID_ORIGIN + id)
	remove_task(TASKID_SETUSER + id)
	
	
	g_revive_delay[id] 	= 0.0
	g_wasducking[id] 	= false
	g_body_origin[id] 	= Float:{0.0, 0.0, 0.0}
}

public fwd_playerpostthink(id)
{
	if(!is_user_connected(id)) 
		return FMRES_IGNORED
		
	if(g_haskit[id]==0) 
		return FMRES_IGNORED
	
	if(!is_user_alive(id))
	{
		Display_Icon(id, ICON_HIDE , "dmg_shock")
		return FMRES_IGNORED
	}
	
	new body = find_dead_body(id)
	if(fm_is_valid_ent(body))
	{
		new lucky_bastard = pev(body, pev_owner)
	
		if(!is_user_connected(lucky_bastard))
			return FMRES_IGNORED

		new lb_team = get_user_team(lucky_bastard)
		if(lb_team == 1 || lb_team == 2 )
			Display_Icon(id, ICON_FLASH , "dmg_shock")		
	}
	else
		Display_Icon(id, ICON_SHOW , "dmg_shock")
	
	return FMRES_IGNORED
}

public task_check_dead_flag(id)
{
	if(!is_user_connected(id))
		return
	
	if(pev(id, pev_deadflag) == DEAD_DEAD)
		create_fake_corpse(id)
	else
		set_task(0.5, "task_check_dead_flag", id)
}	

public create_fake_corpse(id)
{
	set_pev(id, pev_effects, EF_NODRAW)
	
	static model[32]
	cs_get_user_model(id, model, 31)
		
	static player_model[64]
	format(player_model, 63, "models/player/%s/%s.mdl", model, model)
			
	static Float: player_origin[3]
	pev(id, pev_origin, player_origin)
		
	static Float:mins[3]
	mins[0] = -16.0
	mins[1] = -16.0
	mins[2] = -34.0
	
	static Float:maxs[3]
	maxs[0] = 16.0
	maxs[1] = 16.0
	maxs[2] = 34.0
	
	if(g_wasducking[id])
	{
		mins[2] /= 2
		maxs[2] /= 2
	}
		
	static Float:player_angles[3]
	pev(id, pev_angles, player_angles)
	player_angles[2] = 0.0
				
	new sequence = pev(id, pev_sequence)
	
	new ent = fm_create_entity("info_target")
	if(ent)
	{
		set_pev(ent, pev_classname, "fake_corpse")
		engfunc(EngFunc_SetModel, ent, player_model)
		engfunc(EngFunc_SetOrigin, ent, player_origin)
		engfunc(EngFunc_SetSize, ent, mins, maxs)
		set_pev(ent, pev_solid, SOLID_TRIGGER)
		set_pev(ent, pev_movetype, MOVETYPE_TOSS)
		set_pev(ent, pev_owner, id)
		set_pev(ent, pev_angles, player_angles)
		set_pev(ent, pev_sequence, sequence)
		set_pev(ent, pev_frame, 9999.9)
	}	
}

public cod_perk_used(id) 
{
	if(!is_user_alive(id) || !g_haskit[id])
		return FMRES_IGNORED	
	
	if(task_exists(TASKID_REVIVE + id))
		return FMRES_IGNORED
	
	new body = find_dead_body(id)
	if(!fm_is_valid_ent(body))
		return FMRES_IGNORED

	new lucky_bastard = pev(body, pev_owner)
	new lb_team = get_user_team(lucky_bastard)
	if(lb_team != 1 && lb_team != 2)
		return FMRES_IGNORED

	static name[32]
	get_user_name(lucky_bastard, name, 31)
	client_print(id, print_chat, "Reanimacja %s Trwa", name)
		
	new revivaltime = get_pcvar_num(cvar_revival_time)
	msg_bartime(id, revivaltime)
	
	new Float:gametime = get_gametime()
	g_revive_delay[id] = gametime + float(revivaltime) - 0.01

	emit_sound(id, CHAN_AUTO, SOUND_START, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_task(0.0, "task_revive", TASKID_REVIVE + id)
	
	return FMRES_SUPERCEDE
}

public task_revive(taskid) 
{
	new id = taskid - TASKID_REVIVE
	
	if(!is_user_alive(id))
	{
		failed_revive(id)
		return FMRES_IGNORED
	}
	new body = find_dead_body(id)
	if(!fm_is_valid_ent(body))
	{
		failed_revive(id)
		return FMRES_IGNORED
	}
	
	new lucky_bastard = pev(body, pev_owner)
	if(!is_user_connected(lucky_bastard))
	{
		failed_revive(id)
		return FMRES_IGNORED
	}
	
	new lb_team = get_user_team(lucky_bastard)
	if(lb_team != 1 && lb_team != 2)
	{
		failed_revive(id)
		return FMRES_IGNORED
	}
	
	static Float:velocity[3]
	pev(id, pev_velocity, velocity)
	velocity[0] = 0.0
	velocity[1] = 0.0
	set_pev(id, pev_velocity, velocity)
	
	new Float:gametime = get_gametime()
	
	if(g_revive_delay[id] < gametime)
	{
		if(findemptyloc(body, 10.0))
		{
			fm_remove_entity(body)
			emit_sound(id, CHAN_AUTO, SOUND_FINISHED, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			ile_ma[id]++;
			
			if(ile_ma[id] == ilerazy[id])
				off(id)
		
			new args[2]
			args[0]=lucky_bastard
			
			if(get_user_team(id)!=get_user_team(lucky_bastard))
			{
				args[1]=1
				new za_zbeszczeszczenie = get_pcvar_num(cvar_za_zbeszczeszczenie)
				new za_hpdefiling = get_pcvar_num(cvar_za_hpdefiling)
				new health = 100+cod_get_user_health(id);
				new nowe_zdrowie = (get_user_health(id)+za_hpdefiling<health)? get_user_health(id)+za_hpdefiling: health;
				fm_set_user_health(id, nowe_zdrowie);
				cod_set_user_xp(id, cod_get_user_xp(id)+za_zbeszczeszczenie)
				client_print(id, print_chat, "[COD:MW] Dostales %i doswiadczenia za zbeszczeszczenie zwlok wroga.", za_zbeszczeszczenie);
			}
			else
			{
				args[1]=0
				new za_wskrzeszenie = get_pcvar_num(cvar_za_wskrzeszenie)
				cod_set_user_xp(id, cod_get_user_xp(id)+za_wskrzeszenie)
				client_print(id, print_chat, "[COD:MW] Dostales %i doswiadczenia za wskrzeszenie kolegi z teamu.", za_wskrzeszenie);
				set_task(0.1, "task_respawn", TASKID_RESPAWN + lucky_bastard,args,2)
			}
		}
		else
			failed_revive(id)
	}
	else
		set_task(0.1, "task_revive", TASKID_REVIVE + id)
	
	return FMRES_IGNORED
}

public failed_revive(id)
{
	msg_bartime(id, 0)
	emit_sound(id, CHAN_AUTO, SOUND_FAILED, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public off(id)
{
	g_haskit[id] = 0
	msg_bartime(id, 0)
	reset_player(id)
	Display_Icon(id, ICON_HIDE , "dmg_shock")
}

public task_origin(args[])
{
	new id = args[0]
	engfunc(EngFunc_SetOrigin, id, g_body_origin[id])
	
	static  Float:origin[3]
	pev(id, pev_origin, origin)
	set_pev(id, pev_zorigin, origin[2])
		
	set_task(0.1, "task_stuck_check", TASKID_CHECKST + id,args,2)
	
}

stock find_dead_body(id)
{
	static Float:origin[3]
	pev(id, pev_origin, origin)
	
	new ent
	static classname[32]	
	while((ent = fm_find_ent_in_sphere(ent, origin, get_pcvar_float(cvar_revival_dis))) != 0) 
	{
		pev(ent, pev_classname, classname, 31)
		if(equali(classname, "fake_corpse") && fm_is_ent_visible(id, ent))
			return ent
	}
	return 0
}

stock msg_bartime(id, seconds) 
{
	if(is_user_bot(id)||!is_user_alive(id)||!is_user_connected(id))
		return
	
	message_begin(MSG_ONE, g_msg_bartime, _, id)
	write_byte(seconds)
	write_byte(0)
	message_end()
}

public task_respawn(args[]) 
{
	new id = args[0]
	
	if (!is_user_connected(id) || is_user_alive(id) || cs_get_user_team(id) == CS_TEAM_SPECTATOR) return
		
	set_pev(id, pev_deadflag, DEAD_RESPAWNABLE) 
	dllfunc(DLLFunc_Think, id) 
	dllfunc(DLLFunc_Spawn, id) 
	set_pev(id, pev_iuser1, 0)
	
	set_task(0.1, "task_check_respawn", TASKID_CHECKRE + id,args,2)
}

public task_check_respawn(args[])
{
	new id = args[0]
	
	if(pev(id, pev_iuser1))
		set_task(0.1, "task_respawn", TASKID_RESPAWN + id,args,2)
	else
		set_task(0.1, "task_origin", TASKID_ORIGIN + id,args,2)

}
 
public task_stuck_check(args[])
{
	new id = args[0]

	static Float:origin[3]
	pev(id, pev_origin, origin)
	
	if(origin[2] == pev(id, pev_zorigin))
		set_task(0.1, "task_respawn", TASKID_RESPAWN + id,args,2)
	else
		set_task(0.1, "task_setplayer", TASKID_SETUSER + id,args,2)
}

public task_setplayer(args[])
{
	new id = args[0]
	fm_set_user_health(id, get_pcvar_num(cvar_revival_health))
				
	Display_Fade(id,seconds(2),seconds(2),0,0,0,0,255)
}

stock bool:findemptyloc(ent, Float:radius)
{
	if(!fm_is_valid_ent(ent))
		return false

	static Float:origin[3]
	pev(ent, pev_origin, origin)
	origin[2] += 2.0
	
	new owner = pev(ent, pev_owner)
	new num = 0, bool:found = false
	
	while(num <= 100)
	{
		if(is_hull_vacant(origin))
		{
			g_body_origin[owner][0] = origin[0]
			g_body_origin[owner][1] = origin[1]
			g_body_origin[owner][2] = origin[2]
			
			found = true
			break
		}
		else
		{
			origin[0] += random_float(-radius, radius)
			origin[1] += random_float(-radius, radius)
			origin[2] += random_float(-radius, radius)
			
			num++
		}
	}
	return found
}

stock bool:is_hull_vacant(const Float:origin[3])
{
	new tr = 0
	engfunc(EngFunc_TraceHull, origin, origin, 0, HULL_HUMAN, 0, tr)
	if(!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid) && get_tr2(tr, TR_InOpen))
		return true
	
	return false
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin(MSG_ONE, g_msg_screenfade,{0,0,0},id)
	write_short(duration)	
	write_short(holdtime)
	write_short(fadetype)
	write_byte(red)	
	write_byte(green)
	write_byte(blue)
	write_byte(alpha)
	message_end()
}

stock Display_Icon(id ,enable ,name[])
{
	if(!pev_valid(id) || is_user_bot(id))
		return PLUGIN_HANDLED
	
	message_begin(MSG_ONE, g_msg_statusicon, {0,0,0}, id) 
	write_byte(enable) 	
	write_string(name) 
	write_byte(42) 
	write_byte(42) 
	write_byte(255)
	message_end()
	
	return PLUGIN_CONTINUE
}

public message_clcorpse()
	return PLUGIN_HANDLED
