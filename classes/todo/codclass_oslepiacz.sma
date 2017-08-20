
#include <amxmodx>
#include <codmod>
#include <engine>


new const nazwa[] = "Oslepiacz";
new const opis[] = "Po smierci oslepia wrogow w promieniu 500+int";
new const bronie = 0
new const zdrowie = 0;
new const kondycja = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new ma_klase[33]
new sprite_white;

new g_msg_screenfade;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "MAGNET")
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("DeathMsg", "DeathMsg", "a");
	g_msg_screenfade = get_user_msgid("ScreenFade");
}

public cod_class_enabled(id)
{
	ma_klase[id] = 1;
}

public cod_class_disabled(id)
{
	ma_klase[id] = 0;
}
public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr");
}
public DeathMsg(id)
{
	new id = read_data(2);
	if(!ma_klase[id])
	return PLUGIN_CONTINUE;
	new iOrigin[3];
	get_user_origin(id, iOrigin);
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 250 );
	write_coord( iOrigin[2] + 250 );
	write_short( sprite_white );
	write_byte( 0 ); 
	write_byte( 0 ); 
	write_byte( 10 ); 
	write_byte( 120 ); 
	write_byte( 255 ); 
	write_byte( 0 ); 
	write_byte( 255 );
	write_byte( 0 ); 
	write_byte( 128 ); 
	write_byte( 0 ); 
	message_end();
	
	new entlist[33];
	new numfound = find_sphere_class(id, "player", 500.0+cod_get_user_intelligence(id) , entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if (is_user_alive(pid) && get_user_team(id) != get_user_team(pid))
		Display_Fade(pid, 1<<14, 1<<14 ,1<<16, 50, 130, 40, 250);
	}
	
	return PLUGIN_CONTINUE;
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin( MSG_ONE, g_msg_screenfade,{0,0,0},id );
	write_short( duration );
	write_short( holdtime );	
	write_short( fadetype );	
	write_byte ( red );		
	write_byte ( green );		
	write_byte ( blue );	
	write_byte ( alpha );	
	message_end();
}
