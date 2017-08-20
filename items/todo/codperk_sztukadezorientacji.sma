#include <amxmodx>
#include <codmod>
#include <fakemeta>

#define perk_name "Sztuka dezorientacji"
#define perk_desc "Masz 1/LW szansy na ukrycie celownika wroga po strzale"

new bool:ma_perk[33],
wartosc_perku[33],
g_msg_hideweapon;

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc, 3, 6);
	
	register_event("Damage", "Damage", "b", "2!0");
	
	g_msg_hideweapon = get_user_msgid("HideWeapon");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public Damage(id)
{
	new attacker = get_user_attacker(id);
	
	if(!is_user_connected(attacker))
		return PLUGIN_CONTINUE;
	
	if(!ma_perk[attacker])
		return PLUGIN_CONTINUE;
		
	if(random(wartosc_perku[attacker]))
		return PLUGIN_CONTINUE;
	
      ChangeHUD(id, (1<<2));
	set_task(10.0, "Wylacz", id);

	return PLUGIN_CONTINUE;
}

public Wylacz(id)
	ChangeHUD(id, 0);

public ChangeHUD(id, num) 
{		
	message_begin(MSG_ONE_UNRELIABLE, g_msg_hideweapon, _, id);
	write_byte(num);
	message_end();
}
