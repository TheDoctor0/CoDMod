#include <amxmodx>
#include <codmod>
#include <fun>

new bool:ma_klase[33];

new const nazwa[]   = "Umarly";
new const opis[]    = "+10 hp za kazde zabojstwo";
new const bronie    = (1<<CSW_FIVESEVEN)|(1<<CSW_AK47);
new const zdrowie   = 15;
new const kondycja  = 10;
new const inteligencja = 5;
new const wytrzymalosc = 20;

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Darmowe");

	register_event("DeathMsg", "DeathMsg", "ade");
}

public cod_class_enabled(id)
	ma_klase[id] = true;

public cod_class_disabled(id)
	ma_klase[id] = false;

public DeathMsg()
{
	new kid = read_data(1);
	
	if(!is_user_alive(kid)) return;
	
	if(ma_klase[kid])
		set_user_health(kid, get_user_health(kid)+10)
}
