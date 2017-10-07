#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <fakemeta_util>
        
new const nazwa[]   = "Zawodowiec";
new const opis[]    = "4int(+1% do szybkosci strzelania)";
new const bronie    = (1<<CSW_M4A1);
new const zdrowie   = 20;
new const kondycja  = 5;
new const inteligencja = 0
new const wytrzymalosc = 0;
    
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "Eustachy8");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
   
	register_event("CurWeapon","eventCurWeapon", "b");

}

public cod_class_enabled(id)
{
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
	ma_klase[id] = false;

}
public eventCurWeapon(id)
{
        if (!ma_klase[id])
                return PLUGIN_HANDLED;
        
        new iWeapon = get_user_weapon(id);
        new iEnt;
	
        
        static Float:fSpeedMultiplier;
		if (1.0-(cod_get_user_intelligence(id)/400.0) <= 0)
			fSpeedMultiplier = 0.01 
		else
 			  
			fSpeedMultiplier = 1.0-(cod_get_user_intelligence(id)/400.0);
             	  		    
		if (iWeapon == CSW_M4A1)
        {
                iEnt = fm_find_ent_by_owner(-1, "weapon_m4a1", id)
                set_pdata_float( iEnt, 46, ( get_pdata_float(iEnt, 46, 4) * fSpeedMultiplier), 4 );
                set_pdata_float( iEnt, 47, ( get_pdata_float(iEnt, 47, 4) * fSpeedMultiplier), 4 );
        }
        return PLUGIN_HANDLED;
}