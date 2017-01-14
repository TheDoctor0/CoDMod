#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Rewards"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new cvarFirstReward, cvarSecondReward, cvarThirdReward;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cvarFirstReward = register_cvar("cod_first_reward", "300");
	cvarSecondReward = register_cvar("cod_second_reward", "200");
	cvarThirdReward = register_cvar("cod_third_reward", "100");
	
	register_message(SVC_INTERMISSION, "MsgIntermission");
}
	
public MsgIntermission() 
{
	new szName[32], szPlayers[32], iBestID[3], iBestFrags[3], id, iNum, iTempFrags, iSwapFrags, iSwapID, iExp;
	get_players(szPlayers, iNum, "h");
	
	if(iNum < 1)
		return PLUGIN_CONTINUE;
		
	for (new i = 0; i < iNum; i++)
	{
		id = szPlayers[i];
		
		if(!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id))
			continue;
		
		iTempFrags = get_user_frags(id);
		
		if(iTempFrags > iBestFrags[0])
		{
			iBestFrags[0] = iTempFrags;
			iBestID[0] = id;
			if(iTempFrags > iBestFrags[1])
			{
				iSwapFrags = iBestFrags[1];
				iSwapID = iBestID[1];
				iBestFrags[1] = iTempFrags;
				iBestID[1] = id;
				iBestFrags[0] = iSwapFrags;
				iBestID[0] = iSwapID;
				
				if(iTempFrags > iBestFrags[2])
				{
					iSwapFrags = iBestFrags[2];
					iSwapID = iBestID[2];
					iBestFrags[2] = iTempFrags;
					iBestID[2] = id;
					iBestFrags[1] = iSwapFrags;
					iBestID[1] = iSwapID;
				}
			}
		}
	}
	
	if(!iBestID[2])
		return PLUGIN_CONTINUE;
	
	cod_print_chat(0, DontChange, "Gratulacje dla^x04 najlepszych graczy^x01!");
	
	for(new i = 2; i >= 0; i--)
	{
		switch(i)
		{
			case 0: iExp = get_pcvar_num(cvarThirdReward);
			case 1: iExp = get_pcvar_num(cvarSecondReward);
			case 2: iExp = get_pcvar_num(cvarFirstReward);
		}
		
		cod_set_user_exp(iBestID[i], cod_get_user_exp(iBestID[i]) + iExp);
		
		get_user_name(iBestID[i], szName, 31);
		cod_print_chat(0, DontChange, "^x04 %s^x01 - +%i Doswiadczenia -^x04 %i^x01 Zabojstw.", szName, iExp, iBestFrags[i]);
	}
	
	return PLUGIN_CONTINUE;
}