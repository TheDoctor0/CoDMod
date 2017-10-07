#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
        
#define DMG_BULLET (1<<1)
	
new const nazwa[]   = "Terminator (Premium)";
new const opis[]    = "Posiada 1/5 z XM 1014 i Deagla.";
new const bronie    = (1<<CSW_XM1014)|(1<<CSW_DEAGLE);
new const zdrowie   = 20;
new const kondycja  = 15;
new const inteligencja = 10;
new const wytrzymalosc = 10;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);   
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[Terminator (Premium)] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	ma_klase[id] = true;
   
	return COD_CONTINUE;
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
        
        if (!(damagebits & DMG_BULLET))
                return HAM_IGNORED;
                
        if (get_user_weapon(idattacker) == CSW_XM1014 && random_num(1,5) == 1 || get_user_weapon(idattacker) == CSW_DEAGLE && random_num(1,5) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
