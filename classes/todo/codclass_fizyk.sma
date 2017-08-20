#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
        
new const nazwa[]   = "Fizyk";
new const opis[]    = "UMP, deagle, 1 ulepszona rakieta, defuser";
new const bronie    = (1<<CSW_UMP45)|(1<<CSW_DEAGLE);
new const zdrowie   = 45;
new const kondycja  = 15;
new const inteligencja = 20;
new const wytrzymalosc = 10;
    
new sprite_blast;
new ilosc_rakiet_gracza[33];
new poprzednia_rakieta_gracza[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_touch("rocket", "*" , "DotykRakiety");
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Rakiety", 1);

}

public plugin_precache()
{

	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model("models/rpgrocket.mdl");

}

public client_disconnect(id)
{

	new entRakiety = find_ent_by_class(0, "rocket");
	while(entRakiety > 0)
	{
		if(entity_get_edict(entRakiety, EV_ENT_owner) == id)
			remove_entity(entRakiety);
		entRakiety = find_ent_by_class(entRakiety, "rocket");
	}

}

public cod_class_enabled(id)
{

	ilosc_rakiet_gracza[id] = 1;
	cs_set_user_defuse(id, 1);

}

public cod_class_skill_used(id)
{

	if (!ilosc_rakiet_gracza[id])
	{
		client_print(id, print_center, "Wykorzystales juz wszystkie rakiety!");
	}
	else
	{
		if(poprzednia_rakieta_gracza[id] + 2.0 > get_gametime())
		{
			client_print(id, print_center, "Rakiet mozesz uzywac co 2 sekundy!");
		}

		else
		{
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
		}
	}

}

public fwSpawn_Rakiety(id)
{
	if(is_user_alive(id))
		ilosc_rakiet_gracza[id] = 1;
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
		cod_inflict_damage(attacker, pid, 85.0, 1.1, ent, (1<<24));
	}
	remove_entity(ent);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
