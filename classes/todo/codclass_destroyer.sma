#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <hamsandwich>

#define DMG_BULLET (1<<1)
        
new const nazwa[]   = "Destroyer[P]";
new const opis[]    = "Ma 1/4 z kazdej broni";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_M4A1)|(1<<CSW_FLASHBANG)|(1<<CSW_DEAGLE);
new const zdrowie   = 0;
new const kondycja  = 0;
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
		client_print(id, print_chat, "[Destroyer[P]] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_smokegrenade");
	ma_klase[id] = true;
	
	return COD_CONTINUE;
}
public cod_class_disabled(id)
{
	ma_klase[id] = false;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if(!(damagebits & DMG_BULLET))
		return HAM_IGNORED;
	
	if(random_num(1,4) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
