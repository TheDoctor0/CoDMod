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
	
	register_message(SVC_INTERMISSION, "message_intermission");
}
	
public message_intermission() 
{
	enum _:winers { THIRD, SECOND, FIRST };
	
	new playerName[32], playersList[32], winnersId[3], winnersFrags[3], tempFrags, swapFrags, swapId, id, players, exp;

	get_players(playersList, players, "h");
	
	if(!players) return;

	for(new i = 0; i < players; i++)
	{
		id = playersList[i];
		
		if(!is_user_connected(id) || is_user_hltv(id) || is_user_bot(id)) continue;
		
		tempFrags = get_user_frags(id);
		
		if(tempFrags > winnersFrags[THIRD])
		{
			winnersFrags[THIRD] = tempFrags;
			winnersId[THIRD] = id;
			
			if(tempFrags > winnersFrags[SECOND])
			{
				swapFrags = winnersFrags[SECOND];
				swapId = winnersId[SECOND];
				winnersFrags[SECOND] = tempFrags;
				winnersId[SECOND] = id;
				winnersFrags[THIRD] = swapFrags;
				winnersId[THIRD] = swapId;
				
				if(tempFrags > winnersFrags[FIRST])
				{
					swapFrags = winnersFrags[FIRST];
					swapId = winnersId[FIRST];
					winnersFrags[FIRST] = tempFrags;
					winnersId[FIRST] = id;
					winnersFrags[SECOND] = swapFrags;
					winnersId[SECOND] = swapId;
				}
			}
		}
	}
	
	if(!winnersId[FIRST]) return;
	
	cod_print_chat(0, "Gratulacje dla^x03 Najlepszych Graczy^x01!");
	
	for(new i = 2; i >= 0; i--)
	{
		switch(i)
		{
			case THIRD: exp = get_pcvar_num(cvarThirdReward);
			case SECOND: exp = get_pcvar_num(cvarSecondReward);
			case FIRST: exp = get_pcvar_num(cvarFirstReward);
		}
		
		cod_set_user_exp(winnersId[i], cod_get_user_exp(winnersId[i]) + exp);
		
		get_user_name(winnersId[i], playerName, charsmax(playerName));

		cod_print_chat(0, "^x03 %s^x01 - +%i Doswiadczenia -^x03 %i^x01 Zabojstw.", playerName, exp, winnersFrags[i]);
	}
	
	return PLUGIN_CONTINUE;
}