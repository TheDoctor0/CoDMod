#include <amxmodx>
#include <cstrike>
#include <cod>

#define PLUGIN "CoD Market"
#define AUTHOR "O'Zone"

new const commandMarket[][] = { "rynek", "say /market", "say_team /market", "say /rynek", "say_team /rynek" };
new const commandSell[][] = { "sprzedaj", "say /sell", "say_team /sell", "say /wystaw", "say_team /wystaw", "say /sprzedaj", "say_team /sprzedaj" };
new const commandBuy[][] = { "kup", "say /buy", "say_team /buy", "say /kup", "say_team /kup" };
new const commandWithdraw[][] = { "wycofaj", "say /withdraw", "say_team /withdraw", "say /wycofaj", "say_team /wycofaj" };

enum _:itemInfo { MARKET_ID, MARKET_ITEM, MARKET_VALUE, MARKET_DURABILITY, MARKET_OWNER, MARKET_PRICE, MARKET_NAME[MAX_NAME] };

new playerName[MAX_PLAYERS + 1][MAX_NAME], Array:marketItems, bool:mapEnd, items, cvarMaxItems;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	bind_pcvar_num(create_cvar("cod_market_max_items", "5"), cvarMaxItems);

	for (new i; i < sizeof commandMarket; i++) register_clcmd(commandMarket[i], "market_menu");
	for (new i; i < sizeof commandSell; i++) register_clcmd(commandSell[i], "sell_item");
	for (new i; i < sizeof commandBuy; i++) register_clcmd(commandBuy[i], "buy_item");
	for (new i; i < sizeof commandWithdraw; i++) register_clcmd(commandWithdraw[i], "withdraw_item");

	register_concmd("CENA_PRZEDMIOTU", "set_item_price");

	marketItems = ArrayCreate(itemInfo);
}

public client_disconnected(id)
	remove_seller(id);

public client_putinserver(id)
	get_user_name(id, playerName[id], charsmax(playerName[]));

public cod_end_map()
	mapEnd = true;

public market_menu(id)
{
	if (!cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	cod_play_sound(id, SOUND_SELECT);

	new menuData[64];

	formatex(menuData, charsmax(menuData), "%L", id, "MARKET_MENU_TITLE");

	new menu = menu_create(menuData, "market_menu_handle"), callback = menu_makecallback("market_menu_callback");

	formatex(menuData, charsmax(menuData), "%L", id, "MARKET_MENU_SELL");
	menu_additem(menu, menuData, _, _, callback);

	formatex(menuData, charsmax(menuData), "%L", id, "MARKET_MENU_BUY");
	menu_additem(menu, menuData, _, _, callback);

	formatex(menuData, charsmax(menuData), "%L", id, "MARKET_MENU_WITHDRAW");
	menu_additem(menu, menuData, _, _, callback);

	formatex(menuData, charsmax(menuData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, menuData);

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public market_menu_handle(id, menu, item)
{
	if (!is_user_connected(id) || mapEnd) return PLUGIN_HANDLED;

	cod_play_sound(id, SOUND_SELECT);

	if (item == MENU_EXIT) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	switch (item) {
		case 0: sell_item(id, 1);
		case 1: buy_item(id, 1);
		case 2: withdraw_item(id, 1);
	}

	return PLUGIN_HANDLED;
}

public market_menu_callback(id, menu, item)
{
	switch (item) {
		case 0: if (!cod_get_user_class(id) || !cod_get_user_item(id) || (cvarMaxItems && get_items_amount(id) >= cvarMaxItems)) return ITEM_DISABLED;
		case 1: if (!ArraySize(marketItems)) return ITEM_DISABLED;
		case 2: if (!get_items_amount(id)) return ITEM_DISABLED;
	}

	return ITEM_ENABLED;
}

public sell_item(id, sound)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	if (!sound) cod_play_sound(id, SOUND_SELECT);

	if (!cod_get_user_item(id)) {
		cod_print_chat(id, "%L", id, "MARKET_NO_ITEM");

		return PLUGIN_HANDLED;
	}

	if (cvarMaxItems && get_items_amount(id) >= cvarMaxItems) {
		cod_print_chat(id, "%L", id, "MARKET_MAX_ITEMS", cvarMaxItems);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "messagemode CENA_PRZEDMIOTU");

	cod_print_chat(id, "%L", id, "MARKET_ENTER_PRICE");

	client_print(id, print_center, "%L", id, "MARKET_ENTER_PRICE_CENTER");

	return PLUGIN_HANDLED;
}

public set_item_price(id)
{
	if (!cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	cod_play_sound(id, SOUND_EXIT);

	if (!cod_get_user_item(id)) {
		cod_print_chat(id, "%L", id, "MARKET_NO_ITEM");

		return PLUGIN_HANDLED;
	}

	if (cvarMaxItems && get_items_amount(id) >= cvarMaxItems) {
		cod_print_chat(id, "%L", id, "MARKET_MAX_ITEMS", cvarMaxItems);

		return PLUGIN_HANDLED;
	}

	new priceData[16], price;

	read_args(priceData, charsmax(priceData));
	remove_quotes(priceData);

	price = str_to_num(priceData);

	if (price  < 1 || price > 99999) {
		cod_print_chat(id, "%L", id, "MARKET_PRICE_RANGE");

		return PLUGIN_HANDLED;
	}

	new marketItem[itemInfo];

	marketItem[MARKET_ID] = items++;
	marketItem[MARKET_ITEM] = cod_get_user_item(id, marketItem[MARKET_VALUE]);
	marketItem[MARKET_DURABILITY] = cod_get_item_durability(id);
	marketItem[MARKET_OWNER] = id;
	marketItem[MARKET_PRICE] = price;

	cod_get_item_name(cod_get_user_item(id), marketItem[MARKET_NAME], charsmax(marketItem[MARKET_NAME]));

	ArrayPushArray(marketItems, marketItem);

	cod_set_user_item(id);

	cod_print_chat(0, "%L", LANG_SERVER, "MARKET_LISTED", playerName[id], marketItem[MARKET_NAME], marketItem[MARKET_PRICE]);

	return PLUGIN_HANDLED;
}

public buy_item(id, sound)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	if (!sound) cod_play_sound(id, SOUND_SELECT);

	new marketItem[itemInfo], itemData[128], itemId[5], itemsCounts = 0;

	formatex(itemData, charsmax(itemData), "%L", id, "MARKET_BUY_TITLE");

	new menu = menu_create(itemData, "buy_item_handle");

	for (new i = 0; i < ArraySize(marketItems); i++) {
		ArrayGetArray(marketItems, i, marketItem);

		if (marketItem[MARKET_OWNER] == id) continue;

		num_to_str(marketItem[MARKET_ID], itemId, charsmax(itemId));

		formatex(itemData, charsmax(itemData), "%L", id, "MARKET_ITEM_ENTRY", marketItem[MARKET_NAME], marketItem[MARKET_DURABILITY], cod_max_item_durability(), marketItem[MARKET_PRICE]);

		menu_additem(menu, itemData, itemId);

		itemsCounts++;
	}

	formatex(itemData, charsmax(itemData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, itemData);

	formatex(itemData, charsmax(itemData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, itemData);

	formatex(itemData, charsmax(itemData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, itemData);

	if (!itemsCounts)
	{
		menu_destroy(menu);

		cod_print_chat(id, "%L", id, "MARKET_EMPTY");
	} else menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public buy_item_handle(id, menu, item)
{
	if (!is_user_connected(id) || mapEnd) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	new itemId[5], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemId, charsmax(itemId), _, _, itemCallback);

	new item = check_item_id(str_to_num(itemId));

	if (item < 0) {
		buy_item(id, 1);

		cod_print_chat(id, "%L", id, "MARKET_ALREADY_SOLD");

		return PLUGIN_HANDLED;
	}

	new marketItem[itemInfo];

	ArrayGetArray(marketItems, item, marketItem);

	if (!cod_check_item(id, marketItem[MARKET_ITEM])) {
		cod_print_chat(id, "%L", id, "MARKET_NO_ACCESS");

		return PLUGIN_HANDLED;
	}

	new menuData[512], itemDescription[MAX_DESC], length = 0, maxLength = charsmax(menuData);

	cod_get_item_desc(marketItem[MARKET_ITEM], itemDescription, charsmax(itemDescription));

	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_BUY_CONFIRM_FROM", playerName[marketItem[MARKET_OWNER]]);
	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_CONFIRM_ITEM", marketItem[MARKET_NAME]);
	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_CONFIRM_DESC", itemDescription);
	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_CONFIRM_COST", marketItem[MARKET_PRICE]);
	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_CONFIRM_DURABILITY", marketItem[MARKET_DURABILITY], cod_max_item_durability());
	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_BUY_CONFIRM_QUESTION");

	new menu = menu_create(menuData, "buy_question_handle");

	new answerText[32];

	formatex(answerText, charsmax(answerText), "%L", id, "CORE_YES");
	menu_additem(menu, answerText, itemId);

	formatex(answerText, charsmax(answerText), "%L", id, "CORE_NO");
	menu_additem(menu, answerText);

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);

	return PLUGIN_CONTINUE;
}

public buy_question_handle(id, menu, item)
{
	if (!is_user_connected(id) || mapEnd) return PLUGIN_HANDLED;

	if (item == MENU_EXIT || item) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	new itemId[5], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemId, charsmax(itemId), _, _, itemCallback);

	new item = check_item_id(str_to_num(itemId));

	if (item < 0) {
		buy_item(id, 1);

		cod_print_chat(id, "%L", id, "MARKET_ALREADY_SOLD");

		return PLUGIN_HANDLED;
	}

	new marketItem[itemInfo];

	ArrayGetArray(marketItems, item, marketItem);

	if (cod_get_user_honor(id) < marketItem[MARKET_PRICE]) {
		cod_print_chat(id, "%L", id, "MARKET_NOT_ENOUGH_HONOR");

		return PLUGIN_HANDLED;
	} else {
		cod_set_user_honor(marketItem[MARKET_OWNER], cod_get_user_honor(marketItem[MARKET_OWNER]) + marketItem[MARKET_PRICE]);
		cod_set_user_honor(id, cod_get_user_honor(id) - marketItem[MARKET_PRICE]);
	}

	ArrayDeleteItem(marketItems, item);

	cod_set_user_item(id, marketItem[MARKET_ITEM], marketItem[MARKET_VALUE]);
	cod_set_item_durability(id, marketItem[MARKET_DURABILITY]);

	cod_print_chat(id, "%L", id, "MARKET_BOUGHT", marketItem[MARKET_NAME]);
	cod_print_chat(marketItem[MARKET_OWNER], "%L", marketItem[MARKET_OWNER], "MARKET_SOLD", marketItem[MARKET_NAME], playerName[id]);
	cod_print_chat(marketItem[MARKET_OWNER], "%L", marketItem[MARKET_OWNER], "MARKET_SOLD_REWARD", marketItem[MARKET_PRICE])

	return PLUGIN_CONTINUE;
}

public withdraw_item(id, sound)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	if (!sound) cod_play_sound(id, SOUND_SELECT);

	new marketItem[itemInfo], itemData[128], itemId[5], itemsCounts = 0;

	formatex(itemData, charsmax(itemData), "%L", id, "MARKET_WITHDRAW_TITLE");

	new menu = menu_create(itemData, "withdraw_item_handle");

	for (new i = 0; i < ArraySize(marketItems); i++) {
		ArrayGetArray(marketItems, i, marketItem);

		if (marketItem[MARKET_OWNER] != id) continue;

		num_to_str(marketItem[MARKET_ID], itemId, charsmax(itemId));

		formatex(itemData, charsmax(itemData), "%L", id, "MARKET_ITEM_ENTRY", marketItem[MARKET_NAME], marketItem[MARKET_DURABILITY], cod_max_item_durability(), marketItem[MARKET_PRICE]);

		menu_additem(menu, itemData, itemId);

		itemsCounts++;
	}

	formatex(itemData, charsmax(itemData), "%L", id, "CORE_MENU_EXIT");
	menu_setprop(menu, MPROP_EXITNAME, itemData);

	formatex(itemData, charsmax(itemData), "%L", id, "CORE_MENU_PREVIOUS");
	menu_setprop(menu, MPROP_BACKNAME, itemData);

	formatex(itemData, charsmax(itemData), "%L", id, "CORE_MENU_NEXT");
	menu_setprop(menu, MPROP_NEXTNAME, itemData);

	if (!itemsCounts) {
		menu_destroy(menu);

		cod_print_chat(id, "%L", id, "MARKET_NO_OWN_ITEMS");
	} else menu_display(id, menu);

	return PLUGIN_CONTINUE;
}

public withdraw_item_handle(id, menu, item)
{
	if (!is_user_connected(id) || mapEnd) return PLUGIN_HANDLED;

	if (item == MENU_EXIT || item) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	new itemId[5], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemId, charsmax(itemId), _, _, itemCallback);

	new item = check_item_id(str_to_num(itemId));

	if (item < 0) {
		buy_item(id, 1);

		cod_print_chat(id, "%L", id, "MARKET_ALREADY_BOUGHT");

		return PLUGIN_HANDLED;
	}

	new marketItem[itemInfo], menuData[512], itemDescription[MAX_DESC], length = 0, maxLength = sizeof(menuData) - 1;

	ArrayGetArray(marketItems, item, marketItem);

	cod_get_item_desc(marketItem[MARKET_ITEM], itemDescription, charsmax(itemDescription));

	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_WITHDRAW_CONFIRM");
	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_CONFIRM_ITEM", marketItem[MARKET_NAME]);
	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_CONFIRM_DESC", itemDescription);
	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_CONFIRM_COST", marketItem[MARKET_PRICE]);
	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_CONFIRM_DURABILITY_LAST", marketItem[MARKET_DURABILITY], cod_max_item_durability());
	length += formatex(menuData[length], maxLength - length, "%L", id, "MARKET_WITHDRAW_QUESTION");

	new menu = menu_create(menuData, "withdraw_question_handle");

	new answerText[32];

	formatex(answerText, charsmax(answerText), "%L", id, "CORE_YES");
	menu_additem(menu, answerText, itemId);

	formatex(answerText, charsmax(answerText), "%L", id, "CORE_NO");
	menu_additem(menu, answerText);

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);

	return PLUGIN_CONTINUE;
}

public withdraw_question_handle(id, menu, item)
{
	if (!is_user_connected(id) || mapEnd) return PLUGIN_HANDLED;

	if (item == MENU_EXIT || item) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	new itemId[5], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemId, charsmax(itemId), _, _, itemCallback);

	new item = check_item_id(str_to_num(itemId));

	if (item < 0) {
		withdraw_item(id, 1);

		cod_print_chat(id, "%L", id, "MARKET_ALREADY_BOUGHT");

		return PLUGIN_HANDLED;
	}

	new marketItem[itemInfo];

	ArrayGetArray(marketItems, item, marketItem);

	cod_set_user_item(id, marketItem[MARKET_ITEM], marketItem[MARKET_VALUE]);
	cod_set_item_durability(id, marketItem[MARKET_DURABILITY]);

	ArrayDeleteItem(marketItems, item);

	cod_print_chat(id, "%L", id, "MARKET_WITHDRAWN", marketItem[MARKET_NAME]);

	return PLUGIN_HANDLED;
}

stock get_items_amount(id)
{
	if (!is_user_connected(id)) return 0;

	new amount = 0, marketItem[itemInfo];

	for (new i = 0; i < ArraySize(marketItems); i++) {
		ArrayGetArray(marketItems, i, marketItem);

		if (marketItem[MARKET_OWNER] == id) amount++;
	}

	return amount;
}

stock check_item_id(item)
{
	new marketItem[itemInfo];

	for (new i = 0; i < ArraySize(marketItems); i++) {
		ArrayGetArray(marketItems, i, marketItem);

		if (marketItem[MARKET_ID] == item) return i;
	}

	return NONE;
}

stock remove_seller(id)
{
	new marketItem[itemInfo];

	for (new i = 0; i < ArraySize(marketItems); i++) {
		ArrayGetArray(marketItems, i, marketItem);

		if (marketItem[MARKET_OWNER] == id) {
			ArrayDeleteItem(marketItems, i);

			i -= 1;
		}
	}
}