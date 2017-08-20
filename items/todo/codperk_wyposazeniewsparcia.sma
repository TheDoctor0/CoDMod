#include <amxmodx>
#include <engine>
#include <codmod>

new const nazwa[] = "Wyposazenie Wsparcia";
new const opis[] = "Masz SW rakiety co runde";

new bool:ma_perk[33];
new wartosc_perku[33] = 0;
new ilosc_rakiet_gracza[33];
new poprzednia_rakieta_gracza[33];

new sprite_blast;

new wsparcie_id;

public plugin_init()
 {
	register_plugin(nazwa, "1.0", "O'Zone");
	
	cod_register_perk(nazwa, opis, 2, 2);
	
	register_event("ResetHUD", "ResetHUD", "abe");
	register_touch("rocket", "*" , "DotykRakiety");
	
	wsparcie_id = cod_get_classid("Wsparcie Ogniowe");
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model("models/rpgrocket.mdl");
}

public cod_perk_enabled(id, wartosc)
{
	if(cod_get_user_class(id) == wsparcie_id)
		return COD_STOP;
	wartosc_perku[id] = wartosc;
	ilosc_rakiet_gracza[id] = wartosc_perku[id];
	ma_perk[id] = true;
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	ilosc_rakiet_gracza[id] = 0;
}
	
public cod_perk_used(id)
{	
	if (!ilosc_rakiet_gracza[id])
	{
		client_print(id, print_center, "Wykorzystales juz wszystkie rakiety!");
		return PLUGIN_CONTINUE;
	}
	
	if(poprzednia_rakieta_gracza[id] + 2.0 > get_gametime())
	{
		client_print(id, print_center, "Rakiet mozesz uzywac co 2 sekundy!");
		return PLUGIN_CONTINUE;
	}
	
	if (is_user_alive(id))
	{
		poprzednia_rakieta_gracza[id] = floatround(get_gametime());
		ilosc_rakiet_gracza[id]--;

		new Float: Origin[3], Float: vAngle[3], Float: Velocity[3];
		
		entity_get_vector(id, EV_VEC_v_angle, vAngle);
		entity_get_vector(id, EV_VEC_origin , Origin);
	
		new Ent = create_entity("info_target");
	
		entity_set_string(Ent, EV_SZ_classname, "rocket");
		entity_set_model(Ent, "models/rpgrocket.mdl");
	
		vAngle[0] *= -1.0;
	
		entity_set_origin(Ent, Origin);
		entity_set_vector(Ent, EV_VEC_angles, vAngle);
	
		entity_set_int(Ent, EV_INT_effects, 2);
		entity_set_int(Ent, EV_INT_solid, SOLID_BBOX);
		entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY);
		entity_set_edict(Ent, EV_ENT_owner, id);
	
		VelocityByAim(id, 1000 , Velocity);
		entity_set_vector(Ent, EV_VEC_velocity ,Velocity);
	}	
	return PLUGIN_CONTINUE;
}

public DotykRakiety(ent)
{
	if (!is_valid_ent(ent))
		return;

	new attacker = entity_get_edict(ent, EV_ENT_owner);
	

	new Float:fOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, fOrigin);	
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
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

	new entlist[33];
	new numfound = find_sphere_class(ent, "player", 190.0, entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid))
			continue;
		cod_inflict_damage(attacker, pid, 55.0, 1.0, ent, (1<<24));
	}
	remove_entity(ent);
}	

public ResetHUD(id)
	ilosc_rakiet_gracza[id] = wartosc_perku[id];

public client_disconnect(id)
{
	new ent = find_ent_by_class(0, "rocket");
	while(ent > 0)
	{
		if(entity_get_edict(id, EV_ENT_owner) == id)
			remove_entity(ent);
		ent = find_ent_by_class(ent, "rocket");
	}
}
