#include <amxmodx>
#include <fun>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <fakemeta_util>
#include <cod>

#define PLUGIN "CoD Box"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const boxClass[] = "cod_box";

new const boxModel[] = "models/CoDMod/box_model.mdl";

new const boxSound[] =  "CoDMod/get_box.wav";

new spriteGreen, spriteAcid, cvarBoxChance;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_event("DeathMsg", "player_death", "a");
	
	register_touch(boxClass, "player", "touch_box");
	
	cvarBoxChance = register_cvar("cod_box_chance", "5");
}

public plugin_precache()
{
	precache_model(boxModel);
	precache_sound(boxSound);
	
	spriteGreen = precache_model("sprites/CoDMod/green.spr");
	spriteAcid = precache_model("sprites/CoDMod/acid_pou.spr");
}

public player_death()
	if(random_num(1, get_pcvar_num(cvarBoxChance)) == 1) create_box(read_data(2));

public create_box(id)
{
	new ent, Float:origin[3];
	
	entity_get_vector(id, EV_VEC_origin, origin);
	
	ent = fm_create_entity("info_target");
	
	set_pev(ent, pev_classname, boxClass);

	engfunc(EngFunc_SetModel, ent, boxModel);
	
	set_pev(ent, pev_mins, Float:{ -10.0, -10.0, 0.0 });
	set_pev(ent, pev_maxs, Float:{ 10.0, 10.0, 50.0 });
	set_pev(ent, pev_size, Float:{ -1.0, -3.0, 0.0, 1.0, 1.0, 10.0 });
	engfunc(EngFunc_SetSize, ent, Float:{ -1.0, -3.0, 0.0 }, Float:{ 1.0, 1.0, 10.0 });
	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	set_pev(ent, pev_movetype, MOVETYPE_FLY);
	entity_set_origin(ent, origin);
	entity_set_int(ent, EV_INT_sequence, 1);
	entity_set_float(ent, EV_FL_animtime, 360.0);
	entity_set_float(ent, EV_FL_framerate,  1.0);
	entity_set_float(ent, EV_FL_frame, 0.0);
	
	return PLUGIN_CONTINUE;
}

public touch_box(entity, id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE;

	get_box(id);

	new origin[3];
	
	get_user_origin(id, origin);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRITE);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]);
	write_short(spriteGreen);
	write_byte(20);
	write_byte(255);
	message_end();
	
	message_begin(MSG_ALL, SVC_TEMPENTITY, {0, 0, 0}, id);
	write_byte(TE_SPRITETRAIL);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2] + 20);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2] + 80);
	write_short(spriteAcid);
	write_byte(20);
	write_byte(20);
	write_byte(4);
	write_byte(20);
	write_byte(10);
	message_end();
	
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, boxSound, 1.0, ATTN_NORM, 0, PITCH_NORM);

	remove_entity(entity);
	
	return PLUGIN_CONTINUE;
}

public get_box(id) 
{
	switch(random_num(1, 12))
	{
		case 1:
		{
			new frags = random_num(1, 3);
			
			set_user_frags(id, get_user_frags(id) + frags);
			
			cod_print_chat(id, "Niezle... Dostales^x04 %i frag%s^x01!", frags, frags == 1 ? "a" : "i");
		}
		case 2:
		{
			new frags = random_num(1, 2);
			
			set_user_frags(id, get_user_frags(id) - frags);
			
			cod_print_chat(id, "Ups... Znikn%s ci^x04 %i frag%s^x01!", frags == 1 ? "al" : "ely", frags, frags == 1 ? "" : "i");
		}
		case 3:
		{
			new deaths = random_num(1, 3);
			
			cs_set_user_deaths(id, cs_get_user_deaths(id) - deaths);
			
			cod_print_chat(id, "Niezle... Masz o^x04 %i zgon%s^x01 mniej!", deaths, deaths == 1 ? "" : "y");
		}
		case 4:
		{
			new deaths = random_num(1, 3);
			
			cs_set_user_deaths(id, cs_get_user_deaths(id) + deaths);
			
			cod_print_chat(id, "Ups... Masz o^x04 %i zgon%s^x01 wiecej!", deaths, deaths == 1 ? "" : "y");
		}
		case 5:
		{
			if(cod_get_user_item(id))
			{
				get_box(id);

				return PLUGIN_CONTINUE;
			}
			
			cod_set_user_item(id, -1, -1);
			
			cod_print_chat(id, "Wow... Trafiles na^x04 losowy item^x01!");
		}
		case 6:
		{
			new health = random_num(50, 150);
			
			set_user_health(id, get_user_health(id) + health);
			
			cod_print_chat(id, "Yeah... Dostales^x04 +%i HP^x01!", health);
		}
		case 7:
		{
			new health = random_num(25, 75);
			
			if(get_user_health(id) < health)
			{
				user_kill(id);
				
				cod_print_chat(id, "Yyy... Zaliczyles^x04 zgon^x01!");
			}
			else
			{
				set_user_health(id, get_user_health(id) - health);

				cod_print_chat(id, "Yyy... Ubylo ci^x04 %i HP^x01!", health);
			}
		}
		case 8:
		{
			new exp = random_num(25, 100);
			
			cod_set_user_exp(id, cod_get_user_exp(id) + exp);

			cod_print_chat(id, "Ladnie... Dostales^x04 %i Expa^x01!", exp);
		}
		case 9:
		{
			new honor = random_num(10, 50);
			
			cod_set_user_honor(id, cod_get_user_honor(id) + honor);

			cod_print_chat(id, "Ladnie... Dostales^x04 %i Honoru^x01!", honor);
		}
		case 10:
		{
			new honor = random_num(5, 20);
			
			cod_set_user_honor(id, cod_get_user_honor(id) - honor);

			cod_print_chat(id, "Niestety... Straciles^x04 %i Honoru^x01!", honor);
		}
		case 11:
		{
			cod_set_user_rockets(id, cod_get_user_rockets(id) + 1);
			
			cod_print_chat(id, "Yeah... Dostales^x04 Rakiete^x01!");
		}
		case 12:
		{
			cod_set_user_mines(id, cod_get_user_mines(id) + 1);
			
			cod_print_chat(id, "Nice... Dostales^x04 Mine^x01!");
		}
	}

	return PLUGIN_CONTINUE;
}