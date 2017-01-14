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

#define is_user_player(%1) (1 <= %1 <= iMaxPlayers)

new Array:gArray, iVip, iMaxPlayers;

new const szCommandVip[][] = { "say /vip", "say_team /vip", "say /vip", "say_team /vip", "vip" };
new const szCommandVips[][] = { "say /vips", "say_team /vips", "say /vipy", "say_team /vipy", "vipy" };

new const szM4A1Model[][] = { "models/CoDMod/p_goldm4a1.mdl", "models/CoDMod/v_goldm4a1.mdl" };
new const szAK47Model[][] = { "models/CoDMod/p_goldak47.mdl", "models/CoDMod/v_goldak47.mdl" };
new const szAWPModel[][] = { "models/CoDMod/p_goldawp.mdl", "models/CoDMod/v_goldawp.mdl" };

forward amxbans_admin_connect(id);

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof szCommandVip; i++)
		register_clcmd(szCommandVip[i], "ShowMotd");
	
	for(new i; i < sizeof szCommandVips; i++)
		register_clcmd(szCommandVips[i], "ShowVips");
	
	register_event("DeathMsg", "DeathMsg", "a");

	register_message(get_user_msgid("SayText"), "HandleSayText");
	register_message(get_user_msgid("ScoreAttrib"), "VipStatus");
	
	RegisterHam(Ham_Spawn, "player", "SpawnedEventPre", 1);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
	RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "M4A1Model", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_ak47", "AK47Model", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "AWPModel", 1);
	
	gArray = ArrayCreate(64, 32);
	
	iMaxPlayers = get_maxplayers();
}

public plugin_natives()
{
	register_native("cod_get_user_vip", "_cod_get_user_vip", 1);
	register_native("cod_set_user_vip", "_cod_set_user_vip", 1);
}

public plugin_precache()
{
	for(new i = 0; i < sizeof szM4A1Model; i++)
		precache_model(szM4A1Model[i]);
		
	for(new i = 0; i < sizeof szM4A1Model; i++)
		precache_model(szAK47Model[i]);
		
	for(new i = 0; i < sizeof szAWPModel; i++)
		precache_model(szAWPModel[i]);
}

public plugin_end()
	ArrayDestroy(gArray);

public client_authorized(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		Set(id, iVip);
		
		new szName[32], szTempName[32], iSize = ArraySize(gArray);
		get_user_name(id, szName, charsmax(szName));
	
		for(new i = 0; i < iSize; i++)
		{
			ArrayGetString(gArray, i, szTempName, charsmax(szTempName));
		
			if(equal(szName, szTempName))
				return 0;
		}
		
		ArrayPushString(gArray, szName);
	}
	return PLUGIN_CONTINUE;
}

public client_disconnect(id)
{
	if(Get(id, iVip))
	{
		Rem(id, iVip);
		
		new szName[32], szTempName[32], iSize = ArraySize(gArray);
		get_user_name(id, szName,charsmax(szName));
	
		for(new i = 0; i < iSize; i++)
		{
			ArrayGetString(gArray, i, szTempName, charsmax(szTempName));
		
			if(equal(szTempName, szName))
			{
				ArrayDeleteItem(gArray, i);
				break;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public client_infochanged(id)
{
	if(Get(id, iVip))
	{
		new szName[64], szNewName[64];
		get_user_info(id, "name", szName, charsmax(szName));
		
		get_user_name(id, szNewName,charsmax(szNewName));
		
		if(!equal(szName, szNewName))
		{
			ArrayPushString(gArray, szName);
			
			new szTempName[64], iSize = ArraySize(gArray);

			for(new i = 0; i < iSize; i++)
			{
				ArrayGetString(gArray, i, szTempName, charsmax(szTempName));
				
				if(equal(szTempName, szNewName))
				{
					ArrayDeleteItem(gArray,i);
					break;
				}
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public ShowMotd(id)
	show_motd(id, "vip.txt", "Informacje o VIPie");
	
public ShowVips(id)
{
	new szName[64], szMessage[192], iSize = ArraySize(gArray);
	
	for(new i = 0; i < iSize; i++)
	{
		ArrayGetString(gArray, i, szName, charsmax(szName));
		
		add(szMessage, charsmax(szMessage), szName);
		
		if(i == iSize - 1)
			add(szMessage, charsmax(szMessage), ".");
		else
			add(szMessage, charsmax(szMessage), ", ");
	}
	
	cod_print_chat(id, DontChange, "^x03VIPy^x01 na serwerze:^x04 %s", szMessage);
	
	return PLUGIN_CONTINUE;
}

public SpawnedEventPre(id)
{
	if(Get(id, iVip) && is_user_alive(id))
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
	if(!is_user_connected(iVictim) || !is_user_connected(iVictim) || get_user_team(iVictim) == get_user_team(iAttacker) || !Get(iAttacker, iVip))
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

public DeathMsg()
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);
	new iHS = read_data(3);
	
	if(!is_user_alive(iKiller) || get_user_team(iKiller) == get_user_team(iVictim) || !Get(iKiller, iVip))
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
{
	if(is_user_alive(id) && Get(id, iVip))
		cs_set_user_money(id, cs_get_user_money(id) + 500);
}

public bomb_defused(id)
{
	if(is_user_alive(id) && Get(id, iVip))
		cs_set_user_money(id, cs_get_user_money(id) + 500);
}

public VipStatus()
{
	new id = get_msg_arg_int(1);
	
	if(is_user_alive(id) && Get(id, iVip))
		set_msg_arg_int(2, ARG_BYTE, get_msg_arg_int(2) | 4);
}

public HandleSayText(msgId, msgDest, msgEnt)
{
	new id = get_msg_arg_int(1);
	
	if(is_user_connected(id) && Get(id, iVip))
	{
		new szMessage[191], szTemp[191], szPrefix[64], szSteamID[33];
		
		get_msg_arg_string(2, szMessage, charsmax(szMessage));
		get_user_authid(id, szSteamID, charsmax(szSteamID)); 
	
		if(equali(szSteamID, "STEAM_0:0:167047226"))
			formatex(szPrefix, charsmax(szPrefix), "^x04[WLASCICIEL]");
		else
			formatex(szPrefix, charsmax(szPrefix), "^x04[VIP]");
		
		if(!equal(szMessage, "#Cstrike_Chat_All"))
		{
			add(szTemp, charsmax(szTemp), szPrefix);
			add(szTemp, charsmax(szTemp), " ");
			add(szTemp, charsmax(szTemp), szMessage);
		}
		else
		{
			add(szTemp, charsmax(szTemp), szPrefix);
			add(szTemp, charsmax(szTemp), "^x03 %s1^x01 :  %s2");
		}
		
		set_msg_arg_string(2, szTemp);
	}
	return PLUGIN_CONTINUE;
}

public amxbans_admin_connect(id)
	client_authorized(id);
	
public _cod_get_user_vip(id)
	return Get(id, iVip);

public _cod_set_user_vip(id)
	client_authorized(id);