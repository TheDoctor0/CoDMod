#include amxmodx
#include codmod
	  
new const nazwa[]   = "Wsparcie Chemiczne";
new const opis[]	= "14% szans na zatrucie przeciwnika z kazdej broni. Zatrucie zabiera 10HP przez 4 sekundy";
new const bronie	= (1<<CSW_M4A1)|(1<<CSW_HEGRENADE);
new const zdrowie   = 20;
new const kondycja  = 10;
new const inteligencja = 0;
new const wytrzymalosc = 20;

new bool:ma_klase[33];
  
public plugin_init()
{
	register_plugin(nazwa, "1.0", "sharkowy");
	register_event("Damage", "Damage", "be", "2!0", "3=0", "4!0");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}

public cod_class_enabled(id)
	ma_klase[id] = true;

public cod_class_disabled(id)
	ma_klase[id] = false

#define TASK_ZATRUCIE 64000

new zatruwajacy[33];

public Damage(id)
{
	new attacker = get_user_attacker(id);

	if (!is_user_alive(attacker))
		return;

	if (!ma_klase[attacker]) 
		return;

	if (attacker > 32) 
		return;
  
	zatruwajacy[id] = attacker;
	if (!task_exists(id+TASK_ZATRUCIE) && random(100) < 14)
		set_task(0.7, "Zatruj", id+TASK_ZATRUCIE, _, _, "a", 4);
}
public Zatruj(id)
{
	id -= TASK_ZATRUCIE;
	client_print(id, print_center, "Zostales zatruty!!");
	client_print(zatruwajacy[id], print_center, "Zatrules przeciwnika!");
	cod_inflict_damage(zatruwajacy[id], id, 10.0, 0.0); //10.0 obra¿enia, 0.0 czynnik inteligencji
}