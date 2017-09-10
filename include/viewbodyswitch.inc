#define PLUGIN	"SetViewEntityBody"
#define VERSION	"1.7"
#define AUTHOR	"Hanna"

//Natives
native SetViewEntityBody(pPlayer, iValue);
native SetUserSex(pPlayer, iValue);
native GetUserSex(pPlayer);

#define DEBUG

//Player base
#define MAXPLAYERS 32
#define MALE 0
#define FEMALE 1
#define TRUE 1
#define FALSE 0

//Weapon State
#define WPNSTATE_GLOCK18_BURST_MODE (1<<1)
#define WPNSTATE_FAMAS_BURST_MODE (1<<4)
#define WPNSTATE_M4A1_SILENCED (1<<2)
#define WPNSTATE_USP_SILENCED (1<<0)
#define WPNSTATE_ELITE_LEFT (1<<3)

//Weapon type
#define WEAPONTYPE_ELITE 1
#define WEAPONTYPE_GLOCK18 2
#define WEAPONTYPE_FAMAS 3
#define WEAPONTYPE_OTHER 4
#define WEAPONTYPE_M4A1 5
#define WEAPONTYPE_USP 6

//Weapon anims
#define IDLE_ANIM 0
#define KNIFE_STABMISS 5
#define KNIFE_MIDATTACK1HIT 6
#define KNIFE_MIDATTACK2HIT 7
#define GLOCK18_SHOOT2 4
#define GLOCK18_SHOOT3 5
#define AK47_SHOOT1 3
#define AUG_SHOOT1 3
#define AWP_SHOOT2 2
#define DEAGLE_SHOOT1 2
#define ELITE_SHOOTLEFT5 6	//TODO
#define ELITE_SHOOTRIGHT5 12
#define CLARION_SHOOT2 4
#define CLARION_SHOOT3 3
#define FIVESEVEN_SHOOT1 1
#define G3SG1_SHOOT 1
#define GALIL_SHOOT3 5
#define M3_FIRE2 2
#define XM1014_FIRE2 2
#define M4A1_SHOOT3 3
#define M4A1_UNSIL_SHOOT3 10
#define M249_SHOOT2 2
#define MAC10_SHOOT1 3
#define MP5N_SHOOT1 3
#define P90_SHOOT1 3
#define P228_SHOOT2 2
#define SCOUT_SHOOT 1
#define SG550_SHOOT 1
#define SG552_SHOOT2 4
#define TMP_SHOOT3 5
#define UMP45_SHOOT2 4
#define USP_UNSIL_SHOOT3 11
#define USP_SHOOT3 3

//Weapon Sounds
#define DRYFIRE_PISTOL "weapons/dryfire_pistol.wav"
#define DRYFIRE_RIFLE "weapons/dryfire_rifle.wav"
#define GLOCK18_BURST_SOUND "weapons/glock18-1.wav"
#define GLOCK18_SHOOT_SOUND "weapons/glock18-2.wav"
#define AK47_SHOOT_SOUND "weapons/ak47-1.wav"
#define AUG_SHOOT_SOUND "weapons/aug-1.wav"
#define AWP_SHOOT_SOUND "weapons/awp1.wav"
#define DEAGLE_SHOOT_SOUND "weapons/deagle-2.wav"
#define ELITE_SHOOT_SOUND "weapons/elite_fire.wav"
#define CLARION_BURST_SOUND "weapons/famas-burst.wav"
#define CLARION_SHOOT_SOUND "weapons/famas-1.wav"
#define FIVESEVEN_SHOOT_SOUND "weapons/fiveseven-1.wav"
#define G3SG1_SHOOT_SOUND "weapons/g3sg1-1.wav"
#define GALIL_SHOOT_SOUND "weapons/galil-1.wav"
#define M3_SHOOT_SOUND "weapons/m3-1.wav"
#define XM1014_SHOOT_SOUND "weapons/xm1014-1.wav"
#define M4A1_SILENT_SOUND "weapons/m4a1-1.wav"
#define M4A1_SHOOT_SOUND "weapons/m4a1_unsil-1.wav"
#define M249_SHOOT_SOUND "weapons/m249-1.wav"
#define MAC10_SHOOT_SOUND "weapons/mac10-1.wav"
#define MP5_SHOOT_SOUND "weapons/mp5-1.wav"
#define P90_SHOOT_SOUND "weapons/p90-1.wav"
#define P228_SHOOT_SOUND "weapons/p228-1.wav"
#define SCOUT_SHOOT_SOUND "weapons/scout_fire-1.wav"
#define SG550_SHOOT_SOUND "weapons/sg550-1.wav"
#define SG552_SHOOT_SOUND "weapons/sg552-1.wav"
#define TMP_SHOOT_SOUND "weapons/tmp-1.wav"
#define UMP45_SHOOT_SOUND "weapons/ump45-1.wav"
#define USP_SHOOT_SOUND "weapons/usp_unsil-1.wav"
#define USP_SILENT_SOUND "weapons/usp1.wav"

//Knife models
#define MALE_KNIFE "models/weapons/v_knife.mdl"
#define FEMALE_KNIFE "models/weapons/v_knife_w.mdl"

//Shell Models
#define SHELL_MODEL	"models/pshell.mdl"
#define SHOTGUN_SHELL_MODEL "models/shotgunshell.mdl"

//Macros
#define WEAPON_STRING(%0,%1) (pev(%0, pev_classname, %1, charsmax(%1)))
#define WEAPON_ENT(%0) (get_pdata_int(%0, m_iId))
#define CLIENT_DATA(%0,%1,%2) (get_user_info(%0, %1, %2, charsmax(%2)))
#define HOOK_DATA(%0,%1,%2) (set_user_info(%0, %1, %2))

// CBasePlayerItem
stock m_pPlayer = 41 // CBasePlayer *
stock m_iId = 43 // int

// CBasePlayerWeapon
stock m_flNextPrimaryAttack = 46 // float
stock m_flTimeWeaponIdle = 48 // float
stock m_iClip = 51 // int
stock m_iShellId = 57 // int
stock m_iShotsFired = 64 // int
stock m_iWeaponState = 74 // int

// CBaseMonster
stock m_flNextAttack = 83 // float

// CBasePlayer
stock m_flEjectBrass = 111 // float
stock m_pActiveItem = 373 // CBasePlayerItem *

//Weapon ents
new WeaponNames[][] = 
{ 
	"weapon_knife", 
	"weapon_glock18", 
	"weapon_ak47", 
	"weapon_aug", 
	"weapon_awp", 
	"weapon_c4", 
	"weapon_deagle", 
	"weapon_elite", 
	"weapon_famas", 
	"weapon_fiveseven", 
	"weapon_flashbang", 
	"weapon_g3sg1", 
	"weapon_galil", 
	"weapon_hegrenade", 
	"weapon_m3", 
	"weapon_xm1014", 
	"weapon_m4a1", 
	"weapon_m249", 
	"weapon_mac10", 
	"weapon_mp5navy", 
	"weapon_p90", 
	"weapon_p228", 
	"weapon_scout", 
	"weapon_sg550", 
	"weapon_sg552", 
	"weapon_smokegrenade", 
	"weapon_tmp", 
	"weapon_ump45", 
	"weapon_usp" 
}

//World decals
new TraceBullets[][] = 
{ 
	"func_breakable", 
	"func_wall", 
	"func_door", 
	"func_plat", 
	"func_rotating", 
	"worldspawn", 
	"func_door_rotating" 
}

//Old models to unprecache
new g_OldModels[][] = 
{ 
	"v_knife.mdl", 
	"v_glock18.mdl", 
	"v_ak47.mdl", 
	"v_aug.mdl", 
	"v_awp.mdl", 
	"v_c4.mdl" , 
	"v_deagle.mdl", 
	"v_elite.mdl", 
	"v_famas.mdl", 
	"v_fiveseven.mdl", 
	"v_flashbang.mdl", 
	"v_g3sg1.mdl", 
	"v_galil.mdl", 
	"v_hegrenade.mdl", 
	"v_m3.mdl", 
	"v_xm1014.mdl", 
	"v_m4a1.mdl", 
	"v_m249.mdl", 
	"v_mac10.mdl", 
	"v_mp5.mdl", 
	"v_p90.mdl", 
	"v_p228.mdl", 
	"v_scout.mdl", 
	"v_sg550.mdl", 
	"v_sg552.mdl", 
	"v_smokegrenade.mdl", 
	"v_tmp.mdl", 
	"v_ump45.mdl", 
	"v_usp.mdl" 
}

//New models to precache
new g_NewModels[][] = 
{ 
	"models/weapons/v_knife.mdl", 
	"models/weapons/v_glock18.mdl", 
	"models/weapons/v_ak47.mdl", 
	"models/weapons/v_aug.mdl", 
	"models/weapons/v_awp.mdl", 
	"models/weapons/v_c4.mdl" , 
	"models/weapons/v_deagle.mdl", 
	"models/weapons/v_elite.mdl", 
	"models/weapons/v_famas.mdl", 
	"models/weapons/v_fiveseven.mdl", 
	"models/weapons/v_flashbang.mdl", 
	"models/weapons/v_g3sg1.mdl", 
	"models/weapons/v_galil.mdl", 
	"models/weapons/v_hegrenade.mdl", 
	"models/weapons/v_m3.mdl", 
	"models/weapons/v_xm1014.mdl", 
	"models/weapons/v_m4a1.mdl", 
	"models/weapons/v_m249.mdl", 
	"models/weapons/v_mac10.mdl", 
	"models/weapons/v_mp5.mdl", 
	"models/weapons/v_p90.mdl", 
	"models/weapons/v_p228.mdl", 
	"models/weapons/v_scout.mdl", 
	"models/weapons/v_sg550.mdl", 
	"models/weapons/v_sg552.mdl", 
	"models/weapons/v_smokegrenade.mdl", 
	"models/weapons/v_tmp.mdl", 
	"models/weapons/v_ump45.mdl", 
	"models/weapons/v_usp.mdl" 
}

new iBodyIndex[MAXPLAYERS + 1]
new iSex[MAXPLAYERS + 1]
new iSpectatorTarget[MAXPLAYERS + 1]

//Hamsandwich Primary Attack Hooks
stock FireWeaponEffect(iEnt)
{
	switch(WEAPON_ENT(iEnt))
	{
		case CSW_KNIFE: KnifeHit(iEnt);
		
		//Func description: FireBulletsLite(iWeapon, iAnim, const szSoundEmpty[], const szSoundFire[], iAutoShoot, iWeaponType)
		
		case CSW_GLOCK18: FireBulletsLite(iEnt, GLOCK18_SHOOT3, DRYFIRE_PISTOL, GLOCK18_SHOOT_SOUND, FALSE, WEAPONTYPE_GLOCK18);
		case CSW_AK47: FireBulletsLite(iEnt, AK47_SHOOT1, DRYFIRE_RIFLE, AK47_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_AUG: FireBulletsLite(iEnt, AUG_SHOOT1, DRYFIRE_RIFLE, AUG_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_AWP: FireBulletsLite(iEnt, AWP_SHOOT2, DRYFIRE_RIFLE, AWP_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_DEAGLE: FireBulletsLite(iEnt, DEAGLE_SHOOT1, DRYFIRE_PISTOL, DEAGLE_SHOOT_SOUND, FALSE, WEAPONTYPE_OTHER);
		case CSW_ELITE: FireBulletsLite(iEnt, ELITE_SHOOTRIGHT5, DRYFIRE_PISTOL, ELITE_SHOOT_SOUND, FALSE, WEAPONTYPE_ELITE);
		case CSW_FAMAS: FireBulletsLite(iEnt, CLARION_SHOOT3, DRYFIRE_RIFLE, CLARION_SHOOT_SOUND, TRUE, WEAPONTYPE_FAMAS);
		case CSW_FIVESEVEN: FireBulletsLite(iEnt, FIVESEVEN_SHOOT1, DRYFIRE_PISTOL, FIVESEVEN_SHOOT_SOUND, FALSE, WEAPONTYPE_OTHER);
		case CSW_G3SG1: FireBulletsLite(iEnt, G3SG1_SHOOT, DRYFIRE_RIFLE, G3SG1_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_GALIL: FireBulletsLite(iEnt, GALIL_SHOOT3, DRYFIRE_RIFLE, GALIL_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_M3: FireBulletsLite(iEnt, M3_FIRE2, DRYFIRE_RIFLE, M3_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_XM1014: FireBulletsLite(iEnt, XM1014_FIRE2, DRYFIRE_RIFLE, XM1014_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_M4A1: FireBulletsLite(iEnt, M4A1_UNSIL_SHOOT3, DRYFIRE_RIFLE, M4A1_SHOOT_SOUND, TRUE, WEAPONTYPE_M4A1);
		case CSW_M249: FireBulletsLite(iEnt, M249_SHOOT2, DRYFIRE_RIFLE, M249_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_MAC10: FireBulletsLite(iEnt, MAC10_SHOOT1, DRYFIRE_RIFLE, MAC10_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_MP5NAVY: FireBulletsLite(iEnt, MP5N_SHOOT1, DRYFIRE_RIFLE, MP5_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_P90: FireBulletsLite(iEnt, P90_SHOOT1, DRYFIRE_RIFLE, P90_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_P228: FireBulletsLite(iEnt, P228_SHOOT2, DRYFIRE_PISTOL, P228_SHOOT_SOUND, FALSE, WEAPONTYPE_OTHER);
		case CSW_SCOUT: FireBulletsLite(iEnt, SCOUT_SHOOT, DRYFIRE_RIFLE, SCOUT_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_SG550: FireBulletsLite(iEnt, SG550_SHOOT, DRYFIRE_RIFLE, SG550_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_SG552: FireBulletsLite(iEnt, SG552_SHOOT2, DRYFIRE_RIFLE, SG552_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_TMP: FireBulletsLite(iEnt, TMP_SHOOT3, DRYFIRE_RIFLE, TMP_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_UMP45: FireBulletsLite(iEnt, UMP45_SHOOT2, DRYFIRE_RIFLE, UMP45_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_USP: FireBulletsLite(iEnt, USP_UNSIL_SHOOT3, DRYFIRE_PISTOL, USP_SHOOT_SOUND, FALSE, WEAPONTYPE_USP);	
	}
	
	return HAM_SUPERCEDE;
}

//Knife
stock KnifeHit(iEnt) 
{
	static id;
	
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	ExecuteHam(Ham_Weapon_PrimaryAttack, iEnt);
	
	set_pdata_float(id, m_flNextAttack, 0.4, 5);
	
	if(pev(id, pev_weaponanim) == KNIFE_MIDATTACK2HIT)	//Simulate randomize
	{
		UTIL_SendWeaponAnim(id, KNIFE_MIDATTACK1HIT);
	}	
	else
	{
		UTIL_SendWeaponAnim(id, KNIFE_MIDATTACK2HIT);
	}

	return HAM_SUPERCEDE;	
}

//Attack
stock FireBulletsLite(iEnt, iAnim, const szSoundEmpty[], const szSoundFire[], iAutoShoot, iWeaponType)
{
	static id, iClip; 
	
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);	 
	iClip = get_pdata_int(iEnt, m_iClip, 4);	
	
	if(!iClip) 
	{	
		emit_sound(id, CHAN_AUTO, szSoundEmpty, 0.8, ATTN_NORM, 0, PITCH_NORM);
		
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.2, 4);	//m_flNextPrimaryAttack = GetNextAttackDelay(0.2);
		
		return HAM_SUPERCEDE;		
	}
	
	if(get_pdata_int(iEnt, m_iShotsFired, 4) && !iAutoShoot)
	{
		return HAM_SUPERCEDE;
	}	
	
	ExecuteHam(Ham_Weapon_PrimaryAttack, iEnt);
	
	switch(iWeaponType)
	{
		case WEAPONTYPE_ELITE:
		{
			if(get_pdata_int(iEnt, m_iWeaponState, 4) & WPNSTATE_ELITE_LEFT)
			{
				PlayWeaponState(id, ELITE_SHOOT_SOUND, ELITE_SHOOTLEFT5);
			}
		}	
		case WEAPONTYPE_GLOCK18:
		{
			if(get_pdata_int(iEnt, m_iWeaponState, 4) & WPNSTATE_GLOCK18_BURST_MODE)
			{
				PlayWeaponState(id, GLOCK18_BURST_SOUND, GLOCK18_SHOOT2);
			}		
		}
		case WEAPONTYPE_FAMAS:
		{
			if(get_pdata_int(iEnt, m_iWeaponState, 4) & WPNSTATE_FAMAS_BURST_MODE)
			{
				PlayWeaponState(id, CLARION_BURST_SOUND, CLARION_SHOOT2);
			}	
		}
		case WEAPONTYPE_M4A1:
		{
			if(get_pdata_int(iEnt, m_iWeaponState, 4) & WPNSTATE_M4A1_SILENCED)
			{
				PlayWeaponState(id, M4A1_SILENT_SOUND, M4A1_SHOOT3);
			}	
		}
		case WEAPONTYPE_USP:
		{
			if(get_pdata_int(iEnt, m_iWeaponState, 4) & WPNSTATE_USP_SILENCED)
			{
				PlayWeaponState(id, USP_SILENT_SOUND, USP_SHOOT3);
			}	
		}		
	}

	//Second mode disabled or weapontype other
	if(!(get_pdata_int(iEnt, m_iWeaponState, 4)))
	{
		PlayWeaponState(id, szSoundFire, iAnim);
	}	
	
	//TODO	
	EjectBrass(id, iEnt);
	
	return HAM_SUPERCEDE;	
}

//State
stock PlayWeaponState(pPlayer, const szShootSound[], iWeaponAnim)
{
	emit_sound(pPlayer, CHAN_WEAPON, szShootSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
	UTIL_SendWeaponAnim(pPlayer, iWeaponAnim);
	
	UTIL_SendSpectatorAnim(pPlayer, iWeaponAnim);	//No checkout against non pev_iuser2, need to simplify later
}

//Spectator support
stock UTIL_SendSpectatorAnim(pPlayer, iAnim)
{
	for(new iSpectator = 1; iSpectator < 33; iSpectator ++)
	{			
		if(is_user_connected(iSpectator) && !is_user_alive(iSpectator) && !is_user_bot(iSpectator))	//No comment...
		{				
			if(pev(iSpectator, pev_iuser2) == pPlayer)
			{				
				UTIL_SendWeaponAnim(iSpectator, iAnim);
			}
		}
	}	
}

//Anim func
stock UTIL_SendWeaponAnim(pPlayer, iAnim) 
{
	static iBody;
	
	iBody = iBodyIndex[pPlayer];

	set_pev(pPlayer, pev_weaponanim, iAnim);
	
	message_begin(MSG_ONE, SVC_WEAPONANIM, _, pPlayer);
	write_byte(iAnim);
	write_byte(iBody);
	message_end();	
}

//Shells
stock EjectBrass(pPlayer, iEnt)
{
	static iShellRifle, iShellShotgun;
	
	if(!iShellRifle || !iShellShotgun)
	{
		iShellRifle = engfunc(EngFunc_PrecacheModel, SHELL_MODEL);
		iShellShotgun = engfunc(EngFunc_PrecacheModel, SHOTGUN_SHELL_MODEL);
	}	
	
	switch(WEAPON_ENT(iEnt))
	{
		case CSW_M3, CSW_XM1014: set_pdata_int(iEnt, m_iShellId, iShellShotgun, 4);
		default: set_pdata_int(iEnt, m_iShellId, iShellRifle, 4);	
	}
	
	set_pdata_float(pPlayer, m_flEjectBrass, get_gametime());	
}