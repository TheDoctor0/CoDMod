#include <amxmodx>
#include <amxmisc>
#include <codmod>

new const nazwa[]   = "Pancernik (Klasa Premium)";
new const opis[]    = "Posiada tarczê SWAT oraz DGL";
new const bronie    = (1<<CSW_DEAGLE);
new const zdrowie   = 40;
new const kondycja  = 20;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new ma_klase[33];    

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}

public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[Pancernik (Klasa Premium)] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	cod_set_user_shield(id,true)
	ma_klase[id] = true;
	return COD_CONTINUE;
}
public cod_class_disabled(id)
{
	cod_set_user_shield(id,true)
	ma_klase[id] = true;
}
