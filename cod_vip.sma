#include <amxmodx>
#include <cod>
#include <cstrike>
#include <csx>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <dhudmessage>

#define PLUGIN "CoD VIP"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define is_user_player(%1) (1 <= %1 <= maxPlayers)

new Array:listVIPs, maxPlayers, vip;

new const commandVIP[][] = { "say /vip", "say_team /vip", "say /vip", "say_team /vip", "vip" };
new const commandVIPs[][] = { "say /vips", "say_team /vips", "say /vipy", "say_team /vipy", "vipy" };

new const szM4A1Model[][] = { "models/CoDMod/p_goldm4a1.mdl", "models/CoDMod/v_goldm4a1.mdl" };
new const szAK47Model[][] = { "models/CoDMod/p_goldak47.mdl", "models/CoDMod/v_goldak47.mdl" };
new const szAWPModel[][] = { "models/CoDMod/p_goldawp.mdl", "models/CoDMod/v_goldawp.mdl" };

forward amxbans_admin_connect(id);

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof commandVIP; i++) register_clcmd(commandVIP[i], "show_motd");
	
	for(new i; i < sizeof commandVIPs; i++) register_clcmd(commandVIPs[i], "show_vips");
	
	register_event("player_death", "DeathMsg", "a");

	register_message(get_user_msgid("SayText"), "say_text");
	register_message(get_user_msgid("ScoreAttrib"), "vip_status");
	
	RegisterHam(Ham_Spawn, "player", "SpawnedEventPre", 1);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
	RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "M4A1Model", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_ak47", "AK47Model", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "AWPModel", 1);
	
	listVIPs = ArrayCreate(64, 32);
	
	maxPlayers = get_maxplayers();
}

public plugin_natives()
{
	register_native("cod_get_user_vip", "_cod_get_user_vip", 1);
	register_native("cod_set_user_vip", "_cod_set_user_vip", 1);
}

public plugin_precache()
{
	for(new i = 0; i < sizeof szM4A1Model; i++) precache_model(szM4A1Model[i]);
		
	for(new i = 0; i < sizeof szM4A1Model; i++) precache_model(szAK47Model[i]);
		
	for(new i = 0; i < sizeof szAWPModel; i++) precache_model(szAWPModel[i]);
}

public plugin_end()
	ArrayDestroy(listVIPs);

public client_authorized(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		Set(id, vip);
		
		new szName[32], szTempName[32], iSize = ArraySize(listVIPs);
		get_user_name(id, szName, charsmax(szName));
	
		for(new i = 0; i < iSize; i++)
		{
			ArrayGetString(listVIPs, i, szTempName, charsmax(szTempName));
		
			if(equal(szName, szTempName))
				return 0;
		}
		
		ArrayPushString(listVIPs, szName);
	}
	return PLUGIN_CONTINUE;
}

public client_disconnect(id)
{
	if(Get(id, vip))
	{
		Rem(id, vip);
		
		new szName[32], szTempName[32], iSize = ArraySize(listVIPs);
		get_user_name(id, szName,charsmax(szName));
	
		for(new i = 0; i < iSize; i++)
		{
			ArrayGetString(listVIPs, i, szTempName, charsmax(szTempName));
		
			if(equal(szTempName, szName))
			{
				ArrayDeleteItem(listVIPs, i);
				break;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public client_infochanged(id)
{
	if(Get(id, vip))
	{
		new szName[64], szNewName[64];
		get_user_info(id, "name", szName, charsmax(szName));
		
		get_user_name(id, szNewName,charsmax(szNewName));
		
		if(!equal(szName, szNewName))
		{
			ArrayPushString(listVIPs, szName);
			
			new szTempName[64], iSize = ArraySize(listVIPs);

			for(new i = 0; i < iSize; i++)
			{
				ArrayGetString(listVIPs, i, szTempName, charsmax(szTempName));
				
				if(equal(szTempName, szNewName))
				{
					ArrayDeleteItem(listVIPs,i);
					break;
				}
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public show_motd(id)
	show_motd(id, "vip.txt", "Informacje o VIPie");
	
public show_vips(id)
{
	new szName[64], szMessage[192], iSize = ArraySize(listVIPs);
	
	for(new i = 0; i < iSize; i++)
	{
		ArrayGetString(listVIPs, i, szName, charsmax(szName));
		
		add(szMessage, charsmax(szMessage), szName);
		
		if(i == iSize - 1)
			add(szMessage, charsmax(szMessage), ".");
		else
			add(szMessage, charsmax(szMessage), ", ");
	}
	
	cod_print_chat(id, "^x03VIPy^x01 na serwerze:^x04 %s", szMessage);
	
	return PLUGIN_CONTINUE;
}

public SpawnedEventPre(id)
{
	if(Get(id, vip) && is_user_alive(id))
		SpawnedEventPreVip(id);
}

public SpawnedEventPreVip(id)
{
	cod_give_weapon(id, CSW_HEGRENADE);
	
	cod_give_weapon(id, CSW_FLASHBANG);
	cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
	
	cod_give_weapon(id, CSW_SMOKEGRENADE);
}

public TakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamagebits)
{
	if(!is_user_connected(iVictim) || !is_user_connected(iVictim) || get_user_team(iVictim) == get_user_team(iAttacker) || !Get(iAttacker, vip))
		return HAM_IGNORED;
		
	SetHamParamFloat(4, fDamage * 1.1);
	return HAM_HANDLED;
}

public M4A1Model(weapon)
{
	static id;
	id = pev(weapon, pev_owner);

	if(is_user_player(id))
	{
		set_pev(id, pev_weaponmodel2, szM4A1Model[0]);
		set_pev(id, pev_viewmodel2, szM4A1Model[1]);
	}
}

public AK47Model(weapon)
{
	static id;
	id = pev(weapon, pev_owner);

	if(is_user_player(id))
	{
		set_pev(id, pev_weaponmodel2, szAK47Model[0]);
		set_pev(id, pev_viewmodel2, szAK47Model[1]);
	}
}

public AWPModel(weapon)
{
	static id;
	id = pev(weapon, pev_owner);

	if(is_user_player(id))
	{
		set_pev(id, pev_weaponmodel2, szAWPModel[0]);
		set_pev(id, pev_viewmodel2, szAWPModel[1]);
	}
}

public player_death()
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);
	new iHS = read_data(3);
	
	if(!is_user_alive(iKiller) || get_user_team(iKiller) == get_user_team(iVictim) || !Get(iKiller, vip))
		return PLUGIN_CONTINUE;

	set_user_health(iKiller, min(get_user_health(iKiller) + (iHS ? 15 : 10), cod_get_user_health(iKiller, 1, 1, 1)));
	cs_set_user_money(iKiller, cs_get_user_money(iKiller) + (iHS ? 1000 : 500));
	
	if(iHS)
	{
		set_dhudmessage(38, 218, 116, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(iKiller, "HeadShot! +15HP");
	}
	else
	{
		set_dhudmessage(255, 212, 0, 0.50, 0.31, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(iKiller, "Zabiles! +10HP");
	}
	return PLUGIN_CONTINUE;
}

public bomb_planted(id)
	if(is_user_alive(id) && Get(id, vip)) cs_set_user_money(id, cs_get_user_money(id) + 500);

public bomb_defused(id)
	if(is_user_alive(id) && Get(id, vip)) cs_set_user_money(id, cs_get_user_money(id) + 500);

public vip_status()
{
	new id = get_msg_arg_int(1);
	
	if(is_user_alive(id) && Get(id, vip)) set_msg_arg_int(2, ARG_BYTE, get_msg_arg_int(2) | 4);
}

public say_text(msgId, msgDest, msgEnt)
{
	new id = get_msg_arg_int(1);
	
	if(is_user_connected(id) && Get(id, iVip))
	{
		new szTempMessage[190], szMessage[190], szPrefix[64], szSteamID[33];
		
		get_msg_arg_string(2, szTempMessage, charsmax(szTempMessage));
		get_user_authid(id, szSteamID, charsmax(szSteamID)); 

		if(equali(szSteamID, "STEAM_0:1:55664") || equali(szSteamID, "STEAM_0:1:6389510")) formatex(szPrefix, charsmax(szPrefix), "^x04[WLASCICIEL]");
		else formatex(szPrefix, charsmax(szPrefix), "^x04[VIP]");
		
		if(!equal(szTempMessage, "#Cstrike_Chat_All"))
		{
			add(szMessage, charsmax(szMessage), szPrefix);
			add(szMessage, charsmax(szMessage), " ");
			add(szMessage, charsmax(szMessage), szTempMessage);
		}
		else
		{
			add(szMessage, charsmax(szMessage), szPrefix);
			add(szMessage, charsmax(szMessage), "^x03 %s1^x01 :  %s2");
		}
		
		set_msg_arg_string(2, szMessage);
	}
	
	return PLUGIN_CONTINUE;
}

public amxbans_admin_connect(id)
	client_authorized(id);
	
public _cod_get_user_vip(id)
	return Get(id, vip);

public _cod_set_user_vip(id)
	client_authorized(id);