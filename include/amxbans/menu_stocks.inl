/*

	AMXBans, managing bans for Half-Life modifications
	Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
	
	Copyright (C) 2009, 2010  Thomas Kurz

*/

#if defined _menu_stocks_included
    #endinput
#endif
#define _menu_stocks_included


#include <amxmodx>
#include <amxmisc>
#include <time>

stock MenuSetProps(id,menu,title[]) {
	new szText[64]
	if(g_coloredMenus)
		formatex(szText,charsmax(szText),"\r%L\w",id,title)
	else
		formatex(szText,charsmax(szText),"%L",id,title)
	menu_setprop(menu,MPROP_TITLE,szText)
	
	formatex(szText,charsmax(szText),"%L",id,"BACK")
	menu_setprop(menu,MPROP_BACKNAME,szText)
	formatex(szText,charsmax(szText),"%L",id,"MORE")
	menu_setprop(menu,MPROP_NEXTNAME,szText)
	formatex(szText,charsmax(szText),"%L",id,"EXIT")
	menu_setprop(menu,MPROP_EXITNAME,szText)
	//menu_setprop(menu,MPROP_PERPAGE,9)
}
/*******************************************************************************************************************/
stock MenuGetPlayers(menu,callback) {
	new szID[3],count
	
	for(new i=1;i <= plnum;i++) {
		if(!is_user_connected(i))
			continue
		count++
		get_user_name(i,g_PlayerName[i],charsmax(g_PlayerName[]))
		num_to_str(i,szID,charsmax(szID))
		menu_additem(menu,g_PlayerName[i],szID,0,callback)
	}
}

stock MenuGetBantime(id,menu) {
	if(!g_highbantimesnum || !g_lowbantimesnum) {
		log_amx("[AMXBans Notice] High or Low Bantimes empty, loading defaults")
		loadDefaultBantimes(0)
	}
	
	new szDisplay[128],szTime[11]
	// Admins with flag n or what HIGHER_BAN_TIME_ADMIN is set to, will get the higher ban times
	if (get_user_flags(id) & get_higher_ban_time_admin_flag()) {
		for(new i;i < g_highbantimesnum;i++) {
			get_bantime_string(id,g_HighBanMenuValues[i],szDisplay,charsmax(szDisplay))
			num_to_str(g_HighBanMenuValues[i],szTime,charsmax(szTime))
			menu_additem(menu,szDisplay,szTime)
		}
	} else {
		for(new i;i < g_lowbantimesnum;i++) {
			get_bantime_string(id,g_LowBanMenuValues[i],szDisplay,charsmax(szDisplay))
			num_to_str(g_LowBanMenuValues[i],szTime,charsmax(szTime))
			menu_additem(menu,szDisplay,szTime)
		}
	}
}
stock MenuGetReason(id,menu,staticBantime=0) {
	new rnum=ArraySize(g_banReasons)
	new szDisplay[128],szArId[3],szTime[64]
	
	new custom_static_time = get_pcvar_num(pcvar_custom_statictime)
	
	if(custom_static_time >= 0) {
		formatex(szDisplay,charsmax(szDisplay),"%L",id,"USER_REASON")
		if(staticBantime) {
			get_bantime_string(id,custom_static_time,szTime,charsmax(szTime))
			format(szDisplay,charsmax(szDisplay),"%s (%s)",szDisplay,szTime)
		}
		menu_additem(menu,szDisplay,"99")
	}
	
	for(new i;i < rnum;i++) {
		ArrayGetString(g_banReasons,i,szDisplay,charsmax(szDisplay))
		num_to_str(i,szArId,charsmax(szArId))
		if(staticBantime) {
			get_bantime_string(id,ArrayGetCell(g_banReasons_Bantime,i),szTime,charsmax(szTime))
			format(szDisplay,charsmax(szDisplay),"%s (%s)",szDisplay,szTime)
		} 
		menu_additem(menu,szDisplay,szArId)
	}
}
stock MenuGetFlagtime(id,menu) {
	if(!g_flagtimesnum) {
		log_amx("[AMXBans Notice] Flagtimes empty, loading defaults")
		loadDefaultBantimes(3)
	}
	
	new szDisplay[128],szTime[11]
	for(new i;i < g_flagtimesnum;i++) {
		get_flagtime_string(id,g_FlagMenuValues[i],szDisplay,charsmax(szDisplay))
		num_to_str(g_FlagMenuValues[i],szTime,charsmax(szTime))
		menu_additem(menu,szDisplay,szTime)
	}
}
/*******************************************************************************************************************/
public callback_MenuGetPlayers(id,menu,item) {
	new acc,szInfo[3],szText[128],callb
	menu_item_getinfo(menu,item,acc,szInfo,2,szText,127,callb)
	
	new pid=str_to_num(szInfo)
	
	new szStatus[64]
	if(g_coloredMenus) {
		if(!is_user_connected(pid)) format(szStatus,charsmax(szStatus),"%s \r(n.c.)\w",szStatus)
		if(is_user_admin(pid))	format(szStatus,charsmax(szStatus),"%s \r*\w",szStatus)
		if(is_user_bot(pid))	format(szStatus,charsmax(szStatus),"%s \r(BOT)\w",szStatus)
		if(is_user_hltv(pid))	format(szStatus,charsmax(szStatus),"%s \r(HLTV)\w",szStatus)
		if(g_being_flagged[pid])format(szStatus,charsmax(szStatus),"%s \r(%L)\w",szStatus,id,"FLAGGED")
	} else {
		if(!is_user_connected(pid)) format(szStatus,charsmax(szStatus),"%s (n.c.)",szStatus)
		if(is_user_admin(pid))	format(szStatus,charsmax(szStatus),"%s *",szStatus)
		if(is_user_bot(pid))	format(szStatus,charsmax(szStatus),"%s (BOT)",szStatus)
		if(is_user_hltv(pid))	format(szStatus,charsmax(szStatus),"%s (HLTV)",szStatus)
		if(g_being_flagged[pid])format(szStatus,charsmax(szStatus),"%s (%L)",szStatus,id,"FLAGGED")
	}
	
	formatex(szText,charsmax(szText),"%s %s",g_PlayerName[pid],szStatus)
	menu_item_setname(menu,item,szText)
	
	if(get_user_flags(pid) & ADMIN_IMMUNITY || is_user_bot(pid) || g_being_banned[pid] || !is_user_connected(pid)) return ITEM_DISABLED
	
	return ITEM_ENABLED
}
public callback_MenuBanType(id,menu,item) {
	new acc,szInfo[3],szText[128],callb
	menu_item_getinfo(menu,item,acc,szInfo,2,szText,127,callb)
	
	g_menuban_type[id]=str_to_num(szInfo[1])
	
	// toggle the menuban type
	// 0 ban and kick
	// 1 ban for next map
	// 2 ban and kick at next round
	new menutext[64]
	switch(g_menuban_type[id]) {
		case 1: {
			formatex(menutext,charsmax(menutext),"%L",id,"BT_BAN_NEXTMAP")
			g_menuban_type[id]=1
		}
		case 2: {
			if (g_supported_game)
			{
				formatex(menutext,charsmax(menutext),"%L",id,"BT_BAN_NEXTROUND")
				g_menuban_type[id]=2
			}
			else
			{
				formatex(menutext,charsmax(menutext),"%L",id,"BT_BAN_KICK")
				g_menuban_type[id]=0
			}
		}
		default: {
			formatex(menutext,charsmax(menutext),"%L",id,"BT_BAN_KICK")
			g_menuban_type[id]=0
		}
	}
	if(g_coloredMenus)
		format(menutext,charsmax(menutext),"\y%s\w",menutext)
	
	formatex(szInfo,charsmax(szInfo),"t%d",g_menuban_type[id])
	menu_item_setcmd(menu,item,szInfo)
	menu_item_setname(menu,item,menutext)
	
	return ITEM_ENABLED
}


/*******************************************************************************************************************/
stock get_bantime_string(id,btime,text[],len) {
	if(btime <=0 ) {
		formatex(text,len,"%L",id,"BAN_PERMANENT")
	} else {
		new szTime[64]
		get_time_length(id,btime,timeunit_minutes,szTime,charsmax(szTime))
		formatex(text,len,"%L",id,"BAN_FOR_MINUTES",szTime)
	}
}
stock get_flagtime_string(id,btime,text[],len,without=0) {
	if(btime <=0 ) {
		if(!without) {
			formatex(text,len,"%L",id,"FLAG_PERMANENT")
		} else {
			formatex(text,len,"%L",id,"PERMANENT")
		}
	} else {
		if(!without) {
			new szText[128]
			get_time_length(id,btime,timeunit_minutes,szText,charsmax(szText))
			formatex(text,len,"%L",id,"FLAG_FOR_MINUTES",szText)
		} else {
			get_time_length(id,btime,timeunit_minutes,text,len)
		}
	}
}
/*******************************************************************************************************************/
/*
user_viewing_menu() {
	new menu,newmenu,menupage

	for(new i=1;i<=pnum;i++) {
		if(!is_user_connected(i) || is_user_bot(i) || is_user_hltv(i)) continue
		
		if(player_menu_info(i,menu,newmenu,menupage)) {
			if(newmenu != -1) {
				client_print(i,print_chat,"[AMXBans] %L", LANG_PLAYER, "UPDATE_MENU", newmenu,menupage)
				menu_destroy(newmenu)
				menu_display(i,newmenu,menupage)
			} 
		}else {
			client_print(i,print_chat,"[AMXBans] %L", LANG_PLAYER, "NO_MENU_OPENED")
			
		}
	}
}
*/
/*******************************************************************************************************************/
get_ban_type(type[],len,steamid[],ip[]) {
	if(equal("HLTV", steamid)
	 || equal("STEAM_ID_LAN",steamid)
	 || equal("VALVE_ID_LAN",steamid)
	 || equal("VALVE_ID_PENDING",steamid)
	 || equal("STEAM_ID_PENDING",steamid)) {
		formatex(type,len,"SI")
	} else {
		formatex(type,len,"S")
	}
	if(equal(ip,"127.0.0.1") && equal(type,"SI"))
		return 0
	return 1
}

/*******************************************************************************************************************/
public setCustomBanReason(id,level,cid)
{
	if (!cmd_access(id,level,cid,1)) {
		return PLUGIN_HANDLED
	}

	if(!set_custom_reason[id]) return PLUGIN_HANDLED
	
	new szReason[128]
	read_argv(1,szReason,127)
	copy(g_choiceReason[id],127,szReason)
	
	set_custom_reason[id]=false
	
	if(get_pcvar_num(pcvar_debug) >= 2)
		log_amx("[AMXBans CustomReason] %d choice: %s (%d min)",id,g_choiceReason[id],g_choiceTime[id])
	
	if(g_in_flagging[id]){
		g_in_flagging[id]=false
		FlagPlayer(id)
	} else if(g_choicePlayerId[id] == -1) {
		//disconnected ban
		cmdMenuBanDisc(id)
	} else {
		cmdMenuBan(id)
	}
	return PLUGIN_HANDLED
}
