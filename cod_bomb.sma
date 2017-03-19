/*	Copyleft 2016
	Plugin thread: https://forums.alliedmods.net/showthread.php?t=241320 

	Bomb Status is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Bomb Status; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/ 

#include <amxmodx>  
#include <amxmisc> 
#include <fakemeta>  
#include <engine>  
#include <csx> 
#include <cstrike> 
#include <hamsandwich>
#include <okapi>
#include <cvar_util>

#if !defined _okapi_included
	#assert "okapi.inc library required ! Get it from https://forums.alliedmods.net/showthread.php?t=234986"
#endif

#if !defined _cvar_util_included
	#assert "cvar_util.inc library required ! Get it from https://forums.alliedmods.net/showthread.php?t=154642"
#endif

#define FBitSet(%1,%2)   (%1 |=  (1 << (%2 & 31))) 
#define FBitGet(%1,%2)   (%1 &   (1 << (%2 & 31))) 
#define FBitClear(%1,%2) (%1 &= ~(1 << (%2 & 31))) 

#define PluginName    "BombStatus"
#define PluginVersion "1.7"
#define PluginAuthor  "HamletEagle"

const AdminAcces = ADMIN_BAN

enum
{
	A = 1, 
	B
}

enum 
{
	BlockedSection = 1,
	SwappedSection
}

enum HamHooks
{
	HamHook:WeaponIdle,
	HamHook:Killed,
	HamHook:AddPlayerItem,
	HamHook:Holster,
	HamHook:Deploy
}

new HamHook:HandleHamHook[HamHooks]

enum ConfigCvars
{
	TeamAcces,
	ColorR,
	ColorG,
	ColorB,
	CommandsStatus,
	CommandsSpamTime,
	LogsStatus,
	C4Timer,
	DisableTeleport
}

new HandleCvar[ConfigCvars]

new bool:InFreezeTime = true
new bool:IsSwappedMapRunning 
new bool:IsBombPlanted        
new bool:IsBombExploded   
new bool:IsBombPlanting   
new bool:IsBombDefusing 
new bool:IsThrowableC4Running 

new Float:BombSitesOrigins[2][3] 
new Float:BombOrigin[3] 

new CountExplosionTime
new BombEntIndex    
new BombStatus     
new DetectionMethod
new TeleportMenu      
new HudStatusBitsum                        
new HandleHudSyncObject  
new UsedBombSite  
new PlayerName       [32]
new CurrentMapName   [32]
new HandleConfigsDir [64]	
new HandleConfigFile [128] 	
new BombSitesEntIndex[2]               

new const FuncBombTarget[] = "func_bomb_target"
new const InfoBombTarget[] = "info_bomb_target"

new const ConfigMapStatus[][]= {"Normal", "Swapped"}
new const ConfigFileName [] = "bombstatus_configuration.ini" 

const m_bHasDefuser = 774
const m_bStartedArming = 320
const XO_WEAPON = 16

#if AMXX_VERSION_NUM < 183
const INT_BYTES = 4 
const BYTE_BITS = 8 

stock bool:get_pdata_bool(ent, charbased_offset, intbase_linuxdiff = 5) 
{ 
	return !!(get_pdata_int(ent, charbased_offset / INT_BYTES, intbase_linuxdiff) & (0xFF<<((charbased_offset % INT_BYTES) * BYTE_BITS))) 
} 
#endif 	

public plugin_init()
{
	register_plugin
	( 
		.plugin_name = PluginName, 
		.version     = PluginVersion,
		.author      = PluginAuthor
	)
	
	register_dictionary("bombstatus.txt")
	
	register_logevent("Logevent_BombDropped", 3, "2=Dropped_The_Bomb") 
	register_logevent("Logevent_RoundEnd"   , 2, "1=Round_End")  
	register_logevent("Logevent_RoundStart" , 2, "1=Round_Start")  
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")  
	register_event("BarTime", "Event_DefusingCanceled", "b", "1=0")
	register_event("CurWeapon", "Event_DefusingCanceled", "be", "2!6")
	register_event("TextMsg", "Event_NewRound", "a", "2=#Game_Commencing")  
	
	HandleHamHook[Killed]	     = RegisterHam(Ham_Killed       , "player",   "CBasePlayer_Killed"       , false)
	HandleHamHook[AddPlayerItem] = RegisterHam(Ham_AddPlayerItem, "player",   "CBasePlayer_AddPlayerItem", false)  
	HandleHamHook[Holster] 	     = RegisterHam(Ham_Item_Holster , "weapon_c4", "CBasePlayer_ItemHolster" , false) 
	HandleHamHook[Deploy] 	     = RegisterHam(Ham_Item_Deploy  , "weapon_c4", "CBasePlayer_ItemDeploy"  , false)
	
	DisableHamForward(HandleHamHook[WeaponIdle] = RegisterHam(Ham_Weapon_WeaponIdle, "weapon_c4", "CBaseEntity_C4Idle", false))
	
	CvarCache(register_cvar("bomb_status_team"      , "0"  ), CvarType_Int, HandleCvar[TeamAcces       ])
	CvarCache(register_cvar("hud_r_color"           , "0"  ), CvarType_Int, HandleCvar[ColorR          ])
	CvarCache(register_cvar("hud_g_color"           , "255"), CvarType_Int, HandleCvar[ColorG          ])
	CvarCache(register_cvar("hud_b_color"           , "85" ), CvarType_Int, HandleCvar[ColorB          ])
	CvarCache(register_cvar("bomb_status_commands"  , "1"  ), CvarType_Int, HandleCvar[CommandsStatus  ])
	CvarCache(register_cvar("bomb_status_c_spamtime", "10" ), CvarType_Int, HandleCvar[CommandsSpamTime])
	CvarCache(register_cvar("bomb_status_logs"      , "0"  ), CvarType_Int, HandleCvar[LogsStatus      ])
	CvarCache(register_cvar("bomb_status_disable_tp", "0"  ), CvarType_Int, HandleCvar[DisableTeleport ])
	CvarCache(get_cvar_pointer("mp_c4timer"                ), CvarType_Int, HandleCvar[C4Timer         ])
	
	HandleHudSyncObject = CreateHudSyncObj()
	
	register_clcmd("say /ch_hud_state" , "ClientCommand_ChHudState") 
	register_clcmd("say_team /ch_hud_state" , "ClientCommand_ChHudState") 
	register_clcmd("bombstatus_cfgmenu", "ClientCommand_CfgMenu", AdminAcces)
	
	new const ShootSatchelChargeSignature[] = {0x83, 0xDEF, 0xDEF, 0x53, 0x56, 0x57, 0xFF, 0xDEF, 0xDEF, 0xDEF, 0xDEF, 0xDEF, 0x33}
	new const ShootSatchelChargeSymbol   [] = "_ZN8CGrenade18ShootSatchelChargeEP9entvars_s6VectorS2_"

	new HandleShootSatchelChargeFunc
	if
	(
		(HandleShootSatchelChargeFunc = okapi_mod_get_symbol_ptr(ShootSatchelChargeSymbol)) || 
		(HandleShootSatchelChargeFunc = okapi_mod_find_sig(ShootSatchelChargeSignature, sizeof ShootSatchelChargeSignature)) 
	) 
	{ 
		okapi_add_hook(okapi_build_function(HandleShootSatchelChargeFunc, arg_cbase, arg_entvars, arg_vec, arg_vec), "OnShootSatchelCharge", .post = 1) 
	} 
	else
	{
		#if AMXX_VERSION_NUM < 183
			new FailReason[100]
			formatex(FailReason, charsmax(FailReason), "%L", LANG_SERVER, "BOMBSTATUS_FAIL")
			set_fail_state(FailReason)
		#else
			set_fail_state("%L", LANG_SERVER, "BOMBSTATUS_FAIL")
		#endif
	}
}

public plugin_cfg() 
{ 
	get_configsdir(HandleConfigsDir, charsmax(HandleConfigsDir)) 
	formatex(HandleConfigFile, charsmax(HandleConfigFile), "%s/%s", HandleConfigsDir, ConfigFileName)
	
	//Checking because if the file already exists it should not be wrote again
	//Otherwise it would remove custom configurations
	if(!file_exists(HandleConfigFile))
	{
		new FilePointer = fopen(HandleConfigFile, "w")
		if(FilePointer)
		{
			fputs(FilePointer, ";Bomb Status Configuration File^n")
			fputs(FilePointer, "^n")
			fputs(FilePointer, "[RESTRICTED MAPS]^n")
			fputs(FilePointer, ";Here you will write maps on which plugin is disabled^n")
			fputs(FilePointer, ";If you want to restrict pluin in de_dust2 you will here^n")
			fputs(FilePointer, ";de_dust2 ( without ; )^n")
			fputs(FilePointer, "^n")
			fputs(FilePointer, "^n")
			fputs(FilePointer, "[SWAPPED MAPS]^n")
			fputs(FilePointer, ";Here you will write the swapped maps.^n")
			fputs(FilePointer, ";A map is swapped when it has inversed bomb site.^n")
			fputs(FilePointer, ";If the plugin display incorectly the Bomb Site where the bomb is planted^n")
			fputs(FilePointer, ";add the map name here.^n")
			fputs(FilePointer, "^n")
			fputs(FilePointer, "de_dust2^n")
			fputs(FilePointer, "de_chateau^n")
			fputs(FilePointer, "de_train")
			fclose(FilePointer)
		} 		
	}
	
	LoadConfigurationFile()
	FindAndAssignBombSites()
	
	//If throwablec4 is running end origin of the c4 needs to be predicted
	if(is_plugin_loaded("Throwable C4", false) != -1)
	{
		IsThrowableC4Running = true
	}
	
	if(DetectionMethod == 2)
	{
		new TeleportMenu = menu_create("Teleport to:", "HandleTeleportMenu")
		menu_additem(TeleportMenu , "BombSite A", "", 0)
		menu_additem(TeleportMenu , "BombSite B", "", 0)
	}
	
	set_task(1.0, "ShowBombHud", .flags = "b") 
}

public plugin_pause()
{
	for(new i; i < sizeof HandleHamHook; i++)
	{
		if(HandleHamHook[HamHooks:i])
		{
			DisableHamForward(HandleHamHook[HamHooks:i])
		}
	}
}

public plugin_unpause()
{
	for(new i; i < sizeof HandleHamHook; i++)
	{
		EnableHamForward(HandleHamHook[HamHooks:i])
	}
}

public plugin_end()
{
	if(TeleportMenu)
	{
		menu_destroy(TeleportMenu)
	}
} 

LoadConfigurationFile() 
{ 
	get_mapname(CurrentMapName, charsmax(CurrentMapName)) 

	new FileData[128], FileSection  
	new FilePointer = fopen(HandleConfigFile , "rt")
	
	if(FilePointer)
	{
		while(!feof(FilePointer))
		{
			fgets(FilePointer, FileData, charsmax(FileData))
			trim(FileData)

			if(!FileData[0] || FileData[0] == ';' || FileData[0] == '#' || FileData[0] == '/')
			{
				continue
			}

			if(FileData[0] == '[')
			{
				FileSection++
				continue
			}

			if(equali(CurrentMapName, FileData))
			{
				switch(FileSection)
				{
					case BlockedSection:
					{
						if(HandleCvar[LogsStatus])
						{
							log_amx("%L", LANG_SERVER, "BOMBSTATUS_RESTRICT" )
						}
						pause("a") 
					}    
					case SwappedSection:
					{
						if(HandleCvar[LogsStatus])
						{
							log_amx("%L", LANG_SERVER, "BOMBSTATUS_SWAPPED" ) 
						}
						IsSwappedMapRunning = true     
					}
				}
				break
			}
		}
		fclose(FilePointer)
	}
} 

FindAndAssignBombSites()
{
	new Target = -1
	
	BombSitesEntIndex[0] = find_ent_by_class(Target, FuncBombTarget) 
	if(!pev_valid(BombSitesEntIndex[0]))
	{
		BombSitesEntIndex[0] = find_ent_by_class(Target, InfoBombTarget) 
	}
	
	BombSitesEntIndex[1] = find_ent_by_class(BombSitesEntIndex[0], FuncBombTarget) 
	if(!pev_valid(BombSitesEntIndex[1]))
	{	
		BombSitesEntIndex[1] = find_ent_by_class(BombSitesEntIndex[0], InfoBombTarget) 
	}
	
	if(!pev_valid(BombSitesEntIndex[0]) && !pev_valid(BombSitesEntIndex[1]))
	{
		if(HandleCvar[LogsStatus]) 
		{
			log_amx("%L", LANG_SERVER, "BOMBSTATUS_NOBS" ) 
		}
		pause("a") 
	}
	
	//Try to find bombsite name using infodecal entities
	ProcessBombSite(BombSitesEntIndex[0])
	ProcessBombSite(BombSitesEntIndex[1])
	
	new BombSiteType[2]
	BombSiteType[0] = pev(BombSitesEntIndex[0], pev_iuser3)
	BombSiteType[1] = pev(BombSitesEntIndex[1], pev_iuser3)
	
	/*
		| Some maps have infodecals only around one bombsite
		| Assign the other one based on what we found
	*/
	if(!BombSiteType[0] && BombSiteType[1])
	{
		//Missing infodecals for A
		SwapBombSiteType(BombSitesEntIndex[0], BombSiteType[1])
	}
	else if(BombSiteType[0] && !BombSiteType[1])
	{
		//Missing infodecals for B
		SwapBombSiteType(BombSitesEntIndex[1], BombSiteType[0])
	}
	else if(!BombSiteType[0] && !BombSiteType[1])
	{
		//Infodecals method failed, assign randomly, based on swapped maps list
		DetectionMethod = 2
		
		get_brush_entity_origin(BombSitesEntIndex[0], BombSitesOrigins[0])
		get_brush_entity_origin(BombSitesEntIndex[1], BombSitesOrigins[1])
		
		if(IsSwappedMapRunning) 
		{ 
			BombSiteType[0] = B
			BombSiteType[1] = A
			SwapOrigins()
		}
		else 
		{
			BombSiteType[0] = A
			BombSiteType[1] = B
		}
		
		set_pev(BombSitesEntIndex[0], pev_iuser3, BombSiteType[0])	
		set_pev(BombSitesEntIndex[1], pev_iuser3, BombSiteType[1])
	}
}

//Search in a radius of 250.0 units around each bombsite and retrieve infodecal entities 
ProcessBombSite(BombSiteIndex)
{
	new InfoDecalSkin, EntityClassName[32], Target = -1
	new const InfoDecal[] = "infodecal"
	
	new DecalIndex[2]
	DecalIndex[0] = get_decal_index("{siteA")
	DecalIndex[1] = get_decal_index("{siteB")
	
	new Float:TempOrigin[3]
	get_brush_entity_origin(BombSiteIndex, TempOrigin)
	
	while((Target = find_ent_in_sphere(Target, TempOrigin, 250.0)))
	{
		if(pev_valid(Target))
		{
			pev(Target, pev_classname, EntityClassName, charsmax(EntityClassName))
			if(equal(EntityClassName, InfoDecal))
			{
				InfoDecalSkin = pev(Target, pev_skin)
				if(pev(BombSiteIndex, pev_iuser3) == 0)
				{
					if(InfoDecalSkin == DecalIndex[0])
					{
						//This bombsite is A
						set_pev(BombSiteIndex, pev_iuser3, A)
						BombSitesOrigins[0] = TempOrigin
						
						DetectionMethod = 1
					}
					else if(InfoDecalSkin == DecalIndex[1])
					{
						//This bombsite is B
						set_pev(BombSiteIndex, pev_iuser3, B)
						BombSitesOrigins[1] = TempOrigin
						
						DetectionMethod = 1
					}	
				}
				else 
				{
					//Done searching, we found what we wanted
					break
				}
			}
		}
	}
}

SwapBombSiteType(BombSiteIndex, BombSiteType)
{
	switch(BombSiteType)
	{
		case A:
		{
			set_pev(BombSiteIndex, pev_iuser3, B)
			get_brush_entity_origin(BombSiteIndex, BombSitesOrigins[1])
		}
		case B:
		{
			set_pev(BombSiteIndex, pev_iuser3, A)	
			get_brush_entity_origin(BombSiteIndex, BombSitesOrigins[0])
		}
	}
}

public ShowBombHud() 
{ 
	static Float:PlayerOrigins[3] 
	static HudMessage[256]

	static Players[32], PlayersNum, id, i 

	switch(HandleCvar[TeamAcces]) 
	{ 
		case 1:  get_players(Players, PlayersNum, "ce", "TERRORIST") 
		case 2:  get_players(Players, PlayersNum, "ce", "CT") 
		default: get_players(Players, PlayersNum, "c")          
	} 

	if(!PlayersNum) 
	{
		return
	}

	for(i = 0; i < PlayersNum; i++) 
	{ 
		id = Players[i]

		if(!FBitGet(HudStatusBitsum, id)) 
		{
			continue  
		}

		if(!IsBombPlanted) 
		{ 
			BombStatus == 1 ? 
				formatex(HudMessage, charsmax(HudMessage), "%L", id, "BOMBSTATUS_DROPPED") : 
				formatex(HudMessage, charsmax(HudMessage), "%L", id, "BOMBSTATUS_CARRIED", PlayerName)     
		} 

		if(IsBombExploded)  
		{
			formatex(HudMessage, charsmax(HudMessage), "%L", id, "BOMBSTATUS_BOMBED") 
		}

		if(IsBombPlanting)   
		{
			formatex(HudMessage, charsmax(HudMessage), "%L", id, "BOMBSTATUS_PLANTING", PlayerName) 
		}

		if(IsBombPlanted)  
		{
			pev(id, pev_origin, PlayerOrigins)
			
			if(!CountExplosionTime)
			{
				CountExplosionTime = HandleCvar[C4Timer]
			}
			if(CountExplosionTime > 0)
			{   
				IsBombDefusing  ? 
					formatex(HudMessage, charsmax(HudMessage), "%L", id, "BOMBSTATUS_PLANTED1", UsedBombSite == 1 ? "A" :"B", PlayerName, floatround((get_distance_f(PlayerOrigins, BombOrigin) / 100)), CountExplosionTime, get_pdata_bool(id, m_bHasDefuser) ? "DefuseKit" : "Default") : 
					formatex(HudMessage, charsmax(HudMessage), "%L", id, "BOMBSTATUS_PLANTED2", UsedBombSite == 1 ? "A" :"B", PlayerName, floatround((get_distance_f(PlayerOrigins, BombOrigin) / 100)), CountExplosionTime) 
				CountExplosionTime --     
			}
		} 

		set_hudmessage(HandleCvar[ColorR], HandleCvar[ColorG], HandleCvar[ColorB], 0.0, 0.25, 0, 6.0, 2.0)
		ShowSyncHudMsg(id, HandleHudSyncObject, HudMessage)     
	} 
} 

public ClientCommand_ChHudState(id)
{ 
	if(!HandleCvar[CommandsStatus]) 
	{
		client_print(id, print_chat, "%L", id, "BOMBSTATUS_DISABLED") 
		return
	}
	
	new Float:GameTime = get_gametime()
	static Float:CommandsUsedGTime

	if(CommandsUsedGTime > GameTime) 
	{
		client_print(id, print_chat, "%L", id, "BOMBSTATUS_WAIT", HandleCvar[CommandsSpamTime]) 
		return
	}
	
	if(FBitGet(HudStatusBitsum, id))
	{
		FBitClear(HudStatusBitsum, id)
		client_print(id, print_chat, "%L", id, "BOMBSTATUS_HUDDIS")
		CommandsUsedGTime = GameTime + float(HandleCvar[CommandsSpamTime])
	}
	else
	{
		FBitSet(HudStatusBitsum, id)
		client_print(id, print_chat, "%L", id, "BOMBSTATUS_HUDENA")
		CommandsUsedGTime = GameTime + float(HandleCvar[CommandsSpamTime])
	}
} 

public ClientCommand_CfgMenu(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
	{
		return 1
	}
	
	if(DetectionMethod == 2)
	{
		new Access = 0, MenuTitle[60]
		formatex(MenuTitle, charsmax(MenuTitle),"BombStatus Configuration Menu^nStatus: %s", ConfigMapStatus[IsSwappedMapRunning])
		
		new Menu = menu_create(MenuTitle, "HandleConfigurationMenu")

		IsSwappedMapRunning ? 
		menu_additem(Menu, "Mark as normal", "", Access):
		menu_additem(Menu, "Mark as swapped", "", Access)
		
		//Just for avoid command being exploited by admins to get an advantage(like camping in bombsite)
		if(IsBombPlanted && HandleCvar[DisableTeleport] || InFreezeTime)
		{
			Access = 1 << 31
		}
		
		menu_additem(Menu, "Teleport", "", Access)
		menu_display(id, Menu, 0)
	}
	else 
	{
		client_print(id, print_chat, "BombSites were assigned using infodecal detection method. Menu is not available in this map")
	}
	
	return 1
}

public HandleConfigurationMenu(id, Menu, Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(Menu)
		return
	}

	switch(Item)
	{
		case 0:
		{
			IsSwappedMapRunning = !IsSwappedMapRunning
			client_print(id, print_chat, "Map marked as: %s", ConfigMapStatus[IsSwappedMapRunning])
			
			UpdateFile(IsSwappedMapRunning)
			SwapOrigins()
			
			//If bomb is planted fix the hud
			if(IsBombPlanted)
			{
				if(UsedBombSite == 1)
				{
					UsedBombSite = 2
				}
				else
				{
					UsedBombSite = 1
				}
			}
		}
		case 1:
		{
			menu_display(id, TeleportMenu , 0)
		}
	}
	menu_destroy(Menu)
}

public HandleTeleportMenu(id, Menu, Item)
{
	if(Item == MENU_EXIT)
	{
		menu_cancel(id)
		return 
	}
	
	if(!is_user_alive(id))
	{
		return
	}
	
	new Float:BombSitesTempOrigin[3]
	BombSitesTempOrigin = BombSitesOrigins[Item]
	
	//Set the origins and make sure that the player won't get stuck into the map 
	if(ValidSpotFound(id, BombSitesTempOrigin))
	{
		set_pev(id, pev_origin, BombSitesTempOrigin)
	}
	else
	{
		//The above failed, can't teleport directly
		//Need to find am empty spot around given origin
		new RestrictMaxSearches = 150, i, Float:FoundOrigin[3]
		while(--RestrictMaxSearches > 0)
		{
			for(i = 0; i < 3; i++)
			{
				FoundOrigin[i] = random_float(BombSitesTempOrigin[i] - 250, BombSitesTempOrigin[i] + 250)
			}
			
			if(ValidSpotFound(id, FoundOrigin))
			{
				set_pev(id, pev_origin, FoundOrigin)
				drop_to_floor(id)
				break
			}
		}
	}
	
	menu_cancel(id)
}

bool:ValidSpotFound(id, Float:BombSitesTempOrigin[3])
{
	new HandleGlobalTraceLine
	engfunc(EngFunc_TraceHull, BombSitesTempOrigin, BombSitesTempOrigin, IGNORE_MONSTERS, pev(id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, id, HandleGlobalTraceLine)	
	
	if(get_tr2(HandleGlobalTraceLine, TR_InOpen) && !(get_tr2(HandleGlobalTraceLine, TR_StartSolid) || get_tr2(HandleGlobalTraceLine, TR_AllSolid))) 
	{
		return true
	}
	return false		
}

SwapOrigins()
{
	new Float:BackUpOrigins[3]
	BackUpOrigins = BombSitesOrigins[0]
	BombSitesOrigins[0] = BombSitesOrigins[1]
	BombSitesOrigins[1] = BackUpOrigins
}

UpdateFile(bool:SwappedMap)
{
	new const OpenFlags[][] = {"rt", "a"}
	new FilePointer = fopen(HandleConfigFile, OpenFlags[SwappedMap])

	if(FilePointer)
	{
		if(SwappedMap)
		{
			fprintf(FilePointer, "%s", CurrentMapName)
			fclose(FilePointer)
		}
		else 
		{
			new const FileName[] = "/tempfile.ini"
			
			if(!equal(HandleConfigsDir[strlen(HandleConfigsDir) - 13], FileName))
			{
				add(HandleConfigsDir, charsmax(HandleConfigsDir), FileName)
			}
			
			new InputFilePointer = fopen(HandleConfigsDir, "wt")
			if(InputFilePointer)
			{
				new FileData[128]
				while(!feof(FilePointer))
				{
					fgets(FilePointer, FileData, charsmax(FileData))
					trim(FileData)
					
					if(equali(FileData, CurrentMapName))
					{
						continue
					}
					fprintf(InputFilePointer, "%s^n", FileData)
				}
				
				fclose(InputFilePointer)
				fclose(FilePointer)

				delete_file(HandleConfigFile)
				rename_file(HandleConfigsDir, HandleConfigFile, 1)
			}
		} 
	}
}

public client_putinserver(id) 
{
	FBitSet(HudStatusBitsum, id)
}

public bomb_planted(id) 
{ 
	new Target = -1, EntityClassName[32]
	while((Target = find_ent_in_sphere(Target, BombOrigin, 10.0)))
	{
		pev(Target, pev_classname, EntityClassName, charsmax(EntityClassName))
		if(equal(EntityClassName, FuncBombTarget) || equal(EntityClassName, InfoBombTarget))
		{
			UsedBombSite = pev(Target, pev_iuser3)
			break
		}
	}

	get_user_name(id, PlayerName, charsmax(PlayerName)) 

	IsBombPlanting = false
	IsBombPlanted = true 
} 

public bomb_explode() 
{ 
	IsBombPlanted = false 
	IsBombExploded = true 
	IsBombDefusing = false
	CountExplosionTime = 0
} 

public bomb_defused() 
{
	IsBombPlanted = false 
	IsBombDefusing = false
	CountExplosionTime = 0
}

public bomb_planting() 
{
	IsBombPlanting = true

	if(pev_valid(BombEntIndex)) 
	{ 
		new EntityOwner = pev(BombEntIndex, pev_owner)     
		if(is_user_connected(EntityOwner))  
		{
			get_user_name(EntityOwner, PlayerName, charsmax(PlayerName))   
		}            
	} 
}

public bomb_defusing()
{ 
	IsBombDefusing = true
}

public Logevent_BombDropped()   
{
	BombStatus = 1 
}

public Logevent_RoundEnd() 
{ 
	IsBombPlanted      = false     
	IsBombExploded     = false
	IsBombPlanting     = false
	IsBombDefusing 	   = false
	BombStatus         = 1
	CountExplosionTime = 0
} 

public Logevent_RoundStart()
{
	InFreezeTime = false
}

public Event_NewRound() 
{  
	InFreezeTime   = true
	IsBombExploded = false 
	IsBombPlanted  = false
	IsBombPlanting = false
	BombStatus     = 0
}

public Event_DefusingCanceled()
{
	IsBombDefusing = false
}

public CBasePlayer_AddPlayerItem(id, WeaponEnt)
{
	if(pev_valid(WeaponEnt) && cs_get_weapon_id(WeaponEnt) == CSW_C4)
	{
		BombStatus = 0   
		get_user_name(id, PlayerName, charsmax(PlayerName))   
	}
}

public CBasePlayer_Killed(id) 
{
	if(cs_get_user_team(id) != CS_TEAM_T)
	{
		return
	}

	if(user_has_weapon(id, CSW_C4)) 
	{
		BombStatus = 1
		IsBombPlanting = false
	}
}

public CBasePlayer_ItemHolster() 
{
	DisableHamForward(HandleHamHook[WeaponIdle])
}

public CBasePlayer_ItemDeploy()
{
	EnableHamForward(HandleHamHook[WeaponIdle])
}

public CBaseEntity_C4Idle(iEnt)
{
	if(get_pdata_bool(iEnt, m_bStartedArming, XO_WEAPON))
	{
		IsBombPlanting = false
	}
}

public OnShootSatchelCharge(iOwner, iEnt, Float: EntOrigin[3], Float: EntAngles[])
{
	//Get c4 ent id
	BombEntIndex = okapi_get_orig_return()
	if(!IsThrowableC4Running)
	{
		pev(BombEntIndex, pev_origin, BombOrigin)
	}
	else
	{
		//Send a trace so we can get the end origin of the c4, in case throwablec4 is running
		new HandleTrace = create_tr2()
		engfunc(EngFunc_TraceToss, BombEntIndex, IGNORE_MONSTERS, HandleTrace)
		get_tr2(HandleTrace, TR_vecEndPos, BombOrigin)
		free_tr2(HandleTrace)
	}
}  