#include <amxmod> 
#include <cod> 
#include <fakemeta> 

#define PLUGIN "CoD Transfer"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const szCommandHonor[][] = { "say /przelewh", "say_team /przelewh", "say /przelejh", "say_team /przelejh", "przelejh" };
new const szCommandCash[][] = { "say /przelew", "say_team /przelew", "say /przelej", "say_team /przelej", "przelej" };

new iPlayer[MAX_PLAYERS + 1];

public plugin_init() 
{  
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof szCommandHonor; i++)
		register_clcmd(szCommandHonor[i], "TransferHonorMenu");
		
	for(new i; i < sizeof szCommandCash; i++)
		register_clcmd(szCommandCash[i], "TransferCashMenu");

	register_clcmd("Ilosc_Honoru", "TransferHonor_Handler");
	register_clcmd("Ilosc_Kasy", "TransferCash_Handler");
} 

public TransferHonorMenu(id) 
{ 
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}

	new szMenu[256], szName[32], szPlayer[2], iPlayers;
	
	formatex(szMenu, charsmax(szMenu), "\wWybierz \rGracza\w, ktoremu chcesz przelac \yHonor:");
	
	new menu = menu_create(szMenu, "TransferHonorMenu_Handler")
	
	for(new player = 1; player <= 32; player++)
	{
		if(!is_user_connected(player) || is_user_hltv(id) || is_user_bot(id) || player == id)
			continue;
		
		get_user_name(player, szName, charsmax(szName));
		
		formatex(szMenu, charsmax(szMenu), "%s \y[%d Honoru]", szName, cod_get_user_honor(player));
		formatex(szPlayer, charsmax(szPlayer), "%i", get_user_index(szName));
		
		menu_additem(menu, szMenu, szPlayer);
		
		iPlayers++;
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	if(!iPlayers)
	{
		menu_destroy(menu);
		cod_print_chat(id, DontChange, "Na serwerze nie ma gracza, ktoremu moglbys przelac^x03 Honor^x01!");
	}
	return PLUGIN_CONTINUE;
}

public TransferHonorMenu_Handler(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_connected(id))
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	new szData[6], iAccess, iCallback;
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), _, _, iCallback);
	
	new player = str_to_num(szData);
	
	if(!is_user_connected(player))
	{
		cod_print_chat(id, DontChange, "Tego gracza nie ma juz na serwerze!");
		return PLUGIN_CONTINUE;
	}
	
	iPlayer[id] = player;
	
	client_cmd(id, "messagemode Ilosc_Honoru");
	
	cod_print_chat(id, DontChange, "Wpisz ilosc^x03 Honoru^x01, ktora chcesz przelac!");
	client_print(id, print_center, "Wpisz ilosc Honoru, ktora chcesz przelac!");
	
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public TransferHonor_Handler(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_CONTINUE;
	}
		
	if(!is_user_connected(iPlayer[id]))
	{
		cod_print_chat(id, DontChange, "Gracza, ktoremu chcesz przelac^x03 Honor^x01 nie ma juz na serwerze!");
		return PLUGIN_CONTINUE;
	}
	
	new szTemp[16], iHonorAmount;
	
	read_args(szTemp, charsmax(szTemp));
	remove_quotes(szTemp);

	iHonorAmount = str_to_num(szTemp);
	
	if(!iHonorAmount)
	{ 
		cod_print_chat(id, DontChange, "Nie mozesz przelac mniej niz^x03 1 Honoru^x01!");
		return PLUGIN_CONTINUE;
	}
	
	if(cod_get_user_honor(id) < iHonorAmount) 
	{ 
		cod_print_chat(id, DontChange, "Nie masz tyle^x03 Honoru^x01!");
		return PLUGIN_CONTINUE;
	} 
	
	new szName[33], szPlayerName[33];
	
	get_user_name(id, szName, charsmax(szName));
	get_user_name(iPlayer[id], szPlayerName, charsmax(szPlayerName));
	
	cod_set_user_honor(iPlayer[id], cod_get_user_honor(iPlayer[id]) + iHonorAmount);
	cod_set_user_honor(id, cod_get_user_honor(id) - iHonorAmount);
	
	cod_print_chat(0, DontChange, "^x03%s^x01 przelal^x04 %i Honoru^x01 na konto^x03 %s^x01.", szName, iHonorAmount, szPlayerName);
	
	return PLUGIN_CONTINUE;
}

public TransferCashMenu(id) 
{ 
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
	
	new szMenu[256], szName[32], szPlayer[2], iPlayers;
	
	formatex(szMenu, charsmax(szMenu), "\wWybierz \rGracza\w, ktoremu chcesz przelac \ykase:");
	
	new menu = menu_create(szMenu, "TransferCashMenu_Handler")
	
	for(new player = 1; player <= 32; player++)
	{
		if(!is_user_connected(player) || is_user_hltv(id) || is_user_bot(id) || player == id)
			continue;
		
		get_user_name(player, szName, charsmax(szName));
		
		formatex(szMenu, charsmax(szMenu), "%s \y[%d $]", szName, cs_get_user_money(player));
		formatex(szPlayer, charsmax(szPlayer), "%i", get_user_index(szName));
		
		menu_additem(menu, szMenu, szPlayer);
		
		iPlayers++;
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	if(!iPlayers)
	{
		menu_destroy(menu);
		cod_print_chat(id, DontChange, "Na serwerze nie ma gracza, ktoremu moglbys przelac^x03 kase^x01!");
	}
	return PLUGIN_CONTINUE;
}

public TransferCashMenu_Handler(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_connected(id))
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	new szData[6], iAccess, iCallback;
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), _, _, iCallback);
	
	new player = str_to_num(szData);
	
	if(!is_user_connected(player))
	{
		cod_print_chat(id, DontChange, "Tego gracza nie ma juz na serwerze!");
		return PLUGIN_CONTINUE;
	}
	
	iPlayer[id] = player;
	
	client_cmd(id, "messagemode Ilosc_Kasy");
	
	cod_print_chat(id, DontChange, "Wpisz ilosc^x03 kasy^x01, ktora chcesz przelac!");
	client_print(id, print_center, "Wpisz ilosc kasy, ktora chcesz przelac!");
	
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public TransferCash_Handler(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_CONTINUE;
	}
		
	if(!is_user_connected(iPlayer[id]))
	{
		cod_print_chat(id, DontChange, "Gracza, ktoremu chcesz przelac^x03 kase^x01 nie ma juz na serwerze!");
		return PLUGIN_CONTINUE;
	}
	
	new szTemp[16], iCashAmount;
	
	read_args(szTemp, charsmax(szTemp));
	remove_quotes(szTemp);

	iCashAmount = str_to_num(szTemp);
	
	if(!iCashAmount)
	{ 
		cod_print_chat(id, DontChange, "Nie mozesz przelac mniej niz^x03 1 $^x01!");
		return PLUGIN_CONTINUE;
	}
	
	if(cs_get_user_money(id) < iCashAmount) 
	{ 
		cod_print_chat(id, DontChange, "Nie masz tyle^x03 kasy^x01!");
		return PLUGIN_CONTINUE;
	} 
	
	new szName[33], szPlayerName[33];
	
	get_user_name(id, szName, charsmax(szName));
	get_user_name(iPlayer[id], szPlayerName, charsmax(szPlayerName));
	
	cs_set_user_money(iPlayer[id], cs_get_user_money(iPlayer[id]) + iCashAmount);
	cs_set_user_money(id, cs_get_user_money(id) - iCashAmount);
	
	cod_print_chat(0, DontChange, "^x03%s^x01 przelal^x04 %i $^x01 na konto^x03 %s^x01.", szName, iCashAmount, szPlayerName);
	
	return PLUGIN_CONTINUE;
}