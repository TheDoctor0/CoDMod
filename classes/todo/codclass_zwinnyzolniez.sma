#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
	
new const nazwa[]   = "Zwinny Zolniez";
new const opis[]    = "Obra¿enia z MP5 dodane o 8 % z inteligencji";
new const bronie    = (1<<CSW_MP5NAVY);
new const zdrowie   = 100;
new const kondycja  = 100;
new const inteligencja = 100;
new const wytrzymalosc = 100;
    
new bool:ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	cod_give_weapon(id, CSW_HEGRENADE)
}

public cod_class_disabled(id)
{
    	ma_klase[id] = false;
	cod_take_weapon(id,CSW_HEGRENADE)
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits) 
{ 
	if(!is_user_connected(idattacker)) 
		return HAM_IGNORED; 
	
	if(!ma_klase[idattacker]) 
		return HAM_IGNORED; 
	
	if(!(damagebits & (1<<1))) 
		return HAM_IGNORED; 
		
	if(get_user_weapon(idattacker) && CSW_MP5NAVY)
	{
		damage+=cod_get_user_intelligence(idattacker)/10;
	}
	
	return HAM_IGNORED; 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
