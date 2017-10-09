#include <amxmodx>
#include <cod>
#include <fakemeta>
#include <engine>

#define PLUGIN "CoD Item Aimbot"
#define VERSION "1.0.15"
#define AUTHOR "O'Zone"

#define NAME        "Aimbot"
#define DESCRIPTION "Po uzyciu itemu namierzona zostaje glowa najblizszego przeciwnika"

new itemActive;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	set_bit(id, itemActive);

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public cod_item_skill_used(id)
{
	if (!get_bit(id, itemActive)) return;

	new target = get_nearest_player(id);
			
	if (target) {
		cod_show_hud(id, TYPE_HUD, 0, 255, 0, -1.0, 0.43, 0, 0.0, 1.0, 1.0, 1.0, "Namierzono glowe przeciwnika!");
		
		new Float:headOrigin[3], Float:headAngles[3];

		engfunc(EngFunc_GetBonePosition, target, 8, headOrigin, headAngles);	
		
		if (get_user_weapon(id) == CSW_AK47 || get_user_weapon(id) == CSW_AUG || get_user_weapon(id) == CSW_GALIL || get_user_weapon(id) == CSW_DEAGLE) headOrigin[2] -= 14.0;
		else headOrigin[2] -= 8.5;
		
		entity_set_aim(id, headOrigin);
	}
	else cod_show_hud(id, TYPE_HUD, 0, 255, 0, -1.0, 0.43, 0, 0.0, 1.0, 1.0, 1.0, "Wszyscy przeciwnicy sa zbyt daleko.");
}

stock entity_set_aim(ent, const Float:oldOrigin[3])
{
	if (!pev_valid(ent)) return;
	
	static Float:origin[3], Float:entOrigin[3], Float:vectorLength, Float:aimVector[3], Float:newAngles[3];

	origin[0] = oldOrigin[0];
	origin[1] = oldOrigin[1];
	origin[2] = oldOrigin[2];
	
	pev(ent, pev_origin, entOrigin);
	
	origin[0] -= entOrigin[0];
	origin[1] -= entOrigin[1];
	origin[2] -= entOrigin[2];
	
	vectorLength = vector_length(origin);
	
	aimVector[0] = origin[0] / vectorLength;
	aimVector[1] = origin[1] / vectorLength;
	aimVector[2] = origin[2] / vectorLength;

	vector_to_angle(aimVector, newAngles);
	
	newAngles[0] *= -1;
	
	if (newAngles[1] > 180.0) newAngles[1] -= 360;
	if (newAngles[1] < -180.0) newAngles[1] += 360;
	if (newAngles[1] == 180.0 || newAngles[1] == -180.0) newAngles[1] = -179.999999;
	
	set_pev(ent, pev_angles, newAngles);
	set_pev(ent, pev_fixangle, 1);
}	

stock get_nearest_player(ent)
{
	new Float:nearestDistance = 1000.0, Float:distance, nearestPlayer;
	
	for (new id = 1; id <= MAX_PLAYERS; id++) {
		if (!is_user_connected(id) || !is_user_alive(id) || get_user_team(id) == get_user_team(ent)) continue;

		distance = entity_range(id, ent);
		
		if (distance < nearestDistance) {
			nearestPlayer = id;
			nearestDistance = distance;
		}
	}

	return nearestPlayer;
}