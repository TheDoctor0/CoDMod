#include <amxmodx>
#include <amxmisc>
#include <ApolloRP>
#include <bot_api>
#include <engine>
#include <fakemeta>

new p_Location
new p_Angle
new p_Model

new g_Npc

new g_SetupMenu[] = "arp_setupmenu"
new g_Keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_0

stock g_SlotNames[] =
{
	'A',
	'B',
	'C',
	'D',
	'E',
	'F',
	'G',
	'H'
}

new g_Slots[33][3][3]

// Thanks to Johnny - all his code, I just ported it and did some small bug fixes
#define MAX_CARDS 22
#define MAX_MENU_CHARS 256

// Each player's cards.
new player_cards[32][MAX_CARDS]
// The cards of the dealer (unique to each player of course).
new dealer_cards[32][MAX_CARDS]

// Each player's bet amount.
new player_bet[32]

public plugin_init() 
{	
	p_Location = register_cvar("arp_casino_npc_origin","0 0 0")
	p_Angle = register_cvar("arp_casino_npc_angle","0")
	p_Model = register_cvar("arp_casino_npc_model","models/mecklenburg/chef.mdl")
	
	//register_menucmd(register_menuid("ARP Slots - Bet:"),1023,"SetSlotsBet")
	//register_menucmd(register_menuid("ARP Slots - Game State:"),1023,"PlaySlotsGame")
	
	register_menucmd(register_menuid("ARP Blackjack - Bet:"),1023,"SetBet")
	register_menucmd(register_menuid("ARP Blackjack - Game State:"),1023,"PlayGame")
	
	set_task(1.0,"LoadNpc")
	
	register_menucmd(register_menuid(g_SetupMenu),g_Keys,"SetupHandle")
}

public ARP_Init()
	ARP_RegisterPlugin("Casino","1.0","Hawk552","Allows players to bet money and play games")

public LoadNpc()
{
	new StrOrigin[33],Float:Origin[3],OriginParts[3][10],Float:Angle = get_pcvar_float(p_Angle),Model[64]
	get_pcvar_string(p_Location,StrOrigin,32)
	get_pcvar_string(p_Model,Model,63)
	
	if(str_to_num(StrOrigin) == 0)
		return
	
	parse(StrOrigin,OriginParts[0],9,OriginParts[1],9,OriginParts[2],9)
	
	for(new Count;Count < 3;Count++)
		Origin[Count] = str_to_float(OriginParts[Count])
	
	if(!(g_Npc = ARP_RegisterNpc("Casino",Origin,Angle,Model,"NpcHandle",0)))
		return
}

public NpcHandle(id,Npc)
{
	ShowMenu(id)
	
	return PLUGIN_HANDLED
}

ShowMenu(id)
{		
	static Menu[512]
	new Keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_0,Len
	
	Len += formatex(Menu[Len],511 - Len,"ARP Casino Menu^n^n")
	Len += formatex(Menu[Len],511 - Len,"1. Blackjack")
	//Len += formatex(Menu[Len],511 - Len,"2. Slots")
	
	Len += formatex(Menu[Len],511 - Len,"^n^n0. Exit")
	
	show_menu(id,Keys,Menu,-1,g_SetupMenu)
}

public SetupHandle(id,Key)
{
	if(!ARP_NpcDistance(id,g_Npc))
		return
	
	switch(Key)
	{
		case 0 :
			StartBlackJack(id)
		//case 1 :
		//	StartSlots(id)
		case 9 :
			return
		default :
			ShowMenu(id)
	}
}

public StartSlots(id)
{
	for(new Count;Count < 3;Count++)
		for(new Count2;Count2 < 3;Count2++)
			g_Slots[id][Count][Count2] = 0
	
	player_bet[id] = 0
	
	ShowSlotsMenu(id)
	
	return PLUGIN_HANDLED
}

public ShowSlotsMenu(id)
{
	new user_base_cash
	new user_money
	new menu_body[255]
	new menu_keys
	new View[4]

	/////////////////		
	// Format the blackjack menu.
	/////////////////

	// Currently they can only press number 5 (for no money) or 0 (for exit)
	menu_keys = (1<<4)|(1<<9)

	// Get how much money they have available.
	user_base_cash = ARP_GetUserWallet(id)
	user_money = user_base_cash - player_bet[id]

	// Enable/disable menu commands according to funds.
	if (user_money >= 1000)
	{
		View[3] = 1
		menu_keys |= (1<<0)
	}

	if (user_money >= 100)
	{
		View[2] = 1
		menu_keys |= (1<<1)
	}

	if (user_money >= 10)
	{
		View[1] = 1
		menu_keys |= (1<<2)
	}

	if (user_money >= 1)
	{
		View[0] = 1
		menu_keys |= (1<<3)
	}
	
	// Put it all together in a big string.
	new Num,Temp[33]
	format(menu_body,255,"ARP Slots - Bet:^n^nCurrent Money: %d^nCurrent bet: %d^n^n", user_base_cash, player_bet[id])
	for(new Count;Count < 4;Count++)
	{
		if(!View[Count])
			continue
		
		format(Temp,32,"%d. %d^n",++Num,power(10,Count))
		add(menu_body,255,Temp)
	}
	
	add(menu_body,255,"^n5. Play Game^n")
	
	add(menu_body,255,"^n0. Exit")
	
	// Send it to the player.
	show_menu(id,menu_keys,menu_body)  
}

public SetSlotsBet(id,key)
{
	switch(key)
	{
		case 0:
		{
			// Add to their bet.
			player_bet[id] += 1
			ShowBetMenu(id)
		}
		case 1:
		{
			// Add to their bet.
			player_bet[id] += 10
			ShowBetMenu(id)
		}
		case 2:
		{
			// Add to their bet.
			player_bet[id] += 100
			ShowBetMenu(id)
		}
		case 3:
		{
			// Add to their bet.
			player_bet[id] += 1000
			ShowBetMenu(id)
		}
		case 4:
		{
			// They're done betting.
			ARP_SetUserWallet(id,ARP_GetUserWallet(id) - player_bet[id])
			ShowGameMenu(id, false)
		}
	}
	return PLUGIN_HANDLED
}

StartBlackJack(id)
{
	new card_num
	
	// Reset the cards for this player (and their dealer)
	for(card_num=0; card_num < MAX_CARDS; card_num++)
	{
		player_cards[id][card_num] = 0
		dealer_cards[id][card_num] = 0
	}

	// Give this player (and their dealer) a couple random cards.
	player_cards[id][0] = random_num(1,13)
	player_cards[id][1] = random_num(1,13)
	dealer_cards[id][0] = random_num(1,13)
	dealer_cards[id][1] = random_num(1,13)
	
	// This player has bet no money yet, yo.
	player_bet[id] = 0

	// Show the betting menu.
	ShowBetMenu(id)
	
	return PLUGIN_CONTINUE
}

ShowBetMenu(id)
{
	new user_base_cash
	new user_money
	new menu_body[255]
	new menu_keys
	new View[4]

	/////////////////		
	// Format the blackjack menu.
	/////////////////

	// Currently they can only press number 5 (for no money) or 0 (for exit)
	menu_keys = (1<<4)|(1<<9)

	// Get how much money they have available.
	user_base_cash = ARP_GetUserWallet(id)
	user_money = user_base_cash - player_bet[id]

	// Enable/disable menu commands according to funds.
	if (user_money >= 1000)
	{
		View[3] = 1
		menu_keys |= (1<<0)
	}

	if (user_money >= 100)
	{
		View[2] = 1
		menu_keys |= (1<<1)
	}

	if (user_money >= 10)
	{
		View[1] = 1
		menu_keys |= (1<<2)
	}

	if (user_money >= 1)
	{
		View[0] = 1
		menu_keys |= (1<<3)
	}
	
	// Put it all together in a big string.
	new Num,Temp[33]
	format(menu_body,255,"ARP Blackjack - Bet:^n^nCurrent Money: %d^nCurrent bet: %d^n^n", user_base_cash, player_bet[id])
	for(new Count;Count < 4;Count++)
	{
		if(!View[Count])
			continue
		
		format(Temp,32,"%d. %d^n",++Num,power(10,Count))
		add(menu_body,255,Temp)
	}
	
	add(menu_body,255,"^n5. Play Game^n")
	
	add(menu_body,255,"^n0. Exit")
	
	// Send it to the player.
	show_menu(id,menu_keys,menu_body)  
}

public SetBet(id,key)
{ 
	switch(key)
	{
		case 0:
		{
			// Add to their bet.
			player_bet[id] += 1
			ShowBetMenu(id)
		}
		case 1:
		{
			// Add to their bet.
			player_bet[id] += 10
			ShowBetMenu(id)
		}
		case 2:
		{
			// Add to their bet.
			player_bet[id] += 100
			ShowBetMenu(id)
		}
		case 3:
		{
			// Add to their bet.
			player_bet[id] += 1000
			ShowBetMenu(id)
		}
		case 4:
		{
			// They're done betting.
			ARP_SetUserWallet(id,ARP_GetUserWallet(id) - player_bet[id])
			ShowGameMenu(id, false)
		}
	}
	return PLUGIN_HANDLED
}

ShowGameMenu(id, game_done)
{
	new player_total = 0 // Player's total (of card values).
	new dealer_total = 0 // Dealer's total (of card values).
	new card_num         // Card incrementer.
	new player_has_ace   // Does the player have an ace?
	new dealer_has_ace   // Does the dealer have an ace?
	new player_cards_string[MAX_CARDS * 3]   // A string for the player's cards.
	new dealer_cards_string[MAX_CARDS * 3]   // A string for the dealer's cards.
	new card_temp_player[3] // A temporary card string.
	new card_temp_dealer[3] // A temporary card string.
	new menu_body[MAX_MENU_CHARS]  // The menu body message.
	new menu_keys       // The menu keys.
	new user_money

	player_has_ace = false
	dealer_has_ace = false

	for (card_num = 0; card_num < MAX_CARDS; card_num++)
	{
		switch(player_cards[id][card_num])
		{
			case 0:
			{
				// No card in this slot.
			}
			case 1:
			{
				// An ace.
				player_has_ace = true
				player_total += 1
				add(player_cards_string, MAX_CARDS * 3, "A ");
			}
			case 11:
			{
				// A Jack.
				player_total += 10
				add(player_cards_string, MAX_CARDS * 3, "J ");
			}
			case 12:
			{
				// A Queen.
				player_total += 10
				add(player_cards_string, MAX_CARDS * 3, "Q ");
			}
			case 13:
			{
				// A King.
				player_total += 10
				add(player_cards_string, MAX_CARDS * 3, "K ");
			}
			case 10:
			{
				// A Ten.
				player_total += 10
				add(player_cards_string, MAX_CARDS * 3, "10 ");
			}
			default:
			{
				// Just a simple number.
				player_total += player_cards[id][card_num]
				format(card_temp_player,3,"%d ",player_cards[id][card_num])
				add(player_cards_string, MAX_CARDS * 3, card_temp_player)
			}
		}
	}

	if (player_total > 21)
	{
		game_done = true
	}
	else if(game_done)
	{
		// Player didn't bust, and the game's over.
		// The dealer needs to play.
		if (player_has_ace && (player_total < 12))
		{
			DealerPlay(id, player_total + 10)
		}
		else
		{
			DealerPlay(id, player_total)
		}
	}

	for (card_num = 0; card_num < MAX_CARDS; card_num++)
	{
		switch(dealer_cards[id][card_num])
		{
			case 0:
			{
				// No card in this slot.
			}
			case 1:
			{
				// An ace.
				dealer_has_ace = true
				dealer_total += 1
				if(card_num==0 && !game_done)
				{
					add(dealer_cards_string, MAX_CARDS * 3, "# ");
				}
				else
				{
					add(dealer_cards_string, MAX_CARDS * 3, "A ");
				}
			}
			case 11:
			{
				// A Jack.
				dealer_total += 10
				if(card_num==0 && !game_done)
				{
					add(dealer_cards_string, MAX_CARDS * 3, "# ");
				}
				else
				{
					add(dealer_cards_string, MAX_CARDS * 3, "J ");
				}
			}
			case 12:
			{
				// A Queen.
				dealer_total += 10
				if(card_num==0 && !game_done)
				{
					add(dealer_cards_string, MAX_CARDS * 3, "# ");
				}
				else
				{
					add(dealer_cards_string, MAX_CARDS * 3, "Q ");
				}
			}
			case 13:
			{
				// A King.
				dealer_total += 10
				if(card_num==0 && !game_done)
				{
					add(dealer_cards_string, MAX_CARDS * 3, "# ");
				}
				else
				{
					add(dealer_cards_string, MAX_CARDS * 3, "K ");
				}
			}
			case 10:
			{
				// A Ten.
				dealer_total += 10
				if(card_num==0 && !game_done)
				{
					add(dealer_cards_string, MAX_CARDS * 3, "# ");
				}
				else
				{
					add(dealer_cards_string, MAX_CARDS * 3, "10 ");
				}
			}
			default:
			{
				// Just a simple number.
				dealer_total += dealer_cards[id][card_num]
				if(card_num==0 && !game_done)
				{
					add(dealer_cards_string, MAX_CARDS * 3, "# ");
				}
				else
				{
					format(card_temp_dealer,3,"%d ",dealer_cards[id][card_num])
					add(dealer_cards_string, MAX_CARDS * 3, card_temp_dealer)
				}
			}
		}
	}

	/////////////////		
	// Format the game menu.
	/////////////////

	if (game_done)
	{
		if (player_has_ace && (player_total < 12))
		{
			player_total += 10
		}

		if (dealer_has_ace && (dealer_total < 12))
		{
			dealer_total += 10
		}

		// They can only restart or exit.
		menu_keys = (1<<8)|(1<<9)

		// Get how much money they have.
		user_money = ARP_GetUserWallet(id)

		if (player_total > 21)
		{
			//They busted!
			format(menu_body,MAX_MENU_CHARS,"ARP Blackjack - Game State:^n^nDealer's cards:   %s^nDealer's total:   %d^n^nYour cards:     %s^nYour total:      %d^n^nYou lost! (You busted)^n^n9. Play again!^n0. Exit", dealer_cards_string, dealer_total, player_cards_string, player_total)
		}
		else if (dealer_total > 21)
		{
			//Dealer busted!
			format(menu_body,MAX_MENU_CHARS,"ARP Blackjack - Game State:^n^nDealer's cards:   %s^nDealer's total:   %d^n^nYour cards:     %s^nYour total:      %d^n^nYou won! (Dealer busted)^n^n9. Play again!^n0. Exit", dealer_cards_string, dealer_total, player_cards_string, player_total)
			ARP_SetUserWallet(id,user_money + (2*player_bet[id]))
		}
		else
		{
			if (player_total > dealer_total)
			{
				//They won
				format(menu_body,MAX_MENU_CHARS,"ARP Blackjack - Game State:^n^nDealer's cards:   %s^nDealer's total:   %d^n^nYour cards:     %s^nYour total:      %d^n^nYou won!^n^n9. Play again!^n0. Exit", dealer_cards_string, dealer_total, player_cards_string, player_total)
				ARP_SetUserWallet(id,user_money + (2*player_bet[id]))
			}
			else if(player_total < dealer_total)
			{
				//Dealer won.
				format(menu_body,MAX_MENU_CHARS,"ARP Blackjack - Game State:^n^nDealer's cards:   %s^nDealer's total:   %d^n^nYour cards:     %s^nYour total:      %d^n^nYou lost!^n^n9. Play again!^n0. Exit", dealer_cards_string, dealer_total, player_cards_string, player_total)
			}
			else
			{
				//Tie game.
				format(menu_body,MAX_MENU_CHARS,"ARP Blackjack - Game State:^n^nDealer's cards:   %s^nDealer's total:   %d^n^nYour cards:     %s^nYour total:      %d^n^nTie game!^n^n9. Play again!^n0. Exit", dealer_cards_string, dealer_total, player_cards_string, player_total)
				ARP_SetUserWallet(id,user_money + player_bet[id])
			}
		}
	}
	else
	{
		// They can hit or stand.
		menu_keys = (1<<0)|(1<<1)
		
		// Format the game board and stuff.
		if (player_has_ace && (player_total < 12))
		{
			format(menu_body,MAX_MENU_CHARS,"ARP Blackjack - Game State:^n^nDealer's cards:   %s^n^nYour cards:     %s^nYour total:      %d (or %d)^n^n1. Hit^n2. Stand", dealer_cards_string, player_cards_string, player_total, player_total + 10)
		}
		else
		{
			format(menu_body,MAX_MENU_CHARS,"ARP Blackjack - Game State:^n^nDealer's cards:   %s^n^nYour cards:     %s^nYour total:      %d^n^n1. Hit^n2. Stand", dealer_cards_string, player_cards_string, player_total)
		}
	}

	// Send it to the player.
	show_menu(id,menu_keys,menu_body)
}

DealerPlay(id, player_total)
{
	new has_ace
	new dealer_total
	new card_num
	new done_playing
	new empty_slot = 0

	done_playing = false

	while(!done_playing)
	{
		for (card_num = 0; card_num < MAX_CARDS; card_num++)
		{
			switch(dealer_cards[id][card_num])
			{
				case 0:
				{
					// No card in this slot.
					if (empty_slot == 0)
					{
						empty_slot = card_num;
					}
				}
				case 1:
				{
					// An ace.
					has_ace = true;
					dealer_total += 1
				}
				case 11:
				{
					// A Jack.
					dealer_total += 10
				}
				case 12:
				{
					// A Queen.
					dealer_total += 10
				}
				case 13:
				{
					// A King.
					dealer_total += 10
				}
				default:
				{
					// Just a simple number.
					dealer_total += dealer_cards[id][card_num]
				}
			}
		}

		if (dealer_total >= player_total)
		{
			// Dealers don't attempt to go over the value they need to.
			done_playing = true
		}
		else
		{
			if (has_ace && (dealer_total < 12))
			{
				// Dealer has a significant ambiguous ace.
				if (dealer_total + 10 >= player_total)
				{
					// Dealer + ace value (as 11) is over player's value.
					done_playing = true
				}
				else
				{
					// Dealer's gonna risk not using the ace.
					dealer_cards[id][empty_slot] = random_num(1,13)
				}
			}
			else
			{
				// Dealer decides to hit.
				dealer_cards[id][empty_slot] = random_num(1,13)
			}
		}
	}
}

public PlayGame(id,key){ 
	new card_num       // A card number incrementer.
	new empty_slot = 0 // An empty card slot (to add a card to).

	switch(key)
	{
		case 0:
		{
			// They're hitting.
			for (card_num = 0; card_num < MAX_CARDS; card_num++)
			{
				if (player_cards[id][card_num] == 0 && empty_slot == 0)
				{
					empty_slot = card_num;
				}
			}
			player_cards[id][empty_slot] = random_num(1,13)
			ShowGameMenu(id, false)
		}
		case 1:
		{
			// They're standing.
			ShowGameMenu(id, true)
		}
		case 8:
		{
			//They want to play again! :D
			StartBlackJack(id)
		}
	}
	return PLUGIN_HANDLED
}
