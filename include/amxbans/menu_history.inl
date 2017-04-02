/*

	AMXBans, managing bans for Half-Life modifications
	Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
	
	Copyright (C) 2009, 2010  Thomas Kurz

*/

#if defined _menu_history_included
    #endinput
#endif
#define _menu_history_included

#include <amxmodx>
public cmdBanhistoryMenu(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	
	new menu = menu_create("menu_history","actionHistoryMenu")
	new callback=menu_makecallback("callback_MenuGetPlayers")
	
	MenuSetProps(id,menu,"BANHISTORY_MENU")
	MenuGetPlayers(menu,callback)
	
	menu_display(id,menu,0)
	
	return PLUGIN_HANDLED
}
public actionHistoryMenu(id,menu,item) {
	if(item < 0) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	new acc,szInfo[3],szText[128],callb
	menu_item_getinfo(menu,item,acc,szInfo,charsmax(szInfo),szText,charsmax(szText),callb)
	
	new pid=str_to_num(szInfo)
	
	menu_destroy(menu)
	
	new pquery[1024]
	format(pquery, charsmax(pquery), "SELECT amxban_motd FROM `%s%s` WHERE address = '%s:%s'", g_dbPrefix, tbl_serverinfo, g_ip, g_port)
	
	new data[4]
	data[0] = id
	data[1] = pid
	
	SQL_ThreadQuery(g_SqlX, "select_motd_history", pquery, data, 4)
	
	return PLUGIN_HANDLED
}
public select_motd_history(failstate, Handle:query, error[], errnum, data[], size) {
	if (failstate)
	{
		new szQuery[256]
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 9 )
		return PLUGIN_HANDLED
	}
	new id=data[0]
	new pid=data[1]
	
	new authid[35],name[32]
	get_user_authid(pid,authid,charsmax(authid))
	get_user_name(pid,name,charsmax(name))
	
	new motd_url[256]
	if (!SQL_NumResults(query)) {
		return PLUGIN_HANDLED	
	}
	
	SQL_ReadResult(query, 0, motd_url, 256)
	
	//http://URL/motd.php?sid=%s&adm=%d&lang=%s
	if(contain(motd_url,"?sid=%s&adm=%d&lang=%s") != -1) {
		new url[256],lang[5],title[128]
		
		formatex(title,charsmax(title),"%L",id,"HISTORY_MOTD",name)
		
		get_user_info(id,"lang",lang,charsmax(lang))
		if(equal(lang,""))
			get_cvar_string("amx_language",lang,charsmax(lang))
		
		//copy(url,charsmax(url),g_motdurl)
		formatex(url,charsmax(url),motd_url,authid,1,lang)
		if(get_pcvar_num(pcvar_debug) >= 2)
			log_amx("[AMXBans BanHistory Motd] %s",url)
		
		show_motd(id,url,title)
	} else {
		log_amx("[AMXBans ERROR BanHistory] %L",LANG_SERVER,"NO_MOTD")
		//client_print(id,print_chat,"[AMXBans] %L",id,"NO_MOTD")
		ColorChat(id, RED, "[AMXBans]^x01 %L",id,"NO_MOTD")
	}
	return PLUGIN_HANDLED
}
