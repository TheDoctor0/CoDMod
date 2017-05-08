#include <amxmodx>
#include <cstrike>
#include <cod>

#define PLUGIN "CoD Transfer"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const commandTransfer[][] = { "say /przelew", "say_team /przelew", "say /przelej", "say_team /przelej", "przelej" };
new const commandHonor[][] = { "say /przelewh", "say_team /przelewh", "say /przelejh", "say_team /przelejh", "przelejh" };
new const commandCash[][] = { "say /przelewc", "say_team /przelewc", "say /przelejc", "say_team /przelejc", "przelejc" };

new transferPlayer[MAX_PLAYERS + 1], maxPlayers;

public plugin_init() 
{  
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for(new i; i < sizeof commandTransfer; i++) register_clcmd(commandTransfer[i], "transfer_menu");
	for(new i; i < sizeof commandHonor; i++) register_clcmd(commandHonor[i], "transfer_honor_menu");
	for(new i; i < sizeof commandCash; i++) register_clcmd(commandCash[i], "transfer_cash_menu");

	register_clcmd("ILOSC_HONORU", "transfer_honor_handle");
	register_clcmd("ILOSC_KASY", "transfer_cash_handle");

	maxPlayers = get_maxplayers();
} 

public transfer_menu(id)
{
	if(!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menu = menu_create("\yMenu \rPrzelewu", "transfer_menu_handle");
	
	menu_additem(menu, "Przelej \yKase \r(/przelewc)");
	menu_additem(menu, "Przelej \yHonor \r(/przelewh)");
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public transfer_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);

		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		return PLUGIN_HANDLED;
	}
	
	switch(item)
	{
		case 0: transfer_cash_menu(id);
		case 1: transfer_honor_menu(id);	
	}

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public transfer_honor_menu(id) 
{ 
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[256], playerName[64], playerId[3], players, menu = menu_create("\yWybierz \rGracza\y, ktoremu chcesz przelac \rHonor\w:", "transfer_honor_menu_handle");
	
	for(new player = 1; player <= maxPlayers; player++)
	{
		if(!is_user_connected(player) || !cod_get_user_class(player) || player == id) continue;
		
		get_user_name(player, playerName, charsmax(playerName));
		
		formatex(menuData, charsmax(menuData), "%s \y[%d Honoru]", playerName, cod_get_user_honor(player));

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

		cod_print_chat(id, "Na serwerze nie ma gracza, ktoremu moglbys przelac^x03 honor^x01!");
	}
	else menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public transfer_honor_menu_handle(id, menu, item)
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
		cod_print_chat(id, "Tego gracza nie ma juz na serwerze!");

		return PLUGIN_HANDLED;
	}
	
	transferPlayer[id] = player;
	
	client_cmd(id, "messagemode ILOSC_HONORU");
	
	cod_print_chat(id, "Wpisz ilosc^x03 honoru^x01, ktora chcesz przelac!");

	client_print(id, print_center, "Wpisz ilosc honoru, ktora chcesz przelac!");
	
	return PLUGIN_HANDLED;
}

public transfer_honor_handle(id)
{
	if(!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);
		
	if(!is_user_connected(transferPlayer[id]))
	{
		cod_print_chat(id, "Gracza, ktoremu chcesz przelac^x03 honor^x01 nie ma juz na serwerze!");

		return PLUGIN_HANDLED;
	}
	
	new honorData[16], honorAmount;
	
	read_args(honorData, charsmax(honorData));
	remove_quotes(honorData);

	honorAmount = str_to_num(honorData);
	
	if(honorAmount <= 0)
	{ 
		cod_print_chat(id, "Nie mozesz przelac mniej niz^x03 1 honoru^x01!");

		return PLUGIN_HANDLED;
	}
	
	if(cod_get_user_honor(id) < honorAmount) 
	{ 
		cod_print_chat(id, "Nie masz tyle^x03 honoru^x01!");

		return PLUGIN_HANDLED;
	} 
	
	new playerName[33], playerIdName[33];
	
	get_user_name(id, playerName, charsmax(playerName));
	get_user_name(transferPlayer[id], playerIdName, charsmax(playerIdName));
	
	cod_set_user_honor(transferPlayer[id], cod_get_user_honor(transferPlayer[id]) + honorAmount);
	cod_set_user_honor(id, cod_get_user_honor(id) - honorAmount);
	
	cod_print_chat(0, "^x03%s^x01 przelal^x04 %i honoru^x01 na konto^x03 %s^x01.", playerName, honorAmount, playerIdName);
	
	return PLUGIN_HANDLED;
}

public transfer_cash_menu(id) 
{ 
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new menuData[256], playerName[64], playerId[3], players, menu = menu_create("\yWybierz \rGracza\y, ktoremu chcesz przelac \rKase\w:", "transfer_cash_menu_handle");
	
	for(new player = 1; player <= maxPlayers; player++)
	{
		if(!is_user_connected(player) || !cod_get_user_class(player) || player == id) continue;
		
		get_user_name(player, playerName, charsmax(playerName));
		
		formatex(menuData, charsmax(menuData), "%s \y[%d$]", playerName, cod_get_user_honor(player));

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

		cod_print_chat(id, "Na serwerze nie ma gracza, ktoremu moglbys przelac^x03 kase^x01!");
	}
	else menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public transfer_cash_menu_handle(id, menu, item)
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
		cod_print_chat(id, "Tego gracza nie ma juz na serwerze!");

		return PLUGIN_HANDLED;
	}
	
	transferPlayer[id] = player;
	
	client_cmd(id, "messagemode ILOSC_KASY");
	
	cod_print_chat(id, "Wpisz ilosc^x03 kasy^x01, ktora chcesz przelac!");

	client_print(id, print_center, "Wpisz ilosc kasy, ktora chcesz przelac!");
	
	return PLUGIN_HANDLED;
}

public transfer_cash_handle(id)
{
	if(!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);
		
	if(!is_user_connected(transferPlayer[id]))
	{
		cod_print_chat(id, "Gracza, ktoremu chcesz przelac^x03 honor^x01 nie ma juz na serwerze!");

		return PLUGIN_HANDLED;
	}
	
	new cashData[16], cashAmount;
	
	read_args(cashData, charsmax(cashData));
	remove_quotes(cashData);

	cashAmount = str_to_num(cashData);
	
	if(cashAmount <= 0)
	{ 
		cod_print_chat(id, "Nie mozesz przelac mniej niz^x03 1$^x01!");

		return PLUGIN_HANDLED;
	}
	
	if(cs_get_user_money(id) < cashAmount) 
	{ 
		cod_print_chat(id, "Nie masz tyle^x03 honoru^x01!");

		return PLUGIN_HANDLED;
	} 
	
	new playerName[33], playerIdName[33];
	
	get_user_name(id, playerName, charsmax(playerName));
	get_user_name(transferPlayer[id], playerIdName, charsmax(playerIdName));
	
	cs_set_user_money(transferPlayer[id], cs_get_user_money(transferPlayer[id]) + cashAmount);
	cs_set_user_money(id, cs_get_user_money(id) - cashAmount);
	
	cod_print_chat(0, "^x03%s^x01 przelal^x04 %i honoru^x01 na konto^x03 %s^x01.", playerName, cashAmount, playerIdName);
	
	return PLUGIN_HANDLED;
}