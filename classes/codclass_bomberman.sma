#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Bomberman"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Bomberman";
new const description[] = "Ma 2 dynamity, ktore moze podkladac i detonowac.";
new const fraction[] = "";
new const weapons = (1<<CSW_AUG)|(1<<CSW_USP);
new const health = 10;
new const intelligence = 0;
new const strength = 10;
new const stamina = 10;
new const condition = 0;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
	cod_set_user_dynamites(id, 2);

public cod_class_spawned(id)
	cod_add_user_dynamites(id, 2);

public cod_class_skill_used(id)
	cmd_execute(id, "+dynamite");