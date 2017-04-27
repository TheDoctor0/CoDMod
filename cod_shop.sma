#include <amxmodx>
#include <cstrike>
#include <cod>

#define PLUGIN "CoD Shop"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const commandShopMenu[][] = { "say /shop", "say_team /shop", "say /sklep", "say_team /sklep", "sklep" };

enum _:shopInfo { EXCHANGE, REPAIR, BUY, UPGRADE, SMALL_BANDAGE, BIG_BANDAGE, ROCKET, MINE, DYNAMITE, 
	FIRST_AID_KIT, JUMP, BUNNY_HOP, SILENT, ARMOR, DAMAGE, SMALL_EXP, MEDIUM_EXP, BIG_EXP, RANDOM_EXP };

new cvarCostRepair, cvarCostItem, cvarCostUpgrade, cvarCostSmallBandage, cvarCostBigBandage, cvarCostRocket, cvarCostMine, cvarCostDynamite, cvarCostFirstAidKit, 
	cvarCostJump, cvarCostBunnyHop, cvarCostSilent, cvarCostArmor, cvarCostDamage, cvarCostSmallExp, cvarCostMediumExp, cvarCostBigExp, cvarCostRandomExp, cvarExchangeRatio, 
	cvarDurabilityAmount, cvarSmallBandageHP, cvarBigBandageHP, cvarArmorAmount, cvarDamageAmount, cvarSmallExp, cvarMediumExp, cvarBigExp, cvarMinRandomExp, cvarMaxRandomExp;

new costRepair, costItem, costUpgrade, costSmallBandage, costBigBandage, costRocket, costMine, costDynamite, costFirstAidKit, 
	costJump, costBunnyHop, costSilent, costArmor, costDamage, costSmallExp, costMediumExp, costBigExp, costRandomExp, exchangeRatio, 
	durabilityAmount, smallBandageHP, bigBandageHP, armorAmount, damageAmount, smallExp, mediumExp, bigExp, minRandomExp, maxRandomExp;

new silentWalk, bunnyHop, damageBonus;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof commandShopMenu; i++) register_clcmd(commandShopMenu[i], "shop_menu");

	register_clcmd("KUPNO_HONORU", "buy_honor_handle");
	
	cvarCostRepair = register_cvar("cod_shop_repair_cost", "10");
	cvarCostItem = register_cvar("cod_shop_item_cost", "15");
	cvarCostUpgrade = register_cvar("cod_shop_upgrade_cost", "10");
	cvarCostSmallBandage = register_cvar("cod_shop_small_bandage_cost", "6");
	cvarCostBigBandage = register_cvar("cod_shop_big_bandage_cost", "15");
	cvarCostRocket = register_cvar("cod_shop_rocket_cost", "20");
	cvarCostMine = register_cvar("cod_shop_mine_cost", "20");
	cvarCostDynamite = register_cvar("cod_shop_dynamite_cost", "20");
	cvarCostFirstAidKit = register_cvar("cod_shop_firstaidkit_cost", "20");
	cvarCostJump = register_cvar("cod_shop_jump_cost", "15");
	cvarCostBunnyHop = register_cvar("cod_shop_bunnyhop_cost", "20");
	cvarCostSilent = register_cvar("cod_shop_silent_cost", "20");
	cvarCostArmor = register_cvar("cod_shop_armor_cost", "25");
	cvarCostDamage = register_cvar("cod_shop_damage_cost", "25");
	cvarCostSmallExp = register_cvar("cod_shop_small_exp_cost", "6");
	cvarCostMediumExp = register_cvar("cod_shop_medium_exp_cost", "14");
	cvarCostBigExp = register_cvar("cod_shop_big_exp_cost", "25");
	cvarCostRandomExp = register_cvar("cod_shop_random_exp_cost", "15");
	
	cvarExchangeRatio = register_cvar("cod_shop_exchange_ratio", "1000");
	cvarDurabilityAmount = register_cvar("cod_shop_durability_amount", "30");
	cvarSmallBandageHP = register_cvar("cod_shop_small_bandage_hp", "25");
	cvarBigBandageHP = register_cvar("cod_shop_big_bandage_hp", "75");
	cvarArmorAmount = register_cvar("cod_shop_armor_amount", "100");
	cvarDamageAmount = register_cvar("cod_shop_damage_amount", "5");
	cvarSmallExp = register_cvar("cod_shop_small_exp", "25");
	cvarMediumExp = register_cvar("cod_shop_medium_exp", "75");
	cvarBigExp = register_cvar("cod_shop_big_exp", "150");
	cvarMinRandomExp = register_cvar("cod_shop_random_exp_min", "1");
	cvarMaxRandomExp = register_cvar("cod_shop_random_exp_max", "200");
}

public plugin_cfg()
{
	costRepair = get_pcvar_num(cvarCostRepair);
	costItem = get_pcvar_num(cvarCostItem);
	costUpgrade = get_pcvar_num(cvarCostUpgrade);
	costSmallBandage = get_pcvar_num(cvarCostSmallBandage);
	costBigBandage = get_pcvar_num(cvarCostBigBandage);
	costRocket = get_pcvar_num(cvarCostRocket);
	costMine = get_pcvar_num(cvarCostMine);
	costDynamite = get_pcvar_num(cvarCostDynamite);
	costFirstAidKit = get_pcvar_num(cvarCostFirstAidKit);
	costJump = get_pcvar_num(cvarCostJump);
	costBunnyHop = get_pcvar_num(cvarCostBunnyHop);
	costSilent = get_pcvar_num(cvarCostSilent);
	costArmor = get_pcvar_num(cvarCostArmor);
	costDamage = get_pcvar_num(cvarCostDamage);
	costSmallExp = get_pcvar_num(cvarCostSmallExp);
	costMediumExp = get_pcvar_num(cvarCostMediumExp);
	costBigExp = get_pcvar_num(cvarCostBigExp);
	costRandomExp = get_pcvar_num(cvarCostRandomExp);
	
	exchangeRatio = get_pcvar_num(cvarExchangeRatio);
	durabilityAmount = get_pcvar_num(cvarDurabilityAmount);
	smallBandageHP = get_pcvar_num(cvarSmallBandageHP);
	bigBandageHP = get_pcvar_num(cvarBigBandageHP);
	armorAmount = get_pcvar_num(cvarArmorAmount);
	damageAmount = get_pcvar_num(cvarDamageAmount);
	smallExp = get_pcvar_num(cvarSmallExp);
	mediumExp = get_pcvar_num(cvarMediumExp);
	bigExp = get_pcvar_num(cvarBigExp);
	minRandomExp = get_pcvar_num(cvarMinRandomExp);
	maxRandomExp = get_pcvar_num(cvarMaxRandomExp);
}
	
public shop_menu(id)
{
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menuData[128], menuPrice[10], menu = menu_create("\ySklep \rCoD Mod", "shop_menu_handle");

	formatex(menuData, charsmax(menuData), "Kantor Walutowy \r[\yWymiana Kasy na Honor\r] \wKoszt:\r %i$/1H", exchangeRatio);
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "Napraw Przedmiot \r[\y+%i Wytrzymalosci\r] \wKoszt:\r %iH", durabilityAmount, costRepair);
	formatex(menuPrice, charsmax(menuPrice), "%i", costRepair);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Kup Przedmiot \r[\yLosowy Przedmiot\r] \wKoszt:\r %iH", costItem);
	formatex(menuPrice, charsmax(menuPrice), "%i", costItem);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Ulepsz Przedmiot \r[\yWzmocnienie Przedmiotu\r] \wKoszt:\r %iH", costUpgrade);
	formatex(menuPrice, charsmax(menuPrice), "%i", costUpgrade);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Maly Bandaz \r[\y+%i HP\r] \wKoszt:\r %iH", smallBandageHP, costSmallBandage);
	formatex(menuPrice, charsmax(menuPrice), "%i", costSmallBandage);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Duzy Bandaz \r[\y+%i HP\r] \wKoszt:\r %iH", bigBandageHP, costBigBandage);
	formatex(menuPrice, charsmax(menuPrice), "%i", costBigBandage);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowa Rakieta \r[\y+1 Rakieta\r] \wKoszt:\r %iH", costRocket);
	formatex(menuPrice, charsmax(menuPrice), "%i", costRocket);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowa Mina \r[\y+1 Mina\r] \wKoszt:\r %iH", costMine);
	formatex(menuPrice, charsmax(menuPrice), "%i", costMine);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowy Dynamit \r[\y+1 Dynamit\r] \wKoszt:\r %iH", costDynamite);
	formatex(menuPrice, charsmax(menuPrice), "%i", costDynamite);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowa Apteczka \r[\y+1 Apteczka\r] \wKoszt:\r %iH", costFirstAidKit);
	formatex(menuPrice, charsmax(menuPrice), "%i", costFirstAidKit);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowy Skok \r[\y+1 Skok w Powietrzu\r] \wKoszt:\r %iH", costJump);
	formatex(menuPrice, charsmax(menuPrice), "%i", costJump);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Bunny Hop \r[\yAutomatyczny BunnyHop\r] \wKoszt:\r %iH", costBunnyHop);
	formatex(menuPrice, charsmax(menuPrice), "%i", costBunnyHop);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Ciche Chodzenie \r[\yBrak Dzwiekow Poruszania\r] \wKoszt:\r %iH", costSilent);
	formatex(menuPrice, charsmax(menuPrice), "%i", costSilent);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowy Pancerz \r[\y+%i Kamizelki\r] \wKoszt:\r %iH", armorAmount, costArmor);
	formatex(menuPrice, charsmax(menuPrice), "%i", costArmor);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Wieksze Obrazenia \r[\y+%i DMG\r] \wKoszt:\r %iH", damageAmount, costDamage);
	formatex(menuPrice, charsmax(menuPrice), "%i", costDamage);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Male Doswiadczenie \r[\y%i Expa\r] \wKoszt:\r %iH", smallExp, costSmallExp);
	formatex(menuPrice, charsmax(menuPrice), "%i", costSmallExp);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Srednie Doswiadczenie \r[\y%i Expa\r] \wKoszt:\r %iH", mediumExp, costMediumExp);
	formatex(menuPrice, charsmax(menuPrice), "%i", costMediumExp);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Duze Doswiadczenie \r[\y%i Expa\r] \wKoszt:\r %iH", bigExp, costBigExp);
	formatex(menuPrice, charsmax(menuPrice), "%i", costBigExp);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Losowe Doswiadczenie \r[\yLosowo od %i do %i Expa\r] \wKoszt:\r %iH", minRandomExp, maxRandomExp, costRandomExp);
	formatex(menuPrice, charsmax(menuPrice), "%i", costRandomExp);
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

	if(item == EXCHANGE)
	{
		client_print(id, print_center, "Wpisz ile Honoru chcesz kupic.");

		cod_print_chat(id, "Wpisz ile^x03 Honoru^x01 chcesz kupic.");

		client_cmd(id, "messagemode KUPNO_HONORU");

		return PLUGIN_HANDLED;
	}

	if(item == REPAIR && cod_get_item_durability(id) >= cod_max_item_durability())
	{
		cod_print_chat(id, "Twoj przedmiot jest juz w pelni^x03 naprawiony^x01!");

		return PLUGIN_HANDLED;
	}

	if((item == SMALL_BANDAGE || item == BIG_BANDAGE) && get_user_health(id) == cod_get_user_max_health(id))
	{
		cod_print_chat(id, "Jestes juz w pelni^x03 uzdrowiony^x01!");

		return PLUGIN_HANDLED;
	}

	if(item == SILENT && (get_bit(id, silentWalk) || cod_get_user_footsteps(id)))
	{
		cod_print_chat(id, "Masz juz ^x03 Ciche Chodzenie^x01!");

		return PLUGIN_HANDLED;
	}

	if(item == BUNNY_HOP && (get_bit(id, bunnyHop) || cod_get_user_bunnyhop(id)))
	{
		cod_print_chat(id, "Masz juz ^x03 Bunny Hop^x01!");

		return PLUGIN_HANDLED;
	}

	if(item == DAMAGE && get_bit(id, damageBonus))
	{
		cod_print_chat(id, "W tej rundzie juz kupiles^x03 Wieksze Obrazenia^x01!");

		return PLUGIN_HANDLED;
	}
	
	if(item == UPGRADE)
	{
		if(!cod_get_user_item(id))
		{
			cod_print_chat(id, "Nie masz zadnego przedmiotu!");

			return PLUGIN_HANDLED;
		}

		if(!cod_upgrade_user_item(id, 1))
		{
			cod_print_chat(id, "Ulepszenie twojego przedmiotu nie jest mozliwe!");

			return PLUGIN_HANDLED;
		}
	}
	
	new itemPrice[10], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemPrice, charsmax(itemPrice), _, _, itemCallback);
	
	new price = str_to_num(itemPrice);
	
	if(cod_get_user_honor(id) < price)
	{
		cod_print_chat(id, "Nie masz wystarczajaco duzo^x03 Honoru^x01!");

		return PLUGIN_HANDLED;
	}
	
	switch(item)
	{
		case REPAIR:
		{
			cod_print_chat(id, "Kupiles^x03 +%i^x01 wytrzymalosci przedmiotu!", durabilityAmount);
			
			if(cod_get_item_durability(id) + durabilityAmount >= cod_max_item_durability())
			{
				cod_set_item_durability(id, cod_max_item_durability());

				cod_print_chat(id, "Twoj przedmiot jest teraz w pelni naprawiony!");
			}
			else
			{
				cod_set_item_durability(id, cod_get_item_durability(id) + durabilityAmount);

				cod_print_chat(id, "Wytrzymalosc twojego przedmiotu wynosi^x03 %i^x01!", cod_get_item_durability(id));
			}
		}
		case BUY:
		{
			cod_print_chat(id, "Kupiles^x03 Losowy Przedmiot^x01!");
			
			cod_set_user_item(id, -1, -1);
		}
		case UPGRADE:
		{
			cod_print_chat(id, "Kupiles^x03 Ulepszenie Przedmiotu^x01!");

			if(!cod_upgrade_user_item(id))
			{
				cod_print_chat(id, "Twoj przedmiot nie moze juz zostac^x03 ulepszony^x01. Honor nie zostal pobrany z konta.");

				return PLUGIN_HANDLED;
			}
		}
		case MINE:
		{
			cod_print_chat(id, "Kupiles^x03 Dodatkowa Rakiete^x01!");
			
			cod_add_user_mines(id, 1);
		}
		case ROCKET:
		{
			cod_print_chat(id, "Kupiles^x03 Dodatkowa Mine^x01!");
			
			cod_add_user_rockets(id, 1);
		}
		case DYNAMITE:
		{
			cod_print_chat(id, "Kupiles^x03 Dodatkowy Dynamit^x01!");
			
			cod_add_user_dynamites(id, 1);
		}
		case FIRST_AID_KIT:
		{
			cod_print_chat(id, "Kupiles^x03 Dodatkowa Apteczke^x01!");
			
			cod_add_user_medkits(id, 1);
		}
		case JUMP:
		{
			cod_print_chat(id, "Kupiles^x03 Dodatkowy Skok^x01!");
			
			cod_add_user_multijumps(id, 1);
		}
		case BUNNY_HOP:
		{
			cod_print_chat(id, "Kupiles^x03 BunnyHop^x01!");
			
			cod_set_user_bunnyhop(id, 1);

			set_bit(id, bunnyHop);
		}
		case SILENT:
		{
			cod_print_chat(id, "Kupiles^x03 Ciche Chodzenie^x01!");
			
			cod_set_user_footsteps(id, 1);

			set_bit(id, silentWalk);
		}
		case ARMOR:
		{
			cod_print_chat(id, "Kupiles^x03 Dodatkowy Armor^x01!");
			
			cod_add_user_armor(id, armorAmount);
		}
		case DAMAGE:
		{
			cod_print_chat(id, "Kupiles^x03 Wieksze Obrazenia^x01!");

			set_bit(id, damageBonus);
		}
		case SMALL_EXP:
		{
			cod_print_chat(id, "Kupiles^x03 Male Doswiadczenie^x01!");

			cod_print_chat(id, "Dostales^x03 %i^x01 expa!", smallExp);
			
			cod_set_user_exp(id, cod_get_user_exp(id) + smallExp);
		}
		case MEDIUM_EXP:
		{
			cod_print_chat(id, "Kupiles^x03 Srednie Doswiadczenie^x01!");

			cod_print_chat(id, "Dostales^x03 %i^x01 expa!", mediumExp);
			
			cod_set_user_exp(id, cod_get_user_exp(id) + mediumExp);
		}
		case BIG_EXP:
		{
			cod_print_chat(id, "Kupiles^x03 Duze Doswiadczenie^x01!");

			cod_print_chat(id, "Dostales^x03 %i^x01 expa!", bigExp);
			
			cod_set_user_exp(id, cod_get_user_exp(id) + bigExp);
		}
		case RANDOM_EXP:
		{
			new randomExp = random_num(minRandomExp, maxRandomExp);

			cod_print_chat(id, "Kupiles^x03 Losowe Doswiadczenie^x01!");

			cod_print_chat(id, "Dostales^x03 %i^x01 expa!", randomExp);
			
			cod_set_user_exp(id, cod_get_user_exp(id) + randomExp);
		}
	}

	cod_set_user_honor(id, cod_get_user_honor(id) - price);

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

public cod_damage_post(attacker, victim, Float:damage, damageBits)
	if(get_bit(attacker, damageBonus)) cod_inflict_damage(attacker, victim, float(damageAmount), 0.0, DMG_BULLET);

public cod_new_round()
	for(new i = 1; i <= MAX_PLAYERS; i++) rem_bit(i, damageBonus);