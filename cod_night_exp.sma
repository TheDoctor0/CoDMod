#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Night Exp"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define Minute(%1) ((%1)*60.0)

new bool:bActive;

new cvarFrom, cvarTo, cvarKill, cvarKillHS, cvarDamage, cvarWin, cvarPlant, cvarDefuse, cvarHostage;

new iFrom, iTo, iKill, iKillHS, iDamage, iWin, iPlant, iDefuse, iHostage;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cvarFrom = register_cvar("cod_night_exp_from", "22");
	cvarTo = register_cvar("cod_night_exp_to", "8");
	cvarKill = register_cvar("cod_night_exp_kill", "20");
	cvarKillHS = register_cvar("cod_night_exp_killhs", "20");
	cvarDamage = register_cvar("cod_night_exp_damage", "6");
	cvarWin = register_cvar("cod_night_exp_win", "50");
	cvarPlant = register_cvar("cod_night_exp_plant", "50");
	cvarDefuse = register_cvar("cod_night_exp_defuse", "50");
	cvarHostage = register_cvar("cod_night_exp_hostage", "50");
	
	set_task(1.0, "CheckTime");
	
	set_task(300.0, "ShowInfo", _, _, _, "b");
}

public plugin_cfg()
{
	iFrom = get_pcvar_num(cvarFrom);
	iTo = get_pcvar_num(cvarTo);
	iKill = get_pcvar_num(cvarKill);
	iKillHS = get_pcvar_num(cvarKillHS);
	iDamage = get_pcvar_num(cvarDamage);
	iWin = get_pcvar_num(cvarWin);
	iPlant = get_pcvar_num(cvarPlant);
	iDefuse = get_pcvar_num(cvarDefuse);
	iHostage = get_pcvar_num(cvarHostage);
}

public CheckTime()	
{
	new szTime[3], iTime;

	get_time("%H", szTime, charsmax(szTime));
	
	iTime = str_to_num(szTime);
	
	if(iFrom > iTo)
	{
		if(iTime >= iFrom || iTime < iTo)
			bActive = true;	
	}
	else
	{
		if(iTime >= iFrom && iTime < iTo)
			bActive = true;	
	}
	
	if(bActive)	
	{
		server_cmd("cod_exp_kill %i;cod_exp_killhs %i;cod_exp_damage %i;cod_exp_win %i;cod_exp_plant %i;cod_exp_defuse %i;cod_exp_hostage %i", iKill, iKillHS, iDamage, iWin, iPlant, iDefuse, iHostage);
		return;
	}
	
	get_time("%M", szTime, 2);
	
	iTime = str_to_num(szTime);
	
	set_task(Minute(60 - iTime), "CheckTime");
}

public ShowInfo()
{
	if(bActive)
		cod_print_chat(0, DontChange, "Na serwerze wlaczony jest nocny^x03 EXP x 2^x01!");
	else
		cod_print_chat(0, DontChange, "Od godziny %i do %i na serwerze jest^x03 EXP x 2^x01!", iFrom, iTo);
}