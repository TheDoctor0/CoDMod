public sql_connect()
{
	new Host[32], User[32], Pass[32], DB[32]
	get_cvar_string("amx_dr_rangi_host", Host, 31)
	get_cvar_string("amx_dr_rangi_user", User, 31)
	get_cvar_string("amx_dr_rangi_pass", Pass, 31)
	get_cvar_string("amx_dr_rangi_db", DB, 31)
	g_SqlTuple = SQL_MakeDbTuple(Host,User,Pass,DB)
	
	new error, szError[128]
	new Handle:hConn = SQL_Connect(g_SqlTuple,error,szError, 127)
	
	if(error)
		set_fail_state("Plugin can't connect with database !")
	
	new Handle:Queries = SQL_PrepareQuery(hConn,"CREATE TABLE IF NOT EXISTS `Deathrun_Rangi` (name VARCHAR(64) NOT NULL, skoki INT(10) NOT NULL DEFAULT 0, ranga VARCHAR(64) NOT NULL, lvl INT(2) NOT NULL DEFAULT 0, msg INT(1) NOT NULL DEFAULT 0, msg1 INT(1) NOT NULL DEFAULT 0, PRIMARY KEY(name))")
	
	SQL_Execute(Queries)
	SQL_FreeHandle(Queries)
	SQL_FreeHandle(hConn)
}

public sql_load(id)
{
	new szTemp[512],data[1]
	data[0] = id
	formatex(szTemp,charsmax(szTemp),"SELECT * FROM `Deathrun_Rangi` WHERE `name` = '%s'",nick_gracza[id])
	SQL_ThreadQuery(g_SqlTuple,"add_client",szTemp, data, sizeof(data))
}

public add_client(failstate, Handle:query, error[],errcode, data[], datasize)
{
	if(failstate != TQUERY_SUCCESS){
		log_amx("<Query> Error: %s", error)
		return;
	}
	new id = data[0]
	if(!is_user_connected(id) && !is_user_connecting(id))
		return;
	
	if(SQL_NumRows(query))
	{
		stats[id][skoki] = SQL_ReadResult(query, SQL_FieldNameToNum(query,"skoki"))
		SQL_ReadResult(query,SQL_FieldNameToNum(query,"ranga"),stats[id][ranga],63)
		lvl[id] = SQL_ReadResult(query, SQL_FieldNameToNum(query,"lvl"))
		msg[0][id] = SQL_ReadResult(query, SQL_FieldNameToNum(query,"msg"))
		msg[1][id] = SQL_ReadResult(query, SQL_FieldNameToNum(query,"msg1"))
		LoadData[id] = true
	} 
	else
	{
		new szTemp[512]
		formatex(szTemp,charsmax(szTemp),"INSERT INTO `Deathrun_Rangi` (`name`,`skoki`,`ranga`,`lvl`,`msg`,`msg1`) VALUES ('%s','%d','%s','%d','%d','%d')",nick_gracza[id],stats[id][skoki],stats[id][ranga],lvl[id],msg[0][id],msg[1][id])
		SQL_ThreadQuery(g_SqlTuple,"IgnoreHandleInsert",szTemp,data, 1)
		LoadData[id] = true
	}
}
public sql_save(id)
{
	if(!LoadData[id])
	{
		sql_load(id)
		return PLUGIN_HANDLED
	}
	
	new szTemp[512]
	formatex(szTemp,charsmax(szTemp),"UPDATE `Deathrun_Rangi` SET `ranga` = '%s',`skoki` = '%d',`lvl` = '%d',`msg` = '%d',`msg1` = '%d' WHERE `name` = '%s'",stats[id][ranga],stats[id][skoki],lvl[id],msg[0][id],msg[1][id],nick_gracza[id])
	SQL_ThreadQuery(g_SqlTuple,"IgnoreHandleSave",szTemp)
	
	return PLUGIN_CONTINUE
}
public IgnoreHandleInsert(failstate, Handle:query, error[], errnum, data[], size){
	if(failstate != TQUERY_SUCCESS){
		log_amx("<Query> Error: %s", error)
		return;
	}
	LoadData[data[0]] = true
}
public IgnoreHandleSave(failstate, Handle:query, error[], errnum, data[], size){
	if(failstate != TQUERY_SUCCESS){
		log_amx("<Query> Error: %s", error)
		return;
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
