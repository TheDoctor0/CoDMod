
#include <amxmodx>
#include <fakemeta>
#include <codmod>

#define TASK_ID 128000

new msg_bartime;

////////////

#define nazwa "Spowalniacz"
#define opis "Po naladowaniu noza masz 1/4 szansy na spowolnienie wroga o 40 procent"
#define bronie (1<<CSW_DEAGLE | 1<<CSW_M4A1)
#define zdrowie 10
#define kondycja 10
#define wytrzymalosc 10
#define inteligencja 10


#define CZAS_LADOWANIA 10

new bool:moc_zaladowana[33];
new bool:ma_klase[33];
new bool:spowolnij[33];

public plugin_init() {
	register_plugin(nazwa, "1,0", "QTM. Peyote")
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
	register_event("ResetHUD", "ResetHUD", "abe");
	register_event("Damage", "Damage", "be", "2!0", "3=0", "4!0")
	msg_bartime = get_user_msgid("BarTime");
	
	register_forward(FM_PlayerPreThink, "client_PreThink");
	
}

public cod_class_enabled(id)
	ma_klase[id] = true;
	
public cod_class_disabled(id)
	ma_klase[id] = false;

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
	if (spowolnij[id]) set_pev(id, pev_maxspeed, pev(id, pev_maxspeed)*0.6);
	if (get_user_weapon(id) == CSW_KNIFE && !moc_zaladowana[id] && ma_klase[id])
	{
		set_task(CZAS_LADOWANIA.0, "MocZaladowana", id+TASK_ID);
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

public MocZaladowana(id)
{
	id -= TASK_ID;
	
	if (!ma_klase[id]) return;
	
	moc_zaladowana[id] = true;
	client_print(id, print_center, "Umiejetnosc zostala aktywowana!");
	CurWeapon(id);
}
	
	
public ResetHUD(id)
{
	moc_zaladowana[id] = false;
	spowolnij[id] = false;
}

#define TASK_ZATRUCIE 64000


public Damage(id)
{
	new attacker = get_user_attacker(id);

	if (!is_user_alive(attacker)) return;
	
	if (!moc_zaladowana[attacker]) return;

	spowolnij[id] = true;
	set_pev(id, pev_maxspeed, pev(id, pev_maxspeed)*0.6);
}
