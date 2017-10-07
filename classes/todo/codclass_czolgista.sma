#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#include <codmod>

#define MAX 32

#define nazwa "Czolgista"
#define opis "Dostaje Bazuke za P228"

new const bronie = 1<<CSW_GALIL|1<<CSW_P228;
new const zdrowie = 20;
new const kondycja = -10;
new const inteligencja = 5;
new const wytrzymalosc = 10;

new bool:wystrzelony[MAX+1][MAX+1];	
new bool:ma_klase[MAX+1], bool:has_weapon[MAX+1], bool:reloading[MAX+1], rockets[MAX+1], Float:idle[MAX+1];
new sprite_blast, sprite_nadeexp, sprite_smoke, sprite_trail;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "cypis");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	RegisterHam(Ham_Spawn, "player", "Odrodzenie", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_p228", "Weapon_Deploy", 1);
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_p228", "Weapon_WeaponIdle");
	
	register_forward(FM_CmdStart, "CmdStart");
	register_forward(FM_SetModel, "SetModel");
	register_forward(FM_Touch, "fw_Touch")
	
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	
	register_cvar("cod_law_damage", "120.0");
	register_cvar("cod_law_radius", "250.0");
	register_cvar("cod_law_rockets", "15");
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	sprite_smoke = precache_model("sprites/steam1.spr");
	sprite_nadeexp = precache_model("sprites/law_exp.spr");
	sprite_trail = precache_model("sprites/smoke.spr");

	precache_model("models/p_law.mdl");
	precache_model("models/w_law.mdl");
	precache_model("models/v_law.mdl");
	precache_model("models/s_grenade.mdl");
	precache_sound("weapons/law_shoot1.wav");
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	Odrodzenie(id)
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	has_weapon[id] = false;
	rockets[id] = 0;
}

public Odrodzenie(id)
{
	if (is_user_alive(id) && ma_klase[id])
	{
		has_weapon[id] = true;
		rockets[id] = get_cvar_num("cod_law_rockets");
	}	
}
	
public CmdStart(id, uc)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED;
	
	new weapon = get_user_weapon(id);
	if (weapon == 1 && has_weapon[id])
	{ 
		new button = get_uc(uc, UC_Buttons);
		new ent = fm_find_ent_by_owner(-1, "weapon_p228", id);
		
		if (button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc, UC_Buttons, button);
			
			if (!rockets[id] || reloading[id] || !idle[id]) 
				return FMRES_IGNORED;
			if (idle[id] && (get_gametime()-idle[id]<=0.4)) 
				return FMRES_IGNORED;
		
			new Float:Origin[3], Float:Angle[3], Float:Velocity[3];
			pev(id, pev_origin, Origin);
			pev(id, pev_v_angle, Angle);
			velocity_by_aim(id, 1000, Velocity);
			
			Angle[0] *= -1.0
			
			new ent = fm_create_entity("info_target")
			set_pev(ent, pev_classname, "rocket");
			engfunc(EngFunc_SetModel, ent, "models/s_grenade.mdl");
			
			set_pev(ent, pev_solid, SOLID_BBOX);
			set_pev(ent, pev_movetype, MOVETYPE_TOSS);
			set_pev(ent, pev_owner, id);
			set_pev(ent, pev_mins, Float:{-1.0, -1.0, -1.0});
			set_pev(ent, pev_maxs, Float:{1.0, 1.0, 1.0});
			set_pev(ent, pev_gravity, 0.35);
			
			set_pev(ent, pev_origin, Origin);
			set_pev(ent, pev_velocity, Velocity);
			set_pev(ent, pev_angles, Angle);
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW)
			write_short(ent)
			write_short(sprite_trail)
			write_byte(6)
			write_byte(3)
			write_byte(224)	
			write_byte(224)	
			write_byte(255)
			write_byte(100)
			message_end()	
			
			set_pev(id, pev_weaponanim, 7);
			new entwpn = fm_find_ent_by_owner(-1, "weapon_p228", id)
			if (entwpn)
				set_pdata_float(entwpn, 48, 1.5+3.0, 4)
			set_pdata_float(id, 83, 1.5, 4)
			
			reloading[id] = true;
			emit_sound(id, CHAN_WEAPON, "weapons/law_shoot1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			if (task_exists(id+3512)) 
				remove_task(id+3512)
			
			set_task(1.5, "task_launcher_reload", id+3512)
			rockets[id]--;
		}
		else if (button & IN_RELOAD)
		{
			button &= ~IN_RELOAD;
			set_uc(uc, UC_Buttons, button);
			
			set_pev(id, pev_weaponanim, 0);
			set_pdata_float(id, 83, 0.5, 4);
			if (ent)
				set_pdata_float(ent, 48, 0.5+3.0, 4);
		}
		
		if (ent)
			cs_set_weapon_ammo(ent, -1);
		cs_set_user_bpammo(id, 1, rockets[id]);		
	}
	else if (weapon != 1 && has_weapon[id])
		idle[id] = 0.0;
		
	return FMRES_IGNORED;
}	

public Weapon_Deploy(ent)
{
	new id = get_pdata_cbase(ent, 41, 4);
	if (has_weapon[id])
	{
		set_pev(id, pev_viewmodel2, "models/v_law.mdl");
		set_pev(id, pev_weaponmodel2, "models/p_law.mdl");
	}
	return PLUGIN_CONTINUE;
}

public Weapon_WeaponIdle(ent)
{
	new id = get_pdata_cbase(ent, 41, 4);
	if (get_user_weapon(id) == 1 && has_weapon[id])
	{
		if (!idle[id]) 
			idle[id] = get_gametime();
	}
}

public SetModel(ent, model[])
{
	if (!pev_valid(ent))
		return FMRES_IGNORED
	
	if (!equal(model, "models/w_p228.mdl")) 
		return FMRES_IGNORED;

	new id = pev(ent, pev_owner);
	if (!has_weapon[id])
		return FMRES_IGNORED;

	engfunc(EngFunc_SetModel, ent, "models/w_law.mdl");
	set_pev(ent, pev_iuser4, rockets[id]);
	has_weapon[id] = false;
	return FMRES_SUPERCEDE;
}

public task_launcher_reload(id)
{
	id -= 3512;
	reloading[id] = false;
	set_pev(id, pev_weaponanim, 0);
}

public fw_Touch(ent, id)
{
	if (!pev_valid(ent))
		return FMRES_IGNORED
	
	new class[32]
	pev(ent, pev_classname, class, charsmax(class))

	if (!equal(class, "rocket"))
		return FMRES_IGNORED
		
	new attacker = pev(ent, pev_owner);
	new Float:entOrigin[3], Float:fDamage, Float:Origin[3];
	pev(ent, pev_origin, entOrigin);
	entOrigin[2] += 1.0;
	
	new Float:g_damage = get_cvar_float("cod_law_damage");
	new Float:g_radius = get_cvar_float("cod_law_radius");
	
	new victim = -1
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, entOrigin, g_radius)) != 0)
	{		
		if (!is_user_alive(victim) || get_user_team(attacker) == get_user_team(victim))
			continue;
		
		pev(victim, pev_origin, Origin);
		fDamage = g_damage - floatmul(g_damage, floatdiv(get_distance_f(Origin, entOrigin), g_radius));
		fDamage *= estimate_take_hurt(entOrigin, victim);
		if (fDamage>0.0)
			UTIL_Kill(attacker, victim, fDamage, DMG_BULLET);
	}
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
	write_byte(TE_EXPLOSION);
	write_coord(floatround(entOrigin[0]));
	write_coord(floatround(entOrigin[1]));
	write_coord(floatround(entOrigin[2]));
	write_short(sprite_nadeexp); 
	write_byte(40); 
	write_byte(30); 
	write_byte(14); 
	message_end(); 
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
	write_byte(TE_EXPLOSION); 
	write_coord(floatround(entOrigin[0])); 
	write_coord(floatround(entOrigin[1])); 
	write_coord(floatround(entOrigin[2])); 
	write_short(sprite_blast); 
	write_byte(40);
	write_byte(30);
	write_byte(TE_EXPLFLAG_NONE); 
	message_end(); 
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(5)
	write_coord(floatround(entOrigin[0])); 
	write_coord(floatround(entOrigin[1])); 
	write_coord(floatround(entOrigin[2]));
	write_short(sprite_smoke);
	write_byte(35);
	write_byte(5);
	message_end();
	fm_remove_entity(ent);
	return FMRES_IGNORED
}

public message_DeathMsg()
{
	static killer, victim;
	killer = get_msg_arg_int(1);
	victim = get_msg_arg_int(2);
        
	if (wystrzelony[killer][victim])
	{
		wystrzelony[killer][victim] = false;
		set_msg_arg_string(4, "grenade");
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

stock Float:estimate_take_hurt(Float:fPoint[3], ent) 
{
	new Float:fOrigin[3], tr, Float:fFraction;
	pev(ent, pev_origin, fOrigin);
	engfunc(EngFunc_TraceLine, fPoint, fOrigin, DONT_IGNORE_MONSTERS, 0, tr);
	get_tr2(tr, TR_flFraction, fFraction);
	if (fFraction == 1.0 || get_tr2(tr, TR_pHit) == ent)
		return 1.0;
	return 0.6;
}

stock UTIL_Kill(atakujacy, obrywajacy, Float:damage, damagebits)
{
	if (get_user_health(obrywajacy) <= floatround(damage))
		wystrzelony[atakujacy][obrywajacy] = true;
	
	cod_inflict_damage(atakujacy, obrywajacy, damage, 1.0, atakujacy, damagebits);
}
