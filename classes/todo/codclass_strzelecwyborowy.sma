#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new const nazwa[]   = "Strzelec wyborowy";
new const opis[]    = "Dostaje AK i M4A1 + 200 dmg, 110hp bazowe, 80 % biegu, 100 pancerza";
new const bronie    = (1<<CSW_M4A1)|(1<<CSW_AK47);
new const zdrowie   = 10;
new const kondycja  = -20;
new const inteligencja = 0;
new const wytrzymalosc = 100;

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}
public cod_class_enabled(id)
{
	ma_klase[id] = true;
	return COD_CONTINUE;
}	
public cod_class_disabled(id)
	ma_klase[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if (!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if (!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if (get_user_weapon(idattacker) == CSW_M4A1 && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 200.0, 0.1, idinflictor, damagebits);
	
	if (get_user_weapon(idattacker) == CSW_AK47 && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 200.0, 0.1, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
