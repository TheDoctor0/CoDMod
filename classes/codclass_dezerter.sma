#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <cod>

#define PLUGIN "CoD Class Dezerter"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Dezerter"
#define DESCRIPTION  "Ma 1 rakiete, ubranie wroga i 1/6 szansy na odrodzenie na respie wroga."
#define FRACTION     ""
#define WEAPONS      (1<<CSW_GALIL)|(1<<CSW_USP)
#define HEALTH       -10
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      10
#define CONDITION    10

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id)
{
	cod_set_user_rockets(id, 1, CLASS);
	
	cod_set_user_model(id, 1, CLASS);
}

public cod_spawned(id)
{
	cod_add_user_rockets(id, 1);

	if(random_num(1, 6) == 1) set_task(0.1, "teleport_to_enemy_spawn");
}

public cod_class_skill_used(id)
	cod_use_user_rocket(id);

public teleport_to_enemy_spawn(id)
{
	new origin[3], Float:originFloat[3], Float:angle[3];

	find_free_spawn(get_user_team(id), originFloat, angle);

	FVecIVec(originFloat, origin);

	fm_set_user_origin(id, origin);

	set_pev(id, pev_angles, angle);
}

stock const spawnEntString[2][] = {"info_player_deathmatch", "info_player_start"};

stock find_free_spawn(teamNumber, Float:spawnOrigin[3], Float:spawnAngle[3])
{
	const maxSpawns = 128;

	new spawnPoints[maxSpawns], bool:spawnChecked[maxSpawns], spawnPoint, spawnNum, ent = -1, spawnsFound = 0;

	while((ent = fm_find_ent_by_class(ent, spawnEntString[teamNumber - 1])) && spawnsFound < maxSpawns) spawnPoints[spawnsFound++] = ent;

	new Float:vicinity = 100.0, entList[1], i;

	for(i = 0; i < maxSpawns; i++) spawnChecked[i] = false;

	i = 0;

	while(i++ < spawnsFound * 10)
    {
		spawnNum = random(spawnsFound);
		spawnPoint = spawnPoints[spawnNum];

		if(spawnPoint && !spawnChecked[spawnNum])
		{
			spawnChecked[spawnNum] = true;

			pev(spawnPoint, pev_origin, spawnOrigin)

			if(!fm_find_sphere_class(0, "player", vicinity, entList, 1, spawnOrigin))
			{
				pev(spawnPoint, pev_angles, spawnAngle);

				return spawnPoint;
			}
		}
	}

	return 0;
}

stock fm_find_sphere_class(ent, const className[], Float:radius, entList[], maxEnts, Float:origin[3] = {0.0, 0.0, 0.0})
{
	if(pev_valid(ent)) pev(ent, pev_origin, origin);

	new tempEnt, tempClass[32], entsFound;

	while((tempEnt = fm_find_ent_in_sphere(tempEnt, origin, radius)) && entsFound < maxEnts)
	{
		if(pev_valid(tempEnt))
		{
			pev(tempEnt, pev_classname, tempClass, charsmax(tempClass));

			if(equal(className, tempClass)) entList[entsFound++] = tempEnt;
		}
	}

	return entsFound;
}
