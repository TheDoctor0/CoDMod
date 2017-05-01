#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Szturmowiec"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Mnich";
new const description[] = "Posiada teleport, ktorego moze uzyc co 15 sekund";
new const fraction[] = "";
new const weapons = (1<<CSW_AK47)|(1<<CSW_P228);
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
	cod_set_user_teleports(id, -1);
	
public cod_class_disabled(id, promotion)
	cod_set_user_teleports(id, 0);

public cod_class_spawned(id)
	cod_set_user_teleports(id, -1);

public cod_class_skill_used(id)
	cmd_execute(id, "+teleport");
