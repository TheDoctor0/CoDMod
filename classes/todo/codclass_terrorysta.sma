#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
        
new const nazwa[]   = "Terrorysta";
new const opis[]    = "ma 1 rakiete, przebranie wroga oraz 1/4 szansy na zrespieniu sie na respie wroga.";
new const bronie    = (1<<CSW_GLOCK18)|(1<<CSW_M4A1);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;
    
new sprite_blast;
new ilosc_rakiet_gracza[33];
new poprzednia_rakieta_gracza[33];

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"}

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_touch("rocket", "*" , "DotykRakiety");
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Rakiety", 1);

	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
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
		if (entity_get_edict(entRakiety, EV_ENT_owner) == id)
			remove_entity(entRakiety);
		entRakiety = find_ent_by_class(entRakiety, "rocket");
	}

}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_D))
	{
		client_print(id, print_chat, "[Terrorysta] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}

	ilosc_rakiet_gracza[id] = 1;
   
	return COD_CONTINUE;
}
public Spawn(id)
{
        if (!is_user_alive(id))
                return;
                
        if (!ma_klase[id])
                return;
                
        if (random_num(1,2) == 1)
        {
                new CsTeams:team = cs_get_user_team(id);
                
                cs_set_user_team(id, (team == CS_TEAM_CT)? CS_TEAM_T: CS_TEAM_CT);
                ExecuteHam(Ham_CS_RoundRespawn, id);
                
                cs_set_user_team(id, team);
        }
        ZmienUbranie(id, 0);
}

public ZmienUbranie(id, reset)
{
        if (!is_user_connected(id))
                return PLUGIN_CONTINUE;
        
        if (reset)
                cs_reset_user_model(id);
        else
        {
                new num = random_num(0,3);
                cs_set_user_model(id, (cs_get_user_team(id) == CS_TEAM_T)? CT_Skins[num]: Terro_Skins[num]);
        }
        
        return PLUGIN_CONTINUE;
}

public cod_class_skill_used(id)
{

	if (!ilosc_rakiet_gracza[id])
	{
		client_print(id, print_center, "Wykorzystales juz wszystkie rakiety!");
	}
	else
	{
		if (poprzednia_rakieta_gracza[id] + 2.0 > get_gametime())
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
	if (is_user_alive(id))
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
		cod_inflict_damage(attacker, pid, 55.0, 0.9, ent, (1<<24));
	}
	remove_entity(ent);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
