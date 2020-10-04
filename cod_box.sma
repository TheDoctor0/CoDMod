#include <amxmodx>
#include <fun>
#include <engine>
#include <cstrike>
#include <fakemeta_util>
#include <cod>

#define PLUGIN "CoD Box"
#define AUTHOR "O'Zone"

new const boxClass[] = "cod_box", boxModel[] = "models/CoDMod/box.mdl";

new cvarBoxChance, spriteGreen, spriteAcid, boxDroppedForward;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_touch(boxClass, "player", "touch_box");

	bind_pcvar_num(create_cvar("cod_box_chance", "5"), cvarBoxChance);

	boxDroppedForward = CreateMultiForward("cod_box_dropped", ET_IGNORE, FP_CELL);
}

public plugin_precache()
{
	precache_model(boxModel);

	spriteGreen = precache_model("sprites/CoDMod/green.spr");
	spriteAcid = precache_model("sprites/CoDMod/acid_pou.spr");
}

public cod_killed(killer, victim, weaponId, hitPlace)
{
	if (cvarBoxChance && random_num(1, cvarBoxChance) == 1) {
		create_box(victim);
	}
}

public cod_new_round()
{
	remove_entity_name(boxClass);
}

public create_box(id)
{
	new ret, ent, Float:origin[3];

	entity_get_vector(id, EV_VEC_origin, origin);

	origin[0] += 30.0;
	origin[2] -= fm_distance_to_floor(id);

	ent = fm_create_entity("info_target");

	set_pev(ent, pev_classname, boxClass);

	entity_set_model(ent, boxModel);

	entity_set_origin(ent, origin);

	set_pev(ent, pev_mins, Float:{-10.0, -10.0, 0.0});
	set_pev(ent, pev_maxs, Float:{10.0, 10.0, 50.0});
	set_pev(ent, pev_size, Float:{-1.0, -3.0, 0.0, 1.0, 1.0, 10.0});

	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER);
	set_pev(ent, pev_movetype, MOVETYPE_FLY);

	ExecuteForward(boxDroppedForward, ret, ent);

	return PLUGIN_CONTINUE;
}

public touch_box(ent, id)
{
	if (!is_user_alive(id) || !pev_valid(ent)) return PLUGIN_CONTINUE;

	new icon = pev(ent, pev_iuser1);

	if (pev_valid(icon)) {
		remove_entity(icon);
	}

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

	cod_emit_sound(id, SOUND_PICKUP);

	remove_entity(ent);

	get_box(id);

	return PLUGIN_CONTINUE;
}

public get_box(id)
{
	switch (random_num(1, cod_get_user_item(id) ? 9 : 10)) {
		case 1: {
			new frags = random_num(1, 3);

			set_user_frags(id, get_user_frags(id) + frags);

			cod_print_chat(id, "Dostales^4 %i frag%s^1!", frags, frags == 1 ? "a" : "i");
		} case 2: {
			new deaths = random_num(1, 2), frags = deaths - cs_get_user_deaths(id);

			if (frags > 0) set_user_frags(id, get_user_frags(id) + frags);

			cs_set_user_deaths(id, max(0, cs_get_user_deaths(id) - deaths));

			cod_print_chat(id, "Masz o^4 %i zgon%s^1 mniej!", deaths, deaths == 1 ? "" : "y");
		} case 3: {
			new health = random_num(15, 75);

			cod_set_user_health(id, cod_get_user_health(id, 1) + health);

			cod_print_chat(id, "Dostales^4 +%i HP^1!", health);
		} case 4: {
			new exp = random_num(25, 75);

			cod_set_user_exp(id, exp);

			cod_print_chat(id, "Dostales^4 %i doswiadczenia^1!", exp);
		} case 5: {
			new honor = random_num(5, 25);

			cod_add_user_honor(id, honor);

			cod_print_chat(id, "Dostales^4 %i Honoru^1!", honor);
		} case 6: {
			cod_add_user_rockets(id, 1);

			cod_print_chat(id, "Dostales^4 Rakiete^1!");
		} case 7: {
			cod_add_user_mines(id, 1);

			cod_print_chat(id, "Dostales^4 Mine^1!");
		} case 8: {
			cod_add_user_medkits(id, 1);

			cod_print_chat(id, "Dostales^4 Apteczke^1!");
		} case 9: {
			cod_add_user_dynamites(id, 1);

			cod_print_chat(id, "Dostales^4 Dynamit^1!");
		} case 10: {
			cod_set_user_item(id, RANDOM);

			cod_print_chat(id, "Trafiles na^4 losowy item^1!");
		}
	}

	return PLUGIN_CONTINUE;
}