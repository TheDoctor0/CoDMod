#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
        
new const nazwa[]   = "Technik";
new const opis[]    = "Posiada 3 miny (obrazenia zalezne od inteligencji)";
new const bronie    = (1<<CSW_MP5NAVY);
new const zdrowie   = 20;
new const kondycja  = 15;
new const inteligencja = 10;
new const wytrzymalosc = 0;
new const niewidzialnosc = 0;
new const bonus_niewidzialnosci = 0;
    
new const model[] = "models/QTM_CodMod/mine.mdl"
new bool:ma_klase[33];
new sprite_blast_miny;
new ilosc_min_gracza[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "O'Zone");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, niewidzialnosc, bonus_niewidzialnosci);
	register_touch("mine", "player",  "DotykMiny");

	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");

	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public plugin_precache()
{
	precache_model(model);
	sprite_blast_miny = precache_model("sprites/dexplo.spr");
}

public client_disconnect(id)
{
	new entMiny = find_ent_by_class(0, "mine");
	while(entMiny > 0)
	{
		if(entity_get_edict(entMiny, EV_ENT_owner) == id)
			remove_entity(entMiny);
		entMiny = find_ent_by_class(entMiny, "mine");
	}
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	ilosc_min_gracza[id] = 3;
	cs_set_user_armor(id, 50, CS_ARMOR_VESTHELM) 
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	ilosc_min_gracza[id] = 0;
	cs_set_user_armor(id, 0, CS_ARMOR_VESTHELM) 
}

public cod_class_skill_used(id)
{  
	if (!ilosc_min_gracza[id])
	{
		client_print(id, print_center, "Wykorzystales juz wszystkie miny!");
	}
	else
	{
		ilosc_min_gracza[id]--;

		new Float:origin[3];
		entity_get_vector(id, EV_VEC_origin, origin);

		new ent = create_entity("info_target");
		entity_set_string(ent ,EV_SZ_classname, "mine");
		entity_set_edict(ent ,EV_ENT_owner, id);
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
		entity_set_origin(ent, origin);
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);

		entity_set_model(ent, model);
		entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});

		drop_to_floor(ent);

		set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,50);
	}
}

public Spawn(id)
{
	if(is_user_alive(id) && ma_klase[id])
		ilosc_min_gracza[id] = 3;
}

public DotykMiny(ent, id)
{
	if(!is_valid_ent(ent))
		return;

	new attacker = entity_get_edict(ent, EV_ENT_owner);
	if (get_user_team(attacker) != get_user_team(id))
	{
		new Float:fOrigin[3];
		entity_get_vector( ent, EV_VEC_origin, fOrigin);

		new iOrigin[3];
		for(new i=0;i<3;i++)
			iOrigin[i] = floatround(fOrigin[i]);

		message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_short(sprite_blast_miny);
		write_byte(32);
		write_byte(20);
		write_byte(0);
		message_end();

		new entlist[33];
		new numfound = find_sphere_class(ent,"player", 90.0 ,entlist, 32);

		for (new i=0; i < numfound; i++)
		{
			new pid = entlist[i];

			if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid))
				continue;

			cod_inflict_damage(attacker, pid, 70.0, 1.3, ent, (1<<24));
		}
		remove_entity(ent);
	}
}

public NowaRunda()
{
	new entMiny = find_ent_by_class(-1, "mine");
	while(entMiny > 0)
	{
		remove_entity(entMiny);
		entMiny = find_ent_by_class(entMiny, "mine");
	}
}
