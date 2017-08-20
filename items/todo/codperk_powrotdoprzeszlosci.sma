#include <amxmodx>
#include <codmod>
#include <fun>
#include fakemeta

new origin[33][3], sprite_white, bool:uzyte, g_maxplayers
#define TASKID_COFKA 7282

public plugin_init() 
{
      new perk_name[] = "Powrot do przeszlosci";
      new perk_desc[] = "Uzyj [C], a po 5s wszyscy zostana cofnieci w czasie. Perk jednorazowy";

	register_plugin(perk_name, "1.0", "RiviT");
	
	register_logevent("Koniec_Rundy", 2, "1=Round_End")
	
	cod_register_perk(perk_name, perk_desc);
}

public plugin_precache()
{
	g_maxplayers = get_maxplayers()
	sprite_white = precache_model("sprites/white.spr");
}

public cod_perk_used(id)
{
      if(uzyte)
      {
            client_print(0, print_center, "Cofniecie czasu trwa! Sprobuj pozniej")
            return PLUGIN_CONTINUE
      }
      
      uzyte = true
      
      client_print(0, print_center, "Cofniecie czasu nastapi za 5s")
      
      for(new i = 1; i <= get_maxplayers(); i++)
      {
            if(is_user_alive(i))
			get_user_origin(i, origin[i])
      }
      
      set_task(5.0, "cofka", TASKID_COFKA+id)
      
      cod_set_user_perk(id, 0)
      
      return PLUGIN_CONTINUE
}

public cofka(id)
{
      id -= TASKID_COFKA

      message_begin( MSG_BROADCAST, SVC_TEMPENTITY, origin[id] );
	write_byte( TE_BEAMCYLINDER );
	write_coord( origin[id][0] );
	write_coord( origin[id][1] );
	write_coord( origin[id][2] );
	write_coord( origin[id][0] );
	write_coord( origin[id][1] + 2000 );
	write_coord( origin[id][2] + 2000 );
	write_short( sprite_white );
	write_byte( 0 ); 
	write_byte( 0 ); 
	write_byte( 100 ); 
	write_byte( 250 ); 
	write_byte( 255 ); 
	write_byte( 210 ); 
	write_byte( 210 );
	write_byte( 210 ); 
	write_byte( 210 ); 
	write_byte( 0 ); 
	message_end();

	new Float:Origin[3]
      for(new i = 1; i <= g_maxplayers; i++)
      {
            if(is_user_alive(i) && i != id)
            {
			origin[i][2] += 25
			set_user_origin(i, origin[i])
			
			pev(i, pev_origin, Origin)
			engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, pev(i, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0)
			if (get_tr2(0, TR_StartSolid))
			{
				origin[i][2] -= 25
				set_user_origin(i, origin[i])
			}
            }
      }
      
      uzyte = false
}

public client_disconnect(id)
{
	if(task_exists(TASKID_COFKA+id))
	{
		uzyte = false
		remove_task(TASKID_COFKA+id)
      }
}
      
public Koniec_Rundy()
{
      uzyte = false
      for(new i = 1; i <= g_maxplayers; i++)
            remove_task(TASKID_COFKA+i)
}