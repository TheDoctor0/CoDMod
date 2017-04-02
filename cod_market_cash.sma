#include <amxmodx>
#include <cstrike>
#include <cod>

#define PLUGIN "CoD Market"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define MAX_ITEMS 5

enum _:items { ID, ITEM, VALUE, DURABILITY, OWNER, TYPE, PRICE, NAME[64] };

new const commandMarket[][] = { "say /market", "say_team /market", "say /rynek", "say_team /rynek", "rynek" };
new const commandSell[][] = { "say /sell", "say_team /sell", "say /wystaw", "say_team /wystaw", "say /sprzedaj", "say_team /sprzedaj", "sprzedaj" };
new const commandBuy[][] = { "say /buy", "say_team /buy", "say /kup", "say_team /kup", "kup" };
new const commandWithdraw[][] = { "say /withdraw", "say_team /withdraw", "say /wycofaj", "say_team /wycofaj", "wycofaj" };

new playerName[MAX_PLAYERS + 1][64], priceType[MAX_PLAYERS + 1], Array:marketItems, itemId;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof commandMarket; i++) register_clcmd(commandMarket[i], "market_menu");

	for(new i; i < sizeof commandSell; i++) register_clcmd(commandSell[i], "sell_item");
	
	for(new i; i < sizeof commandBuy; i++) register_clcmd(commandBuy[i], "buy_item");
	
	for(new i; i < sizeof commandWithdraw; i++) register_clcmd(commandWithdraw[i], "withdraw_item");

	register_concmd("CENA_PRZEDMIOTU", "set_item_price");
	
	marketItems = ArrayCreate(items);
}

public client_disconnected(id)
	remove_seller(id);

public client_connect(id)
	get_user_name(id, playerName[id], charsmax(playerName[]));

public market_menu(id)
{
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menu = menu_create("\wMenu \rRynku", "market_menu_handle"), callback = menu_makecallback("market_menu_callback");
	
	menu_additem(menu, "Wystaw \yPrzedmiot \r(/wystaw)", _, _, callback);
	menu_additem(menu, "Kup \yPrzedmiot \r(/kup)", _, _, callback);
	menu_additem(menu, "Wycofaj \yPrzedmiot \r(/wycofaj)", _, _, callback);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public market_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
		
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}
	
	switch(item)	
	{
		case 0: sell_item(id, 1);	
		case 1: buy_item(id, 1);
		case 2: withdraw_item(id, 1);
	}

	return PLUGIN_HANDLED;
}

public market_menu_callback(id, menu, item)
{
	switch(item)	
	{
		case 0: if(!cod_get_user_class(id) || !cod_get_user_item(id) || get_items_amount(id) >= MAX_ITEMS) return ITEM_DISABLED;
		case 1: if(!ArraySize(marketItems)) return ITEM_DISABLED;
		case 2: if(!get_items_amount(id)) return ITEM_DISABLED;
	}

	return ITEM_ENABLED;
}

public sell_item(id, sound)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
		
	if(!cod_check_account(id)) return PLUGIN_HANDLED;
		
	if(!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menu = menu_create("\wRodzaj \rOferty", "sell_item_handle");
	
	menu_additem(menu, "Sprzedaz \rza \yDolary");
	menu_additem(menu, "Sprzedaz \rza \yHonor");
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public sell_item_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	if(!cod_get_user_item(id))	
	{
		cod_print_chat(id, "Nie masz zadnego itemu!");

		return PLUGIN_HANDLED;
	}
	
	if(get_items_amount(id) >= MAX_ITEMS)	
	{
		cod_print_chat(id, "Wystawiles juz maksymalne^x03 %i^x01 przedmiotow!", MAX_ITEMS);

		return PLUGIN_HANDLED;
	}

	priceType[id] = item;
	
	client_cmd(id, "messagemode CENA_PRZEDMIOTU");
	
	cod_print_chat(id, "Wpisz^x03 cene^x01, za ktora chcesz sprzedac item.");

	client_print(id, print_center, "Wpisz cene, za ktora chcesz sprzedac item.");
	
	return PLUGIN_HANDLED;
}

public set_item_price(id)
{
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

	if(!cod_get_user_item(id))
	{
		cod_print_chat(id, "Nie masz zadnego itemu!");

		return PLUGIN_HANDLED;
	}

	if(get_items_amount(id) >= MAX_ITEMS)	
	{
		cod_print_chat(id, "Wystawiles juz maksymalne^x03 %i^x01 przedmiotow!", MAX_ITEMS);

		return PLUGIN_HANDLED;
	}

	new priceData[16], price;
	
	read_args(priceData, charsmax(priceData));
	remove_quotes(priceData);

	price = str_to_num(priceData);
	
	if(price  <= 0 || price >= 100000)
	{ 
		cod_print_chat(id, "Cena musi nalezec do przedzialu^x03 1 - 99999^x01!");

		return PLUGIN_HANDLED;
	}

	new marketItem[items];
	
	marketItem[ID] = itemId++;
	marketItem[ITEM] = cod_get_user_item(id, marketItem[VALUE]);
	marketItem[DURABILITY] = cod_get_item_durability(id);
	marketItem[OWNER] = id;
	marketItem[TYPE] = priceType[id];
	marketItem[PRICE] = price;

	cod_get_item_name(cod_get_user_item(id), marketItem[NAME], charsmax(marketItem[NAME]));
	
	ArrayPushArray(marketItems, marketItem);
	
	cod_set_user_item(id);
	
	cod_print_chat(0, "^x03%s^x01 wystawil^x03 %s^x01 na rynek za^x03 %i%s^x01.", playerName[id], marketItem[NAME], marketItem[PRICE], marketItem[TYPE] ? " Honoru" : "$");
	
	return PLUGIN_HANDLED;
}

public buy_item(id, sound)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	if(!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new marketItem[items], itemData[128], itemId[2], itemsCounts = 0, menu = menu_create("\wKup \rPrzedmiot", "buy_item_handle");
	
	for(new i = 0; i < ArraySize(marketItems); i++)
	{
		ArrayGetArray(marketItems, i, marketItem);
		
		if(marketItem[OWNER] == id) continue;

		num_to_str(marketItem[ID], itemId, charsmax(itemId));
		
		formatex(itemData, charsmax(itemData), "\w%s \y(%i/%i Wytrzymalosci) \r(%i%s)", marketItem[NAME], marketItem[DURABILITY], cod_max_item_durability(), marketItem[PRICE], marketItem[TYPE] ? " Honoru" : "$");
		
		menu_additem(menu, itemData, itemId);

		itemsCounts++;
	}

	if(!itemsCounts)
	{
		menu_destroy(menu);

		cod_print_chat(id, "Na rynku nie ma zadnych przedmiotow, ktore moglbys kupic!");
	}
	else menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public buy_item_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new itemId[2], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemId, charsmax(itemId), _, _, itemCallback);

	new item = check_item_id(str_to_num(itemId));

	if(item < 0)
	{
		buy_item(id, 1);

		cod_print_chat(id, "Przedmiot zostal juz kupiony lub wycofany z rynku!");

		return PLUGIN_HANDLED;
	}
	
	new marketItem[items], menuData[512], itemDescription[64], length = 0, maxLength = sizeof(menuData) - 1;

	ArrayGetArray(marketItems, item, marketItem);
	
	cod_get_item_desc(marketItem[ITEM], itemDescription, charsmax(itemDescription));

	length += formatex(menuData[length], maxLength - length, "Potwierdzenie kupna od: \y%s^n", playerName[marketItem[OWNER]]);
	length += formatex(menuData[length], maxLength - length, "\wPrzedmiot: \y%s^n", marketItem[NAME]);
	length += formatex(menuData[length], maxLength - length, "\wOpis: \y%s^n", itemDescription);
	length += formatex(menuData[length], maxLength - length, "\wKoszt: \y%d%s^n", marketItem[PRICE], marketItem[TYPE] ? " Honoru" : "$");
	length += formatex(menuData[length], maxLength - length, "\wWytrzymalosc: \y%d/%i^n", marketItem[DURABILITY], cod_max_item_durability());
	length += formatex(menuData[length], maxLength - length, "\wCzy chcesz \rkupic\w ten przedmiot?^n^n");
	
	new menu = menu_create(menuData, "buy_question_handle");
	
	menu_additem(menu, "Tak", itemId);
	menu_additem(menu, "Nie");

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public buy_question_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT || item)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new itemId[2], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemId, charsmax(itemId), _, _, itemCallback);

	new item = check_item_id(str_to_num(itemId));

	if(item < 0)
	{
		buy_item(id, 1);

		cod_print_chat(id, "Przedmiot zostal juz kupiony lub wycofany z rynku!");

		return PLUGIN_HANDLED;
	}

	new marketItem[items];

	ArrayGetArray(marketItems, item, marketItem);
	
	switch(marketItem[TYPE])
	{
		case 0:
		{
			if(cs_get_user_money(id) < marketItem[PRICE])
			{
				cod_print_chat(id, "Nie masz wystarczajacej ilosci kasy!");

				return PLUGIN_HANDLED;
			}
			else
			{
				cs_set_user_money(marketItem[OWNER], cs_get_user_money(marketItem[OWNER]) + marketItem[PRICE]);
				cs_set_user_money(id, cs_get_user_money(id) - marketItem[PRICE]);
			}
		}
		case 1:
		{
			if(cod_get_user_honor(id) < marketItem[PRICE])
			{
				cod_print_chat(id, "Nie masz wystarczajacej ilosci honoru!");

				return PLUGIN_HANDLED;
			}
			else
			{
				cod_set_user_honor(marketItem[OWNER], cod_get_user_honor(marketItem[OWNER]) + marketItem[PRICE]);
				cod_set_user_honor(id, cod_get_user_honor(id) - marketItem[PRICE]);
			}
		}
	}

	new itemDescription[64];
	
	ArrayDeleteItem(marketItems, item);
	
	cod_set_user_item(id, marketItem[ITEM], marketItem[VALUE]);

	cod_get_item_desc(marketItem[ITEM], itemDescription, charsmax(itemDescription));
	
	cod_print_chat(id, "Przedmiot^x03 %s^x01 zostal pomyslnie zakupiony.", itemDescription);
	cod_print_chat(marketItem[OWNER], "Twoj przedmiot^x03 %s zostal zakupiony przez^x03 %s^x01. Otrzymujesz^x03 %i%s^x01.", marketItem[NAME], playerName[id], marketItem[PRICE], marketItem[TYPE] ? " Honoru" : "$");
	
	return PLUGIN_CONTINUE;
}

public withdraw_item(id, sound)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	if(!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new marketItem[items], itemData[128], itemId[2], itemsCounts = 0, menu = menu_create("\wWycofaj \rPrzedmiot", "withdraw_item_handle");
	
	for(new i = 0; i < ArraySize(marketItems); i++)
	{
		ArrayGetArray(marketItems, i, marketItem);
		
		if(marketItem[OWNER] != id) continue;

		num_to_str(marketItem[ID], itemId, charsmax(itemId));
		
		formatex(itemData, charsmax(itemData), "\w%s \y(%i/%i Wytrzymalosci) \r(%i%s)", marketItem[NAME], marketItem[DURABILITY], cod_max_item_durability(), marketItem[PRICE], marketItem[TYPE] ? " Honoru" : "$");
		
		menu_additem(menu, itemData, itemId);

		itemsCounts++;
	}

	if(!itemsCounts)
	{
		menu_destroy(menu);

		cod_print_chat(id, "Na rynku nie ma zadnych twoich przedmiotow!");
	}
	else menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public withdraw_item_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT || item)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new itemId[2], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemId, charsmax(itemId), _, _, itemCallback);

	new item = check_item_id(str_to_num(itemId));

	if(item < 0)
	{
		buy_item(id, 1);

		cod_print_chat(id, "Przedmiot zostal juz kupiony!");

		return PLUGIN_HANDLED;
	}
	
	new marketItem[items], menuData[512], itemDescription[64], length = 0, maxLength = sizeof(menuData) - 1;

	ArrayGetArray(marketItems, item, marketItem);
	
	cod_get_item_desc(marketItem[ITEM], itemDescription, charsmax(itemDescription));

	length += formatex(menuData[length], maxLength - length, "Potwierdzenie wycofania przedmiotu^n");
	length += formatex(menuData[length], maxLength - length, "\wItem: \y%s^n", marketItem[NAME]);
	length += formatex(menuData[length], maxLength - length, "\wOpis: \y%s^n", itemDescription);
	length += formatex(menuData[length], maxLength - length, "\wKoszt: \y%d%s^n", marketItem[PRICE], marketItem[TYPE] ? " Honoru" : "$");
	length += formatex(menuData[length], maxLength - length, "\wWytrzymalosc: \y%d/%i^n^n", marketItem[DURABILITY], cod_max_item_durability());
	length += formatex(menuData[length], maxLength - length, "\wCzy chcesz \rwycofac\w ten przedmiot?");
	
	new menu = menu_create(menuData, "withdraw_question_handle");
	
	menu_additem(menu, "Tak", itemId);
	menu_additem(menu, "Nie");

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);

	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public withdraw_question_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT || item)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new itemId[2], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemId, charsmax(itemId), _, _, itemCallback);

	new item = check_item_id(str_to_num(itemId));

	if(item < 0)
	{
		withdraw_item(id, 1);

		cod_print_chat(id, "Przedmiot zostal juz kupiony!");

		return PLUGIN_HANDLED;
	}

	new marketItem[items];

	ArrayGetArray(marketItems, item, marketItem);
	
	cod_set_user_item(id, marketItem[ITEM], marketItem[VALUE]);

	ArrayDeleteItem(marketItems, item);
	
	cod_print_chat(id, "Przedmiot^x03 %s^x01 zostal pomyslnie wycofany z rynku.", marketItem[NAME]);
	
	return PLUGIN_HANDLED;
}

stock get_items_amount(id) 
{
	if(!is_user_connected(id)) return 0;

	new amount = 0, marketItem[items];
	
	for(new i = 0; i < ArraySize(marketItems); i++) 
	{
		ArrayGetArray(marketItems, i, marketItem);

		if(marketItem[OWNER] == id) amount++;
	}
	
	return amount;
}

stock check_item_id(item)
{
	new marketItem[items];
	
	for(new i = 0; i < ArraySize(marketItems); i++) 
	{
		ArrayGetArray(marketItems, i, marketItem);

		if(marketItem[ID] == item) return i;
	}
	
	return -1;
}

stock remove_seller(id)
{
	new marketItem[items];
	
	for(new i = 0; i < ArraySize(marketItems); i++) 
	{
		ArrayGetArray(marketItems, i, marketItem);

		if(marketItem[OWNER] == id) 
		{
			ArrayDeleteItem(marketItems, i);

			i -= 1;
		}
	}
}