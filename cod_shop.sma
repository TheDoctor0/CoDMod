#include <amxmodx>
#include <cstrike>
#include <cod>

#define PLUGIN "CoD Shop"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const commandShopMenu[][] = { "say /shop", "say_team /shop", "say /sklep", "say_team /sklep", "sklep" };

new cvarCostRepair, cvarCostItem, cvarCostUpgrade, cvarCostSmallExp, cvarCostBigExp,
	costRepair, costItem, costUpgrade, costSmallExp, costBigExp;

new cvarExchangeRatio, cvarDurability, cvarMinSmallExp, cvarMaxSmallExp, cvarMinBigExp, cvarMaxBigExp,
	exchangeRatio, itemDurability, minSmallExp, maxSmallExp, minBigExp, maxBigExp;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof commandShopMenu; i++) register_clcmd(commandShopMenu[i], "shop_menu");

	register_clcmd("KUPNO_HONORU", "buy_honor_handle");
	
	cvarCostRepair = register_cvar("cod_shop_repair_cost", "8");
	cvarCostItem = register_cvar("cod_shop_item_cost", "10");
	cvarCostUpgrade = register_cvar("cod_shop_upgrade_cost", "8");
	cvarCostSmallExp = register_cvar("cod_shop_smallexp_cost", "6");
	cvarCostBigExp = register_cvar("cod_shop_bigexp_cost", "12");
	
	cvarExchangeRatio = register_cvar("cod_shop_exchange_ratio", "1000");
	cvarDurability = register_cvar("cod_shop_durability", "30");
	cvarMinSmallExp = register_cvar("cod_shop_min_smallexp", "25");
	cvarMaxSmallExp = register_cvar("cod_shop_max_smallexp", "75");
	cvarMinBigExp = register_cvar("cod_shop_min_bigexp", "100");
	cvarMaxBigExp = register_cvar("cod_shop_max_bigexp", "200");
}

public plugin_cfg()
{
	costRepair = get_pcvar_num(cvarCostRepair);
	costItem = get_pcvar_num(cvarCostItem);
	costUpgrade = get_pcvar_num(cvarCostUpgrade);
	costSmallExp = get_pcvar_num(cvarCostSmallExp);
	costBigExp = get_pcvar_num(cvarCostBigExp);
	
	exchangeRatio = get_pcvar_num(cvarExchangeRatio);
	itemDurability = get_pcvar_num(cvarDurability);
	minSmallExp = get_pcvar_num(cvarMinSmallExp);
	maxSmallExp = get_pcvar_num(cvarMaxSmallExp);
	minBigExp = get_pcvar_num(cvarMinBigExp);
	maxBigExp = get_pcvar_num(cvarMaxBigExp);
}
	
public shop_menu(id)
{
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menuData[128], menuPrice[8], menu = menu_create("\wSklep \rCoD Mod", "shop_menu_handle");

	formatex(menuData, charsmax(menuData), "Kantor Walutowy \r[\yWymiana Kasy na Honor\r] \wKoszt:\r %i$/1 Honor", exchangeRatio);
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "Napraw Przedmiot \r[\y+%i Wytrzymalosci\r] \wKoszt:\r %i Honoru", itemDurability, costRepair);
	formatex(menuPrice, charsmax(menuPrice), "%i", costRepair);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Kup Przedmiot \r[\yLosowy Przedmiot\r] \wKoszt:\r %i Honoru", costItem);
	formatex(menuPrice, charsmax(menuPrice), "%i", costItem);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Ulepsz Przedmiot \r[\yWzmocnienie Przedmiotu\r] \wKoszt:\r %i Honoru", costUpgrade);
	formatex(menuPrice, charsmax(menuPrice), "%i", costUpgrade);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Maly Exp \r[\yLosowo od %i do %i Expa\r] \wKoszt:\r %i Honoru", minSmallExp, maxSmallExp, costSmallExp);
	formatex(menuPrice, charsmax(menuPrice), "%i", costSmallExp);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Duzy Exp \r[\yLosowo od %i do %i Expa\r] \wKoszt:\r %i Honoru", minBigExp, maxBigExp, costBigExp);
	formatex(menuPrice, charsmax(menuPrice), "%i", costBigExp);
	menu_additem(menu, menuData, menuPrice);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public shop_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	if(item == 0)
	{
		client_print(id, print_center, "Wpisz ile Honoru chcesz kupic.");

		cod_print_chat(id, "Wpisz ile^x03 Honoru^x01 chcesz kupic.");

		client_cmd(id, "messagemode KUPNO_HONORU");

		return PLUGIN_HANDLED;
	}
	
	if(item == 1)
	{
		new itemValue, playerItem = cod_get_user_item(id, itemValue);

		if(!playerItem)
		{
			cod_print_chat(id, "Nie masz zadnego przedmiotu!");

			return PLUGIN_HANDLED;
		}

		if(itemValue <= 1)
		{
			cod_print_chat(id, "Twoj przedmiot nie moze juz zostac ulepszony!");

			return PLUGIN_HANDLED;
		}
	}
	
	new itemPrice[6], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemPrice, charsmax(itemPrice), _, _, itemCallback);
	
	new price = str_to_num(itemPrice);
	
	if(cod_get_user_honor(id) < price)
	{
		cod_print_chat(id, "Nie masz wystarczajaco duzo^x03 Honoru^x01!");

		return PLUGIN_HANDLED;
	}

	cod_set_user_honor(id, cod_get_user_honor(id) - price);
	
	switch(item)
	{
		case 1:
		{
			cod_print_chat(id, "Kupiles ^x03+%i^x01 wytrzymalosci przedmiotu!", itemDurability);
			
			if(cod_get_item_durability(id) + itemDurability >= cod_max_item_durability())
			{
				cod_set_item_durability(id, cod_max_item_durability());

				cod_print_chat(id, "Twoj przedmiot jest w pelni naprawiony!");
			}
			else
			{
				cod_set_item_durability(id, cod_get_item_durability(id) + itemDurability);

				cod_print_chat(id, "Wytrzymalosc twojego przedmiotu wynosi ^x03%i^x01!", cod_get_item_durability(id));
			}
		}
		case 2:
		{
			cod_print_chat(id, "Kupiles^x03 losowy przedmiot^x01!");
			
			cod_set_user_item(id, -1, -1);
		}
		case 3:
		{
			cod_print_chat(id, "Kupiles^x03 ulepszenie przedmiotu^x01!");
			
			cod_upgrade_user_item(id);
		}
		case 4:
		{
			cod_print_chat(id, "Kupiles^x03 maly exp^x01!");
			
			new exp = random_num(minSmallExp, maxSmallExp);

			cod_print_chat(id, "Dostales^x03 %i^x01 expa!", exp);
			
			cod_set_user_exp(id, cod_get_user_exp(id) + exp);
		}
		case 5:
		{
			cod_print_chat(id, "Kupiles^x03 duzy exp^x01!");
			
			new exp = random_num(minBigExp, maxBigExp);

			cod_print_chat(id, "Dostales^x03 %i^x01 expa!", exp);
			
			cod_set_user_exp(id, cod_get_user_exp(id) + exp);
		}
	}

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public buy_honor_handle(id)
{
	if(!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);
	
	new honorData[16], honorAmount;
	
	read_args(honorData, charsmax(honorData));
	remove_quotes(honorData);

	honorAmount = str_to_num(honorData);
	
	if(honorAmount <= 0)
	{ 
		cod_print_chat(id, "Nie mozesz kupic mniej niz^x03 1 Honoru^x01!");

		return PLUGIN_HANDLED;
	}
	
	if(cs_get_user_money(id) < honorAmount * exchangeRatio) 
	{ 
		cod_print_chat(id, "Nie masz wystarczajaco^x03 kasy^x01, aby kupic tyle^x03 Honoru^x01!");

		return PLUGIN_HANDLED;
	}
	
	cs_set_user_money(id, cs_get_user_money(id) - honorAmount * exchangeRatio);
	cod_add_user_honor(id, honorAmount);
	
	cod_print_chat(id, "Wymieniles^x03 %i$^x01 na ^x03%i Honoru^x01.", honorAmount * exchangeRatio, honorAmount);
	
	return PLUGIN_HANDLED;
}