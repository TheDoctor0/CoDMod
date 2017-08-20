#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <codmod>
#include <cstrike>
/*================================================================================
[Opcje]
=================================================================================*/
new cod_weapon;
// Model Granatu
new const model_grenade_vfire[] = "models/v_hegrenade.mdl"
new const model_grenade_pfire[] = "models/p_hegrenade.mdl"
new const model_grenade_wfire[] = "models/w_hegrenade.mdl"
new bool:ma_perk[33];
// Dzwiek Eksplozji
new const grenade_fire[][] = { "weapons/hegrenade-1.wav" }

// Dzwiek palocego sie gracza
new const grenade_fire_player[][] = { "scientist/sci_fear8.wav", "scientist/sci_pain1.wav", "scientist/scream02.wav" }

// Sprity Granade
new const sprite_grenade_fire[] = "sprites/flame.spr"
new const sprite_grenade_smoke[] = "sprites/black_smoke3.spr"
new const sprite_grenade_trail[] = "sprites/laserbeam.spr"
new const sprite_grenade_ring[] = "sprites/shockwave.spr"

// Glow and trail colors (red, green, blue) Niewiem?
const NAPALM_R = 200
const NAPALM_G = 0
const NAPALM_B = 0

/*===============================================================================*/

// Burning task
const TASK_BURN = 1000
#define ID_BURN (taskid - TASK_BURN)

// Flame task
#define FLAME_DURATION args[0]
#define FLAME_ATTACKER args[1]

// CS Offsets
#if cellbits == 32
const OFFSET_CSTEAMS = 114
const OFFSET_CSMONEY = 115
const OFFSET_MAPZONE = 235
#else
const OFFSET_CSTEAMS = 139
const OFFSET_CSMONEY = 140
const OFFSET_MAPZONE = 268
#endif
const OFFSET_LINUX = 5 // offsets +5 in Linux builds

const PLAYER_IN_BUYZONE = (1<<0)

// HE grenade weapon entity
#define HE_WPN_ENTITY(%1) fm_find_ent_by_owner(-1, "weapon_hegrenade", %1)

// pev_ field used to store custom nade types and their values
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_NAPALM = 681856

// Whether ham forwards are registered for CZ bots
new g_hamczbots

// Precached sprites indices
new g_flameSpr, g_smokeSpr, g_trailSpr, g_exploSpr

// Messages
new g_msgDamage, g_msgMoney, g_msgBlinkAcct

// CVAR pointers
new cvar_radius, cvar_price, cvar_hitself, cvar_duration, cvar_slowdown, cvar_override,
cvar_damage, cvar_on, cvar_buyzone, cvar_ff, cvar_cankill, cvar_spread, cvar_botquota

// Precache all custom stuff
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, model_grenade_vfire)
	engfunc(EngFunc_PrecacheModel, model_grenade_pfire)
	engfunc(EngFunc_PrecacheModel, model_grenade_wfire)
	
	new i
	for (i = 0; i < sizeof grenade_fire; i++)
		engfunc(EngFunc_PrecacheSound, grenade_fire[i])
	for (i = 0; i < sizeof grenade_fire_player; i++)
		engfunc(EngFunc_PrecacheSound, grenade_fire_player[i])
	
	g_flameSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_fire)
	g_smokeSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_smoke)
	g_trailSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_trail)
	g_exploSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_ring)
}
new const perk_name[] = "Napalm";
new const perk_desc[] = "Dostajesz 5 granatow podpalajacych";

public plugin_init()
{
	cod_register_perk(perk_name, perk_desc);
	// Register plugin call
	register_plugin("Napalm Nades", "1.1", "MeRcyLeZZ & fbang")
	
	// Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	
	// Forwards
	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	RegisterHam(Ham_Touch, "player", "fw_TouchPlayer")
	
	// Client commands
	register_clcmd("say napalm", "buy_napalm")
	register_clcmd("say /napalm", "buy_napalm")
	
	// CVARS
	cvar_on = register_cvar("napalm_on", "1")
	cvar_override = register_cvar("napalm_override", "1")
	cvar_price = register_cvar("napalm_price", "1000")
	cvar_buyzone = register_cvar("napalm_buyzone", "1")
	
	cvar_radius = register_cvar("napalm_radius", "240.0")
	cvar_hitself = register_cvar("napalm_hitself", "0")
	cvar_ff = register_cvar("napalm_ff", "0")
	cvar_spread = register_cvar("napalm_spread", "0")
	
	cvar_duration = register_cvar("napalm_duration", "5")
	cvar_damage = register_cvar("napalm_damage", "7")
	cvar_cankill = register_cvar("napalm_cankill", "1")
	cvar_slowdown = register_cvar("napalm_slowdown", "0.5")
	
	cvar_botquota = get_cvar_pointer("bot_quota")
	register_event("ResetHUD", "ResetHUD", "abe");
	
	// Message ids
	g_msgDamage = get_user_msgid("Damage")
	g_msgMoney = get_user_msgid("Money")
	g_msgBlinkAcct = get_user_msgid("BlinkAcct")
}
public cod_perk_enabled(id)
{
	cod_weapon = CSW_HEGRENADE
	cod_give_weapon(id, cod_weapon);
	ma_perk[id] = true;
	ResetHUD(id);
	
}
public cod_perk_disabled(id)
{
	cod_take_weapon(id, cod_weapon);
	ma_perk[id] = false;
}
// Round Start Event
public event_round_start()
{
	// Stop any burning tasks on players
	static id
	for (id = 1; id <= 32; id++) remove_task(id+TASK_BURN);
}

// Current Weapon Event
public event_curweapon(id)
{
	// Napalm grenades disabled
	if (!get_pcvar_num(cvar_on))
		return;
	
	// Not a HE grenade
	if (read_data(2) != CSW_HEGRENADE)
		return;
	
	// Not a napalm grenade (because the weapon_hegrenade entity of its owner doesn't have the flag set)
	if (!get_pcvar_num(cvar_override) && pev(HE_WPN_ENTITY(id), PEV_NADE_TYPE) != NADE_TYPE_NAPALM)
		return;
	
	// Replace models
	set_pev(id, pev_viewmodel2, model_grenade_vfire)
	set_pev(id, pev_weaponmodel2, model_grenade_pfire)
}

// Client joins the game
public client_putinserver(id)
{
	// CZ bots seem to use a different "classtype" for player entities
	// (or something like that) which needs to be hooked separately
	if (cvar_botquota && !g_hamczbots) set_task(0.1, "register_ham_czbots", id)
}

// Set Model Forward
public fw_SetModel(entity, const model[])
{
	// Napalm grenades disabled
	if (!get_pcvar_num(cvar_on))
		return FMRES_IGNORED;
	
	// Not a HE grenade
	if (!equal(model[7], "w_hegrenade.mdl"))
		return FMRES_IGNORED;
	
	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	// Grenade not yet thrown
	if (dmgtime == 0.0)
		return FMRES_IGNORED;
	
	// Not a napalm grenade (because the weapon_hegrenade entity of its owner doesn't have the flag set)
	if (!get_pcvar_num(cvar_override) && pev(HE_WPN_ENTITY(pev(entity, pev_owner)), PEV_NADE_TYPE) != NADE_TYPE_NAPALM)
		return FMRES_IGNORED;
	
	// Give it a glow
	fm_set_rendering(entity, kRenderFxGlowShell, NAPALM_R, NAPALM_G, NAPALM_B, kRenderNormal, 16)
	
	// And a colored trail
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // TE id
	write_short(entity) // entity
	write_short(g_trailSpr) // sprite
	write_byte(10) // life
	write_byte(10) // width
	write_byte(NAPALM_R) // r
	write_byte(NAPALM_G) // g
	write_byte(NAPALM_B) // b
	write_byte(200) // brightness
	message_end()
	
	// Set grenade type on the thrown grenade entity
	set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_NAPALM)
	
	// Set owner's team on the thrown grenade entity
	set_pev(entity, pev_team, fm_get_user_team(pev(entity, pev_owner)))
	
	// Set custom model and supercede the original forward
	engfunc(EngFunc_SetModel, entity, model_grenade_wfire)
	return FMRES_SUPERCEDE;
}

// Grenade Think Forward
public fw_ThinkGrenade(entity)
{
	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	// Check if it's time to go off
	if (dmgtime > get_gametime())
		return HAM_IGNORED;
	
	// Not a napalm grenade
	if (pev(entity, PEV_NADE_TYPE) != NADE_TYPE_NAPALM)
		return HAM_IGNORED;
	
	// Explode event
	napalm_explode(entity)
	
	return HAM_SUPERCEDE;
}

// Player Touch Forward
public fw_TouchPlayer(self, other)
{
	// Spread cvar disabled or not on fire
	if (!get_pcvar_num(cvar_spread) || !task_exists(self+TASK_BURN))
		return;
	
	// Not touching a player or player already on fire
	if (!is_user_alive(other) || task_exists(other+TASK_BURN))
		return;
	
	// Check if friendly fire is allowed
	if (!get_pcvar_num(cvar_ff) && fm_get_user_team(self) == fm_get_user_team(other))
		return;
	
	// Heat icon
	message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, other)
	write_byte(0) // damage save
	write_byte(0) // damage take
	write_long(DMG_BURN) // damage type
	write_coord(0) // x
	write_coord(0) // y
	write_coord(0) // z
	message_end()
	
	// Our task params
	static params[2]
	params[0] = get_pcvar_num(cvar_duration)*2; // duration (reduced a bit)
	params[1] = self; // attacker
	
	// Set burning task on victim
	set_task(0.1, "burning_flame", other+TASK_BURN, params, sizeof params)
}

// Say hook
public buy_napalm(id)
{
	// Napalm grenades disabled
	if (!get_pcvar_num(cvar_on))
		return PLUGIN_CONTINUE;
	
	// Check if override setting is enabled instead
	if (get_pcvar_num(cvar_override))
	{
		client_print(id, print_center, "Just buy a HE grenade and get a napalm automatically!")
		return PLUGIN_HANDLED;
	}
	
	// Check that we are alive
	if (!is_user_alive(id))
	{
		client_print(id, print_center, "You can't buy when you're dead!")
		return PLUGIN_HANDLED;
	}
	
	// Check that we are in a buyzone
	if (get_pcvar_num(cvar_buyzone) && !fm_get_user_buyzone(id))
	{
		client_print(id, print_center, "You need to be in a buyzone!")
		return PLUGIN_HANDLED;
	}
	
	// Check that we have the money
	if (fm_get_user_money(id) < get_pcvar_num(cvar_price))
	{
		client_print(id, print_center, "#Cstrike_TitlesTXT_Not_Enough_Money")
		
		// blink money
		message_begin(MSG_ONE_UNRELIABLE, g_msgBlinkAcct, _, id)
		write_byte(2) // times
		message_end()
		
		return PLUGIN_HANDLED;
	}
	
	// Check that we don't have a hegrenade already
	if (user_has_weapon(id, CSW_HEGRENADE))
	{
		client_print(id, print_center, "#Cstrike_Already_Own_Weapon")
		return PLUGIN_HANDLED;
	}
	
	// Give napalm
	fm_give_item(id, "weapon_hegrenade")
	
	// Set grenade type
	set_pev(HE_WPN_ENTITY(id), PEV_NADE_TYPE, NADE_TYPE_NAPALM)
	
	// Remove the money
	fm_set_user_money(id, fm_get_user_money(id)-get_pcvar_num(cvar_price))
	
	// Update money on HUD
	message_begin(MSG_ONE, g_msgMoney, _, id)
	write_long(fm_get_user_money(id)) // amount
	write_byte(1) // flash
	message_end()
	
	return PLUGIN_HANDLED;
}

// Napalm Grenade Explosion
napalm_explode(ent)
{
// Get attacker and its team
static attacker, attacker_team
attacker = pev(ent, pev_owner)
attacker_team = pev(ent, pev_team)

// Get origin
static Float:originF[3]
pev(ent, pev_origin, originF)

// Explosion
create_blast2(originF)

// Napalm explosion sound
engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, grenade_fire[random_num(0, sizeof grenade_fire - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

// Collisions
static victim
victim = -1;

while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, get_pcvar_float(cvar_radius))) != 0)
{
	// Only effect alive players
	if (!is_user_alive(victim))
		continue;
		
		// Check if myself is allowed
		if (victim == attacker && !get_pcvar_num(cvar_hitself))
			continue;
		
		// Check if friendly fire is allowed
		if (victim != attacker && !get_pcvar_num(cvar_ff) && attacker_team == fm_get_user_team(victim))
			continue;
		
		// Heat icon
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, victim)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_BURN) // damage type
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
		
		// Our task params
		static params[2]
		params[0] = get_pcvar_num(cvar_duration)*5; // duration
		params[1] = attacker; // attacker
		
		// Set burning task on victim
		set_task(0.1, "burning_flame", victim+TASK_BURN, params, sizeof params)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}

// Burning Task
public burning_flame(args[2], taskid)
{
	// Player died/disconnected
	if (!is_user_alive(ID_BURN))
		return;
	
	// Get player origin
	static Float:originF[3]
	pev(ID_BURN, pev_origin, originF)
	
	// In water or burning stopped
	if ((pev(ID_BURN, pev_flags) & FL_INWATER) || FLAME_DURATION < 1)
	{
		// Smoke sprite
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		return;
	}
	
	// Randomly play burning sounds
	if (!random_num(0, 20))
		engfunc(EngFunc_EmitSound, ID_BURN, CHAN_VOICE, grenade_fire_player[random_num(0, sizeof grenade_fire_player - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Fire slow down
	if (get_pcvar_float(cvar_slowdown) > 0.0 && (pev(ID_BURN, pev_flags) & FL_ONGROUND))
	{
		static Float:velocity[3]
		pev(ID_BURN, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, get_pcvar_float(cvar_slowdown), velocity)
		set_pev(ID_BURN, pev_velocity, velocity)
	}
	
	// Take damage from the fire
	if (pev(ID_BURN, pev_health) > get_pcvar_num(cvar_damage))
		fm_set_user_health(ID_BURN, pev(ID_BURN, pev_health) - get_pcvar_num(cvar_damage))
	else if (get_pcvar_num(cvar_cankill))
	{
		// Kill the victim
		ExecuteHamB(Ham_Killed, ID_BURN, FLAME_ATTACKER, 0)
		
		// Smoke sprite
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		return;
	}
	
	// Flame sprite
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPRITE) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]+random_float(-5.0, 5.0)) // x
	engfunc(EngFunc_WriteCoord, originF[1]+random_float(-5.0, 5.0)) // y
	engfunc(EngFunc_WriteCoord, originF[2]+random_float(-10.0, 10.0)) // z
	write_short(g_flameSpr) // sprite
	write_byte(random_num(5, 10)) // scale
	write_byte(200) // brightness
	message_end()
	
	// Decrease task cycle count
	FLAME_DURATION -= 1;
	
	// Keep sending flame messages
	set_task(0.2, "burning_flame", taskid, args, sizeof args)
}

// Napalm Grenade: Fire Blast (originally made by Avalanche in Frostnades)
create_blast2(const Float:originF[3])
{
// Smallest ring
engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
write_byte(TE_BEAMCYLINDER) // TE id
engfunc(EngFunc_WriteCoord, originF[0]) // x
engfunc(EngFunc_WriteCoord, originF[1]) // y
engfunc(EngFunc_WriteCoord, originF[2]) // z
engfunc(EngFunc_WriteCoord, originF[0]) // x axis
engfunc(EngFunc_WriteCoord, originF[1]) // y axis
engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
write_short(g_exploSpr) // sprite
write_byte(0) // startframe
write_byte(0) // framerate
write_byte(4) // life
write_byte(60) // width
write_byte(0) // noise
write_byte(200) // red
write_byte(100) // green
write_byte(0) // blue
write_byte(200) // brightness
write_byte(0) // speed
message_end()

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
write_byte(200) // red
write_byte(50) // green
write_byte(0) // blue
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
write_byte(200) // red
write_byte(0) // green
write_byte(0) // blue
write_byte(200) // brightness
write_byte(0) // speed
message_end()
}

// Register Ham Forwards for CZ bots
public register_ham_czbots(id)
{
// Make sure it's a CZ bot and it's still connected
if (g_hamczbots || !get_pcvar_num(cvar_botquota) || !is_user_connected(id) || !is_user_bot(id))
	return;
	
	RegisterHamFromEntity(Ham_Touch, id, "fw_TouchPlayer")
	
	// Ham forwards for CZ bots succesfully registered
	g_hamczbots = true;
}

// Set entity's rendering type (from fakemeta_util)
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r);
	color[1] = float(g);
	color[2] = float(b);
	
	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, color);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));
}

// Set player's health (from fakemeta_util)
stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

// Give an item to a player (from fakemeta_util)
stock fm_give_item(id, const item[])
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	if (!pev_valid(ent)) return;
	
	static Float:originF[3]
	pev(id, pev_origin, originF);
	set_pev(ent, pev_origin, originF);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);
	
	static save
	save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, id);
	if (pev(ent, pev_solid) != save)
		return;
	
	engfunc(EngFunc_RemoveEntity, ent);
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) {}
	
	return entity;
}

// Get User Money
stock fm_get_user_money(id)
{
	return get_pdata_int(id, OFFSET_CSMONEY, OFFSET_LINUX);
}

// Set User Money
stock fm_set_user_money(id, amount)
{
	set_pdata_int(id, OFFSET_CSMONEY, amount, OFFSET_LINUX);
}

// Get User Team
stock fm_get_user_team(id)
{
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX);
}

// Returns whether user is in a buyzone
stock fm_get_user_buyzone(id)
{
	if (get_pdata_int(id, OFFSET_MAPZONE) & PLAYER_IN_BUYZONE)
		return 1;
	
	return 0;
}
public ResetHUD(id)
	set_task(0.1, "ResetHUDx", id);

public ResetHUDx(id)
{
	if(!is_user_connected(id)) return;
	
	if(!ma_perk[id]) return;
	
	cs_set_user_bpammo(id, CSW_HEGRENADE, 5);
}
