#include amxmodx
#include codmod
#include engine
#include hamsandwich

new const nazwa[]   = "Fala soniczna";
new const opis[] = "Raz na runde mozesz uzyc fali sonicznej, ktora zadaje LW DMG przeciwnikom w zasiegu 600+int";

new bool:used[33],
wartosc_p[33]

new sprite_white;

public plugin_init()
{
	register_plugin(nazwa, "1.0", "sharkowy");
	
	RegisterHam(Ham_Spawn, "player", "fw_spawn", 1)
	cod_register_perk(nazwa, opis, 40, 120);
}

public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr");
	precache_sound("cannon.wav");
}

public cod_perk_enabled(id, wartosc)
{
	used[id] = false
	wartosc_p[id] = wartosc;
}

public fw_spawn(id)
	used[id] = false

public cod_perk_used(id)
{
	if(used[id])
	{
		client_print(id, print_center, "Wykorzystales umiejetnosc w tej rundzie")
		return PLUGIN_CONTINUE;
	}															

      fala(id);
      used[id] = true

	return PLUGIN_CONTINUE
}

public fala(id)
{
	emit_sound(id, CHAN_ITEM, "cannon.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);

	new entlist[33], pid, num;
	num = find_sphere_class(id, "player", 600.0+cod_get_user_intelligence(id, 1, 1, 1), entlist, 32);
	
	for (new i = 0; i < num; i++)
	{
		pid = entlist[i]
		if (is_user_alive(pid) && get_user_team(id) != get_user_team(pid))
			ExecuteHamB(Ham_TakeDamage, pid, 0, id, float(wartosc_p[id]), 1<<1);
	}
	
	new iOrigin[3];
	get_user_origin(id, iOrigin);
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 600 );
	write_coord( iOrigin[2] + 600 );
	write_short( sprite_white );
	write_byte( 0 ); 
	write_byte( 0 ); 
	write_byte( 10 ); 
	write_byte( 250 ); 
	write_byte( 255 ); 
	write_byte( 210 ); 
	write_byte( 210 );
	write_byte( 210 ); 
	write_byte( 210 ); 
	write_byte( 0 ); 
	message_end();
}