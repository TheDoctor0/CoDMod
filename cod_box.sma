#include <amxmodx>
#include <cod>
#include <fun>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <fakemeta_util>

#define PLUGIN "CoD Box"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const szClassName[] = "cod_box";

new const szModel[] = "models/CoDMod/box_model.mdl";

new const szSound[] =  "CoDMod/get_box.wav";

new iSprite, iSpriteTwo, cvarBoxChance;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_event("DeathMsg", "DeathMsg", "a");
	
	register_touch(szClassName, "player", "Touch");
	
	cvarBoxChance = register_cvar("cod_box_chance", "5");
}

public plugin_precache()
{
	precache_model(szModel);
	precache_sound(szSound);
	
	iSprite = precache_model("sprites/CoDMod/green.spr");
	iSpriteTwo = precache_model("sprites/CoDMod/acid_pou.spr");
}

public DeathMsg()
{
	new victim = read_data(2);
		
	if(random_num(1, get_pcvar_num(cvarBoxChance)) == 1)
		CreateBox(victim);
	
	return PLUGIN_CONTINUE;
}

public CreateBox(id)
{
	new ent, Float:fOrigin[3];
	
	entity_get_vector(id, EV_VEC_origin, fOrigin);
	
	ent = fm_create_entity("info_target");
	
	set_pev(ent, pev_classname, szClassName);

	engfunc(EngFunc_SetModel, ent, szModel);
	
	set_pev(ent,pev_mins, Float:{-10.0,-10.0,0.0});
	set_pev(ent,pev_maxs, Float:{10.0,10.0,50.0});
	set_pev(ent,pev_size, Float:{-1.0,-3.0,0.0,1.0,1.0,10.0});
	engfunc(EngFunc_SetSize, ent, Float:{-1.0,-3.0,0.0}, Float:{1.0,1.0,10.0});
	
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	set_pev(ent, pev_movetype, MOVETYPE_FLY);
	entity_set_origin(ent, fOrigin);
	entity_set_int(ent, EV_INT_sequence, 1);
	entity_set_float(ent, EV_FL_animtime, 360.0);
	entity_set_float(ent, EV_FL_framerate,  1.0);
	entity_set_float(ent, EV_FL_frame, 0.0);
	
	return PLUGIN_CONTINUE;
}

public Touch(entity, id)
{
	if(!is_user_alive(id)) 
		return PLUGIN_CONTINUE;

	GetBox(id);
	ShowEffect(id);
	
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);

	remove_entity(entity);
	
	return PLUGIN_CONTINUE;
}

public GetBox(id) 
{
	switch(random_num(1, 12))
	{
		case 1:
		{
			new iFrags = random_num(1, 3);
			
			set_user_frags(id, get_user_frags(id) + iFrags);
			
			cod_print_chat(id, DontChange, "Niezle... Dostales^x04 %i frag%s^x01!", iFrags, iFrags == 1 ? "a" : "i");
		}
		case 2:
		{
			new iFrags = random_num(1, 2);
			
			set_user_frags(id, get_user_frags(id) - iFrags);
			
			cod_print_chat(id, DontChange, "Ups... Znikn%s ci^x04 %i frag%s^x01!", iFrags == 1 ? "al" : "ely", iFrags, iFrags == 1 ? "" : "i");
		}
		case 3:
		{
			new iDeaths = random_num(1, 3);
			
			cs_set_user_deaths(id, cs_get_user_deaths(id) - iDeaths);
			
			cod_print_chat(id, DontChange, "Niezle... Masz o^x04 %i zgon%s^x01 mniej!", iDeaths, iDeaths == 1 ? "" : "y");
		}
		case 4:
		{
			new iDeaths = random_num(1, 3);
			
			cs_set_user_deaths(id, cs_get_user_deaths(id) + iDeaths);
			
			cod_print_chat(id, DontChange, "Ups... Masz o^x04 %i zgon%s^x01 wiecej!", iDeaths, iDeaths == 1 ? "" : "y");
		}
		case 5:
		{
			if(cod_get_user_item(id))
			{
				GetBox(id);
				return PLUGIN_CONTINUE;
			}
			
			cod_set_user_item(id, -1, -1, 1);
			
			cod_print_chat(id, DontChange, "Wow... Trafiles na^x04 losowy item^x01!");
		}
		case 6:
		{
			new iHealth = random_num(50, 150);
			
			set_user_health(id, get_user_health(id) + iHealth);
			
			cod_print_chat(id, DontChange, "Yeah... Dostales^x04 +%i HP^x01!", iHealth);
		}
		case 7:
		{
			new iHealth = random_num(25, 75);
			
			if(get_user_health(id) < iHealth)
			{
				user_kill(id);
				cod_print_chat(id, DontChange, "Yyy... Zaliczyles^x04 zgon^x01!");
			}
			else
			{
				set_user_health(id, get_user_health(id) - iHealth);
				cod_print_chat(id, DontChange, "Yyy... Ubylo ci^x04 %i HP^x01!", iHealth);
			}
		}
		case 8:
		{
			new iExp = random_num(25, 100);
			
			cod_set_user_exp(id, cod_get_user_exp(id) + iExp);
			cod_print_chat(id, DontChange, "Ladnie... Dostales^x04 %i Expa^x01!", iExp);
		}
		case 9:
		{
			new iHonor = random_num(10, 50);
			
			cod_set_user_honor(id, cod_get_user_honor(id) + iHonor);
			cod_print_chat(id, DontChange, "Ladnie... Dostales^x04 %i Honoru^x01!", iHonor);
		}
		case 10:
		{
			new iHonor = random_num(5, 20);
			
			cod_set_user_honor(id, cod_get_user_honor(id) - iHonor);
			cod_print_chat(id, DontChange, "Niestety... Straciles^x04 %i Honoru^x01!", iHonor);
		}
		case 11:
		{
			cod_set_user_rockets(id, cod_get_user_rockets(id) + 1);
			
			cod_print_chat(id, DontChange, "Yeah... Dostales^x04 Rakiete^x01!");
		}
		case 12:
		{
			cod_set_user_mines(id, cod_get_user_mines(id) + 1);
			
			cod_print_chat(id, DontChange, "Nice... Dostales^x04 Mine^x01!");
		}
	}
	return PLUGIN_CONTINUE;
}

public ShowEffect(id) 
{
	new iOrigin[3];
	
	get_user_origin(id, iOrigin);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRITE);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(iSprite);
	write_byte(20);
	write_byte(255);
	message_end();
	
	message_begin(MSG_ALL, SVC_TEMPENTITY, {0, 0, 0}, id);
	write_byte(TE_SPRITETRAIL);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + 20);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + 80);
	write_short(iSpriteTwo);
	write_byte(20);
	write_byte(20);
	write_byte(4);
	write_byte(20);
	write_byte(10);
	message_end();
}