#include <amxmodx>
#include <fakemeta>
#include <codmod>
#include <fun>

#define TASK_ID 128000

new msg_bartime;

new const nazwa[] = "Noz Medyka";
new const opis[] = "Na nozu regenerujesz hp";

#define CZAS_LADOWANIA 3  // Po jakim czasie ma dodac hp

new bool:ma_perk[33];

public plugin_init() {
	register_plugin(nazwa, "1.0", "Sewek");
	
	cod_register_perk(nazwa, opis);
	
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
	msg_bartime = get_user_msgid("BarTime");
	
	register_forward(FM_PlayerPreThink, "client_PreThink");
	
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
	ma_perk[id] = false;

public client_PreThink(id)
{
	if (!task_exists(id+TASK_ID))
		return;
		
	if (pev(id, pev_button) & (IN_MOVELEFT+IN_MOVERIGHT+IN_FORWARD+IN_BACK+IN_JUMP+IN_DUCK))
	{
		change_task(id+TASK_ID, CZAS_LADOWANIA.0);
		set_bartime(id, CZAS_LADOWANIA);
	}
}

public CurWeapon(id)
{
	if (get_user_weapon(id) == CSW_KNIFE && ma_perk[id])
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
	message_begin((id)?MSG_ONE:MSG_ALL, msg_bartime, _, id)
	write_short(czas);
	message_end();   
}

public Dajhp(id)
{
	id -= TASK_ID;
	
	if (!ma_perk[id] && !is_user_connected(id)) return;
	
	new cur_health = get_user_health(id);
	new max_health = 100+cod_get_user_health(id);
	new new_health = cur_health+5<max_health? cur_health+5: max_health;
	set_user_health(id, new_health);
	CurWeapon(id);
}