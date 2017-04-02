/*

	AMXBans, managing bans for Half-Life modifications
	Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
	
	Copyright (C) 2009, 2010  Thomas Kurz

*/

#if defined _check_flag_included
    #endinput
#endif
#define _check_flag_included


#include <amxmodx>
#include <amxmisc>
#include <sqlx>

check_flagged(id)
{
	if(g_being_flagged[id])
		return PLUGIN_HANDLED;
	
	new authid[35], ip[22], pquery[1024];
	get_user_authid(id, authid, charsmax(authid));
	get_user_ip(id, ip, charsmax(ip), 1);
	
	if(get_pcvar_num(pcvar_flagged_all))
		formatex(pquery, charsmax(pquery), "SELECT `fid`,`reason`,`created`,`length` FROM `%s%s` WHERE player_id='%s' OR player_ip='%s' ORDER BY `length` ASC", g_dbPrefix, tbl_flagged, authid, ip);
	else
		formatex(pquery, charsmax(pquery), "SELECT `fid`,`reason`,`created`,`length` FROM `%s%s` WHERE (player_id='%s' OR player_ip='%s') AND `server_ip`='%s:%s' ORDER BY `length` ASC", g_dbPrefix, tbl_flagged, authid,ip, g_ip, g_port);
	
	new data[1];
	data[0] = id;
	if(g_SqlX) 
	SQL_ThreadQuery(g_SqlX, "_check_flagged", pquery, data, 1);
	
	return PLUGIN_HANDLED;
}

public _check_flagged(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0];
	
	if(failstate)
	{
		new szQuery[256];
		MySqlX_ThreadError(szQuery, error, errnum, failstate, 40);
		return PLUGIN_HANDLED;
	}
	
	if(!SQL_NumResults(query))
		return PLUGIN_HANDLED;
	
	new length, reason[128], created, fid, bool:flagged;
	new cur_time = get_systime();
	
	while(SQL_MoreResults(query))
	{
		fid = SQL_ReadResult(query, 0);
		SQL_ReadResult(query, 1, reason, charsmax(reason));
		created = SQL_ReadResult(query, 2);
		length = SQL_ReadResult(query, 3);
		
		if(created + length * 60 > cur_time)
		{
			flagged = true;
		}
		else
		{
			remove_flagged(fid);
		}
		
		SQL_NextRow(query);
	}
	
	if(!flagged)
		return PLUGIN_HANDLED;
	
	//the last result contains the longest flagg time, using this of course
	
	g_flaggedTime[id] = length;
	copy(g_flaggedReason[id], charsmax(g_flaggedReason[]), reason);
	
	if(!g_being_flagged[id])
	{
		new ret;
		ExecuteForward(MFHandle[Player_Flagged], ret, id, (g_flaggedTime[id] * 60), g_flaggedReason[id]);
	}
	g_being_flagged[id] = true;
	return PLUGIN_HANDLED;
}

remove_flagged(fid)
{
	new pquery[1024];
	formatex(pquery, charsmax(pquery), "DELETE FROM `%s%s` WHERE `fid`=%d", g_dbPrefix, tbl_flagged, fid);
	if(g_SqlX)
	SQL_ThreadQuery(g_SqlX, "_remove_flagged", pquery);
	
	return PLUGIN_CONTINUE;
}

public _remove_flagged(failstate, Handle:query, error[], errnum, data[], size)
{
	if(failstate)
	{
		new szQuery[256];
		MySqlX_ThreadError(szQuery, error, errnum, failstate, 41);
	}
	
	return PLUGIN_HANDLED;
}