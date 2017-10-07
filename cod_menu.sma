#include <amxmodx>
#include <cod>
 
#define PLUGIN "CoD Menu"
#define VERSION "1.0.11"
#define AUTHOR "O'Zone" 

new const commandMenu[][] = { "say /help", "say_team /help", "say /pomoc", "say_team /pomoc", "say /komendy", "say_team /komendy", "say /menu", "say_team /menu", "menu" };

new Array:menuTitles, Array:menuCommands;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for (new i; i < sizeof commandMenu; i++) register_clcmd(commandMenu[i], "display_menu");
}

public plugin_cfg()
{	
	menuTitles = ArrayCreate(64, 1);
	menuCommands = ArrayCreate(64, 1);
	
	new menuFile[128]; 
	
	get_localinfo("amxx_configsdir", menuFile, charsmax(menuFile));
	format(menuFile, charsmax(menuFile), "%s/cod_menu.ini", menuFile);
	
	if (!file_exists(menuFile)) set_fail_state("[CoD] Brak pliku cod_menu.ini z zawartoscia glownego menu!");
	
	new lineContent[128], menuTitle[64], menuCommand[64], file = fopen(menuFile, "r");
	
	while (!feof(file)) {
		fgets(file, lineContent, charsmax(lineContent)); trim(lineContent);
		
		if (lineContent[0] == ';' || lineContent[0] == '^0') continue;

		parse(lineContent, menuTitle, charsmax(menuTitle), menuCommand, charsmax(menuCommand));
		
		ArrayPushString(menuTitles, menuTitle);
		ArrayPushString(menuCommands, menuCommand);
	}
	
	fclose(file);
}

public client_putinserver(id)
{
	cod_cmd_execute(id, "bind v menu");
	cod_cmd_execute(id, "bind ^"v^" ^"menu^"");
	cod_cmd_execute(id, "echo ^"^";^"bind ^"v^" ^"menu^"");
}

public display_menu(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;
		
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menuTitle[64], menu = menu_create("\yMenu \rCoD Mod\w", "display_menu_handle");
	
	for (new i; i < ArraySize(menuTitles); i++) {
		ArrayGetString(menuTitles, i, menuTitle, charsmax(menuTitle));

		menu_additem(menu, menuTitle);
	}
    
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}  
 
public display_menu_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	if (!item) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuCommand[64];
    
	ArrayGetString(menuCommands, item, menuCommand, charsmax(menuCommand));
	
	cod_cmd_execute(id, menuCommand);
	
	menu_destroy(menu);

	return PLUGIN_CONTINUE;
}