#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <fakemeta>

#define DMG_HEGRENADE (1<<24)
#define DMG_FALL (1<<5)

#define nazwa "MacGyver"
#define opis "Odpornosc na HE, miny, dynamity, rakiety i upadek, 1/7 na zatrzesienie ekranem i zmiane broni na noz ofierze"

new bool:ma_perk[33]

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);

	RegisterHam( Ham_TakeDamage, "player", "TakeDmg", 0);
}

public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
	ma_perk[id] = false;

public TakeDmg(this, idi, idattacker, Float:dmg, damagebits)
{
	if(!is_user_connected(this)) return HAM_IGNORED

	if(ma_perk[this])
	{
		if(damagebits & (DMG_HEGRENADE | DMG_FALL)) return HAM_SUPERCEDE

		new class[10];
		pev(idi, pev_classname, class, 9);

		if(equal(class, "rocket") || equal(class, "dynamite") || equal(class, "mine")) return HAM_SUPERCEDE;
      }
      
	if(!is_user_connected(idattacker)) return HAM_IGNORED

	if(ma_perk[idattacker] && !random(7))
		trzesienie(this)

	return HAM_IGNORED;
}

public trzesienie(id)
{
      client_cmd(id, "weapon_knife")

	message_begin(MSG_ONE,get_user_msgid("ScreenShake"),{0,0,0},id); 
	write_short(255<<14);
	write_short(10<<14);
	write_short(255<<14);
	message_end();
}