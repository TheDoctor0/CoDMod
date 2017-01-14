#include <amxmodx>
#include <cod>
#include <cstrike>

#define PLUGIN "CoD Market"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define Set(%2,%1)	(%1 |= (1<<(%2&31)))
#define Rem(%2,%1)	(%1 &= ~(1 <<(%2&31)))
#define Get(%2,%1)	(%1 & (1<<(%2&31)))

#define MAX_PLAYERS 32
#define MAX_ITEMS 5

enum _:Item { ID = 0, ITEM, VALUE, DURABILITY, OWNER, TYPE, PRICE, NAME[32] };

new const szCommandMarket[][] = { "say /market", "say_team /market", "say /rynek", "say_team /rynek", "rynek" };
new const szCommandSell[][] = { "say /sell", "say_team /sell", "say /wystaw", "say_team /wystaw", "say /sprzedaj", "say_team /sprzedaj", "sprzedaj" };
new const szCommandBuy[][] = { "say /buy", "say_team /buy", "say /kup", "say_team /kup", "kup" };
new const szCommandWithdraw[][] = { "say /withdraw", "say_team /withdraw", "say /wycofaj", "say_team /wycofaj", "wycofaj" };

new Array:gItems;

new iUniqueID;

new szPlayer[MAX_PLAYERS + 1][64], iPriceType[MAX_PLAYERS + 1];

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof szCommandMarket; i++)
		register_clcmd(szCommandMarket[i], "MarketMenu");

	for(new i; i < sizeof szCommandSell; i++)
		register_clcmd(szCommandSell[i], "SellItem");
	
	for(new i; i < sizeof szCommandBuy; i++)
		register_clcmd(szCommandBuy[i], "BuyItem");
	
	for(new i; i < sizeof szCommandWithdraw; i++)
		register_clcmd(szCommandWithdraw[i], "WithdrawItem");

	register_concmd("Wpisz_Cene_Itemu", "SetItemPrice");
	
	gItems = ArrayCreate(Item);
}

public client_disconnect(id)
	RemoveSeller(id);

public client_connect(id)
	get_user_name(id, szPlayer[id], charsmax(szPlayer));

public MarketMenu(id)
{
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
	
	client_cmd(id, "spk CodMod/select");
	
	new menu = menu_create("\wMenu \rRynku", "MarketMenu_Handle");
	new callback = menu_makecallback("MarketMenu_Callback");
	
	menu_additem(menu, "Wystaw \yItem", _, _, callback);
	menu_additem(menu, "Kup \yItem", _, _, callback);
	menu_additem(menu, "Wycofaj \yItem", _, _, callback);
	
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public MarketMenu_Handle(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select");
	
	if(item == MENU_EXIT)	
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	switch(item)	
	{
		case 0: SellItem(id);	
		case 1: BuyItem(id);
		case 2: WithdrawItem(id);
	}
	return PLUGIN_CONTINUE;
}

public MarketMenu_Callback(id, menu, item)
{
	switch(item)	
	{
		case 0: if(!cod_get_user_class(id) || !cod_get_user_item(id) || getItemsAmount(id) >= MAX_ITEMS) return ITEM_DISABLED;
		case 1: if(!ArraySize(gItems)) return ITEM_DISABLED;
		case 2: if(!getItemsAmount(id)) return ITEM_DISABLED;
	}
	return ITEM_ENABLED;
}

public SellItem(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
		
	client_cmd(id, "spk CodMod/select");
	
	new menu = menu_create("\wRodzaj \rOferty", "SellItem_Handle");
	
	menu_additem(menu, "Za \yDolary");
	menu_additem(menu, "Za \yHonor");
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_setprop(menu, MPROP_EXIT, 0);
	
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public SellItem_Handle(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	iPriceType[id] = item;
	
	if(!cod_get_user_item(id))	
	{
		MarketMenu(id);
		cod_print_chat(id, DontChange, "Nie masz zadnego itemu!");
		return PLUGIN_CONTINUE;
	}
	
	if(getItemsAmount(id) >= MAX_ITEMS)	
	{
		MarketMenu(id);
		cod_print_chat(id, DontChange, "Wystawiles juz %i itemow!", MAX_ITEMS);
		return PLUGIN_CONTINUE;
	}
	
	client_cmd(id, "messagemode Wpisz_Cene_Itemu");
	
	cod_print_chat(id, DontChange, "Wpisz cene, za ktora chcesz sprzedac item.");
	
	return PLUGIN_CONTINUE;
}

public SetItemPrice(id)
{
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
	
	new szMessage[16], szTemp[16], iPrice;
	
	read_argv(1, szMessage, charsmax(szMessage));
	format(szTemp, charsmax(szTemp), "%s", szMessage);
	
	iPrice = str_to_num(szTemp);
	
	if(iPrice > 0 && iPrice < 100000)	
	{
		SellItem(id);
		cod_print_chat(id, DontChange, "Cena musi nalezec do przedzialu 1 - 99999!");
		return PLUGIN_CONTINUE;
	}
	
	new aItem[Item];
	
	aItem[ID] = iUniqueID++;
	aItem[ITEM] = cod_get_user_item(id, aItem[VALUE]);
	aItem[DURABILITY] = cod_get_item_durability(id);
	aItem[OWNER] = id;
	aItem[TYPE] = iPriceType[id];
	aItem[PRICE] = iPrice;
	cod_get_item_name(cod_get_user_item(id), aItem[NAME], charsmax(aItem[NAME]));
	
	ArrayPushArray(gItems, aItem);
	
	cod_set_user_item(id, 0);
	
	cod_print_chat(0, DontChange, "^x03%s^x01 wystawil na rynek^x03 %s^x01 za^x03 %i %s^x01.", szPlayer[id], aItem[NAME], aItem[PRICE], aItem[TYPE] ? "Honoru" : "$");
	
	return PLUGIN_CONTINUE;
}

public BuyItem(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
	
	client_cmd(id, "spk CodMod/select");
	
	new menu = menu_create("\wKup \rItem", "BuyItem_Handle");
	
	new szTemp[128], szData[2];
	
	for(new i = 0; i < ArraySize(gItems); i++)
	{		
		new aItem[Item];
		
		ArrayGetArray(gItems, i, aItem);
		
		if(aItem[OWNER] == id)
			continue;
		
		szData[0] = i;
		szData[1] = aItem[ID];
		
		formatex(szTemp, charsmax(szTemp), "\w%s \y(%i/%i Wytrzymalosci) \r(%i %s)", aItem[NAME], aItem[DURABILITY], cod_max_item_durability(), aItem[PRICE], aItem[TYPE] ? "H" : "$");
		
		menu_additem(menu, szTemp, szData);
	}
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public BuyItem_Handle(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	new szText[512], szDesc[64], iLen = 0, iMax = sizeof(szText) - 1, aItem[Item];
	
	new szData[2], iAccesss, iCallback;
	menu_item_getinfo(menu, item, iAccesss, szData, charsmax(szData), _, _, iCallback);
	
	ArrayGetArray(gItems, item, aItem);
	
	cod_get_item_desc(aItem[ITEM], szDesc, charsmax(szDesc));

	iLen += formatex(szText[iLen], iMax - iLen, "Potwierdzenie kupna itemu od: \r%s^n", szPlayer[aItem[OWNER]]);
	iLen += formatex(szText[iLen], iMax - iLen, "\yItem: \r%s^n", aItem[NAME]);
	iLen += formatex(szText[iLen], iMax - iLen, "\yOpis: \r%s^n", szDesc);
	iLen += formatex(szText[iLen], iMax - iLen, "\yKoszt: \r%d %s^n", aItem[PRICE], aItem[TYPE] ? "H" : "$");
	iLen += formatex(szText[iLen], iMax - iLen, "\yWytrzymalosc: \r%d/%i^n^n", aItem[DURABILITY], cod_max_item_durability());
	iLen += formatex(szText[iLen], iMax - iLen, "\wCzy chcesz kupic ten item?");
	
	new menu = menu_create(szText, "BuyQuestion_Handle");
	
	menu_additem(menu, "Tak", szData);
	menu_additem(menu, "Nie");

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public BuyQuestion_Handle(id, menu, item)
{
	if(item == MENU_EXIT || item)
	{
		BuyItem(id);
		return PLUGIN_CONTINUE;
	}
	
	new szData[2], iAccesss, iCallback;
	menu_item_getinfo(menu, item, iAccesss, szData, charsmax(szData), _, _, iCallback);
	
	new aItem[Item], aItemID = szData[0];
	
	ArrayGetArray(gItems, aItemID, aItem);
	
	if(szData[1] != aItem[ID])
	{
		BuyItem(id);
		cod_print_chat(id, DontChange, "Item zostal juz kupiony lub wycofany z rynku!");
		return PLUGIN_CONTINUE;
	}	
	
	switch(aItem[TYPE])
	{
		case 0:
		{
			if(cs_get_user_money(id) < aItem[PRICE])
			{
				cod_print_chat(id, DontChange, "Nie masz wystarczajacej ilosci kasy!");
				return PLUGIN_CONTINUE;
			}
			else
			{
				cs_set_user_money(aItem[OWNER], cs_get_user_money(aItem[OWNER]) + aItem[PRICE]);
				cs_set_user_money(id, cs_get_user_money(id) - aItem[PRICE]);
			}
		}
		case 1:
		{
			if(cod_get_user_honor(id) < aItem[PRICE])
			{
				cod_print_chat(id, DontChange, "Nie masz wystarczajacej ilosci honoru!");
				return PLUGIN_CONTINUE;
			}
			else
			{
				cod_set_user_honor(aItem[OWNER], cod_get_user_honor(aItem[OWNER]) + aItem[PRICE]);
				cod_set_user_honor(id, cod_get_user_honor(id) - aItem[PRICE]);
			}
		}
	}
	
	ArrayDeleteItem(gItems, aItemID);
	
	cod_set_user_item(id, aItem[ITEM], aItem[VALUE]);
	
	cod_print_chat(id, DontChange, "Item^x03 %s^x01 zostal pomyslnie zakupiony.", aItem);
	cod_print_chat(aItem[OWNER], DontChange, "Twoj item^x03 %s zostal zakupiony przez^x03 %s^x01. Otrzymujesz^x03 %i %s^x01.", aItem[NAME], szPlayer[id], aItem[PRICE], aItem[TYPE] ? "Honoru" : "$");
	
	return PLUGIN_CONTINUE;
}

public WithdrawItem(id)
{		
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
	
	client_cmd(id, "spk CodMod/select");
	
	new menu = menu_create("\wTwoje \rOferty", "WithdrawItem_Handle");
	
	new szTemp[128], szData[2];
	
	for(new i = 0; i < ArraySize(gItems); i++)
	{		
		new aItem[Item];
		
		ArrayGetArray(gItems, i, aItem);
		
		if(aItem[OWNER] != id)
			continue;
		
		szData[0] = i;
		szData[1] = aItem[ID];
		
		formatex(szTemp, charsmax(szTemp), "\w%s \y(%i/%i Wytrzymalosci) \r(%i %s)", aItem[NAME], aItem[DURABILITY], cod_max_item_durability(), aItem[PRICE], aItem[TYPE] ? "H" : "$");
		
		menu_additem(menu, szTemp, szData);
	}
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public WithdrawItem_Handle(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	new szText[512], szDesc[64], iLen = 0, iMax = sizeof(szText) - 1, aItem[Item];
	
	new szData[2], iAccesss, iCallback;
	menu_item_getinfo(menu, item, iAccesss, szData, charsmax(szData), _, _, iCallback);
	
	ArrayGetArray(gItems, item, aItem);
	
	cod_get_item_desc(aItem[ITEM], szDesc, charsmax(szDesc));

	iLen += formatex(szText[iLen], iMax - iLen, "Potwierdzenie wycofania itemu^n");
	iLen += formatex(szText[iLen], iMax - iLen, "\yItem: \r%s^n", aItem[NAME]);
	iLen += formatex(szText[iLen], iMax - iLen, "\yOpis: \r%s^n", szDesc);
	iLen += formatex(szText[iLen], iMax - iLen, "\yKoszt: \r%d %s^n", aItem[PRICE], aItem[TYPE] ? "H" : "$");
	iLen += formatex(szText[iLen], iMax - iLen, "\yWytrzymalosc: \r%d/%i^n^n", aItem[DURABILITY], cod_max_item_durability());
	iLen += formatex(szText[iLen], iMax - iLen, "\wCzy chcesz \rwycofac ten item?");
	
	new menu = menu_create(szText, "WithdrawQuestion_Handle");
	
	menu_additem(menu, "Tak", szData);
	menu_additem(menu, "Nie");

	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public WithdrawQuestion_Handle(id, menu, item)
{
	if(item == MENU_EXIT || item)
	{
		WithdrawItem(id);
		return PLUGIN_CONTINUE;
	}
	
	new szData[2], iAccesss, iCallback;
	menu_item_getinfo(menu, item, iAccesss, szData, charsmax(szData), _, _, iCallback);
	
	new aItem[Item], aItemID = szData[0];
	
	ArrayGetArray(gItems, aItemID, aItem);
	
	if(szData[1] != aItem[ID])
	{
		WithdrawItem(id);
		cod_print_chat(id, DontChange, "Item zostal juz kupiony!");
		return PLUGIN_CONTINUE;
	}	
	
	ArrayDeleteItem(gItems, aItemID);
	
	cod_set_user_item(id, aItem[ITEM], aItem[VALUE]);
	
	cod_print_chat(id, DontChange, "Item zostal pomyslnie wycofany z rynku.");
	
	return PLUGIN_CONTINUE;
}

stock getItemsAmount(id) 
{
	if(!is_user_connected(id))
		return 0;
		
	new iAmount = 0, aItem[Item];
	
	for(new i = 0; i < ArraySize(gItems); ++i) 
	{
		ArrayGetArray(gItems, i, aItem);
		if(id == aItem[OWNER])
			iAmount++;
	}
	
	return iAmount;
}

stock RemoveSeller(id)
{
	new aItem[Item];
	
	for(new i = 0; i < ArraySize(gItems); ++i) 
	{
		ArrayGetArray(gItems, i, aItem);
		if(id == aItem[OWNER]) 
		{
			ArrayDeleteItem(gItems, i);
			i -= 1;
		}
	}
}