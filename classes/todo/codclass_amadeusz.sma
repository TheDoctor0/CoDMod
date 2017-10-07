#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
        
new const nazwa[]   = "Amadeusz";
new const opis[]    = "Dodatkowe  5(+inteligencja) obrazen z MP5";
new const bronie    = (1<<CSW_MP5NAVY);
new const zdrowie   = 20;
new const kondycja  = 10;
new const inteligencja = 0;
new const wytrzymalosc = 5;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

}
public cod_class_enabled(id)
{
	ma_klase[id] = true;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits) 
{ 
	if (!is_user_connected(idattacker)) 
		return HAM_IGNORED; 
	
	if (!ma_klase[idattacker]) 
		return HAM_IGNORED; 
	
	if (!(damagebits & (1<<1))) 
		return HAM_IGNORED; 
		
	if (get_user_weapon(idattacker) & CSW_MP5NAVY)
	{
		damage+=5+(cod_get_user_intelligence(idattacker)/10);
	}
	
	return HAM_IGNORED; 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
