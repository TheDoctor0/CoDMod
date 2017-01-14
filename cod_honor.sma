#include <amxmodx>
#include <cod>
#include <nvault>
#include <sqlx>
#include <fakemeta>

#define PLUGIN	"CoD Honor System"
#define AUTHOR	"O'Zone"
#define VERSION	"1.0"

#define is_user_player(%1) (1 <= %1 <= iMaxPlayers)

#define Set(%2,%1) (%1 |= (1<<(%2&31)))
#define Rem(%2,%1) (%1 &= ~(1 <<(%2&31)))
#define Get(%2,%1) (%1 & (1<<(%2&31)))
	
enum Events 
{
	KILL = 0, 
	KILLHS, 
	DEFUSED, 
	PLANTED, 
	RESCUEHOST, 
	KILLHOST
};

new szPlayer[33][64], iPlayerHonor[33];

new cvarSaveType, cvarMinPlayers, cvarKill, cvarKillHS, cvarBombPlated, cvarBombDefused, cvarRescueHostage, cvarKillHostage;

new iHonor[Events], iHonorMinPlayers, iMaxPlayers, iLoaded;

new gVault;

new Handle:hSqlHook;

public plugin_init()
{	
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cvarSaveType = register_cvar("cod_honor_save_type", "1"); // 0 - SQL | 1 - NVAULT
	cvarMinPlayers = register_cvar("cod_honor_minplayers", "5");
	cvarKill = register_cvar("cod_honor_kill", "1");
	cvarKillHS = register_cvar("cod_honor_killhs", "1");
	cvarBombPlated = register_cvar("cod_honor_bombplanted", "1");
	cvarBombDefused = register_cvar("cod_honor_bombdefused", "1");
	cvarRescueHostage = register_cvar("cod_honor_rescuehostage", "1");
	cvarKillHostage = register_cvar("cod_honor_killhostage", "4");
	
	register_event("DeathMsg", "EnemyKilled", "a");
	
	register_logevent("HostageRescued", 3, "1=triggered", "2=Rescued_A_Hostage");
	register_logevent("HostageKilled", 3, "1=triggered", "2=Killed_A_Hostage");
	
	register_message(SVC_INTERMISSION, "MsgIntermission");
	
	iMaxPlayers = get_maxplayers();
}

public plugin_cfg()
{
	iHonorMinPlayers = get_pcvar_num(cvarMinPlayers);
	iHonor[KILL] = get_pcvar_num(cvarKill);
	iHonor[KILLHS] = get_pcvar_num(cvarKillHS);
	iHonor[PLANTED] = get_pcvar_num(cvarBombPlated);
	iHonor[DEFUSED] = get_pcvar_num(cvarBombDefused);
	iHonor[RESCUEHOST] = get_pcvar_num(cvarRescueHostage);
	iHonor[KILLHOST] = get_pcvar_num(cvarKillHostage);
	
	if(get_pcvar_num(cvarSaveType))
	{
		gVault = nvault_open("cod_honor");
	
		if(gVault == INVALID_HANDLE)
			set_fail_state("Nie mozna otworzyc pliku cod_honor.vault");
	}
	else
		SqlInit();
}

public plugin_natives()
{
	register_native("cod_get_user_honor", "_cod_get_user_honor");
	register_native("cod_set_user_honor", "_cod_get_user_honor");
}

public plugin_end()
	get_pcvar_num(cvarSaveType) ? nvault_close(gVault) : SQL_FreeHandle(hSqlHook);

public client_putinserver(id)
{
	iPlayerHonor[id] = 0;
	
	Rem(id, iLoaded);

	get_user_name(id, szPlayer[id], charsmax(szPlayer));
	
	LoadHonor(id);
}

public client_disconnect(id)
	SaveHonor(id);

public EnemyKilled()
{
	if(get_playersnum() < iHonorMinPlayers)
		return PLUGIN_CONTINUE;

	new iKiller = read_data(1);
	new iVictim = read_data(2);
	new iHS = read_data(3);
	
	if(!is_user_alive(iKiller) || get_user_team(iKiller) == get_user_team(iVictim))
		return PLUGIN_CONTINUE;
		
	iPlayerHonor[iKiller] += cod_get_user_vip(iKiller) ? iHonor[KILL]*2 : iHonor[KILL];
	
	if(iHS)	iPlayerHonor[iKiller] += cod_get_user_vip(iKiller) ? iHonor[KILLHS]*2 : iHonor[KILLHS];
	
	SaveHonor(iKiller);
	
	return PLUGIN_CONTINUE;
}

public bomb_planted(id)
{
	if(get_playersnum() < iHonorMinPlayers)
		return PLUGIN_CONTINUE;

	iPlayerHonor[id] += cod_get_user_vip(id) ? iHonor[PLANTED]*2 : iHonor[PLANTED];

	SaveHonor(id);
	
	return PLUGIN_CONTINUE;
}

public bomb_defused(id)
{
	if(get_playersnum() < iHonorMinPlayers)
		return PLUGIN_CONTINUE;

	iPlayerHonor[id] += cod_get_user_vip(id) ? iHonor[DEFUSED]*2 : iHonor[DEFUSED];

	SaveHonor(id);
	
	return PLUGIN_CONTINUE;
}

public HostageRescued()
{
	if(get_playersnum() < iHonorMinPlayers)
		return PLUGIN_CONTINUE;

	new szLogUser[128], szName[32];
	
	read_logargv(0, szLogUser, charsmax(szLogUser));
	parse_loguser(szLogUser, szName, charsmax(szName));
	
	new id = get_user_index(szName);
	
	iPlayerHonor[id] += cod_get_user_vip(id) ? iHonor[RESCUEHOST]*2 : iHonor[RESCUEHOST];

	SaveHonor(id);
	
	return PLUGIN_CONTINUE;
} 

public HostageKilled() 
{
	if(get_playersnum() < iHonorMinPlayers)
		return PLUGIN_CONTINUE;
	
	new szLogUser[128], szName[32];
	
	read_logargv(0, szLogUser, charsmax(szLogUser));
	parse_loguser(szLogUser, szName, charsmax(szName));
	
	new id = get_user_index(szName);
	
	iPlayerHonor[id] -= cod_get_user_vip(id) ? iHonor[KILLHOST]/2 : iHonor[KILLHOST];

	SaveHonor(id);
	
	return PLUGIN_CONTINUE;
}

public MsgIntermission() 
{
	new szPlayers[32], id, iNum;
	get_players(szPlayers, iNum, "h");
	
	if(!iNum)
		return PLUGIN_CONTINUE;
		
	for (new i = 0; i < iNum; i++)
	{
		id = szPlayers[i];
		
		if(!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id))
			continue;
		
		SaveHonor(id, 1);
	}

	return PLUGIN_CONTINUE;
}

public SqlInit()
{
	new szData[4][64];
	
	get_cvar_string("cod_sql_host", szData[0], charsmax(szData)); 
	get_cvar_string("cod_sql_user", szData[1], charsmax(szData)); 
	get_cvar_string("cod_sql_pass", szData[2], charsmax(szData)); 
	get_cvar_string("cod_sql_db", szData[3], charsmax(szData));  
	
	hSqlHook = SQL_MakeDbTuple(szData[0], szData[1], szData[2], szData[3]);

	new iError, szError[128];
	new Handle:hConnection = SQL_Connect(hSqlHook, iError, szError, charsmax(szError));
	
	if(iError)
	{
		log_to_file("addons/amxmodx/logs/password.log", "Error: %s", szError);
		return;
	}
	
	new szTemp[128], Handle:hQuery = SQL_PrepareQuery(hConnection, szTemp);
	
	formatex(szTemp, charsmax(szTemp), "CREATE TABLE IF NOT EXISTS `cod_honor` (name VARCHAR(35), honor INT(11), PRIMARY KEY(name));");
	
	SQL_Execute(hQuery);
	SQL_FreeHandle(hQuery);
	SQL_FreeHandle(hConnection);
}

public LoadHonor(id)
{
	if(!is_user_connected(id))
		return;

	if(get_pcvar_num(cvarSaveType))
	{
		new szVaultKey[64], szVaultData[64];
	
		formatex(szVaultKey, charsmax(szVaultKey), "%s-cod_honor", szPlayer[id]);
	
		if(nvault_get(gVault, szVaultKey, szVaultData, charsmax(szVaultData)))
		{
			new szTempHonor[16];
			parse(szVaultData, szTempHonor, charsmax(szTempHonor));
	
			iPlayerHonor[id] = str_to_num(szTempHonor);
		}
		
		Set(id, iLoaded);
	}
	else
	{
		new szTemp[128], szName[33], szData[1];
		
		szData[0] = id;
		
		mysql_escape_string(szName, szPlayer[id], charsmax(szPlayer));
	
		formatex(szTemp, charsmax(szTemp), "SELECT * FROM `cod_honor` WHERE name = '%s'", szName);
		SQL_ThreadQuery(hSqlHook, "LoadHonor_Handle", szTemp, szData, 1);
	}
} 

public LoadHonor_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iSize)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_to_file("addons/amxmodx/logs/cod_honor.log", "<Query> Error: %s", szError);
		return;
	}
	
	new id = szData[0];
	
	if(!is_user_connected(id))
		return;
	
	if(SQL_MoreResults(hQuery))
		iPlayerHonor[id] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "honor"));
	else
	{
		new szTemp[128];
		
		formatex(szTemp, charsmax(szTemp), "INSERT INTO `cod_honor` VALUES ('%s', '0')", szPlayer[id]);
		
		SQL_ThreadQuery(hSqlHook, "Ignore_Handle", szTemp);
	}
	
	Set(id, iLoaded);
}

SaveHonor(id, end = 0)
{
	if(!Get(id, iLoaded))
		return;

	if(get_pcvar_num(cvarSaveType))
	{
		new szVaultKey[64], szVaultData[64];
	
		formatex(szVaultKey, charsmax(szVaultKey), "%s-cod_honor", szPlayer[id]);
		formatex(szVaultData, charsmax(szVaultData), "%d", iPlayerHonor[id]);
	
		nvault_set(gVault, szVaultKey, szVaultData);
	}
	else
	{
		new szTemp[128], szName[33];
		
		mysql_escape_string(szName, szPlayer[id], charsmax(szPlayer));
		
		formatex(szTemp, charsmax(szTemp), "UPDATE `cod_honor` SET honor = '%i' WHERE name = '%s'", iPlayerHonor[id], szName);
		
		switch(end)
		{
			case 0: SQL_ThreadQuery(hSqlHook, "Ignore_Handle", szTemp);
			case 1:
			{
				new szError[128], iError, Handle:hSqlConnection, Handle:hQuery;
			
				hSqlConnection = SQL_Connect(hSqlHook, iError, szError, charsmax(szError));

				if(!hSqlConnection)
				{
					log_to_file("addons/amxmodx/logs/cod_honor.txt", "Save - Could not connect to SQL database.  [%d] %s", szError, szError);
				
					SQL_FreeHandle(hSqlConnection);
				
					return;
				}
			
				hQuery = SQL_PrepareQuery(hSqlConnection, szTemp);
			
				if(!SQL_Execute(hQuery))
				{
					iError = SQL_QueryError(hQuery, szError, charsmax(szError));
				
					log_to_file("addons/amxmodx/logs/cod_honor.txt", "Save Query Nonthreaded failed. [%d] %s", iError, szError);
				
					SQL_FreeHandle(hQuery);
					SQL_FreeHandle(hSqlConnection);
				
					return;
				}
	
				SQL_FreeHandle(hQuery);
				SQL_FreeHandle(hSqlConnection);
			}
		}
	}
	
	if(end) Rem(id, iLoaded);
}

public Ignore_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iSize)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_to_file("addons/amxmodx/logs/cod_honor.log", "Could not connect to SQL database.  [%d] %s", iError, szError);
		return;
	}
}

stock mysql_escape_string(const szSource[], szDest[], iLen)
{
	copy(szDest, iLen, szSource);
	replace_all(szDest, iLen, "\\", "\\\\");
	replace_all(szDest, iLen, "\0", "\\0");
	replace_all(szDest, iLen, "\n", "\\n");
	replace_all(szDest, iLen, "\r", "\\r");
	replace_all(szDest, iLen, "\x1a", "\Z");
	replace_all(szDest, iLen, "'", "\'");
	replace_all(szDest, iLen, "`", "\`");
	replace_all(szDest, iLen, "^"", "\^"");
}

public _cod_get_user_honor(iPlugin, iParams)
{
	if(iParams != 1)
		return PLUGIN_CONTINUE;
		
	new id = get_param(1);
	
	if(!is_user_player(id))
		return PLUGIN_CONTINUE;
	
	return iPlayerHonor[id];
}

public _cod_set_user_honor(iPlugin, iParams)
{
	if(iParams != 1)
		return PLUGIN_CONTINUE;
		
	new id = get_param(1);
	
	if(!is_user_player(id))
		return PLUGIN_CONTINUE;
	
	iPlayerHonor[id] = get_param(2) > 0 ? get_param(2) : 0;
	
	SaveHonor(id);
	
	return PLUGIN_CONTINUE;
}