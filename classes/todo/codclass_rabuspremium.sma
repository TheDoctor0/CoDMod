#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define DMG_BULLET (1<<1)
        
new const nazwa[]   = "Rabus (Premium)";
new const opis[]    = "AWP, Mac 10 i mniejsza widocznosc przy kucaniu";
new const bronie    = (1<<CSW_MAC10)|(1<<CSW_AWP);
new const zdrowie   = 15;
new const kondycja  = 15;
new const inteligencja = 15;
new const wytrzymalosc = 15;
    
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_forward(FM_PlayerPreThink, "fwPrethink_Niewidzialnosc", 1);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[Rabus (Premium)] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	ma_klase[id] = true;
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
    	ma_klase[id] = false;

}


//Przy kucaniu
public fwPrethink_Niewidzialnosc(id)
{
	if (!ma_klase[id])
		return;

	new button = get_user_button(id);
	if ( button & IN_DUCK )
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 25);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if (!is_user_connected(idattacker))
                return HAM_IGNORED;
        
        if (!ma_klase[idattacker])
                return HAM_IGNORED;
        
        if (!(damagebits & DMG_BULLET))
                return HAM_IGNORED;
                
        if (get_user_weapon(idattacker) == CSW_AWP && random_num(1,2) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}
