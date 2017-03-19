#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Night Exp"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define Minute(%1) ((%1)*60.0)

new cvarFrom, cvarTo, cvarKill, cvarKillHS, cvarDamage, cvarWin, cvarPlant, cvarDefuse, cvarHostage;

new bool:expActive, expFrom, expTo, expKill, expKillHS, expDamage, expWin, expPlant, expDefuse, expHostage;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cvarFrom = register_cvar("cod_night_exp_from", "22");
	cvarTo = register_cvar("cod_night_exp_to", "8");
	cvarKill = register_cvar("cod_night_exp_kill", "20");
	cvarKillHS = register_cvar("cod_night_exp_killhs", "20");
	cvarDamage = register_cvar("cod_night_exp_damage", "6");
	cvarWin = register_cvar("cod_night_exp_win", "50");
	cvarPlant = register_cvar("cod_night_exp_plant", "50");
	cvarDefuse = register_cvar("cod_night_exp_defuse", "50");
	cvarHostage = register_cvar("cod_night_exp_hostage", "50");
	
	set_task(1.0, "check_time");
	
	set_task(300.0, "show_info", _, _, _, "b");
}

public plugin_cfg()
{
	expFrom = get_pcvar_num(cvarFrom);
	expTo = get_pcvar_num(cvarTo);
	expKill = get_pcvar_num(cvarKill);
	expKillHS = get_pcvar_num(cvarKillHS);
	expDamage = get_pcvar_num(cvarDamage);
	expWin = get_pcvar_num(cvarWin);
	expPlant = get_pcvar_num(cvarPlant);
	expDefuse = get_pcvar_num(cvarDefuse);
	expHostage = get_pcvar_num(cvarHostage);
}

public check_time()	
{
	new time[3];

	get_time("%H", time, charsmax(time));
	
	new hour = str_to_num(time);
	
	if((expFrom > expTo && (hour >= expFrom || hour < expTo)) || (hour >= expFrom && hour < expTo)) expActive = true;	
	
	if(expActive)	
	{
		server_cmd("cod_exp_kill %i;cod_exp_killhs %i;cod_exp_damage %i;cod_exp_win %i;cod_exp_plant %i;cod_exp_defuse %i;cod_exp_hostage %i", expKill, expKillHS, expDamage, expWin, expPlant, expDefuse, expHostage);
		
		return;
	}
	
	get_time("%M", time, charsmax(time));
	
	new minute = str_to_num(time);
	
	set_task(Minute(60 - minute), "check_time");
}

public show_info()
{
	if(expActive) cod_print_chat(0, "Na serwerze wlaczony jest nocny^x03 EXP x 2^x01!");
	else cod_print_chat(0, "Od godziny^x03 %i^x01 do^x03 %i^x01 na serwerze jest^x03 EXP x 2^x01!", expFrom, expTo);
}