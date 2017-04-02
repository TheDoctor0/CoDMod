/*

	AMXBans, managing bans for Half-Life modifications
	Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
	
	Copyright (C) 2009, 2010  Thomas Kurz

*/

#if defined _check_player_included
    #endinput
#endif
#define _check_player_included

#include <amxmodx>
#include <amxmisc>
#include <sqlx>

public prebanned_check(id) {
	if(is_user_bot(id) || id==0)
		return PLUGIN_HANDLED
	
	if(!get_pcvar_num(pcvar_show_prebanned))
		return PLUGIN_HANDLED
	
	if(get_user_flags(id) & ADMIN_IMMUNITY)
		return PLUGIN_HANDLED
	
	new player_steamid[35], player_ip[22], pquery[1024]
	get_user_authid(id, player_steamid, 34)
	get_user_ip(id, player_ip, 21, 1)

	//formatex(pquery, charsmax(pquery), "SELECT ban_created,admin_nick FROM `%s%s` WHERE ( (player_id='%s' AND ban_type='S') OR (player_ip='%s' AND ban_type='SI') ) AND expired=1",g_dbPrefix, tbl_bans, player_steamid, player_ip)
	formatex(pquery, charsmax(pquery), "SELECT COUNT(*) FROM `%s%s` WHERE ( (player_id='%s' AND ban_type='S') OR (player_ip='%s' AND ban_type='SI') ) AND expired=1",g_dbPrefix, tbl_bans, player_steamid, player_ip)
	
	new data[1]
	data[0] = id
	if(g_SqlX)
	SQL_ThreadQuery(g_SqlX, "prebanned_check_", pquery, data, 1)
	
	return PLUGIN_HANDLED
}
public prebanned_check_(failstate, Handle:query, error[], errnum, data[], size) {
                                new id = data[0]
                                
                                if (failstate) {
                                                                new szQuery[256]
                                                                MySqlX_ThreadError( szQuery, error, errnum, failstate, 16 )
                                                                return PLUGIN_HANDLED
                                }
                                
                                new ban_count=SQL_ReadResult(query, 0)
                                
                                if(ban_count < get_pcvar_num(pcvar_show_prebanned_num))
                                                                return PLUGIN_HANDLED
                                                                
                                new name[32], player_steamid[35], player_ip[20];
                                get_user_authid(id, player_steamid, 34)
                                get_user_name(id, name, 31)
                                get_user_ip(id, player_ip, 19, 1)
                                
                                for(new i=1;i<=plnum;i++) {
                                                                if(is_user_bot(i) || is_user_hltv(i) || !is_user_connected(i) || i==id)
                                                                                                continue
                                                                if(get_user_flags(i) & ADMIN_CHAT) {
                                                                                                ColorChat(i, RED, "[AMXBans] ^x01%L",i, "PLAYER_BANNED_BEFORE", name, player_ip, player_steamid, ban_count)
                                                                }
                                }
                                log_amx("[AMXBans] %L",LANG_SERVER, "PLAYER_BANNED_BEFORE", name, player_ip, player_steamid, ban_count)
                                
                                return PLUGIN_HANDLED
}

/*************************************************************************/

public check_player(id) {
	new player_steamid[32], player_ip[20]
	get_user_authid(id, player_steamid, 31)
	get_user_ip(id, player_ip, 19, 1)

	new data[1], pquery[1024]
	formatex(pquery, charsmax(pquery), "SELECT bid,ban_created,ban_length,UNIX_TIMESTAMP(),ban_reason,admin_nick,admin_id,admin_ip,player_nick,player_id,player_ip,server_name,server_ip,ban_type \
FROM `%s%s` WHERE ((player_id='%s' AND ban_type='S') OR (player_ip='%s' AND ban_type='SI')) AND expired=0", g_dbPrefix, tbl_bans, player_steamid, player_ip);
	
	data[0] = id
	if(g_SqlX)
	SQL_ThreadQuery(g_SqlX, "check_player_", pquery, data, 1)
	
	return PLUGIN_HANDLED
}

public check_player_(failstate, Handle:query, error[], errnum, data[], size) {
	new id = data[0]

	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 17 )
		return PLUGIN_HANDLED
	}
	
	if(!SQL_NumResults(query)) {
		check_flagged(id)
		return PLUGIN_HANDLED
	}
	
	new ban_reason[128], admin_nick[100],admin_steamid[50],admin_ip[30],ban_type[4]
	new player_nick[50],player_steamid[50],player_ip[30],server_name[100],server_ip[30]
	
	new bid = SQL_ReadResult(query, 0)
	new ban_created = SQL_ReadResult(query, 1)
	new ban_length_int = SQL_ReadResult(query, 2)*60 //min to sec
	new current_time_int = SQL_ReadResult(query, 3);
	SQL_ReadResult(query, 4, ban_reason, 127);
	SQL_ReadResult(query, 5, admin_nick, 99);
	SQL_ReadResult(query, 6, admin_steamid, 31);
	SQL_ReadResult(query, 7, admin_ip, 19);
	SQL_ReadResult(query, 8, player_nick, 47);
	SQL_ReadResult(query, 9, player_steamid, 31);
	SQL_ReadResult(query, 10, player_ip, 19);
	SQL_ReadResult(query, 11, server_name, 99);
	SQL_ReadResult(query, 12, server_ip, 29);
	SQL_ReadResult(query, 13, ban_type, 3);

	if ( get_pcvar_num(pcvar_debug) >= 1 )
		log_amx("[AMXBans] Player Check on Connect:^nbid: %d ^nwhen: %d ^nlenght: %d ^nreason: %s ^nadmin: %s ^nadminsteamID: %s ^nPlayername %s ^nserver: %s ^nserverip: %s ^nbantype: %s",\
		bid,ban_created,ban_length_int,ban_reason,admin_nick,admin_steamid,player_nick,server_name,server_ip,ban_type)

	//new ban_length_int = str_to_num(ban_length) * 60 // in secs

	// A ban was found for the connecting player!! Lets see how long it is or if it has expired
	if ((ban_length_int == 0) || (ban_created ==0) || ((ban_created+ban_length_int) > current_time_int)) {
		new complain_url[256]
		get_pcvar_string(pcvar_complainurl ,complain_url,255)
		
		client_cmd(id, "echo [AMXBans] ===============================================")
		
		new show_activity = get_cvar_num("amx_show_activity")
		
		if(get_user_flags(id)&get_admin_mole_access_flag() || id == 0)
		show_activity = 1
		
		switch(show_activity)
		{
			case 1:
			{
				client_cmd(id, "echo [AMXBans] %L",id,"MSG_9")
			}
			case 2:
			{
				client_cmd(id, "echo [AMXBans] %L",id,"MSG_8", admin_nick)
			}
			case 3:
			{
				if (is_user_admin(id))
					client_cmd(id, "echo [AMXBans] %L",id,"MSG_8", admin_nick)
				else
					client_cmd(id, "echo [AMXBans] %L",id,"MSG_9")
			}
			case 4:
			{
				if (is_user_admin(id))
					client_cmd(id, "echo [AMXBans] %L",id,"MSG_8", admin_nick)
			}
			case 5:
			{
				if (is_user_admin(id))
					client_cmd(id, "echo [AMXBans] %L",id,"MSG_9")
			}
		}
		
		if (ban_length_int==0) {
			client_cmd(id, "echo [AMXBans] %L",id,"MSG_10")
		} else {
			new cTimeLength[128]
			new iSecondsLeft = (ban_created + ban_length_int - current_time_int)
			get_time_length(id, iSecondsLeft, timeunit_seconds, cTimeLength, 127)
			client_cmd(id, "echo [AMXBans] %L" ,id, "MSG_12", cTimeLength)
		}
		
		replace_all(complain_url,charsmax(complain_url),"http://","")
		
		client_cmd(id, "echo [AMXBans] %L", id, "MSG_13", player_nick)
		client_cmd(id, "echo [AMXBans] %L", id, "MSG_2", ban_reason)
		client_cmd(id, "echo [AMXBans] %L", id, "MSG_7", complain_url)
		client_cmd(id, "echo [AMXBans] %L", id, "MSG_4", player_steamid)
		client_cmd(id, "echo [AMXBans] %L", id, "MSG_5", player_ip)
		client_cmd(id, "echo [AMXBans] ===============================================")

		if ( get_pcvar_num(pcvar_debug) >= 1 )
			log_amx("[AMXBans] BID:<%d> Player:<%s> <%s> connected and got kicked, because of an active ban", bid, player_nick, player_steamid)

		new id_str[3]
		num_to_str(id,id_str,3)

		if ( get_pcvar_num(pcvar_debug) >= 1 )
			log_amx("[AMXBans] Delayed Kick-TASK ID1: <%d>  ID2: <%s>", id, id_str)
		
		add_kick_to_db(bid)
		
		id+=200
		set_task(3.5,"delayed_kick",id)

		return PLUGIN_HANDLED
	} else {
		// The ban has expired
		client_cmd(id, "echo [AMXBans] %L",LANG_PLAYER,"MSG_11")
		
		new pquery[1024]
		formatex(pquery,charsmax(pquery),"UPDATE `%s%s` SET expired=1 WHERE bid=%d",g_dbPrefix, tbl_bans, bid)
		if(g_SqlX)
		SQL_ThreadQuery(g_SqlX, "insert_to_banhistory", pquery)
		
		if ( get_pcvar_num(pcvar_debug) >= 1 )
			log_amx("[AMXBans] PRUNE BAN: %s",pquery)
			
		check_flagged(id)
	}
	return PLUGIN_HANDLED
}

public insert_to_banhistory(failstate, Handle:query, error[], errnum, data[], size) {
	if (failstate) {
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 19 )
	}
	return PLUGIN_HANDLED
}
/*************************************************************************/
public add_kick_to_db(bid) {
	new pquery[1024]
	formatex(pquery,charsmax(pquery),"UPDATE `%s%s` SET `ban_kicks`=`ban_kicks`+1 WHERE `bid`=%d",g_dbPrefix, tbl_bans, bid)
	
	if(g_SqlX)
	SQL_ThreadQuery(g_SqlX, "_add_kick_to_db", pquery)
	return PLUGIN_HANDLED
}
public _add_kick_to_db(failstate, Handle:query, error[], errnum, data[], size) {
	if (failstate) {
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 19 )
	}
	return PLUGIN_HANDLED
}

