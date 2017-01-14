#include <amxmodx>
#include <cod>
#include <csx>
#include <sqlx>
#include <fakemeta>
#include <hamsandwich>
#include <unixtime>

#define PLUGIN "CoD Stats"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define Set(%2,%1) (%1 |= (1<<(%2&31)))
#define Rem(%2,%1) (%1 &= ~(1 <<(%2&31)))
#define Get(%2,%1) (%1 & (1<<(%2&31)))

#define is_user_player(%1) (1 <= %1 <= iMaxPlayers)

#define TASK_TIME 9054

enum Stats
{
	Name[64],
	Admin,
	Time,
	FirstVisit,
	LastVisit,
	Kills,
	BestStats,
	BestKills,
	BestDeaths,
	BestHS,
	CurrentStats,
	CurrentKills,
	CurrentDeaths,
	CurrentHS,
};

new const szCommandMenu[][] = { "say /statsmenu", "say_team /statsmenu", "say /menustaty", "say_team /menustaty", "menustaty" };
new const szCommandTime[][] = { "say /time", "say_team /time", "say /czas", "say_team /czas", "czas" };
new const szCommandAdminTime[][] = { "say /timeadmin", "say_team /timeadmin", "say /tadmin", "say_team /tadmin", "say /czasadmin", "say_team /czasadmin", "say /cadmin", "say_team /cadmin", "czasadmin" };
new const szCommandTopTime[][] = { "say /ttop15", "say_team /ttop15", "say /toptime", "say_team /toptime", "say /ctop15", "say_team /ctop15", "say /topczas", "say_team /topczas", "topczas" };
new const szCommandStats[][] = { "say /beststats", "say_team /beststats", "say /bstats", "say_team /bstats", "say /najlepszestaty", "say_team /najlepszestaty", "say /nstaty", "say_team /nstaty", "najlepszestaty" };
new const szCommandTopStats[][] = { "say /stop15", "say_team /stop15", "say /topstats", "say_team /topstats", "say /topstaty", "say_team /topstaty", "topstaty" };

new szBuffer[2048], gPlayer[MAX_PLAYERS + 1][Stats], iLoaded, iVisit, iMaxPlayers, Handle:hSqlHook;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_cvar("cod_sql_host", "sql.pukawka.pl", FCVAR_SPONLY | FCVAR_PROTECTED);
	register_cvar("cod_sql_user", "262947", FCVAR_SPONLY | FCVAR_PROTECTED);
	register_cvar("cod_sql_pass", "A$*C*!2]XhfysF!", FCVAR_SPONLY | FCVAR_PROTECTED);
	register_cvar("cod_sql_database", "262947_cod", FCVAR_SPONLY | FCVAR_PROTECTED);
	
	for(new i; i < sizeof szCommandMenu; i++)
		register_clcmd(szCommandMenu[i], "StatsMenu");
		
	for(new i; i < sizeof szCommandTime; i++)
		register_clcmd(szCommandTime[i], "CmdTime");

	for(new i; i < sizeof szCommandTopTime; i++)
		register_clcmd(szCommandTopTime[i], "CmdTimeTop");
	
	for(new i; i < sizeof szCommandStats; i++)
		register_clcmd(szCommandStats[i], "CmdStats");
		
	for(new i; i < sizeof szCommandTopStats; i++)
		register_clcmd(szCommandTopStats[i], "CmdTopStats");
		
	for(new i; i < sizeof szCommandAdminTime; i++)
		register_clcmd(szCommandAdminTime[i], "CmdTimeAdmin");

	RegisterHam(Ham_Spawn , "player", "Spawn", 1);
	
	register_event("DeathMsg", "DeathMsg", "a");
	register_event("TextMsg", "HostagesRescued", "a", "2&#All_Hostages_R");
	
	register_message(SVC_INTERMISSION, "MsgIntermission");
	register_message(get_user_msgid("SayText"), "HandleSayText");
	
	iMaxPlayers = get_maxplayers();
}

public plugin_cfg()
	SqlInit();
	
public plugin_end()
	SQL_FreeHandle(hSqlHook);
	
public plugin_natives()
{
	register_native("cod_stats_add_kill", "_cod_stats_add_kill");
	
	register_native("cod_get_user_time", "_cod_get_user_time");
}

public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
		return;

	get_user_name(id, gPlayer[id][Name], charsmax(gPlayer));
	
	Rem(id, iLoaded);
	Rem(id, iVisit);
	
	gPlayer[id][Kills] = 0;
	gPlayer[id][Time] = 0;
	gPlayer[id][FirstVisit] = 0;
	gPlayer[id][LastVisit] = 0;
	gPlayer[id][CurrentKills] = 0;
	gPlayer[id][CurrentDeaths] = 0;
	gPlayer[id][CurrentHS] = 0;
	gPlayer[id][CurrentKills] = 0;
	gPlayer[id][CurrentDeaths] = 0;
	gPlayer[id][CurrentHS] = 0;
	gPlayer[id][BestStats] = 0;
	
	LoadStats(id);
}

public client_authorized(id)
	gPlayer[id][Admin] = get_user_flags(id) & ADMIN_BAN ? 1 : 0;
	
public client_disconnect(id)
	SaveStats(id);
	
public StatsMenu(id)
{
	new menu = menu_create("\wMenu \rStatow", "StatsMenu_Handler");
 
	menu_additem(menu, "\wMoj \rCzas \y(/czas)", "1");
	menu_additem(menu, "\wCzas \rAdminow \y(/adminczas)", "2");
	menu_additem(menu, "\wTop \rCzasu \y(/ctop15)", "3");
	menu_additem(menu, "\wNajlepsze \rStaty \y(/nstaty)", "4");
	menu_additem(menu, "\wTop \rStatow \y(/stop15)", "5");
    
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	
	menu_display(id, menu, 0);
}  
 
public StatsMenu_Handler(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;

	client_cmd(id, "spk CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	new szData[4], iAccess, iCallback;
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), _, _, iCallback);
    
	new iKey = str_to_num(szData);
    
	switch(iKey)
    { 
		case 1: client_cmd(id, "czas"); 
		case 2: client_cmd(id, "czasadmin"); 
		case 3: client_cmd(id, "topczas"); 
		case 4: client_cmd(id, "najlepszestaty"); 
		case 5: client_cmd(id, "topstaty"); 
	}
	
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
} 

public CmdTime(id)
{
	new szTemp[256], szName[33], szData[1];
	
	szData[0] = id;
	
	mysql_escape_string(szName, gPlayer[id][Name], charsmax(gPlayer));
	
	formatex(szTemp, charsmax(szTemp), "SELECT rank, count FROM (SELECT COUNT(*) as count FROM `stats_system`) a CROSS JOIN (SELECT COUNT(*) as rank FROM `stats_system` WHERE `time` > '%i' ORDER BY `time` DESC) b", gPlayer[id][Time]);
	SQL_ThreadQuery(hSqlHook, "ShowTime", szTemp, szData, charsmax(szData));
}

public ShowTime(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState) 
	{
		log_to_file("addons/amxmodx/logs/cod_stats.log", "SQL Error: %s (%d)", szError, iError);
		return PLUGIN_CONTINUE;
	}
	
	new id = szData[0];
	new iRank = SQL_ReadResult(hQuery, 0) + 1;
	new iPlayers = SQL_ReadResult(hQuery, 1);
	new iSeconds = (gPlayer[id][Time] + get_user_time(id)), iMinutes, iHours;
	
	while(iSeconds >= 60)
	{
		iSeconds -= 60;
		iMinutes++;
	}
	while(iMinutes >= 60)
	{
		iMinutes -= 60;
		iHours++;
	}
	
	cod_print_chat(id, DontChange, "Spedziles na serwerze lacznie^x04 %i h %i min %i s^x01.", iHours, iMinutes, iSeconds);
	cod_print_chat(id, DontChange, "Zajmujesz^x04 %i/%i^x01 miejsce w rankingu czasu gry.", iRank, iPlayers);
	
	return PLUGIN_CONTINUE;
}

public CmdTimeTop(id)
{
	new szTemp[256], szData[1];
	
	szData[0] = id;
	
	format(szTemp, charsmax(szTemp), "SELECT name, time FROM `stats_system` ORDER BY time DESC LIMIT 15");
	SQL_ThreadQuery(hSqlHook, "ShowTimeTop", szTemp, szData, charsmax(szData));
}

public ShowTimeTop(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState) 
	{
		log_to_file("addons/amxmodx/logs/cod_stats.log", "SQL Error: %s (%d)", szError, iError);
		return PLUGIN_CONTINUE;
	}
	
	new id = szData[0];
	
	static iLen, iPlace = 0;
	
	iLen = format(szBuffer, charsmax(szBuffer), "<body bgcolor=#000000><font color=#FFB000><pre>");
	iLen += format(szBuffer[iLen], charsmax(szBuffer) - iLen, "%1s %-22.22s %13s^n", "#", "Nick", "Czas Gry");
	
	while(SQL_MoreResults(hQuery))
	{
		iPlace++;
		
		static szName[33], iSeconds = 0, iMinutes = 0, iHours = 0;
		
		SQL_ReadResult(hQuery, 0, szName, charsmax(szName));
		iSeconds = SQL_ReadResult(hQuery, 1);
		
		replace_all(szName, charsmax(szName), "<", "");
		replace_all(szName, charsmax(szName), ">", "");
		
		while(iSeconds >= 60)
		{
			iSeconds -= 60;
			iMinutes++;
		}
		while(iMinutes >= 60)
		{
			iMinutes -= 60;
			iHours++;
		}
		
		if(iPlace >= 10)
			iLen += format(szBuffer[iLen], charsmax(szBuffer) - iLen, "%1i %-22.22s %1ih %1imin %1is^n", iPlace, szName, iHours, iMinutes, iSeconds);
		else
			iLen += format(szBuffer[iLen], charsmax(szBuffer) - iLen, "%1i %-22.22s %2ih %1imin %1is^n", iPlace, szName, iHours, iMinutes, iSeconds);
		
		SQL_NextRow(hQuery);
	}
	
	show_motd(id, szBuffer, "Top15 Czasu Gry");
	
	return PLUGIN_HANDLED;
}

public CmdStats(id)
{
	new szTemp[256], szName[33], szData[1];
	
	szData[0] = id;
	
	mysql_escape_string(szName, gPlayer[id][Name], charsmax(gPlayer));
	
	gPlayer[id][CurrentStats] = gPlayer[id][CurrentKills]*2 + gPlayer[id][CurrentHS] - gPlayer[id][CurrentDeaths]*2;
	
	if(gPlayer[id][CurrentStats] > gPlayer[id][BestStats])
		formatex(szTemp, charsmax(szTemp), "SELECT rank, count FROM (SELECT COUNT(*) as count FROM `stats_system`) a CROSS JOIN (SELECT COUNT(*) as rank FROM `stats_system` WHERE `beststats` > '%i' ORDER BY `beststats` DESC) b", gPlayer[id][BestStats]);
	else
		formatex(szTemp, charsmax(szTemp), "SELECT rank, count FROM (SELECT COUNT(*) as count FROM `stats_system`) a CROSS JOIN (SELECT COUNT(*) as rank FROM `stats_system` WHERE `beststats` > '%i' ORDER BY `beststats` DESC) b", gPlayer[id][CurrentStats]);
	
	SQL_ThreadQuery(hSqlHook, "ShowStats", szTemp, szData, charsmax(szData));
}

public ShowStats(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState) 
	{
		log_to_file("addons/amxmodx/logs/cod_stats.log", "SQL Error: %s (%d)", szError, iError);
		return PLUGIN_CONTINUE;
	}
	
	new id = szData[0];
	new iRank = SQL_ReadResult(hQuery, 0);
	new iPlayers = SQL_ReadResult(hQuery, 1);
	
	if(gPlayer[id][CurrentStats] > gPlayer[id][BestStats])
		cod_print_chat(id, DontChange, "Twoje najlepsze staty to^x04 %i^x01 zabic (w tym^x04 %i^x01 z HS) i^x04 %i^x01 zgonow^x01.", gPlayer[id][CurrentKills], gPlayer[id][CurrentHS], gPlayer[id][CurrentDeaths]);
	else
		cod_print_chat(id, DontChange, "Twoje najlepsze staty to^x04 %i^x01 zabic (w tym^x04 %i^x01 z HS) i^x04 %i^x01 zgonow^x01.", gPlayer[id][BestKills], gPlayer[id][BestHS], gPlayer[id][BestDeaths]);
		
	cod_print_chat(id, DontChange, "Zajmujesz^x04 %i/%i^x01 miejsce w rankingu najlepszych statystyk.", iRank, iPlayers);
	
	return PLUGIN_CONTINUE;
}

public CmdTopStats(id)
{
	new szTemp[512], szData[1];
	
	szData[0] = id;
	
	format(szTemp, charsmax(szTemp), "SELECT name, bestkills, besths, bestdeaths FROM `stats_system` ORDER BY beststats DESC LIMIT 15");
	SQL_ThreadQuery(hSqlHook, "ShowStatsTop", szTemp, szData, charsmax(szData));
}

public ShowStatsTop(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState) 
	{
		log_to_file("addons/amxmodx/logs/cod_stats.log", "SQL Error: %s (%d)", szError, iError);
		return PLUGIN_CONTINUE;
	}
	
	new id = szData[0];
	
	static iLen, iPlace = 0;
	
	iLen = format(szBuffer, charsmax(szBuffer), "<body bgcolor=#000000><font color=#FFB000><pre>");
	iLen += format(szBuffer[iLen], charsmax(szBuffer) - iLen, "%1s %-22.22s %19s %4s^n", "#", "Nick", "Zabojstwa", "Zgony");
	
	while(SQL_MoreResults(hQuery))
	{
		iPlace++;
		
		static szName[33], iKills, iHS, iDeaths;
		
		SQL_ReadResult(hQuery, 0, szName, charsmax(szName));
		iKills = SQL_ReadResult(hQuery, 1);
		iHS = SQL_ReadResult(hQuery, 2);
		iDeaths = SQL_ReadResult(hQuery, 3);
		
		replace_all(szName, charsmax(szName), "<", "");
		replace_all(szName, charsmax(szName), ">", "");
		
		if(iPlace >= 10)
			iLen += format(szBuffer[iLen], charsmax(szBuffer) - iLen, "%1i %-22.22s %1d (%i HS) %12d^n", iPlace, szName, iKills, iHS, iDeaths);
		else
			iLen += format(szBuffer[iLen], charsmax(szBuffer) - iLen, "%1i %-22.22s %2d (%i HS) %12d^n", iPlace, szName, iKills, iHS, iDeaths);
		
		SQL_NextRow(hQuery);
	}
	
	show_motd(id, szBuffer, "Top15 Statystyk");
	
	return PLUGIN_CONTINUE;
}

public CmdTimeAdmin(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN))
		return;
		
	new szTemp[256], szData[1];
	
	szData[0] = id;
	
	format(szTemp, charsmax(szTemp), "SELECT name, time FROM `cod_stats` WHERE admin = '1' ORDER BY time DESC");
	SQL_ThreadQuery(hSqlHook, "ShowTimeAdmin", szTemp, szData, charsmax(szData));
}

public ShowTimeAdmin(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState) 
	{
		log_to_file("addons/amxmodx/logs/cod_stats.log", "SQL Error: %s (%d)", szError, iError);
		return PLUGIN_CONTINUE;
	}
	
	new id = szData[0];
	
	static iLen, iPlace = 0;
	
	iLen = format(szBuffer, charsmax(szBuffer), "<body bgcolor=#000000><font color=#FFB000><pre>");
	iLen += format(szBuffer[iLen], charsmax(szBuffer) - iLen, "%1s %-22.22s %13s^n", "#", "Nick", "Czas Gry");
	
	while(SQL_MoreResults(hQuery))
	{
		iPlace++;
		
		static szName[33], iSeconds = 0, iMinutes = 0, iHours = 0;
		
		SQL_ReadResult(hQuery, 0, szName, charsmax(szName));
		iSeconds = SQL_ReadResult(hQuery, 1);
		
		replace_all(szName, charsmax(szName), "<", "");
		replace_all(szName, charsmax(szName), ">", "");
		
		while(iSeconds >= 60)
		{
			iSeconds -= 60;
			iMinutes++;
		}
		while(iMinutes >= 60)
		{
			iMinutes -= 60;
			iHours++;
		}
		
		if(iPlace >= 10)
			iLen += format(szBuffer[iLen], charsmax(szBuffer) - iLen, "%1i %-22.22s %1ih %1imin %1is^n", iPlace, szName, iHours, iMinutes, iSeconds);
		else
			iLen += format(szBuffer[iLen], charsmax(szBuffer) - iLen, "%1i %-22.22s %2ih %1imin %1is^n", iPlace, szName, iHours, iMinutes, iSeconds);
		
		SQL_NextRow(hQuery);
	}
	
	show_motd(id, szBuffer, "Czas Gry Adminow");
	
	return PLUGIN_CONTINUE;
}

public CheckTime(id)
{
	id -= TASK_TIME;
	
	if(Get(id, iVisit))
		return;
	
	if(Get(id, iLoaded))
	{ 
		set_task(3.0, "CheckTime", id + TASK_TIME);
		return;
	}
	
	Set(id, iVisit);
	
	new iYear, Year, iMonth, Month, iDay, Day, iHour, iMinute, iSecond, iTime = get_systime();
	
	UnixToTime(iTime, iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_SERVER);
	
	cod_print_chat(id, DontChange, "Aktualnie jest godzina^x03 %02d:%02d:%02d (Data: %02d.%02d.%02d)^x01.", iHour, iMinute, iSecond, iDay, iMonth, iYear);
	
	if(gPlayer[id][FirstVisit] == gPlayer[id][LastVisit])
		cod_print_chat(id, DontChange, "To twoja^x03 pierwsza wizyta^x01 na serwerze. Zyczymy milej gry!" );
	else 
	{
		UnixToTime(gPlayer[id][LastVisit], Year, Month, Day, iHour, iMinute, iSecond, UT_TIMEZONE_SERVER);
		
		if(iYear == Year && iMonth == Month && iDay == Day)
			cod_print_chat(id, DontChange, "Twoja ostatnia wizyta miala miejsce^x04 dzisiaj^x01 o^x03 %02d:%02d:%02d^x01. Zyczymy milej gry!", iHour, iMinute, iSecond);
		else if(iYear == Year && iMonth == Month && (iDay - 1) == Day)
			cod_print_chat(id, DontChange, "Twoja ostatnia wizyta miala miejsce^x04 wczoraj^x01 o^x03 %02d:%02d:%02d^x01. Zyczymy milej gry!", iHour, iMinute, iSecond);
		else
			cod_print_chat(id, DontChange, "Twoja ostatnia wizyta:^x03 %02d:%02d:%02d (Data: %02d.%02d.%02d)^x01. Zyczymy milej gry!", iHour, iMinute, iSecond, Day, Month, Year);
	}
}

public Spawn(id)
{
	if(is_user_alive(id) && Get(id, iVisit))
		set_task(5.0, "CheckTime", id + TASK_TIME);
}

public DeathMsg()
{
	new iKiller = read_data(1);
	new iVictim = read_data(2);
	new iHeadShot = read_data(3);
	
	if(is_user_connected(iVictim))
		gPlayer[iVictim][CurrentDeaths]++;

	if(is_user_connected(iKiller) && iKiller != iVictim)
	{
		gPlayer[iKiller][CurrentKills]++;
		gPlayer[iKiller][Kills]++;
		
		if(iHeadShot)
			gPlayer[iKiller][CurrentHS]++;
	}
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
		
		SaveStats(id, 1);
	}
	return PLUGIN_CONTINUE;
}

public HandleSayText(msgId, msgDest, msgEnt)
{
	new id = get_msg_arg_int(1);
	
	if(is_user_connected(id))
	{
		new szTmp[150], szTmp2[170], szPrefix[16], iStats[8], iBody[8], iRank;
		
		get_msg_arg_string(2, szTmp, charsmax(szTmp));
		iRank = get_user_stats(id, iStats, iBody);
		
		if(iRank > 3)
			return PLUGIN_CONTINUE;
			
		switch(iRank)
		{
			case 1: formatex(szPrefix, charsmax(szPrefix), "^x04[TOP1]");
			case 2: formatex(szPrefix, charsmax(szPrefix), "^x04[TOP2]");
			case 3: formatex(szPrefix, charsmax(szPrefix), "^x04[TOP3]");
		}
		
		if(!equal(szTmp,"#Cstrike_Chat_All"))
		{
			add(szTmp2,charsmax(szTmp2), szPrefix);
			add(szTmp2,charsmax(szTmp2), "");
			add(szTmp2,charsmax(szTmp2), szTmp);
		}
		else
		{
			add(szTmp2,charsmax(szTmp2), szPrefix);
			add(szTmp2,charsmax(szTmp2), "^x03 %s1^x01 :  %s2");
		}
		set_msg_arg_string(2, szTmp2);
	}
	return PLUGIN_CONTINUE;
}

public bomb_explode(planter, defuser) 
	gPlayer[planter][Kills] += 3;

public bomb_defused(defuser)
	gPlayer[defuser][Kills] += 3;

public HostagesRescued()
	gPlayer[get_loguser_index()][Kills] += 3;
	
public SqlInit()
{
	new szHost[32], szUser[32], szPass[32], szDatabase[32], szTemp[512], szError[128], iError;
	
	get_cvar_string("cod_sql_host", szHost, charsmax(szHost));
	get_cvar_string("cod_sql_user", szUser, charsmax(szUser));
	get_cvar_string("cod_sql_pass", szPass, charsmax(szPass));
	get_cvar_string("cod_sql_database", szDatabase, charsmax(szDatabase));
	
	hSqlHook = SQL_MakeDbTuple(szHost, szUser, szPass, szDatabase);

	new Handle:hConnect = SQL_Connect(hSqlHook, iError, szError, charsmax(szError));
	
	if(iError)
	{
		log_to_file("addons/amxmodx/logs/cod_stats.log", "Error: %s", szError);
		return;
	}
	
	formatex(szTemp, charsmax(szTemp), "CREATE TABLE IF NOT EXISTS `cod_stats` (`name` varchar(32) NOT NULL, `admin` int(10) NOT NULL, `kills` int(10) NOT NULL, `time` int(10) NOT NULL, `firstvisit` int(10) NOT NULL, ");
	add(szTemp, charsmax(szTemp), "`lastvisit` int(10) NOT NULL, `bestkills` int(10) NOT NULL, `bestdeaths` int(10) NOT NULL, `besths` int(10) NOT NULL, `beststats` int(10) NOT NULL, PRIMARY KEY (`name`));");

	new Handle:hQuery = SQL_PrepareQuery(hConnect, szTemp);

	SQL_Execute(hQuery);
	
	SQL_FreeHandle(hQuery);
	SQL_FreeHandle(hConnect);
}

public LoadStats(id)
{
	if(!is_user_connected(id))
		return;

	new szTemp[128], szName[33], szData[1];

	szData[0] = id;

	mysql_escape_string(szName, gPlayer[id][Name], charsmax(gPlayer));
	
	formatex(szTemp, charsmax(szTemp), "SELECT * FROM `cod_stats` WHERE name = '%s'", szName);
	SQL_ThreadQuery(hSqlHook, "LoadStats_Handle", szTemp, szData, 1);
}

public LoadStats_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iSize)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_to_file("addons/amxmodx/logs/cod_stats.log", "<Query> Error: %s", szError);
		return;
	}

	new id = szData[0];
	
	if(SQL_NumRows(hQuery))
	{
		gPlayer[id][Kills] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "kills"));
		gPlayer[id][Time] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "time"));
		gPlayer[id][FirstVisit] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "firstvisit"));
		gPlayer[id][LastVisit] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "lastvisit"));
		gPlayer[id][BestStats] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "beststats"));
		gPlayer[id][BestKills] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "bestkills"));
		gPlayer[id][BestHS] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "besths"));
		gPlayer[id][BestDeaths] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "bestdeaths"));
	}
	else
	{
		new szTemp[256], iVisit = get_systime();
		
		formatex(szTemp, charsmax(szTemp), "INSERT IGNORE INTO `cod_stats` (`name`, `firstvisit`) VALUES ('%s', '%i');", gPlayer[id][Name], iVisit);
		
		SQL_ThreadQuery(hSqlHook, "Ignore_Handle", szTemp);
	}
	
	Set(id, iLoaded);
}

SaveStats(id, end = 0)
{
	if(Get(id, iLoaded))
		return;
		
	new szTemp[256], szBest[128], szName[33];

	gPlayer[id][CurrentStats] = gPlayer[id][CurrentKills]*2 + gPlayer[id][CurrentHS] - gPlayer[id][CurrentDeaths]*2;
	
	if(gPlayer[id][CurrentStats] > gPlayer[id][BestStats])
	{			
		formatex(szBest, charsmax(szBest), ", `bestkills` = %d, `besths` = %d, `bestdeaths` = %d, `beststats` = %d", 
		gPlayer[id][CurrentKills], gPlayer[id][CurrentHS], gPlayer[id][CurrentDeaths], gPlayer[id][CurrentStats]);
	}
	
	gPlayer[id][Time] += get_user_time(id);
	
	mysql_escape_string(szName, gPlayer[id][Name], charsmax(gPlayer));

	formatex(szTemp, charsmax(szTemp), "UPDATE `cod_stats` SET `admin` = %i, `kills` = %i, `time` = %i, `lastvisit` = %i%s WHERE name = '%s' AND `time` <= %i", 
	gPlayer[id][Admin], gPlayer[id][Kills], gPlayer[id][Time], get_systime(), szBest, szName, gPlayer[id][Time]);

	switch(end)
	{
		case 0: SQL_ThreadQuery(hSqlHook, "Ignore_Handle", szTemp);
		case 1:
		{
			new szError[128], iError, Handle:hSqlConnection, Handle:hQuery;
			
			hSqlConnection = SQL_Connect(hSqlHook, iError, szError, charsmax(szError));

			if(!hSqlConnection)
			{
				log_to_file("addons/amxmodx/logs/cod_stats.txt", "Save - Could not connect to SQL database.  [%d] %s", szError, szError);
				
				SQL_FreeHandle(hSqlConnection);
				
				return;
			}
			
			hQuery = SQL_PrepareQuery(hSqlConnection, szTemp);
			
			if(!SQL_Execute(hQuery))
			{
				iError = SQL_QueryError(hQuery, szError, charsmax(szError));
				
				log_to_file("addons/amxmodx/logs/cod_stats.txt", "Save Query Nonthreaded failed. [%d] %s", iError, szError);
				
				SQL_FreeHandle(hQuery);
				SQL_FreeHandle(hSqlConnection);
				
				return;
			}
	
			SQL_FreeHandle(hQuery);
			SQL_FreeHandle(hSqlConnection);
		}
	}

	Rem(id, iLoaded);
}

public Ignore_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iSize)
{
	if(iFailState == TQUERY_CONNECT_FAILED)
		log_to_file("addons/amxmodx/logs/cod_stats.txt", "Could not connect to SQL database. [%d] %s", iError, szError);
	else if(iFailState == TQUERY_QUERY_FAILED)
		log_to_file("addons/amxmodx/logs/cod_stats.txt", "Query failed. [%d] %s", iError, szError);
}

public _stats_add_kill(iPlugin, iParams)
{
	if(iParams != 1)
		return PLUGIN_CONTINUE;
		
	new id = get_param(1);
	
	if(!is_user_player(id))
		return PLUGIN_CONTINUE;
	
	gPlayer[id][CurrentKills]++;
	gPlayer[id][Kills]++;
	
	return PLUGIN_CONTINUE;
}

public _cod_get_user_time(id, szReturn[], iLen)
{
	new id = get_param(1);
	
	if(!is_user_player(id))
		return;

	new szTemp[64], iSeconds = (gPlayer[id][Time] + get_user_time(id)), iMinutes, iHours;
	
	while(iSeconds >= 60)
	{
		iSeconds -= 60;
		iMinutes++;
	}
	while(iMinutes >= 60)
	{
		iMinutes -= 60;
		iHours++;
	}
	
	param_convert(2);
	
	formatex(szTemp, charsmax(szTemp), "%i h %i min %i s", iHours, iMinutes, iSeconds);
	copy(szReturn, iLen, szTemp);
}

stock get_loguser_index()
{
	new szLogUser[80], szName[32];
	read_logargv(0, szLogUser, 79);
	parse_loguser(szLogUser, szName, 31);

	return get_user_index(szName);
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