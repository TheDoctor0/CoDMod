#if defined _colorchat_included
	#endinput
#endif
#define _colorchat_included


#define COLORCODE_NORMAL 0x01
#define COLORCODE_TEAM 0x03
#define COLORCODE_GREEN 0x04

enum Color {
	NORMAL = 1, // Yellow
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE, // Blue
}

new const ColorTeamName[][] = {
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

stock const ColorCodeType[] = {
	0x00,
	COLORCODE_NORMAL,
	COLORCODE_GREEN,
	COLORCODE_TEAM,
	COLORCODE_TEAM,
	COLORCODE_TEAM,
	COLORCODE_TEAM
}

public ColorChat(id, Color:type, const msg[], any:...) { // {Float,Sql,Result,_}
	static message[192];
	switch(type) {
		case NORMAL: message[0] = COLORCODE_NORMAL; // Yellow
		case GREEN: message[0] = COLORCODE_GREEN; // Green
		default: message[0] = COLORCODE_TEAM; // White, Red, Blue
	}
	vformat(message[1], 191, msg, 4);
	message[190] = '^0';
	new team, ColorChange;
	if(!id)	{
		new ColPlay[32], ColNum, i;
		get_players(ColPlay, ColNum);

		for(i=0; i<ColNum; ++i) {
			team = get_user_team(ColPlay[i]);
			ColorChange = ColorSelection(ColPlay[i], team, type);
			ShowColorMessage(ColPlay[i], message);
			if(ColorChange)
				ColorTeamInfo(ColPlay[i], ColorTeamName[team]);
		}
	}
	else {
		if(!is_user_connected(id))
			return;

		team = get_user_team(id);
		ColorChange = ColorSelection(id, team, type);
		ShowColorMessage(id, message);
		if(ColorChange)
			ColorTeamInfo(id, ColorTeamName[team]);
	}
}

ShowColorMessage(id, const message[]) {
	message_begin(MSG_ONE, 76, _, id);
	write_byte(id);
	write_string(message);
	message_end();
}

ColorTeamInfo(id, const szTeam[]) {
	message_begin(MSG_ONE, 86, _, id);
	write_byte(id);
	write_string(szTeam);
	message_end();
	return 1;
}

ColorSelection(id, iTeam, Color:Type) {
	switch(Type) {
		case RED: {
			if(iTeam != 1)
				return ColorTeamInfo(id, ColorTeamName[1]);
		}
		case BLUE: {
			if(iTeam != 2)
				return ColorTeamInfo(id, ColorTeamName[2]);
		}
		case GREY: {
			if(iTeam != 0 && iTeam != 3)
				return ColorTeamInfo(id, ColorTeamName[0]);
		}
	}
	return 0;
}
