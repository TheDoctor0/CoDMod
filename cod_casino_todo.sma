#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <nvault>
#include <xs>

#define PLUGIN "CS1.6Bet.com"
#define VERSION "1.7"
#define AUTHOR "EFFx" // Coinflip and jackpot roll system code by Natsheh - https://forums.alliedmods.net/member.php?u=198418

#if AMXX_VERSION_NUM < 183
#define MAX_PLAYERS 32
#endif

#define ADMIN_ACCESS			ADMIN_IMMUNITY

const TASK_ROULETTE = 			3133
const TASK_DICE =			3134
const TASK_CRASH =			3135
const TASK_CRASH_MENU =			3136
const TASK_LIST =			3137
const TASK_COUNTDOWN =			3138
const MAX_MONEY =			16000
const g_iOneDayInSeconds =		86400

new const g_szCoinModel[] =		"models/coin.mdl"
new const g_szCoinClassName[] =		"coin"

enum Positions
{
	X,
	Y
}

enum hSyncs
{
	Roulling,
	Numbers,
	BestPredictor,
	CrashTime,
	Crashed,
	Won,
	Lost,
	Tails,
	Heads
}

enum dPlayerDatas
{
	bool:bIsBetting,
	bool:bCanUseDailyWheel,
	bool:bIsJackpotGambler,
	iMoneyBetted,
	iDayWins,
	iTimes,
	iLastBet,
	iTimesWon,
	iBetTimes,
	iTimesLose,
	iRouletteBets,
	iDiceBets,
	iCrashBets,
	iJackpotsBets,
	iCoinflipBets,
	iAutoCrashout,
	iMostWonValue,
	iMostLoseValue,
	iDailyWheelTimesUsed,
	iCoinSide,
	Float:fRouletteTime,
	Float:fCrashTimes,
	szMostWonGame[MAX_PLAYERS],
	szMostLostGame[MAX_PLAYERS]
}

enum cPcvars
{
	pCvarMinTimesToUseDailyWheel,
	pCvarRouletteMultiplier,
	pCvarDiceMultiplier,
	pCvarRoulette,
	pCvarDice,
	pCvarCrash,
	pCvarJackpot,
	pCvarSponsorAdmin,
	pCvarMinPlayersToStart,
	pCvarMinBet, 
	pCvarMaxBet,
	pCvarCoinflip,
	pCvarRollType,
	pCvarRollTime
}

new g_dPlayerData[MAX_PLAYERS + 1][dPlayerDatas], pCvars[cPcvars]
new g_iSequence[Positions], g_iBestPredictor, g_iPredictorWins, g_hSync[hSyncs], g_szPredictorName[MAX_PLAYERS]
new g_nVaultBet, gMsgSayText

const MAX_CHANCES = 100
new chances_reserved[MAX_CHANCES][MAX_PLAYERS], g_iJackpotMoney

new g_fwPreThinkPost, Trie:g_tUserChance
new g_iEntity[MAX_PLAYERS + 1]

new g_iValueBetted, bool:g_bIsRolling, g_iCount

new const g_szChatPrefix[] = "^x04[CS1.6Bet Casino]^x01"

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_nVaultBet = nvault_open("Bet_Times")
	if(g_nVaultBet == INVALID_HANDLE)
	{
		set_fail_state("Nvault save file was not opened, failing the plugin..")
	}
	
	g_tUserChance = TrieCreate()
	gMsgSayText = get_user_msgid("SayText")
	
	pCvars[pCvarMinTimesToUseDailyWheel] = register_cvar("bet_minbets_to_daily", "50")
	pCvars[pCvarRouletteMultiplier] = register_cvar("bet_roulette_multiplier", "2")
	pCvars[pCvarDiceMultiplier] = register_cvar("bet_dice_multiplier", "2")
	pCvars[pCvarRoulette] = register_cvar("bet_roulette", "1")
	pCvars[pCvarJackpot] = register_cvar("bet_jackpot", "1")
	pCvars[pCvarCoinflip] = register_cvar("bet_coinflip", "1")
	pCvars[pCvarRollTime] = register_cvar("bet_roll_time_seconds", "60")
	pCvars[pCvarRollType] = register_cvar("bet_roll_type", "1")
	pCvars[pCvarMinPlayersToStart] = register_cvar("bet_jp_minplayers_to_roll", "15")
	pCvars[pCvarMinBet] = register_cvar("bet_jp_minbet", "1000")
	pCvars[pCvarMaxBet] = register_cvar("bet_jp_maxbet", "16000")
	pCvars[pCvarDice] = register_cvar("bet_dice", "1")
	pCvars[pCvarCrash] = register_cvar("bet_crash", "1")
	pCvars[pCvarSponsorAdmin] = register_cvar("bet_sponsor_admin", "a")

	for(new i; i < sizeof g_hSync;i++)
	{
		g_hSync[hSyncs:i] = CreateHudSyncObj()
	}

	register_concmd("amx_allow_daily", "cmdAllowDaily", ADMIN_ACCESS, "<name or #userid> - Player will be able to use daily wheel!")
	register_concmd("amx_reset_data", "cmdResetData", ADMIN_ACCESS, "- Reset nvault data")
	
	register_clcmd("say", "cmdSay")
	register_clcmd("AutoCrashoutValue", "cmdCrashOutValue")
	register_clcmd("jackpot_bet", "cmdBetValue")
	register_clcmd("enter_coin_bet", "clcmd_coinbet")
	
	set_task(1.0, "showBestWinner", .flags = "b")
}

public plugin_precache()
{
	precache_model(g_szCoinModel)
}

public plugin_end()
{
	nvault_close(g_nVaultBet)
	TrieDestroy(g_tUserChance)
}

public client_disconnected(id)
{
	savePlayerBets(id)
	checkPlayerTasks(id)
}

public client_putinserver(id)
{
	loadPlayerBets(id)
}

public cmdAllowDaily(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
		
	new szTarget[MAX_PLAYERS]
	read_argv(1, szTarget, charsmax(szTarget))
	
	new iTarget = cmd_target(id, szTarget, CMDTARGET_NO_BOTS)
	if(!iTarget)
	{
		return PLUGIN_HANDLED
	}
	
	new szAdminName[MAX_PLAYERS], szTargetName[MAX_PLAYERS]
	get_user_name(iTarget, szTargetName, charsmax(szTargetName))
	get_user_name(id, szAdminName, charsmax(szAdminName))
	
	if(g_dPlayerData[iTarget][bCanUseDailyWheel])
	{
		console_print(id, "%s already can use the daily wheel!", szTargetName)
		return PLUGIN_HANDLED
	}
	
	g_dPlayerData[iTarget][bCanUseDailyWheel] = true
	ChatColor(id, "Admin^x04 %s^x01 enabled the daily wheel for^x04 %s^x01.", szAdminName, szTargetName)
	return PLUGIN_HANDLED
}

public cmdResetData(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
		
	new szAdminName[MAX_PLAYERS]
	get_user_name(id, szAdminName, charsmax(szAdminName))
	
	nvault_prune(g_nVaultBet, 0, get_systime() + 1)
	
	new iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum)
	for(new iPlayer, i;i < iNum;i++)
	{
		iPlayer = iPlayers[i]
		
		g_dPlayerData[iPlayer][iBetTimes] = 0
		g_dPlayerData[iPlayer][iMoneyBetted] = 0
		g_dPlayerData[iPlayer][iMostLoseValue] = 0
		g_dPlayerData[iPlayer][iMostWonValue] = 0
		g_dPlayerData[iPlayer][iLastBet] = 0
		g_dPlayerData[iPlayer][iDailyWheelTimesUsed] = 0
		g_dPlayerData[iPlayer][iDiceBets] = 0
		g_dPlayerData[iPlayer][iCrashBets] = 0
		g_dPlayerData[iPlayer][iJackpotsBets] = 0
		g_dPlayerData[iPlayer][iCoinflipBets] = 0
		g_dPlayerData[iPlayer][iDayWins] = 0
		g_dPlayerData[iPlayer][iRouletteBets] = 0
		g_dPlayerData[iPlayer][iTimesLose] = 0
		g_dPlayerData[iPlayer][iTimesWon] = 0
		g_dPlayerData[iPlayer][bCanUseDailyWheel] = true
		
		g_dPlayerData[iPlayer][szMostLostGame] = EOS
		g_dPlayerData[iPlayer][szMostWonGame] = EOS
	}
	ChatColor(id, "Admin^x04 %s^x01 has reseted all player's bet data.", szAdminName)
	return PLUGIN_HANDLED
}

public cmdCrashOutValue(id)
{
	new szValue[5]
	read_argv(1, szValue, charsmax(szValue))
	remove_quotes(szValue)
	
	new iValue = str_to_num(szValue)
	if(!iValue || iValue == 1)
	{
		client_cmd(id, "messagemode AutoCrashoutValue")
		ChatColor(id, "You must set a value that's more than 1!")
		return PLUGIN_HANDLED
	}
	
	g_dPlayerData[id][iAutoCrashout] = iValue
	ChatColor(id, "Auto crashout changed to^x04 %d^x01", g_dPlayerData[id][iAutoCrashout])
	set_task(0.75, "cmdCrashMenu", id + TASK_CRASH_MENU)
	return PLUGIN_HANDLED
}

public cmdSay(id)
{
	new szSay[18]
	read_args(szSay, charsmax(szSay))
	remove_quotes(szSay)

	if(szSay[0] == '/')
	{
		new szCommand[15], szValue[MAX_PLAYERS]
		argbreak(szSay, szCommand, charsmax(szCommand), szValue, charsmax(szValue))
		new iMoneyBet = str_to_num(szValue)

		if(equal(szCommand, "/roulette"))
		{
			if(canBet(id, iMoneyBet, false, true, get_pcvar_num(pCvars[pCvarRoulette])))
			{	
				g_dPlayerData[id][iBetTimes]++
				g_dPlayerData[id][iRouletteBets]++
				
				set_task(2.0, "cmdStartRolling", id + TASK_ROULETTE)
			}
			return PLUGIN_HANDLED
		}
		else if(equal(szCommand, "/dice"))
		{
			if(canBet(id, iMoneyBet, false, true, get_pcvar_num(pCvars[pCvarDice])))
			{
				g_dPlayerData[id][iBetTimes]++
				g_dPlayerData[id][iDiceBets]++
				
				set_task(2.0, "cmdDice", id + TASK_DICE)
			}
			return PLUGIN_HANDLED
		}
		else if(equal(szCommand, "/crash"))
		{
			if(canBet(id, iMoneyBet, true, .iCvarCheck = get_pcvar_num(pCvars[pCvarCrash])))
			{
				set_task(2.1, "cmdCrashMenu", id + TASK_CRASH_MENU)
			}
			return PLUGIN_HANDLED
		}
		else if(equal(szCommand, "/jackpot"))
		{
			if(!get_pcvar_num(pCvars[pCvarJackpot]))
			{
				ChatColor(id, "This game is currently disabled!")
				return PLUGIN_HANDLED
			}
			else if(!is_user_alive(id))
			{
				ChatColor(id, "You must be alive!")
				return PLUGIN_HANDLED
			}
			cmdJackpot(id)
			return PLUGIN_HANDLED
		}
		else if(equal(szCommand, "/coinflip"))
		{
			if(!get_pcvar_num(pCvars[pCvarCoinflip]))
			{
				ChatColor(id, "This game is currently disabled!")
				return PLUGIN_HANDLED
			}
			else if(!is_user_alive(id))
			{
				ChatColor(id, "You must be alive!")
				return PLUGIN_HANDLED
			}
			clcmd_stack_menu(id)
			return PLUGIN_HANDLED
		}
		else if(equal(szCommand, "/betstatus"))
		{
			if(!szValue[0])
			{
				ChatColor(id, "Use /betstatus me or /betstatus <target name>.")
				return PLUGIN_HANDLED
			}
			
			if(equal(szValue, "me"))
			{
				showStatus(id, id)
				return PLUGIN_HANDLED
			}
			else
			{
				new iTarget = cmd_target(id, szValue, (CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS))
				if(!iTarget)
				{
					return PLUGIN_HANDLED
				}
				showStatus(id, iTarget)
				return PLUGIN_HANDLED
			}
		}
		else if(equal(szCommand, "/dailywheel"))
		{
			CheckIfIsTimeToWheel(id)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public cmdJackpot(id)
{	
	new szFormat[75]
	formatex(szFormat, charsmax(szFormat), "Jackpot Menu^n\d- Current jackpot: %d", g_iValueBetted)
	new iMenu = menu_create(szFormat, "jackpot_handler")
	
	menu_additem(iMenu, "Join Jackpot^n\d - Bet a value to join!")
	menu_additem(iMenu, "Gamblers' Chance^n\d - Check gamblers' chance!")
	menu_additem(iMenu, "Get out the pot^n\d- Get outta this round!")
	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}

public jackpot_handler(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED
	}
	
	switch(iItem)
	{
		case 0:
		{
			if(g_dPlayerData[id][bIsJackpotGambler])
			{
				ChatColor(id, "You have already joined!")
				menu_display(id, iMenu)
				return PLUGIN_HANDLED
			}
			else if(g_bIsRolling)
			{
				ChatColor(id, "The jackpot is rolling, you cannot now.")
				menu_display(id, iMenu)
				return PLUGIN_HANDLED
			}
			client_cmd(id, "messagemode jackpot_bet")
			client_print(id, print_center, "Type the value that you wanna bet!")
		}
		case 1:
		{
			if(!g_iCount)
			{
				ChatColor(id, "There's no bets!")
				menu_display(id, iMenu)
				return PLUGIN_HANDLED
			}
			showPlayersChanceMenu(id)
		}
		case 2:
		{
			if(!g_dPlayerData[id][bIsJackpotGambler])
			{
				ChatColor(id, "You haven't joined!")
				menu_display(id, iMenu)
				return PLUGIN_HANDLED
			}
			else if(g_bIsRolling)
			{
				ChatColor(id, "The jackpot is rolling, you cannot now.")
				menu_display(id, iMenu)
				return PLUGIN_HANDLED
			}

			cs_set_user_money(id, cs_get_user_money(id) + g_dPlayerData[id][iMoneyBetted])

			g_dPlayerData[id][iBetTimes]--
			g_dPlayerData[id][iJackpotsBets]--
			g_dPlayerData[id][bIsJackpotGambler] = false

			g_iCount--
			g_iValueBetted -= g_dPlayerData[id][iMoneyBetted]

			new szName[MAX_PLAYERS]
			get_user_name(id, szName, charsmax(szName))
			ChatColor(0, "^x03%s^x01 has abandoned the pot!", szName)
		}
	}
	menu_destroy(iMenu)
	return PLUGIN_HANDLED
}

public showPlayersChanceMenu(id)
{
	new szFormat[100], iMenu = menu_create("Players Chance^n\d- Check player's chance here!", "chance_handler")
	
	new iPlayers[MAX_PLAYERS], iNum, tempid
	get_players(iPlayers, iNum)
	for(new i, iChance, szAuthid[35], szName[MAX_PLAYERS];i < iNum; i++)
	{
		tempid = iPlayers[i]
	
		if(g_dPlayerData[tempid][bIsJackpotGambler])
		{
			get_user_authid(tempid, szAuthid, charsmax(szAuthid))
			TrieGetCell(g_tUserChance, szAuthid, iChance)
			
			get_user_name(tempid, szName, charsmax(szName))
			formatex(szFormat, charsmax(szFormat), "\r%s\w with\y %d%%", szName, iChance)
		
			menu_additem(iMenu, szFormat)
		}
	}
	menu_display(id, iMenu)
}

public chance_handler(id, iMenu)
{
	menu_destroy(iMenu)
}

public cmdBetValue(id)
{
	new szValue[6]
	read_argv(1, szValue, charsmax(szValue))
	new iValue = str_to_num(szValue), iUserMoney = cs_get_user_money(id)
	
	new iCvarMinBet = get_pcvar_num(pCvars[pCvarMinBet])
	new iCvarMaxBet = get_pcvar_num(pCvars[pCvarMaxBet])
	
	if(iValue <= 0)
	{
		ChatColor(id, "You must use a value that's more than 0")
		return PLUGIN_HANDLED
	}
	else if(iValue > iUserMoney)
	{
		ChatColor(id, "You do not have enough money!")
		return PLUGIN_HANDLED
	}
	else if(iValue < iCvarMinBet)
	{
		ChatColor(id, "You must use a value that's more than^x04 %d", iCvarMinBet)
		return PLUGIN_HANDLED
	}
	else if(iValue > iCvarMaxBet)
	{
		ChatColor(id, "You must use a value that's less than^x04 %d", iCvarMaxBet)
		return PLUGIN_HANDLED
	}
	else
	{
		cs_set_user_money(id, (iUserMoney - iValue))
		
		g_iCount++
		g_iValueBetted += iValue
		
		new Float:fTempMoney = float(g_iJackpotMoney)
		fTempMoney += float(iValue)
		
		g_dPlayerData[id][iMoneyBetted] += iValue
		g_dPlayerData[id][iBetTimes]++
		g_dPlayerData[id][iJackpotsBets]++
		g_dPlayerData[id][bIsJackpotGambler] = true

		new szAuthid[MAX_PLAYERS], szName[MAX_PLAYERS]
		get_user_authid(id, szAuthid, charsmax(szAuthid))
		get_user_name(id, szName, charsmax(szName))
	
		new iChance
		for(new i, start, iChances, j; i < g_iCount; i++)
		{
			iChance = floatround((iValue / fTempMoney) * MAX_CHANCES)
			iChances += iChance
			TrieSetCell(g_tUserChance, szAuthid, iChance)
			
			if(iChances > MAX_CHANCES) 
			{
				iChances = MAX_CHANCES
			}
			
			for(j = start; j < iChances <= MAX_CHANCES; j++)
			{
				chances_reserved[j] = szAuthid
			}
			
			start = iChances
		}
		
		ChatColor(0, "Player^x04 %s^x01 has joined the jackpot betting^x04 %d$^x01 with^x04 %d%%^x01 chance!", szName, iValue, iChance)
		
		if(checkPlayersInJackpot() == 1)
		{
			if(!task_exists(TASK_LIST))
			{
				set_task(1.0, "showPlayersList", TASK_LIST, .flags = "b")
			}
		}		
	}
	return PLUGIN_HANDLED
}

public showPlayersList()
{
	static iRollTime
	
	if(!checkPlayersInJackpot())
	{
		iRollTime = 0
		ChatColor(0, "There's no jackpot gamblers, ending this round...")
		resetData(0)
		return
	}

	new szHud[75]

	switch(get_pcvar_num(pCvars[pCvarRollType]))
	{
		case 0:
		{
			new iPlayersNeeded = get_pcvar_num(pCvars[pCvarMinPlayersToStart])
			if(checkPlayersInJackpot() >= iPlayersNeeded)
			{
				set_task(1.0, "rollMsg", .flags = "a", .repeat = 4)
				remove_task(TASK_LIST)
			}
			else
			{
				formatex(szHud, charsmax(szHud), "%d of %d players needed^nto roll!", checkPlayersInJackpot(), iPlayersNeeded)
			}
		}
		default:
		{
			new szTime[10]

			if(!iRollTime)
			{
				iRollTime = get_pcvar_num(pCvars[pCvarRollTime])
			}
			
			if(--iRollTime == 1)
			{
				if(checkPlayersInJackpot() != 1)
				{
					ChatColor(0, "The jackpot needs more than 1 gambler to roll. Ending that round...")
					resetData(1)
				}
				else
				{
					set_task(1.0, "rollMsg", .flags = "a", .repeat = 4)
				}
				
				remove_task(TASK_LIST)
			}

			format_time(szTime, charsmax(szTime), "%M:%S", iRollTime)
			formatex(szHud, charsmax(szHud), "Jackpot will roll in^n        %s^nPot value: %d", szTime, g_iValueBetted)
			
		}
	}
	
	set_hudmessage(0, 200, 0, 0.75, 0.10, 0, 1.0, 1.0)
	show_hudmessage(0, szHud)
}

public rollMsg()
{
	static iTime
	if(!iTime)
	{
		iTime = 4
		g_bIsRolling = true
				
		ChatColor(0, "Rolling...")
		set_task(3.8, "roll")
	}
	set_hudmessage(0, 200, 0, 0.75, 0.10, 0, 1.0, 1.0)
	show_hudmessage(0, "Rolling in %d...", iTime--)
}

public roll()
{
	new iRand = random(MAX_CHANCES), iRandomPlayer = is_user_connected_byauthid(chances_reserved[iRand])
	
	if(!is_user_connected(iRandomPlayer) || !g_dPlayerData[iRandomPlayer][bIsJackpotGambler])
	{
		roll()
		return
	}
	
	setUserMoney(iRandomPlayer, g_iValueBetted, "Jackpot")
	
	new iPlayers[MAX_PLAYERS], iNum, id
	get_players(iPlayers, iNum)
	for(new i;i < iNum; i++)
	{
		id = iPlayers[i]
		
		if(id != iRandomPlayer && g_dPlayerData[id][bIsJackpotGambler])
		{
			setSett(id, 0, "Jackpot")
		}
	}

	resetData(0)
}

public clcmd_coinbet(id)
{
	if(g_dPlayerData[id][bIsBetting]) 
	{
		ChatColor(id, "You're already betting!")
		return PLUGIN_HANDLED
	}
	
	new szArgs[30]
	read_args(szArgs, charsmax(szArgs))
	remove_quotes(szArgs)
	
	new iAmount = str_to_num(szArgs)
	if(iAmount <= 0)
	{
		ChatColor(id, "You must use a value that's more than 0")
		return PLUGIN_HANDLED
	}
	else if(iAmount > cs_get_user_money(id)) 
	{
		ChatColor(id, "You do not have enough money!")
		return PLUGIN_HANDLED
	}
	else 
	{
		g_dPlayerData[id][iMoneyBetted] = iAmount
		clcmd_stack_menu(id)
	}
	return PLUGIN_HANDLED
}

public clcmd_stack_menu(id)
{
	if(g_dPlayerData[id][bIsBetting]) 
	{
		ChatColor(id, "You're already betting!")
		return PLUGIN_HANDLED
	}
	
	new menu = menu_create("\rCoin Challenge^n\d- Choose your stack!", "coin_menu_handle")
	
	new szText[60]
	formatex(szText, charsmax(szText), "\wChoose your Stack: \r%d$^n\d- How much do ya wanna bet?", g_dPlayerData[id][iMoneyBetted])
	menu_additem(menu, szText, "STACK")
	menu_additem(menu, "\rReady!^n\d- Lets challenge someone?!", "STACK")
	
	menu_display(id, menu)
	return PLUGIN_HANDLED
}

public clclmd_coin_menu(id)
{
	if(!g_dPlayerData[id][iMoneyBetted])
	{
		ChatColor(id, "Choose your stack!")
		return PLUGIN_HANDLED
	}
	
	new iMenu = menu_create("\rCoin Challenge^n\yChoose your opponent!", "coin_menu_handle")
	
	new iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum)
	
	for(new i, szName[MAX_PLAYERS], player, szInfo[3]; i < iNum; i++)
	{
		player = iPlayers[i]
		
		if(player == id || g_dPlayerData[player][bIsBetting]) 
		{
			continue
		}
		
		get_user_name(player, szName, charsmax(szName))
		num_to_str(player, szInfo, charsmax(szInfo))
		menu_additem(iMenu, szName, szInfo)
	}
	
	menu_display(id, iMenu)
	return PLUGIN_HANDLED
}

public coin_menu_handle(id, iMenu, iItem)
{
	if(iItem == MENU_EXIT || g_dPlayerData[id][bIsBetting])
	{
		menu_destroy(iMenu)
		return PLUGIN_HANDLED
	}
	
	new sData[12], iAccess, iCallback
	menu_item_getinfo(iMenu, iItem, iAccess, sData, charsmax(sData), "", 0, iCallback)
	menu_destroy(iMenu)
	
	if(equal(sData, "STACK"))
	{
		switch(iItem)
		{
			case 0:
			{
				client_print(id, print_center, "Choose an amount of money above than zero!")
				client_cmd(id, "messagemode enter_coin_bet")
			}
			case 1: 
			{
				clclmd_coin_menu(id)
			}
		}
		
		return PLUGIN_HANDLED
	}
	
	if(equal(sData, "DUEL", 4))
	{	
		strtok(sData, "", 0, sData, charsmax(sData), '|')
		
		new player = str_to_num(sData)
		if(!player || g_dPlayerData[player][bIsBetting]) 
		{
			clclmd_coin_menu(id)
			return PLUGIN_HANDLED
		}
		
		new szPlayerName[MAX_PLAYERS], szTargetName[MAX_PLAYERS]
		get_user_name(player, szTargetName, charsmax(szTargetName))
		get_user_name(id, szPlayerName, charsmax(szPlayerName))
		
		switch(iItem)
		{
			case 0:
			{
				ChatColor(0, "^x03%s^x01 vs.^x03 %s^x01 in coin flip challenge!", szTargetName, szPlayerName)
				
				new iRandomValue = random_num(1, 2), bool:bChanceX = bool:(iRandomValue == 1)
				
				set_hudmessage(101, 236, 38, -1.0, 0.34, 0, 6.0, 4.0)
				show_hudmessage(bChanceX ? id : player, g_hSync[Tails], "You are Tails!")
				
				set_hudmessage(101, 236, 38, -1.0, 0.34, 0, 6.0, 4.0)
				show_hudmessage(bChanceX ? player : id, g_hSync[Heads], "You are Heads!")
				
				if(!get_challengers_num() && !g_fwPreThinkPost)
				{
					g_fwPreThinkPost = register_forward(FM_PlayerPreThink, "fw_client_prethink_post", 1)
				}
				
				g_dPlayerData[id][bIsBetting] = true
				g_dPlayerData[id][iBetTimes]++
				g_dPlayerData[id][iCoinflipBets]++
				
				setData(id, g_dPlayerData[id][iMoneyBetted], false)
				setData(player, g_dPlayerData[id][iMoneyBetted], false)
				
				g_dPlayerData[player][iCoinflipBets]++
				g_dPlayerData[player][bIsBetting] = true
				g_dPlayerData[player][iBetTimes]++
				
				new iOppositeValue[2]
				iOppositeValue[0] = bChanceX ? 2 : 1
				iOppositeValue[1] = bChanceX ? 1 : 2
				
				remove_task(TASK_COUNTDOWN)
				
				g_dPlayerData[id][iCoinSide] = iOppositeValue[0]
				g_dPlayerData[player][iCoinSide] = iOppositeValue[1]
				
				display_coin(id, iOppositeValue[0])
				display_coin(player, iOppositeValue[1])
				
				ChatColor(0, "^x03%s^x01 is^x04 tails^x01 &^x03 %s^x01 is^x04 heads!", bChanceX ? szPlayerName : szTargetName, bChanceX ? szTargetName : szPlayerName)
			}
			case 1:
			{
				remove_task(TASK_COUNTDOWN)
				ChatColor(player, "^x03%s^x01 has denied your coin challenge!", szPlayerName)
			}
		}
		return PLUGIN_HANDLED
	}
		
	new player = str_to_num(sData)
	if(!player || g_dPlayerData[player][bIsBetting]) 
	{
		clclmd_coin_menu(id)
		return PLUGIN_HANDLED
	}
		
	ChatColor(id, "Waiting the target to accept!")
	
	coin_menu_duel(id, player)
	return PLUGIN_HANDLED
}

public countdown(iData[3])
{
	new id = iData[0]
	new iTarget = iData[1]
	new iMenu = iData[2]

	static iTime
	
	new szTargetName[MAX_PLAYERS]
	get_user_name(iTarget, szTargetName, charsmax(szTargetName))
	
	if(!is_user_connected(iTarget))
	{
		ChatColor(id, "%s has disconnected!", szTargetName)
		
		iTime = 0
		g_dPlayerData[id][bIsBetting] = false

		remove_task(TASK_COUNTDOWN)
		return
	}
	
	if(!iTime)
	{
		iTime = 8
	}
	set_hudmessage(0, 255, 0, -1.0, 0.30, 0, 1.0, 1.0)
	show_hudmessage(iTarget, "%d second%s to auto-deny the challenge!", iTime--, (iTime > 1) ? "s" : "")
	
	if(!iTime)
	{
		menu_destroy(iMenu)
		
		remove_task(TASK_COUNTDOWN)	
		g_dPlayerData[id][bIsBetting] = false
		g_dPlayerData[iTarget][bIsBetting] = false
		
		ChatColor(id, "^x03%s^x01 has denied your coin challenge!", szTargetName)
		ChatColor(iTarget, "You didn't select any option, menu destroyed.")
	}
}

public coin_menu_duel(id, target)
{	
	new szText[MAX_PLAYERS * 2], szName[MAX_PLAYERS]
	get_user_name(id, szName, charsmax(szName))
	
	formatex(szText, charsmax(szText), "\w%s has Challenged you for \r%d$^n\yIn a coin flip game!^n", szName, g_dPlayerData[id][iMoneyBetted])
	new iMenu = menu_create(szText, "coin_menu_handle")
	
	formatex(szText, charsmax(szText), "DUEL|%d", id)
	menu_additem(iMenu, "Accept the Challenge!", szText)
	menu_additem(iMenu, "Deny the Challenge!", szText)
	
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER)
	
	menu_display(target, iMenu)
	
	new iData[3]
	iData[0] = id
	iData[1] = target
	iData[2] = iMenu
	
	set_task(1.0, "countdown", TASK_COUNTDOWN, iData, sizeof iData, "b")
}

public task_chosen_side(const ent)
{
	new classname[6]
	pev(ent, pev_classname, classname ,charsmax(classname))
	
	if(!pev_valid(ent) || !equal(classname, g_szCoinClassName)) 
	{
		return
	}
	
	set_pev(ent, pev_sequence, 0)
	set_pev(ent, pev_frame, 1.0)
	set_pev(ent, pev_framerate, 1.0)
	if(pev(ent, pev_iuser4) == 2) 
	{
		set_pev(ent, pev_iuser3, 1)
	}

	new iOwner = pev(ent, pev_iuser2)
	
	switch(g_dPlayerData[iOwner][iCoinSide] == pev(ent, pev_iuser4)) 
	{
		case true:
		{
			setUserMoney(iOwner, g_dPlayerData[iOwner][iMoneyBetted], "Coinflip")
			
			setSett(iOwner, 1, "Coinflip")
		}
		case false: 
		{
			setSett(iOwner, 0, "Coinflip")
		}
	}
	
	set_task(3.0, "removeCoin", iOwner)
}

public removeCoin(id)
{	
	g_dPlayerData[id][iCoinSide] = 0
	g_dPlayerData[id][iMoneyBetted] = 0
	g_dPlayerData[id][bIsBetting] = false

	new iEnt = -1
	while((iEnt = find_ent_by_class(iEnt, g_szCoinClassName)))
	{
		engfunc(EngFunc_RemoveEntity, iEnt)
	}
	
	g_iEntity[id] = 0

	if(!get_challengers_num() && g_fwPreThinkPost)
	{
		unregister_forward(FM_PlayerPreThink, g_fwPreThinkPost, 1)
		g_fwPreThinkPost = 0
	}
}

public fw_client_prethink_post(target)
{
	static iEnt
	if((iEnt = g_iEntity[target]) > 0)
	{
		static Float:fOrigin[3], Float:fAim[3]
		pev(target, pev_origin, fOrigin)
		pev(target, pev_view_ofs, fAim)
		
		xs_vec_add(fOrigin, fAim, fOrigin)
		pev(target, pev_v_angle, fAim)
		
		angle_vector(fAim, ANGLEVECTOR_FORWARD, fAim)
		xs_vec_mul_scalar(fAim, 10.0, fAim)
		xs_vec_add(fOrigin, fAim, fOrigin)
		pev(target, pev_v_angle, fAim)
		
		set_pev(iEnt, pev_origin, fOrigin)
		pev(iEnt, pev_angles, fOrigin)
	
		fAim[0] = fOrigin[0]
		fAim[2] = fOrigin[2]
		fAim[1] += 180.0
	
		if(pev(iEnt, pev_iuser3) == 1)
		{
			fAim[1] += 180.0
		}
		
		set_pev(iEnt, pev_angles, fAim)
	}
}

public cmdCrashMenu(id)
{
	id -= TASK_CRASH_MENU

	new iMenu = menu_create("Crash Menu", "crash_menu_handler"), szItemFormat[75], szValue[2]

	menu_additem(iMenu, g_dPlayerData[id][bIsBetting] ? "\dStart Crash [ALREADY BETTING]" : "Start Crash")
	
	num_to_str(g_dPlayerData[id][iAutoCrashout], szValue, charsmax(szValue))
	formatex(szItemFormat, charsmax(szItemFormat), g_dPlayerData[id][bIsBetting] ? "\dAuto Crashout: %s [ALREADY BETTING]" : "Auto Crashout: %s", (g_dPlayerData[id][iAutoCrashout] > 0) ? szValue : "NO LIMIT")
	menu_additem(iMenu, szItemFormat)
	
	menu_additem(iMenu, g_dPlayerData[id][bIsBetting] ? "Crashout" : "\dCrashout [CRASH IS OFF]")

	menu_display(id, iMenu)
}

public crash_menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	switch(item)
	{
		case 0:
		{
			if(!g_dPlayerData[id][bIsBetting])
			{
				set_task(2.0, "cmdCrash", id + TASK_CRASH)
				setData(id, g_dPlayerData[id][iMoneyBetted], true)
				
				g_dPlayerData[id][iBetTimes]++
				g_dPlayerData[id][iCrashBets]++
				
				g_dPlayerData[id][bIsBetting] = true
				
				g_dPlayerData[id][fCrashTimes] = _:1.0
			}			
			else
			{
				ChatColor(id, "You're betting already.")
			}
			set_task(0.75, "cmdCrashMenu", id + TASK_CRASH_MENU)
			return PLUGIN_HANDLED
		}
		case 1:
		{
			if(!g_dPlayerData[id][bIsBetting])
			{
				client_cmd(id, "messagemode AutoCrashoutValue")
				return PLUGIN_HANDLED
			}
			else
			{
				ChatColor(id, "You're betting already, the auto crashout value can not be changed.")
				set_task(0.75, "cmdCrashMenu", id + TASK_CRASH_MENU)
				return PLUGIN_HANDLED
			}
		}
		case 2:
		{
			if(g_dPlayerData[id][bIsBetting])
			{
				crashMessage(id)
				crashSetMoney(id)
				return PLUGIN_HANDLED
			}
			else
			{
				ChatColor(id, "You're not betting for crashout!")
				set_task(0.75, "cmdCrashMenu", id + TASK_CRASH_MENU)
			}
		}
	}
	return PLUGIN_HANDLED
}

public cmdCrash(id)
{
	id -= TASK_CRASH
	
	new iRandomNumber = random_num(1, 100), RGB[3];RGB = {220, 0, 0}
	
	if(g_dPlayerData[id][fCrashTimes] >= 2.0)
	{
		RGB = {0, 255, 0}
	}
	
	g_dPlayerData[id][fCrashTimes] += 0.1
	
	set_hudmessage(RGB[0], RGB[1], RGB[2], -1.0, 0.40, 0, 1.0, 0.2)
	ShowSyncHudMsg(id, g_hSync[CrashTime], "%.2f", g_dPlayerData[id][fCrashTimes])
	
	set_task(0.2, "cmdCrash", id + TASK_CRASH)
	
	if(g_dPlayerData[id][iAutoCrashout] > 0)
	{
		if(g_dPlayerData[id][fCrashTimes] >= g_dPlayerData[id][iAutoCrashout])
		{
			crashSetMoney(id)
			crashMessage(id)

			setSett(id, 1, "Crash")
			return
		}
	}
	
	if(getChance(id, "Crash") >= iRandomNumber)
	{
		crashMessage(id)
		
		setSett(id, 0, "Crash")
		return
	}
}

public showBestWinner()
{
	static szHour[3], szMinutes[3]
	get_time("%H", szHour, charsmax(szHour))
	get_time("%M", szMinutes, charsmax(szMinutes))
	
	new iHour = str_to_num(szHour), iMinutes = str_to_num(szMinutes)
	if(iHour == 00 && iMinutes == 00)
	{
		g_iBestPredictor = 0
		g_iPredictorWins = 0
		arrayset(g_szPredictorName, 0, charsmax(g_szPredictorName))
		return
	}
	
	if(!g_szPredictorName[0])
		return
			
	set_hudmessage(0, 255, 0, 0.70, 0.50, 0, 1.0, 1.0)
	ShowSyncHudMsg(0, g_hSync[BestPredictor], "BEST PREDICTOR OF THE DAY^n%s with %d win%s", g_szPredictorName, g_iPredictorWins, (g_iPredictorWins > 1) ? "s" : "")
}

public cmdStartRolling(id)
{
	id -= TASK_ROULETTE
	
	new iRandomNumber = random_num(0, 100)
	set_hudmessage(0, 255, 0, selectRandomXPosition(), selectRandomYPosition(), 0, 1.0, g_dPlayerData[id][fRouletteTime])
	ShowSyncHudMsg(id, g_hSync[Numbers], "%d", iRandomNumber)
	
	set_task(g_dPlayerData[id][fRouletteTime], "cmdStartRolling", id + TASK_ROULETTE)
		
	g_dPlayerData[id][iTimes]++
	switch(g_dPlayerData[id][iTimes])
	{
		case 12..22:	g_dPlayerData[id][fRouletteTime] = _:0.2
		case 23..26:	g_dPlayerData[id][fRouletteTime] = _:0.4
		case 27..33:	g_dPlayerData[id][fRouletteTime] = _:0.6
		case 34..37:	g_dPlayerData[id][fRouletteTime] = _:0.8
		case 38..41:	g_dPlayerData[id][fRouletteTime] = _:1.0
		case 42:
		{
			g_dPlayerData[id][iTimes] = 0
			g_dPlayerData[id][fRouletteTime] = _:0.1
			
			g_dPlayerData[id][bIsBetting] = false
			
			remove_task(id + TASK_ROULETTE)
			
			if(iRandomNumber >= getChance(id, "Roulette"))
			{
				setUserMoney(id, (g_dPlayerData[id][iMoneyBetted] * get_pcvar_num(pCvars[pCvarRouletteMultiplier])), "Roulette")
				return
			}
			else
			{
				if(iRandomNumber != 0)
				{
					setSett(id, 0, "Roulette")

					ChatColor(id, "You lost^x04 %d$^x01 betting on roulette. Try again...", g_dPlayerData[id][iMoneyBetted])
					return
				}
				else
				{
					setUserMoney(id, (g_dPlayerData[id][iMoneyBetted] * 14), "Roulette")
				}
			}
		}
	}
}

public cmdDice(id)
{
	id -= TASK_DICE
	
	g_dPlayerData[id][bIsBetting] = false
	
	new iRandomNumber = random_num(1, 100)
	if(iRandomNumber >= getChance(id, "Dice"))
	{
		setUserMoney(id, (g_dPlayerData[id][iMoneyBetted] * get_pcvar_num(pCvars[pCvarDiceMultiplier])), "Dice")
		return
	}
	else
	{
		setSett(id, 0, "Dice")
		
		ChatColor(id, "You lost^x04 %d$^x01 betting on dice. Try again...", g_dPlayerData[id][iMoneyBetted])
	}
}

showStatus(id, target)
{
	ChatColor(id, "Check your console!")
	
	new szTargetName[MAX_PLAYERS]
	get_user_name(target, szTargetName, charsmax(szTargetName))
	
	if(!g_dPlayerData[target][szMostWonGame])
	{
		formatex(g_dPlayerData[target][szMostWonGame], charsmax(g_dPlayerData[]), "Unknown")
	}
	
	if(!g_dPlayerData[target][szMostLostGame])
	{
		formatex(g_dPlayerData[target][szMostLostGame], charsmax(g_dPlayerData[]), "Unknown")
	}
	
	console_print(id, "============= %s's status =============", szTargetName)
	console_print(id, "Times bet: %d, TimesWon: %d, TimesLose: %d, Daily wheels: %d", g_dPlayerData[target][iBetTimes], g_dPlayerData[target][iTimesWon], g_dPlayerData[target][iTimesLose], g_dPlayerData[target][iDailyWheelTimesUsed])
	console_print(id, "Most won value: %d$ on %s, Most lose value: %d$ on %s", g_dPlayerData[target][iMostWonValue], g_dPlayerData[target][szMostWonGame], g_dPlayerData[target][iMostLoseValue], g_dPlayerData[target][szMostLostGame])
	console_print(id, "Bets on roulette: %d, Bets on dice: %d, Bets on crash: %d, Bets on Jackpot: %d, Bets on Coinflip: %d", g_dPlayerData[target][iRouletteBets], g_dPlayerData[target][iDiceBets], g_dPlayerData[target][iCrashBets], g_dPlayerData[target][iJackpotsBets], g_dPlayerData[target][iCoinflipBets])
	console_print(id, "==================================================")
}

crashMessage(id)
{
	set_hudmessage(220, 0, 0, -1.0, 0.30, 0, 1.0, 1.0)
	ShowSyncHudMsg(id, g_hSync[Crashed], "CRASHED!")

	remove_task(id + TASK_CRASH)
	
	show_menu(id, 0, "^n")
	g_dPlayerData[id][bIsBetting] = false
}

setUserMoney(id, iWonValue, szGameName[])
{
	new szWinnerName[MAX_PLAYERS], szMsg[150]
	get_user_name(id, szWinnerName, charsmax(szWinnerName))
	
	if(szGameName[0] == 'J')
	{
		new szAuthid[35], iChance
		get_user_authid(id, szAuthid, charsmax(szAuthid))
		TrieGetCell(g_tUserChance, szAuthid, iChance)
	
		formatex(szMsg, charsmax(szMsg), "^x03%s^x01 won^x04 %d$^x01 with^x04 %d percent^x01 chance!", szWinnerName, g_iValueBetted, iChance)
	}
	else
	{
		formatex(szMsg, charsmax(szMsg), "Player^x04 %s^x01 won^x04 %d$^x01 betting^x04 %d$^x01 on^x04 %s^x01.", szWinnerName, iWonValue, g_dPlayerData[id][iMoneyBetted], szGameName)
	}
	ChatColor(0, szMsg)
			
	cs_set_user_money(id, clamp((cs_get_user_money(id) + iWonValue), 0, MAX_MONEY), 1)
	
	if(szGameName[0] == 'R')
	{
		g_dPlayerData[id][iDayWins]++

		g_iBestPredictor = get_best()
		g_iPredictorWins = g_dPlayerData[g_iBestPredictor][iDayWins]
		get_user_name(g_iBestPredictor, g_szPredictorName, charsmax(g_szPredictorName))
	}
	
	if(!(equal(szGameName, "Crash")))
	{
		set_hudmessage(0, 250, 0, -1.0, 0.30, 0, 1.0, 1.0)
		ShowSyncHudMsg(id, g_hSync[Won], "YOU WON!")
	}

	setSett(id, 1, szGameName)
}

get_best()
{
	new iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum)
	SortCustom1D(iPlayers, iNum, "get_best_player")
	
	return iPlayers[0]
}

public get_best_player(id1, id2)
{
	if(g_dPlayerData[id1][iDayWins] > g_dPlayerData[id2][iDayWins])
		return -1
		
	else if(g_dPlayerData[id2][iDayWins] < g_dPlayerData[id1][iDayWins])
		return 1
		
	return 0
}

Float:selectRandomXPosition()
{
	new Float:fReturnValue
	
	if(g_iSequence[X] <= 3)
	{
		g_iSequence[X]++
	}
	else
	{
		g_iSequence[X] = 1
	}
		
	switch(g_iSequence[X])
	{
		case 1:
		{
			fReturnValue = -1.0
		}
		case 2:
		{
			fReturnValue = 0.65
		}
		case 3:
		{
			fReturnValue = 0.50
		}
		case 4:
		{
			fReturnValue = 0.30
		}
	}
	return fReturnValue
}

Float:selectRandomYPosition()
{
	new Float:fReturnValue
	
	if(g_iSequence[Y] <= 3)
	{
		g_iSequence[Y]++
	}
	else
	{
		g_iSequence[Y] = 1
	}
	
	switch(g_iSequence[Y])
	{
		case 1:
		{
			fReturnValue = 0.30
		}
		case 2:
		{
			fReturnValue = 0.45
		}
		case 3:
		{
			fReturnValue = 0.60
		}
		case 4:
		{
			fReturnValue = 0.40
		}
	}
	return fReturnValue
}

bool:canBet(id, iMoneyBet, bool:bIsCrash = false, bool:bMessage = false, iCvarCheck)
{
	if(!iCvarCheck)
	{
		ChatColor(id, "This game is currently disabled!")
		return false
	}
	else if(iMoneyBet <= 0)
	{
		ChatColor(id, "You must bet a value that's more than 0!")
		return false
	}
	else if(cs_get_user_money(id) < iMoneyBet)
	{
		ChatColor(id, "You can not bet more than you have!")
		return false
	}
	else if(g_dPlayerData[id][bIsBetting])
	{
		ChatColor(id, "You're already betting!")
		return false
	}
	else if((iMoneyBet * get_pcvar_num(pCvars[pCvarRouletteMultiplier])) > MAX_MONEY
	|| (iMoneyBet * get_pcvar_num(pCvars[pCvarDiceMultiplier]) > MAX_MONEY))
	{
		ChatColor(id, "You can not win more than^x04 %d$^x01. Bet less than it!", MAX_MONEY)
		return false
	}
	
	g_dPlayerData[id][iMoneyBetted] = iMoneyBet

	if(!bIsCrash)
	{
		setData(id, iMoneyBet, bMessage ? true : false)
	}
	return true
}

crashSetMoney(id)
{
	setUserMoney(id, floatround(g_dPlayerData[id][iMoneyBetted] * g_dPlayerData[id][fCrashTimes]), "Crash")
}

setData(id, iMoneyBet, bool:bHud)
{
	if(bHud)
	{
		ChatColor(id, "Rolling...")
								
		set_hudmessage(0, 255, 0, -1.0, 0.40, 0, 1.0, 1.8)
		ShowSyncHudMsg(id, g_hSync[Roulling], "ROLLING...")
	}
	
	cs_set_user_money(id, (cs_get_user_money(id) - iMoneyBet), 1)
}

resetData(setTheChange)
{
	g_bIsRolling = false
	g_iValueBetted = 0
	g_iCount = 0
	g_iJackpotMoney = 0

	remove_task(TASK_LIST)
	
	new iPlayers[MAX_PLAYERS], iNum, id
	get_players(iPlayers, iNum)
	for(new i;i < iNum; i++)
	{
		id = iPlayers[i]
		
		if(setTheChange)
		{
			if(g_dPlayerData[id][bIsJackpotGambler])
			{
				cs_set_user_money(id, cs_get_user_money(id) + g_dPlayerData[id][iMoneyBetted])
			}
		}

		g_dPlayerData[id][bIsJackpotGambler] = false
		g_dPlayerData[id][iMoneyBetted] = 0
	}
	
	TrieClear(g_tUserChance)
}

checkPlayersInJackpot()
{
	new iPlayers[MAX_PLAYERS], iNum, iPlayersNum
	get_players(iPlayers, iNum)
	for(new i;i < iNum; i++)
	{
		if(g_dPlayerData[iPlayers[i]][bIsJackpotGambler])
		{
			iPlayersNum++
		}
	}
	return iPlayersNum
}

checkPlayerTasks(id)
{
	if(task_exists(id + TASK_ROULETTE))
	{
		remove_task(id + TASK_ROULETTE)
	}
	
	if(task_exists(id + TASK_DICE))
	{
		remove_task(id + TASK_DICE)
	}
	
	if(task_exists(id + TASK_CRASH_MENU))
	{
		remove_task(id + TASK_CRASH_MENU)
	}
	
	if(task_exists(id + TASK_CRASH))
	{
		remove_task(id + TASK_CRASH)
	}
}

savePlayerBets(id)
{
	new szAuthID[35]
	get_user_authid(id, szAuthID, charsmax(szAuthID))
	
	new szVaultKey[128], szVaultData[512]
	formatex(szVaultKey, charsmax(szVaultKey), "Bet-%s-Save", szAuthID)
	formatex
	(
		szVaultData, charsmax(szVaultData), " %d %d %d %d %d %d %d %d %d %d %d %d %s %s", 
		g_dPlayerData[id][iBetTimes], 
		g_dPlayerData[id][iTimesLose], 
		g_dPlayerData[id][iTimesWon],
		g_dPlayerData[id][iRouletteBets], 
		g_dPlayerData[id][iDiceBets],
		g_dPlayerData[id][iJackpotsBets],
		g_dPlayerData[id][iCoinflipBets],
		g_dPlayerData[id][iMostWonValue], 
		g_dPlayerData[id][iMostLoseValue],
		g_dPlayerData[id][iLastBet],
		g_dPlayerData[id][iDailyWheelTimesUsed],
		g_dPlayerData[id][iCrashBets],
		g_dPlayerData[id][szMostLostGame],
		g_dPlayerData[id][szMostWonGame]
	)
	
	nvault_set(g_nVaultBet, szVaultKey, szVaultData)
}

loadPlayerBets(id)
{
	new szAuthID[35]
	get_user_authid(id, szAuthID, charsmax(szAuthID))
	
	new szVaultKey[128], szVaultData[512]
	formatex(szVaultKey, charsmax(szVaultKey), "Bet-%s-Save", szAuthID)
	formatex
	(
		szVaultData, charsmax(szVaultData), " %d %d %d %d %d %d %d %d %d %d %d %d %s %s" , 
		g_dPlayerData[id][iBetTimes], 
		g_dPlayerData[id][iTimesLose], 
		g_dPlayerData[id][iTimesWon],
		g_dPlayerData[id][iRouletteBets], 
		g_dPlayerData[id][iDiceBets],
		g_dPlayerData[id][iJackpotsBets],
		g_dPlayerData[id][iCoinflipBets],
		g_dPlayerData[id][iMostWonValue], 
		g_dPlayerData[id][iMostLoseValue],
		g_dPlayerData[id][iLastBet],
		g_dPlayerData[id][iDailyWheelTimesUsed],
		g_dPlayerData[id][iCrashBets],
		g_dPlayerData[id][szMostLostGame],
		g_dPlayerData[id][szMostWonGame]
	)		
	nvault_get(g_nVaultBet, szVaultKey, szVaultData, charsmax(szVaultData))
			
	new szTimesBet[MAX_PLAYERS], szTimesWin[MAX_PLAYERS], szTimesLose[MAX_PLAYERS], 
	szRouletteBets[MAX_PLAYERS], szDiceBets[MAX_PLAYERS], szMostWon[MAX_PLAYERS], 
	szMostLose[MAX_PLAYERS], szLastBet[MAX_PLAYERS], szDailyWheelBets[MAX_PLAYERS], 
	szCrashBets[MAX_PLAYERS], szMostLostGamee[MAX_PLAYERS], szMostWonGamee[MAX_PLAYERS],
	szCoinflipBets[MAX_PLAYERS], szJackpotBets[MAX_PLAYERS]
	
	parse
	(
		szVaultData, 
		szTimesBet, charsmax(szTimesBet),
		szTimesLose, charsmax(szTimesLose),
		szTimesWin, charsmax(szTimesWin),
		szRouletteBets, charsmax(szRouletteBets),
		szDiceBets, charsmax(szDiceBets),
		szJackpotBets, charsmax(szJackpotBets),
		szCoinflipBets, charsmax(szCoinflipBets),
		szMostWon, charsmax(szMostWon),
		szMostLose, charsmax(szMostLose),
		szLastBet, charsmax(szLastBet),
		szDailyWheelBets, charsmax(szDailyWheelBets),
		szCrashBets, charsmax(szCrashBets),
		szMostLostGamee, charsmax(szMostLostGamee),
		szMostWonGamee, charsmax(szMostWonGamee)
	)
	
	g_dPlayerData[id][iBetTimes] = str_to_num(szTimesBet)
	g_dPlayerData[id][iTimesWon] = str_to_num(szTimesWin)
	g_dPlayerData[id][iTimesLose] = str_to_num(szTimesLose)
	g_dPlayerData[id][iRouletteBets] = str_to_num(szRouletteBets)
	g_dPlayerData[id][iDiceBets] = str_to_num(szDiceBets)
	g_dPlayerData[id][iMostWonValue] = str_to_num(szMostWon)
	g_dPlayerData[id][iMostLoseValue] = str_to_num(szMostLose)
	g_dPlayerData[id][iLastBet] = str_to_num(szLastBet)
	g_dPlayerData[id][iDailyWheelTimesUsed] = str_to_num(szDailyWheelBets)
	g_dPlayerData[id][iCrashBets] = str_to_num(szCrashBets)
	g_dPlayerData[id][iCoinflipBets] = str_to_num(szCoinflipBets)
	g_dPlayerData[id][iJackpotsBets] = str_to_num(szJackpotBets)
	
	g_dPlayerData[id][szMostLostGame] = szMostLostGamee
	g_dPlayerData[id][szMostWonGame] = szMostWonGamee
	
	if(g_dPlayerData[id][iDailyWheelTimesUsed] > 0)
	{	
		if((get_systime() - g_dPlayerData[id][iLastBet]) > g_iOneDayInSeconds)
		{
			g_dPlayerData[id][bCanUseDailyWheel] = true
		}
	}
	else
	{
		g_dPlayerData[id][bCanUseDailyWheel] = true
	}
}

CheckIfIsTimeToWheel(id)
{
	new iMinBets = get_pcvar_num(pCvars[pCvarMinTimesToUseDailyWheel])
	if(g_dPlayerData[id][iBetTimes] < iMinBets)
	{
		ChatColor(id, "You must bet more times to use the daily wheel:^x04 %d^x01/^x04%d", g_dPlayerData[id][iBetTimes], iMinBets)
		return
	}
	
	if(!g_dPlayerData[id][bCanUseDailyWheel])
	{
		new iSeconds = (g_iOneDayInSeconds - (get_systime() - g_dPlayerData[id][iLastBet]))
		if(iSeconds < g_iOneDayInSeconds)
		{
			new iMinutes = (iSeconds / 60)
			ChatColor(id, "You must wait^x04 %d^x01 minute%s to use the daily wheel again!", iMinutes, (iMinutes > 1) ? "s" : "")
			return
		}
	}
	
	new iUserMoney = cs_get_user_money(id)
	if(iUserMoney >= MAX_MONEY)
	{
		ChatColor(id, "You can not use the daily wheel while you're with the max money:^x04 %d^x01", MAX_MONEY)
		return
	}
		
	g_dPlayerData[id][iLastBet] = get_systime()
	g_dPlayerData[id][iDailyWheelTimesUsed]++
	g_dPlayerData[id][bCanUseDailyWheel] = false
	
	new iRandomNumber = random_num(1, 100), szReward[15]
	if(iRandomNumber < 100)
	{
		switch(iRandomNumber)
		{
			case 1..10:		formatex(szReward, charsmax(szReward), "100$")
			case 11..21:		formatex(szReward, charsmax(szReward), "500$")
			case 22..32:		formatex(szReward, charsmax(szReward), "1000$")
			case 33..43:		formatex(szReward, charsmax(szReward), "2000$")
			case 44..54:		formatex(szReward, charsmax(szReward), "3000$")
			case 55..65:		formatex(szReward, charsmax(szReward), "5000$")
			case 66..76:		formatex(szReward, charsmax(szReward), "7000$")
			case 77..87:		formatex(szReward, charsmax(szReward), "9000$")
			case 88..89:		formatex(szReward, charsmax(szReward), "10000$")
			case 90..99:		formatex(szReward, charsmax(szReward), "12000$")
		}
	}
	else
	{
		formatex(szReward, charsmax(szReward), "16000$")
	}

	new bool:bIsBestReward = bool:(iRandomNumber == 100), szName[MAX_PLAYERS]
	get_user_name(id, szName, charsmax(szName))
	
	ChatColor((bIsBestReward) ? 0 : id, "%s^x01 got^x04 %s^x01 on daily wheel!", (bIsBestReward) ? szName : "You", szReward)
	replace(szReward, charsmax(szReward), "$", "")
	
	cs_set_user_money(id, clamp((iUserMoney + str_to_num(szReward)), 0, MAX_MONEY), 1)
}

is_user_connected_byauthid(const sAuthid[])
{
	new iPlayers[MAX_PLAYERS], iNum
	get_players(iPlayers, iNum)
	
	for(new i, szAuthid[MAX_PLAYERS], iPlayer; i < iNum; i++)
	{
		iPlayer = iPlayers[i]
		
		get_user_authid(iPlayer, szAuthid, charsmax(szAuthid))
		if(equal(sAuthid, szAuthid))
		{
			return iPlayer
		}
	}
	return 0
}

setSett(id, iType, szGameName[])
{
	new bool:bIsCrash = bool:(equal(szGameName, "Crash"))
	switch(iType)
	{
		case 0:
		{
			if(g_dPlayerData[id][iMoneyBetted] > g_dPlayerData[id][iMostLoseValue])
			{
				g_dPlayerData[id][iMostLoseValue] = g_dPlayerData[id][iMoneyBetted]
				formatex(g_dPlayerData[id][szMostLostGame], charsmax(g_dPlayerData[]), szGameName)
			}
			g_dPlayerData[id][iTimesLose]++
			
			if(!bIsCrash)
			{
				set_hudmessage(255, 20, 0, -1.0, 0.30, 0, 1.0, 1.0)
				ShowSyncHudMsg(id, g_hSync[Lost], "YOU LOST!")
			}
		}
		case 1:
		{
			if(g_dPlayerData[id][iMoneyBetted] > g_dPlayerData[id][iMostWonValue])
			{
				g_dPlayerData[id][iMostWonValue] = g_dPlayerData[id][iMoneyBetted]
				formatex(g_dPlayerData[id][szMostWonGame], charsmax(g_dPlayerData[]), szGameName)
			}
			g_dPlayerData[id][iTimesWon]++
			
			if(!bIsCrash)
			{
				set_hudmessage(0, 250, 0, -1.0, 0.30, 0, 1.0, 1.0)
				ShowSyncHudMsg(id, g_hSync[Lost], "YOU WON!")
			}
		}
	}
}

display_coin(target, chosen)
{
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!iEnt) 
	{
		return
	}

	g_iEntity[target] = iEnt
	
	static Float:fOrigin[3], Float:fAim[3]
	pev(target, pev_origin, fOrigin)
	pev(target, pev_view_ofs, fAim)
	xs_vec_add(fOrigin, fAim, fOrigin)
	pev(target, pev_v_angle, fAim)
	angle_vector(fAim, ANGLEVECTOR_FORWARD, fAim)
	xs_vec_mul_scalar(fAim, 10.0, fAim)
	xs_vec_add(fOrigin, fAim, fOrigin)
	pev(target, pev_v_angle, fAim)
	
	set_pev(iEnt, pev_classname, g_szCoinClassName)
	set_pev(iEnt, pev_movetype, MOVETYPE_NOCLIP)
	set_pev(iEnt, pev_solid, SOLID_NOT)
	set_pev(iEnt, pev_origin, fOrigin)
	set_pev(iEnt, pev_v_angle, fAim)
	engfunc(EngFunc_SetModel, iEnt, g_szCoinModel)

	set_pev(iEnt, pev_animtime, get_gametime() + 0.3)
	set_pev(iEnt, pev_sequence, 1)
	set_pev(iEnt, pev_frame, 2.0)
	set_pev(iEnt, pev_framerate, 1.0)
	set_pev(iEnt, pev_iuser4, chosen)
	set_pev(iEnt, pev_iuser2, target)
	
	set_task(6.0, "task_chosen_side", iEnt)
}

get_challengers_num()
{
	new iPlayers[MAX_PLAYERS], iNum, iCount
	get_players(iPlayers, iNum)
	for(new i; i < iNum; i++)
	{
		if(g_dPlayerData[iPlayers[i]][iCoinSide])
		{
			iCount++
		}
	}
	return iCount
}

getChance(id, szGameName[])
{
	new szFlags[27], iReturn
	get_pcvar_string(pCvars[pCvarSponsorAdmin], szFlags, charsmax(szFlags))
	new bool:bFlags = bool:(has_flag(id, szFlags))
	
	switch(szFlags[0])
	{
		case '!':
		{
			switch(szGameName[0])
			{
				case 'D':
				{
					iReturn = 50
				}
				case 'R':
				{
					iReturn = 50
				}
				case 'C':
				{
					iReturn = 7
				}
			}

		}
		default:
		{
			switch(szGameName[0])
			{
				case 'D':
				{
					iReturn = (bFlags) ? 30 : 50
				}
				case 'R':
				{
					iReturn = (bFlags) ? 20 : 50
				}
				case 'C':
				{
					iReturn = (bFlags) ? 4 : 7
				}
			}
		}
	}
	return iReturn
}

ChatColor(id, szMessage[], any:...) 
{
	new iCount = 1, iPlayers[MAX_PLAYERS], Player

	static szMsg[191]
	vformat(szMsg, charsmax(szMsg), szMessage, 3)
	format(szMsg, charsmax(szMsg), "%s %s", g_szChatPrefix, szMsg)

	replace_all(szMsg, charsmax(szMsg), "!g", "^4")
	replace_all(szMsg, charsmax(szMsg), "!y", "^1")
	replace_all(szMsg, charsmax(szMsg), "!t", "^3")
	
	if(id) 
	{
		iPlayers[0] = id
	}
	else 
	{
		get_players(iPlayers, iCount)
	}
		
	for(new i; i < iCount; i++)
	{
		Player = iPlayers[i]

		message_begin(MSG_ONE_UNRELIABLE, gMsgSayText, .player = Player)  
		write_byte(Player)
		write_string(szMsg)
		message_end()
	}
}
