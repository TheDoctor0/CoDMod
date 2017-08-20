#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
        
new const nazwa[]   = "Mroczny Rycerz(premium)";
new const opis[]    = "Jest w ogóle nie widzoczny (255/0), Ma 1 hp, i ma 1/1 z kosy.I jest bardzo szybki.Ma ma³¹ grawitacje";
new const bronie    = 0;
new const zdrowie   = -99;
new const kondycja  = 50;
new const inteligencja = 0;
new const wytrzymalosc = 0;
    
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);   
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

   
	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage_JedenCios");

}

public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[Mroczny Rycerz(premium)] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}

 	entity_set_float(id, EV_FL_gravity, 400.0/800.0);
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
		entity_set_float(id, EV_FL_gravity, 400.0/800.0);
}


public fwTakeDamage_JedenCios(id, ent, attacker)
{
	if(is_user_alive(attacker) && ma_klase[attacker] && get_user_weapon(attacker) == CSW_KNIFE)
	{
		cs_set_user_armor(id, 0, CS_ARMOR_NONE);
		SetHamParamFloat(4, float(get_user_health(id) + 1));
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
