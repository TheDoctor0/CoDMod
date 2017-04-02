/*

	AMXBans, managing bans for Half-Life modifications
	Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
	
	Copyright (C) 2009, 2010  Thomas Kurz

*/

#if defined _cmdban_included
    #endinput
#endif
#define _cmdban_included

#include <amxmodx>
#include <sqlx>
public cmdMenuBan(id) {
	if(!id)
		return PLUGIN_HANDLED
	
	if(g_being_banned[g_choicePlayerId[id]]) {
		client_print(id,print_chat,"[AMXBans] %L", LANG_PLAYER, "BLOCKING_DOUBLEBAN", g_choicePlayerName[id])
		//ColorChat(id, RED, "[AMXBans]^x01 Blocking doubleban from <%s>", g_choicePlayerName[id])
	}
	g_being_banned[g_choicePlayerId[id]]=true
	
	if(!get_ban_type(g_ban_type[id],charsmax(g_ban_type),g_choicePlayerAuthid[id],g_choicePlayerIp[id])) {
		log_amx("[AMXBans ERROR cmdMenuBan] Steamid / IP Invalid! Bantype: <%s> | Authid: <%s> | IP: <%s>",g_ban_type[id],g_choicePlayerAuthid[id],g_choicePlayerIp[id])
		g_being_banned[g_choicePlayerId[id]]=false
		return PLUGIN_HANDLED
	}
	
	if(get_pcvar_num(pcvar_debug) >= 2) {
		log_amx("[AMXBans cmdMenuBan %d] %d | %s | %s | %s | %s (%d min)",id,\
		g_choicePlayerId[id],g_choicePlayerName[id],g_choicePlayerAuthid[id],g_choicePlayerIp[id],g_choiceReason[id],g_choiceTime[id])
	}
	
	new pquery[1024]
	
	if (equal(g_ban_type[id], "S")) {
		formatex(pquery, charsmax(pquery),"SELECT player_id FROM %s%s WHERE player_id='%s' and expired=0", g_dbPrefix, tbl_bans, g_choicePlayerAuthid[id])
		if ( get_pcvar_num(pcvar_debug) >= 2 )
			log_amx("[AMXBans cmdMenuBan] Banned a player by SteamID")
	} else {
		formatex(pquery, charsmax(pquery),"SELECT player_ip FROM %s%s WHERE player_ip='%s' and expired=0", g_dbPrefix, tbl_bans, g_choicePlayerIp[id])
		if ( get_pcvar_num(pcvar_debug) >= 2 )
			log_amx("[AMXBans cmdMenuBan] Banned a player by IP/steamID")
	}
	
	
	new data[3]
	data[0] = id
	data[1] = g_choicePlayerId[id]
	SQL_ThreadQuery(g_SqlX, "_cmdMenuBan", pquery, data, 3)
	
	return PLUGIN_HANDLED	
}
public _cmdMenuBan(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	new pid = data[1]
	
	if ( get_pcvar_num(pcvar_debug) >= 1 )
		log_amx("[AMXBans cmdMenuBan function 2]Playerid: %d", pid)
		
	if (failstate) {
		new szQuery[256]
		SQL_GetQueryString(query,szQuery,255)
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 6 )
		return PLUGIN_HANDLED
	}
	
	//if (SQL_NumResults(query)) {
		//client_print(id,print_console,"[AMXBANS] %L",id,"ALREADY_BANNED", g_choicePlayerAuthid[id], g_choicePlayerIp[id])
		//ColorChat(id, RED, "[AMXBans]^x01 %L",id,"ALREADY_BANNED", g_choicePlayerAuthid[id], g_choicePlayerIp[id])
		//g_being_banned[id] = false
		//return PLUGIN_HANDLED
	//}
	
	new admin_nick[64], admin_steamid[35], admin_ip[22];
	mysql_get_username_safe(id, admin_nick, charsmax(admin_nick));
	get_user_ip(id, admin_ip, charsmax(admin_ip), 1)
	get_user_authid(id, admin_steamid, charsmax(admin_steamid))
	
	new server_name[256]
	get_cvar_string("hostname", server_name, charsmax(server_name))
	
	if ( get_pcvar_num(pcvar_add_mapname) == 1 ) {
		new mapname[32]
		get_mapname(mapname,31)
		format(server_name,charsmax(server_name),"%s (%s)",server_name,mapname)
	}

	//new servername_safe[256]
	//mysql_escape_string(server_name,servername_safe,charsmax(servername_safe))
	new player_nick[64]
	mysql_escape_string(g_choicePlayerName[id],player_nick,charsmax(player_nick))
	
	new pquery[1024]
	formatex(pquery, charsmax(pquery), "INSERT INTO `%s%s` (player_id,player_ip,player_nick,admin_ip,admin_id,admin_nick,ban_type,ban_reason,ban_created,ban_length,server_name,server_ip,expired) \
			VALUES('%s','%s', '%s','%s','%s', '%s','%s','%s',UNIX_TIMESTAMP(NOW()),%d, '%s','%s:%s',0)", \
			g_dbPrefix, tbl_bans, g_choicePlayerAuthid[id],g_choicePlayerIp[id],player_nick,admin_ip,admin_steamid,admin_nick,g_ban_type[id],g_choiceReason[id],g_choiceTime[id],server_name,g_ip,g_port)
	
	
	new data[3]
	data[0] = id
	data[1] = g_choicePlayerId[id]
	SQL_ThreadQuery(g_SqlX, "insert_bandetails", pquery, data, 3)
	
	return PLUGIN_HANDLED
}
/*******************************************************************************************************************/
/*******************************************************************************************************************/
public cmdBan(id, level, cid)
{
	/* Checking if the admin has the right access */
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED

	g_menuban_type[id] = 0
	
	new text[128]
	read_args(text, 127)
	
	// get player ident and bantime depending on the ban cmd format
	new ban_length[50]
	parse(text, ban_length, 49, g_ident, 49)
	
	trim(g_ident)
	trim(ban_length)
	
	// Check so the ban command has the right format
	if( !is_str_num(ban_length) || read_argc() < 3 )
	{
		client_print(id,print_console,"[AMXBans] %L",LANG_PLAYER,"AMX_BAN_SYNTAX")
		return PLUGIN_HANDLED
	}
	
	new length = strlen(ban_length) + strlen(g_ident) + 2
	
	// get and format the ban reason
	new reason[128]
	read_args(reason,127)
	formatex(g_choiceReason[id], charsmax(g_choiceReason[]), "%s", reason[length])
	trim(g_choiceReason[id])
	remove_quotes(g_choiceReason[id])
	
	//if the reason is empty use the default ban reason from cvar
	if(!strlen(g_choiceReason[id])) {
		get_pcvar_string(pcvar_default_banreason,g_choiceReason[id],charsmax(g_choiceReason[]))
	}
	
	g_choiceTime[id] = abs(str_to_num(ban_length))
	new cTimeLength[128]
	if (g_choiceTime[id] > 0)
		get_time_length(id, g_choiceTime[id], timeunit_minutes, cTimeLength, 127)
	else
		format(cTimeLength, 127, "%L", LANG_PLAYER, "TIME_ELEMENT_PERMANENTLY")
	
	// This stops admins from banning perm in console if not adminflag n
	if(!(get_user_flags(id) & get_higher_ban_time_admin_flag()) && g_choiceTime[id] == 0)
	{
		client_print(id,print_console,"[AMXBans] %L",LANG_PLAYER,"NOT_BAN_PERMANENT")
		return PLUGIN_HANDLED
	}

	// Try to find the player that should be banned
	g_choicePlayerId[id] = locate_player(id, g_ident)
	
	// Player is a BOT or has immunity
	if (g_choicePlayerId[id] == -1)
		return PLUGIN_HANDLED
		
	if(g_being_banned[g_choicePlayerId[id]]) {
		if ( get_pcvar_num(pcvar_debug) >= 1 )
			log_amx("[AMXBans Blocking doubleban(g_being_banned)] Playerid: %d BanLenght: %s Reason: %s", g_choicePlayerId[id], g_choiceTime[id], g_choiceReason[id])
			
		return PLUGIN_HANDLED
	}
	
	g_being_banned[g_choicePlayerId[id]] = true
	
	if ( get_pcvar_num(pcvar_debug) >= 1 )
		log_amx("[AMXBans cmdBan function 1]Playerid: %d", g_choicePlayerId[id])

	if (g_choicePlayerId[id])
	{
		get_user_authid(g_choicePlayerId[id], g_choicePlayerAuthid[id], 49)
		get_user_ip(g_choicePlayerId[id], g_choicePlayerIp[id], 29, 1)
	}
	else
	{
		g_being_banned[0]=false
		
		console_print(id, "[AMXBans] %L", LANG_PLAYER, "PLAYER_NOT_FOUND",g_ident)

		if ( get_pcvar_num(pcvar_debug) >= 1 )
			log_amx("[AMXBans] Player %s could not be found",g_ident)
				
		return PLUGIN_HANDLED
	}

	if(!get_ban_type(g_ban_type[id],charsmax(g_ban_type[]),g_choicePlayerAuthid[id],g_choicePlayerIp[id])) {
		log_amx("[AMXBans ERROR cmdBan] Steamid / IP Invalid! Bantype: <%s> | Authid: <%s> | IP: <%s>",g_ban_type[id],g_choicePlayerAuthid[id],g_choicePlayerIp[id])
		g_being_banned[g_choicePlayerId[id]]=false
		return PLUGIN_HANDLED
	}
	
	new pquery[1024]
	
	if (equal(g_ban_type[id], "S"))
	{
		formatex(pquery, charsmax(pquery),"SELECT player_id FROM %s%s WHERE player_id='%s' AND expired=0", g_dbPrefix, tbl_bans, g_choicePlayerAuthid[id])
		
		if ( get_pcvar_num(pcvar_debug) >= 1 )
			log_amx("[AMXBans cmdBan] Banned a player by SteamID: %s",g_choicePlayerAuthid[id])
	}
	else
	{
		formatex(pquery, charsmax(pquery),"SELECT player_ip FROM %s%s WHERE player_ip='%s' AND expired=0", g_dbPrefix, tbl_bans, g_choicePlayerIp[id])
		
		if ( get_pcvar_num(pcvar_debug) >= 1 )
			log_amx("[AMXBans cmdBan] Banned a player by IP/steamID: %s",g_choicePlayerIp[id])
	}
	
	
	new data[1]
	data[0] = id
	SQL_ThreadQuery(g_SqlX, "cmd_ban_", pquery, data, 1)
	
	return PLUGIN_HANDLED
}

public cmd_ban_(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	
	if ( get_pcvar_num(pcvar_debug) >= 1 )
		log_amx("[AMXBans cmd_ban_ function 2]Playerid: %d", g_choicePlayerId[id])
	
	new bool:serverCmd = false
	/* Determine if this was a server command or a command issued by a player in the game */
	if ( id == 0 )
		serverCmd = true;
	
	if (failstate)
	{
		new szQuery[256]
		SQL_GetQueryString(query,szQuery,255)
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 6 )
	}
	else
	{	
		if (!SQL_NumResults(query))
		{
			if (g_choicePlayerId[id])
			{
				get_user_name(g_choicePlayerId[id], g_choicePlayerName[id], charsmax(g_choicePlayerName[]))
			}
			else /* The player was not found in server */
			{
				// Must make that false to be able to ban another player not on the server
				// Players that aren't in the server always get id = 0
				g_being_banned[0] = false
			
				console_print(id, "[AMXBans] %L", LANG_PLAYER, "PLAYER_NOT_FOUND",g_ident)
	
				if ( get_pcvar_num(pcvar_debug) >= 1 )
					log_amx("[AMXBans] Player %s could not be found",g_ident)
	
				return PLUGIN_HANDLED
			}
			
			new admin_nick[100], admin_steamid[50], admin_ip[20]
			mysql_get_username_safe(id, admin_nick, 99)
			get_user_ip(id, admin_ip, 19, 1)
			
			if (!serverCmd)
			{
				get_user_authid(id, admin_steamid, 49)
	
				if ( get_pcvar_num(pcvar_debug) >= 1 )
					log_amx("[AMXBans cmdBan] Adminsteamid: %s, Servercmd: %s", admin_steamid, (serverCmd)?"Yes":"No")
			}
			else
			{
				/* If the server does the ban you cant get any steam_ID or team */
				admin_steamid = "STEAM_0:1:36484"
		
				/* This is so you can have a shorter name for the servers hostname.
				Some servers hostname can be very long b/c of sponsors and that will make the ban list on the web bad */
				new servernick[100]
				get_pcvar_string(pcvar_server_nick, servernick, 99)
				if (strlen(servernick))
					copy(admin_nick,charsmax(admin_nick),servernick)
			}
		
			if ( get_pcvar_num(pcvar_debug) >= 1 )
				log_amx("[AMXBans cmdBan] Admin nick: %s, Admin userid: %d", admin_nick, get_user_userid(id))
			
			new server_name[200]
			mysql_get_servername_safe(server_name, charsmax(server_name))

			if ( get_pcvar_num(pcvar_add_mapname) ) {
				new mapname[32]//, pre[4],post[4]
				get_mapname(mapname,31)
				format(server_name,charsmax(server_name),"%s (%s)",server_name,mapname)
			}

			new player_nick[64]
			mysql_escape_string(g_choicePlayerName[id],player_nick,charsmax(player_nick))
			
			new pquery[1024]
			format(pquery, charsmax(pquery), "INSERT INTO `%s%s` \
				(player_id,player_ip,player_nick,admin_ip,admin_id,admin_nick,ban_type,ban_reason,ban_created,ban_length,server_name,server_ip,expired) \
				VALUES('%s','%s','%s','%s','%s','%s','%s','%s',UNIX_TIMESTAMP(NOW()),%d,'%s','%s:%s',0)", \
				g_dbPrefix, tbl_bans, g_choicePlayerAuthid[id], g_choicePlayerIp[id], player_nick, admin_ip, admin_steamid, admin_nick, g_ban_type[id], \
				g_choiceReason[id], g_choiceTime[id], server_name, g_ip, g_port)
		
			new data[3]
			data[0] = id
			SQL_ThreadQuery(g_SqlX, "insert_bandetails", pquery, data, 3)
		}
		else
		{
			if ( serverCmd )
				log_message("[AMXBans] %L",LANG_SERVER,"ALREADY_BANNED", g_choicePlayerAuthid[id], g_choicePlayerIp[id])
			else
				client_print(id,print_console,"[AMXBans] %L",LANG_PLAYER,"ALREADY_BANNED", g_choicePlayerAuthid[id], g_choicePlayerIp[id])
			// Must make that false to be able to ban another player not on the server
			// Players that aren't in the server always get id = 0
			g_being_banned[g_choicePlayerId[id]] = false

		}
	}
	
	return PLUGIN_HANDLED
}
/*******************************************************************************************************************/
/*******************************************************************************************************************/
/*******************************************************************************************************************/
public insert_bandetails(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	
	if ( get_pcvar_num(pcvar_debug) >= 1 )
		log_amx("[AMXBans cmdBan function 5]Playerid: %d",g_choicePlayerId[id])
	
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 8 )
		
		return PLUGIN_HANDLED
	}
	
	new bid = SQL_GetInsertId(query)
	
	//break if the banned player should not be kicked at the moment
	if(g_menuban_type[id]==1) return PLUGIN_HANDLED
	if(g_menuban_type[id]==2) {
		g_nextround_kick[g_choicePlayerId[id]]=true
		//g_nextround_kick_time[g_choicePlayerId[id]]=g_choiceTime[id]
		g_nextround_kick_bid[g_choicePlayerId[id]]=bid
		//copy(g_nextround_kick_Reason[g_choicePlayerId[id]],charsmax(g_nextround_kick_Reason[]),g_choiceReason[id])
		
		return PLUGIN_HANDLED
	}
	
	select_amxbans_motd(id,g_choicePlayerId[id],bid)
	return PLUGIN_HANDLED
}
/*******************************************************************************************************************/
public select_amxbans_motd(id,player,bid) {
	if ( get_pcvar_num(pcvar_debug) >= 1 )
		log_amx("[AMXBans cmdBan function 5]Bid: %d", bid)

	//get ban details from db
	new pquery[1024]
	format(pquery, charsmax(pquery), "SELECT si.amxban_motd,ba.player_nick,ba.player_id,ba.player_ip, \
		ba.admin_nick,ba.admin_id,ba.ban_type,ba.ban_reason,ba.ban_length FROM `%s%s` as si,`%s%s` as ba \
		WHERE ba.bid=%d AND si.address = '%s:%s'", g_dbPrefix, tbl_serverinfo, g_dbPrefix, tbl_bans, bid,g_ip, g_port)

	
	new data[4]
	data[0] = id
	data[1] = bid
	data[2] = player
	SQL_ThreadQuery(g_SqlX, "_select_amxbans_motd", pquery, data, 4)
	
	
	return PLUGIN_HANDLED
}
public _select_amxbans_motd(failstate, Handle:query, error[], errnum, data[], size) {
	new id = data[0]
	new bid = data[1]
	new player = data[2]
	//new iBanLength = g_choiceTime[id]
	
	if ( get_pcvar_num(pcvar_debug) >= 1 )
		log_amx("[AMXBans cmdBan function 6]Playerid: %d, Bid: %d", player, bid)

	new bool:serverCmd = false
	/* Determine if this was a server command or a command issued by a player in the game */
	if ( id == 0 )
		serverCmd = true;

	if (failstate) {
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 9 )
		return PLUGIN_HANDLED
	}
	
	new amxban_motd_url[256]
	new admin_steamid[35], admin_nick[100],pl_steamid[35],pl_nick[100],pl_ip[22]
	new ban_type[32],ban_reason[128],iBanLength
	if (!SQL_NumResults(query)) {
		amxban_motd_url[0]='^0'
		log_amx("[AMXBans cmdBan function 6.1] select_motd without result: %d, Bid: %d", player, bid)
		
		if(player && is_user_connected(player)) {
			new pid=player+200
			set_task(kick_delay, "delayed_kick", pid)
		}
		return PLUGIN_HANDLED
		//copy(amxban_motd_url,256, "0")	
	} else {
		SQL_ReadResult(query, 0, amxban_motd_url, 256)
		SQL_ReadResult(query, 1, pl_nick, 99)
		SQL_ReadResult(query, 2, pl_steamid, 34)
		SQL_ReadResult(query, 3, pl_ip, 21)
		SQL_ReadResult(query, 4, admin_nick, 99)
		SQL_ReadResult(query, 5, admin_steamid, 34)
		SQL_ReadResult(query, 6, ban_type, 31)
		SQL_ReadResult(query, 7, ban_reason, 127)
		iBanLength=SQL_ReadResult(query,8)
	}
	
	new admin_team[11]
	
	get_user_team(id, admin_team, 10)
	//get_user_authid(id, admin_steamid, charsmax(admin_steamid))
	//mysql_get_username_safe(id,admin_nick,charsmax(admin_nick))
	
	new cTimeLengthPlayer[128]
	new cTimeLengthServer[128]
		
	if (iBanLength > 0) {
		get_time_length(player, iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
		get_time_length(0, iBanLength, timeunit_minutes, cTimeLengthServer, 127)
	} else { //Permanent Ban
		format(cTimeLengthPlayer, 127, "%L", player, "TIME_ELEMENT_PERMANENTLY")
		format(cTimeLengthServer, 127, "%L", LANG_SERVER, "TIME_ELEMENT_PERMANENTLY")
	}
	
	new show_activity = get_cvar_num("amx_show_activity")
	if( (get_user_flags(id)&get_admin_mole_access_flag() || id == 0) && (get_pcvar_num(pcvar_show_name_evenif_mole) == 0) )
		show_activity = 1
	
	if (player) {
		new complain_url[256]
		get_pcvar_string(pcvar_complainurl ,complain_url, 255)
			
		client_print(player,print_console,"[AMXBans] ===============================================")
		
		new ban_motd[1400]
		switch(show_activity)
		{
			case 1:
			{
				client_print(player,print_console,"[AMXBans] %L",player,"MSG_1")
				client_print(player,print_console,"[AMXBans] %L",player,"MSG_7", complain_url)
				format(ban_motd, charsmax(ban_motd), "%L", player, "MSG_MOTD_1", ban_reason, cTimeLengthPlayer, pl_steamid)
			}
			case 2:
			{
				client_print(player,print_console,"[AMXBans] %L",player,"MSG_6", admin_nick)
				client_print(player,print_console,"[AMXBans] %L",player,"MSG_7", complain_url)
				format(ban_motd, charsmax(ban_motd), "%L", player, "MSG_MOTD_2", ban_reason, cTimeLengthPlayer, pl_steamid, admin_nick)
			}
			case 3:
			{
				if (is_user_admin(id))
				{
					client_print(player,print_console,"[AMXBans] %L",player,"MSG_6", admin_nick)
					client_print(player,print_console,"[AMXBans] %L",player,"MSG_7", complain_url)
					format(ban_motd, charsmax(ban_motd), "%L", player, "MSG_MOTD_2", ban_reason, cTimeLengthPlayer, pl_steamid, admin_nick)
				}
				else
				{
					client_print(player,print_console,"[AMXBans] %L",player,"MSG_1")
					client_print(player,print_console,"[AMXBans] %L",player,"MSG_7", complain_url)
					format(ban_motd, charsmax(ban_motd), "%L", player, "MSG_MOTD_1", ban_reason, cTimeLengthPlayer, pl_steamid)
				}
			}
			case 4:
			{
				if (is_user_admin(id))
				{
					client_print(player,print_console,"[AMXBans] %L",player,"MSG_6", admin_nick)
					client_print(player,print_console,"[AMXBans] %L",player,"MSG_7", complain_url)
					format(ban_motd, charsmax(ban_motd), "%L", player, "MSG_MOTD_2", ban_reason, cTimeLengthPlayer, pl_steamid, admin_nick)
				}
			}
			case 5:
			{
				if (is_user_admin(id))
				{
					client_print(player,print_console,"[AMXBans] %L",player,"MSG_1")
					client_print(player,print_console,"[AMXBans] %L",player,"MSG_7", complain_url)
					format(ban_motd, charsmax(ban_motd), "%L", player, "MSG_MOTD_1", ban_reason, cTimeLengthPlayer, pl_steamid)
				}
			}
		}
		
		client_print(player,print_console,"[AMXBans] %L",player,"MSG_2", ban_reason)
		client_print(player,print_console,"[AMXBans] %L",player,"MSG_3", cTimeLengthPlayer)
		client_print(player,print_console,"[AMXBans] %L",player,"MSG_4", pl_steamid)
		client_print(player,print_console,"[AMXBans] %L",player,"MSG_5", pl_ip)
		client_print(player,print_console,"[AMXBans] ===============================================")
		
		new msg[1400]
		
		if ( get_pcvar_num(pcvar_debug) >= 1 )
			log_amx("[AMXBans cmdBan function 6.2]Bid: %d URL= %s Kickdelay:%f", bid, amxban_motd_url, kick_delay)

		if(contain(amxban_motd_url,"sid=%s&adm=%d&lang=%s") != -1) {
			new bidstr[10],lang[5] 
			formatex(bidstr,9,"B%d",bid)
			get_user_info(player,"lang",lang,charsmax(lang))
			if(equal(lang,""))
				get_cvar_string("amx_language",lang,charsmax(lang))
			format(msg, charsmax(msg), amxban_motd_url,bidstr,(show_activity==2)?1:0,lang)
			if ( get_pcvar_num(pcvar_debug) >= 1 )
				log_amx("[AMXBans cmdBan function 6.3]Motd: %s",msg)
		} else {
			formatex(msg, charsmax(msg), ban_motd)
		}
		
		if(is_user_connected(player)) {
			new ret
			ExecuteForward(MFHandle[Ban_MotdOpen],ret,player)
			
			show_motd(player, msg, "Banned by Amxbans")
			
			new pid=player+200
			set_task(kick_delay, "delayed_kick", pid)
			
			set_pev( player, pev_flags, pev( player , pev_flags ) | FL_FROZEN ); // Added by xPaw
		}
	} else { /* The player was not found in server */
		console_print(id, "[AMXBans] %L", LANG_PLAYER, "PLAYER_NOT_FOUND",g_ident)

		if ( get_pcvar_num(pcvar_debug) >= 1 )
			log_amx("[AMXBans] Player %s could not be found",g_ident)

		return PLUGIN_HANDLED
		
		
	}
			
	if (equal(ban_type, "S")) {
		if ( serverCmd )
			log_message("[AMXBans] %L",LANG_SERVER,"STEAMID_BANNED_SUCCESS_IP_LOGGED",pl_steamid)
		else
			client_print(id,print_console,"[AMXBans] %L",id,"STEAMID_BANNED_SUCCESS_IP_LOGGED",pl_steamid)
	} else {
		if ( serverCmd )
			log_message("[AMXBans] %L",LANG_SERVER,"STEAMID_IP_BANNED_SUCCESS")
		else
			client_print(id,print_console,"[AMXBans] %L",id,"STEAMID_IP_BANNED_SUCCESS")
	}
	
	if (serverCmd) {
		/* If the server does the ban you cant get any steam_ID or team */
		admin_steamid[0] = '^0'
		admin_team[0] = '^0'
	}
			
	// Logs all bans by admins/server to amxx logs
	if (g_choiceTime[id] > 0) {
		log_amx("%L", LANG_SERVER, "BAN_LOG",admin_nick, get_user_userid(id), admin_steamid, admin_team, \
			pl_nick, pl_steamid, cTimeLengthServer, iBanLength, ban_reason)

		if ( get_pcvar_num(pcvar_show_in_hlsw) ) {
			// If you use HLSW you will see when someone ban a player if you can see the chatlogs
			log_message("^"%s<%d><%s><%s>^" triggered ^"amx_chat^" (text ^"%L^")", admin_nick, get_user_userid(id), admin_steamid, admin_team, \
				LANG_SERVER, "BAN_CHATLOG", pl_nick, pl_steamid, cTimeLengthServer, iBanLength, ban_reason)
		}
	} else {
		log_amx("%L", LANG_SERVER, "BAN_LOG_PERM", admin_nick, get_user_userid(id), admin_steamid, admin_team, pl_nick, pl_steamid, ban_reason)

		if ( get_pcvar_num(pcvar_show_in_hlsw) ) {
			// If you use HLSW you will see when someone ban a player if you can see the chatlogs
			log_message("^"%s<%d><%s><%s>^" triggered ^"amx_chat^" (text ^"%L^")", admin_nick, get_user_userid(id), admin_steamid, admin_team, \
				LANG_SERVER, "BAN_CHATLOG_PERM", pl_nick, pl_steamid, ban_reason)
		}
	}
	
	new message[191]
	
	
	switch (show_activity)
	{
		case 1:
		{
			new playerCount, idx, players[32]
			get_players(players, playerCount)
			for (idx=0; idx<playerCount; idx++) {
				if (is_user_hltv(players[idx]) || is_user_bot(players[idx])) continue // Dont count HLTV or bots as players
				
				get_time_length(players[idx], iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
				
				if (g_choiceTime[id] > 0)
					format(message,190,"%L", players[idx],"PUBLIC_BAN_ANNOUNCE", pl_nick, cTimeLengthPlayer, ban_reason)
				else
					format(message,190,"%L", players[idx],"PUBLIC_BAN_ANNOUNCE_PERM", pl_nick, ban_reason)
				
				if ( get_pcvar_num(pcvar_show_hud_messages) == 1 ) {
					set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 10.0 , 0.5, 0.15, -1)
					ShowSyncHudMsg(players[idx], g_MyMsgSync, "%s", message)
				}
				//client_print(players[idx],print_chat, "%s", message)
				ColorChat(players[idx], RED, "[AMXBans]^x01 %s", message)
				client_print(players[idx],print_console, "%s", message)
			}
		}
		case 2:
		{
			new playerCount, idx, players[32]
			get_players(players, playerCount)
			for (idx=0; idx<playerCount; idx++) {
				if (is_user_hltv(players[idx]) || is_user_bot(players[idx])) continue // Dont count HLTV or bots as players
				get_time_length(players[idx], iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
				
				if (g_choiceTime[id] > 0)
					format(message,190, "%L", players[idx], "PUBLIC_BAN_ANNOUNCE_2", pl_nick, cTimeLengthPlayer, ban_reason, admin_nick)
				else
					format(message,190, "%L", players[idx], "PUBLIC_BAN_ANNOUNCE_2_PERM", pl_nick, ban_reason, admin_nick)
				
				if ( get_pcvar_num(pcvar_show_hud_messages) == 1 ) {
					set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 10.0 , 0.5, 0.15, -1)
					ShowSyncHudMsg(players[idx], g_MyMsgSync, "%s", message)
				}
				//client_print(players[idx],print_chat, "%s", message)
				ColorChat(players[idx], RED, "[AMXBans]^x01 %s", message)
				client_print(players[idx], print_console, "%s", message)
			}
		}
		case 3:
		{
			if (is_user_admin(id))
			{
				new playerCount, idx, players[32]
				get_players(players, playerCount)
				
				for (idx=0; idx<playerCount; idx++) {
					if (is_user_hltv(players[idx]) || is_user_bot(players[idx])) continue // Dont count HLTV or bots as players
					get_time_length(players[idx], iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
					
					if (g_choiceTime[id] > 0)
						format(message,190, "%L", players[idx], "PUBLIC_BAN_ANNOUNCE_2", pl_nick, cTimeLengthPlayer, ban_reason, admin_nick)
					else
						format(message,190, "%L", players[idx], "PUBLIC_BAN_ANNOUNCE_2_PERM", pl_nick, ban_reason, admin_nick)
					
					if ( get_pcvar_num(pcvar_show_hud_messages) == 1 ) {
						set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 10.0 , 0.5, 0.15, -1)
						ShowSyncHudMsg(players[idx], g_MyMsgSync, "%s", message)
					}
					//client_print(players[idx],print_chat, "%s", message)
					ColorChat(players[idx], RED, "[AMXBans]^x01 %s", message)
					client_print(players[idx],print_console, "%s", message)
				}
			}
			else
			{
				new playerCount, idx, players[32]
				get_players(players, playerCount)
				
				for (idx=0; idx<playerCount; idx++) {
					if (is_user_hltv(players[idx]) || is_user_bot(players[idx])) continue // Dont count HLTV or bots as players
					
					get_time_length(players[idx], iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
					
					if (g_choiceTime[id] > 0)
						format(message,190,"%L", players[idx],"PUBLIC_BAN_ANNOUNCE", pl_nick, cTimeLengthPlayer, ban_reason)
					else
						format(message,190,"%L", players[idx],"PUBLIC_BAN_ANNOUNCE_PERM", pl_nick, ban_reason)
					
					if ( get_pcvar_num(pcvar_show_hud_messages) == 1 ) {
						set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 10.0 , 0.5, 0.15, -1)
						ShowSyncHudMsg(players[idx], g_MyMsgSync, "%s", message)
					}
					//client_print(players[idx],print_chat, "%s", message)
					ColorChat(players[idx], RED, "[AMXBans]^x01 %s", message)
					client_print(players[idx],print_console, "%s", message)
				}
			}
		}
		case 4:
		{
			if (is_user_admin(id))
			{
				new playerCount, idx, players[32]
				get_players(players, playerCount)
				
				for (idx=0; idx<playerCount; idx++) {
					if (is_user_hltv(players[idx]) || is_user_bot(players[idx])) continue // Dont count HLTV or bots as players
					get_time_length(players[idx], iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
					
					if (g_choiceTime[id] > 0)
						format(message,190, "%L", players[idx], "PUBLIC_BAN_ANNOUNCE_2", pl_nick, cTimeLengthPlayer, ban_reason, admin_nick)
					else
						format(message,190, "%L", players[idx], "PUBLIC_BAN_ANNOUNCE_2_PERM", pl_nick, ban_reason, admin_nick)
					
					if ( get_pcvar_num(pcvar_show_hud_messages) == 1 ) {
						set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 10.0 , 0.5, 0.15, -1)
						ShowSyncHudMsg(players[idx], g_MyMsgSync, "%s", message)
					}
					//client_print(players[idx],print_chat, "%s", message)
					ColorChat(players[idx], RED, "[AMXBans]^x01 %s", message)
					client_print(players[idx],print_console, "%s", message)
				}
			}
		}
		case 5:
		{
			if (is_user_admin(id))
			{
				new playerCount, idx, players[32]
				get_players(players, playerCount)
				
				for (idx=0; idx<playerCount; idx++) {
					if (is_user_hltv(players[idx]) || is_user_bot(players[idx])) continue // Dont count HLTV or bots as players
					
					get_time_length(players[idx], iBanLength, timeunit_minutes, cTimeLengthPlayer, 127)
					
					if (g_choiceTime[id] > 0)
						format(message,190,"%L", players[idx],"PUBLIC_BAN_ANNOUNCE", pl_nick, cTimeLengthPlayer, ban_reason)
					else
						format(message,190,"%L", players[idx],"PUBLIC_BAN_ANNOUNCE_PERM", pl_nick, ban_reason)
					
					if ( get_pcvar_num(pcvar_show_hud_messages) == 1 ) {
						set_hudmessage(0, 255, 0, 0.05, 0.30, 0, 6.0, 10.0 , 0.5, 0.15, -1)
						ShowSyncHudMsg(players[idx], g_MyMsgSync, "%s", message)
					}
					//client_print(players[idx],print_chat, "%s", message)
					ColorChat(players[idx], RED, "[AMXBans]^x01 %s", message)
					client_print(players[idx],print_console, "%s", message)
				}
			}
		}
	}

	return PLUGIN_HANDLED
}
public insert_ban_cmd(failstate, Handle:query, error[], errnum, data[], size) {
	if (failstate) {
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 12 )
	}
	return PLUGIN_HANDLED
}
public locate_player(id, identifier[]) {
	g_ban_type[id] = "S"

	// Check based on steam ID
	new player = find_player("c", identifier)

	// Check based on a partial non-case sensitive name
	if (!player) {
		player = find_player("bl", identifier)
	}
	// Check based on IP address
	if (!player) {
		player = find_player("d", identifier)
		if ( player )
			g_ban_type[id] = "SI"
	}
	// Check based on user ID
	if ( !player && identifier[0]=='#' && identifier[1] ) {
		player = find_player("k",str_to_num(identifier[1]))
	}

	if ( player ) {
		/* Check for immunity */
		if (get_user_flags(player) & ADMIN_IMMUNITY) {
			new name[32]
			get_user_name(player, name, 31)
			if( id == 0 )
				server_print("[AMXBans] Client ^"%s^" has immunity", name)
			else
				console_print(id,"[AMXBans] Client ^"%s^" has immunity", name)
			return -1
		}
		/* Check for a bot */
		/*
		else if (is_user_bot(player)) {
			new name[32]
			get_user_name(player, name, 31)
			if( id == 0 )
				server_print("[AMXBans] Client ^"%s^" is a bot", name)
			else
				console_print(id,"[AMXBans] Client ^"%s^" is a bot", name)
			return -1
		}
		*/
	} else
		player = -1;
	
	return player;
}
