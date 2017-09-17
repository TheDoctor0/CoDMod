#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fun>
        
#define DMG_BULLET (1<<1)
	
new const nazwa[]   = "SuperHero (Klasa Premium)";
new const opis[]    = "Dostaje 120hp, 700 grawitacji, wszystkie granaty, 1/5 z uzi";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_MAC10)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG);
new const zdrowie   = 20;
new const kondycja  = 60;
new const inteligencja = 100;
new const wytrzymalosc = 50;
    
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);   
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

}

public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[SuperHero (Klasa Premium)] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}

 	entity_set_float(id, EV_FL_gravity, 700.0/800.0);
	give_item(id, "weapon_hegrenade");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_flashbang");
	give_item(id, "weapon_smokegrenade");
	ma_klase[id] = true;
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{

 	entity_set_float(id, EV_FL_gravity, 1.0);
	ma_klase[id] = false;

}

public fwSpawn_Grawitacja(id)
{
	if(ma_klase[id])
		entity_set_float(id, EV_FL_gravity, 700.0/800.0);
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if(!is_user_connected(idattacker))
                return HAM_IGNORED;
        
        if(!ma_klase[idattacker])
                return HAM_IGNORED;
        
        if(!(damagebits & DMG_BULLET))
                return HAM_IGNORED;
                
        if(get_user_weapon(idattacker) == CSW_MAC10 && random_num(1,5) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/