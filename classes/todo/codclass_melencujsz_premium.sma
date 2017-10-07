#include <amxmodx>
#include <amxmisc>
#include <codmod>
        
new const nazwa[]   = "Melencjusz(Premium)";
new const opis[]    = "50HP i 100 Kondycji";
new const bronie    = 0;
new const zdrowie   = -50;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 100;
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[Melencjusz(Premium)] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
   
	return COD_CONTINUE;
}

