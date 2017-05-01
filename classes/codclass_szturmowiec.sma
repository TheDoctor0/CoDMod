#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Szturmowiec"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Szturmowiec";
new const description[] = "Ma 1 rakiete i nie slychac jego krokow.";
new const fraction[] = "";
new const weapons = (1<<CSW_M4A1)|(1<<CSW_DEAGLE);
new const health = 20;
new const intelligence = 0;
new const strength = 0;
new const stamina = 10;
new const condition = 20;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
{
	cod_set_user_footsteps(id, CLASS, 1);
	cod_set_user_rockets(id, 1);
}
	
public cod_class_disabled(id, promotion)
	cod_set_user_footsteps(id, CLASS, 0);

public cod_class_spawned(id)
	cod_add_user_rockets(id, 1);

public cod_class_skill_used(id)
	client_cmd(id, "+rocket");