#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <cod>

#define PLUGIN "CoD Class Replikant"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Replikant"
#define DESCRIPTION  "Ma dwie repliki odbijajace polowe obrazen, podwojny skok i mniejsza grawitacje."
#define FRACTION     "Premium"
#define WEAPONS      (1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE)
#define HEALTH       25
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      10
#define CONDITION    15

#define REPLICAS     2

new itemLastUse[MAX_PLAYERS + 1], itemUse[MAX_PLAYERS + 1];

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);

	RegisterHam(Ham_TakeDamage, "info_target", "take_damage");
}

public client_disconnected(id)
	cod_remove_ents(id, "replica");

public cod_class_enabled(id, promotion)
{
	cod_set_user_gravity(id, -0.3, CLASS);

	cod_set_user_multijumps(id, 1, CLASS);

	itemUse[id] = REPLICAS;
}

public cod_class_spawned(id, respawn)
	if (!respawn) itemUse[id] = REPLICAS;

public cod_new_round()
	cod_remove_ents(0, "replica");

public cod_class_skill_used(id)
{
	if (!itemUse[id]) {
		cod_show_hud(id, TYPE_DHUD, 218, 40, 67, -1.0, 0.42, 0, 0.0, 2.0, 0.0, 0.0, "Juz wykorzystales wszystkie repliki!");

		return;
	}
	
	if (itemLastUse[id] + 5.0 > get_gametime()) {
		cod_show_hud(id, TYPE_DHUD, 218, 40, 67, -1.0, 0.42, 0, 0.0, 2.0, 0.0, 0.0, "Replike mozesz postawic raz na 5 sekund!");

		return;
	}

	if (!(pev(id, pev_flags) & FL_ONGROUND)) {
		cod_show_hud(id, TYPE_DHUD, 218, 40, 67, -1.0, 0.42, 0, 0.0, 2.0, 0.0, 0.0, "Musisz stac na podlozu, zeby postawic replike!");

		return;
	}
		
	if (!cod_is_enough_space(id)) {
		cod_show_hud(id, TYPE_DHUD, 218, 40, 67, -1.0, 0.42, 0, 0.0, 2.0, 0.0, 0.0, "Nie mozesz postawic repliki w przejsciu!");

		return;
	}

	itemLastUse[id] = floatround(get_gametime());
	itemUse[id]--;
	
	new entModel[64], playerModel[32], Float:entOrigin[3], Float:entAngles[3], entSequence = entity_get_int(id, EV_INT_gaitsequence);

	entSequence = (entSequence == 3 || entSequence == 4) ? 1 : entSequence;

	cs_get_user_model(id, playerModel, charsmax(playerModel));

	format(entModel, charsmax(playerModel), "models/player/%s/%s.mdl", playerModel, playerModel);

	entity_get_vector(id, EV_VEC_angles, entAngles);
	entity_get_vector(id, EV_VEC_origin, entOrigin);
	
	entAngles[0] = 0.0;
	
	new ent = create_entity("info_target");
	
	entity_set_string(ent, EV_SZ_classname, "replica");
	entity_set_model(ent, entModel);
	entity_set_vector(ent, EV_VEC_origin, entOrigin);
	entity_set_vector(ent, EV_VEC_angles, entAngles);
	entity_set_vector(ent, EV_VEC_v_angle, entAngles);
	entity_set_int(ent, EV_INT_sequence, entSequence);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_float(ent, EV_FL_health, 300.0);
	entity_set_float(ent, EV_FL_takedamage, DAMAGE_YES);
	entity_set_size(ent, Float:{-16.0, -16.0, -36.0}, Float:{16.0, 16.0, 40.0});
	entity_set_int(ent, EV_INT_iuser1, id);
}

public take_damage(victim, inflictor, attacker, Float:damage, damageBits)
{
	if (!is_user_alive(attacker)) return HAM_IGNORED;
		
	new className[32];

	entity_get_string(victim, EV_SZ_classname, className, charsmax(className));
	
	if (!equal(className, "replica")) return HAM_IGNORED;
	
	new owner = entity_get_int(victim, EV_INT_iuser1);
	
	if (get_user_team(owner) == get_user_team(attacker)) return HAM_SUPERCEDE;
		
	new itemName[32], bool:knifeUsed = get_user_weapon(attacker) == CSW_KNIFE;

	cod_get_user_item_name(attacker, itemName, charsmax(itemName));

	if (equal(itemName, "Pogromca Replik")) damage *= 2;
	
	if (!knifeUsed && !(equal(itemName, "Pogromca Replik"))) cod_inflict_damage(owner, attacker, damage * 0.5, 0.0, damageBits);
	
	if (damage > entity_get_float(victim, EV_FL_health)) {
		if (!knifeUsed) cod_make_explosion(victim, 190, 1);
		else cod_make_explosion(victim, 190, 1, 190.0, 50.0, 0.0);
	}
	
	return HAM_IGNORED;
}