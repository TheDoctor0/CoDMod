#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new const nazwa[]   = "Zawodowy Strzelec(Premium)";
new const opis[]    = "Ma dodatkowe 500 Obra¿eñ z M4A1 i AK47 oraz 1/1 Z awp i 1/2 z deagle ";
new const bronie    = (1<<CSW_AWP)|(1<<CSW_M4A1)|(1<<CSW_DEAGLE)|(1<<CSW_AK47);
new const zdrowie   = 1000;
new const kondycja  = 500;
new const inteligencja = 500;
new const wytrzymalosc = 200;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}
public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[Zawodowy Strzelec(Premium)] Nie masz uprawnien, aby uzywac tej klasy.")
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
	if (!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if (!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if (!(damagebits & DMG_BULLET))
		return HAM_IGNORED;
	
	if (get_user_weapon(idattacker) == CSW_AWP && random_num(1,1) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	if (get_user_weapon(idattacker) == CSW_DEAGLE && random_num(1,2) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	if (get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_M4A1 && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 500.0, 1.0, idinflictor, damagebits);
	
	if (get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_AK47 && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 50.0, 1.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
