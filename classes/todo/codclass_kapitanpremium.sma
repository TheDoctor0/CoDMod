#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new const nazwa[]   = "Kapitan [Premium]";
new const opis[]    = "Posiada 1/4 na natychmiastowe zabicie z Deagla i 1/1 z AWP";
new const bronie    = (1<<CSW_AWP)|(1<<CSW_DEAGLE);
new const zdrowie   = 1200;
new const kondycja  = 2000;
new const inteligencja = 500;
new const wytrzymalosc = 800;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_A))
	{
		client_print(id, print_chat, "[Kapitan [Premium]] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	ma_klase[id]= true;
	return COD_CONTINUE;
}
public cod_class_disabled(id)
{
	ma_klase[id]=false;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if(!(damagebits & DMG_BULLET))
		return HAM_IGNORED;
	
	if(get_user_weapon(idattacker) == CSW_AWP && random_num(1,1) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	if(get_user_weapon(idattacker) == CSW_DEAGLE && random_num(1,4) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
