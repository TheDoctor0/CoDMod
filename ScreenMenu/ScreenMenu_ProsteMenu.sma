#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <ScreenMenu>

#define PLUGIN "ScreenMenu - ProsteMenu"
#define VERSION "1.0"
#define AUTHOR "R3X"

new menu;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	menu = smenu_create("Proste menu kolowe", "mcbScreenMenu");
	smenu_additem(menu, "Czesc");
	smenu_additem(menu, "Siema");
	smenu_additem(menu, "Yo");
	smenu_additem(menu, "Elosza");
	smenu_additem(menu, "Witaj");
	
	register_clcmd("+wybierz", "cmdStartWybierz");
	register_clcmd("-wybierz", "cmdStopWybierz");
}

public mcbScreenMenu(id, menu, item){
	if(item > 0)
		client_print(id, print_chat, "Wybrales opcje %d", item);
}

public cmdStartWybierz(id){
	smenu_display(id, menu);
	return PLUGIN_HANDLED;
}
public cmdStopWybierz(id){
	smenu_exit(id);
	return PLUGIN_HANDLED;
}





