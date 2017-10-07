#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
        
#define DMG_BULLET (1<<1)
	
new const nazwa[]   = "Marszalek[Premium]";
new const opis[]    = "Awp 1/1 , niewidzialny na kucaniu 30 % , bardzo szybki all granaty";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_AWP)|(1<<CSW_FLASHBANG);
new const zdrowie   = 20;
new const kondycja  = 20;
new const inteligencja = 20;
new const wytrzymalosc = 20;
    
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
		client_print(id, print_chat, "[Marszalek[Premium]] Nie masz uprawnien, aby uzywac tej klasy.")
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
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 76);
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
	
	if (get_user_weapon(idattacker) == CSW_AWP && random_num(1,1) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
