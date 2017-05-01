#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Skoczek"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Skoczek";
new const description[] = "Ma BunnyHop i dodatkowy skok.";
new const fraction[] = "";
new const weapons = (1<<CSW_UMP45)|(1<<CSW_FIVESEVEN);
new const health = 10;
new const intelligence = 0;
new const strength = 10;
new const stamina = 0;
new const condition = 30;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_bunnyhop(id, CLASS, 1);
	cod_set_user_multijumps(id, 1);
}

public cod_class_disabled(id, promotion)
	cod_set_user_bunnyhop(id, CLASS, 0);

public cod_class_spawned(id)
	cod_add_user_multijumps(id, 1);