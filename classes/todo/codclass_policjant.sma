#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <hamsandwich> 

new const nazwa[]   = "Policjant";
new const opis[]    = "Ma 1/9 z usp i glocka +15 dmg z deagla.";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE);
new const zdrowie   = 20;
new const kondycja  = 30;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new ma_klase[33] 
new oneonone[33][31]

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id) 
{ 
	oneonone[id][CSW_USP] = 9 
	oneonone[id][CSW_GLOCK18] = 9 
	give_item(id, "weapon_hegrenade");
	ma_klase[id] = 1; 
	
	return COD_CONTINUE; 
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits) 
{ 
	if(!is_user_connected(idattacker)) 
		return HAM_IGNORED; 
	
	if(!ma_klase[idattacker]) 
		return HAM_IGNORED; 
	
	if(!(damagebits & (1<<1))) 
		return HAM_IGNORED; 
	
	new hp_ofiary = get_user_health(this) 
	new bron_atakujacego = get_user_weapon(idattacker) 
	
	if (oneonone[idattacker][bron_atakujacego] > 0) 
	{ 
		if (random_num(1,oneonone[idattacker][bron_atakujacego]) == 1) cod_inflict_damage(idattacker, this, float(hp_ofiary), 0.0, idinflictor, damagebits); 
	}
	if(get_user_weapon(idattacker) == CSW_DEAGLE)
	{
		damage*=15.0;
	}
	
	return HAM_IGNORED; 
}
public cod_class_disabled(id)
{
	oneonone[id][CSW_USP] = 0
	oneonone[id][CSW_GLOCK18] = 0
	ma_klase[id] = 0
}