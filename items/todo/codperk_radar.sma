#include <amxmodx>
#include <codmod>

#define TASKID_RADAR 8437

new const nazwa[] = "Radar";
new const opis[] = "Widzisz przeciwnikow na radarze";

new g_msgHostageAdd, g_msgHostageDel, gMaxPlayers;

public plugin_init()
{
	register_plugin(nazwa, "1.0", "NothiNg");
	
	g_msgHostageAdd = get_user_msgid("HostagePos");
	g_msgHostageDel = get_user_msgid("HostageK");
	
	cod_register_perk(nazwa, opis)
}

public plugin_cfg()
      gMaxPlayers = get_maxplayers()

public cod_perk_enabled(id)
      set_task (2.0, "radar_scan",TASKID_RADAR+id,_,_, "b");
	
public cod_perk_disabled(id)
	remove_task(TASKID_RADAR+id)

public radar_scan(id)
{
      id -= TASKID_RADAR
 
      if(!is_user_alive(id)) return;
      
      new PlayerCoords[3];
      for (new i=1;i<=gMaxPlayers;i++)
      {       
            if(!is_user_alive(i) || get_user_team(i) == get_user_team(id)) continue;
			
            get_user_origin(i, PlayerCoords)

            message_begin(MSG_ONE_UNRELIABLE, g_msgHostageAdd, {0,0,0}, id)
            write_byte(id)
            write_byte(i)           
            write_coord(PlayerCoords[0])
            write_coord(PlayerCoords[1])
            write_coord(PlayerCoords[2])
            message_end()
                                
            message_begin(MSG_ONE_UNRELIABLE, g_msgHostageDel, {0,0,0}, id)
            write_byte(i)
            message_end()
      }
}