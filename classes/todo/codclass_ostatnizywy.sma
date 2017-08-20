#include <amxmodx> 
#include <hamsandwich>
#include <codmod>
#include <colorchat>

new const nazwa[] = "Ostatni Zywy";
new const opis[] = "Posiadajac ta klase stajesz sie niesmiertelny pod koniec rundy !";
new const bronie = 1<<CSW_M4A1 | 1<<CSW_HEGRENADE;
new const zdrowie = 20;
new const kondycja = 40;
new const inteligencja = 10;
new const wytrzymalosc = 10;

new bool:ma_klase[33], bool:niesmiertelnosc[33];

public plugin_init() {
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_event("SendAudio", "round_end", "a", "2=%!MRAD_terwin", "2=%!MRAD_ctwin", "2=%!MRAD_rounddraw");

	RegisterHam(Ham_Spawn, "player", "odrodzenie", 0);
	RegisterHam(Ham_TakeDamage, "player", "obrazenia", 0);
}

public cod_class_enabled(id)
{
	ColorChat(id, GREEN, "Klasa %s zostala stworzona przez CBeebies", nazwa);
	ma_klase[id] = true;
}

public cod_class_disabled(id)
	ma_klase[id] = false;

public round_end()
	set_task(0.1, "aktywacja");

public aktywacja(id) 
{
	if(is_user_alive(id) && ma_klase[id])
		niesmiertelnosc[id] = true;
}

public odrodzenie(id) {
	if(niesmiertelnosc[id])
		niesmiertelnosc[id] = false;
}

public obrazenia(id) {
	if(niesmiertelnosc[id])
		return HAM_SUPERCEDE;

	return HAM_IGNORED;
}
