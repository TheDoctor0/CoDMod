#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>

#define DMG_BULLET (1<<1)
        
new const nazwa[]   = "Mini Mentos";
new const opis[]    = "1/7 na zabicie z XM1014";
new const bronie    = (1<<CSW_XM1014);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if (!is_user_connected(idattacker))
                return HAM_IGNORED;
        
        if (!ma_klase[idattacker])
                return HAM_IGNORED;
        
        if (!(damagebits & DMG_BULLET))
                return HAM_IGNORED;
                
        if (get_user_weapon(idattacker) == CSW_XM1014 && random_num(1,7) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
