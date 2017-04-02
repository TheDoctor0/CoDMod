#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <sqlx>


stock SQL_PrepareString(const szQuery[], szOutPut[], size){
	copy(szOutPut, size, szQuery);
	replace_all(szOutPut, size, "'", "\'");
	replace_all(szOutPut,size, "`", "\`");	
	replace_all(szOutPut,size, "\\", "\\\\");	
}

SQLx_Init()<mysql>{
	new szHost[32], szUser[32], szPass[32], szDB[32];
	get_cvar_string("amx_drstats_host", szHost, 31);
	get_cvar_string("amx_drstats_user", szUser, 31);
	get_cvar_string("amx_drstats_pass", szPass, 31);
	get_cvar_string("amx_drstats_db", szDB, 31);
	
	gTuple = SQL_MakeDbTuple(szHost, szUser, szPass, szDB);
	
	if(gTuple == Empty_Handle){
		set_fail_state("Cant create connection tuple");
	}
	
	new iErr, szError[32];
	new Handle:link = SQL_Connect(gTuple, iErr, szError, 31);
	if(link == Empty_Handle){
		log_amx("Error (%d): %s", iErr, szError);
		set_fail_state("Cant connect to database");
	}
	
	new Handle:query;
	query = SQL_PrepareQuery(link, 
		"CREATE TABLE IF NOT EXISTS `runners`( \
			id 		INT(11) 	UNSIGNED 	AUTO_INCREMENT,\
			steamid		VARCHAR(32) 	NOT NULL, \
			nickname	VARCHAR(32) 	NOT NULL, \
			ip		VARCHAR(32) 	NOT NULL, \
			PRIMARY KEY(id) \
		)");
	SQL_Execute(query);
	SQL_FreeHandle(query);
	
	query = SQL_PrepareQuery(link, 
		"ALTER TABLE `runners` \
		ADD 	nationality	VARCHAR(3) 	NULL");
		
	SQL_Execute(query);
	SQL_FreeHandle(query);
	
	query = SQL_PrepareQuery(link, 
		"CREATE TABLE IF NOT EXISTS `maps`( \
			mid 		INT(11) 	UNSIGNED 	AUTO_INCREMENT,\
			mapname		VARCHAR(64) 	NOT NULL	UNIQUE, \
			games		INT(11) 	NOT NULL, 	\
			finishX		INT(11) 	NOT NULL	DEFAULT 0, \
			finishY		INT(11) 	NOT NULL 	DEFAULT 0, \
			finishZ		INT(11) 	NOT NULL 	DEFAULT 0, \
			PRIMARY KEY(mid) \
		)");
	SQL_Execute(query);
	SQL_FreeHandle(query);
	
	query = SQL_PrepareQuery(link, 
		"CREATE TABLE IF NOT EXISTS `results`( \
			id		INT(11)		UNSIGNED, \
			mid 		INT(11) 	UNSIGNED, \
			besttime	INT(11) 	NOT NULL, \
			games		INT(11) 	NOT NULL, \
			playedtime	INT(11)		NOT NULL, 	\
			deaths		INT(11)		NOT NULL, 	\
			FOREIGN KEY(id) REFERENCES `runners`(id) ON DELETE CASCADE, \
			FOREIGN KEY(mid) REFERENCES `maps`(mid) ON DELETE CASCADE, \
			PRIMARY KEY(id, mid) \
		)");
	SQL_Execute(query);
	SQL_FreeHandle(query);
	
	query = SQL_PrepareQuery(link, 
		"ALTER TABLE `results` \
		ADD 	recorddate	DATETIME	NULL");
		
	SQL_Execute(query);
	SQL_FreeHandle(query);
	
	
	SQL_FreeHandle(link);
	
	get_mapname(gszMapname, charsmax(gszMapname));
	formatex(gszQuery, charsmax(gszQuery), "INSERT INTO `maps`(mid, mapname, games) VALUES (0, '%s', 1) ON DUPLICATE KEY UPDATE games = games + 1", gszMapname);
	SQL_ThreadQuery(gTuple, "handleUpdateMap", gszQuery);
}
public handleUpdateMap(failstate, Handle:query, error[], errnum, data[], size)<mysql>{
	if(failstate != TQUERY_SUCCESS){
		log_amx("SQL Insert error: %s",error);
		return;
	}
	formatex(gszQuery, charsmax(gszQuery), "SELECT mid, games, finishX, finishY, finishZ FROM `maps` WHERE mapname='%s'", gszMapname);
	SQL_ThreadQuery(gTuple, "handleSelectMap", gszQuery);
}
public handleSelectMap(failstate, Handle:query, error[], errnum, data[], size)<mysql>{
	if(failstate != TQUERY_SUCCESS){
		log_amx("SQL Insert error: %s",error);
		return;
	}
	gMid = SQL_ReadResult(query, 0);
	giGames = SQL_ReadResult(query, 1);
	
	createFinishI( 0, SQL_ReadResult(query, 2),  SQL_ReadResult(query, 3),  SQL_ReadResult(query, 4));

	for(new i=1;i<33; i++)
		if(is_user_connected(i))
			client_putinserver(i);
			
	loadNshowTop15(0);
	
	
	if(gszTop15Redirect[0]){
		new szTemp[15];
		formatex(szTemp, 14, "mid=%d", gMid);
		add(gszTop15Redirect, charsmax(gszTop15Redirect), szTemp);
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
