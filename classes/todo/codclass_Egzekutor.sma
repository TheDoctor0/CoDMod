#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include engine

new const nazwa[]   = "Egzekutor [P]";
new const opis[]    = "1/9 na wyrzucenie broni przeciwnika, pelen magazynek za fraga";
new const bronie    = (1<<CSW_P228)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_M4A1);
new const zdrowie   = 5;
new const kondycja  = 0;
new const inteligencja = 10;
new const wytrzymalosc = 5;
    
new bool:ma_klase[33];
new const maxClip[31] = { -1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 10,  30, 100,  8, 30,  30, 20,  2,  7, 30, 30, -1,  50 };

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Premium");

	register_event("Damage", "Damage_Wyrzucenie", "b", "2!0");
      register_event("DeathMsg", "SmiercGracza", "a", "1!0");
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

public Damage_Wyrzucenie(id)
{
	new idattacker = get_user_attacker(id);

	if(is_user_alive(idattacker) && ma_klase[idattacker] && !random(9))
	{
            new wpnname[33]
            get_weaponname(get_user_weapon(id), wpnname, charsmax(wpnname))
		engclient_cmd(id, "drop", wpnname);
      }
}

public SmiercGracza()
{
      new kid = read_data(1)
      
	if(!is_user_connected(kid))
		return PLUGIN_CONTINUE;
	
	if(ma_klase[kid])
	{	
		new weapon = get_user_weapon(kid);
		if(maxClip[weapon] != -1)
			set_user_clip(kid, weapon);
	}
	
	return PLUGIN_CONTINUE;
}

stock set_user_clip(id, wid)
{
	new weaponname[32];
	get_weaponname(wid, weaponname, 31);
	
	new ent = find_ent_by_owner(-1, weaponname, id)
	if(ent)
		set_pdata_int(ent, 51, maxClip[wid], 4);
}