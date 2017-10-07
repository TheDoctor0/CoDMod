#include <amxmodx>
#include <ColorChat>
#include <codmod>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>

#define DMG_BULLET (1<<1) 


new bool:ma_klase[33];

new const nazwa[] = "Granadier";
new const opis[] = "Co sekunde dostaje granat wybuchowy i ma 1/4 szans na natych. zabicie z niego";
new const bronie = 1<<CSW_DEAGLE | 1<<CSW_HEGRENADE;
new const zdrowie = 10;
new const kondycja = 10;
new const inteligencja = 0;
new const wytrzymalosc = 0;

public plugin_init()
{  
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	set_user_footsteps(id, 1);
	set_task(1.0,"DodajGranat",id+9812)
	ColorChat(id, GREEN, "^x01[^x04 %s^x01 ] Ta klasa zostala stworzona przez:^x03 RPK. Macior", nazwa);
	ma_klase[id] = true;
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	set_user_footsteps(id, 0);
	ma_klase[id] = false;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if (!is_user_connected(idattacker))
		return HAM_IGNORED; 
	
	if (!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if (damagebits & DMG_BULLET)
	{
		new weapon = get_user_weapon(idattacker);
		
		if (weapon == CSW_HEGRENADE && damage > 20.0 && random_num(1,4) == 1) 
			cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	}
	
	return HAM_IGNORED;
}

public DodajGranat(id)
{
	id-=9812;
	
	if (!is_user_alive(id))
	{
		remove_task(id+9812)
		return PLUGIN_CONTINUE;
	}
	give_item(id,"weapon_hegrenade")
	set_task(1.0,"DodajGranat",id+9812)
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
