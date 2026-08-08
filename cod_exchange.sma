#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Exchange"
#define AUTHOR "O'Zone"

new const commandExchange[][] = { "wymien", "say /exchange", "say_team /exchange", "say /zamien", "say_team /zamien", "say /wymien", "say_team /wymien" };
new const commandGive[][] = { "daj", "say /give", "say_team /give", "say /oddaj", "say_team /oddaj", "say /daj", "say_team /daj" };

new bool:mapEnd, blockExchange, cooldown;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for (new i; i < sizeof commandExchange; i++) register_clcmd(commandExchange[i], "exchange_menu");
	for (new i; i < sizeof commandGive; i++) register_clcmd(commandGive[i], "give_item");
}

public cod_end_map()
	mapEnd = true;

public cod_new_round()
	for (new i = 1; i <= MAX_PLAYERS; i++) rem_bit(i, cooldown);

public exchange_menu(id)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	cod_play_sound(id, SOUND_SELECT);

	new menuData[96], statusText[32];

	formatex(menuData, charsmax(menuData), "%L", id, "EXCHANGE_MENU_TITLE");

	new menu = menu_create(menuData, "exchange_menu_handle");

	formatex(menuData, charsmax(menuData), "%L", id, "EXCHANGE_MENU_ITEM");
	menu_additem(menu, menuData);

	formatex(statusText, charsmax(statusText), "%L", id, get_bit(id, blockExchange) ? "EXCHANGE_BLOCKED" : "EXCHANGE_UNBLOCKED");
	formatex(menuData, charsmax(menuData), "%L", id, "EXCHANGE_MENU_PROPOSALS", statusText);

	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public exchange_menu_handle(id, menu, item)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		menu_destroy(menu);

		cod_play_sound(id, SOUND_EXIT);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	switch (item) {
		case 0: exchange_item(id, 1);
		case 1: {
			if (get_bit(id, blockExchange)) {
				rem_bit(id, blockExchange);

				cod_print_chat(id, "%L", id, "EXCHANGE_UNBLOCKED_INFO");
			} else {
				set_bit(id, blockExchange);

				cod_print_chat(id, "%L", id, "EXCHANGE_BLOCKED_INFO");
			}
		}
	}

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public exchange_item(id, sound)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	if (!sound) cod_play_sound(id, SOUND_SELECT);

	new menuData[128], playerName[MAX_NAME], itemName[MAX_NAME], playerId[3], players;

	formatex(menuData, charsmax(menuData), "%L", id, "EXCHANGE_ITEM_TITLE");

	new menu = menu_create(menuData, "exchange_item_handle");

	for (new player = 1; player <= MAX_PLAYERS; player++) {
		if (!is_user_connected(player) || id == player || !cod_get_user_class(player) || !cod_get_user_item(player) || get_bit(player, blockExchange)) continue;

		cod_get_item_name(cod_get_user_item(player), itemName, charsmax(itemName));

		get_user_name(player, playerName, charsmax(playerName));

		formatex(menuData, charsmax(menuData), "%s \y(%s)", playerName, itemName);

		num_to_str(player, playerId, charsmax(playerId));

		menu_additem(menu, menuData, playerId);

		players++;
	}

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	if (!players) {
		menu_destroy(menu);

		cod_print_chat(id, "%L", id, "EXCHANGE_NO_PLAYERS");
	} else menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public exchange_item_handle(id, menu, item)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		menu_destroy(menu);

		cod_play_sound(id, SOUND_EXIT);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	new playerId[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, playerId, charsmax(playerId), _, _, itemCallback);

	new player = str_to_num(playerId);

	menu_destroy(menu);

	if (!is_user_connected(player)) {
		cod_print_chat(id, "%L", id, "EXCHANGE_PLAYER_LEFT");

		return PLUGIN_HANDLED;
	}

	if (get_bit(player, cooldown)) {
		cod_print_chat(id, "%L", id, "EXCHANGE_TARGET_COOLDOWN");

		return PLUGIN_HANDLED;
	}

	if (get_bit(id, cooldown)) {
		cod_print_chat(id, "%L", id, "EXCHANGE_COOLDOWN");

		return PLUGIN_HANDLED;
	}

	if (!cod_get_user_item(player)) {
		cod_print_chat(id, "%L", id, "EXCHANGE_TARGET_NO_ITEM");

		return PLUGIN_HANDLED;
	}

	if (!cod_get_user_item(id)) {
		cod_print_chat(id, "%L", id, "EXCHANGE_NO_ITEM");

		return PLUGIN_HANDLED;
	}

	if (!cod_check_item(id, cod_get_user_item(player))) {
		cod_print_chat(id, "%L", id, "EXCHANGE_NO_ACCESS");

		return PLUGIN_HANDLED;
	}

	if (!cod_check_item(player, cod_get_user_item(id))) {
		cod_print_chat(id, "%L", id, "EXCHANGE_TARGET_NO_ACCESS");

		return PLUGIN_HANDLED;
	}

	new menuData[128], playerName[MAX_NAME], itemName[MAX_NAME];

	cod_get_item_name(cod_get_user_item(id), itemName, charsmax(itemName));
	get_user_name(id, playerName, charsmax(playerName));

	formatex(menuData, charsmax(menuData), "%L", player, "EXCHANGE_QUESTION_TITLE", playerName, itemName);

	new menu = menu_create(menuData, "exchange_item_question");

	num_to_str(id, playerId, charsmax(playerId));

	formatex(menuData, charsmax(menuData), "%L", player, "CORE_YES");
	menu_additem(menu, menuData, playerId);

	formatex(menuData, charsmax(menuData), "%L", player, "CORE_NO");
	menu_additem(menu, menuData, playerId);

	formatex(menuData, charsmax(menuData), "%L", player, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	menu_display(player, menu);

	return PLUGIN_HANDLED;
}

public exchange_item_question(id, menu, item)
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
		cod_print_chat(id, "%L", id, "EXCHANGE_PROPOSER_LEFT");

		return PLUGIN_HANDLED;
	}

	if (get_bit(player, cooldown)) {
		cod_print_chat(id, "%L", id, "EXCHANGE_PROPOSER_COOLDOWN");

		return PLUGIN_HANDLED;
	}

	if (!cod_get_user_item(player)) {
		cod_print_chat(id, "%L", id, "EXCHANGE_PROPOSER_NO_ITEM");

		return PLUGIN_HANDLED;
	}

	if (!cod_get_user_item(id)) {
		cod_print_chat(id, "%L", id, "EXCHANGE_NO_ITEM");

		return PLUGIN_HANDLED;
	}

	if (!cod_check_item(id, cod_get_user_item(player))) {
		cod_print_chat(id, "%L", id, "EXCHANGE_PROPOSER_ITEM_NO_ACCESS");

		return PLUGIN_HANDLED;
	}

	if (!cod_check_item(player, cod_get_user_item(id))) {
		cod_print_chat(id, "%L", id, "EXCHANGE_PROPOSER_NO_ACCESS");

		return PLUGIN_HANDLED;
	}

	switch (item) {
		case 0: {
			new name[MAX_NAME], playerName[MAX_NAME], itemName[MAX_NAME], playerItemName[MAX_NAME],
				itemValue, itemId = cod_get_user_item(id, itemValue), itemDurability = cod_get_item_durability(id),
				playerItemValue, playerItemId = cod_get_user_item(player, playerItemValue), playerItemDurability = cod_get_item_durability(player);

			get_user_name(player, playerName, charsmax(playerName));
			get_user_name(id, name, charsmax(name));

			cod_get_item_name(cod_get_user_item(player), playerItemName, charsmax(playerItemName));
			cod_get_item_name(cod_get_user_item(id), itemName, charsmax(itemName));

			cod_set_user_item(player, itemId, itemValue);
			cod_set_user_item(id, playerItemId, playerItemValue);

			cod_set_item_durability(player, itemDurability);
			cod_set_item_durability(id, playerItemDurability);

			set_bit(player, cooldown);
			set_bit(id, cooldown);

			cod_print_chat(player, "%L", player, "EXCHANGE_DONE", name, itemName);
			cod_print_chat(id, "%L", id, "EXCHANGE_DONE", playerName, playerItemName);
		} case 1: cod_print_chat(player, "%L", player, "EXCHANGE_DECLINED");
	}

	return PLUGIN_HANDLED;
}

public give_item(id)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	cod_play_sound(id, SOUND_SELECT);

	new playerName[MAX_NAME], playerId[3], players, menuData[64];

	formatex(menuData, charsmax(menuData), "%L", id, "GIVE_MENU_TITLE");

	new menu = menu_create(menuData, "give_item_handle");

	for (new player = 1; player <= MAX_PLAYERS; player++) {
		if (!is_user_connected(player) || player == id || !cod_get_user_class(player) || cod_get_user_item(player)) continue;

		get_user_name(player, playerName, charsmax(playerName));

		num_to_str(player, playerId, charsmax(playerId));

		menu_additem(menu, playerName, playerId);

		players++;
	}

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, menuData);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, menuData);

	if (!players) {
		menu_destroy(menu);

		cod_print_chat(id, "%L", id, "GIVE_NO_PLAYERS");
	} else menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public give_item_handle(id, menu, item)
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
		cod_print_chat(id, "%L", id, "EXCHANGE_PLAYER_LEFT");

		return PLUGIN_HANDLED;
	}

	if (get_bit(id, cooldown)) {
		cod_print_chat(id, "%L", id, "GIVE_COOLDOWN");

		return PLUGIN_HANDLED;
	}

	if (cod_get_user_item(player))
	{
		cod_print_chat(id, "%L", id, "GIVE_TARGET_HAS_ITEM");

		return PLUGIN_HANDLED;
	}

	if (!cod_get_user_item(id)) {
		cod_print_chat(id, "%L", id, "EXCHANGE_NO_ITEM");

		return PLUGIN_HANDLED;
	}

	if (!cod_check_item(player, cod_get_user_item(id))) {
		cod_print_chat(id, "%L", id, "GIVE_TARGET_NO_ACCESS");

		return PLUGIN_HANDLED;
	}

	new name[MAX_NAME], playerName[MAX_NAME], itemName[MAX_NAME],
		itemValue, itemId = cod_get_user_item(id, itemValue), itemDurability = cod_get_item_durability(id);

	get_user_name(id, name, charsmax(name));
	get_user_name(player, playerName, charsmax(playerName));

	cod_get_item_name(cod_get_user_item(id), itemName, charsmax(itemName));

	set_bit(player, cooldown);
	rem_bit(id, cooldown);

	cod_set_user_item(player, itemId, itemValue);
	cod_set_item_durability(player, itemDurability);
	cod_set_user_item(id);

	cod_print_chat(id, "%L", id, "GIVE_DONE_GIVER", itemName, playerName);
	cod_print_chat(player, "%L", player, "GIVE_DONE_RECEIVER", itemName, name);

	return PLUGIN_HANDLED;
}