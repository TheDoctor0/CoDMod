#include <amxmodx>
#include <engine>
#include <codmod>

new const nazwa[] = "Rakieciarz";
new const opis[] = "Masz 4 rakiety co runde, tracisz 20 inty";

new ilosc_rakiet_gracza[33],
poprzednia_rakieta_gracza[33],
sprite_blast;

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);
	
	register_event("ResetHUD", "ResetHUD", "abe");
	register_touch("rocket", "*" , "DotykRakiety");
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model("models/rpgrocket.mdl");
}

public cod_perk_enabled(id)
{
	cod_add_user_bonus_intelligence(id, -20);

	ilosc_rakiet_gracza[id] = 4;
}

public cod_perk_disabled(id)
	cod_add_user_bonus_intelligence(id, 20);
	
public cod_perk_used(id)
{	
	if (!ilosc_rakiet_gracza[id])
	{
		client_print(id, print_center, "Wykorzystales juz wszystkie rakiety!");
		return PLUGIN_CONTINUE;
	}
	
	if(poprzednia_rakieta_gracza[id] + 4.0 > get_gametime())
	{
		client_print(id, print_center, "Rakiet mozesz uzywac co 4 sekundy!");
		return PLUGIN_CONTINUE;
	}
	
		poprzednia_rakieta_gracza[id] = floatround(get_gametime());
		ilosc_rakiet_gracza[id]--;

		new Float: Origin[3], Float: vAngle[3]
		
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
	
		VelocityByAim(id, 1000 , vAngle);
		entity_set_vector(Ent, EV_VEC_velocity ,vAngle);

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
	iOrigin[0] = find_sphere_class(ent, "player", 190.0, entlist, 32);
	
	for (new i=0; i < iOrigin[0]; i++)
	{		
		if (!is_user_alive(entlist[i]) || get_user_team(attacker) == get_user_team(entlist[i]))
			continue;
		cod_inflict_damage(attacker, entlist[i], 55.0, 1.0, ent, (1<<24));
	}
	remove_entity(ent);
}	

public ResetHUD(id)
	ilosc_rakiet_gracza[id] = 4;