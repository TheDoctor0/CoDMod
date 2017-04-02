/*

	AMXBans, managing bans for Half-Life modifications
	Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
	
	Copyright (C) 2009, 2010  Thomas Kurz

*/

#if defined _menu_disconnected_included
    #endinput
#endif
#define _menu_disconnected_included

#include <amxmodx>
#include <amxmisc>
#include <sqlx>
public cmdBanDisconnectedMenu(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
		
	new dnum=ArraySize(g_disconPLname)
	
	if(!dnum) {
		//client_print(id,print_chat,"[AMXBans] %L",id,"NO_DISCONNECTED_PLAYER_IN_LIST")
		ColorChat(id, RED, "[AMXBans]^x01 %L",id,"NO_DISCONNECTED_PLAYER_IN_LIST")
		return PLUGIN_HANDLED
	}
	
	new menu = menu_create("menu_discplayer","actionBanDisconnectedMenu")
	
	new szText[64]
	if(g_coloredMenus)
		formatex(szText,charsmax(szText),"\r%L\w",id,"BANDISCONNECTED_MENU",dnum)
	else
		formatex(szText,charsmax(szText),"%L",id,"BANDISCONNECTED_MENU",dnum)
	
	menu_setprop(menu,MPROP_TITLE,szText)
	formatex(szText,charsmax(szText),"%L",id,"BACK")
	menu_setprop(menu,MPROP_BACKNAME,szText)
	formatex(szText,charsmax(szText),"%L",id,"MORE")
	menu_setprop(menu,MPROP_NEXTNAME,szText)
	formatex(szText,charsmax(szText),"%L",id,"EXIT")
	menu_setprop(menu,MPROP_EXITNAME,szText)
	
	new szDisplay[128],szArId[3]
	for(new i=dnum-1; i >= 0;i--) {
		ArrayGetString(g_disconPLname,i,szDisplay,charsmax(szDisplay))
		num_to_str(i,szArId,charsmax(szArId))
		menu_additem(menu,szDisplay,szArId,0)
	}
	menu_display(id,menu,0)
	
	return PLUGIN_HANDLED
}
public actionBanDisconnectedMenu(id,menu,item) {
	if(item < 0) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new acc,szInfo[3],szText[128],callb
	menu_item_getinfo(menu,item,acc,szInfo,charsmax(szInfo),szText,charsmax(szText),callb)
	
	new aid=str_to_num(szInfo)
	
	ArrayGetString(g_disconPLname,aid,g_choicePlayerName[id],charsmax(g_choicePlayerName[]))
	ArrayGetString(g_disconPLauthid,aid,g_choicePlayerAuthid[id],charsmax(g_choicePlayerAuthid[]))
	ArrayGetString(g_disconPLip,aid,g_choicePlayerIp[id],charsmax(g_choicePlayerIp[]))
	g_choicePlayerId[id]=-1
	
	if(get_pcvar_num(pcvar_debug) >= 2)
		log_amx("[AMXBans PlayerDiscMenu %d] %d choice: %s | %s | %s | %d",menu,id,g_choicePlayerName[id],g_choicePlayerAuthid[id],g_choicePlayerIp[id],g_choicePlayerId[id])
	
	if(amxbans_get_static_bantime(id)) {
		set_task(0.2,"cmdReasonMenu",id)
	} else {
		set_task(0.2,"cmdBantimeMenu",id)
	}
	
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
/*************************************************************************************/
public cmdMenuBanDisc(id) {
	if(!id) return PLUGIN_HANDLED
	
	if(!get_ban_type(g_ban_type[id],charsmax(g_ban_type),g_choicePlayerAuthid[id],g_choicePlayerIp[id])) {
		log_amx("[AMXBans Disc ERROR] Steamid / IP Invalid! Bantype: <%s> | Authid: <%s> | IP: <%s>",g_ban_type[id],g_choicePlayerAuthid[id],g_choicePlayerIp[id])
		return PLUGIN_HANDLED
	}
	
	if(get_pcvar_num(pcvar_debug) >= 2) {
		log_amx("[AMXBans cmdMenuBanDisc %d] %d | %s | %s | %s | %s (%d min)",id,\
		g_choicePlayerId[id],g_choicePlayerName[id],g_choicePlayerAuthid[id],g_choicePlayerIp[id],g_choiceReason[id],g_choiceTime[id])
	}
	
	new pquery[1024]
	
	if (equal(g_ban_type[id], "S")) {
		formatex(pquery, charsmax(pquery),"SELECT player_id FROM %s%s WHERE player_id='%s' and expired=0", g_dbPrefix, tbl_bans, g_choicePlayerAuthid[id])
		if ( get_pcvar_num(pcvar_debug) >= 2 )
			log_amx("[AMXBans cmdMenuBanDisc] Banned a player by SteamID")
	} else {
		formatex(pquery, charsmax(pquery),"SELECT player_ip FROM %s%s WHERE player_ip='%s' and expired=0", g_dbPrefix, tbl_bans, g_choicePlayerIp[id])
		if ( get_pcvar_num(pcvar_debug) >= 2 )
			log_amx("[AMXBans cmdMenuBanDisc] Banned a player by IP/steamID")
	}
	
	
	new data[3]
	data[0] = id
	SQL_ThreadQuery(g_SqlX, "_cmdMenuBanDisc", pquery, data, 3)
	
	return PLUGIN_HANDLED	
}
public _cmdMenuBanDisc(failstate, Handle:query, error[], errnum, data[], size)
{
	new id = data[0]
	
	if ( get_pcvar_num(pcvar_debug) >= 1 )
		log_amx("[cmdMenuBanDisc function 2]")
		
	if (failstate) {
		new szQuery[256]
		SQL_GetQueryString(query,szQuery,255)
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 6 )
		return PLUGIN_HANDLED
	}
	
	if (SQL_NumResults(query)) {
		//client_print(id,print_console,"[AMXBANS] %L",id,"ALREADY_BANNED", g_choicePlayerAuthid[id], g_choicePlayerIp[id])
		ColorChat(id, RED, "[AMXBans]^x01 %L",id,"ALREADY_BANNED", g_choicePlayerAuthid[id], g_choicePlayerIp[id])
		g_being_banned[id] = false
		return PLUGIN_HANDLED
	}
	
	new admin_nick[64], admin_steamid[35], admin_ip[22]
	mysql_get_username_safe(id, admin_nick, charsmax(admin_nick))
	get_user_ip(id, admin_ip, charsmax(admin_ip), 1)
	get_user_authid(id, admin_steamid, charsmax(admin_steamid))
	
	new server_name[256]
	get_cvar_string("hostname", server_name, charsmax(server_name))
	
	if ( get_pcvar_num(pcvar_add_mapname) == 1 ) {
		new mapname[32]
		get_mapname(mapname,31)
		format(server_name,charsmax(server_name),"%s (%s)",server_name,mapname)
	}
	new servername_safe[256]
	mysql_escape_string(server_name,servername_safe,charsmax(servername_safe))
	
	new player_name[64]
	mysql_escape_string(g_choicePlayerName[id],player_name,charsmax(player_name))
	
	new pquery[1024]
	
	formatex(pquery, charsmax(pquery), "INSERT INTO `%s%s` (player_id,player_ip,player_nick,admin_ip,admin_id,admin_nick,ban_type,ban_reason,ban_created,ban_length,server_name,server_ip,expired) \
			VALUES('%s','%s','%s','%s','%s','%s','%s','%s',UNIX_TIMESTAMP(NOW()),%d,'%s','%s:%s',0)", \
			g_dbPrefix, tbl_bans, g_choicePlayerAuthid[id],g_choicePlayerIp[id],player_name,admin_ip,admin_steamid,admin_nick,g_ban_type[id],g_choiceReason[id],g_choiceTime[id],servername_safe,g_ip,g_port)
	
	new data[3]
	data[0] = id
	SQL_ThreadQuery(g_SqlX, "__cmdMenuBanDisc", pquery, data, 3)
	
	return PLUGIN_HANDLED
}
public __cmdMenuBanDisc(failstate, Handle:query, error[], errnum, data[], size) {
	new id = data[0]
	
	if (failstate) {
		new szQuery[256]
		SQL_GetQueryString(query,szQuery,255)
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 6 )
		return PLUGIN_HANDLED
	}
	
	if ( get_pcvar_num(pcvar_debug) >= 1 )
		log_amx("[AMXBans cmdMenuBanDisc function 3] %d: %s",id,g_choicePlayerName[id])
	
	if (SQL_GetInsertId(query)) {
		//client_print(id,print_console,"[AMXBANS] %L",id,"BAN_DISCONNECTED_PLAYER_SUCCESS")
		ColorChat(id, RED, "[AMXBans]^x01 %L",id,"BAN_DISCONNECTED_PLAYER_SUCCESS")
	} else {
		//client_print(id,print_console,"[AMXBANS] %L",id,"BAN_DISCONNECTED_PLAYER_FAILED")
		ColorChat(id, RED, "[AMXBans]^x01 %L",id,"BAN_DISCONNECTED_PLAYER_FAILED")
	}
	return PLUGIN_HANDLED
}
/*************************************************************************************/
disconnect_remove_player(id) {
	if(is_user_bot(id)) return PLUGIN_CONTINUE
	
	new dnum=ArraySize(g_disconPLauthid)
	if(!dnum) return PLUGIN_CONTINUE
	
	new authid[35],tmpid[35]
	get_user_authid(id,authid,charsmax(authid))
	
	for(new i;i < dnum;i++) {
		ArrayGetString(g_disconPLauthid,i,tmpid,charsmax(tmpid))
		if(!equal(authid,tmpid)) continue
		disc_array_remove_item(i)
		break
	}
	disc_debug_list()
	
	return PLUGIN_CONTINUE
}
disconnected_add_player(id) {
	if(is_user_bot(id)) return PLUGIN_CONTINUE
	
	new maxnum=get_pcvar_num(pcvar_discon_in_banlist)
	if(!maxnum) return PLUGIN_CONTINUE
	
	new name[32],authid[35],ip[22]
	get_user_name(id,name,charsmax(name))
	get_user_authid(id,authid,charsmax(authid))
	get_user_ip(id,ip,charsmax(ip),1)
	
	new dnum=ArraySize(g_disconPLname)
	
	
	ArrayPushString(g_disconPLname,name)
	ArrayPushString(g_disconPLauthid,authid)
	ArrayPushString(g_disconPLip,ip)
	
	while(dnum >= maxnum) {
		disc_array_remove_item(0)
		dnum--
	}
	disc_debug_list()
	return PLUGIN_CONTINUE
}
stock disc_array_remove_item(item) {
	ArrayDeleteItem(g_disconPLname,item)
	ArrayDeleteItem(g_disconPLauthid,item)
	ArrayDeleteItem(g_disconPLip,item)
}
stock disc_debug_list() {
	if(get_pcvar_num(pcvar_debug) < 4) return PLUGIN_CONTINUE
	
	new dnum=ArraySize(g_disconPLname)
	new maxnum=get_pcvar_num(pcvar_discon_in_banlist)
	
	for(new i;i < dnum;i++) {
		log_amx("[AMXBans DiscList %d/%d] %d %a | %a | %a",dnum,maxnum,i,\
			ArrayGetStringHandle(g_disconPLname,i),
			ArrayGetStringHandle(g_disconPLauthid,i),
			ArrayGetStringHandle(g_disconPLip,i))
	}
	return PLUGIN_CONTINUE
}
	
