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
	client_cmd(id,"bind ^"v^" ^"menu^"");
	cmd_execute(id, "bind v menu");
}

public display_menu(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
		
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menu = menu_create("\wMenu \rCoD Mod", "display_menu_handle");
 
	menu_additem(menu, "\wSklep \rSMS \y(/sklepsms)", "1");
	menu_additem(menu, "\wWybierz \rKlase \y(/klasa)", "2");
	menu_additem(menu, "\wOpisy \rKlas \y(/klasy)", "3");
	menu_additem(menu, "\wOpis \rItemu \y(/item)", "4");
	menu_additem(menu, "\wOpisy \rItemow \y(/itemy)", "5");
	menu_additem(menu, "\wWyrzuc \rItem \y(/wyrzuc)", "6");
	menu_additem(menu, "\wSklep \y(/sklep)", "7");
	menu_additem(menu, "\wRynek \y(/rynek)", "8");
	menu_additem(menu, "\wKlan \y(/klan)", "9");
	menu_additem(menu, "\wQuesty \y(/questy)", "10");
	menu_additem(menu, "\wHaslo \y(/haslo)", "11");
	menu_additem(menu, "\wStaty \y(/staty)", "12");
	menu_additem(menu, "\wWymien \rItem \y(/wymien)", "13");
	menu_additem(menu, "\wOddaj \rItem \y(/daj)", "14");
	menu_additem(menu, "\wZmien \rSerwer \y(/serwer)", "15");
	menu_additem(menu, "\wInformacje o \rVIPie \y(/vip)", "16");
	menu_additem(menu, "\wLista \rVIPow \y(/vipy)", "17");
    
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}  
 
public display_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
		
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}
	
	new itemData[4], itemAccess, itemCallback;
	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, itemCallback);
    
	new item = str_to_num(itemData);
    
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