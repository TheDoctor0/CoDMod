#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
        
new const nazwa[]   = "Slepy Ninja [Premium]";
new const opis[]    = "1/3 z no¿a ppm, 300 grawitacji, na no¿u widoczny w 10%, 1/2 z awp ";
new const bronie    = (1<<CSW_AWP);
new const zdrowie   = 30;
new const kondycja  = 55;
new const inteligencja = 15;
new const wytrzymalosc = 35;
    
new ma_klase[33];
new oneonone[33][31];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_event("CurWeapon", "eventKnife_Niewidzialnosc", "be", "1=1");
   
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

}

public cod_class_enabled(id)
{

 	entity_set_float(id, EV_FL_gravity, 300.0/800.0);
	ma_klase[id] = 1;
	oneonone[id][CSW_AWP] = 2
	oneonone[id][CSW_KNIFE] = 3
}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
    
 	entity_set_float(id, EV_FL_gravity, 1.0);
	ma_klase[id] = 0;

}

public eventKnife_Niewidzialnosc(id)
{
	if (!ma_klase[id])
		return;

	if ( read_data(2) == CSW_KNIFE )
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 25);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}

public fwSpawn_Grawitacja(id)
{
	if (ma_klase[id])
		entity_set_float(id, EV_FL_gravity, 300.0/800.0);
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if (!is_user_connected(idattacker))
                return HAM_IGNORED;
        
        if (!ma_klase[idattacker])
                return HAM_IGNORED;
        
        if (!(damagebits & (1<<1)))
                return HAM_IGNORED;
        
        new hp_ofiary = get_user_health(this)
        new bron_atakujacego = get_user_weapon(idattacker)
        
        if (oneonone[idattacker][bron_atakujacego] > 0)
        {
                if (random_num(1,oneonone[idattacker][bron_atakujacego]) == 1) cod_inflict_damage(idattacker, this, float(hp_ofiary), 0.0, idinflictor, damagebits);
        }
        
        return HAM_IGNORED;
}

