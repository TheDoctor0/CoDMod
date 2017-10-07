#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <hamsandwich>
        
new const nazwa[]   = "Spryciarz";
new const opis[]    = "Posiada M4|FAMAS|FB ma 40% wiecej obrazen z famasa, 4 fleshe nie slychac jego krokow.";
new const bronie    = (1<<CSW_FAMAS)|(1<<CSW_M4A1)|(1<<CSW_FLASHBANG);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;
    
new ma_klase[33]; 
   
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_C))
	{
		client_print(id, print_chat, "[Spryciarz] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	ma_klase[id] = true;
	set_user_footsteps(id,1)
	return COD_CONTINUE;
}
public cod_class_disabled(id)
{
	ma_klase[id] = false
	set_user_footsteps(id,0)
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits) 
{ 
	if (!is_user_connected(idattacker)) 
		return HAM_IGNORED; 
	
	if (!ma_klase[idattacker]) 
		return HAM_IGNORED; 
	
	if (!(damagebits & (1<<1))) 
		return HAM_IGNORED; 
		
	if (get_user_weapon(idattacker) & CSW_FAMAS)
	{
		damage*=1.4;
	}
	
	return HAM_IGNORED; 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
