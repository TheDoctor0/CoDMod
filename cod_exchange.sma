#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Exchange"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const commandExchange[][] = { "say /exchange", "say_team /exchange", "say /zamien", "say_team /zamien", "say /wymien", "say_team /wymien", "wymien" };
new const commandGive[][] = { "say /give", "say_team /give", "say /oddaj", "say_team /oddaj", "say /daj", "say_team /daj", "daj" };

new maxPlayers, blockExchange, cooldown;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof commandExchange; i++) register_clcmd(commandExchange[i], "exchange_menu");
		
	for(new i; i < sizeof commandGive; i++) register_clcmd(commandGive[i], "give_item");

	maxPlayers = get_maxplayers();
}

public cod_new_round()
	for(new i = 1; i <= MAX_PLAYERS; i++) rem_bit(i, cooldown);
	
public exchange_menu(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menuData[64], menu = menu_create("\yMenu \rWymiany", "exchange_menu_handle");
	
	menu_additem(menu, "Wymien \yPrzedmiot \r(/wymien)^n");
	
	formatex(menuData, charsmax(menuData), "Propozycje \yWymiany \d[\r%s\d]", get_bit(id, blockExchange) ? "Zablokowane" : "Odblokowane");
	
	menu_additem(menu, menuData);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public exchange_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);

		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	switch(item)
	{
		case 0: exchange_item(id, 1);
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

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public exchange_item(id, sound)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(!sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menuData[128], playerName[64], itemName[64], playerId[3], players, menu = menu_create("\yWymien \rPrzedmiot", "exchange_item_handle");

	for(new player = 1; player <= maxPlayers; player++)
	{
		if(!is_user_connected(player) || id == player || !cod_get_user_class(player) || !cod_get_user_item(player)) continue;
		
		cod_get_item_name(cod_get_user_item(id), itemName, charsmax(itemName));

		get_user_name(id, playerName, charsmax(playerName));
		
		formatex(menuData, charsmax(menuData), "%s \y(%s)", playerName, itemName);

		num_to_str(player, playerId, charsmax(playerId));
		
		menu_additem(menu, menuData, playerId);
		
		players++;
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");

	if(!players)
	{
		menu_destroy(menu);

		cod_print_chat(id, "Na serwerze nie ma gracza, z ktorym moglbys sie wymienic przedmiotem!");
	}
	else menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public exchange_item_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);

		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new playerId[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, playerId, charsmax(playerId), _, _, itemCallback);

	new player = str_to_num(playerId);

	menu_destroy(menu);
	
	if(!is_user_connected(player))
	{
		cod_print_chat(id, "Wybranego gracza nie ma juz na serwerze.");

		return PLUGIN_HANDLED;
	}
	
	if(get_bit(player, cooldown))
	{
		cod_print_chat(id, "Wybrany gracz musi poczekac^x03 1 runde^x01, aby wymienic sie przedmiotem.");

		return PLUGIN_HANDLED;
	}
	
	if(get_bit(id, cooldown))
	{
		cod_print_chat(id, "Musisz poczekac^x03 1 runde^x01, aby wymienic sie tym przedmiotem.");

		return PLUGIN_HANDLED;
	}
	
	if(!cod_get_user_item(player))
	{
		cod_print_chat(id, "Wybrany gracz nie ma zadnego przedmiotu.");

		return PLUGIN_HANDLED;
	}
	
	if(!cod_get_user_item(id))
	{
		cod_print_chat(id, "Nie masz zadnego przedmiotu.");

		return PLUGIN_HANDLED;
	}

	new menuData[128], playerName[64], itemName[64];
	
	cod_get_item_name(cod_get_user_item(id), itemName, charsmax(itemName));
	get_user_name(id, playerName, charsmax(playerName));
	
	formatex(menuData, charsmax(menuData), "\wWymien sie przedmiotem z \y%s \w(\r%s\w):", playerName, itemName);
	
	new menu = menu_create(menuData, "exchange_item_question");

	num_to_str(player, playerId, charsmax(playerId));

	menu_additem(menu, "Tak", playerId);
	menu_additem(menu, "Nie", playerId);
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(player, menu);
	
	return PLUGIN_HANDLED;
}

public exchange_item_question(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new playerId[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, playerId, charsmax(playerId), _, _, itemCallback);

	new player = str_to_num(playerId);

	menu_destroy(menu);
	
	if(!is_user_connected(player))
	{
		cod_print_chat(id, "Gracza proponujacego wymiane nie ma juz na serwerze.");

		return PLUGIN_HANDLED;
	}
	
	if(get_bit(player, cooldown))
	{
		cod_print_chat(id, "Gracz proponujacy wymiane musi poczekac^x03 1 runde^x01, aby wymienic sie przedmiotem.");

		return PLUGIN_HANDLED;
	}
	
	if(!cod_get_user_item(player))
	{
		cod_print_chat(id, "Gracz proponujacy wymiane nie ma juz przedmiotu.");

		return PLUGIN_HANDLED;
	}
	
	if(!cod_get_user_item(id))
	{
		cod_print_chat(id, "Nie masz zadnego przedmiotu.");

		return PLUGIN_HANDLED;
	}
	
	switch(item)
	{
		case 0: 
		{ 
			new name[64], playerName[64], itemName[64], playerItemName[64],
				playerItemValue, playerItemId = cod_get_user_item(player, playerItemValue), itemValue, itemId = cod_get_user_item(id, itemValue), 
				playerItemDurability = cod_get_item_durability(player), itemDurability = cod_get_item_durability(id);

			get_user_name(player, playerName, charsmax(playerName));
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

	return PLUGIN_HANDLED;
}

public give_item(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new playerName[64], playerId[3], players, menu = menu_create("\yOddaj \rPrzedmiot", "give_item_handle");

	for(new player = 1; player <= maxPlayers; player++)
	{
		if(!is_user_connected(player) || player == id || !cod_get_user_class(player) || cod_get_user_item(player)) continue;
		
		get_user_name(id, playerName, charsmax(playerName));

		num_to_str(player, playerId, charsmax(playerId));
		
		menu_additem(menu, playerName, playerId);
		
		players++;
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");

	if(!players)
	{
		menu_destroy(menu);

		cod_print_chat(id, "Na serwerze nie ma gracza, z ktoremu moglbys oddac przedmiot!");
	}
	else menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public give_item_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new playerId[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, playerId, charsmax(playerId), _, _, itemCallback);

	new player = str_to_num(playerId);

	menu_destroy(menu);
	
	if(!is_user_connected(player))
	{
		cod_print_chat(id, "Wybranego gracza nie ma juz na serwerze.");

		return PLUGIN_HANDLED;
	}
	
	if(get_bit(id, cooldown))
	{
		cod_print_chat(id, "Musisz poczekac^x03 1 runde^x01, aby oddac ten przedmiot.");

		return PLUGIN_HANDLED;
	}
	
	if(cod_get_user_item(player))
	{
		cod_print_chat(id, "Wybrany gracz ma juz przedmiot.");

		return PLUGIN_HANDLED;
	}

	if(!cod_get_user_item(id))
	{
		cod_print_chat(id, "Nie masz zadnego przedmiotu.");

		return PLUGIN_HANDLED;
	}
	
	new name[64], playerName[64], itemName[64],
		itemValue, itemId = cod_get_user_item(id, itemValue), itemDurability = cod_get_item_durability(id);
	
	get_user_name(id, name, charsmax(name));
	get_user_name(player, playerName, charsmax(playerName));

	cod_get_item_name(cod_get_user_item(id), itemName, charsmax(itemName));
	
	set_bit(player, cooldown);
	rem_bit(id, cooldown);
	
	cod_set_user_item(player, itemId, itemValue);
	cod_set_item_durability(player, itemDurability);
	cod_set_user_item(id);
	
	cod_print_chat(id, "Oddales przedmiot^x03 %s^x01 graczowi^x03 %s^x01.", name, itemName);
	cod_print_chat(player, "Dostales przedmiot^x03 %s^x01 od gracza^x03 %s^x01.", playerName, itemName);
	
	return PLUGIN_HANDLED;
}