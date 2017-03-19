/*
Credits: 
CLAW for helping and testing
Pastout! for his cvar method from JailBreakMod plugins!
*/
#include <amxmodx>
#include <cstrike>

#if AMXX_VERSION_NUM <183
    #define MAX_PLAYERS 32
#endif

#pragma semicolon 1;

new const g_Info[][] =
{
	"Slots_Machine",
	"0.1.1",
	"eNd.",
	"skitaila03"
};

#define SLOTS 9
new g_iSlotsNumbers[MAX_PLAYERS+1][SLOTS];
new g_iSlotsPoints[MAX_PLAYERS+1];
new g_iBet[MAX_PLAYERS+1];
new bool:g_bFreeTry[MAX_PLAYERS+1];

enum _:Cvars 
{	
	cvar_prefix,
	cvar_try,
	cvar_freetry
};
new const cvar_names[Cvars][] = 
{
	"slots_prefix",		// Set the prefix
	"slots_try",		// Set the price for each try
	"slots_freetry"		// 1 - First try free On | 0 - First try free Off
};
new const cvar_defaults[Cvars][] = 
{
	"[SLOTS]",	// Set the prefix
	"100",		// Set the price for each try
	"1"		// 1 - First try free On | 0 - First try free Off
};
new cvar_pointer[Cvars];

public plugin_init()
{
	register_plugin(g_Info[0], g_Info[1], g_Info[random_num(2,3)] );

	register_clcmd( "say !slots", "ClCmd_Slots" );
	register_clcmd( "say_team !slots", "ClCmd_Slots" );

	for(new i = 0; i < Cvars; i++)
		cvar_pointer[i] = register_cvar(cvar_names[i] , cvar_defaults[i]);


	register_dictionary("slots_machine.txt");
}

public ClCmd_Slots(iPlayer)
{
	if(!is_user_connected(iPlayer)) 
		return PLUGIN_HANDLED;

	new szText[256];


	if( g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][1] && g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][2]
	&&  g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][4] &&  g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][5]
	&&  g_iSlotsNumbers[iPlayer][6] == g_iSlotsNumbers[iPlayer][7] &&  g_iSlotsNumbers[iPlayer][7] == g_iSlotsNumbers[iPlayer][8] )
	{
		/*
		1 1 1
		1 1 1
		1 1 1
		*/
		
		formatex(szText, charsmax(szText), "%L^n^n\r%i %i %i^n\r%i %i %i^n\r%i %i %i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else                  
	if( g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][1] && g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][2]
	&&  g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][4] &&  g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][5] )
	{
		/*
		1 1 1
		1 1 1
		0 0 0	
		*/
		formatex(szText, charsmax(szText), "%L^n^n\r%i %i %i^n\r%i %i %i^n\d%i %i %i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else                  
	if( g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][4] &&  g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][5]
	&&  g_iSlotsNumbers[iPlayer][6] == g_iSlotsNumbers[iPlayer][7] &&  g_iSlotsNumbers[iPlayer][7] == g_iSlotsNumbers[iPlayer][8] )
	{
		/*
		0 0 0
		1 1 1
		1 1 1
		*/
		formatex(szText, charsmax(szText), "%L^n^n\d%i %i %i^n\r%i %i %i^n\r%i %i %i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else                  
	if( g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][1] &&  g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][2]
	&&  g_iSlotsNumbers[iPlayer][6] == g_iSlotsNumbers[iPlayer][7] &&  g_iSlotsNumbers[iPlayer][7] == g_iSlotsNumbers[iPlayer][8] )
	{
		/*
		1 1 1
		0 0 0
		1 1 1
		*/
		formatex(szText, charsmax(szText), "%L^n^n\r%i %i %i^n\r%i %i %i^n\d%i %i %i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else                  
	if( g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][3] &&  g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][6]	
	&&  g_iSlotsNumbers[iPlayer][2] == g_iSlotsNumbers[iPlayer][5] &&  g_iSlotsNumbers[iPlayer][5] == g_iSlotsNumbers[iPlayer][8] )
	{
		/*
		1 0 1
		1 0 1
		1 0 1
		*/
		formatex(szText, charsmax(szText), "%L^n^n\r%i \d%i \r%i^n\r%i \d%i \r%i^n\r%i \d%i \r%i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else                  
	if( g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][3] &&  g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][6]
	&&  g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][4] &&  g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][7] )
	{
		/*
		1 1 0
		1 1 0
		1 1 0
		*/
		formatex(szText, charsmax(szText), "%L^n^n\r%i \r%i \d%i^n\r%i \r%i \d%i^n\r%i \r%i \d%i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else                  
	if( g_iSlotsNumbers[iPlayer][2] == g_iSlotsNumbers[iPlayer][5] &&  g_iSlotsNumbers[iPlayer][5] == g_iSlotsNumbers[iPlayer][8]
	&&  g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][4] &&  g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][7] )
	{
		/*
		0 1 1
		0 1 1
		0 1 1
		*/
		formatex(szText, charsmax(szText), "%L^n^n\d%i \r%i \r%i^n\d%i \r%i \r%i^n\d%i \r%i \r%i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else 
	if(g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][1] && g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][2])
	{
		/*
		1 1 1
		0 0 0
		0 0 0
		*/
		formatex(szText, charsmax(szText), "%L^n^n\r%i %i %i^n\d%i %i %i^n%i %i %i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else 
	if(g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][4] && g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][5])
	{
		/*
		0 0 0
		1 1 1
		0 0 0
		*/
		formatex(szText, charsmax(szText), "%L^n^n\d%i %i %i^n\r%i %i %i^n\d%i %i %i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else 
	if(g_iSlotsNumbers[iPlayer][6] == g_iSlotsNumbers[iPlayer][7] && g_iSlotsNumbers[iPlayer][7] == g_iSlotsNumbers[iPlayer][8])
	{
		/*
		0 0 0	
		0 0 0
		1 1 1
		*/
		formatex(szText, charsmax(szText), "%L^n^n\d%i %i %i^n\d%i %i %i^n\r%i %i %i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else 
	if(g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][3] && g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][6])
	{
		/*
		1 0 0
		1 0 0
		1 0 0
		*/
		formatex(szText, charsmax(szText), "%L^n^n\r%i \d%i %i^n\r%i \d%i %i^n\r%i \d%i %i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else 
	if(g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][4] && g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][7])
	{
		/*
		0 1 0
		0 1 0
		0 1 0  
		*/
               	formatex(szText, charsmax(szText), "%L^n^n\d%i \r%i \d%i^n\d%i \r%i \d%i^n\d%i \r%i \d%i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}   
                                
	else 
	if(g_iSlotsNumbers[iPlayer][2] == g_iSlotsNumbers[iPlayer][5] && g_iSlotsNumbers[iPlayer][5] == g_iSlotsNumbers[iPlayer][8])
	{
		/*
		0 0 1
		0 0 1
		0 0 1
		*/
               	formatex(szText, charsmax(szText), "%L^n^n\d%i \d%i \r%i^n\d%i \d%i \r%i^n\d%i \d%i \r%i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}      
                            
	else 
	if(g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][4] && g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][8])
	{
		/*
		1 0 0
		0 1 0
		0 0 1
		*/
               	formatex(szText, charsmax(szText), "%L^n^n\r%i \d%i %i^n\d%i \r%i \d%i^n\d%i \d%i \r%i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}    
                                   
	else 
	if(g_iSlotsNumbers[iPlayer][6] == g_iSlotsNumbers[iPlayer][4] && g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][2])
	{
		/*
		0 0 1
		0 1 0
		1 0 0
		*/
	        formatex(szText, charsmax(szText), "%L^n^n\d%i %i \r%i^n\d%i \r%i \d%i^n\r%i \d%i %i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );
		
	}

	else
		formatex(szText, charsmax(szText), "%L^n^n\d%i %i %i^n\d%i %i %i^n\d%i %i %i", LANG_SERVER, "SLOTS_TITLE", g_iSlotsPoints[iPlayer], g_iBet[iPlayer], g_iSlotsNumbers[iPlayer][0], g_iSlotsNumbers[iPlayer][1], g_iSlotsNumbers[iPlayer][2], g_iSlotsNumbers[iPlayer][3], g_iSlotsNumbers[iPlayer][4], g_iSlotsNumbers[iPlayer][5], g_iSlotsNumbers[iPlayer][6], g_iSlotsNumbers[iPlayer][7], g_iSlotsNumbers[iPlayer][8] );

	new slotsmenu = menu_create(szText, "sub_slotsmenu");

	formatex(szText, charsmax(szText), "%s%L", g_bFreeTry[iPlayer] ? "\rFree ":"", LANG_SERVER, "SLOTS_M1");
	menu_additem(slotsmenu, szText, "1", 0);

	formatex(szText, charsmax(szText), "%L", LANG_SERVER, "SLOTS_M2");
	menu_additem(slotsmenu, szText, "2", 0);

	formatex(szText, charsmax(szText), "%L", LANG_SERVER, "SLOTS_M3");
	menu_additem(slotsmenu, szText, "3", 0);

	formatex(szText, charsmax(szText), "%L", LANG_SERVER, "SLOTS_M4");
	menu_additem(slotsmenu, szText, "4", 0);

	formatex(szText, charsmax(szText), "%L", LANG_SERVER, "SLOTS_M5");
	menu_additem(slotsmenu, szText, "5", 0);

	menu_setprop(slotsmenu, MPROP_EXIT , MEXIT_ALL);
	menu_display(iPlayer, slotsmenu, 0);

	return PLUGIN_HANDLED;
}

public sub_slotsmenu(iPlayer, slotsmenu, item)  
{
	if(!is_user_connected(iPlayer)) 
		return PLUGIN_HANDLED;
			
	if (item == MENU_EXIT)
	{
		menu_destroy(slotsmenu);
		return PLUGIN_HANDLED;
	}


	new data[7], name[64];
	new access, callback;
	menu_item_getinfo(slotsmenu, item, access, data, charsmax(data), name, charsmax(name), callback);
	
	new Key = str_to_num(data);
	
	switch (Key)
	{
		case 1:
		{
			for(new slots=0; slots < SLOTS; ++slots)
			{
				g_iSlotsNumbers[iPlayer][slots] = random_num(SLOTS-SLOTS, SLOTS);
			}

			if(g_bFreeTry[iPlayer] && g_nCvar(cvar_freetry))
			{
				g_bFreeTry[iPlayer] = false;
				++g_iBet[iPlayer];
				for(new i=0; i < g_nCvar(cvar_try); ++i)
					++g_iSlotsPoints[iPlayer];	
			}

			if(g_iBet[iPlayer] < 1)
			{
				client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_BET");
				return PLUGIN_HANDLED;
			}

			if(g_iSlotsPoints[iPlayer] < g_nCvar(cvar_try) * g_iBet[iPlayer])
			{
				client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_MIN", g_nCvar(cvar_try) * g_iBet[iPlayer]);
				return PLUGIN_HANDLED;
			}

			prize_slots(iPlayer);
			ClCmd_Slots(iPlayer);	
		}
		case 2:
		{
			if(g_bFreeTry[iPlayer] && g_nCvar(cvar_freetry))
			{
				client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_FREETRY");
				return PLUGIN_HANDLED;
			}


			++g_iBet[iPlayer];
			ClCmd_Slots(iPlayer);
		}

		case 3:
		{
			if(g_bFreeTry[iPlayer] && g_nCvar(cvar_freetry))
			{
				client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_FREETRY");
				return PLUGIN_HANDLED;
			}

			--g_iBet[iPlayer];

			if(g_iBet[iPlayer] < 0)
				g_iBet[iPlayer] = 0;

			ClCmd_Slots(iPlayer);	
		}
		case 4:
		{
			if(g_bFreeTry[iPlayer] && g_nCvar(cvar_freetry))
			{
				client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_FREETRY");
				return PLUGIN_HANDLED;
			}

			for(new i=0; i < g_nCvar(cvar_try); ++i)
				++g_iSlotsPoints[iPlayer];	

			cs_set_user_money(iPlayer, cs_get_user_money(iPlayer)-g_nCvar(cvar_try));
			client_print(iPlayer, print_center, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_TOKENS", g_nCvar(cvar_try));
			ClCmd_Slots(iPlayer);
			
		}
		case 5:
		{
			if(g_bFreeTry[iPlayer] && g_nCvar(cvar_freetry))
			{
				client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_FREETRY");
				return PLUGIN_HANDLED;
			}

			if(cs_get_user_money(iPlayer)+g_iSlotsPoints[iPlayer] > 16000)
				cs_set_user_money(iPlayer, 16000);
			else
			cs_set_user_money(iPlayer, cs_get_user_money(iPlayer)+g_iSlotsPoints[iPlayer]);
		
			client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_SWITCH", g_iSlotsPoints[iPlayer]);
			g_iSlotsPoints[iPlayer] = 0;
			ClCmd_Slots( iPlayer );
		}
		
	}
	menu_destroy(slotsmenu);
	return PLUGIN_HANDLED;
}
	
prize_slots(iPlayer)
{
	if( g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][1] && g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][2]
	&&  g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][4] &&  g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][5]
	&&  g_iSlotsNumbers[iPlayer][6] == g_iSlotsNumbers[iPlayer][7] &&  g_iSlotsNumbers[iPlayer][7] == g_iSlotsNumbers[iPlayer][8] )
	{
		/*
		1 1 1
		1 1 1
  		1 1 1
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * SLOTS;
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS, g_nCvar(cvar_try) * g_iBet[iPlayer] * SLOTS);
	}
	else                  
	if( g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][1] && g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][2]
	&&  g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][4] &&  g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][5] )
	{
		/*
		1 1 1
		1 1 1
		0 0 0
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-3, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3));
	}
	else                  
	if( g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][4] &&  g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][5]
	&&  g_iSlotsNumbers[iPlayer][6] == g_iSlotsNumbers[iPlayer][7] &&  g_iSlotsNumbers[iPlayer][7] == g_iSlotsNumbers[iPlayer][8] )
	{
		/*
		0 0 0
		1 1 1
		1 1 1
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-3, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3));
	}
	else                  
	if( g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][1] &&  g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][2]
	&&  g_iSlotsNumbers[iPlayer][6] == g_iSlotsNumbers[iPlayer][7] &&  g_iSlotsNumbers[iPlayer][7] == g_iSlotsNumbers[iPlayer][8] )
	{
		/*
		1 1 1
		0 0 0
		1 1 1
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-3, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3));
	}
	else                  
	if( g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][3] &&  g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][6]
	&&  g_iSlotsNumbers[iPlayer][2] == g_iSlotsNumbers[iPlayer][5] &&  g_iSlotsNumbers[iPlayer][5] == g_iSlotsNumbers[iPlayer][8] )
	{
		/*
		1 0 1
		1 0 1
		1 0 1
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-3, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3));
	}
	else                  	
	if( g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][3] &&  g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][6]
	&&  g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][4] &&  g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][7] )
	{
		/*
		1 1 0
		1 1 0
		1 1 0
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-3, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3));
	}
	else    	              
	if( g_iSlotsNumbers[iPlayer][2] == g_iSlotsNumbers[iPlayer][5] &&  g_iSlotsNumbers[iPlayer][5] == g_iSlotsNumbers[iPlayer][8]
	&&  g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][4] &&  g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][7] )
	{
		/*	
		0 1 1
		0 1 1
		0 1 1
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-6, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-3));
	}
	else 
	if(g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][1] && g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][2])
	{
		/*
		1 1 1
		0 0 0
		0 0 0
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-6, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6));
	}
	else 
	if(g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][4] && g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][5])
	{
		/*
		0 0 0
		1 1 1
		0 0 0
		*/


		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-6, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6));
	}
	else 
	if(g_iSlotsNumbers[iPlayer][6] == g_iSlotsNumbers[iPlayer][7] && g_iSlotsNumbers[iPlayer][7] == g_iSlotsNumbers[iPlayer][8])
	{
		/*
		0 0 0
		0 0 0
		1 1 1
		*/


		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-6, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6));
	}
	else 
	if(g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][3] && g_iSlotsNumbers[iPlayer][3] == g_iSlotsNumbers[iPlayer][6])
	{
		/*
		1 0 0
		1 0 0
		1 0 0
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-6, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6));
	}
	else 
	if(g_iSlotsNumbers[iPlayer][1] == g_iSlotsNumbers[iPlayer][4] && g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][7])
	{
		/*
		0 1 0
		0 1 0
		0 1 0  
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-6, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6));                 
	}                                   
	else 
	if(g_iSlotsNumbers[iPlayer][2] == g_iSlotsNumbers[iPlayer][5] && g_iSlotsNumbers[iPlayer][5] == g_iSlotsNumbers[iPlayer][8])
	{
		/*
		0 0 1
		0 0 1
		0 0 1
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-6, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6));
	}                                  
	else 
	if(g_iSlotsNumbers[iPlayer][0] == g_iSlotsNumbers[iPlayer][4] && g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][8])
	{
		/*
		1 0 0
		0 1 0
		0 0 1
		*/

		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-6, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6));
	}                                       
	else 
	if(g_iSlotsNumbers[iPlayer][6] == g_iSlotsNumbers[iPlayer][4] && g_iSlotsNumbers[iPlayer][4] == g_iSlotsNumbers[iPlayer][2])
	{
		/*
		0 0 1
		0 1 0
		1 0 0
		*/
		
		g_iSlotsPoints[iPlayer] += g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6);
		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_WINNER", g_iBet[iPlayer], SLOTS-6, g_nCvar(cvar_try) * g_iBet[iPlayer] * (SLOTS-6));
	}
	else
	{
		if(g_iSlotsPoints[iPlayer] < 0)
			g_iSlotsPoints[iPlayer] = 0;
		else
			g_iSlotsPoints[iPlayer] -= g_nCvar(cvar_try) * g_iBet[iPlayer];


		client_print(iPlayer, print_chat, "%s %L", g_sCvar(cvar_prefix), LANG_SERVER, "SLOTS_LOOSER", g_nCvar(cvar_try) * g_iBet[iPlayer]);
	}
}

public client_putinserver(iPlayer)
{
	if(!is_user_connected(iPlayer))
		return PLUGIN_HANDLED;

	if(!g_bFreeTry[iPlayer] && g_nCvar(cvar_freetry))
		g_bFreeTry[iPlayer] = true;


	return PLUGIN_CONTINUE;
}
public client_disconnect(iPlayer)
{
	if(!is_user_connected(iPlayer))
		return PLUGIN_HANDLED;
	
	if(g_bFreeTry[iPlayer] && g_nCvar(cvar_freetry))
		g_bFreeTry[iPlayer] = false;

	if(g_iSlotsPoints[iPlayer])
		g_iSlotsPoints[iPlayer] = 0;

	for(new slots=0; slots < SLOTS; ++slots)
		g_iSlotsNumbers[iPlayer][slots] = 0;

	return PLUGIN_CONTINUE;
}

g_sCvar( cvar )
{
	new sCvar[ MAX_PLAYERS ];
	get_pcvar_string(cvar_pointer[ cvar ], sCvar, charsmax( sCvar ));
	return sCvar;
}
g_nCvar( cvar )
{
        static nCvar;
        nCvar = get_pcvar_num(cvar_pointer[ cvar ]);
        return nCvar;
}

