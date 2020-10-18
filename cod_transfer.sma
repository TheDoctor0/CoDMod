#include <amxmodx>
#include <cstrike>
#include <cod>

#define PLUGIN "CoD Transfer"
#define AUTHOR "O'Zone"

new const commandTransfer[][] = { "przelej", "say /przelew", "say_team /przelew", "say /przelej", "say_team /przelej" };

new transferPlayer[MAX_PLAYERS + 1], bool:mapEnd;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for (new i; i < sizeof commandTransfer; i++) register_clcmd(commandTransfer[i], "transfer_menu");

	register_clcmd("ILOSC_HONORU", "transfer_honor_handle");
}

public cod_end_map()
	mapEnd = true;

public transfer_menu(id)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	cod_play_sound(id, SOUND_SELECT);

	new menuData[256], playerName[MAX_NAME], playerId[3], players, menu = menu_create("\yWybierz \rGracza\y, ktoremu chcesz przelac \rHonor\w:", "transfer_menu_handle");

	for (new player = 1; player <= MAX_PLAYERS; player++) {
		if (!is_user_connected(player) || !cod_get_user_class(player) || player == id) continue;

		get_user_name(player, playerName, charsmax(playerName));

		formatex(menuData, charsmax(menuData), "%s \y[%d Honoru]", playerName, cod_get_user_honor(player));

		num_to_str(player, playerId, charsmax(playerId));

		menu_additem(menu, menuData, playerId);

		players++;
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");

	if (!players) {
		menu_destroy(menu);

		cod_print_chat(id, "Na serwerze nie ma gracza, ktoremu moglbys przelac^3 honor^1!");
	} else menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public transfer_menu_handle(id, menu, item)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	new playerId[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, playerId, charsmax(playerId), _, _, itemCallback);

	new player = str_to_num(playerId);

	menu_destroy(menu);

	if (!is_user_connected(player)) {
		cod_print_chat(id, "Tego gracza nie ma juz na serwerze!");

		return PLUGIN_HANDLED;
	}

	transferPlayer[id] = player;

	client_cmd(id, "messagemode ILOSC_HONORU");

	cod_print_chat(id, "Wpisz ilosc^3 honoru^1, ktora chcesz przelac!");

	client_print(id, print_center, "Wpisz ilosc honoru, ktora chcesz przelac!");

	return PLUGIN_HANDLED;
}

public transfer_honor_handle(id)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	cod_play_sound(id, SOUND_EXIT);

	if (!is_user_connected(transferPlayer[id])) {
		cod_print_chat(id, "Gracza, ktoremu chcesz przelac^3 honor^1 nie ma juz na serwerze!");

		return PLUGIN_HANDLED;
	}

	new honorData[16], honorAmount;

	read_args(honorData, charsmax(honorData));
	remove_quotes(honorData);

	honorAmount = str_to_num(honorData);

	if (honorAmount <= 0) {
		cod_print_chat(id, "Nie mozesz przelac mniej niz^3 1 honoru^1!");

		return PLUGIN_HANDLED;
	}

	if (cod_get_user_honor(id) < honorAmount) {
		cod_print_chat(id, "Nie masz tyle^3 honoru^1!");

		return PLUGIN_HANDLED;
	}

	new playerName[MAX_NAME], playerIdName[MAX_NAME];

	get_user_name(id, playerName, charsmax(playerName));
	get_user_name(transferPlayer[id], playerIdName, charsmax(playerIdName));

	cod_set_user_honor(transferPlayer[id], cod_get_user_honor(transferPlayer[id]) + honorAmount);
	cod_set_user_honor(id, cod_get_user_honor(id) - honorAmount);

	cod_print_chat(0, "^3%s^1 przelal^4 %i honoru^1 na konto^3 %s^1.", playerName, honorAmount, playerIdName);

	return PLUGIN_HANDLED;
}