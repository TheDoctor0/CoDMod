#include <amxmodx>
#include <codmod>
#include <fun>

#define TASK_ID 128000

new const nazwa[] = "Noz medyka";
new const opis[] = "Na nozu co 2 sekundy dostajesz 3 hp";

#define CZAS_LADOWANIA 2  // Po jakim czasie ma dodac hp

new bool:ma_perk[33],
msg_bartime

public plugin_init()
{
	register_plugin(nazwa, "1.0", "Sewek");
	
	cod_register_perk(nazwa, opis);
	
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
	msg_bartime = get_user_msgid("BarTime");
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
      remove_task(id+TASK_ID);
      set_bartime(id, 0);
}

public CurWeapon(id)
{
	if(!ma_perk[id]) return;
	
	if(read_data(2) == CSW_KNIFE)
	{
		set_task(CZAS_LADOWANIA.0, "Dajhp", id+TASK_ID);
		set_bartime(id, CZAS_LADOWANIA);
	}
	else
	{
		remove_task(id+TASK_ID);
		set_bartime(id, 0);
	}
}

stock set_bartime(id, czas)
{
	message_begin(MSG_ONE_UNRELIABLE, msg_bartime, _, id)
	write_short(czas);
	message_end();   
}

public Dajhp(id)
{
	id -= TASK_ID;
	
	if(!is_user_alive(id) || !ma_perk[id]) return;
	
	new cur_health = get_user_health(id);
	new max_health = 100+cod_get_user_health(id);
	new new_health = cur_health+3<max_health? cur_health+3: max_health;
	set_user_health(id, new_health);

      if(get_user_weapon(id) == CSW_KNIFE)
	{
		set_task(CZAS_LADOWANIA.0, "Dajhp", id+TASK_ID);
		set_bartime(id, CZAS_LADOWANIA);
	}
}