/*

	AMXBans, managing bans for Half-Life modifications
	Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
	
	Copyright (C) 2009, 2010  Thomas Kurz

	Color Chat Inc
	refer to http://forums.alliedmods.net/showthread.php?t=45753
	credits: teame06

	^x01 is Yellow
	^x03 is Team Color. Ie. Red (Terrorist) or blue (Counter-Terrorist) or grey (SPECTATOR or UNASSIGNED).
	^x04 is Green
*/

#if defined _color_chat_included
    #endinput
#endif
#define _color_chat_included

#include <amxmodx>

enum Color
{
	YELLOW = 1, // Yellow
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE, // Blue
}

new TeamInfo;
new SayText;

new TeamName[][] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}


public color_chat_init()
{
	TeamInfo = get_user_msgid("TeamInfo");
	SayText = get_user_msgid("SayText");
}

public ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)
{
	new message[ 192 ];

	switch(type)
	{
		case YELLOW: // Yellow
		{
			message[0] = 0x01;
		}
		case GREEN: // Green
		{
			message[0] = 0x04;
		}
		default: // White, Red, Blue
		{
			message[0] = 0x03;
		}
	}

	vformat(message[1], 191, msg, 4);

	// Make sure message is not longer than 192 character. Will crash the server.
	message[189] = '^0';

	new team, ColorChange, index, MSG_Type;
	
	if(!id)
	{
		index = FindPlayer();
		MSG_Type = MSG_ALL;
	
	} else {
		MSG_Type = MSG_ONE;
		index = id;
	}
	
	team = get_user_team(index);	
	ColorChange = ColorSelection(index, MSG_Type, type);

	ShowColorMessage(index, MSG_Type, message);
		
	if(ColorChange)
	{
		Team_Info(index, MSG_Type, TeamName[team]);
	}
}

ShowColorMessage(id, type, message[])
{
	message_begin(type, SayText, _, id);
	write_byte(id)		
	write_string(message);
	message_end();	
}

Team_Info(id, type, team[])
{
	message_begin(type, TeamInfo, _, id);
	write_byte(id);
	write_string(team);
	message_end();

	return 1;
}

ColorSelection(index, type, Color:Type)
{
	switch(Type)
	{
		case RED:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case BLUE:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		case GREY:
		{
			return Team_Info(index, type, TeamName[0]);
		}
	}

	return 0;
}

FindPlayer()
{
	new i = -1;

	while(i <= plnum)
	{
		if(is_user_connected(++i))
		{
			return i;
		}
	}

	return -1;
}
