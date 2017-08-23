#include <amxmodx>
#include <cod>
#include <engine>

#define PLUGIN "CoD Item Elektromagnes"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

new const name[] = "Elektromagnes";
new const description[] = "Co runde mozesz polozyc elektromagnes, ktory przyciaga bronie przeciwnikow";

enum _:itemSounds { CHARGE, ACTIVATE, DEPLOY };

new const itemSound[itemSounds][] = { "CoDMod/mine_charge.wav", "CoDMod/mine_activate.wav", "CoDMod/mine_deploy.wav" };
new const itemModel[] = "models/CodMod/item.mdl";

new usedItem, spriteWhite;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(name, description);
	
	register_think("electromagnet", "electromagnet_think");
	
}

public plugin_precache()
{
	precache_model(itemModel);

	for(new i = 0; i < sizeof(itemSound); i++) precache_sound(itemSound[i]);

	spriteWhite = precache_model("sprites/white.spr");
}

public cod_item_enabled(id, value)
	rem_bit(id, usedItem);

public cod_item_spawned(id)
	rem_bit(id, usedItem);

public client_disconnected(id)
	remove_ents(id);

public cod_new_round()
	remove_ents();

public cod_item_skill_used(id)
{	
	if(get_bit(id, usedItem))
	{
		cod_show_hud(id, TYPE_HUD, 218, 40, 67, -1.0, 0.35, 0, 0.0, 3.0, 0.0, 0.0, "Wykorzystales juz elektromagnes w tej rundzie!");

		return PLUGIN_CONTINUE;
	}

	set_bit(id, usedItem);
	
	new Float:origin[3], ent = create_entity("info_target");

	entity_get_vector(id, EV_VEC_origin, origin);

	entity_set_string(ent, EV_SZ_classname, "electromagnet");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + 20.0 + 3.5);
	entity_set_model(ent, itemModel);

	drop_to_floor(ent);
	
	emit_sound(ent, CHAN_VOICE, itemSound[CHARGE], 0.5, ATTN_NORM, 0, PITCH_NORM );
	emit_sound(ent, CHAN_ITEM, itemSound[DEPLOY], 0.5, ATTN_NORM, 0, PITCH_NORM );
	
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 3.5);
	
	return PLUGIN_CONTINUE;
}

public item_think(ent)
{
	if(entity_get_int(ent, EV_INT_iuser2)) return PLUGIN_CONTINUE;
	
	if(!entity_get_int(ent, EV_INT_iuser1)) emit_sound(ent, CHAN_VOICE, itemSound[ACTIVATE], 0.5, ATTN_NORM, 0, PITCH_NORM );
	
	entity_set_int(ent, EV_INT_iuser1, 1);
	
	new Float:origin[3], entList[MAX_PLAYERS + 1], weaponName[MAX_PLAYERS + 1], id = entity_get_edict(ent, EV_ENT_owner), Float:distance = 400.0 + cod_get_user_intelligence(id) * 2, player, playerWeapons;
	
	entity_get_vector(ent, EV_VEC_origin, origin);
	
	new entsFound = find_sphere_class(0, "player", distance, entList, charsmax(entList), origin);
	
	for(new i = 0; i < entsFound; i++)
	{		
		player = entList[i];
		
		if (!is_user_alive(player) || get_user_team(player) == get_user_team(id)) continue;
		
		playerWeapons = entity_get_int(player, EV_INT_weapons);

		for(new j = 1; j <= 32; j++)
		{
			if(1<<j & playerWeapons)
			{
				get_weaponname(j, weaponName, charsmax(weaponName));

				engclient_cmd(player, "drop", weaponName);
			}
		}
	}
	
	entsFound = find_sphere_class(0, "weaponbox", distance + 100.0, entList, charsmax(entList), origin);
	
	for(new i = 0; i < entsFound; i++) if(get_entity_distance(ent, entList[i]) > 50.0) set_velocity_to_origin(entList[i], origin, 999.0);
	
	if(entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id))
	{
		entity_set_int(ent, EV_INT_iuser2, 1);

		return PLUGIN_CONTINUE;
	}
	
	new beamOrigin[3];

	FVecIVec(origin, beamOrigin);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, beamOrigin);
	write_byte(TE_BEAMCYLINDER);
	write_coord(beamOrigin[0]);
	write_coord(beamOrigin[1]);
	write_coord(beamOrigin[2]);
	write_coord(beamOrigin[0]);
	write_coord(beamOrigin[1] + floatround(distance));
	write_coord(beamOrigin[2] + floatround(distance));
	write_short(spriteWhite);
	write_byte(0);
	write_byte(0);
	write_byte(10);
	write_byte(10);
	write_byte(255);
	write_byte(0);
	write_byte(100);
	write_byte(255);
	write_byte(5);
	write_byte(0);
	message_end();
	
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);
	
	return PLUGIN_CONTINUE;
}

stock remove_ents(id = 0)
{
	new ent = find_ent_by_class(-1, "electromagnet");
	
	while(ent > 0)
	{
		if(!id || entity_get_edict(ent, EV_ENT_owner) == id) remove_entity(ent);
		
		ent = find_ent_by_class(ent, "electromagnet");
	}
}

stock get_velocity_to_origin(ent, Float:origin[3], Float:speed, Float:velocity[3])
{
	new Float:endOrigin[3];

	entity_get_vector(ent, EV_VEC_origin, endOrigin);
	
	new Float:fDistance[3];
	fDistance[0] = endOrigin[0] - origin[0];
	fDistance[1] = endOrigin[1] - origin[1];
	fDistance[2] = endOrigin[2] - origin[2];
	
	new Float:time = -(vector_distance(endOrigin, origin) / speed);
	
	velocity[0] = fDistance[0] / time;
	velocity[1] = fDistance[1] / time;
	velocity[2] = fDistance[2] / time + 50.0;
	
	return (velocity[0] && velocity[1] && velocity[2]);
}

stock set_velocity_to_origin(ent, Float:origin[3], Float:speed)
{
	new Float:velocity[3];

	get_velocity_to_origin(ent, origin, speed, velocity);
	
	entity_set_vector(ent, EV_VEC_velocity, velocity);
	
	return;
}
