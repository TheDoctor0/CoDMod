#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Exchange"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const commandExchange[][] = { "say /exchange", "say_team /exchange", "say /zamien", "say_team /zamien", "say /wymien", "say_team /wymien", "wymien" };
new const commandGive[][] = { "say /give", "say_team /give", "say /oddaj", "say_team /oddaj", "say /daj", "say_team /daj", "daj" };

new blockExchange, cooldown, exchangeId[MAX_PLAYERS + 1], giveId[MAX_PLAYERS + 1];

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof commandExchange; i++) register_clcmd(commandExchange[i], "exchange_menu");
		
	for(new i; i < sizeof commandGive; i++) register_clcmd(commandGive[i], "give_item");
}

public cod_new_round()
	for(new i = 1; i <= MAX_PLAYERS; i++) rem_bit(i, cooldown);
	
public exchange_menu(id)
{
	client_cmd(id, "spk CodMod/select");
	
	new menuData[64], menu = menu_create("\wMenu \rWymiany", "exchange_menu_handle");
	
	menu_additem(menu, "Wymien \yPrzedmiot^n");
	
	formatex(menuData, charsmax(menuData), "Propozycje \yWymiany \d[\r%s\d]", get_bit(id, blockExchange) ? "Zablokowane" : "Odblokowane");
	menu_additem(menu, menuData);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	
	menu_display(id, menu);
}

public exchange_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
	
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
			exchange_item(id);

			menu_destroy(menu);

			return PLUGIN_HANDLED;
		}
		case 1:
		{
			if(get_bit(id, blockExchange))
			{
				rem_bit(id, blockExchange);

				cod_print_chat(id, "^x03Odblokowales^x01 mozliwosc wysylania ci propozycji wymiany przedmiotu!");
			}
			else
			{
				set_bit(id, blockExchange);

				cod_print_chat(id, "^x03Zablokowales^x01 mozliwosc wysylania ci propozycji wymiany przedmiotu!");
			}
		}		
	}

	return PLUGIN_CONTINUE;
}

public exchange_item(id)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	new menuData[128], playerName[64], itemName[64], menu = menu_create("\wWymien \rPrzedmiot", "exchange_item_handle");
	
	for(new i = 0, j = 0; i <= 32; i++)
	{
		if(!is_user_connected(i) || id == i || !cod_get_user_class(i) || !cod_get_user_item(i) || get_bit(id, blockExchange)) continue;

		exchangeId[j++] = i;

		cod_get_item_name(cod_get_user_item(id), itemName, charsmax(itemName));
		get_user_name(id, playerName, charsmax(playerName));

		formatex(menuData, charsmax(menuData), "%s \y(%s)", playerName, itemName);

		menu_additem(menu, menuData);
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	
	menu_display(id, menu);

	return PLUGIN_CONTINUE;
}

public exchange_item_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);

		return PLUGIN_CONTINUE;
	}
	
	if(!is_user_connected(exchangeId[item]))
	{
		cod_print_chat(id, "Wybranego gracza nie ma juz na serwerze.");

		return PLUGIN_CONTINUE;
	}
	
	if(get_bit(exchangeId[item], cooldown))
	{
		cod_print_chat(id, "Wybrany gracz musi poczekac^x03 1 runde^x01, aby wymienic sie przedmiotem.");

		return PLUGIN_CONTINUE;
	}
	
	if(get_bit(id, cooldown))
	{
		cod_print_chat(id, "Musisz poczekac^x03 1 runde^x01, aby wymienic sie tym przedmiotem.");

		return PLUGIN_CONTINUE;
	}
	
	if(!cod_get_user_item(exchangeId[item]))
	{
		cod_print_chat(id, "Wybrany gracz nie ma zadnego przedmiotu.");

		return PLUGIN_CONTINUE;
	}
	
	if(!cod_get_user_item(id))
	{
		cod_print_chat(id, "Nie masz zadnego przedmiotu.");

		return PLUGIN_CONTINUE;
	}

	new menuData[128], playerName[64], itemName[64];
	
	cod_get_item_name(cod_get_user_item(id), itemName, charsmax(itemName));
	get_user_name(id, playerName, charsmax(playerName));
	
	formatex(menuData, charsmax(menuData), "Wymien sie przedmiotem z %s (%s):", playerName, itemName);
	
	new menu = menu_create(menuData, "exchange_item_question");

	menu_additem(menu, "Tak", playerName);
	menu_additem(menu, "Nie", playerName);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	menu_display(exchangeId[item], menu);
	
	return PLUGIN_CONTINUE;
}

public exchange_item_question(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);

		return PLUGIN_CONTINUE;
	}
	
	new playerName[64], itemAccess, itemCallback;
	
	menu_item_getinfo(menu, item, itemAccess, playerName, charsmax(playerName), _, _, itemCallback);
	
	new player = get_user_index(playerName);
	
	if(!is_user_connected(player))
	{
		cod_print_chat(id, "Gracza proponujacego wymiane nie ma juz na serwerze.");

		return PLUGIN_CONTINUE;
	}
	
	if(get_bit(player, cooldown))
	{
		cod_print_chat(id, "Gracz proponujacy wymiane musi poczekac^x03 1 runde^x01, aby wymienic sie przedmiotem.");

		return PLUGIN_CONTINUE;
	}
	
	if(!cod_get_user_item(player))
	{
		cod_print_chat(id, "Gracz proponujacy wymiane nie ma juz przedmiotu.");

		return PLUGIN_CONTINUE;
	}
	
	if(!cod_get_user_item(id))
	{
		cod_print_chat(id, "Nie masz zadnego przedmiotu.");

		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0: 
		{ 
			new name[64], itemName[64], playerItemName[64],
				playerItemValue, playerItemId = cod_get_user_item(player, playerItemValue), itemValue, itemId = cod_get_user_item(id, itemValue), 
				playerItemDurability = cod_get_item_durability(player), itemDurability = cod_get_item_durability(id);

			get_user_name(id, name, charsmax(name));

			cod_get_item_name(cod_get_user_item(player), playerItemName, charsmax(playerItemName));
			cod_get_item_name(cod_get_user_item(id), itemName, charsmax(itemName));

			cod_set_user_item(player, itemId);
			cod_set_user_item(id, playerItemId);

			cod_set_item_durability(player, itemDurability);
			cod_set_item_durability(id, playerItemDurability);

			set_bit(player, cooldown);
			set_bit(id, cooldown);

			cod_print_chat(player, "Wymieniles sie przedmiotem z^x03 %s^x01. Otrzymales^x03 %s^x01.", name, playerItemName);
			cod_print_chat(id, "Wymieniles sie przedmiotem z^x03 %s^x01. Otrzymales^x03 %s^x01.", playerName, itemName);
		}
		case 1: cod_print_chat(player, "Wybrany gracz nie zgodzil sie na wymiane przedmiotami.");
	}
	return PLUGIN_CONTINUE;
}

public give_item(id)
{
	client_cmd(id, "spk CodMod/select");
	
	new playerName[64], menu = menu_create("\wOddaj \rPrzedmiot", "give_item_handle");
	
	for(new i = 0, n = 0; i <= 32; i++)
	{
		if(!is_user_connected(i) || i == id || !cod_get_user_class(i) || cod_get_user_item(i)) continue;

		giveId[n++] = i;
		
		get_user_name(i, playerName, charsmax(playerName));
		
		menu_additem(menu, playerName);
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	
	menu_display(id, menu);
}

public give_item_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);

		return PLUGIN_CONTINUE;
	}
	
	if(!is_user_connected(giveId[item]))
	{
		cod_print_chat(id, "Wybranego gracza nie ma juz na serwerze.");

		return PLUGIN_CONTINUE;
	}
	
	if(get_bit(id, cooldown))
	{
		cod_print_chat(id, "Musisz poczekac^x03 1 runde^x01, aby oddac ten przedmiot.");

		return PLUGIN_CONTINUE;
	}
	
	if(cod_get_user_item(giveId[id]))
	{
		cod_print_chat(id, "Wybrany gracz ma juz przedmiot.");

		return PLUGIN_CONTINUE;
	}
	
	new itemValue, itemId = cod_get_user_item(id, itemValue), itemDurability = cod_get_item_durability(id);
	
	if(!itemId)
	{
		cod_print_chat(id, "Nie masz zadnego przedmiotu.");

		return PLUGIN_CONTINUE;
	}
	
	new name[64], playerName[64], itemName[64];
	
	get_user_name(id, name, charsmax(name));
	get_user_name(giveId[item], playerName, charsmax(playerName));

	cod_get_item_name(cod_get_user_item(id), itemName, charsmax(itemName));
	
	set_bit(giveId[item], cooldown);
	
	cod_set_user_item(giveId[item], itemId, itemValue);
	cod_set_item_durability(giveId[item], itemDurability);
	cod_set_user_item(id);
	
	cod_print_chat(id, "Oddales przedmiot^x03 %s^x01 graczowi^x03 %s^x01.", name, itemName);
	cod_print_chat(giveId[item], "Dostales przedmiot^x03 %s^x01 od gracza^x03 %s^x01.", playerName, itemName);
	
	return PLUGIN_CONTINUE;
}