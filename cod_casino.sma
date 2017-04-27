#include <amxmodx>
#include <sqlx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Casino"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const commandCasino[][] = { "say /kasyno", "say_team /kasyno", "say /casino", "say_team /casino", 
	"say /ruletka", "say_team /ruletka", "say /roulette", "say_team /roulette", "kasyno" };
new const commandDice[][] = { "say /kostka", "say_team /kostka", "say /dice", "say_team /dice", "kostka" };
new const commandRoulette[][] = { "say /ruletka", "say_team /ruletka", "say /roulette", "say_team /roulette", "ruletka" };
new const commandBlackjack[][] = { "say /blackjack", "say_team /blackjack", "blackjack" };
new const commandPoker[][] = { "say /poker", "say_team /poker", "poker" };
new const commandMachine[][] = { "say /automat", "say_team /automat", "say /machine", "say_team /machine", "automat" };
new const commandCoinFlip[][] = { "say /automat", "say_team /automat", "say /machine", "say_team /machine", "automat" };

enum _:gamesInfo { GAME_BID, GAME_TYPE, DICE, ROULETTE, BLACKJACK, POKER, MACHINE, COINFLIP };
enum _:diceInfo { DICE_NUMBER, DICE_TYPE, DICE_NORMAL, DICE_LOWHIGH, DICE_LOW, DICE_HIGH };
enum _:rouletteInfo { ROULETTE_BLACK, ROULETTE_RED, ROULETTE_GREEN };

new playerData[MAX_PLAYERS + 1][GAME_TYPE + 1], playerDice[MAX_PLAYERS + 1][DICE_TYPE + 1], playerRoulette[MAX_PLAYERS + 1];

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for(new i; i < sizeof commandCasino; i++) register_clcmd(commandCasino[i], "casino_menu");
	for(new i; i < sizeof commandDice; i++) register_clcmd(commandDice[i], "dice_menu");
	for(new i; i < sizeof commandRoulette; i++) register_clcmd(commandRoulette[i], "roulette_menu");
	for(new i; i < sizeof commandBlackjack; i++) register_clcmd(commandBlackjack[i], "blackjack_menu");
	for(new i; i < sizeof commandPoker; i++) register_clcmd(commandPoker[i], "poker_menu");
	for(new i; i < sizeof commandMachine; i++) register_clcmd(commandMachine[i], "machine_menu");
	for(new i; i < sizeof commandCoinFlip; i++) register_clcmd(commandCoinFlip[i], "coinflip_menu");

	register_clcmd("KOSTKA_ZMIEN_STAWKE", "dice_change_bid");
}

public client_putinserver(id)
{
	playerData[id][GAME_BID] = 1;
	playerData[id][GAME_TYPE] = 0;

	playerDice[id][DICE_NUMBER] = 1;
	playerDice[id][DICE_TYPE] = DICE_NORMAL;

	playerRoulette[id] = ROULETTE_BLACK;
}

public casino_menu(id, sound)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;

	if(sound) client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menu = menu_create("\yGry w \rKasynie\w:", "casino_menu_handle");
	
	menu_additem(menu, "\wKostka \y(/kostka)");
	menu_additem(menu, "\wRuletka \y(/ruletka)");
	menu_additem(menu, "\wBlackjack \y(/blackjack)");
	menu_additem(menu, "\wPoker \y(/poker)");
	menu_additem(menu, "\wAutomat \y(/automat)");
	menu_additem(menu, "\wRzut Moneta \y(/moneta)");

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public casino_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
    
	switch(item)
	{ 
		case 0: dice_menu(id);
		case 1: roulette_menu(id);
		case 2: blackjack_menu(id);
		case 3: poker_menu(id);
		case 4: machine_menu(id);
		case 5: coinflip_menu(id);
	}
	
	menu_destroy(menu);

	return PLUGIN_CONTINUE;
}

stock dice_menu(id, number = 0)
{
	if(!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	playerData[id][GAME_TYPE] = DICE;

	new menuData[64], menu;

	if(number > 0)
	{
		new bool:win;

		if(playerDice[id][DICE_TYPE] == DICE_NORMAL) if(playerDice[id][DICE_NUMBER] == number) win = true;
		else if(playerDice[id][DICE_NUMBER] <= 3 && playerDice[id][DICE_NUMBER] == DICE_LOW || playerDice[id][DICE_NUMBER] > 3 && playerDice[id][DICE_NUMBER] == DICE_HIGH) win = true;

		cod_set_user_honor(id, win ? (cod_get_user_honor(id) + playerDice[id][DICE_TYPE] == DICE_NORMAL ? playerData[id][GAME_BID]*5 : playerData[id][GAME_BID]) : (cod_get_user_honor(id) - playerData[id][GAME_BID]));

		formatex(menuData, charsmax(menuData), "\yGra w \rKostke\w:^n\wWylosowano \y%s \w- \r%s %i Honoru!\w", number, win ? "Wygrales" : "Przegrales", 
			win ? (playerDice[id][DICE_TYPE] == DICE_NORMAL ? playerData[id][GAME_BID]*6 : playerData[id][GAME_BID]*2) : playerData[id][GAME_BID]);

		menu = menu_create(menuData, "dice_menu_handle");
	}
	else menu = menu_create("\yGra w \rKostke\w:", "dice_menu_handle");

	menu_additem(menu, "\wGraj");
	
	formatex(menuData, charsmax(menuData), "\wTyp \yGry \r[%s]", playerDice[id][DICE_TYPE] == DICE_NORMAL ? "LICZBA" : "LOW/HIGH");
	menu_additem(menu, menuData);

	new numStr[2];
	num_to_str(playerDice[id][DICE_NUMBER], numStr, charsmax(numStr));

	formatex(menuData, charsmax(menuData), "\wTwoj \yTyp \r[%s]", playerDice[id][DICE_TYPE] == DICE_NORMAL ? numStr : (playerDice[id][DICE_NUMBER] == DICE_LOW ? "LOW" : "HIGH"));
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "\wTwoja \yStawka \r[%s]", playerData[id][GAME_BID]);
	menu_additem(menu, menuData);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public dice_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	menu_destroy(menu);
    
	switch(item)
	{ 
		case 0: 
		{
			if(cod_get_user_honor(id) < playerData[id][GAME_BID]) 
			{ 
				cod_print_chat(id, "Nie masz wystarczajaco^x03 honoru^x01, aby grac na tej stawce!");

				return PLUGIN_HANDLED;
			}

			dice_menu(id, random_num(1, 6));

			return PLUGIN_HANDLED;
		}
		case 1: 
		{
			playerDice[id][DICE_TYPE] = playerDice[id][DICE_TYPE] == DICE_NORMAL ? DICE_LOWHIGH : DICE_NORMAL;

			if(playerDice[id][DICE_TYPE] == DICE_NORMAL) playerDice[id][DICE_NUMBER] = 1;
			else playerDice[id][DICE_NUMBER] = DICE_LOW;
		}
		case 2:
		{
			if(playerDice[id][DICE_TYPE] == DICE_NORMAL && ++playerDice[id][DICE_NUMBER] > 6) playerDice[id][DICE_NUMBER] = 1;
			else if(playerDice[id][DICE_TYPE] == DICE_LOWHIGH) playerDice[id][DICE_NUMBER] = playerDice[id][DICE_NUMBER] == DICE_LOW ? DICE_HIGH : DICE_LOW;
		}
		case 3:
		{
			cod_print_chat(id, "Wpisz nowa^x04 stawke^x01.");

			cod_show_hud(id, TYPE_HUD, 255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0, "Wpisz nowa stawke.");

			client_cmd(id, "messagemode ZMIEN_STAWKE");
		}
	}

	return PLUGIN_HANDLED;
}

stock roulette_menu(id, number = -1)
{
	if(!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	playerData[id][GAME_TYPE] = ROULETTE;

	new menuData[64], menu;

	if(number >= 0)
	{
		new bool:win, amount;

		if(playerRoulette[id] == ROULETTE_GREEN && number == 0) win = true;
		else if(playerRoulette[id] == ROULETTE_BLACK && number <= 7) win = true;
		else if(playerRoulette[id] == ROULETTE_RED && number > 7) win = true;

		amount = win ? (playerRoulette[id] == ROULETTE_GREEN ? playerData[id][GAME_BID]*14 : playerData[id][GAME_BID]*2) : playerData[id][GAME_BID];

		cod_set_user_honor(id, win ? (cod_get_user_honor(id) + amount) : (cod_get_user_honor(id) - amount));

		formatex(menuData, charsmax(menuData), "\yGra w \rRuletke\w:^n\wWylosowano \y%s (%s) \w- \r%s %i Honoru!\w", number, number == 0 ? "Zielone" : (number <= 7 ? "Czerwone" : "Czarne"), win ? "Wygrales" : "Przegrales", amount);

		menu = menu_create(menuData, "roulette_menu_handle");
	}
	else menu = menu_create("\yGra w \rRuletke\w:", "roulette_menu_handle");

	menu_additem(menu, "\wGraj");

	formatex(menuData, charsmax(menuData), "\wTwoj \yTyp \r[%s]", playerRoulette[id] == ROULETTE_GREEN ? "ZIELONE" : (playerRoulette[id] == ROULETTE_BLACK ? "CZARNE" : "CZERWONE"));
	menu_additem(menu, menuData);

	formatex(menuData, charsmax(menuData), "\wTwoja \yStawka \r[%s]", playerData[id][GAME_BID]);
	menu_additem(menu, menuData);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public roulette_menu_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	menu_destroy(menu);
    
	switch(item)
	{ 
		case 0: 
		{
			if(cod_get_user_honor(id) < playerData[id][GAME_BID]) 
			{ 
				cod_print_chat(id, "Nie masz wystarczajaco^x03 honoru^x01, aby grac na tej stawce!");

				return PLUGIN_HANDLED;
			}

			roulette_menu(id, random_num(0, 14));

			return PLUGIN_HANDLED;
		}
		case 1: if(++playerRoulette[id] > ROULETTE_GREEN) playerRoulette[id] = ROULETTE_BLACK;
		case 2:
		{
			cod_print_chat(id, "Wpisz nowa^x04 stawke^x01.");

			cod_show_hud(id, TYPE_HUD, 255, 128, 0, 0.24, 0.07, 0, 0.0, 3.5, 0.0, 0.0, "Wpisz nowa stawke.");

			client_cmd(id, "messagemode ZMIEN_STAWKE");
		}
	}

	return PLUGIN_HANDLED;
}

public blackjack_menu(id)
{
	
}

public poker_menu(id)
{

}

public machine_menu(id)
{

}

public coinflip_menu(id)
{

}

public change_bid(id)
{
	if(!is_user_connected(id) || !cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new bidData[16], bid;
	
	read_args(bidData, charsmax(bid));
	remove_quotes(bidData);

	bid = str_to_num(bidData);
	
	if(bid <= 0)
	{ 
		cod_print_chat(id, "Nie mozesz ustawic stawki mniejszej niz^x03 1 honoru^x01!");

		return PLUGIN_HANDLED;
	}
	
	if(cod_get_user_honor(id) < bid) 
	{ 
		cod_print_chat(id, "Nie mozesz ustawic stawki wiekszej niz twoja ilosc^x03 honoru^x01!");

		return PLUGIN_HANDLED;
	}

	playerData[id][GAME_BID] = bid;

	switch(playerData[id][GAME_TYPE])
	{ 
		case DICE: dice_menu(id);
		case ROULETTE: roulette_menu(id);
		case BLACKJACK: blackjack_menu(id);
		case POKER: poker_menu(id);
		case MACHINE: machine_menu(id);
	}
	
	return PLUGIN_HANDLED;
}