#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <codmod>
#include <hamsandwich>
#include <fun>
 
#define PLUGIN "PluginName"
#define VERSION "1.0"
#define AUTHOR ".:Vitek:."
 
new const nazwa[] = "Czolgister";
new const opis[] = "Dostajesz M3, Elite oraz Bazooke (na nozu, PPM)";
new const bronie = 1<<CSW_M3 | 1<<CSW_ELITE
new const zdrowie = 0;
new const kondycja = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;
 
new ROCKET_MDL[64] = "models/rpgrocket.mdl"
new ROCKET_SOUND[64] = "weapons/rocketfire1.wav"
new getrocket[64] = "items/9mmclip2.wav"
 
new bool:ma_klase[33]
new bool:ma_bazooke[33]
new bool:rocket[33]
new bool:shot[33] = false
new bool:rksound[33] = false
 
new Float:gltime = 0.0
new Float:last_Rocket[33] = 0.0
new explosion, trail, white
 
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_event("CurWeapon", "check_models", "be")
 
	register_forward(FM_StartFrame, "fm_startFrame")
	register_forward(FM_EmitSound, "emitsound")
	register_forward(FM_UpdateClientData, "UpdateClientData_Post", 1)
}
 
public plugin_precache()
{
	precache_model("models/p_rpg.mdl")
	precache_model("models/v_rpg.mdl")
	precache_model("models/w_rpg.mdl")
 
	precache_model(ROCKET_MDL)
	precache_sound(ROCKET_SOUND)
	precache_sound(getrocket)
 
	explosion = precache_model("sprites/zerogxplode.spr")
	trail = precache_model("sprites/smoke.spr")
	white = precache_model("sprites/white.spr")
}
 
public cod_class_enabled(id){
	ma_klase[id] = true
	ma_bazooke[id] = true
	rocket[id] = true
}
 
public cod_class_disabled(id){
	ma_klase[id] = false
	rocket[id] = false
	ma_bazooke[id] = false
}
 
public fm_startFrame(){
 
	gltime = get_gametime()
	static id
	for (id = 1; id <= 32; id++)
	{
		jp_forward(id)
	}
}

public UpdateClientData_Post(id, sendweapons, cd_handle) 
{
	if (get_user_weapon(id) != CSW_KNIFE || !ma_klase[id])
		return FMRES_IGNORED
		
	set_cd(cd_handle, CD_ID, 0)
	return FMRES_HANDLED
}
 
public jp_forward(player) {
 
	if (!ma_klase[player])
		return FMRES_IGNORED
 
	check_rocket(player)
 
	new clip,ammo
	new wpnid = get_user_weapon(player,clip,ammo)
	if (wpnid == CSW_KNIFE){
		if ((pev(player, pev_button)&IN_ATTACK)){
			set_pev(player, pev_button, pev(player,pev_button) & ~IN_ATTACK)
			return FMRES_HANDLED 
		}
		if ((pev(player,pev_button)&IN_ATTACK2)){
				attack2(player)	
			}	
	}
 
	return FMRES_IGNORED
}
 
public attack2(player) {
 
	if (rocket[player])
	{
 
		new rocket = create_entity("info_target")
		if (rocket == 0) return PLUGIN_CONTINUE
 
		entity_set_string(rocket, EV_SZ_classname, "rakieta")
		entity_set_model(rocket, ROCKET_MDL)
 
		entity_set_size(rocket, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0})
		entity_set_int(rocket, EV_INT_movetype, MOVETYPE_FLY)
		entity_set_int(rocket, EV_INT_solid, SOLID_BBOX)
 
		new Float:vSrc[3]
		entity_get_vector(player, EV_VEC_origin, vSrc)
 
		new Float:Aim[3],Float:origin[3]
		VelocityByAim(player, 64, Aim)
		entity_get_vector(player,EV_VEC_origin,origin)
 
		vSrc[0] += Aim[0]
		vSrc[1] += Aim[1]
		entity_set_origin(rocket, vSrc)
 
		new Float:velocity[3], Float:angles[3]
		VelocityByAim(player, 1500, velocity)
 
		entity_set_vector(rocket, EV_VEC_velocity, velocity)
		vector_to_angle(velocity, angles)
		entity_set_vector(rocket, EV_VEC_angles, angles)
		entity_set_edict(rocket,EV_ENT_owner,player)
		entity_set_float(rocket, EV_FL_takedamage, 1.0)
 
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW)
		write_short(rocket)
		write_short(trail)
		write_byte(25)
		write_byte(5)
		write_byte(224)
		write_byte(224)
		write_byte(255)
		write_byte(255)
		message_end()
 
		emit_sound(rocket, CHAN_WEAPON, ROCKET_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)
 
		shot[player] = true
		new Float:czekanie = random_float(20.0, 40.0)
		last_Rocket[player] = gltime + czekanie
	}
	return PLUGIN_CONTINUE
}
 
public check_models(id) {
 
	if (ma_klase[id]) {
		new clip,ammo
		new wpnid = get_user_weapon(id,clip,ammo)
 
		if ( wpnid == CSW_KNIFE ) {
			switchmodel(id)
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
 
public switchmodel(id) {
	entity_set_string(id,EV_SZ_viewmodel,"models/v_rpg.mdl")
	entity_set_string(id,EV_SZ_weaponmodel,"models/p_rpg.mdl")
}
 
public emitsound(entity, channel, const sample[]) {
	if (is_user_alive(entity)) {
		new clip,ammo
		new weapon = get_user_weapon(entity,clip,ammo)
 
		if (ma_klase[entity] && weapon == CSW_KNIFE) {
			if (equal(sample,"weapons/knife_slash1.wav")) return FMRES_SUPERCEDE
			if (equal(sample,"weapons/knife_slash2.wav")) return FMRES_SUPERCEDE
 
			if (equal(sample,"weapons/knife_deploy1.wav")) return FMRES_SUPERCEDE
			if (equal(sample,"weapons/knife_hitwall1.wav")) return FMRES_SUPERCEDE
 
			if (equal(sample,"weapons/knife_hit1.wav")) return FMRES_SUPERCEDE
			if (equal(sample,"weapons/knife_hit2.wav")) return FMRES_SUPERCEDE
			if (equal(sample,"weapons/knife_hit3.wav")) return FMRES_SUPERCEDE
			if (equal(sample,"weapons/knife_hit4.wav")) return FMRES_SUPERCEDE
 
			if (equal(sample,"weapons/knife_stab.wav")) return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}
 
public check_rocket(player) {
 
	if (last_Rocket[player] > gltime)
	{	
		rk_forbidden(player)
		rksound[player] = true
	}
	else
	{	
 
		if (shot[player])
		{
			rksound[player] = false
			shot[player] = false
		}
		rk_sound(player)
		rk_allow(player)
	}
 
}
 
public rk_allow(player) {
 
	rocket[player] = true
}
 
public rk_forbidden(player) {
 
	rocket[player] = false
 
}
 
public rk_sound(player) {
 
	if (!rksound[player])
	{
		engfunc(EngFunc_EmitSound, player, CHAN_WEAPON, getrocket, 1.0, ATTN_NORM, 0, PITCH_NORM)
		client_print(player, print_center, "Bazooka naladowana !!!")
		rksound[player] = true
	}
	else if (rksound[player])
	{
 
	}
 
}
 
public pfn_touch(ptr, ptd) {
	if (is_valid_ent(ptr)) {
		new classname[32]
		entity_get_string(ptr,EV_SZ_classname,classname,31)
 
		if (equal(classname, "bazooka")) {
			if (is_valid_ent(ptd)) {
				new id = ptd
				if (id > 0 && id < 34) {
					if (!ma_bazooke[id] && is_user_alive(id)) {
 
						ma_bazooke[id] = true
						rocket[id] = true
						client_cmd(id,"spk items/gunpickup2.wav")
						engclient_cmd(id,"weapon_knife")
						switchmodel(id)
					}
				}
			}
		}else if (equal(classname, "rakieta")) {
			new Float:fOrigin[3]
			new iOrigin[3]
			entity_get_vector(ptr, EV_VEC_origin, fOrigin)
			FVecIVec(fOrigin,iOrigin)
			jp_radius_damage(ptr)
 
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY,iOrigin)
			write_byte(TE_EXPLOSION)
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2])
			write_short(explosion)
			write_byte(30)
			write_byte(15)
			write_byte(0)
			message_end()
 
			message_begin(MSG_ALL,SVC_TEMPENTITY,iOrigin)
			write_byte(TE_BEAMCYLINDER)
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2])
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2]+200)
			write_short(white)
			write_byte(0)
			write_byte(1)
			write_byte(6)
			write_byte(8)
			write_byte(1)
			write_byte(255)
			write_byte(255)
			write_byte(192)
			write_byte(128)
			write_byte(5)
			message_end()
 
			if (is_valid_ent(ptd)) {
				new classname2[32]
				entity_get_string(ptd,EV_SZ_classname,classname2,31)
 
				if (equal(classname2,"func_breakable"))
					force_use(ptr,ptd)
			}
		}
	}
	return PLUGIN_CONTINUE
}
 
stock jp_radius_damage(entity) {
	new id = entity_get_edict(entity,EV_ENT_owner) 
	for(new i = 1; i < 33; i++) {
		if (is_user_alive(i)) {
			new dist = floatround(entity_range(entity,i))
 
			if (dist <= 350) {
				new hp = get_user_health(i)
				new Float:damage = 100.0
 
				new Origin[3]
				get_user_origin(i,Origin)
 
				if (get_user_team(id) != get_user_team(i)) {
						if (hp > damage)
							ExecuteHam(Ham_TakeDamage, i, id, id, damage, DMG_BLAST);
						else
							log_kill(id,i,"Rakiety",0)
					}
			}
		}
	}
}
 
stock log_kill(killer, victim, weapon[], headshot)
{
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET)
	ExecuteHamB(Ham_Killed, victim, killer, 2) 
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT)
 
 
	message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"))
	write_byte(killer)
	write_byte(victim)
	write_byte(headshot)
	write_string(weapon)
	message_end()
//
 
	if (get_user_team(killer)!=get_user_team(victim))
		set_user_frags(killer,get_user_frags(killer) +1)
	if (get_user_team(killer)==get_user_team(victim))
		set_user_frags(killer,get_user_frags(killer) -1)
 
	new kname[32], vname[32], kauthid[32], vauthid[32], kteam[10], vteam[10]
 
	get_user_name(killer, kname, 31)
	get_user_team(killer, kteam, 9)
	get_user_authid(killer, kauthid, 31)
 
	get_user_name(victim, vname, 31)
	get_user_team(victim, vteam, 9)
	get_user_authid(victim, vauthid, 31)
 
	log_message("^"%s<%d><%s><%s>^" zabil ^"%s<%d><%s><%s>^" przy uzyciu ^"%s^"", 
	kname, get_user_userid(killer), kauthid, kteam, 
 	vname, get_user_userid(victim), vauthid, vteam, weapon)
 
 	return PLUGIN_CONTINUE;
}
