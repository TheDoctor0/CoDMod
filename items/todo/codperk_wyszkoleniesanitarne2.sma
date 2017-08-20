#include <amxmodx>
#include <codmod>
#include <fun>

#define TASK_WYSZKOLENIE_SANITARNE 736

new const perk_name[] = "Wyszkolenie Sanitarne";
new const perk_desc[] = "Co 5 sekund dostajesz 10 HP";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	set_task(5.0, "WyszkolenieSanitarne", id+TASK_WYSZKOLENIE_SANITARNE);
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public WyszkolenieSanitarne(id)
{
	id -= TASK_WYSZKOLENIE_SANITARNE;
	
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;
		
	if(ma_perk[id])
	{
		set_task(5.0, "WyszkolenieSanitarne", id+TASK_WYSZKOLENIE_SANITARNE);

            new cur_health = get_user_health(id);
            new max_health = 100+cod_get_user_health(id);
            new new_health = cur_health+10<max_health? cur_health+10: max_health;
            set_user_health(id, new_health);
	}
	return PLUGIN_CONTINUE;
}