#include <amxmodx>
#include <fun>
#include <engine>
#include <cstrike>
#include <fakemeta_util>
#include <cod>

#define PLUGIN "CoD Box"
#define VERSION "1.0.10"
#define AUTHOR "O'Zone"

new const boxClass[] = "cod_box", boxModel[] = "models/CoDMod/box.mdl";

new cvarBoxChance, spriteGreen, spriteAcid;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_touch(boxClass, "player", "touch_box");

	bind_pcvar_num(create_cvar("cod_box_chance", "6"), cvarBoxChance);
}

public plugin_precache()
{
	precache_model(boxModel);
	
	spriteGreen = precache_model("sprites/CoDMod/green.spr");
	spriteAcid = precache_model("sprites/CoDMod/acid_pou.spr");
}

public cod_killed(killer, victim, weaponId, hitPlace)
	if (random_num(1, cvarBoxChance) == 1) create_box(victim);

public cod_new_round()
	set_task(0.1, "remove_ents");

public remove_ents()
{
	new ent = find_ent_by_class(NONE, boxClass);
	
	while (ent > 0) {
		cod_remove_box_icon(ent);
		
		ent = find_ent_by_class(ent, boxClass);
	}
}

public create_box(id)
{
	new ent, Float:origin[3];
	
	entity_get_vector(id, EV_VEC_origin, origin);

	origin[0] += 30.0;
	origin[2] -= distance_to_floor(origin);
	
	ent = fm_create_entity("info_target");
	
	set_pev(ent, pev_classname, boxClass);

	entity_set_model(ent, boxModel);

	entity_set_origin(ent, origin);
	
	set_pev(ent, pev_mins, Float:{ -10.0, -10.0, 0.0 });
	set_pev(ent, pev_maxs, Float:{ 10.0, 10.0, 50.0 });
	set_pev(ent, pev_size, Float:{ -1.0, -3.0, 0.0, 1.0, 1.0, 10.0 });
	engfunc(EngFunc_SetSize, ent, Float:{ -1.0, -3.0, 0.0 }, Float:{ 1.0, 1.0, 10.0 });
	
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER);
	set_pev(ent, pev_movetype, MOVETYPE_FLY);

	cod_spawn_box_icon(ent);
	
	return PLUGIN_CONTINUE;
}

public touch_box(ent, id)
{
	if (!is_user_alive(id)) return PLUGIN_CONTINUE;

	cod_remove_box_icon(ent);

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
	
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, codSounds[SOUND_PICKUP], 1.0, ATTN_NORM, 0, PITCH_NORM);

	get_box(id);
	
	return PLUGIN_CONTINUE;
}

public get_box(id) 
{
	switch (random_num(1, 10)) {
		case 1: {
			new frags = random_num(1, 3);
			
			set_user_frags(id, get_user_frags(id) + frags);
			
			cod_print_chat(id, "Dostales^x04 %i frag%s^x01!", frags, frags == 1 ? "a" : "i");
		}
		case 2: {
			new deaths = random_num(1, 2), frags = deaths - cs_get_user_deaths(id);

			if (frags > 0) set_user_frags(id, get_user_frags(id) + frags);
			
			cs_set_user_deaths(id, max(0, cs_get_user_deaths(id) - deaths));
			
			cod_print_chat(id, "Masz o^x04 %i zgon%s^x01 mniej!", deaths, deaths == 1 ? "" : "y");
		}
		case 3: {
			if (cod_get_user_item(id)) {
				get_box(id);

				return PLUGIN_CONTINUE;
			}
			
			cod_set_user_item(id, RANDOM, RANDOM);
			
			cod_print_chat(id, "Trafiles na^x04 losowy item^x01!");
		}
		case 4: {
			new health = random_num(15, 75);
			
			cod_set_user_health(id, cod_get_user_health(id, 1) + health);
			
			cod_print_chat(id, "Dostales^x04 +%i HP^x01!", health);
		}
		case 5: {
			new exp = random_num(25, 75);
			
			cod_set_user_exp(id, exp);

			cod_print_chat(id, "Dostales^x04 %i Expa^x01!", exp);
		}
		case 6: {
			new honor = random_num(5, 25);
			
			cod_add_user_honor(id, honor);

			cod_print_chat(id, "Dostales^x04 %i Honoru^x01!", honor);
		}
		case 7: {
			cod_add_user_rockets(id, 1);
			
			cod_print_chat(id, "Dostales^x04 Rakiete^x01!");
		}
		case 8: {
			cod_add_user_mines(id, 1);
			
			cod_print_chat(id, "Dostales^x04 Mine^x01!");
		}
		case 9: {
			cod_add_user_medkits(id, 1);
			
			cod_print_chat(id, "Dostales^x04 Apteczke^x01!");
		}
		case 10: {
			cod_add_user_dynamites(id, 1);
			
			cod_print_chat(id, "Dostales^x04 Dynamit^x01!");
		}
	}

	return PLUGIN_CONTINUE;
}

stock Float:distance_to_floor(Float:start[3], ignoremonsters = 1)
{
	new Float:dest[3], Float:end[3];

	dest[0] = start[0];
	dest[1] = start[1];
	dest[2] = -8191.0;

	engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, 0, 0);
	get_tr2(0, TR_vecEndPos, end);

	new Float:ret = start[2] - end[2];

	return ret > 0 ? ret : 0.0;
}