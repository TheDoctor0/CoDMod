#include <amxmodx>
#include <codmod>
#include <cstrike>

#define MAX_DIST 8192.0
#define MAX 32

new const nazwa[] = "GPS";
new const opis[] = "Widzi przeciwnikow na radarze";
new const bronie = 1<<CSW_AK47 || 1<<CSW_DEAGLE;
new const zdrowie = 30;
new const kondycja = 17;
new const inteligencja = 0;
new const wytrzymalosc = 16;

new bool:ma_klase[33], bool:radar[2], bool:uav[MAX+1];
new emp_czasowe;

public plugin_init( )
{
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	set_task(2.0,"radar_scan",_,_,_,"b");
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	if(!emp_czasowe || (emp_czasowe && get_user_team(id) == get_user_team(emp_czasowe)))
	CreateUVA(id);
	return COD_CONTINUE;
}
	
public cod_class_disabled(id)
{
	ma_klase[id] = false;
	uav[id] = false;
}
public CreateUVA(id)
{
	static CzasUav[2];
	new team = get_user_team(id) == 1? 0: 1;
	uav[id] = false;
	radar[team] = true;
	
	new num, players[32];
	get_players(players, num, "gh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a]
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/uav_enemy.wav")
		else
			client_cmd(i, "spk sound/mw/uav_friend.wav")
	}
	radar_scan()
	
	if(task_exists(7354+team))
	{
		new times = (CzasUav[team]-get_systime())+9999
		change_task(7354+team, float(times));
		CzasUav[team] = CzasUav[team]+times;
	}
	else
	{
		new data[1];
		data[0] = team;
		set_task(9999.0, "deluav", 7354+team, data, 1);
		CzasUav[team] = get_systime()+9999;
	}
}

public deluav(data[1])
{
	radar[data[0]] = false;
}

public radar_scan()
{
	new num, players[32];
	get_players(players, num, "gh")
	for(new i=0; i<num; i++)
	{
		new id = players[i];
		if(!is_user_alive(id) || !ma_klase[id] || !radar[get_user_team(id) == 1? 0: 1])
			continue;
		
		if(!emp_czasowe)
			radar_continue(id)
		else if(get_user_team(id) == get_user_team(emp_czasowe))
			radar_continue(id)
	}
}

radar_continue(id)
{
	new num, players[32], PlayerCoords[3]
	get_players(players, num, "gh")
	for(new a=0; a<num; a++)
	{
		new i = players[a]       
		if(!is_user_alive(i) || !ma_klase[id] || get_user_team(i) == get_user_team(id)) 
			continue;
		
		get_user_origin(i, PlayerCoords)
		
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostagePos"), {0,0,0}, id)
		write_byte(id)
		write_byte(i)           
		write_coord(PlayerCoords[0])
		write_coord(PlayerCoords[1])
		write_coord(PlayerCoords[2])
		message_end()
		
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostageK"), {0,0,0}, id)
		write_byte(i)
		message_end()
	}	
}