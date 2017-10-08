#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cod>

#define PLUGIN "CoD Class Czolgista"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Czolgista"
#define DESCRIPTION  "Ma podwojny skok, posiada Bazooke (R na nozu) i 10 pociskow do niej."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_GALIL)|(1<<CSW_GLOCK18)
#define HEALTH       20
#define INTELLIGENCE 0
#define STRENGTH     20
#define STAMINA      0
#define CONDITION    0

#define MISSILES     10

new const classModels[][] = { "models/CoDMod/bazooka.mdl", "models/CoDMod/bazooka2.mdl", "models/CoDMod/missile.mdl" };
new const classSprites[][] = { "sprites/steam1.spr", "sprites/smoke.spr", "sprites/explosion.spr" };

enum _:models { V_BAZOOKA, P_BAZOOKA, MISSILE };
enum _:sprites { SMOKE, TRAIL, EXPLOSION }

new bazookaMissiles[MAX_PLAYERS + 1], lastBazookaMissile[MAX_PLAYERS + 1], sprite[sprites], bazookaActive, classActive;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);

	register_touch("missile", "*" , "touch_missile");

	register_forward(FM_EmitSound, "sound_emit");
}

public plugin_precache()
{
	for (new i = 0; i < sizeof(classModels); i++) precache_model(classModels[i]);
	for (new i = 0; i < sizeof(classSprites); i++) sprite[i] = precache_model(classSprites[i]);
}

public client_disconnected(id)
	cod_remove_ents(id, "missile");

public cod_class_enabled(id, promotion)
{
	cod_set_user_multijumps(id, 1, CLASS);

	set_bit(id, classActive);

	bazookaMissiles[id] = MISSILES;
}

public cod_class_disabled(id)
{
	rem_bit(id, classActive);
	rem_bit(id, bazookaActive);

	bazookaMissiles[id] = 0;
}

public cod_class_spawned(id, respawn)
{
	rem_bit(id, bazookaActive);

	if (!respawn) bazookaMissiles[id] = MISSILES;
}

public cod_new_round()
	cod_remove_ents(0, "missile");

public cod_weapon_deploy(id, weapon, ent)
	rem_bit(id, bazookaActive);

public cod_cmd_start(id, button, oldButton, playerState)
{
	if (!get_bit(id, classActive)) return;

	if (get_user_weapon(id) == CSW_KNIFE && button & IN_RELOAD && !(oldButton & IN_RELOAD)) {
		set_bit(id, bazookaActive);

		entity_set_string(id, EV_SZ_viewmodel, classModels[V_BAZOOKA]);
		entity_set_string(id, EV_SZ_weaponmodel, classModels[P_BAZOOKA]);
	}

	if (button & IN_ATTACK && !(oldButton & IN_ATTACK)) {
		static modelName[32];

		entity_get_string(id, EV_SZ_viewmodel, modelName, charsmax(modelName));

		if (equal(modelName, classModels[V_BAZOOKA])) shoot_missile(id);
	}
}

public shoot_missile(id)
{
	if (!is_user_alive(id)) return;
	
	if (!bazookaMissiles[id]) {
		cod_show_hud(id, TYPE_DHUD, 218, 40, 67, -1.0, 0.42, 0, 0.0, 2.0, 0.0, 0.0, "Juz wykorzystales wszystkie pociski bazooki!");

		return;
	}
	
	if (lastBazookaMissile[id] + 5.0 > get_gametime()) {
		cod_show_hud(id, TYPE_DHUD, 218, 40, 67, -1.0, 0.42, 0, 0.0, 2.0, 0.0, 0.0, "Pocisk mozesz wystrzelic raz na 5 sekund!");

		return;
	}

	rem_bit(id, bazookaActive);
	
	lastBazookaMissile[id] = floatround(get_gametime());
	bazookaMissiles[id]--;

	new Float:origin[3], Float:angle[3], Float:velocity[3];

	pev(id, pev_origin, origin);
	pev(id, pev_v_angle, angle);
	
	new ent = create_entity("info_target");

	set_pev(ent, pev_classname, "rocket");
	engfunc(EngFunc_SetModel, ent, classModels[MISSILE]);
	
	set_pev(ent, pev_solid, SOLID_BBOX);
	set_pev(ent, pev_movetype, MOVETYPE_TOSS);
	set_pev(ent, pev_owner, id);
	set_pev(ent, pev_mins, Float:{-1.0, -1.0, -1.0});
	set_pev(ent, pev_maxs, Float:{1.0, 1.0, 1.0});
	set_pev(ent, pev_gravity, 0.3);

	velocity_by_aim(id, 1000, velocity);
	
	angle[0] *= -1.0;
	
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_velocity, velocity);
	set_pev(ent, pev_angles, angle);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(ent);
	write_short(sprite[TRAIL]);
	write_byte(6);
	write_byte(3);
	write_byte(224);	
	write_byte(224);
	write_byte(255);
	write_byte(100);
	message_end();

	//ExecuteHam(Ham_Item_Deploy, id);

	emit_sound(id, CHAN_ITEM, codSounds[SOUND_DEPLOY], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

public touch_missile(ent)
{
	if (!is_valid_ent(ent)) return;
	
	new origin[3];

	get_user_origin(ent, origin);

	origin[2] += 1.0;
	
	cod_make_explosion(ent, 0, 1, 250.0, 125.0, 0.5);

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
	write_byte(TE_EXPLOSION);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	write_short(sprite[EXPLOSION]); 
	write_byte(40); 
	write_byte(30); 
	write_byte(14); 
	message_end(); 
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(5);
	write_coord(origin[0]); 
	write_coord(origin[1]); 
	write_coord(origin[2]);
	write_short(sprite[SMOKE]);
	write_byte(35);
	write_byte(5);
	message_end();

	remove_entity(ent);
}

public sound_emit(ent, channel, const sample[])
{
	if (!is_user_alive(ent) || !get_bit(ent, classActive)) return FMRES_IGNORED;

	static modelName[32];

	entity_get_string(ent, EV_SZ_viewmodel, modelName, charsmax(modelName));

	if (equal(modelName, classModels[V_BAZOOKA])) {
		if (equal(sample,"weapons/knife_slash1.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_slash2.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_deploy1.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_hitwall1.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_hit1.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_hit2.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_hit3.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_hit4.wav")) return FMRES_SUPERCEDE;
		if (equal(sample,"weapons/knife_stab.wav")) return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}