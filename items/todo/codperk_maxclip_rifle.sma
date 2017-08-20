#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <engine>
#include <codmod>

#define VERSION "0.3.0"

enum {
	idle,
	shoot1,
	shoot2,
	insert,
	after_reload,
	start_reload,
	draw
}
new g_pWeapons, g_iNum, g_iWeapons[32];

const RIFLES_WPN_BS = ((1<<CSW_AUG)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_M4A1)|(1<<CSW_SG552)|(1<<CSW_AK47))
const SILENT_BS	= (1<<CSW_M4A1)

// weapons offsets
#define XTRA_OFS_WEAPON			4
#define m_pPlayer				41
#define m_iId					43
#define m_fKnown				44
#define m_flNextPrimaryAttack		46
#define m_flNextSecondaryAttack	47
#define m_flTimeWeaponIdle		48
#define m_iPrimaryAmmoType		49
#define m_iClip				51
#define m_fInReload				54
#define m_fSilent				74

// players offsets
#define XTRA_OFS_PLAYER		5
#define m_flNextAttack		83
#define m_rgAmmo_player_Slot0	376

stock const g_iDftMaxClip[CSW_P90+1] = {
	-1,  13, -1, 10,  1,  7,    1, 30, 30,  1,  30, 
		20, 25, 30, 35, 25,   12, 20, 10, 30, 100, 
		8 , 30, 30, 20,  2,    7, 30, 30, -1,  50}

stock const Float:g_fDelay[CSW_P90+1] = {
	0.00, 2.70, 0.00, 2.00, 0.00, 0.55,   0.00, 3.15, 3.30, 0.00, 4.50, 
		 2.70, 3.50, 3.35, 2.45, 3.30,   2.70, 2.20, 2.50, 2.63, 4.70, 
		 0.55, 3.05, 2.12, 3.50, 0.00,   2.20, 3.00, 2.45, 0.00, 3.40
}

stock const g_iReloadAnims[CSW_P90+1] = {
	-1,  5, -1, 3, -1,  6,   -1, 1, 1, -1, 14, 
		4,  2, 3,  1,  1,   13, 7, 4,  1,  3, 
		6, 11, 1,  3, -1,    4, 1, 1, -1,  1}

new g_iMaxClip[CSW_P90+1]
new g_iPerkValue[33];
new HamHook:g_iHhPostFrame[CSW_P90+1]
new HamHook:g_iHhAttachToPlayer[CSW_P90+1]
new bool: ma_perk[33];

new const PerkName[] = "Magazynek Bebnowy";
new const PerkDesc[] = "Dostajesz magazynek bebnowy, dzieki czemu masz dodatkowe LW amunicji w karabinach szturmowych";

public plugin_init()
{
	register_plugin(PerkName, VERSION, "ConnorMcLeod & Hleb")
	cod_register_perk(PerkName, PerkDesc, 30, 60);
	RegisterHam(Ham_Spawn, "player", "Player_Spawn", 1);
}
public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	g_pWeapons = get_user_weapons(id, g_iWeapons, g_iNum);
	g_iPerkValue[id] = wartosc;
	CodSetMaxClips(id, g_pWeapons, g_iPerkValue[id]);
}
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	g_pWeapons = get_user_weapons(id, g_iWeapons, g_iNum);
	CodSetMaxClips(id, g_pWeapons, 0);
}
public Player_Spawn(id)
{
	if(ma_perk[id])
	{
		g_pWeapons = get_user_weapons(id, g_iWeapons, g_iNum);
		CodSetMaxClips(id, g_pWeapons, g_iPerkValue[id]);
	}
}		
public CodSetMaxClips(id, weaponbits, value)
{
	for(new i = 1; i<=30; i++)
	{
		if(weaponbits & 1<<i && RIFLES_WPN_BS & 1<<i)
		{
			new szWeaponName[22];
			get_weaponname(i, szWeaponName, 21);
			new iMaxClip = g_iDftMaxClip[i]+value;
			if( iMaxClip && iMaxClip != g_iDftMaxClip[i] )
			{
				g_iMaxClip[i] = iMaxClip
				if(g_iHhPostFrame[i] )
				{
					EnableHamForward( g_iHhPostFrame[i] )
				}
				else
				{
					g_iHhPostFrame[i] = RegisterHam(Ham_Item_PostFrame, szWeaponName, "Item_PostFrame")
				}
				if(g_iHhAttachToPlayer[i] )
				{
					EnableHamForward( g_iHhAttachToPlayer[i] )
				}
				else
				{
					g_iHhAttachToPlayer[i] = RegisterHam(Ham_Item_AttachToPlayer, szWeaponName, "Item_AttachToPlayer")
				}
			}
			else
			{
				g_iMaxClip[i] = 0;
				if( g_iHhPostFrame[i] )
				{
					DisableHamForward( g_iHhPostFrame[i] )
				}
				if( g_iHhAttachToPlayer[i] )
				{
					DisableHamForward( g_iHhAttachToPlayer[i] )
				}
			}
		}
	}
	return PLUGIN_HANDLED
}
public Item_AttachToPlayer(iEnt, id)
{
	if(get_pdata_int(iEnt, m_fKnown, XTRA_OFS_WEAPON) && !ma_perk[id])
	{
		return
	}
	set_pdata_int(iEnt, m_iClip, g_iMaxClip[ get_pdata_int(iEnt, m_iId, XTRA_OFS_WEAPON) ], XTRA_OFS_WEAPON)
}
public Item_PostFrame(iEnt)
{
	static id ; id = get_pdata_cbase(iEnt, m_pPlayer, XTRA_OFS_WEAPON)
	if(!ma_perk[id])
		return;
	static iId ; iId = get_pdata_int(iEnt, m_iId, XTRA_OFS_WEAPON)
	static iMaxClip ; iMaxClip = g_iMaxClip[iId]
	static fInReload ; fInReload = get_pdata_int(iEnt, m_fInReload, XTRA_OFS_WEAPON)
	
	static Float:flNextAttack ; flNextAttack = get_pdata_float(id, m_flNextAttack, XTRA_OFS_PLAYER)

	static iAmmoType ; iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int(iEnt, m_iPrimaryAmmoType, XTRA_OFS_WEAPON)
	static iBpAmmo ; iBpAmmo = get_pdata_int(id, iAmmoType, XTRA_OFS_PLAYER)
	static iClip ; iClip = get_pdata_int(iEnt, m_iClip, XTRA_OFS_WEAPON)

	if( fInReload && flNextAttack <= 0.0 )
	{
		new j = min(iMaxClip - iClip, iBpAmmo)
		set_pdata_int(iEnt, m_iClip, iClip + j, XTRA_OFS_WEAPON)
		set_pdata_int(id, iAmmoType, iBpAmmo-j, XTRA_OFS_PLAYER)
		
		set_pdata_int(iEnt, m_fInReload, 0, XTRA_OFS_WEAPON)
		fInReload = 0
	}

	static iButton ; iButton = pev(id, pev_button)
	if(	(iButton & IN_ATTACK2 && get_pdata_float(iEnt, m_flNextSecondaryAttack, XTRA_OFS_WEAPON) <= 0.0)
	||	(iButton & IN_ATTACK && get_pdata_float(iEnt, m_flNextPrimaryAttack, XTRA_OFS_WEAPON) <= 0.0)	)
	{
		return
	}

	if( iButton & IN_RELOAD && !fInReload )
	{
		if( iClip >= iMaxClip )
		{
			set_pev(id, pev_button, iButton & ~IN_RELOAD)
			if( SILENT_BS & (1<<iId) && !get_pdata_int(iEnt, m_fSilent, XTRA_OFS_WEAPON) )
			{
				SendWeaponAnim( id, 7 )
			}
			else
			{
				SendWeaponAnim(id, 0)
			}
		}
		else if( iClip == g_iDftMaxClip[iId] )
		{
			if( iBpAmmo )
			{
				set_pdata_float(id, m_flNextAttack, g_fDelay[iId], XTRA_OFS_PLAYER)

				if( SILENT_BS & (1<<iId) && get_pdata_int(iEnt, m_fSilent, XTRA_OFS_WEAPON) )
				{
					SendWeaponAnim( id, 4 )
				}
				else
				{
					SendWeaponAnim(id, g_iReloadAnims[iId])
				}
				set_pdata_int(iEnt, m_fInReload, 1, XTRA_OFS_WEAPON)

				set_pdata_float(iEnt, m_flTimeWeaponIdle, g_fDelay[iId] + 0.5, XTRA_OFS_WEAPON)
			}
		}
	}
}

SendWeaponAnim(id, iAnim)
{
	set_pev(id, pev_weaponanim, iAnim)

	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id,pev_body))
	message_end()
}
