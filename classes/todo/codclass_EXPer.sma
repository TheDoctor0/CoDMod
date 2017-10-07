/* Plugin wygenerowany przez AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <fun>
#include <codmod>
#include <colorchat>

#define DMG_BULLET (1<<1)

new bool:ma_klase[33];

new ile_nozy[33];
new blood
new blood2

new const nazwa[] = "EXPer";
new const opis[] = "Dostaje +10 expa za fraga, wybucha po smierci zadajac 80dmg(+int), ma 6 nozy ktorymi moze rzucac na odleglosc oraz ma 1/2 szans na zreanimowanie czlonka druzyny";
new const bronie = 1<<CSW_SG552 | 1<<CSW_DEAGLE;
new const zdrowie = 20;
new const kondycja = 22;
new const inteligencja = 0;
new const wytrzymalosc = 25;

new sprite_blast, 
sprite_white;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "BloodMan");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("DeathMsg", "Death", "ade");
	register_event("DeathMsg", "Zrespij", "ade");
	register_event("DeathMsg", "DodajEXP", "ade");
	
	register_cvar("amx_knifedamage_mw2","100")
	register_cvar("amx_knifespeed_mw2","600")
	register_cvar("amx_knifegravity_mw2","0.3")
	register_event("HLTV", "Nowa_Runda", "a", "1=0", "2=0") 
	register_touch("throw_knife", "player", "knife_touch")
	register_touch("throw_knife", "worldspawn",		"touchWorld")
	register_touch("throw_knife", "func_wall",		"touchWorld")
	register_touch("throw_knife", "func_wall_toggle",	"touchWorld")
}

public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr") ;
	sprite_blast = precache_model("sprites/dexplo.spr");
	blood = precache_model("sprites/blood.spr")
	blood2 = precache_model("sprites/bloodspray.spr")
	precache_model("models/w_throw.mdl");
	precache_sound("player/headshot1.wav")
	precache_sound("player/die1.wav")
}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		ColorChat(id, RED, "[General] Nie masz uprawnien, aby korzystac z tej klasy.");
		return COD_STOP;
	}
	ma_klase[id] = true;
	return COD_CONTINUE;
}

public cod_class_disabled(id)
	ma_klase[id] = false;

public cod_class_skill_used(id)
	pusc_noz(id);

public Nowa_Runda()
{
	for(new i = 0;i<33;i++){
		ile_nozy[i] = 6;
	}
}

public touchWorld(Toucher, Touched)
{
	remove_entity(Toucher)
	return PLUGIN_HANDLED;
}

public Death()
{
	new id = read_data(2);
	if (ma_klase[id])
		Eksploduj(id);
}

public Eksploduj(id)
{
	new Float:fOrigin[3], iOrigin[3];
	entity_get_vector( id, EV_VEC_origin, fOrigin);
	iOrigin[0] = floatround(fOrigin[0]);
	iOrigin[1] = floatround(fOrigin[1]);
	iOrigin[2] = floatround(fOrigin[2]);
	
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
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 300 );
	write_coord( iOrigin[2] + 300 );
	write_short( sprite_white );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 8 ); // speed
	message_end();
	
	new entlist[33];
	new numfound = find_sphere_class(id, "player", 300.0 , entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if (!is_user_alive(pid) || get_user_team(id) == get_user_team(pid))
			continue;
		cod_inflict_damage(id, pid, 80.0, 0.2);
	}
	return PLUGIN_CONTINUE;
}

public knife_touch(Toucher, Touched){
	new kid = entity_get_edict(Toucher, EV_ENT_owner)
	new vic = entity_get_edict(Toucher, EV_ENT_enemy)
	if (is_user_alive(Touched)) 
	{
		new bool:zyje = true;
		if (kid == Touched || vic == Touched)
		{
			return ;
		}
		if (get_cvar_num("mp_friendlyfire") == 0 && get_user_team(Touched) == get_user_team(kid)) 
		{
			return ;
		}
		
		new Float:Random_Float[3]
		for(new i = 0; i < 3; i++) Random_Float[i] = random_float(-50.0, 50.0)
		Punch_View(Touched, Random_Float)
		
		if (get_cvar_num("amx_knifedamage_mw2") >= get_user_health(Touched)){
			zyje = false;
		}
		new origin[3];
		get_user_origin(Touched,origin)
		origin[2] += 25
		if (zyje == true){
			if (get_user_team(Touched) == get_user_team(kid)) 
			{
				new name[33]
				get_user_name(kid,name,32)
				client_print(0,print_chat,"%s attacked a teammate",name)
			}
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2])
			write_short(blood2)
			write_short(blood)
			write_byte(229)
			write_byte(25)
			message_end()
			set_user_health(Touched,get_user_health(Touched) - get_cvar_num("amx_knifedamage_mw2"));
			emit_sound(Touched, CHAN_ITEM, "player/headshot1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		
		else
		{
			if (get_user_team(Touched) == get_user_team(kid)) {
				set_user_frags(kid, get_user_frags(kid) - 1)
				client_print(kid,print_center,"You killed a teammate")
			}
			else {
				set_user_frags(kid, get_user_frags(kid) + 1)
			}
			
			new gmsgScoreInfo = get_user_msgid("ScoreInfo")
			new gmsgDeathMsg = get_user_msgid("DeathMsg")
			
			
			
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2])
			write_short(blood2)
			write_short(blood)
			write_byte(229)
			write_byte(25)
			message_end()
			
			//Zabijam tego co dostal i blokuje wiadomosci
			set_msg_block(gmsgDeathMsg,BLOCK_ONCE)
			set_msg_block(gmsgScoreInfo,BLOCK_ONCE)
			user_kill(Touched,1)
			
			//zmieniam ilosc fragow w tablicy zabojcy
			message_begin(MSG_ALL,gmsgScoreInfo)
			write_byte(kid)
			write_short(get_user_frags(kid))
			write_short(get_user_deaths(kid))
			write_short(0)
			write_short(get_user_team(kid))
			message_end()
			
			//zmieniam ilosc zginiec w tablicy ofiary
			message_begin(MSG_ALL,gmsgScoreInfo)
			write_byte(Touched)
			write_short(get_user_frags(Touched))
			write_short(get_user_deaths(Touched))
			write_short(0)
			write_short(get_user_team(Touched))
			message_end()
			
			//Pokazuje wiadomosc o zabiciu
			message_begin(MSG_ALL,gmsgDeathMsg,{0,0,0},0)
			write_byte(kid)
			write_byte(Touched)
			write_byte(0)
			write_string("knife")
			message_end()
			emit_sound(Touched, CHAN_ITEM, "player/die1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		//usuwam noz
		remove_entity(Toucher)
	}
}

public pusc_noz(id)
{
	new ent = create_entity("info_target")
	if (pev_valid(ent) && is_user_alive(id))
	{
		if (ile_nozy[id]-- < 1)
		{
			client_print(id, print_center, "Nie masz wiecej nozy!");
			return 0;
		}
		
		new Float:vangles[3], Float:nvelocity[3], Float:voriginf[3], vorigin[3];
		
		set_pev(ent, pev_owner, id);
		set_pev(ent, pev_classname, "throw_knife");
		engfunc(EngFunc_SetModel, ent, "models/w_throw.mdl");
		set_pev(ent, pev_gravity, get_cvar_float("amx_knifegravity_mw2"));	
		get_user_origin(id, vorigin, 1);
		
		IVecFVec(vorigin, voriginf);
		set_pev(ent,pev_origin,voriginf)
		
		static Float:player_angles[3]
		pev(id, pev_angles, player_angles)
		player_angles[2] = 0.0
		set_pev(ent, pev_angles, player_angles);
		
		pev(id, pev_v_angle, vangles);
		set_pev(ent, pev_v_angle, vangles);
		pev(id, pev_view_ofs, vangles);
		set_pev(ent, pev_view_ofs, vangles);
		
		new veloc = get_cvar_num("amx_knifespeed_mw2")
		
		set_pev(ent, pev_movetype, MOVETYPE_TOSS);
		set_pev(ent, pev_solid, 2);
		velocity_by_aim(id, veloc, nvelocity);	
		
		set_pev(ent, pev_velocity, nvelocity);
		set_pev(ent, pev_effects, pev(ent, pev_effects) & ~EF_NODRAW);
		set_pev(ent,pev_sequence,0)
		set_pev(ent,pev_framerate,1.0)
		
		entity_set_edict(ent, EV_ENT_owner, id)
	}
	return ent;
}

public Punch_View(id, Float:ViewAngle[3])
{
	set_pev(id, pev_punchangle, ViewAngle)
}

public Zrespij()
{
	new attacker = read_data(1);
	
	if (!is_user_connected(attacker))
		return PLUGIN_CONTINUE;
	
	if (!ma_klase[attacker])
		return PLUGIN_CONTINUE;
	
	if (random(2) == 1)
		return PLUGIN_CONTINUE;
	
	new id = read_data(2);
	new attacker_team = get_user_team(attacker);
	
	if (get_user_team(id) == attacker_team)
		return PLUGIN_CONTINUE;
	
	new Players[32], playersCount;	
	
	get_players(Players, playersCount, "beh", (attacker_team == 1)? "TERRORIST" : "CT");
	
	if (!playersCount)
		return PLUGIN_CONTINUE;
	
	new nick_zreanimowanego[33], nick_reanimujacego[33], zreanimowany = Players[random(playersCount)];
	
	Zresp(zreanimowany);
	
	get_user_name(zreanimowany, nick_zreanimowanego, 32);
	get_user_name(attacker, nick_reanimujacego, 32);
	
	ColorChat(zreanimowany, GREEN, "Zostales zreanimowany przez %s.", nick_reanimujacego);
	ColorChat(attacker, GREEN, "Zreanimowales %s.", nick_zreanimowanego);
	
	return PLUGIN_CONTINUE;
}

public Zresp(id)
{
	set_pev(id, pev_deadflag, DEAD_RESPAWNABLE);
	set_pev(id, pev_iuser1, 0);
	dllfunc(DLLFunc_Think, id)
}

public DodajEXP(id)
{
	new attacker = read_data(1);
	if (!is_user_connected(attacker))
		return PLUGIN_CONTINUE;
	
	if (!ma_klase[attacker])
		return PLUGIN_CONTINUE;
	
	if (get_user_team(id) != get_user_team(attacker))
		cod_set_user_xp(id, cod_get_user_xp(id)+15);
	
	return PLUGIN_CONTINUE;
}
