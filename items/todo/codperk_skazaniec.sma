#include <amxmodx>
#include <codmod>
#include <fun>
#include <hamsandwich>
#include <engine>
#include <cstrike>
	
new const perk_name[] = "Skazaniec";
new const perk_desc[] = "Dostajesz HE, przebranie wroga, wybuchasz po smierci zabijajac wszystkich wkolo, +15 hp za HS";
    
new ma_perk[33],
sprite_blast, sprite_white;

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"}

public plugin_init()
{
      register_plugin(perk_name, "1.0", "RiviT");

      cod_register_perk(perk_name, perk_desc);

      RegisterHam(Ham_Spawn, "player", "Spawn", 1);
      register_event("DeathMsg", "DeathMsg", "a");
}

public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_HEGRENADE)
      ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
      if (is_user_connected(id)) cs_reset_user_model(id);
	cod_take_weapon(id, CSW_HEGRENADE)
    	ma_perk[id] = false;
}

public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr");
	sprite_blast = precache_model("sprites/dexplo.spr");
}

public Spawn(id)
{
	if(!is_user_alive(id))
		return;
		
	if(!ma_perk[id])
		return;
		
	cs_set_user_model(id, (cs_get_user_team(id) == CS_TEAM_T)? CT_Skins[random_num(0,3)]: Terro_Skins[random_num(0,3)]);
}

public DeathMsg()
{
	new vid = read_data(2);
      new kid = read_data(1);
      if(!is_user_connected(kid) || get_user_team(vid) == get_user_team(kid)) return
      
      if(ma_perk[kid] && read_data(3))
            set_user_health(kid, get_user_health(kid)+15);

	if(ma_perk[vid])
      {
            new Float:fOrigin[3];
            entity_get_vector(vid, EV_VEC_origin, fOrigin);

            new iOrigin[3];
            for(new i=0;i<=2;i++)
                  iOrigin[i] = floatround(fOrigin[i]);

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
            write_coord( iOrigin[1] + 200 );
            write_coord( iOrigin[2] + 200 );
            write_short( sprite_white );
            write_byte( 0 );
            write_byte( 0 );
            write_byte( 10 );
            write_byte( 10 );
            write_byte( 255 );
            write_byte( 255 );
            write_byte( 100 );
            write_byte( 100 );
            write_byte( 128 );
            write_byte( 0 );
            message_end();

            new entlist[33];
            iOrigin[0] = find_sphere_class(vid, "player", 200.0 , entlist, 32);
            
            for (new i=0; i <iOrigin[0]; i++)
            {
                  if (is_user_alive(entlist[i]) && get_user_team(vid) != get_user_team(entlist[i]))
                        ExecuteHamB(Ham_Killed, entlist[i], vid, 1)
            }
	}
}