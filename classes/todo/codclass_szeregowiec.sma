#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
        
new const nazwa[]   = "Szeregowiec";
new const opis[]    = "ma m4 i AWP. jest szybki  i wytrzyma³y, ma zmniejszon¹ grawitacje.";
new const bronie    = (1<<CSW_AWP)|(1<<CSW_M4A1);
new const zdrowie   = 30;
new const kondycja  = 20;
new const inteligencja = 20;
new const wytrzymalosc = 25;
    
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);   
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

}

public cod_class_enabled(id)
{

 	entity_set_float(id, EV_FL_gravity, 400.0/800.0);
	ma_klase[id] = true;

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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
