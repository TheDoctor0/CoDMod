#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Medyk"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Medyk";
new const description[] = "Ma 2 apteczki, ktorymi moze leczyc siebie i innych.";
new const fraction[] = "";
new const weapons = (1<<CSW_M4A1)|(1<<CSW_GLOCK18);
new const health = 10;
new const intelligence = 0;
new const strength = 0;
new const stamina = 30;
new const condition = 0;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
	cod_set_user_medkits(id, 2);

public cod_class_spawned(id)
	cod_add_user_medkits(id, 2);

public cod_class_skill_used(id)
	cod_use_user_medkit(id);