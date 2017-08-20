/* Plugin by Lui */

#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <colorchat>
#include <engine>

#define DMG_BULLET (1<<1) 


new bool:ma_klase[33];

new const nazwa[] = "Stopper";
new const opis[] = "Klasa posiada shotgu XM1014 (1/4), jest s³abo widoczna i ma bardzo ma³o HP";
new const bronie = 1<<CSW_XM1014;
new const zdrowie = -50;
new const kondycja = -10;
new const inteligencja = 0;
new const wytrzymalosc = 50;

public plugin_init()
{  
  cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
  
  RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	ColorChat(id, GREEN, "Klasa stworzona przez Sangre Asesino");
	ma_klase[id] = true;
	set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 50);
	return COD_CONTINUE;
}
	
public cod_class_disabled(id)
	{
	ma_klase[id] = false;
  set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255);
  }
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED; 
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if(damagebits & DMG_BULLET)
	{
		new weapon = get_user_weapon(idattacker);
			
		if(weapon == CSW_XM1014 && damage > 20.0 && random_num(1,4) == 1) 
			cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	}
	
	return HAM_IGNORED;
}
