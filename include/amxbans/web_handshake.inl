/*

	AMXBans, managing bans for Half-Life modifications
	Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
	
	Copyright (C) 2009, 2010  Thomas Kurz

*/

#if defined _web_handshake_included
    #endinput
#endif
#define _web_handshake_included

#include <amxmodx>

public cmdLst(id,level,cid)
{
	if(id) 
		return PLUGIN_HANDLED
	
	new name[32],authid[35],ip[22],status,immun,userid
		
	//console_print(id,"%c%c%c%c",-1,-1,-1,-1)
	
	for(new pid = 1; pid <= plnum; pid++)
	{
		if(is_user_connected(pid)) {
			get_user_name(pid,name,charsmax(name))
			get_user_ip(pid,ip,charsmax(ip),1)
			get_user_authid(pid,authid,charsmax(authid))
			userid=get_user_userid(pid)
			
			status=0
			if(is_user_bot(pid))
				status=1
			if(is_user_hltv(pid))
				status=2
			
			immun=0
			if(get_user_flags(pid) & ADMIN_IMMUNITY)
				immun=1
			
			console_print(id,"%s%c%d%c%s%c%s%c%d%c%d",name,-4,userid,-4,authid,-4,ip,-4,status,-4,immun)
		}
	}
	return PLUGIN_HANDLED
}
