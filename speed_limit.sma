#include <amxmodx>
#include <colorchat>

new const PLUGIN[] = "Ogranicznik Speed"
new const VERSION[] = "v1.1"
new const AUTHOR[] = "Skull [t]"

#define TASK_SPEED 666		/* Definicja od taska, aby pobiera³o danego Usera, a nie wszystkich */
#define TASK_OPIS 768		/* Definicja od taska który wyœwietla komunikat na serwerze */

new cvar_typ,
	cvar_maxspeed,
	cvar_forwardspeed,
	cvar_backspeed,
	cvar_sidespeed;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cvar_typ		= register_cvar("amx_typ_ograniczenia", "1", FCVAR_SPONLY | FCVAR_PRINTABLEONLY);	/* 0 - Wy³. 1 - W³. + Optymalny typ dzialania bez spamu. 2 - W³. Jest to pewniejsze dzialanie, lecz z spamem w konsili" */
	cvar_maxspeed		= register_cvar("amx_max_speed", "501", FCVAR_SPONLY | FCVAR_PRINTABLEONLY);		/* Ustawiasz limit komendy serwera "sv_maxspeed" */
	cvar_forwardspeed	= register_cvar("amx_forward_speed", "401", FCVAR_SPONLY | FCVAR_PRINTABLEONLY);		/* Ustawiasz limit komendy Gracza "cl_forwardspeed" */
	cvar_backspeed		= register_cvar("amx_back_speed", "451", FCVAR_SPONLY | FCVAR_PRINTABLEONLY);		/* Ustawiasz limit komendy Gracza "cl_backspeed" */
	cvar_sidespeed		= register_cvar("amx_side_speed", "451", FCVAR_SPONLY | FCVAR_PRINTABLEONLY);		/* Ustawiasz limit komendy Gracza "cl_sidespeed" */
	
	set_task(5.0, "Task_cfg");			/* £aduje plik z Cvarami */
	set_task(6.0, "Ustaw_Speed");	/* Ustawia odpowiedni¹ wartoœæ sv_maxspeed pod CODy */
	
	register_event("ResetHUD", "ResetHUD", "abe");	/* Rozpoczyna uruchomienie taska */
}

public client_putinserver(id)
{
	set_task(10.0, "Pokaz_Opis", id+TASK_OPIS);
}

public Task_cfg()
{			/* £aduje plik z Cvarami */
	server_cmd("exec addons/amxmodx/configs/OgraniczenieSpeed.cfg");
}

public client_disconnect(id)
{			/* Jeœli gracz wyjdzie to przerwie Taski */
	remove_task(id + TASK_SPEED);
	remove_task(id + TASK_OPIS);
}

public Ustaw_Speed()
{
	server_cmd("sv_maxspeed %i", get_pcvar_num(cvar_maxspeed));		/* Ustawia odpowiedni¹ wartoœæ sv_maxspeed pod CODy */
	server_cmd("exec addons/amxmodx/configs/OgraniczenieSpeed.cfg");	/* Dla pewnosci oraz wzmocnienie (nie zaszkodzi ta funcja) £aduje plik z Cvarami ponownie */
}

public Wymus_Ustawienia(id)
{
	id -= TASK_SPEED;	/* Zmienna ID Userów */
	
	if(!is_user_connected(id))		/* Jeœli jakimœ cudem gracz zniknie z serwera, to przerywa wymuszanie */
	{
		remove_task(id + TASK_SPEED);
		return;
	}
	if(!is_user_alive(id))			/* Jeœli gracz nie ¿yje to przerywa wymuszanie */
	{
		remove_task(id + TASK_SPEED);
		return;
	}
	
			/* Jeœli gracz ¿yje to wymusza ograniczenia speed */
	switch(get_pcvar_num(cvar_typ))
	{
		case 0: remove_task(id + TASK_SPEED);
		case 1:
		{
			new_client_cmd(id, "cl_forwardspeed %i", get_pcvar_num(cvar_forwardspeed));
			new_client_cmd(id, "cl_backspeed %i", get_pcvar_num(cvar_backspeed));
			new_client_cmd(id, "cl_sidespeed %i", get_pcvar_num(cvar_sidespeed));
			new_client_cmd(id, "^"cl_forwardspeed^" %i", get_pcvar_num(cvar_forwardspeed));
			new_client_cmd(id, "^"cl_backspeed^" %i", get_pcvar_num(cvar_backspeed));
			new_client_cmd(id, "^"cl_sidespeed^" %i", get_pcvar_num(cvar_sidespeed));
		}
		case 2:
		{
			new_client_cmd(id, "cl_forwardspeed %i", get_pcvar_num(cvar_forwardspeed));
			new_client_cmd(id, "cl_backspeed %i", get_pcvar_num(cvar_backspeed));
			new_client_cmd(id, "cl_sidespeed %i", get_pcvar_num(cvar_sidespeed));
			new_client_cmd(id, "^"cl_forwardspeed^" %i", get_pcvar_num(cvar_forwardspeed));
			new_client_cmd(id, "^"cl_backspeed^" %i", get_pcvar_num(cvar_backspeed));
			new_client_cmd(id, "^"cl_sidespeed^" %i", get_pcvar_num(cvar_sidespeed));
			new_client_cmd(id, "echo ^"^";^"cl_forwardspeed^" %i", get_pcvar_num(cvar_forwardspeed));
			new_client_cmd(id, "echo ^"^";^"cl_backspeed^" %i", get_pcvar_num(cvar_backspeed));
			new_client_cmd(id, "echo ^"^";^"cl_sidespeed^" %i", get_pcvar_num(cvar_sidespeed));
		}
	}
}

public ResetHUD(id)
{				/* Uruchamia Funkcje ograniczeñ Speed */
	if(!task_exists(id+TASK_SPEED))
		set_task(0.1, "Wymus_Ustawienia", id + TASK_SPEED, _, _, "b");
}

public Pokaz_Opis(id)
{
	id -= TASK_OPIS;	/* Zmienna ID Userów */
	
	ColorChat(id, GREEN,"[%s]^x01 Modyfikacja stworzona pod wszelkiego rodzaju COD'ow", PLUGIN);	/* Jeœli mo¿na to nie usuwaj tego info, gdy¿ pomog³em wam z walk¹ na ograniczenie komend */
	ColorChat(id, GREEN,"[%s]^x01 W celu ograniczenia nie dozwolonych komend speed", PLUGIN);	/* Jeœli mo¿na to nie usuwaj tego info, gdy¿ pomog³em wam z walk¹ na ograniczenie komend */
	ColorChat(id, GREEN,"[%s]^x01 Znalazles bug? Pisz na AMXX.PL", PLUGIN);		/* Jeœli mo¿na to nie usuwaj tego info, gdy¿ pomog³em wam z walk¹ na ograniczenie komend */
	ColorChat(id, GREEN,"[%s]^x01 Wersja Pluginu:^x04 %s", PLUGIN, VERSION);		/* Jeœli mo¿na to nie usuwaj tego info, gdy¿ pomog³em wam z walk¹ na ograniczenie komend */
	ColorChat(id, GREEN,"[%s]^x01 Autor Plugini: by-^x04%s", PLUGIN, AUTHOR);	/* Jeœli mo¿na to nie usuwaj tego info, gdy¿ pomog³em wam z walk¹ na ograniczenie komend */
}

stock new_client_cmd(id, const szText[], any:...)	/* Nowa, lepsza Funkcja Client CMD (Wykonana by-DarkGL) */
{					// Link: http://darkgl.pl/2014/07/23/wykonywanie-komend-na-graczu-z-pominieciem-protektorow-i-blokad/
	#pragma unused szText
	
	new szMessage[256];
	format_args(szMessage, charsmax(szMessage), 1);
	
	message_begin(id == 0 ? MSG_ALL : MSG_ONE, 51, _, id)
	write_byte(strlen(szMessage) +2)
	write_byte(10)
	write_string(szMessage)
	message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
