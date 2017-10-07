#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <fakemeta>

#define DMG_BULLET (1<<1)
        
new const nazwa[]   = "Drabik";
new const opis[]    = "MP5 10dmg + int,modul odrzutowy";
new const bronie    = (1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE);
new const zdrowie   = 30;
new const kondycja  = 30;
new const inteligencja = 30;
new const wytrzymalosc = 30;

new ma_klase[33];
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}

public cod_class_enabled(id)
{
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
                
        if (get_user_weapon(idattacker) == CSW_MP5NAVY && damagebits & DMG_BULLET)               //Bron
                cod_inflict_damage(idattacker, this, 10.0, 0.4, idinflictor, damagebits);
                
        return HAM_IGNORED;
}
public cod_class_skill_used(id)
{
	static Float:ostatni_skok[33];
	new flags = pev(id, pev_flags);
	
	if (flags & FL_ONGROUND && get_gametime() > ostatni_skok[id]+4.0)
	{
		ostatni_skok[id] = get_gametime();
		new Float:velocity[3];
		velocity_by_aim(id, 666+cod_get_user_intelligence(id), velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity, velocity);
	}
}

