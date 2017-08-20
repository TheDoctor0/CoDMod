#include <amxmodx>
#include <codmod>
#include fakemeta
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new const nazwa[] = "Zlodziej [P]";
new const opis[] = "1/13 na zabranie perku, 1/1 noz PPM, 1/7 z FiveSeven";
new const bronie = (1<<CSW_FIVESEVEN)|(1<<CSW_GALIL);
new const zdrowie = 25;
new const kondycja = 5;
new const inteligencja = 10;
new const wytrzymalosc = 20;

new bool:ma_klase[33], ofiara[33], perk_ofiary[33], wartosc_perku_ofiary[33];

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Premium");

	register_event("DeathMsg", "DeathMsg", "ade");
      RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	if(!(cod_get_user_status(id) & STATUS_PREMIUM))
	{
		client_print(id, print_chat, "[%s] Nie masz premium, zeby grac ta klasa!", nazwa)
		return COD_STOP;
	}
	ma_klase[id] = true;

	return COD_CONTINUE;
}

public cod_class_disabled(id)
	ma_klase[id] = false;

public DeathMsg()
{
	new killer = read_data(1);
 
	if(!is_user_connected(killer)) return;
	if(!ma_klase[killer]) return;
	if(random(13)) return;
	
 	new victim = read_data(2);

	if(!(perk_ofiary[killer] = cod_get_user_perk(victim, wartosc_perku_ofiary[killer])))
            return;
	  
	ofiara[killer] = victim;
 
	Zapytaj(killer);
}

public Zapytaj(id)
{
	new tytul[55];
	new nazwa_perku[33];
	cod_get_perk_name(perk_ofiary[id], nazwa_perku, 32);
	format(tytul, 54, "Czy chcesz ukrasc perk: %s ?", nazwa_perku);
	new menu = menu_create(tytul, "Zapytaj_Handle");
 
	menu_additem(menu, "Tak");
	menu_setprop(menu, MPROP_EXITNAME, "Nie");
 
	menu_display(id, menu);
}

public Zapytaj_Handle(id, menu, item)
{
	if(item) return;
 
	if(cod_get_user_perk(ofiara[id]) != perk_ofiary[id]) return;
 
	new nick_zlodzieja[33];
	get_user_name(id, nick_zlodzieja, 32);
	client_print(ofiara[id], print_center, "%s ukradl twoj perk", nick_zlodzieja);
	cod_set_user_perk(ofiara[id], 0);
	cod_set_user_perk(id, perk_ofiary[id], wartosc_perku_ofiary[id]);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
		
      if(damagebits & DMG_BULLET)
      {
            switch(get_user_weapon(idattacker))
            {
                  case CSW_KNIFE:
                  {
                        if(get_pdata_float(get_pdata_cbase(idattacker, 373, 5), 47, 4) > 1.0)
                              KillPlayer(this, idinflictor, idattacker, (1<<1), CSW_KNIFE)
                  }
                  case CSW_FIVESEVEN:
                  {
                        if(!random(7))
                              KillPlayer(this, idinflictor, idattacker, (1<<1), CSW_FIVESEVEN)
                  }
            }
      }
      
	return HAM_IGNORED;
}

KillPlayer(id, inflictor, attacker, damagebits, weapon)
{
	static DeathMsgId
	
	new msgblock, effect
	if (!DeathMsgId)	DeathMsgId = get_user_msgid("DeathMsg")
	
	msgblock = get_msg_block(DeathMsgId)
	set_msg_block(DeathMsgId, BLOCK_ONCE)
	
	set_pdata_int(id, 75, HIT_CHEST , 5)
	set_pdata_int(id, 76, damagebits, 5)
	
	ExecuteHamB(Ham_Killed, id, attacker, 1)
	
	set_pev(id, pev_dmg_inflictor, inflictor)
	
	effect = pev(id, pev_effects)
	if(effect & 128)	set_pev(id, pev_effects, effect-128)
	
	set_msg_block(DeathMsgId, msgblock)
	
	new weaponname[32];
	get_weaponname(weapon,weaponname,31)

	message_begin(MSG_ALL, DeathMsgId)
	write_byte(attacker)
	write_byte(id)
	write_byte(0)
      write_string(weaponname[7])
	message_end()
}