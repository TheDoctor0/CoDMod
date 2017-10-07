#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>

new const nazwa[]   = "Komandos[Super premium]";
new const opis[]    = "1/1 z no¿a,1/1 z AWP ,1/1 z he oraz 1/40 z deagla";
new const bronie    = 0;
new const zdrowie   = 0;
new const kondycja  = 0;
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
	if (!(get_user_flags(id) & ADMIN_LEVEL_D))
	{
		client_print(id, print_chat, "[Komandos[Super premium]] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	oneonone[id][CSW_KNIFE] = 1
	oneonone[id][CSW_AWP] = 1
	oneonone[id][CSW_HEGRENADE] = 1
	oneonone[id][CSW_DEAGLE] = 40
	ma_klase[id] = 1;
	
	return COD_CONTINUE;
}
public cod_class_disabled(id)
{
	ma_klase[id] = 0;
	oneonone[id][CSW_KNIFE] = 0
	oneonone[id][CSW_AWP] = 0
	oneonone[id][CSW_HEGRENADE] = 0
	oneonone[id][CSW_DEAGLE] = 0
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
