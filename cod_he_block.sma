#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD HE Block"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define TASK_BLOCK 7526
#define TASK_INFO 8432

new bool:block;

new Float:roundStart;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_hegrenade", "block_he");
}

public cod_new_round()
	block = true;

public cod_start_round()
{
	remove_task(TASK_BLOCK);

	set_task(10.0, "unblock_he", TASK_BLOCK);

	roundStart = get_gametime();
}

public cod_end_round()
	remove_task(TASK_BLOCK);

public cod_weapon_deploy(id, weapon, ent)
{
	if(weapon == CSW_HEGRENADE && block) set_task(0.1, "show_info", id + TASK_INFO, .flags = "b");
	else if(task_exists(id + TASK_INFO))
	{
		client_print(id, print_center, "");

		remove_task(id + TASK_INFO);
	}
}

public show_info(id)
{
	id -= TASK_INFO;

	new Float:currentTime = (roundStart + 10.0) - get_gametime();

	if(currentTime <= 0.0)
	{
		client_print(id, print_center, "");

		remove_task(id + TASK_INFO);

		return;
	}

	client_print(id, print_center, "Granaty zostana odblokowane za %0.1fs", currentTime);
}

public block_he(weapon)
{
	if(block) 
	{ 
		new id = pev(weapon, pev_owner);

		if(!task_exists(id + TASK_INFO)) set_task(0.1, "show_info", id + TASK_INFO, .flags = "b");

		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}

public unblock_he()
	block = false;