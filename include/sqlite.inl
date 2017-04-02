#include <amxmodx>
#include <sqlx>

SQLx_Init()<sqlite>{
	SQL_SetAffinity("sqlite");
	
	new szDB[32];
	get_cvar_string("amx_drstats_db", szDB, 31);
	
	if(!file_exists(szDB)){
		new fp = fopen(szDB, "w");
		if(!fp){
			new szMsg[128];
			formatex(szMsg, 127, "%s file not found and cant be created. Do it mannualy", szDB);
			set_fail_state(szMsg);
		}
		fclose(fp);
	}
	
	gTuple = SQL_MakeDbTuple("", "", "", szDB, 0);
	
	SQL_ThreadQuery(gTuple, "handleCreateQuery", "PRAGMA integrity_check" );
	SQL_ThreadQuery(gTuple, "handleCreateQuery", "PRAGMA synchronous = 1" );
	
	if(gTuple == Empty_Handle){
		set_fail_state("Cant create connection tuple");
	}
	
	new iErr;
	static szError[128];
	new Handle:link = SQL_Connect(gTuple, iErr, szError, 127);
	if(link == Empty_Handle){
		log_amx("Error (%d): %s", iErr, szError);
		set_fail_state("Cant connect to database");
	}
	
	new Handle:query;
	query = SQL_PrepareQuery(link, 
		"CREATE TABLE IF NOT EXISTS `runners`( \
			id 		INTEGER		PRIMARY KEY,\
			steamid		TEXT 	NOT NULL, \
			nickname	TEXT 	NOT NULL, \
			ip		TEXT 	NOT NULL, \
			nationality	TEXT 	NULL \
		)");
	SQL_Execute(query);
	SQL_FreeHandle(query);
	
	query = SQL_PrepareQuery(link, 
		"CREATE TABLE IF NOT EXISTS `maps`( \
			mid 		INTEGER		PRIMARY KEY,\
			mapname		TEXT 		NOT NULL	UNIQUE, \
			games		INTEGER 	NOT NULL, 	\
			finishX		INTEGER 	NOT NULL	DEFAULT 0, \
			finishY		INTEGER 	NOT NULL 	DEFAULT 0, \
			finishZ		INTEGER 	NOT NULL 	DEFAULT 0 \
		)");
	SQL_Execute(query);
	
	SQL_FreeHandle(query);
	
	query = SQL_PrepareQuery(link, 
		"CREATE TABLE IF NOT EXISTS `results`( \
			id		INTEGER 	NOT NULL, \
			mid 		INTEGER 	NOT NULL, \
			besttime	INTEGER 	NOT NULL, \
			games		INTEGER 	NOT NULL, \
			playedtime	INTEGER 	NOT NULL, 	\
			deaths		INTEGER 	NOT NULL, 	\
			recorddate	DATETIME	NULL,	\
			FOREIGN KEY(id) REFERENCES `runners`(id), \
			FOREIGN KEY(mid) REFERENCES `maps`(mid), \
			PRIMARY KEY(id, mid) \
		)");
	SQL_Execute(query);
	SQL_FreeHandle(query);
	
	SQL_FreeHandle(link);
	
	get_mapname(gszMapname, charsmax(gszMapname));
	formatex(gszQuery, charsmax(gszQuery), "SELECT mid, games, finishX, finishY, finishZ FROM `maps` WHERE mapname='%s'", gszMapname);
	SQL_ThreadQuery(gTuple, "handleSelectMap", gszQuery);
}

public handleSelectMap(failstate, Handle:query, error[], errnum, data[], size)<sqlite>{
	if(failstate != TQUERY_SUCCESS){
		log_amx("SQL Insert error: %s",error);
		return;
	}
	
	if(SQL_NumRows(query) == 0){
		formatex(gszQuery, charsmax(gszQuery), "INSERT INTO `maps`(mapname, games) VALUES ('%s', 1)", gszMapname);
		SQL_ThreadQuery(gTuple, "handleUpdateMap", gszQuery);
		return;
	}
	
	gMid = SQL_ReadResult(query, 0);
	giGames = SQL_ReadResult(query, 1)+1;
	
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
	
	formatex(gszQuery, charsmax(gszQuery), "UPDATE `maps` SET games = games + 1 WHERE mid = %d", gMid);
	SQL_ThreadQuery(gTuple, "handleStandard", gszQuery);
}

public handleUpdateMap(failstate, Handle:query, error[], errnum, data[], size)<sqlite>{
	if(failstate != TQUERY_SUCCESS){
		log_amx("SQL Insert error: %s",error);
		return;
	}
	
	gMid = SQL_GetInsertId(query);
	giGames = 1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
