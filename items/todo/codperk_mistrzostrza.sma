#include <amxmodx>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>

#define nazwa "Mistrz ostrza"
#define opis "Co runde dostajesz LW nozy do rzucania"

new wartosc_perku[33],
ile_nozy[33]

public plugin_init() 
{
	register_plugin("Mistrz Ostrza", "1.0", "DarkGL")

	RegisterHam(Ham_Spawn, "player", "fwSpawn", 1)
	register_touch("throw_knife", "player", "knife_touch")
	register_touch("throw_knife", "worldspawn",		"touchWorld")
	register_touch("throw_knife", "func_wall",		"touchWorld")
	register_touch("throw_knife", "func_wall_toggle",	"touchWorld")
	
	cod_register_perk(nazwa, opis, 4, 10);
}

public plugin_precache()
{
	precache_model("models/w_throw.mdl");
	precache_sound("player/headshot1.wav")
	precache_sound("player/die1.wav")
}

public cod_perk_enabled(id, wartosc)
{
	ile_nozy[id] = (wartosc_perku[id] = wartosc)
}
	
public cod_perk_disabled(id)
	wartosc_perku[id] = 0;

public fwSpawn(id)
      ile_nozy[id] = wartosc_perku[id];

public touchWorld(Toucher, Touched)
{
	remove_entity(Toucher)
	return PLUGIN_HANDLED;
}

public knife_touch(Toucher, Touched) //ent dotykajacy, ofiara
{     
	if(!is_user_alive(Touched)) return

      new kid = entity_get_edict(Toucher, EV_ENT_owner) //atakujacy

      if(get_user_team(Touched) == get_user_team(kid)) return ;
		
      new Float:Random_Float[3]
      for(new i = 0; i < 3; i++) Random_Float[i] = random_float(-50.0, 50.0)
      Punch_View(Touched, Random_Float)
		
      new knife_damage = random_num(50, 140)
      if(knife_damage >= get_user_health(Touched))
            KillPlayer(Touched, Toucher, kid, (1<<1))
      else
      {
            cod_inflict_damage(kid, Touched, float(knife_damage), 0.0, Toucher, (1<<1))
            emit_sound(Touched, CHAN_ITEM, "player/headshot1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
      }

      remove_entity(Toucher)
}

public cod_perk_used(id)
{
	new ent = create_entity("info_target")
	if (pev_valid(ent))
	{
		if(ile_nozy[id]-- < 1)
		{
			client_print(id, print_center, "Nie masz wiecej nozy!");
			return 0;
		}
			
		new Float:vangles[3], Float:nvelocity[3], Float:voriginf[3], vorigin[3];
		
		set_pev(ent, pev_owner, id);
		set_pev(ent, pev_classname, "throw_knife");
		engfunc(EngFunc_SetModel, ent, "models/w_throw.mdl");
		set_pev(ent, pev_gravity, 0.1);	
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
		
		new veloc = 700
		
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
	set_pev(id, pev_punchangle, ViewAngle)

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
      write_string("knife")
	message_end()
}