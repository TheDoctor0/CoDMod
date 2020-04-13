#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Menu"
#define VERSION "1.1.2"
#define AUTHOR "O'Zone"

new const commandMenu[][] = { "say /help", "say_team /help", "say /pomoc", "say_team /pomoc", "say /commands",
	"say_team /commands", "say /komendy", "say_team /komendy", "say /menu", "say_team /menu", "menu" };

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

	if (!file_exists(menuFile)) {
		new failState[64];

		formatex(failState, charsmax(failState), "%L", LANG_SERVER, "MENU_FILE_ERROR");

		set_fail_state(failState);
	}

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

	new menuData[64];

	formatex(menuData, charsmax(menuData), "%L", id, "MENU_DISPLAY_TITLE");

	new menu = menu_create(menuData, "display_menu_handle");

	for (new i; i < ArraySize(menuData); i++) {
		ArrayGetString(menuTitles, i, menuData, charsmax(menuTitle));

		menu_additem(menu, menuData);
	}

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, factionName);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

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

	new menuCommand[64];

	ArrayGetString(menuCommands, item, menuCommand, charsmax(menuCommand));

	client_cmd(id, menuCommand);

	menu_destroy(menu);

	return PLUGIN_CONTINUE;
}