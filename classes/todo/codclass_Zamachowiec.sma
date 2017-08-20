#include <amxmodx>
#include <codmod>
#include <engine>
#include <cstrike>
#include <hamsandwich>
#include fun
        
#pragma tabsize 0

new const nazwa[]   = "Zamachowiec [P]";
new const opis[]    = "Ma ciche kroki, widocznosc na nozu spada do 68, 1 apteczka";
new const bronie    = (1<<CSW_FAMAS)|(1<<CSW_FLASHBANG)|(1<<CSW_GLOCK18);
new const zdrowie   = 30;
new const kondycja  = 0;
new const inteligencja = 10;
new const wytrzymalosc = -10;
    
new ma_klase[33];
new sprite_white_apteczki, ilosc_apteczek_gracza[33]

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Premium");

	new const Nazwy_broni[][] = {
	"weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", 
	"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", 
	"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", 
	"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", 
	"weapon_ak47", "weapon_knife", "weapon_p90" }
	
      for(new i = 0; i < sizeof Nazwy_broni; i++)
            RegisterHam(Ham_Item_Deploy, Nazwy_broni[i], "fwHamItemDeploy", 1)
	
	register_think("medkit", "Think_Apteczki");

	RegisterHam(Ham_Spawn, "player", "fwSpawn_Apteczki", 1);
}

public cod_class_enabled(id)
{
	if(!(cod_get_user_status(id) & STATUS_PREMIUM))
	{
		client_print(id, print_chat, "[%s] Nie masz premium, zeby grac ta klasa!", nazwa)
		return COD_STOP;
	}

	set_user_footsteps(id, 1);
      ilosc_apteczek_gracza[id] = 1;
	ma_klase[id] = true;
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	set_user_footsteps(id, 0);
	cod_remove_user_rendering(id)
    	ma_klase[id] = false;
}

#define m_pPlayer 41
public fwHamItemDeploy(ent)
{
	static id;
	id = get_pdata_cbase(ent, m_pPlayer, 4)
	
	if(!is_user_alive(id) || !ma_klase[id]) return;
	
	if(cs_get_weapon_id(ent) == CSW_KNIFE)
		cod_set_user_rendering(id, 68)
	else
		cod_remove_user_rendering(id)
}

public plugin_precache()
{
	sprite_white_apteczki = precache_model("sprites/white.spr");
	precache_model("models/w_medkit.mdl");
}

public cod_class_skill_used(id)
{
	if (!ilosc_apteczek_gracza[id])
		client_print(id, print_center, "Masz tylko 1 apteczke na runde!");
	else
	{
		ilosc_apteczek_gracza[id]--;

		new Float:origin[3];
		entity_get_vector(id, EV_VEC_origin, origin);

		new ent = create_entity("info_target");
		entity_set_string(ent, EV_SZ_classname, "medkit");
		entity_set_edict(ent, EV_ENT_owner, id);
		entity_set_int(ent, EV_INT_solid, SOLID_NOT);
		entity_set_vector(ent, EV_VEC_origin, origin);
		entity_set_float(ent, EV_FL_ltime, halflife_time() + 7 + 0.1);


		entity_set_model(ent, "models/w_medkit.mdl");
		set_rendering ( ent, kRenderFxGlowShell, 255,0,0, kRenderFxNone, 255 )     ;
		drop_to_floor(ent);

		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);
	}
}

public fwSpawn_Apteczki(id)
{
	if(ma_klase[id])
	{
		ilosc_apteczek_gracza[id] = 1;
		cod_remove_user_rendering(id)
	}
}

public Think_Apteczki(ent)
{
	if(!is_valid_ent(ent))
		return PLUGIN_CONTINUE;

	new id = entity_get_edict(ent, EV_ENT_owner);

	if (entity_get_edict(ent, EV_ENT_euser2) == 1)
	{
            new heal = 4+floatround(cod_get_user_intelligence(id)*0.3);

		new Float:forigin[3];
		entity_get_vector(ent, EV_VEC_origin, forigin);

		new entlist[33];
		new numfound = find_sphere_class(0,"player", float(250),entlist, 32,forigin);
		new maksymalne_zdrowie, zdrowie, Float:nowe_zdrowie

		for (new i=0; i < numfound; i++)
		{
			if (get_user_team(entlist[i]) != get_user_team(id) || !is_user_alive(entlist[i]))
				continue;
				
                  maksymalne_zdrowie = 100+cod_get_user_health(entlist[i]);
                  zdrowie = get_user_health(entlist[i]);
                  nowe_zdrowie = (zdrowie+heal<maksymalne_zdrowie)?zdrowie+heal+0.0:maksymalne_zdrowie+0.0;

			entity_set_float(entlist[i], EV_FL_health, nowe_zdrowie);
		}

		entity_set_edict(ent, EV_ENT_euser2, 0);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.5);

		return PLUGIN_CONTINUE;
	}

	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id))
	{
		remove_entity(ent);
		return PLUGIN_CONTINUE;
	}

	if (entity_get_float(ent, EV_FL_ltime)-2.0 < halflife_time())
		set_rendering ( ent, kRenderFxNone, 255,255,255, kRenderTransAlpha, 100 );

	new Float:forigin[3];
	entity_get_vector(ent, EV_VEC_origin, forigin);

	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(forigin[i]);

 	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 250 );
	write_coord( iOrigin[2] + 250 );
	write_short( sprite_white_apteczki );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 0 ); // speed
	message_end();

	entity_set_edict(ent, EV_ENT_euser2 ,1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);

	return PLUGIN_CONTINUE;
}
