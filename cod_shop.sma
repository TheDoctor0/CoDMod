#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Shop"
#define VERSION "1.3.0"
#define AUTHOR "O'Zone"

new const commandShopMenu[][] = { "sklep", "say /shop", "say_team /shop", "say /sklep", "say_team /sklep" };

enum _:shopInfo { REPAIR, BUY, UPGRADE, SMALL_BANDAGE, BIG_BANDAGE, SMALL_EXP, MEDIUM_EXP, BIG_EXP, RANDOM_EXP,
	ROCKET, MINE, DYNAMITE, MEDKIT, THUNDER, TELEPORT, JUMP, BUNNY_HOP, SILENT, ARMOR, DAMAGE, INVISIBLE };

new cvarCostRepair, cvarCostItem, cvarCostUpgrade, cvarCostSmallBandage, cvarCostBigBandage, cvarCostSmallExp,
	cvarCostMediumExp,cvarCostBigExp, cvarCostRandomExp, cvarCostRocket, cvarCostMine, cvarCostDynamite, cvarCostMedkit,
	cvarCostThunder,cvarCostTeleport, cvarCostJump, cvarCostBunnyHop, cvarCostSilent, cvarCostArmor, cvarCostDamage,
	cvarCostInvisible,cvarDurabilityAmount, cvarSmallExp, cvarMediumExp,cvarBigExp, cvarMinRandomExp, cvarMaxRandomExp,
	cvarSmallBandageHP,cvarBigBandageHP, cvarArmorAmount, cvarDamageAmount, cvarMaxDurability, bool:mapEnd, damageBonus;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for (new i; i < sizeof commandShopMenu; i++) register_clcmd(commandShopMenu[i], "shop_menu");

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
	bind_pcvar_num(create_cvar("cod_shop_medkit_cost", "15"), cvarCostMedkit);
	bind_pcvar_num(create_cvar("cod_shop_thunder_cost", "15"), cvarCostThunder);
	bind_pcvar_num(create_cvar("cod_shop_teleport_cost", "30"), cvarCostTeleport);
	bind_pcvar_num(create_cvar("cod_shop_jump_cost", "20"), cvarCostJump);
	bind_pcvar_num(create_cvar("cod_shop_bunny_hop_cost", "25"), cvarCostBunnyHop);
	bind_pcvar_num(create_cvar("cod_shop_silent_cost", "15"), cvarCostSilent);
	bind_pcvar_num(create_cvar("cod_shop_armor_cost", "20"), cvarCostArmor);
	bind_pcvar_num(create_cvar("cod_shop_damage_cost", "35"), cvarCostDamage);
	bind_pcvar_num(create_cvar("cod_shop_invisible_cost", "50"), cvarCostInvisible);

	bind_pcvar_num(create_cvar("cod_shop_durability_amount", "50"), cvarDurabilityAmount);
	bind_pcvar_num(create_cvar("cod_shop_small_bandage_hp", "25"), cvarSmallBandageHP);
	bind_pcvar_num(create_cvar("cod_shop_big_bandage_hp", "75"), cvarBigBandageHP);
	bind_pcvar_num(create_cvar("cod_shop_small_exp", "25"), cvarSmallExp);
	bind_pcvar_num(create_cvar("cod_shop_medium_exp", "75"), cvarMediumExp);
	bind_pcvar_num(create_cvar("cod_shop_big_exp", "150"), cvarBigExp);
	bind_pcvar_num(create_cvar("cod_shop_random_exp_min", "1"), cvarMinRandomExp);
	bind_pcvar_num(create_cvar("cod_shop_random_exp_max", "200"), cvarMaxRandomExp);
	bind_pcvar_num(create_cvar("cod_shop_armor_amount", "100"), cvarArmorAmount);
	bind_pcvar_num(create_cvar("cod_shop_damage_amount", "10"), cvarDamageAmount);

	bind_pcvar_num(get_cvar_pointer("cod_max_durability"), cvarMaxDurability);
}

public cod_end_map()
	mapEnd = true;

public shop_menu(id)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	cod_play_sound(id, SOUND_SELECT);

	new menuData[128], menuPrice[10], menu = menu_create("\yMenu \rSklepu\w:", "shop_menu_handle");

	if (cvarMaxDurability && cvarCostRepair) {
		formatex(menuData, charsmax(menuData), "Napraw Przedmiot \r[\y+%i Wytrzymalosci\r] \wKoszt:\r %iH", cvarDurabilityAmount, cvarCostRepair);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostRepair, REPAIR);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostItem) {
		formatex(menuData, charsmax(menuData), "Kup Przedmiot \r[\yLosowy Przedmiot\r] \wKoszt:\r %iH", cvarCostItem);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostItem, BUY);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostUpgrade) {
		formatex(menuData, charsmax(menuData), "Ulepsz Przedmiot \r[\yWzmocnienie Przedmiotu\r] \wKoszt:\r %iH", cvarCostUpgrade);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostUpgrade, UPGRADE);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostSmallBandage) {
		formatex(menuData, charsmax(menuData), "Maly Bandaz \r[\y+%i HP\r] \wKoszt:\r %iH", cvarSmallBandageHP, cvarCostSmallBandage);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostSmallBandage, SMALL_BANDAGE);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostBigBandage) {
		formatex(menuData, charsmax(menuData), "Duzy Bandaz \r[\y+%i HP\r] \wKoszt:\r %iH", cvarBigBandageHP, cvarCostBigBandage);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostBigBandage, BIG_BANDAGE);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostSmallExp) {
		formatex(menuData, charsmax(menuData), "Male Doswiadczenie \r[\y%i Expa\r] \wKoszt:\r %iH", cvarSmallExp, cvarCostSmallExp);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostSmallExp, SMALL_EXP);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostMediumExp) {
		formatex(menuData, charsmax(menuData), "Srednie Doswiadczenie \r[\y%i Expa\r] \wKoszt:\r %iH", cvarMediumExp, cvarCostMediumExp);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostMediumExp, MEDIUM_EXP);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostBigExp) {
		formatex(menuData, charsmax(menuData), "Duze Doswiadczenie \r[\y%i Expa\r] \wKoszt:\r %iH", cvarBigExp, cvarCostBigExp);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostBigExp, BIG_EXP);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostRandomExp) {
		formatex(menuData, charsmax(menuData), "Losowe Doswiadczenie \r[\yLosowo od %i do %i Expa\r] \wKoszt:\r %iH", cvarMinRandomExp, cvarMaxRandomExp, cvarCostRandomExp);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostRandomExp, RANDOM_EXP);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostRocket) {
		formatex(menuData, charsmax(menuData), "Dodatkowa Rakieta \r[\y+1 Rakieta\r] \wKoszt:\r %iH", cvarCostRocket);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostRocket, ROCKET);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostMine) {
		formatex(menuData, charsmax(menuData), "Dodatkowa Mina \r[\y+1 Mina\r] \wKoszt:\r %iH", cvarCostMine);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostMine, MINE);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostDynamite) {
		formatex(menuData, charsmax(menuData), "Dodatkowy Dynamit \r[\y+1 Dynamit\r] \wKoszt:\r %iH", cvarCostDynamite);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostDynamite, DYNAMITE);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostMedkit) {
		formatex(menuData, charsmax(menuData), "Dodatkowa Apteczka \r[\y+1 Apteczka\r] \wKoszt:\r %iH", cvarCostMedkit);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostMedkit, MEDKIT);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostThunder) {
		formatex(menuData, charsmax(menuData), "Dodatkowy Piorun \r[\y+1 Piorun\r] \wKoszt:\r %iH", cvarCostThunder);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostThunder, THUNDER);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostTeleport) {
		formatex(menuData, charsmax(menuData), "Dodatkowy Teleport \r[\y+1 Teleport\r] \wKoszt:\r %iH", cvarCostTeleport);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostTeleport, TELEPORT);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostJump) {
		formatex(menuData, charsmax(menuData), "Dodatkowy Skok \r[\y+1 Skok w Powietrzu\r] \wKoszt:\r %iH", cvarCostJump);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostJump, JUMP);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostBunnyHop) {
		formatex(menuData, charsmax(menuData), "Bunny Hop \r[\yAuto BunnyHop\r] \wKoszt:\r %iH", cvarCostBunnyHop);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostBunnyHop, BUNNY_HOP);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostSilent) {
		formatex(menuData, charsmax(menuData), "Ciche Chodzenie \r[\yBrak Dzwieku Biegu\r] \wKoszt:\r %iH", cvarCostSilent);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostSilent, SILENT);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostArmor) {
		formatex(menuData, charsmax(menuData), "Dodatkowy Pancerz \r[\y+%i Kamizelki\r] \wKoszt:\r %iH", cvarArmorAmount, cvarCostArmor);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostArmor, ARMOR);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostDamage) {
		formatex(menuData, charsmax(menuData), "Wieksze Obrazenia \r[\y+%i Obrazen\r] \wKoszt:\r %iH", cvarDamageAmount, cvarCostDamage);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostDamage, DAMAGE);
		menu_additem(menu, menuData, menuPrice);
	}

	if (cvarCostInvisible) {
		formatex(menuData, charsmax(menuData), "Peleryna Niewidka \r[\yPelna Niewidzialnosc\r] \wKoszt:\r %iH", cvarCostInvisible);
		formatex(menuPrice, charsmax(menuPrice), "%i#%i", cvarCostInvisible, INVISIBLE);
		menu_additem(menu, menuData, menuPrice);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public shop_menu_handle(id, menu, item)
{
	if (!is_user_connected(id) || !cod_check_account(id) || mapEnd) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	new itemData[16], dataParts[2][8], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, itemCallback);

	menu_destroy(menu);

	explode(itemData, '#', dataParts, sizeof(dataParts), charsmax(dataParts[]));

	new price = str_to_num(dataParts[0]);
	item = str_to_num(dataParts[1]);

	if (cod_get_user_honor(id) < price) {
		cod_print_chat(id, "Nie masz wystarczajaco duzo^3 Honoru^1!");

		return PLUGIN_HANDLED;
	}

	switch (item) {
		case REPAIR: {
			if (!cod_get_user_item(id)) {
				cod_print_chat(id, "Nie masz zadnego przedmiotu^1!");

				return PLUGIN_HANDLED;
			}

			if (cod_get_item_durability(id) >= cod_max_item_durability()) {
				cod_print_chat(id, "Twoj przedmiot jest juz w pelni^3 naprawiony^1!");

				return PLUGIN_HANDLED;
			}

			cod_print_chat(id, "Kupiles^3 +%i^1 wytrzymalosci przedmiotu!", cvarDurabilityAmount);

			if (cod_get_item_durability(id) + cvarDurabilityAmount >= cod_max_item_durability()) {
				cod_set_item_durability(id, cod_max_item_durability());

				cod_print_chat(id, "Twoj przedmiot jest teraz w pelni naprawiony!");
			} else {
				cod_set_item_durability(id, cod_get_item_durability(id) + cvarDurabilityAmount);

				cod_print_chat(id, "Wytrzymalosc twojego przedmiotu wynosi^3 %i^1!", cod_get_item_durability(id));
			}
		} case BUY: {
			cod_print_chat(id, "Kupiles^3 Losowy Przedmiot^1!");

			cod_set_user_item(id, RANDOM);
		} case UPGRADE: {
			if (!cod_get_user_item(id)) {
				cod_print_chat(id, "Nie masz zadnego przedmiotu!");

				return PLUGIN_HANDLED;
			}

			if (!cod_upgrade_user_item(id, 1)) {
				cod_print_chat(id, "Ulepszenie twojego przedmiotu nie jest mozliwe!");

				return PLUGIN_HANDLED;
			}

			cod_print_chat(id, "Kupiles^3 Ulepszenie Przedmiotu^1!");

			if (!cod_upgrade_user_item(id)) {
				cod_print_chat(id, "Twoj przedmiot nie moze juz zostac^3 ulepszony^1. Honor nie zostal pobrany z konta.");

				return PLUGIN_HANDLED;
			}
		} case SMALL_BANDAGE: {
			if (cod_get_user_health(id, 1) >= cod_get_user_max_health(id)) {
				cod_print_chat(id, "Jestes juz w pelni^3 uzdrowiony^1!");

				return PLUGIN_HANDLED;
			}

			cod_set_user_health(id, cod_get_user_health(id, 1) + cvarSmallBandageHP);

			cod_print_chat(id, "Kupiles^3 Maly Bandaz^1!");
		} case BIG_BANDAGE: {
			if (cod_get_user_health(id, 1) >= cod_get_user_max_health(id)) {
				cod_print_chat(id, "Jestes juz w pelni^3 uzdrowiony^1!");

				return PLUGIN_HANDLED;
			}

			cod_set_user_health(id, cod_get_user_health(id, 1) + cvarBigBandageHP);

			cod_print_chat(id, "Kupiles^3 Duzy Bandaz^1!");
		} case SMALL_EXP: {
			cod_print_chat(id, "Kupiles^3 Male Doswiadczenie^1!");

			cod_print_chat(id, "Dostales^3 %i^1 expa!", cvarSmallExp);

			cod_set_user_exp(id, cvarSmallExp);
		} case MEDIUM_EXP: {
			cod_print_chat(id, "Kupiles^3 Srednie Doswiadczenie^1!");

			cod_print_chat(id, "Dostales^3 %i^1 expa!", cvarMediumExp);

			cod_set_user_exp(id, cvarMediumExp);
		} case BIG_EXP: {
			cod_print_chat(id, "Kupiles^3 Duze Doswiadczenie^1!");

			cod_print_chat(id, "Dostales^3 %i^1 expa!", cvarBigExp);

			cod_set_user_exp(id, cvarBigExp);
		} case RANDOM_EXP: {
			new randomExp = random_num(cvarMinRandomExp, cvarMaxRandomExp);

			cod_print_chat(id, "Kupiles^3 Losowe Doswiadczenie^1!");

			cod_print_chat(id, "Dostales^3 %i^1 expa!", randomExp);

			cod_set_user_exp(id, randomExp);
		} case ROCKET: {
			cod_print_chat(id, "Kupiles^3 Dodatkowa Rakiete^1!");

			cod_add_user_rockets(id, 1, DEATH);
		} case MINE: {
			cod_print_chat(id, "Kupiles^3 Dodatkowa Mine^1!");

			cod_add_user_mines(id, 1, DEATH);
		} case DYNAMITE: {
			cod_print_chat(id, "Kupiles^3 Dodatkowy Dynamit^1!");

			cod_add_user_dynamites(id, 1, DEATH);
		} case MEDKIT: {
			cod_print_chat(id, "Kupiles^3 Dodatkowa Apteczke^1!");

			cod_add_user_medkits(id, 1, DEATH);
		} case THUNDER: {
			cod_print_chat(id, "Kupiles^3 Dodatkowy Piorun^1!");

			cod_add_user_thunders(id, 1, DEATH);
		} case TELEPORT: {
			if (cod_get_user_teleports(id) == FULL) {
				cod_print_chat(id, "Masz juz nielimitowany^3 Teleport^1!");

				return PLUGIN_HANDLED;
			}

			cod_print_chat(id, "Kupiles^3 Dodatkowy Teleport^1!");

			cod_add_user_teleports(id, 1, DEATH);
		} case JUMP: {
			if (cod_get_user_multijumps(id) >= 3) {
				cod_print_chat(id, "Mozesz miec maksymalnie^3 3 Dodatkowe Skoki^1!");

				return PLUGIN_HANDLED;
			}

			cod_print_chat(id, "Kupiles^3 Dodatkowy Skok^1!");

			cod_add_user_multijumps(id, 1, DEATH);
		} case BUNNY_HOP: {
			if (cod_get_user_bunnyhop(id)) {
				cod_print_chat(id, "Masz juz ^3 Bunny Hop^1!");

				return PLUGIN_HANDLED;
			}

			cod_print_chat(id, "Kupiles^3 BunnyHop^1!");

			cod_set_user_bunnyhop(id, 1, DEATH);
		} case SILENT: {
			if (cod_get_user_footsteps(id)) {
				cod_print_chat(id, "Masz juz ^3 Ciche Chodzenie^1!");

				return PLUGIN_HANDLED;
			}

			cod_print_chat(id, "Kupiles^3 Ciche Chodzenie^1!");

			cod_set_user_footsteps(id, 1, DEATH);
		} case ARMOR: {
			if (cod_get_user_armor(id) >= 300) {
				cod_print_chat(id, "Mozesz miec maksymalnie^3 300 Pancerza^1!");

				return PLUGIN_HANDLED;
			}

			cod_print_chat(id, "Kupiles^3 Dodatkowy Pancerz^1!");

			cod_add_user_armor(id, cvarArmorAmount);
		} case DAMAGE: {
			if (get_bit(id, damageBonus)) {
				cod_print_chat(id, "W tej rundzie juz kupiles^3 Wieksze Obrazenia^1!");

				return PLUGIN_HANDLED;
			}

			cod_print_chat(id, "Kupiles^3 Wieksze Obrazenia^1!");

			set_bit(id, damageBonus);
		} case INVISIBLE: {
			if (!cod_get_user_render(id)) {
				cod_print_chat(id, "Masz juz^3 Pelna Niewidzialnosc^1!");

				return PLUGIN_HANDLED;
			}

			cod_print_chat(id, "Kupiles^3 Peleryne Niewidke^1!");

			cod_set_user_render(id, 0, DEATH);
		}
	}

	cod_add_user_honor(id, -price);

	return PLUGIN_HANDLED;
}

public cod_damage_post(attacker, victim, weapon, Float:damage, damageBits, hitPlace)
	if (get_bit(attacker, damageBonus)) cod_inflict_damage(attacker, victim, float(cvarDamageAmount), 0.0, damageBits);

public cod_new_round()
	for (new i = 1; i <= MAX_PLAYERS; i++) rem_bit(i, damageBonus);

stock explode(const string[], const character, output[][], const maxParts, const maxLength)
{
	new currentPart = 0, stringLength = strlen(string), currentLength = 0;

	do {
		currentLength += (1 + copyc(output[currentPart++], maxLength, string[currentLength], character));
	} while(currentLength < stringLength && currentPart < maxParts);
}