#include <amxmodx>
#include <cod>
#include <engine>
#include <cstrike>
#include <fun>

#define PLUGIN "CoD Shop"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

enum { CASH = 0, HONOR = 1 };

new buySymbol [][] = { "$", "H" };

new const szCommandShop[][] = { "say /shop", "say_team /shop", "say /sklep", "say_team /sklep", "sklep" };
new const szCommandShopC[][] = { "say /shopc", "say_team /shopc", "say /sklepk", "say_team /sklepk", "sklepk" };
new const szCommandShopH[][] = { "say /shoph", "say_team /shoph", "say /skleph", "say_team /skleph", "skleph" };

new iSilent[MAX_PLAYERS + 1], iHP[MAX_PLAYERS + 1], iHE[MAX_PLAYERS + 1], iType[MAX_PLAYERS + 1], bool:bSilent[MAX_PLAYERS + 1];

new cvarCostRepair[2], cvarCostItem[2], cvarCostUpgrade[2], cvarCostSmallExp[2], cvarCostBigExp[2], cvarCostSilent[2], cvarCostHP[2], cvarCostHE[2];
new costRepair[2], costItem[2], costUpgrade[2], costSmallExp[2], costBigExp[2], costSilent[2], costHP[2], costHE[2];

new cvarExchangeRatio, cvarDurability, cvarSmallExpMin, cvarSmallExpMax, cvarBigExpMin, cvarBigExpMax, cvarSilentRounds, cvarHPAmount, cvarHPRounds, cvarHEAmount, cvarHERounds;
new iExchangeRatio, iDurability, iSmallExpMin, iSmallExpMax, iBigExpMin, iBigExpMax, iSilentRounds, iHPAmount, iHPRounds, iHEAmount, iHERounds;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof szCommandShop; i++) register_clcmd(szCommandShop[i], "Shop");

	for(new i; i < sizeof szCommandShopC; i++) register_clcmd(szCommandShopC[i], "ShopC");
		
	for(new i; i < sizeof szCommandShopH; i++) register_clcmd(szCommandShopH[i], "ShopH");
	
	register_logevent("RoundStart", 2, "1=Round_Start");
	register_logevent("RoundEnd", 2, "1=Round_End");
	
	cvarCostRepair[0] = register_cvar("cod_shop_repair_costc", "5000");
	cvarCostRepair[1] = register_cvar("cod_shop_repair_costh", "5");
	cvarCostItem[0] = register_cvar("cod_shop_item_costc", "5000");
	cvarCostItem[1] = register_cvar("cod_shop_item_costh", "5");
	cvarCostUpgrade[0] = register_cvar("cod_shop_upgrade_costc", "5000");
	cvarCostUpgrade[1] = register_cvar("cod_shop_upgrade_costh", "5");
	cvarCostSmallExp[0] = register_cvar("cod_shop_smallexp_costc", "5000");
	cvarCostSmallExp[1] = register_cvar("cod_shop_smallexp_costh", "5");
	cvarCostBigExp[0] = register_cvar("cod_shop_bigexp_costc", "5000");
	cvarCostBigExp[1] = register_cvar("cod_shop_bigexp_costh", "5");
	cvarCostSilent[0] = register_cvar("cod_shop_silent_costc", "5000");
	cvarCostSilent[1] = register_cvar("cod_shop_silent_costh", "5");
	cvarCostHP[0] = register_cvar("cod_shop_hp_costc", "5000");
	cvarCostHP[1] = register_cvar("cod_shop_hp_costh", "5");
	cvarCostHE[0] = register_cvar("cod_shop_he_costc", "5000");
	cvarCostHE[1] = register_cvar("cod_shop_he_costh", "5");
	
	cvarExchangeRatio = register_cvar("cod_shop_exchange_ratio", "2500");
	cvarDurability = register_cvar("cod_shop_durability", "30");
	cvarSmallExpMin = register_cvar("cod_shop_smallexp_min", "25");
	cvarSmallExpMax = register_cvar("cod_shop_smallexp_max", "75");
	cvarBigExpMin = register_cvar("cod_shop_bigexp_min", "100");
	cvarBigExpMax = register_cvar("cod_shop_bigexp_max", "200");
	cvarSilentRounds = register_cvar("cod_shop_silent_rounds", "5");
	cvarHPAmount = register_cvar("cod_shop_hp_amount", "50");
	cvarHPRounds = register_cvar("cod_shop_hp_rounds", "5");
	cvarHEAmount = register_cvar("cod_shop_he_amount", "5");
	cvarHERounds = register_cvar("cod_shop_he_rounds", "5");
}

public plugin_cfg()
{
	costRepair[0] = get_pcvar_num(cvarCostRepair[0]);
	costRepair[1] = get_pcvar_num(cvarCostRepair[1]);
	costItem[0] = get_pcvar_num(cvarCostItem[0]);
	costItem[1] = get_pcvar_num(cvarCostItem[1]);
	costUpgrade[0] = get_pcvar_num(cvarCostUpgrade[0]);
	costUpgrade[1] = get_pcvar_num(cvarCostUpgrade[1]);
	costSmallExp[0] = get_pcvar_num(cvarCostSmallExp[0]);
	costSmallExp[1] = get_pcvar_num(cvarCostSmallExp[1]);
	costBigExp[0] = get_pcvar_num(cvarCostBigExp[0]);
	costBigExp[1] = get_pcvar_num(cvarCostBigExp[1]);
	costSilent[0] = get_pcvar_num(cvarCostSilent[0]);
	costSilent[1] = get_pcvar_num(cvarCostSilent[1]);
	costHP[0] = get_pcvar_num(cvarCostHP[0]);
	costHP[1] = get_pcvar_num(cvarCostHP[1]);
	costHE[0] = get_pcvar_num(cvarCostHE[0]);
	costHE[1] = get_pcvar_num(cvarCostHE[1]);
	
	iExchangeRatio = = get_pcvar_num(cvarExchangeRatio);
	iDurability = get_pcvar_num(cvarDurability);
	iSmallExpMin = get_pcvar_num(cvarSmallExpMin);
	iSmallExpMax = get_pcvar_num(cvarSmallExpMax);
	iBigExpMin = get_pcvar_num(cvarBigExpMin);
	iBigExpMax = get_pcvar_num(cvarBigExpMax);
	iSilentRounds = get_pcvar_num(cvarSilentRounds);
	iHPAmount = get_pcvar_num(cvarHPAmount);
	iHPRounds = get_pcvar_num(cvarHPRounds);
	iHEAmount = get_pcvar_num(cvarHEAmount);
	iHERounds = get_pcvar_num(cvarHERounds);
}
	
public Shop(id)
{
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
	
	client_cmd(id, "spk CodMod/select2");
	
	new menu = menu_create("\wSklep \rCoD Mod", "Shop_Handler");
	
	menu_additem(menu, "Place \yDolarami");
	menu_additem(menu, "Place \yHonorem");
	
	menu_display(id, menu);
	return PLUGIN_CONTINUE;
}

public Shop_Handler(id, menu, item)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0: iType[id] = CASH;
		case 1: iType[id] = HONOR;
	}
	
	ShowShop(id);
	
	return PLUGIN_CONTINUE;
}

public ShopC(id)
{
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
	
	iType[id] = CASH;
	
	ShowShop(id);
	
	return PLUGIN_CONTINUE;
}

public ShopH(id)
{
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
	
	iType[id] = HONOR;
	
	ShowShop(id);
	
	return PLUGIN_CONTINUE;
}

public ShowShop(id)
{
	client_cmd(id, "spk CoDMod/select2");
	
	new menu = menu_create("\wSklep \rCoD Mod", "ShowShop_Handler");
	
	new szTemp[128], szPrice[8];

	formatex(szTemp, charsmax(szTemp), "Kantor Walutowy\r[Wymiana Kasy na Honor] \yKoszt:\r %i%s/%i%s", iType[id] ? 1 : iExchangeRatio, buySymbol[iType[id]], iType[id] ? iExchangeRatio : 1, buySymbol[iType[id]]);
	formatex(szPrice, charsmax(szPrice), -1);
	menu_additem(menu, szTemp, szPrice);
	formatex(szTemp, charsmax(szTemp), "Napraw Item \r[+%i Wytrzymalosci] \yKoszt:\r %i%s", iDurability, costRepair[iType[id]], buySymbol[iType[id]]);
	formatex(szPrice, charsmax(szPrice), costRepair[iType[id]]);
	menu_additem(menu, szTemp, szPrice);
	formatex(szTemp, charsmax(szTemp), "Kup Item \r[Losowy Item] \yKoszt:\r %i%s", costItem[iType[id]], buySymbol[iType[id]]);
	formatex(szPrice, charsmax(szPrice), costItem[iType[id]]);
	menu_additem(menu, szTemp, szPrice);
	formatex(szTemp, charsmax(szTemp), "Ulepsz Item \r[Wzmocnienie Itemu] \yKoszt:\r %i%s", costUpgrade[iType[id]], buySymbol[iType[id]]);
	formatex(szPrice, charsmax(szPrice), costUpgrade[iType[id]]);
	menu_additem(menu, szTemp, szPrice);
	formatex(szTemp, charsmax(szTemp), "Maly Exp \r[Od %i do %i Expa] \yKoszt:\r %i%s", iSmallExpMin, iSmallExpMax, costSmallExp[iType[id]], buySymbol[iType[id]]);
	formatex(szPrice, charsmax(szPrice), costSmallExp[iType[id]]);
	menu_additem(menu, szTemp, szPrice);
	formatex(szTemp, charsmax(szTemp), "Duzy Exp \r[Od %i do %i Expa] \yKoszt:\r %i%s", iBigExpMin, iBigExpMax, costBigExp[iType[id]], buySymbol[iType[id]]);
	formatex(szPrice, charsmax(szPrice), costBigExp[iType[id]]);
	menu_additem(menu, szTemp, szPrice);

	if(cod_get_user_vip(id))
	{
		formatex(szTemp, charsmax(szTemp), "VIP: Ciche Buty \r[%i rund] \yKoszt:\r %i%s", iSilentRounds, costSilent[iType[id]], buySymbol[iType[id]]);
		formatex(szPrice, charsmax(szPrice), costSilent[iType[id]]);
		menu_additem(menu, szTemp, szPrice);
		formatex(szTemp, charsmax(szTemp), "VIP: +%i HP \r[%i rund] \yKoszt:\r %i%s", iHPAmount, iHPRounds, costHP[iType[id]], buySymbol[iType[id]]);
		formatex(szPrice, charsmax(szPrice), costHP[iType[id]]);
		menu_additem(menu, szTemp, szPrice);
		formatex(szTemp, charsmax(szTemp), "VIP: Zestaw %i HE \r[%i rund] \yKoszt:\r %i%s", iHEAmount, iHERounds, costHE[iType[id]], buySymbol[iType[id]]);
		formatex(szPrice, charsmax(szPrice), costHE[iType[id]]);
		menu_additem(menu, szTemp, szPrice);
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu);
}

public ShowShop_Handler(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CoDMod/select2");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	if(item >= 6 && !cod_get_user_vip(id))
	{
		cod_print_chat(id, "Nie masz^x03 VIPa^x01!");
		return PLUGIN_CONTINUE;
	}
	
	if(item == 2)
	{
		if(cod_get_user_item_value(id) <= 1)
		{
			cod_print_chat(id, "Twoj item nie moze juz zostac ulepszony!");
			return PLUGIN_CONTINUE;
		}
		
		if(!cod_get_user_item(id))
		{
			cod_print_chat(id, "Nie masz zadnego itemu!");
			return PLUGIN_CONTINUE;
		}
	}
	
	new szData[8], iAccess, iCallback, iPrice;
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), _, _, iCallback); 
	
	iPrice = str_to_num(szData);
	
	switch(iType[id])
	{
		case CASH:
		{
			if(cs_get_user_money(id) < iPrice)
			{
				cod_print_chat(id, "Nie masz wystarczajaco duzo kasy!");
				return PLUGIN_CONTINUE;
			}
			
			cs_set_user_money(id, cs_get_user_money(id) - iPrice);
		}
		case HONOR:
		{
			if(cod_get_user_honor(id < iPrice))
			{
				cod_print_chat(id, "Nie masz wystarczajaco duzo honoru!");
				return PLUGIN_CONTINUE;
			}
			
			cod_set_user_honor(id, cod_get_user_honor(id) - iPrice);
		}
	}
	
	switch(item)
	{
		case 0:
		{
			cod_print_chat(id, "Kupiles ^x03+%i^x01 wytrzymalosci itemu!", iDurability);
			
			if(cod_get_item_durability(id) + iDurability >= cod_max_item_durability())
			{
				cod_set_item_durability(id, cod_max_item_durability());
				cod_print_chat(id, "Twoj perk jest w pelni naprawiony!");
			}
			else
			{
				cod_set_item_durability(id, cod_get_item_durability(id) + iDurability);
				cod_print_chat(id, "Wytrzymalosc twojego itemu wynosi ^x03%i^x01!", cod_get_item_durability(id));
			}
		}
		case 1:
		{
			cod_print_chat(id, "Kupiles^x03 losowy item^x01!");
			
			cod_set_user_item(id, -1, -1, 1);
		}
		case 2:
		{
			cod_print_chat(id, "Kupiles^x03 ulepszenie itemu^x01!");
			
			cod_upgrade_user_item(id);
		}
		case 3:
		{
			cod_print_chat(id, "Kupiles^x03 Maly Exp^x01!");
			
			new iExp = random_num(iSmallExpMin, iSmallExpMax);

			cod_print_chat(id, "Dostales^x03 %i^x01 Expa!", iExp);
			
			cod_set_user_exp(id, cod_get_user_exp(id) + iExp);
		}
		case 4:
		{
			cod_print_chat(id, "Kupiles^x03 Duzy Exp^x01!");
			
			new iExp = random_num(iBigExpMin, iBigExpMax);

			cod_print_chat(id, "Dostales^x03 %i^x01 Expa!", iExp);
			
			cod_set_user_exp(id, cod_get_user_exp(id) + iExp);
		}
		case 5:
		{
			cod_print_chat(id, "Kupiles^x03 Ciche Buty^x01 na^x03 %i^x01 rund^x01!", iSilentRounds);
			
			iSilent[id] += iSilentRounds;
		}
		case 6:
		{
			cod_print_chat(id, "Kupiles^x03 +%i HP^x01 na^x03 %i^x01 rund^x01!", iHPAmount, iHPRounds);
			
			iHP[id] += iHPRounds;
		}
		case 7:
		{
			cod_print_chat(id, "Kupiles^x03 Zestaw %i HE^x01 na^x03 %i^x01 rund^x01!", iHEAmount, iHERounds);
			
			iHE[id] += iHERounds;
		}
	}

	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public RoundStart()
{
	for(new id = 1; id < 33; id++)
	{
		if(!is_user_alive(id))
			continue;
			
		if(iSilent[id])
		{
			if(iSilent[id] == 1)
			{
				cod_print_chat(id, "To^x03 ostatnia^x01 runda, w ktorej masz^x03 Ciche Buty^x01.");
				bSilent[id] = true;
			}
			else
				cod_print_chat(id, "Jeszcze przez^x03 %i^x01 rundy masz^x03 Ciche Buty^x01.", iSilent[id]);
				
			iSilent[id]--;
			
			set_user_footsteps(id, 1);
		}
	
		if(iHP[id])
		{
			if(iHP[id] == 1)
				cod_print_chat(id, "To^x03 ostatnia^x01 runda, w ktorej masz^x03 +%i HP^x01.", iHPAmount);
			else
				cod_print_chat(id, "Jeszcze przez^x03 %i^x01 rundy masz^x03 +%i HP^x01.", iHP[id], iHPAmount);

			iHP[id]--;
			
			set_user_health(id, get_user_health(id) + iHPAmount);
		}
	
		if(iHE[id])
		{
			if(iHE[id] == 1)
				cod_print_chat(id, "To^x03 ostatnia^x01 runda, w ktorej masz^x03 %i HE^x01.", iHEAmount);
			else
				cod_print_chat(id, "Jeszcze przez^x03 %i^x01 rundy masz^x03 %i HE^x01.", iHE[id], iHEAmount);
				
			iHE[id]--;
				
			give_item(id, "weapon_hegrenade");
			cs_set_user_bpammo(id, CSW_HEGRENADE, iHEAmount);
		}
	}
	return PLUGIN_CONTINUE;
}

public RoundEnd()
{
	for(new id = 1; id < 33; id++)
	{
		if(is_user_alive(id) && bSilent[id])
		{
			set_user_footsteps(id, 0);
			bSilent[id] = false;
		}
	}
	return PLUGIN_CONTINUE;
}