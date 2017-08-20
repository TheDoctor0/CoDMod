#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <fakemeta>

#define DMG_BULLET (1<<1)
new ma_klase[33];        
new const nazwa[]   = "Aimer(VIP)";
new const opis[]    = "1/3 na natychmiastowe zabicie z HeadShota";
new const bronie    = (1<<CSW_M4A1);
new const zdrowie   = 5;
new const kondycja  = 10;
new const inteligencja = 0;
new const wytrzymalosc = 20;
    
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
        if(!is_user_connected(idattacker))
                return HAM_IGNORED;

        if(!ma_klase[idattacker])
                return HAM_IGNORED;

        if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_M4A1 && get_pdata_int(this, 75, 5) == HIT_HEAD && random_num(1, 2) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor);
                
        return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
