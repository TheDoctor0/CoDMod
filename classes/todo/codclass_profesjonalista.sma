#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
        
new const nazwa[]   = "Profesjonalista (Klasa Premium)";
new const opis[]    = "Dostaje M4A1, AK47, AWP, DEAGLE, HE, 150 hp, 140 speeda, 250 armoru";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_AWP)|(1<<CSW_M4A1)|(1<<CSW_DEAGLE)|(1<<CSW_AK47);
new const zdrowie   = 50;
new const kondycja  = 140;
new const inteligencja = 100;
new const wytrzymalosc = 250;
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_F))
	{
		client_print(id, print_chat, "[Profesjonalista (Klasa Premium)] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	give_item(id, "weapon_hegrenade");
   
	return COD_CONTINUE;
}
