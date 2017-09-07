#include amxmodx
#include codmod
#include engine
#include hamsandwich
#include fakemeta
#include fakemeta_util

new const nazwa[]   = "Partyzant";
new const opis[] = "Na E strzela zlotymi strzalami, ktore po trafieniu w przeciwnika zadaja mu 120 DMG +int/2.";
new const bronie    = (1<<CSW_M4A1);
new const zdrowie   = 20;
new const kondycja  = 20;
new const inteligencja = 0;
new const wytrzymalosc = 10;

new cbow_bolt[]  = "models/Crossbow_bolt.mdl"

new bool:ma_klase[33]

new wait1[33]

new sprite_blood_drop = 0
new sprite_blood_spray = 0

public plugin_init()
{
	register_plugin(nazwa, "1.0", "sharkowy");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_touch("xbow_arrow", "player", 			"toucharrow")
	register_touch("xbow_arrow", "worldspawn",		"touchWorld2")
	register_touch("xbow_arrow", "func_wall",		"touchWorld2")
	register_touch("xbow_arrow", "func_door",		"touchWorld2")
	register_touch("xbow_arrow", "func_door_rotating",	"touchWorld2")
	register_touch("xbow_arrow", "func_wall_toggle",	"touchWorld2")
	//register_touch("xbow_arrow", "dbmod_shild",		"touchWorld2")
	
	register_touch("xbow_arrow", "func_breakable",		"touchbreakable")
	register_touch("func_breakable", "xbow_arrow",		"touchbreakable")
	
	register_cvar("cod_arrow","120.0")
	register_cvar("cod_arrow_multi","2.0")
	register_cvar("cod_arrow_speed","1800")
}

public plugin_precache()
{
	precache_model(cbow_bolt)
	sprite_blood_spray = precache_model("sprites/bloodspray.spr")
	sprite_blood_drop = precache_model("sprites/blood.spr")
}

public cod_class_enabled(id)
	ma_klase [id] = true;

public cod_class_disabled(id)
	ma_klase[id] = false;

public cod_class_skill_used(id)
{

	new xD = floatround(halflife_time()-wait1[id])
	new czas = 10-xD
	if (halflife_time()-wait1[id] <= 10)
	{
		client_print(id, print_center, "Za %d sek mozesz uzyc mocy!", czas)
		return PLUGIN_CONTINUE;
	}															
	else {
		command_arrow(id)
		wait1[id]=floatround(halflife_time())
	}
	return PLUGIN_HANDLED
}

/*kod wyciagniety z diablo moda*/
public command_arrow(id) 
{

	if(!is_user_alive(id)) return PLUGIN_HANDLED


	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)

	Ent = create_entity("info_target")

	if (!Ent) return PLUGIN_HANDLED

	entity_set_string(Ent, EV_SZ_classname, "xbow_arrow")
	entity_set_model(Ent, cbow_bolt)

	new Float:MinBox[3] = {-2.8, -2.8, -0.8}
	new Float:MaxBox[3] = {2.8, 2.8, 2.0}
	entity_set_vector(Ent, EV_VEC_mins, MinBox)
	entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

	vAngle[0]*= -1
	Origin[2]+=10
	
	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)

	entity_set_int(Ent, EV_INT_effects, 2)
	entity_set_int(Ent, EV_INT_solid, 1)
	entity_set_int(Ent, EV_INT_movetype, 5)
	entity_set_edict(Ent, EV_ENT_owner, id)
	new Float:dmg = get_cvar_float("cod_arrow") + cod_get_user_intelligence(id) * get_cvar_float("cod_arrow_multi") //ten cvar nie dziala chyba, dmg edytujemy "na sucho" nizej
	entity_set_float(Ent, EV_FL_dmg,dmg)

	VelocityByAim(id, get_cvar_num("cod_arrow_speed") , Velocity)
	set_rendering (Ent,kRenderFxGlowShell, 232,232,0, kRenderNormal,50)
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
	
	return PLUGIN_HANDLED
}

public toucharrow(arrow, id)
{	
	new kid = entity_get_edict(arrow, EV_ENT_owner)
	new lid = entity_get_edict(arrow, EV_ENT_enemy)
	
	if(is_user_alive(id)) 
	{
		if(kid == id || lid == id) return
		
		entity_set_edict(arrow, EV_ENT_enemy,id)
	
		new Float:dmg = entity_get_float(arrow,EV_FL_dmg)
		entity_set_float(arrow,EV_FL_dmg,(dmg*3.0)/5.0)
		
		if(get_cvar_num("mp_friendlyfire") == 0 && get_user_team(id) == get_user_team(kid)) return
		
		Effect_Bleed(id,248)

		//bowdelay[kid] -=  0.5 - floatround(player_intelligence[kid]/5.0)
	
		ExecuteHam(Ham_TakeDamage, id, kid, kid, 120.0+cod_get_user_intelligence(kid)/2, 1); //tu zmieniamy dmg
				
		message_begin(MSG_ONE,get_user_msgid("ScreenShake"),{0,0,0},id); 
		write_short(7<<14); 
		write_short(1<<13); 
		write_short(1<<14); 
		message_end();

		if(get_user_team(id) == get_user_team(kid)) 
		{
			new name[33]
			get_user_name(kid,name,32)
			client_print(0,print_chat,"%s attacked a teammate",name)
		}

		emit_sound(id, CHAN_ITEM, "weapons/knife_hit4.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		if(dmg<30) remove_entity(arrow)
	}
}

public touchWorld2(arrow, world)
{
	remove_entity(arrow)
}

stock Effect_Bleed(id,color)
{
	new origin[3]
	get_user_origin(id,origin)
	
	new dx, dy, dz
	
	for(new i = 0; i < 3; i++) 
	{
		dx = random_num(-15,15)
		dy = random_num(-15,15)
		dz = random_num(-20,25)
		
		for(new j = 0; j < 2; j++) 
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0]+(dx*j))
			write_coord(origin[1]+(dy*j))
			write_coord(origin[2]+(dz*j))
			write_short(sprite_blood_spray)
			write_short(sprite_blood_drop)
			write_byte(color) // color index
			write_byte(8) // size
			message_end()
		}
	}
}