#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Exchange"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define Set(%2,%1)	(%1 |= (1<<(%2&31)))
#define Rem(%2,%1)	(%1 &= ~(1 <<(%2&31)))
#define Get(%2,%1)	(%1 & (1<<(%2&31)))

#define MAX_PLAYERS 32

new const szCommandExchange[][] = { "say /exchange", "say_team /exchange", "say /zamien", "say_team /zamien", "say /wymien", "say_team /wymien", "wymien" };
new const szCommandGive[][] = { "say /give", "say_team /give", "say /oddaj", "say_team /oddaj", "say /daj", "say_team /daj", "daj" };

new iReceived, iBlock, iExchangeID[MAX_PLAYERS + 1], iGiveID[MAX_PLAYERS + 1];

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof szCommandExchange; i++)
		register_clcmd(szCommandExchange[i], "ExchangeMenu");
		
	for(new i; i < sizeof szCommandGive; i++)
		register_clcmd(szCommandGive[i], "GiveItem");
	
	register_event("ResetHUD", "cod_perk_changed", "abe");
}

public cod_perk_changed(id)
	Rem(id, iReceived);
	
public ExchangeMenu(id)
{
	client_cmd(id, "spk CodMod/select");
	
	new menu = menu_create("\wMenu \rWymiany", "ExchangeMenu_Handle");
	
	menu_additem(menu, "Wymien \yItem^n");
	
	new szTemp[64];
	formatex(szTemp, charsmax(szTemp), "Propozycje \yWymiany \d[\r%s\d]", Get(id, iBlock) ? "Zablokowane" : "Odblokowane");
	menu_additem(menu, szTemp);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	
	menu_display(id, menu);
}

public ExchangeMenu_Handle(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0:
		{
			ExchangeItem(id);
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
		case 1:
		{
			if(Get(id, iBlock))
			{
				Rem(id, iBlock);
				cod_print_chat(id, DontChange, "^x03Odblokowales^x01 mozliwosc wysylania ci propozycji wymiany itemu!");
			}
			else
			{
				Set(id, iBlock);
				cod_print_chat(id, DontChange, "^x03Zablokowales^x01 mozliwosc wysylania ci propozycji wymiany itemu!");
			}
		}		
	}
	return PLUGIN_CONTINUE;
}

public ExchangeItem(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	new menu = menu_create("\wWymien \rItem", "ExchangeItem_Handle");
	
	for(new i = 0, j = 0; i <= 32; i++)
	{
		if(!is_user_connected(i) || id == i || !cod_get_user_class(i) || !cod_get_user_item(i) || Get(id, iBlock))
			continue;

		iExchangeID[j++] = i;
		
		new szTemp[128], szName[64], szItem[33];

		cod_get_item_name(cod_get_user_item(id), szItem, charsmax(szItem));
		get_user_name(id, szName, charsmax(szName));

		formatex(szTemp, charsmax(szTemp), "%s \y(%s)", szName, szItem);

		menu_additem(menu, szTemp);
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}

public ExchangeItem_Handle(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	if(!is_user_connected(iExchangeID[item]))
	{
		cod_print_chat(id, DontChange, "Wybranego gracza nie ma juz na serwerze.");
		return PLUGIN_CONTINUE;
	}
	
	if(Get(iExchangeID[item], iReceived))
	{
		cod_print_chat(id, DontChange, "Wybrany gracz musi poczekac^x03 1 runde^x01.");
		return PLUGIN_CONTINUE;
	}
	
	if(Get(id, iReceived))
	{
		cod_print_chat(id, DontChange, "Musisz poczekac^x03 1 runde^x01.");
		return PLUGIN_CONTINUE;
	}
	
	if(!cod_get_user_item(iExchangeID[item]))
	{
		cod_print_chat(id, DontChange, "Wybrany gracz nie ma zadnego itemu.");
		return PLUGIN_CONTINUE;
	}
	
	if(!cod_get_user_item(id))
	{
		cod_print_chat(id, DontChange, "Nie masz zadnego itemu.");
		return PLUGIN_CONTINUE;
	}

	new szTemp[128], szName[64], szItem[33];
	
	cod_get_item_name(cod_get_user_item(id), szItem, charsmax(szItem));
	get_user_name(id, szName, charsmax(szName));
	
	formatex(szTemp, charsmax(szTemp), "Wymien sie itemem z %s (Item: %s):", szName, szItem);
	
	new menu = menu_create(szTemp, "ExchangeItemQuestion");

	menu_additem(menu, "Tak", szName);
	menu_additem(menu, "Nie", szName);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	menu_display(iExchangeID[item], menu);
	
	return PLUGIN_CONTINUE;
}

public ExchangeItemQuestion(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	new szPlayer[64], iAccess, iCallback;
	
	menu_item_getinfo(menu, item, iAccess, szPlayer, charsmax(szPlayer), _, _, iCallback);
	
	new player = get_user_index(szPlayer);
	
	if(!is_user_connected(player))
	{
		cod_print_chat(id, DontChange, "Gracza proponujacy wymiane nie ma juz na serwerze.");
		return PLUGIN_CONTINUE;
	}
	
	if(Get(player, iReceived))
	{
		cod_print_chat(id, DontChange, "Gracz proponujacy wymiane musi poczekac^x03 1 runde^x01.");
		return PLUGIN_CONTINUE;
	}
	
	if(!cod_get_user_item(player))
	{
		cod_print_chat(id, DontChange, "Gracz proponujacy wymiane juz nie ma itemu.");
		return PLUGIN_CONTINUE;
	}
	
	if(!cod_get_user_item(id))
	{
		cod_print_chat(id, DontChange, "Nie masz zadnego itemu.");
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0: 
		{ 
			new iPlayerItem = cod_get_user_item(player);
			new iItem = cod_get_user_item(id);
			new iPlayerDurability = cod_get_item_durability(player);
			new iDurability = cod_get_item_durability(id);

			cod_set_user_item(player, iItem);
			cod_set_user_item(id, iPlayerItem);
			cod_set_item_durability(player, iDurability);
			cod_set_item_durability(id, iPlayerDurability);

			Set(player, iReceived);
			Set(id, iReceived);

			new szName[64];
			
			get_user_name(id, szName, charsmax(szName));

			cod_print_chat(id, DontChange, "Wymieniles sie itemem z^x03 %s^x01.", szPlayer);
			cod_print_chat(player, DontChange, "Wymieniles sie itemem z^x03 %s^x01.", szName);
		}
		case 1: cod_print_chat(player, DontChange, "Wybrany gracz nie zgodzil sie na wymiane itemami.");
	}
	return PLUGIN_CONTINUE;
}

public GiveItem(id)
{
	client_cmd(id, "spk CodMod/select");
	
	new menu = menu_create("\wOddaj \rItem", "GiveItem_Handle");
	
	for(new i = 0, n = 0; i <= 32; i++)
	{
		if(!is_user_connected(i) || i == id || !cod_get_user_class(i) || cod_get_user_item(i))
			continue;

		iGiveID[n++] = i;
		
		new szName[64];
		
		get_user_name(i, szName, charsmax(szName));
		
		menu_additem(menu, szName);
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	
	menu_display(id, menu);
}

public GiveItem_Handle(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	if(!is_user_connected(iGiveID[item]))
	{
		cod_print_chat(id, DontChange, "Wybranego gracza nie ma juz na serwerze.");
		return PLUGIN_CONTINUE;
	}
	
	if(Get(id, iReceived))
	{
		cod_print_chat(id, DontChange, "Musisz poczekac^x03 1 runde^x01.");
		return PLUGIN_CONTINUE;
	}
	
	if(cod_get_user_item(iGiveID[id]))
	{
		cod_print_chat(id, DontChange, "Wybrany gracz ma juz item.");
		return PLUGIN_CONTINUE;
	}
	
	new iItem, iValue = cod_get_user_item(id, iValue);
	new iDurability = cod_get_item_durability(id);
	
	if(!iItem)
	{
		cod_print_chat(id, DontChange, "Nie masz zadnego perku.");
		return PLUGIN_CONTINUE;
	}
	
	new szName[64], szPlayer[64];
	
	get_user_name(id, szName, 63);
	get_user_name(iGiveID[item], szPlayer, 63);
	
	Set(iGiveID[item], iReceived);
	
	cod_set_user_item(iGiveID[item], iItem, iValue, 0);
	cod_set_item_durability(iGiveID[item], iDurability);
	cod_set_user_item(id, 0);
	
	cod_print_chat(id, DontChange, "Oddales item graczowi^x03 %s^x01.", szPlayer);
	cod_print_chat(iGiveID[item], DontChange, "Dostales item od gracza %s.", szName);
	
	return PLUGIN_CONTINUE;
}