#include <amxmodx>
#include <codmod>
#include <engine>

new bool:ma_perk[33];

new const perk_name[] = "Zemsta";
new const perk_desc[] = "Po smierci twoje cialo wybucha zadajc 60(+int) dmg";

new sprite_blast, sprite_white;

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT")
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("DeathMsg", "Death", "ade");
}

public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr") ;
	sprite_blast = precache_model("sprites/dexplo.spr");
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
}
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}
public Death()
{
	new id = read_data(2);
	if(is_user_connected(id) && ma_perk[id])
		Eksploduj(id);
}

public Eksploduj(id)
{
	new Float:fOrigin[3], iOrigin[3];
	entity_get_vector( id, EV_VEC_origin, fOrigin);
	iOrigin[0] = floatround(fOrigin[0]);
	iOrigin[1] = floatround(fOrigin[1]);
	iOrigin[2] = floatround(fOrigin[2]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32);
	write_byte(20);
	write_byte(0);
	message_end();
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 300 );
	write_coord( iOrigin[2] + 300 );
	write_short( sprite_white );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 8 ); // speed
	message_end();
	
	new entlist[33];
	iOrigin[0] = find_sphere_class(id, "player", 300.0 , entlist, 32);
	
	for (new i=0; i < iOrigin[0]; i++)
	{		
		if (!is_user_alive(entlist[i]) || get_user_team(id) == get_user_team(entlist[i]))
			continue;
		cod_inflict_damage(id, entlist[i], 60.0, 1.0);
	}
	return PLUGIN_CONTINUE;
}