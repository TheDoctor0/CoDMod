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
}

public display_menu(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
		
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menu = menu_create("\wMenu \rCoD Mod", "display_menu_handle");
 
	menu_additem(menu, "\wSklep \rSMS \y(/sklepsms)");
	menu_additem(menu, "\wWybierz \rKlase \y(/klasa)");
	menu_additem(menu, "\wOpisy \rKlas \y(/klasy)");
	menu_additem(menu, "\wOpis \rItemu \y(/item)");
	menu_additem(menu, "\wOpisy \rItemow \y(/itemy)");
	menu_additem(menu, "\wWyrzuc \rItem \y(/wyrzuc)");
	menu_additem(menu, "\wSklep \y(/sklep)");
	menu_additem(menu, "\wRynek \y(/rynek)");
	menu_additem(menu, "\wKlan \y(/klan)");
	menu_additem(menu, "\wQuesty \y(/questy)");
	menu_additem(menu, "\wHaslo \y(/haslo)");
	menu_additem(menu, "\wStaty \y(/staty)");
	menu_additem(menu, "\wWymien \rItem \y(/wymien)");
	menu_additem(menu, "\wOddaj \rItem \y(/daj)");
	menu_additem(menu, "\wZmien \rSerwer \y(/serwer)");
	menu_additem(menu, "\wInformacje o \rVIPie \y(/vip)");
	menu_additem(menu, "\wLista \rVIPow \y(/vipy)");
    
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

	if(item == 1) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
    
	switch(item)
	{ 
		case 1: client_cmd(id, "say /sklepsms"); 
		case 2: client_cmd(id, "klasa"); 
		case 3: client_cmd(id, "klasy"); 
		case 4: client_cmd(id, "item"); 
		case 5: client_cmd(id, "itemy"); 
		case 6: client_cmd(id, "wyrzuc"); 
		case 7: client_cmd(id, "sklep"); 
		case 8: client_cmd(id, "rynek");
		case 9: client_cmd(id, "klan");
		case 10: client_cmd(id, "questy");
		case 11: client_cmd(id, "haslo");
		case 12: client_cmd(id, "staty");
		case 13: client_cmd(id, "wymien");
		case 14: client_cmd(id, "daj");
		case 15: client_cmd(id, "serwer");
		case 16: client_cmd(id, "vip");
		case 17: client_cmd(id, "vipy");
	}
	
	menu_destroy(menu);

	return PLUGIN_CONTINUE;
}