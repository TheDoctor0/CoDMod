#if defined _tutor_included
#endinput
#endif
#define _tutor_included

#if !defined _amxmodx_included
#include <amxmodx>
#endif

#define TASK_TUTOR 467666646

enum TutorColor 
{ 
	TUTOR_RED = 1, 
	TUTOR_BLUE, 
	TUTOR_YELLOW, 
	TUTOR_GREEN
}

new const g_TutorPrecache[][] = { "gfx/career/icon_!.tga", "gfx/career/icon_!-bigger.tga", "gfx/career/icon_i.tga", "gfx/career/icon_i-bigger.tga", "gfx/career/icon_skulls.tga", "gfx/career/round_corner_ne.tga", "gfx/career/round_corner_nw.tga", "gfx/career/round_corner_se.tga", "gfx/career/round_corner_sw.tga", "resource/TutorScheme.res", "resource/UI/TutorTextWindow.res" }

new g_MsgTutor
new g_MsgTutClose
new tutor_g_iMaxPlayers;

stock tutorInit(){
	g_MsgTutor = get_user_msgid("TutorText");
	g_MsgTutClose = get_user_msgid("TutorClose");
	
	tutor_g_iMaxPlayers = get_maxplayers();
}

stock tutorPrecache(){
	for(new i = 0; i < sizeof g_TutorPrecache; i++) 
	{	
		precache_generic(g_TutorPrecache[i]);
	}
}

stock tutorMake(id,TutorColor:Color,Float:fTime = 0.0,const szText[],any:...){
	new szMessage[512];
	vformat(szMessage, charsmax(szMessage), szText, 5);
	
	if(!id){
		message_begin(MSG_ALL,g_MsgTutor);
		write_string(szMessage);
		write_byte(0);
		write_short(0);
		write_short(0);
		write_short(1<<_:Color);
		message_end();
	}
	else if(is_user_connected(id))
	{
		message_begin(MSG_ONE_UNRELIABLE,g_MsgTutor,_,id);
		write_string(szMessage);
		write_byte(0);
		write_short(0);
		write_short(0);
		write_short(1<<_:Color);
		message_end();
	}
	
	if(fTime != 0.0){
		if(!id){
			for(new i = 1; i <= tutor_g_iMaxPlayers; i++)
			remove_task(i+TASK_TUTOR);
			
			
			set_task(fTime,"tutorClose",TASK_TUTOR)
		}
		else
		{
			remove_task(id+TASK_TUTOR)
			set_task(fTime,"tutorClose",id+TASK_TUTOR)
		}
	}
}

public tutorClose(iTask){
	new id = iTask - TASK_TUTOR;
	
	if(!id){
		message_begin(MSG_ALL,g_MsgTutClose)
		message_end()
	}
	else if(is_user_connected(id))
	{
		message_begin(MSG_ONE_UNRELIABLE,g_MsgTutClose,_,id)
		message_end()
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
