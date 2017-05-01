#include <amxmodx>
#include <cod>
 
#define PLUGIN "CoD Menu"
#define VERSION "1.0"
#define AUTHOR "O'Zone" 

new const commandMenu[][] = { "say /help", "say_team /help", "say /pomoc", "say_team /pomoc", "say /menu", "say_team /menu", "menu" };

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof commandMenu; i++) register_clcmd(commandMenu[i], "display_menu");
}

public client_putinserver(id)
{
	cmd_execute(id, "bind v menu");
	cmd_execute(id, "bind ^"v^" ^"menu^"");
	cmd_execute(id, "echo ^"^";^"bind ^"v^" ^"menu^"");
}

public display_menu(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
		
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menu = menu_create("\yMenu \rCoD Mod\w", "display_menu_handle");
 
	menu_additem(menu, "\wSklep \rSMS \y(/sklepsms)");
	menu_additem(menu, "\wInformacje o \rVIPie \y(/vip)");
	menu_additem(menu, "\wZmien \rSerwer \y(/serwer)");
	menu_additem(menu, "\wWybierz \rKlase \y(/klasa)");
	menu_additem(menu, "\wOpisy \rKlas \y(/klasy)");
	menu_additem(menu, "\wOpis \rPrzedmiotu \y(/item)");
	menu_additem(menu, "\wOpisy \rPrzedmiotow \y(/itemy)");
	menu_additem(menu, "\wMenu \rSklep \y(/sklep)");
	menu_additem(menu, "\wMenu \rRynek \y(/rynek)");
	menu_additem(menu, "\wMenu \rKlan \y(/klan)");
	menu_additem(menu, "\wMenu \rMisje \y(/misje)");
	menu_additem(menu, "\wMenu \rKasyno \y(/kasyno)");
	menu_additem(menu, "\wUstawienia \rIkon \y(/ikony)");
	menu_additem(menu, "\wUstawienia \rHUD \y(/hud)");
	menu_additem(menu, "\wNajlepsze \rStaty \y(/staty)");
	menu_additem(menu, "\wTwoje \rKonto \y(/konto)");
	menu_additem(menu, "\wWymien \rItem \y(/wymien)");
	menu_additem(menu, "\wOddaj \rItem \y(/daj)");
	menu_additem(menu, "\wWyrzuc \rItem \y(/wyrzuc)");
	menu_additem(menu, "\wPunkty \rStatystyk \y(/punkty)");
	menu_additem(menu, "\wReset \rPunktow \y(/reset)");
    
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}  
 
public display_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	if(!item) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
    
	switch(item)
	{ 
		case 0: cmd_execute(id, "say /sklepsms");
		case 1: cmd_execute(id, "vip");
		case 2: cmd_execute(id, "serwer");
		case 3: cmd_execute(id, "klasa"); 
		case 4: cmd_execute(id, "klasy"); 
		case 5: cmd_execute(id, "item"); 
		case 6: cmd_execute(id, "itemy");  
		case 7: cmd_execute(id, "sklep"); 
		case 8: cmd_execute(id, "rynek");
		case 9: cmd_execute(id, "klan");
		case 10: cmd_execute(id, "misje");
		case 11: cmd_execute(id, "kasyno");
		case 12: cmd_execute(id, "ikony");
		case 13: cmd_execute(id, "hud");
		case 14: cmd_execute(id, "staty");
		case 15: cmd_execute(id, "konto");
		case 16: cmd_execute(id, "wymien");
		case 17: cmd_execute(id, "daj");
		case 18: cmd_execute(id, "wyrzuc");
		case 19: cmd_execute(id, "punkty");
		case 20: cmd_execute(id, "reset");
	}
	
	menu_destroy(menu);

	return PLUGIN_CONTINUE;
}