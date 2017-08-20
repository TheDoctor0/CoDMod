#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <codmod>
#include <cstrike>

#define SMOKE_SCALE 30
#define SMOKE_FRAMERATE 12
#define SMOKE_GROUND_OFFSET 6

// nie edytowac
new const g_sound_explosion[] = "weapons/sg_explode.wav"

new const g_classname_grenade[] = "grenade"

new const Float:g_sign[4][2] = {{1.0, 1.0}, {1.0, -1.0}, {-1.0, -1.0}, {-1.0, 1.0}}

new g_spriteid_steam1
new g_eventid_createsmoke


new const perk_name[] = "Teleport";
new const perk_desc[] = "Dostajesz 10 SMOKE'ow. Rzucasz tam gdzie chcesz sie przeteleportowac";

new bool:ma_perk[33];
new has_teleport[33]


public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Roadrage+VEN edit by Klakier");
	cod_register_perk(perk_name, perk_desc);
	
	register_forward(FM_EmitSound, "forward_emitsound")
	register_forward(FM_PlaybackEvent, "forward_playbackevent")
	
	register_forward(FM_SetModel, "fw_SetModel")	
	register_message(get_user_msgid("CurWeapon"), "message_cur_weapon")
	
	g_spriteid_steam1 = engfunc(EngFunc_PrecacheModel, "sprites/steam1.spr")
	g_eventid_createsmoke = engfunc(EngFunc_PrecacheEvent, 1, "events/createsmoke.sc")
}

public client_disconnect(id)
{
	has_teleport[id] = 0
}
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	has_teleport[victim] = 0	
}
public cod_perk_enabled(player)
{
	ma_perk[player] = true
	has_teleport[player] = 1	
	fm_strip_user_gun(player,9)
	cod_give_weapon(player, CSW_SMOKEGRENADE)
	cs_set_user_bpammo(player, CSW_SMOKEGRENADE, 10)
	client_print(player, print_center, "Rzuc SMOKE'a tam gdzie chcesz sie przeteleportowac")
	
}
public cod_perk_disabled(id)
{
	ma_perk[id] = false
	has_teleport[id] = 0
}

public forward_emitsound(ent, channel, const sound[]) 
{
	if (!equal(sound, g_sound_explosion) || !is_grenade(ent))
		return FMRES_IGNORED
	static id, Float:origin[3]
	id = pev(ent, pev_owner)
	if(!ma_perk[id])
		return FMRES_IGNORED
	
	pev(ent, pev_origin, origin)
	engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, g_sound_explosion, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	engfunc(EngFunc_RemoveEntity, ent)
	origin[2] += SMOKE_GROUND_OFFSET
	create_smoke(origin)
	
	if (is_user_alive(id)) {
		static Float:mins[3], hull
		pev(id, pev_mins, mins)
		origin[2] -= mins[2] + SMOKE_GROUND_OFFSET
		hull = pev(id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
		if (is_hull_vacant(origin, hull))
			engfunc(EngFunc_SetOrigin, id, origin)
		else { 
			static Float:vec[3]
			vec[2] = origin[2]
			for (new i; i < sizeof g_sign; ++i) {
				vec[0] = origin[0] - mins[0] * g_sign[i][0]
				vec[1] = origin[1] - mins[1] * g_sign[i][1]
				if (is_hull_vacant(vec, hull)) {
					engfunc(EngFunc_SetOrigin, id, vec)
					break
				}
			}
		}
	}
	
	return FMRES_SUPERCEDE
}

public forward_playbackevent(flags, invoker, eventindex) {
	
	if (eventindex == g_eventid_createsmoke)
		return FMRES_SUPERCEDE
	
	return FMRES_IGNORED
}

bool:is_grenade(ent) {
	if (!pev_valid(ent))
		return false
	
	static classname[sizeof g_classname_grenade + 1]
	pev(ent, pev_classname, classname, sizeof g_classname_grenade)
	if (equal(classname, g_classname_grenade))
		return true
	
	return false
}


create_smoke(const Float:origin[3]) {
	// engfunc because origin are float
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SMOKE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(g_spriteid_steam1)
	write_byte(SMOKE_SCALE)
	write_byte(SMOKE_FRAMERATE)
	message_end()
}


stock bool:is_hull_vacant(const Float:origin[3], hull) {
	new tr = 0
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, tr)
	if (!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid) && get_tr2(tr, TR_InOpen))
		return true
	
	return false
}
