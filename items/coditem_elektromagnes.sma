#include <amxmodx>
#include <cod>
#include <engine>

#define PLUGIN "CoD Item Elektromagnes"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Elektromagnes"
#define DESCRIPTION "Co runde mozesz polozyc elektromagnes, ktory przyciaga bronie przeciwnikow"

new const itemModel[] = "models/CodMod/magnet.mdl";

new itemUsed;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);

	register_think("electromagnet", "electromagnet_think");
}

public plugin_precache()
	precache_model(itemModel);

public cod_item_enabled(id, value)
	rem_bit(id, itemUsed);

public cod_item_spawned(id, respawn)
{
	if (!respawn) {
		rem_bit(id, itemUsed);
	}
}

public client_disconnected(id)
	cod_remove_ents(id, "electromagnet");

public cod_new_round()
	cod_remove_ents(0, "electromagnet");

public cod_item_skill_used(id)
{
	if (get_bit(id, itemUsed)) {
		cod_show_hud(id, TYPE_HUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Elektromagnesu mozesz uzyc tylko raz na runde!");

		return PLUGIN_CONTINUE;
	}

	set_bit(id, itemUsed);

	new Float:origin[3], ent = create_entity("info_target");

	entity_get_vector(id, EV_VEC_origin, origin);

	entity_set_string(ent, EV_SZ_classname, "electromagnet");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + 20.0 + 3.5);
	entity_set_model(ent, itemModel);

	drop_to_floor(ent);

	cod_emit_sound(player, SOUND_CHARGE, VOLUME_QUIET, CHAN_VOICE);
	cod_emit_sound(player, SOUND_ACTIVATE, VOLUME_QUIET, CHAN_ITEM);

	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 3.5);

	return PLUGIN_CONTINUE;
}

public electromagnet_think(ent)
{
	if (entity_get_int(ent, EV_INT_iuser2)) return PLUGIN_CONTINUE;

	if (!entity_get_int(ent, EV_INT_iuser1)) {
		cod_emit_sound(player, SOUND_ACTIVATE, VOLUME_QUIET, CHAN_VOICE);
	}

	entity_set_int(ent, EV_INT_iuser1, 1);

	new Float:origin[3], entList[MAX_PLAYERS + 1], weaponName[MAX_PLAYERS + 1], id = entity_get_edict(ent, EV_ENT_owner),
		Float:distance = 400.0 + cod_get_user_intelligence(id) * 2, player, playerWeapons;

	entity_get_vector(ent, EV_VEC_origin, origin);

	new entsFound = find_sphere_class(0, "player", distance, entList, charsmax(entList), origin);

	for (new i = 0; i < entsFound; i++) {
		player = entList[i];

		if (!is_user_alive(player) || get_user_team(player) == get_user_team(id)) continue;

		playerWeapons = entity_get_int(player, EV_INT_weapons);

		for (new j = 1; j <= CSW_P90; j++) {
			if (1<<j & playerWeapons) {
				get_weaponname(j, weaponName, charsmax(weaponName));

				engclient_cmd(player, "drop", weaponName);
			}
		}
	}

	entsFound = find_sphere_class(0, "weaponbox", distance + 100.0, entList, charsmax(entList), origin);

	for (new i = 0; i < entsFound; i++) {
		if (get_entity_distance(ent, entList[i]) > 50.0) {
			set_velocity_to_origin(entList[i], origin, 999.0);
		}
	}

	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id)) {
		entity_set_int(ent, EV_INT_iuser2, 1);

		return PLUGIN_CONTINUE;
	}

	cod_make_explosion(ent, floatround(distance), 0);

	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);

	return PLUGIN_CONTINUE;
}

stock get_velocity_to_origin(ent, Float:origin[3], Float:speed, Float:velocity[3])
{
	new Float:endOrigin[3], Float:distance[3];

	entity_get_vector(ent, EV_VEC_origin, endOrigin);

	distance[0] = endOrigin[0] - origin[0];
	distance[1] = endOrigin[1] - origin[1];
	distance[2] = endOrigin[2] - origin[2];

	new Float:time = -(vector_distance(endOrigin, origin) / speed);

	velocity[0] = distance[0] / time;
	velocity[1] = distance[1] / time;
	velocity[2] = distance[2] / time + 50.0;

	return (velocity[0] && velocity[1] && velocity[2]);
}

stock set_velocity_to_origin(ent, Float:origin[3], Float:speed)
{
	new Float:velocity[3];

	get_velocity_to_origin(ent, origin, speed, velocity);

	entity_set_vector(ent, EV_VEC_velocity, velocity);

	return;
}
