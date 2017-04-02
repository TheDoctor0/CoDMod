/* ColorStatus
*
* by DarkGL
*
* This file is provided as is (no warranties).
*/

#define STATUS_TASK 	486784986
#define STATUS_TASK2 	471231345

enum COLOR_STATUS{
	RED_STATUS,
	BLUE_STATUS,
	YELLOW_STATUS,
	GREY_STATUS
}

new msgStatusText;
new msgStatusValue;
new msgSayText;

//prefix _colorStatus_

new oldTeam[33],MSG_TYPE[33],Float:fTimeColor[33];

stock initColorStatus(){
	msgStatusText 	= 	get_user_msgid("StatusText");
	msgStatusValue 	= 	get_user_msgid("StatusValue");
	msgSayText	=	get_user_msgid("SayText");
	
	register_message(get_user_msgid("StatusText"),"ColorStatusText");
	register_message(get_user_msgid("StatusValue"),"ColorStatusValue");
}

public ColorStatusText(msgID, msgDest,msgEnt){
	if(!msgEnt || msgDest == MSG_ALL){
		
		new Float:fTime,szRet[256];
		
		get_msg_arg_string(2,szRet,charsmax(szRet));
		
		for(new i = 1;i<33;i++){
			if(!is_user_connected(i))	continue;
			
			fTime = fTimeColor[i] > fTimeColor[0] ? fTimeColor[i] : fTimeColor[0];
			
			if(fTime >= get_gametime() || fTime == -1.0)	continue;
			
			message_begin(MSG_ONE,msgStatusText,_,i);
			write_byte(0);
			write_string(szRet);
			message_end();
		}
		
		return PLUGIN_HANDLED;
	}
	else if(is_user_connected(msgEnt)){
		if(fTimeColor[msgEnt] >= get_gametime() || fTimeColor[msgEnt] == -1.0)	return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public ColorStatusValue(msgID, msgDest,msgEnt){
	if(!msgEnt || msgDest == MSG_ALL){
		
		new Float:fTime,szRet[256];
		
		get_msg_arg_string(2,szRet,charsmax(szRet));
		
		for(new i = 1;i<33;i++){
			if(!is_user_connected(i))	continue;
			
			fTime = fTimeColor[i] > fTimeColor[0] ? fTimeColor[i] : fTimeColor[0];
			
			if(fTime >= get_gametime() || fTime == -1.0)	continue;
			
			message_begin(MSG_ONE,msgStatusValue,_,i);
			write_byte(get_msg_arg_int(1));
			write_short(get_msg_arg_int(2));
			message_end();
		}
		
		return PLUGIN_HANDLED;
	}
	else if(is_user_connected(msgEnt)){
		if(fTimeColor[msgEnt] >= get_gametime() || fTimeColor[msgEnt] == -1.0)	return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

stock makeStatusText(id,COLOR_STATUS:color,Float:fTime = 0.0,const szText[] = "",any:...){
	new szTextFormated[197];
	
	vformat(szTextFormated, charsmax(szTextFormated), szText, 5);
	
	
	if(id)
	{
		MSG_TYPE[id] = MSG_ONE;
		fTimeColor[id] = !fTime ? -1.0 : get_gametime() + fTime;
	} else {
		id = FindPlayerStatus();
		MSG_TYPE[id] = MSG_ALL;
		
		if(id == -1)	return ;
		
		fTimeColor[0] = !fTime ? -1.0 : get_gametime() + fTime;
		
	}
	
	if(color == YELLOW_STATUS){
		message_begin(MSG_TYPE[id],msgStatusText,_,id);
		write_byte(0);
		write_string(szTextFormated);
		message_end();
		
		return ;
	}
	
	format(szTextFormated, charsmax(szTextFormated),"%s%s","%p2",szTextFormated);
	
	set_msg_block(msgSayText, BLOCK_ONCE);
	
	message_begin(MSG_TYPE[id],msgStatusText,_,id);
	write_byte(0);
	write_string(szTextFormated);
	message_end();
	
	oldTeam[id] = get_user_team(id);
	
	setTeamMessage(id,color == RED_STATUS ? 1 : color == BLUE_STATUS ? 2 : 3,MSG_TYPE[id]);
	
	message_begin(MSG_TYPE[id],msgStatusValue,_,id);
	write_byte(2);
	write_short(id);
	message_end();
	
	remove_task(id+STATUS_TASK);
	remove_task(id+STATUS_TASK2);
	
	set_task(0.1,"returnToStatus",id+STATUS_TASK);
	if(fTime != 0.0)	set_task(fTime,"deleteStatus",MSG_TYPE[id] == MSG_ALL ? STATUS_TASK2 : id+STATUS_TASK2);
}

public deleteStatus(id){
	id-=STATUS_TASK2;
	
	new Float:fTime;
	
	if(!id){
		for(new i = 1;i<33;i++){
			if(!is_user_connected(i))	continue;
			
			fTime = fTimeColor[i] > fTimeColor[0] ? fTimeColor[i] : fTimeColor[0];
			
			if(fTime >= get_gametime() || fTime == -1.0)	continue;
			
			message_begin(MSG_ONE,msgStatusText,_,i);
			write_byte(0);
			write_string("");
			message_end();
			
			message_begin(MSG_ONE,msgStatusValue,_,i);
			write_byte(1);
			write_short(0);
			message_end();
			
			message_begin(MSG_ONE,msgStatusValue,_,i);
			write_byte(2);
			write_short(0);
			message_end();
			
			message_begin(MSG_ONE,msgStatusValue,_,i);
			write_byte(3);
			write_short(0);
			message_end();
		}
	}
	else if(is_user_connected(id)){
		fTime = fTimeColor[id] > fTimeColor[0] ? fTimeColor[id] : fTimeColor[0];
		
		if(fTime >= get_gametime() || fTime == -1.0)	return ;
		
		message_begin(MSG_ONE,msgStatusText,_,id);
		write_byte(0);
		write_string("");
		message_end();
		
		message_begin(MSG_ONE,msgStatusValue,_,id);
		write_byte(1);
		write_short(0);
		message_end();
		
		message_begin(MSG_ONE,msgStatusValue,_,id);
		write_byte(2);
		write_short(0);
		message_end();
		
		message_begin(MSG_ONE,msgStatusValue,_,id);
		write_byte(3);
		write_short(0);
		message_end();
	}
}

public returnToStatus(id){
	id-=STATUS_TASK;
	
	set_msg_block(msgSayText, BLOCK_ONCE);
	
	setTeamMessage(id,oldTeam[id],MSG_TYPE[id]);
}

stock setTeamMessage(id, team,type){
	static msgTeamInfo;
	
	if(!msgTeamInfo)	msgTeamInfo = get_user_msgid("TeamInfo");
	
	static TeamName[][] = 
	{
		"",
		"TERRORIST",
		"CT",
		"SPECTATOR"
	};

	message_begin(type, msgTeamInfo, _, id);
	write_byte(id);
	write_string(TeamName[team]);
	message_end();
}

stock FindPlayerStatus()
{
	static maxPlayers;
	static i;
	i = -1;

	if(!maxPlayers)	maxPlayers = get_maxplayers();

	while(i <= maxPlayers)
	{
		if(is_user_connected(++i))
		{
			return i;
		}
	}

	return -1;
}
