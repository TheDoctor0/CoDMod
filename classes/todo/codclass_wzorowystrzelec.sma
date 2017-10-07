#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new const nazwa[]   = "Wzorowy Strzelec";
new const opis[]    = "1/12 z M4A1 ma HE 1/6 deagle";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_M4A1)|(1<<CSW_DEAGLE);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	give_item(id, "weapon_hegrenade");
	
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if (!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if (!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if (!(damagebits & DMG_BULLET))
		return HAM_IGNORED;
	
	if (get_user_weapon(idattacker) == CSW_M4A1 && random_num(1,12) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	if (get_user_weapon(idattacker) == CSW_DEAGLE && random_num(1,6) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
