#include <amxmodx>
#include <cod>

#define PLUGIN  "CoD Admin Menu"
#define AUTHOR  "O'Zone"

#define ACCESS_FLAG ADMIN_CVAR

new const menuOptions[][] = {
	"ADMIN_MENU_GIVE_ITEM",
	"ADMIN_MENU_SET_LEVEL",
	"ADMIN_MENU_ADD_LEVEL",
	"ADMIN_MENU_ADD_EXP",
	"ADMIN_MENU_EXCHANGE_EXP",
	"ADMIN_MENU_TRANSFER_EXP",
	"ADMIN_MENU_ADD_HONOR"
};

enum _:options {
	GIVE_ITEM,
	SET_LEVEL,
	ADD_LEVEL,
	ADD_EXP,
	EXCHANGE_EXP,
	TRANSFER_EXP,
	ADD_HONOR
};

new const commandMenu[][] = { "codadmin", "say /codadmin", "say /ca", "say_team /codadmin", "say_team /ca" };

new selectedOption[MAX_PLAYERS + 1], selectedPlayer[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for (new i; i < sizeof(commandMenu); i++) register_clcmd(commandMenu[i], "admin_menu");

	register_clcmd("WPISZ_ILOSC", "amount_handle");
}

public admin_menu(id)
{
	if (!(cod_get_user_flags(id) & ACCESS_FLAG)) return PLUGIN_HANDLED;

	new menuData[64];

	formatex(menuData, charsmax(menuData), "%L", id, "ADMIN_MENU_TITLE");

	new menu = menu_create(menuData, "admin_menu_handle");

	for (new i; i < sizeof(menuOptions); i++) {
		formatex(menuData, charsmax(menuData), "%L", id, menuOptions[i]);

		menu_additem(menu, menuData);
	}

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public admin_menu_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	selectedOption[id] = item;

	menu_destroy(menu);

	player_menu(id);

	return PLUGIN_HANDLED;
}

public player_menu(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	new playerName[MAX_NAME], playerId[6], menuData[64];

	formatex(menuData, charsmax(menuData), "%L", id, "ADMIN_MENU_SELECT_PLAYER");

	new menu = menu_create(menuData, "player_menu_handle");

	for (new player = 1; player <= MAX_PLAYERS; player++) {
		if (!is_user_connected(player) || is_user_hltv(player)) continue;

		get_user_name(player, playerName, charsmax(playerName));

		num_to_str(player, playerId, charsmax(playerId));

		menu_additem(menu, playerName, playerId);
	}

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public player_menu_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	new itemData[6], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, itemCallback);

	menu_destroy(menu);

	new player = str_to_num(itemData);

	if (!is_user_connected(player)) {
		cod_print_chat(id, "%L", id, "ADMIN_PLAYER_LEFT");

		return PLUGIN_HANDLED;
	}

	selectedPlayer[id] = player;

	switch (selectedOption[id]) {
		case GIVE_ITEM: select_item_menu(id);
		case EXCHANGE_EXP, TRANSFER_EXP: select_class_menu(id);
		case SET_LEVEL: {
			client_cmd(id, "messagemode WPISZ_ILOSC");

			client_print(id, print_center, "%L", id, "ADMIN_ENTER_SET_LEVEL");
			cod_print_chat(id, "%L", id, "ADMIN_ENTER_SET_LEVEL");
		} case ADD_LEVEL: {
			client_cmd(id, "messagemode WPISZ_ILOSC");

			client_print(id, print_center, "%L", id, "ADMIN_ENTER_ADD_LEVEL");
			cod_print_chat(id, "%L", id, "ADMIN_ENTER_ADD_LEVEL");
		} case ADD_EXP: {
			client_cmd(id, "messagemode WPISZ_ILOSC");

			client_print(id, print_center, "%L", id, "ADMIN_ENTER_ADD_EXP");
			cod_print_chat(id, "%L", id, "ADMIN_ENTER_ADD_EXP");
		} case ADD_HONOR: {
			client_cmd(id, "messagemode WPISZ_ILOSC");

			client_print(id, print_center, "%L", id, "ADMIN_ENTER_ADD_HONOR");
			cod_print_chat(id, "%L", id, "ADMIN_ENTER_ADD_HONOR");
		}
	}

	return PLUGIN_HANDLED;
}

public select_item_menu(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (!is_user_connected(selectedPlayer[id])) {
		cod_play_sound(id, SOUND_EXIT);

		cod_print_chat(id, "%L", id, "ADMIN_PLAYER_LEFT");

		return PLUGIN_HANDLED;
	}

	new menuData[128], itemName[MAX_NAME], itemId[6];

	formatex(menuData, charsmax(menuData), "%L", id, "ADMIN_MENU_SELECT_ITEM");

	new menu = menu_create(menuData, "select_menu_handle");

	for (new i = 1; i <= cod_get_items_num(); i++) {
		cod_get_item_name(i, itemName, charsmax(itemName));

		formatex(menuData,charsmax(menuData), itemName);

		num_to_str(i, itemId, charsmax(itemId));

		menu_additem(menu, menuData, itemId);
	}

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public select_class_menu(id)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (!is_user_connected(selectedPlayer[id])) {
		cod_play_sound(id, SOUND_EXIT);

		cod_print_chat(id, "%L", id, "ADMIN_PLAYER_LEFT");

		return PLUGIN_HANDLED;
	}

	new menuData[128], className[MAX_NAME], classId[6];

	formatex(menuData, charsmax(menuData), "%L", id, "ADMIN_MENU_SELECT_CLASS");

	new menu = menu_create(menuData, "select_menu_handle");

	for (new i = 1; i < cod_get_classes_num(); i++) {
		if (cod_get_user_class(selectedPlayer[id]) == i) continue;

		cod_get_class_name(i, _, className, charsmax(className));

		formatex(menuData,charsmax(menuData), className);

		num_to_str(i, classId, charsmax(classId));

		menu_additem(menu, menuData, classId);
	}

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public select_menu_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	if (!is_user_connected(selectedPlayer[id])) {
		cod_play_sound(id, SOUND_EXIT);

		cod_print_chat(id, "%L", id, "ADMIN_PLAYER_LEFT");

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	new itemData[6], itemName[MAX_NAME], playerName[MAX_NAME], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), itemName, charsmax(itemName), itemCallback);

	menu_destroy(menu);

	get_user_name(selectedPlayer[id], playerName, charsmax(playerName));

	new selected = str_to_num(itemData);

	switch (selectedOption[id]) {
		case GIVE_ITEM: {
			cod_set_user_item(selectedPlayer[id], selected, RANDOM, true);

			cod_print_chat(id, "%L", id, "ADMIN_GAVE_ITEM", itemName, playerName);
		} case EXCHANGE_EXP: {
			new firstClassName[MAX_NAME], secondClassName[MAX_NAME],
				firstClassExp = cod_get_user_exp(selectedPlayer[id]),
				firstClass = cod_get_user_class(selectedPlayer[id]);

			cod_get_class_name(firstClass, _, firstClassName, charsmax(firstClassName));
			cod_get_class_name(selected, _, secondClassName, charsmax(secondClassName));

			cod_set_user_class(selectedPlayer[id], selected, 1);

			new secondClassExp = cod_get_user_exp(selectedPlayer[id]);

			cod_set_user_exp(selectedPlayer[id], -secondClassExp + firstClassExp);
			cod_set_user_class(selectedPlayer[id], firstClass, 1);
			cod_set_user_exp(selectedPlayer[id], -firstClassExp + secondClassExp);

			if (secondClassExp < firstClassExp) {
				cod_set_user_class(selectedPlayer[id], selected, 1);
			}

			cod_print_chat(id, "%L", id, "ADMIN_EXCHANGED_EXP", firstClassName, secondClassName, playerName);
		} case TRANSFER_EXP: {
			new firstClassName[MAX_NAME], secondClassName[MAX_NAME],
				firstClassExp = cod_get_user_exp(selectedPlayer[id]),
				firstClass = cod_get_user_class(selectedPlayer[id]);

			cod_get_class_name(firstClass, _, firstClassName, charsmax(firstClassName));
			cod_get_class_name(selected, _, secondClassName, charsmax(secondClassName));

			cod_set_user_exp(selectedPlayer[id], -firstClassExp);
			cod_set_user_class(selectedPlayer[id], selected, 1);
			cod_set_user_exp(selectedPlayer[id], firstClassExp);

			cod_print_chat(id, "%L", id, "ADMIN_TRANSFERRED_EXP", firstClassName, secondClassName, playerName);
		}
	}

	return PLUGIN_HANDLED;
}

public amount_handle(id)
{
	if (!is_user_connected(id) || !(cod_get_user_flags(id) & ACCESS_FLAG)) return PLUGIN_HANDLED;

	if (!is_user_connected(selectedPlayer[id])) {
		cod_print_chat(id, "%L", id, "ADMIN_PLAYER_LEFT");

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_EXIT);

	new amountData[16], amount;

	read_args(amountData, charsmax(amountData));
	remove_quotes(amountData);

	amount = str_to_num(amountData);

	if (amount <= 0) {
		cod_print_chat(id, "%L", id, "ADMIN_MIN_AMOUNT");

		return PLUGIN_HANDLED;
	}

	new playerName[MAX_NAME];

	get_user_name(selectedPlayer[id], playerName, charsmax(playerName));

	switch (selectedOption[id]) {
		case SET_LEVEL: {
			cod_set_user_exp(selectedPlayer[id], -cod_get_user_exp(selectedPlayer[id]) + cod_get_level_exp(amount - 1));

			cod_print_chat(id, "%L", id, "ADMIN_SET_LEVEL_DONE", amount, playerName);
		} case ADD_LEVEL: {
			cod_set_user_exp(selectedPlayer[id], cod_get_level_exp(cod_get_user_level(selectedPlayer[id]) + amount - 1) - cod_get_user_exp(selectedPlayer[id]));

			cod_print_chat(id, "%L", id, "ADMIN_ADD_LEVEL_DONE", amount, playerName);
		} case ADD_EXP: {
			cod_set_user_exp(selectedPlayer[id], amount);

			cod_print_chat(id, "%L", id, "ADMIN_ADD_EXP_DONE", amount, playerName);
		} case ADD_HONOR: {
			cod_add_user_honor(selectedPlayer[id], amount);

			cod_print_chat(id, "%L", id, "ADMIN_ADD_HONOR_DONE", amount, playerName);
		}
	}

	return PLUGIN_HANDLED;
}
