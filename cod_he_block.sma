#include <amxmodx>
#include <cod>

#define PLUGIN "CoD HE Block"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define TASK_BLOCK 7526

new bool:block;

public plugin_init() 
	register_plugin(PLUGIN, VERSION, AUTHOR);

public cod_new_round()
{
	block = true;

	remove_task(TASK_BLOCK);

	set_task(15.0, "unblock", TASK_BLOCK);
}

public cod_weapon_deploy(id, weapon, ent)
	if(weapon == CSW_HEGRENADE && block) engclient_cmd(id, "lastinv");

public unblock()
{
	block = false;

	cod_print_chat(0, "Granaty zostaly odblokowane.")
}