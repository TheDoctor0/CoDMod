#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fun>

new const nazwa[]   = "Dream Eater";
new const opis[]    = "Zamienia miejsce i HP ofiary,ktora znajdziemy w poblizu.";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_M4A1)|(1<<CSW_DEAGLE);
new const zdrowie   = 30;
new const kondycja  = 15;
new const inteligencja = 10;
new const wytrzymalosc = 20;

new ma_klase[33];
new origin[3];
new best_origin[3];
new poprzedni_skan[33];
new licznik[33];
new bool:znalazl_pierwszego[33];
new Float:odleglosc = 700.0

public plugin_init()
{
	register_plugin(nazwa, "1.0", "UTeam");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}
public client_disconnect(id)
{
	znalazl_pierwszego[id] = false;
	licznik[id] = 0;
	poprzedni_skan[id] = 0;
}
public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[Nazwa] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	give_item(id, "weapon_hegrenade");
	ma_klase[id] = true;
	
	return COD_CONTINUE;
}
public cod_class_disabled(id)
	ma_klase[id] = false;

public cod_class_skill_used(id)
{
	if (!ma_klase[id])
		return COD_STOP;
		
	if (poprzedni_skan[id] + 45.0 > get_gametime())
	{
		client_print(id,print_chat,"Skanowac mozesz za %i",licznik[id]);	
		return PLUGIN_CONTINUE;
	}
	
	new zdrowie = 0;
	new entlist[33], pid, i;
	new best_zdrowie = 0;
	new best_id = 0;
	new numfound = find_sphere_class(id, "player", odleglosc, entlist, 31);
	for(i=0; i<numfound; i++) 
	{
		pid = entlist[i];
		
		if (pid == id || !is_user_alive(pid)) continue;
		
		zdrowie = get_user_health(id);
		new zdrowiePid = 0;
		zdrowiePid = get_user_health(pid);
		
		if (is_user_connected(pid) && zdrowiePid > zdrowie && !znalazl_pierwszego[id])	
		{	
			znalazl_pierwszego[id] = true;
			best_zdrowie = zdrowiePid
			best_id = pid;
			
		}
		else if (is_user_connected(pid) && zdrowiePid > best_zdrowie && znalazl_pierwszego[id])	
		{	
			best_zdrowie = zdrowiePid
			best_id = pid;
			
		}
		
		if (znalazl_pierwszego[id])
		{
			
			poprzedni_skan[id] = floatround(get_gametime());
			licznik[id] = 45;
			set_task(1.0,"Licznik",id);
			
			set_user_health(id,best_zdrowie);
			set_user_health(best_id,zdrowie);
			
			get_user_origin(id, origin);
			get_user_origin(best_id, best_origin);
			
			set_user_origin(id,best_origin);
			set_user_origin(best_id,origin);
		}
		
		if (!znalazl_pierwszego[id])
			client_print(id,print_chat,"Nie znaleziono odpowiedniej ofiary !!")
	}
	
	return COD_CONTINUE;
}
public Licznik(id)
{
	if (licznik[id] < 1)
	{
		znalazl_pierwszego[id] = false;
		return COD_STOP;
	}
	
	licznik[id]--;
	set_task(1.0,"Licznik",id);
	
	return COD_CONTINUE;
}