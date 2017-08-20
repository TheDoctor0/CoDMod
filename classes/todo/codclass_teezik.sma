#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new const nazwa[]   = "TeeZik (Klasa Premium)";
new const opis[]    = "Posiada Krowe i zadaje z niej 150 dmg";
new const bronie    = (1<<CSW_M249)|(1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_FLASHBANG);
new const zdrowie   = 150;
new const kondycja  = 100;
new const inteligencja = 60;
new const wytrzymalosc = 120;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}
public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_A))
	{
		client_print(id, print_chat, "[TeeZik (Klasa Premium))] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	ma_klase[id]=true;
	return COD_CONTINUE;
}
public cod_class_disabled(id)
{
	ma_klase[id]=false;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if(!(damagebits & DMG_BULLET))
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_M249 && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 500.0, 1.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
