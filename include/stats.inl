#include <amxmodx>
#include <amxmisc>

new Float:gfAntiFlood[33];

register_fullclcmd(const szName[], const szFunction[]){
	new szName2[64];
	
	register_clcmd(szName, szFunction);
	
	formatex(szName2, charsmax(szName2), "say /%s", szName);
	register_clcmd(szName2, szFunction);
	
	formatex(szName2, charsmax(szName2), "say_team /%s", szName);
	register_clcmd(szName2, szFunction);
}
STDRES(){
	new szCmd[4];
	read_argv(0, szCmd, 3);
	return equal(szCmd, "say")?PLUGIN_CONTINUE:PLUGIN_HANDLED;
}
flood(id){
	new fl = 0;
	new Float:fNow = get_gametime()
	if((fNow-gfAntiFlood[id]) < 1.0)
		fl = 1
		
	gfAntiFlood[id] = fNow;
	return fl;
}
public showRank(id){
	if(flood(id)){
		client_print(id, print_center, "%L", id, "STATS_TRY_LATER");
		return PLUGIN_HANDLED;
	}
		
	if(giBestTime[id] == 0)
		ColorChat(id, RED, "%s^x01 %L", gszChatPrefix, id, "NEVER_REACH_FINISH");
	else{
		client_print(id, print_chat, "%L", id, "STATS_LOADING");
		loadRank(id, "_showRank");
	}
	
	return STDRES();
}
public _showRank(id, rank){
	new iTime = giBestTime[id];
	
	new szTime[32];
	getFormatedTime(iTime, szTime, charsmax(szTime));
	
	ColorChat(id, RED, "%s^x01 %L ^x04 %s", gszChatPrefix, id, "STATS_RANKED", rank, szTime);
}

public showTop15(id){
	if(flood(id)){
		client_print(id, print_center, "%L", id, "STATS_TRY_LATER");
		return PLUGIN_HANDLED;
	}
	
	if(gszTop15Redirect[0])
		show_motd(id, gszTop15Redirect, "Top15");
	else{
		client_print(id, print_chat, "%L", id, "STATS_LOADING");
		loadNshowTop15(id);
	}
	
	return STDRES();
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
