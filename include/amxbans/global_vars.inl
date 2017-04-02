/*

	AMXBans, managing bans for Half-Life modifications
	Copyright (C) 2003, 2004  Ronald Renes / Jeroen de Rover
	
	Copyright (C) 2009, 2010  Thomas Kurz

*/

//db table defines, no need to change something
new const tbl_serverinfo[] = "_serverinfo";
new const tbl_reasons[] = "_reasons";
new const tbl_reasons_to_set[] = "_reasons_to_set";
new const tbl_bans[] = "_bans";
new const tbl_flagged[] = "_flagged";

// global
new plnum;
new g_ip[32];
new g_port[10];
new bool:g_kicked_by_amxbans[33];
new bool:g_being_banned[33];
new bool:g_supported_game = true;

//forwards
enum MFHandles
{
	Ban_MotdOpen,
	Player_Flagged,
	Player_UnFlagged
}
new MFHandle[MFHandles];

// For hudmessages
new g_MyMsgSync;

// Variables for menus
new g_coloredMenus;
new bool:g_in_flagging[33];
new bool:set_custom_reason[33];

new g_menuban_type[33]; // 0 ban and kick, 1 ban for next map, 2 ban and kick at next round
new bool:g_nextround_kick[33];
//new g_nextround_kick_time[33];
new g_nextround_kick_bid[33];
//new g_nextround_kick_Reason[33][128];

new g_PlayerName[33][32];
new g_choicePlayerName[33][32];
new g_choicePlayerAuthid[33][35];
new g_choicePlayerIp[33][22];
new g_choicePlayerId[33];
new g_choiceTime[33];
new g_choiceReason[33][128];
new g_ban_type[33][3];
new g_ident[50];

new Array:g_banReasons;
new Array:g_banReasons_Bantime;

// flagging
new bool:g_being_flagged[33];
new g_flaggedReason[33][128];
new g_flaggedTime[33];

/*****************************/

// pcvars

new pcvar_serverip;
new pcvar_server_nick;
new pcvar_discon_in_banlist;
new pcvar_complainurl;
new pcvar_debug;
new pcvar_add_mapname;
new pcvar_flagged_all;
new pcvar_show_in_hlsw;
new pcvar_show_hud_messages;
new pcvar_higher_ban_time_admin;
new pcvar_admin_mole_access;
new pcvar_show_name_evenif_mole;
new pcvar_custom_statictime;
new pcvar_show_prebanned;
new pcvar_show_prebanned_num;
new pcvar_default_banreason;

new pcvar_extendedbanmenu;

/*****************************/

// SQL

new Handle:g_SqlX;
new g_dbPrefix[32];

new Float:kick_delay = 10.0; //motd_delay from DB

/*****************************/

// disconnected Player

new Array:g_disconPLname;
new Array:g_disconPLauthid;
new Array:g_disconPLip;

new g_highbantimesnum;
new g_lowbantimesnum;
new g_flagtimesnum;
new g_HighBanMenuValues[14];
new g_LowBanMenuValues[14];
new g_FlagMenuValues[14];