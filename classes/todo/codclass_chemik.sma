/* Klasa stworzona przy pomocy AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>

#define MAX 32

new const nazwa[]   = "Chemik [Premium]";
new const opis[]    = "Raz na mapke moze wezwac bron chemiczna ktora zabija wszystkich";
new const bronie    = 1<<CSW_AK47 | 1<<CSW_DEAGLE;
new const zdrowie   = 20;
new const kondycja  = 10;
new const inteligencja = 0;
new const wytrzymalosc = 10;

new ma_klase[33];

new bool:nuke[MAX+1];

new bool:nuke_player[MAX+1];

new ilosc[33];

new licznik_zabic[MAX+1];

new ZmienKilla[2];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "BloodMan");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
}

public plugin_precache()
{
	precache_sound("mw/nuke_friend.wav"); // to oznacza ¿e przyjaciel u¿y³ broni
	precache_sound("mw/nuke_enemy.wav"); // to oznacza ¿e wróg u¿y³ broni
}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[Klasa: Chemik [Premium] Nie masz uprawnien, aby uzywac tej klasy. Jesli chcesz je miec to kup klase")
		return COD_STOP;
	}
	ilosc[id] = 1;
	ma_klase[id] = true;
	
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ilosc[id] = 0;
	ma_klase[id] = false;
}

public cod_class_skill_used(id)
{
	if (!ilosc[id])
	{
		client_print(id, print_center, "Broni chemicznej mozesz uzyc raz na mapke!");
		return PLUGIN_CONTINUE;
	}
	else
	{
		if (is_user_alive(id))
		{
			
			ilosc[id]--;
			
			UzyjChemi(id);
		}
	}
	return PLUGIN_CONTINUE;
}

//bron chemiczna
public UzyjChemi(id)
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if (is_user_alive(i))
			Display_Fade(i,(10<<12),(10<<12),(1<<16),255, 42, 42,171);
		
		if (get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/nuke_enemy.wav");
		else
			client_cmd(i, "spk sound/mw/nuke_friend.wav");
	}
	print_info(id, "Nuke", "e");
	set_task(10.0,"shakehud");
	set_task(13.5,"del_nuke", id);
	nuke[id] = false;
}

public shakehud()
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if (is_user_alive(i))
		{
			Display_Fade(i,(3<<12),(3<<12),(1<<16),255, 85, 42,215);
			message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, i);
			write_short(255<<12);
			write_short(4<<12);
			write_short(255<<12);
			message_end();
		}
	}
}

public del_nuke(id)
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if (is_user_alive(i))
		{
			if (get_user_team(id) != get_user_team(i))
			{
				cs_set_user_armor(i, 0, CS_ARMOR_NONE);
				UTIL_Kill(id, i, float(get_user_health(i)), DMG_BULLET)
			}
			else
				user_silentkill(i);
		}
	}
	nuke_player[id] = false;
	licznik_zabic[id] = 0;
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"),{0,0,0},id);
	write_short(duration);
	write_short(holdtime);
	write_short(fadetype);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	message_end();
}

stock UTIL_Kill(atakujacy, obrywajacy, Float:damage, damagebits, ile=0)
{
	ZmienKilla[ile] |= (1<<atakujacy);
	ExecuteHam(Ham_TakeDamage, obrywajacy, atakujacy, atakujacy, damage, damagebits);
	ZmienKilla[ile] &= ~(1<<atakujacy);
}

stock print_info(id, const nagroda[], const nazwa[] = "y")
{
	new nick[64];
	get_user_name(id, nick, 63);
	client_print(0, print_chat, "%s wezwan%s przez %s", nagroda, nazwa, nick);
}

public client_putinserver(id)
{
	licznik_zabic[id] = 0;
	nuke[id] = false;
}

public message_DeathMsg()
{
	new killer = get_msg_arg_int(1);
	if (ZmienKilla[0] & (1<<killer))
	{
		set_msg_arg_string(4, "grenade");
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

public Spawn(id)
{
	if (!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	if (ma_klase[id])
		ilosc[id] = 1;
	
	return PLUGIN_CONTINUE;
}
