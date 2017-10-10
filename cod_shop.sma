#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Shop"
#define VERSION "1.0.9"
#define AUTHOR "O'Zone"

new const commandShopMenu[][] = { "say /shop", "say_team /shop", "say /sklep", "say_team /sklep", "sklep" };

enum _:shopInfo { EXCHANGE, REPAIR, BUY, UPGRADE, SMALL_BANDAGE, BIG_BANDAGE, SMALL_EXP, MEDIUM_EXP, BIG_EXP, 
	RANDOM_EXP, ROCKET, MINE, DYNAMITE, FIRST_AID_KIT, TELEPORT, JUMP, BUNNY_HOP, SILENT, ARMOR, DAMAGE, INVISIBLE };

new cvarCostRepair, cvarCostItem, cvarCostUpgrade, cvarCostSmallBandage, cvarCostBigBandage, cvarCostSmallExp, cvarCostMediumExp, 
	cvarCostBigExp, cvarCostRandomExp, cvarCostRocket, cvarCostMine, cvarCostDynamite, cvarCostFirstAidKit, cvarCostTeleport, 
	cvarCostJump, cvarCostBunnyHop, cvarCostSilent, cvarCostArmor, cvarCostDamage, cvarCostInvisible, cvarExchangeRatio, cvarDurabilityAmount, 
	cvarSmallExp, cvarMediumExp, cvarBigExp, cvarMinRandomExp, cvarMaxRandomExp, cvarSmallBandageHP, cvarBigBandageHP, cvarArmorAmount, cvarDamageAmount;

new damageBonus;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for (new i; i < sizeof commandShopMenu; i++) register_clcmd(commandShopMenu[i], "shop_menu");

	register_clcmd("KUPNO_HONORU", "buy_honor_handle");

	bind_pcvar_num(create_cvar("cod_shop_repair_cost", "10"), cvarCostRepair);
	bind_pcvar_num(create_cvar("cod_shop_item_cost", "15"), cvarCostItem);
	bind_pcvar_num(create_cvar("cod_shop_upgrade_cost", "10"), cvarCostUpgrade);
	bind_pcvar_num(create_cvar("cod_shop_small_bandage_cost", "6"), cvarCostSmallBandage);
	bind_pcvar_num(create_cvar("cod_shop_big_bandage_cost", "15"), cvarCostBigBandage);
	bind_pcvar_num(create_cvar("cod_shop_small_exp_cost", "6"), cvarCostSmallExp);
	bind_pcvar_num(create_cvar("cod_shop_medium_exp_cost", "14"), cvarCostMediumExp);
	bind_pcvar_num(create_cvar("cod_shop_big_exp_cost", "25"), cvarCostBigExp);
	bind_pcvar_num(create_cvar("cod_shop_random_exp_cost", "15"), cvarCostRandomExp);
	bind_pcvar_num(create_cvar("cod_shop_rocket_cost", "15"), cvarCostRocket);
	bind_pcvar_num(create_cvar("cod_shop_mine_cost", "15"), cvarCostMine);
	bind_pcvar_num(create_cvar("cod_shop_dynamite_cost", "15"), cvarCostDynamite);
	bind_pcvar_num(create_cvar("cod_shop_firstaidkit_cost", "15"), cvarCostFirstAidKit);
	bind_pcvar_num(create_cvar("cod_shop_dynamite_cost", "15"), cvarCostTeleport);
	bind_pcvar_num(create_cvar("cod_shop_jump_cost", "20"), cvarCostJump);
	bind_pcvar_num(create_cvar("cod_shop_bunnyhop_cost", "25"), cvarCostBunnyHop);
	bind_pcvar_num(create_cvar("cod_shop_silent_cost", "15"), cvarCostSilent);
	bind_pcvar_num(create_cvar("cod_shop_armor_cost", "20"), cvarCostArmor);
	bind_pcvar_num(create_cvar("cod_shop_damage_cost", "20"), cvarCostDamage);
	bind_pcvar_num(create_cvar("cod_shop_invisible_cost", "50"), cvarCostInvisible);

	bind_pcvar_num(create_cvar("cod_shop_exchange_ratio", "1000"), cvarExchangeRatio);
	bind_pcvar_num(create_cvar("cod_shop_durability_amount", "50"), cvarDurabilityAmount);
	bind_pcvar_num(create_cvar("cod_shop_small_bandage_hp", "25"), cvarSmallBandageHP);
	bind_pcvar_num(create_cvar("cod_shop_big_bandage_hp", "75"), cvarBigBandageHP);
	bind_pcvar_num(create_cvar("cod_shop_small_exp", "25"), cvarSmallExp);
	bind_pcvar_num(create_cvar("cod_shop_medium_exp", "75"), cvarMediumExp);
	bind_pcvar_num(create_cvar("cod_shop_big_exp", "150"), cvarBigExp);
	bind_pcvar_num(create_cvar("cod_shop_random_exp_min", "1"), cvarMinRandomExp);
	bind_pcvar_num(create_cvar("cod_shop_random_exp_max", "200"), cvarMaxRandomExp);
	bind_pcvar_num(create_cvar("cod_shop_armor_amount", "100"), cvarArmorAmount);
	bind_pcvar_num(create_cvar("cod_shop_damage_amount", "5"), cvarDamageAmount);
}
	
public shop_menu(id)
{
	if (!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menuData[128], menuPrice[10], menu = menu_create("\ySklep \rCoD Mod", "shop_menu_handle");

	formatex(menuData, charsmax(menuData), "Kantor Walutowy \r[\yWymiana Kasy na Honor\r] \wKoszt:\r %i$/1H", cvarExchangeRatio);
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "Napraw Przedmiot \r[\y+%i Wytrzymalosci\r] \wKoszt:\r %iH", cvarDurabilityAmount, cvarCostRepair);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostRepair);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Kup Przedmiot \r[\yLosowy Przedmiot\r] \wKoszt:\r %iH", cvarCostItem);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostItem);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Ulepsz Przedmiot \r[\yWzmocnienie Przedmiotu\r] \wKoszt:\r %iH", cvarCostUpgrade);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostUpgrade);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Maly Bandaz \r[\y+%i HP\r] \wKoszt:\r %iH", cvarSmallBandageHP, cvarCostSmallBandage);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostSmallBandage);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Duzy Bandaz \r[\y+%i HP\r] \wKoszt:\r %iH", cvarBigBandageHP, cvarCostBigBandage);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostBigBandage);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Male Doswiadczenie \r[\y%i Expa\r] \wKoszt:\r %iH", cvarSmallExp, cvarCostSmallExp);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostSmallExp);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Srednie Doswiadczenie \r[\y%i Expa\r] \wKoszt:\r %iH", cvarMediumExp, cvarCostMediumExp);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostMediumExp);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Duze Doswiadczenie \r[\y%i Expa\r] \wKoszt:\r %iH", cvarBigExp, cvarCostBigExp);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostBigExp);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Losowe Doswiadczenie \r[\yLosowo od %i do %i Expa\r] \wKoszt:\r %iH", cvarMinRandomExp, cvarMaxRandomExp, cvarCostRandomExp);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostRandomExp);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowa Rakieta \r[\y+1 Rakieta\r] \wKoszt:\r %iH", cvarCostRocket);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostRocket);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowa Mina \r[\y+1 Mina\r] \wKoszt:\r %iH", cvarCostMine);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostMine);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowy Dynamit \r[\y+1 Dynamit\r] \wKoszt:\r %iH", cvarCostDynamite);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostDynamite);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowa Apteczka \r[\y+1 Apteczka\r] \wKoszt:\r %iH", cvarCostFirstAidKit);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostFirstAidKit);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowy Teleport \r[\y+1 Teleport\r] \wKoszt:\r %iH", cvarCostTeleport);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostTeleport);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowy Skok \r[\y+1 Skok w Powietrzu\r] \wKoszt:\r %iH", cvarCostJump);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostJump);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Bunny Hop \r[\yAuto BunnyHop\r] \wKoszt:\r %iH", cvarCostBunnyHop);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostBunnyHop);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Ciche Chodzenie \r[\yBrak Dzwieku Biegu\r] \wKoszt:\r %iH", cvarCostSilent);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostSilent);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Dodatkowy Pancerz \r[\y+%i Kamizelki\r] \wKoszt:\r %iH", cvarArmorAmount, cvarCostArmor);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostArmor);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Wieksze Obrazenia \r[\y+%i DMG\r] \wKoszt:\r %iH", cvarDamageAmount, cvarCostDamage);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostDamage);
	menu_additem(menu, menuData, menuPrice);

	formatex(menuData, charsmax(menuData), "Peleryna Niewidka \r[\yPelna Niewidzialnosc\r] \wKoszt:\r %iH", cvarCostInvisible);
	formatex(menuPrice, charsmax(menuPrice), "%i", cvarCostInvisible);
	menu_additem(menu, menuData, menuPrice);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public shop_menu_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	if (item == EXCHANGE) {
		client_print(id, print_center, "Wpisz ile Honoru chcesz kupic.");

		cod_print_chat(id, "Wpisz ile^x03 Honoru^x01 chcesz kupic.");

		client_cmd(id, "messagemode KUPNO_HONORU");

		return PLUGIN_HANDLED;
	}

	if (item == REPAIR && cod_get_item_durability(id) >= cod_max_item_durability()) {
		cod_print_chat(id, "Twoj przedmiot jest juz w pelni^x03 naprawiony^x01!");

		return PLUGIN_HANDLED;
	}

	if ((item == SMALL_BANDAGE || item == BIG_BANDAGE) && cod_get_user_health(id, 1) == cod_get_user_max_health(id)) {
		cod_print_chat(id, "Jestes juz w pelni^x03 uzdrowiony^x01!");

		return PLUGIN_HANDLED;
	}

	if (item == SILENT && cod_get_user_footsteps(id)) {
		cod_print_chat(id, "Masz juz ^x03 Ciche Chodzenie^x01!");

		return PLUGIN_HANDLED;
	}

	if (item == BUNNY_HOP && cod_get_user_bunnyhop(id)) {
		cod_print_chat(id, "Masz juz ^x03 Bunny Hop^x01!");

		return PLUGIN_HANDLED;
	}

	if (item == TELEPORT && cod_get_user_teleports(id) == FULL) {
		cod_print_chat(id, "Masz juz nielimitowany^x03 Teleport^x01!");

		return PLUGIN_HANDLED;
	}

	if (item == JUMP && cod_get_user_multijumps(id) >= 3) {
		cod_print_chat(id, "Mozesz miec maksymalnie^x03 3 Dodatkowe Skoki^x01!");

		return PLUGIN_HANDLED;
	}

	if (item == ARMOR && cod_get_user_armor(id) >= 300) {
		cod_print_chat(id, "Mozesz miec maksymalnie^x03 300 Pancerza^x01!");

		return PLUGIN_HANDLED;
	}

	if (item == DAMAGE && get_bit(id, damageBonus)) {
		cod_print_chat(id, "W tej rundzie juz kupiles^x03 Wieksze Obrazenia^x01!");

		return PLUGIN_HANDLED;
	}

	if (item == INVISIBLE && !cod_get_user_render(id)) {
		cod_print_chat(id, "Masz juz^x03 Pelna Niewidzialnosc^x01!");

		return PLUGIN_HANDLED;
	}
	
	if (item == UPGRADE) {
		if (!cod_get_user_item(id)) {
			cod_print_chat(id, "Nie masz zadnego przedmiotu!");

			return PLUGIN_HANDLED;
		}

		if (!cod_upgrade_user_item(id, 1)) {
			cod_print_chat(id, "Ulepszenie twojego przedmiotu nie jest mozliwe!");

			return PLUGIN_HANDLED;
		}
	}
	
	new itemPrice[10], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemPrice, charsmax(itemPrice), _, _, itemCallback);
	
	new price = str_to_num(itemPrice);
	
	if (cod_get_user_honor(id) < price) {
		cod_print_chat(id, "Nie masz wystarczajaco duzo^x03 Honoru^x01!");

		return PLUGIN_HANDLED;
	}
	
	switch (item) {
		case REPAIR: {
			cod_print_chat(id, "Kupiles^x03 +%i^x01 wytrzymalosci przedmiotu!", cvarDurabilityAmount);
			
			if (cod_get_item_durability(id) + cvarDurabilityAmount >= cod_max_item_durability()) {
				cod_set_item_durability(id, cod_max_item_durability());

				cod_print_chat(id, "Twoj przedmiot jest teraz w pelni naprawiony!");
			} else {
				cod_set_item_durability(id, cod_get_item_durability(id) + cvarDurabilityAmount);

				cod_print_chat(id, "Wytrzymalosc twojego przedmiotu wynosi^x03 %i^x01!", cod_get_item_durability(id));
			}
		}
		case BUY: {
			cod_print_chat(id, "Kupiles^x03 Losowy Przedmiot^x01!");
			
			cod_set_user_item(id, RANDOM, RANDOM);
		}
		case UPGRADE: {
			cod_print_chat(id, "Kupiles^x03 Ulepszenie Przedmiotu^x01!");

			if (!cod_upgrade_user_item(id)) {
				cod_print_chat(id, "Twoj przedmiot nie moze juz zostac^x03 ulepszony^x01. Honor nie zostal pobrany z konta.");

				return PLUGIN_HANDLED;
			}
		}
		case SMALL_BANDAGE: {
			cod_set_user_health(id, cod_get_user_health(id, 1) + cvarSmallBandageHP);
			
			cod_print_chat(id, "Kupiles^x03 Maly Bandarz^x01!");
		}
		case BIG_BANDAGE: {
			cod_set_user_health(id, cod_get_user_health(id, 1) + cvarBigBandageHP);
			
			cod_print_chat(id, "Kupiles^x03 Duzy Bandarz^x01!");
		}
		case SMALL_EXP: {
			cod_print_chat(id, "Kupiles^x03 Male Doswiadczenie^x01!");

			cod_print_chat(id, "Dostales^x03 %i^x01 expa!", cvarSmallExp);
			
			cod_set_user_exp(id, cvarSmallExp);
		}
		case MEDIUM_EXP: {
			cod_print_chat(id, "Kupiles^x03 Srednie Doswiadczenie^x01!");

			cod_print_chat(id, "Dostales^x03 %i^x01 expa!", cvarMediumExp);
			
			cod_set_user_exp(id, cvarMediumExp);
		}
		case BIG_EXP: {
			cod_print_chat(id, "Kupiles^x03 Duze Doswiadczenie^x01!");

			cod_print_chat(id, "Dostales^x03 %i^x01 expa!", cvarBigExp);
			
			cod_set_user_exp(id, cvarBigExp);
		}
		case RANDOM_EXP: {
			new randomExp = random_num(cvarMinRandomExp, cvarMaxRandomExp);

			cod_print_chat(id, "Kupiles^x03 Losowe Doswiadczenie^x01!");

			cod_print_chat(id, "Dostales^x03 %i^x01 expa!", randomExp);
			
			cod_set_user_exp(id, randomExp);
		}
		case ROCKET: {
			cod_print_chat(id, "Kupiles^x03 Dodatkowa Rakiete^x01!");
			
			cod_add_user_mines(id, 1);
		}
		case MINE: {
			cod_print_chat(id, "Kupiles^x03 Dodatkowa Mine^x01!");
			
			cod_add_user_rockets(id, 1);
		}
		case DYNAMITE: {
			cod_print_chat(id, "Kupiles^x03 Dodatkowy Dynamit^x01!");
			
			cod_add_user_dynamites(id, 1);
		}
		case FIRST_AID_KIT: {
			cod_print_chat(id, "Kupiles^x03 Dodatkowa Apteczke^x01!");
			
			cod_add_user_medkits(id, 1);
		}
		case TELEPORT: {
			cod_print_chat(id, "Kupiles^x03 Dodatkowy Teleport^x01!");
			
			cod_add_user_teleports(id, 1);
		}
		case JUMP: {
			cod_print_chat(id, "Kupiles^x03 Dodatkowy Skok^x01!");
			
			cod_add_user_multijumps(id, 1);
		}
		case BUNNY_HOP: {
			cod_print_chat(id, "Kupiles^x03 BunnyHop^x01!");
			
			cod_set_user_bunnyhop(id, 1);
		}
		case SILENT: {
			cod_print_chat(id, "Kupiles^x03 Ciche Chodzenie^x01!");
			
			cod_set_user_footsteps(id, 1);
		}
		case ARMOR: {
			cod_print_chat(id, "Kupiles^x03 Dodatkowy Armor^x01!");
			
			cod_add_user_armor(id, cvarArmorAmount);
		}
		case DAMAGE: {
			cod_print_chat(id, "Kupiles^x03 Wieksze Obrazenia^x01!");

			set_bit(id, damageBonus);
		}
		case INVISIBLE: {
			cod_print_chat(id, "Kupiles^x03 Peleryne Niewidke^x01!");

			cod_set_user_render(id, 0);
		}
	}

	cod_add_user_honor(id, -price);

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public buy_honor_handle(id)
{
	if (!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);
	
	new honorData[16], honorAmount;
	
	read_args(honorData, charsmax(honorData));
	remove_quotes(honorData);

	honorAmount = str_to_num(honorData);
	
	if (honorAmount <= 0) { 
		cod_print_chat(id, "Nie mozesz kupic mniej niz^x03 1 Honoru^x01!");

		return PLUGIN_HANDLED;
	}
	
	if (cod_get_user_money(id) < honorAmount * cvarExchangeRatio) { 
		cod_print_chat(id, "Nie masz wystarczajaco^x03 kasy^x01, aby kupic tyle^x03 Honoru^x01!");

		return PLUGIN_HANDLED;
	}
	
	cod_add_user_money(id, -honorAmount * cvarExchangeRatio);
	cod_add_user_honor(id, honorAmount);
	
	cod_print_chat(id, "Wymieniles^x03 %i$^x01 na ^x03%i Honoru^x01.", honorAmount * cvarExchangeRatio, honorAmount);
	
	return PLUGIN_HANDLED;
}

public cod_damage_post(attacker, victim, weapon, Float:damage, damageBits, hitPlace)
	if (get_bit(attacker, damageBonus)) cod_inflict_damage(attacker, victim, float(cvarDamageAmount), 0.0, damageBits);

public cod_new_round()
	for (new i = 1; i <= MAX_PLAYERS; i++) rem_bit(i, damageBonus);