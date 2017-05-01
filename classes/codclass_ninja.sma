#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>

#define DMG_BULLET (1<<1)

new const nazwa[] = "Ninja";
new const opis[] = "Posiada 2 miny, 1/4 na zabicie ze scouta, 1/2 na zabicie z noza, podwojny skok";
new const bronie = (1<<CSW_SCOUT)|(1<<CSW_DEAGLE)|(1<<CSW_MAC10);
new const zdrowie = 20;
new const kondycja = 50;
new const inteligencja = 0;
new const wytrzymalosc = 10;
new const niewidzialnosc = 0;
new const bonus_niewidzialnosci = 0;

new const modelMiny[] = "models/QTM_CodMod/mine.mdl"

new sprite_blast_miny;
new ilosc_min_gracza[33];


new bool:ma_klase[33];
new skoki[33];

public plugin_init() {
	register_plugin(nazwa, "1.0", "O'Zone");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, niewidzialnosc, bonus_niewidzialnosci);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	register_touch("mine", "player",  "DotykMiny");

	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");

	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	
	register_forward(FM_CmdStart, "MultiJump");
}

public plugin_precache()
{
	precache_model(modelMiny);
	sprite_blast_miny = precache_model("sprites/dexplo.spr");
	//precache_model("models/player/assasinct/assasinct.mdl");
	//precache_model("models/player/assasintt/assasintt.mdl");
}

public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_A))
	{
		client_print(id, print_chat, "[%s] Nie masz uprawnien, aby uzywac tej klasy.",nazwa)
		return COD_STOP;
	}
	ma_klase[id] = true;
	ilosc_min_gracza[id] = 2;
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	ilosc_min_gracza[id] = 0;
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

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET && random_num(1,2) == 1 && damage > 20.0)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_SCOUT && damagebits & DMG_BULLET && random_num(1,4) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
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

		entity_set_model(ent, modelMiny);
		entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});

		drop_to_floor(ent);

		set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,50);
	}
}

public Spawn(id)
{
	if(is_user_alive(id) && ma_klase[id]){
		ilosc_min_gracza[id] = 2;
		//new g_Model[64];
		//formatex(g_Model,charsmax(g_Model),"%s",get_user_team(id) == 1 ? "assasintt" : "assasinct");
		//cs_set_user_model(id,g_Model);
	}
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

			cod_inflict_damage(attacker, pid, 70.0, 0.8, ent, (1<<24));
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

public MultiJump(id, uc_handle)
{
	if(!is_user_alive(id) || !ma_klase[id])
		return FMRES_IGNORED;

	new flags = pev(id, pev_flags);

	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id])
	{
		skoki[id]--;
		new Float:velocity[3];
		pev(id, pev_velocity,velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity,velocity);
	}
	else if(flags & FL_ONGROUND)
		skoki[id] = 1;

	return FMRES_IGNORED;
}
