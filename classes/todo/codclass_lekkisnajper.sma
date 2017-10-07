

#include <amxmodx>
#include <ColorChat>
#include <codmod>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <fakemeta>

#define DMG_BULLET (1<<1) 


new bool:ma_klase[33];

new const nazwa[] = "Lekki Snajper";
new const opis[] = "Klasa posiada 1/2 szansy na zabicie ze scouta, nie slychac jak biega";
new const bronie = 1<<CSW_SCOUT | 1<<CSW_ELITE | 1<<CSW_FLASHBANG;
new const zdrowie = 25;
new const kondycja = 25;
new const inteligencja = 0;
new const wytrzymalosc = 10;

public plugin_init()
{  
  cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
  
  RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
  set_user_footsteps(id, 1);
	ColorChat(id, GREEN, "Klasa stworzona przez Sangre Asesino");
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
			
		if (weapon == CSW_SCOUT && damage > 20.0 && random_num(1,2) == 1) 
			cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	}
	
	return HAM_IGNORED;
}
