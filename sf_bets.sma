/*
*	SF Bets				     v. 0.1.5
*	by serfreeman1337	      http://1337.uz/
*/

#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "SF Bets"
#define VERSION "0.1.5"
#define AUTHOR "serfreeman1337"

//#define AES	// раскомментируйте для возможности ставить опыт AES (http://1337.uz/advanced-experience-system/)
//#define ACP	// раскомментируйте для возможности ставить очки ACP (http://www.a114games.com/community/threads/igrovye-akkaunty-ili-sistema-registracii-nikov.1658/)

#if defined AES
	#include <aes_main>
#endif

#if defined ACP
	#include <acp>
	
	/*acp_get_player_auth(id)
		return 1
	
	acp_get_player_points(id)
		return 1337*/
		
	acp_take_player_points(id,points)
	{
		if(callfunc_begin("TakePoints","acp_general.amxx"))
		{
			callfunc_push_int(id)
			callfunc_push_int(points)
			callfunc_end()
		}
	}
	
	acp_give_player_points(id,points)
	{
		if(callfunc_begin("GivePoints","acp_general.amxx"))
		{
			callfunc_push_int(id)
			callfunc_push_int(points)
			callfunc_end()
		}
	}
#endif

#if AMXX_VERSION_NUM < 183
	#include <colorchat>
	
	#define print_team_default DontChange
	#define print_team_grey Grey
	#define print_team_red Red
	#define print_team_blue Blue

	#define MAX_PLAYERS 32
	#define MAX_NAME_LENGTH 32
	
	#define argbreak strbreak
#endif

// данный код не рекомендуется смотреть людям страдающим синдромом оптимизации

// -- КОНСТАНТЫ -- //

enum _:players_data_struct
{
	BET_FOR,		// на кого поставил игрок
	BET_MONEY		// деньги
	
	#if defined AES
	,BET_EXP,
	BET_BONUS
	#endif
	
	#if defined ACP
	,BET_POINTS
	#endif
}

enum _:cvars
{
	CVAR_MIN_PLAYERS,
	CVAR_BET_TIME,
	CVAR_BET_AUTOOPEN,
	CVAR_BET_MONEY,
	CVAR_BET_MODE,
	CVAR_BET_MULTIPLER
	
	#if defined AES
	,CVAR_BET_EXP,
	CVAR_BET_BONUS
	#endif
	
	#if defined ACP
	,CVAR_BET_POINTS
	#endif
}

const taskid_updatemenu		= 31337

new const lyl_array[][] = {
	{CVAR_BET_MONEY,BET_MONEY}
	#if defined AES
	,{CVAR_BET_EXP,BET_EXP}
	,{CVAR_BET_BONUS,BET_BONUS}
	#else
	,{-1,-1}
	,{-1,-1}
	#endif
	#if defined ACP
	,{CVAR_BET_POINTS,BET_POINTS}
	#else
	,{-1,-1}
	#endif
}

#define m_iJoinedState 			121

// -- ПЕРЕМЕННЫЕ -- //

new t_id,ct_id			// id игроков 1х1
new Float:bet_time			// время ставки
new bet_menu

new players_data[MAX_PLAYERS + 1][players_data_struct]

new cvar[cvars]

new HamHook:hook_playerKilled
new menuCB_bet

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR)
	
	// sf plugin tracker
	register_cvar("sf_bets", VERSION, FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED)
	
	hook_playerKilled = RegisterHam(Ham_Killed,"player","HamHook_PlayerKilled",true)
	register_logevent("Bet_CheckMinPlayers",3,"1=joined team")
	register_event("SendAudio", "EventHook_TWin", "a", "2&%!MRAD_terwin")  
	register_event("SendAudio", "EventHook_CtWin", "a", "2&%!MRAD_ctwin") 
	register_event("HLTV", "EventHook_NewRound", "a", "1=0", "2=0")
	
	//
	// Минимальное количество игроков в обеих командах для работы ставок
	//
	cvar[CVAR_MIN_PLAYERS] = register_cvar("sf_bet_min_players","2")
	
	//
	// Время, в течении которого можно сделать ставку
	//
	cvar[CVAR_BET_TIME] = register_cvar("sf_bet_time","15")
	
	//
	// Ставка денег
	//
	cvar[CVAR_BET_MONEY] = register_cvar("sf_bet_money","100 1000 3000")
	
	//
	// Как расчитывается выигрыш
	//	0 - выигрышем является сумма поставленная на проигравшего, делится в процентом соотношении ставки победителей
	//	1 - выигрышем является ваша ставка
	//
	cvar[CVAR_BET_MODE] = register_cvar("sf_bet_mode","0")
	
	//
	// Множитель выигрыша
	//
	cvar[CVAR_BET_MULTIPLER] = register_cvar("sf_bet_multipler","1.0")
	
	#if defined AES
	//
	// Ставка опыта
	//
	cvar[CVAR_BET_EXP] = register_cvar("sf_bet_exp","")
	
	//
	// Ставка бонусов
	//
	cvar[CVAR_BET_BONUS] = register_cvar("sf_bet_bonus","")
	#endif
	
	#if defined ACP
	//
	// Ставка очков ACP
	//
	cvar[CVAR_BET_POINTS] = register_cvar("sf_bet_points","")
	#endif
	
	//
	// Автоматическое открытие меню ставок
	//
	cvar[CVAR_BET_AUTOOPEN] = register_cvar("sf_bet_auto","1")
	
	register_clcmd("say /bet","Bet_ShowMenu",-1,"- open bet menu")
	
	register_dictionary("sf_bets.txt")
	register_dictionary("common.txt")
}

public plugin_cfg()
{
	server_exec()
	
	// --- МЕНЮ --- //
	
	bet_menu = menu_create("Bet Menu","Bet_MenuHandler")
	menuCB_bet = menu_makecallback("Bet_MenuCallback")
	
	menu_additem(bet_menu,"Player T","0",.callback = menuCB_bet)
	menu_additem(bet_menu,"Player CT","1",.callback = menuCB_bet)
	
	new v_cvar[10]
	get_pcvar_string(cvar[CVAR_BET_MONEY],v_cvar,charsmax(v_cvar))
	
	if(v_cvar[0])
		menu_additem(bet_menu,"Money","2",.callback = menuCB_bet)
	
	#if defined AES
	get_pcvar_string(cvar[CVAR_BET_EXP],v_cvar,charsmax(v_cvar))
	
	if(v_cvar[0])
		menu_additem(bet_menu,"Exp","3",.callback = menuCB_bet)
		
	get_pcvar_string(cvar[CVAR_BET_BONUS],v_cvar,charsmax(v_cvar))
	
	if(v_cvar[0])
		menu_additem(bet_menu,"Bonus","4",.callback = menuCB_bet)
	#endif
	
	#if defined ACP
	get_pcvar_string(cvar[CVAR_BET_POINTS],v_cvar,charsmax(v_cvar))
	
	if(v_cvar[0])
		menu_additem(bet_menu,"Points","5",.callback = menuCB_bet)
	#endif
}


public client_disconnect(id)
{
	// TODO: придумать что-то
	set_task(0.1,"Bet_CheckMinPlayers")
	
	if(players_data[id][BET_FOR])
	{
		#if defined AES
		if(players_data[id][BET_EXP])
		{
			aes_add_player_exp(id,-players_data[id][BET_EXP],true)
		}
		
		if(players_data[id][BET_BONUS])
		{
			aes_add_player_bonus(id,-players_data[id][BET_BONUS])
		}
		#endif
		
		#if defined ACP
		if(players_data[id][BET_POINTS])
		{
			acp_take_player_points(id,players_data[id][BET_POINTS])
		}
		#endif
	}
	
	arrayset(players_data[id],0,players_data_struct)
}

//
// Победа T
//
public EventHook_TWin()
{
	if(t_id && ct_id)
		Bet_End1x1(t_id)
}

//
// Победа CT
//
public EventHook_CtWin()
{
	if(t_id && ct_id)
		Bet_End1x1(ct_id)
}

public EventHook_NewRound()
{
	if(t_id || ct_id)
	{
		new players[MAX_PLAYERS],pnum
		get_players(players,pnum,"ch")
		
		for(new i ; i < pnum ; i++)
		{
			arrayset(players_data[players[i]],0,players_data_struct)
		}
		
		t_id = 0
		ct_id = 0
		bet_time = 0.0
	}
}

//
// Вкл/выкл обнаружения 1x1 по кол-ву игроков в командах
//
public Bet_CheckMinPlayers()
{
	new players[MAX_PLAYERS],pnum,min_players = get_pcvar_num(cvar[CVAR_MIN_PLAYERS])
	
	// проверяем кол-во игроков за T
	get_players(players,pnum,"e","TERRORIST")
	
	if(pnum < min_players)
	{
		DisableHamForward(hook_playerKilled)
		return PLUGIN_CONTINUE
	}
	
	// проверяем кол-во игроков за CT
	get_players(players,pnum,"e","CT")
	
	if(pnum < min_players)
	{
		DisableHamForward(hook_playerKilled)
		return PLUGIN_CONTINUE
	}
	
	// вкл все
	
	if(Bet_Check1x1())
	{
		Bet_Start()
	}
	
	EnableHamForward(hook_playerKilled)
	return PLUGIN_CONTINUE
}

public HamHook_PlayerKilled()
{
	if(Bet_Check1x1())
	{
		Bet_Start()
	}
}

//
// Начало 1х1
//
public Bet_Start()
{
	bet_time = get_gametime() + get_pcvar_float(cvar[CVAR_BET_TIME])
	
	// показываем меню всем
	if(get_pcvar_num(cvar[CVAR_BET_AUTOOPEN]))
	{
		new players[MAX_PLAYERS],pnum
		get_players(players,pnum,"ch")
		
		for(new i,player ; i < pnum ; i++)
		{
			player = players[i]
			
			Bet_ShowMenu(player)
		}
	}
	
	// таск обновление меню игрокам
	if(!task_exists(taskid_updatemenu))
		set_task(0.5,"Bet_UpdateMenu",taskid_updatemenu,.flags = "b")
}

//
// Конец 1x1
//
public Bet_End1x1(win_practicant)
{
	new players[MAX_PLAYERS],pnum
	get_players(players,pnum,"ch")
	
	bet_time = 0.0
	remove_task(taskid_updatemenu)
	Bet_UpdateMenu()
	
	for(new i,player ; i < pnum ; i++)
	{
		player = players[i]
		
		// игрок не делал ставку
		if(!players_data[player][BET_FOR])
		{	
			continue
		}
		
		// победная ставка
		if(players_data[player][BET_FOR] == win_practicant)
		{
			new win_name[MAX_NAME_LENGTH]
			get_user_name(players_data[player][BET_FOR],win_name,charsmax(win_name))
			
			new prize,prize_str[128],prize_len
			
			prize = Bet_GetWinPool(player,BET_MONEY,win_practicant)
			
			// выдаем деньги
			if(prize)
			{
				prize_len += formatex(prize_str[prize_len],charsmax(prize_str) - prize_len,"%L",
					player,"SF_BET14",
					prize
				)
				
				cs_set_user_money(player,
					cs_get_user_money(player) + prize
				)
			}
			
			#if defined AES
			// выдаем опыт
			prize = Bet_GetWinPool(player,BET_EXP,win_practicant)
			
			if(prize)
			{
				prize_len += formatex(prize_str[prize_len],charsmax(prize_str) - prize_len,"%s%L",
					prize_len ? ", " : "",
					player,"SF_BET15",
					prize
				)
				
				aes_add_player_exp(player,prize)
			}
			
			// выдаем бонусы
			prize = Bet_GetWinPool(player,BET_BONUS,win_practicant)
			
			if(prize)
			{
				prize_len += formatex(prize_str[prize_len],charsmax(prize_str) - prize_len,"%s%L",
					prize_len ? ", " : "",
					player,"SF_BET21",
					prize
				)
				
				aes_add_player_bonus(player,prize)
			}
			#endif
			
			#if defined ACP
			prize = Bet_GetWinPool(player,BET_POINTS,win_practicant)
			
			if(prize)
			{
				prize_len += formatex(prize_str[prize_len],charsmax(prize_str) - prize_len,"%s%L",
					prize_len ? ", " : "",
					player,"SF_BET25",
					prize
				)
				
				acp_give_player_points(player,prize)
			}
			#endif
			
			if(!prize_len)
			{
				formatex(prize_str,charsmax(prize_str),"%L",player,"SF_BET22")
			}
			
			client_print_color(player,print_team_blue,"%L %L",
				player,"SF_BET9",
				player,"SF_BET13",
				win_name,prize_str
			)
		}
		// фейловая ставка
		else
		{
			new lose_name[MAX_NAME_LENGTH]
			get_user_name(players_data[player][BET_FOR],lose_name,charsmax(lose_name))
			
			client_print_color(player,print_team_red,"%L %L",
				player,"SF_BET9",
				player,"SF_BET12",
				lose_name
			)
			
			if(players_data[player][BET_MONEY])
			{
				cs_set_user_money(player,
					cs_get_user_money(player) - players_data[player][BET_MONEY]
				)
			}
			
			#if defined AES
			if(players_data[player][BET_EXP])
			{
				aes_add_player_exp(player,-players_data[player][BET_EXP],true)
			}
			
			if(players_data[player][BET_BONUS])
			{
				aes_add_player_bonus(player,-players_data[player][BET_BONUS])
			}
			#endif
			
			#if defined ACP
			if(players_data[player][BET_POINTS])
			{
				acp_take_player_points(player,players_data[player][BET_POINTS])
			}
			#endif
		}
		
		arrayset(players_data[player],0,players_data_struct)
	}
}

//
// Функция обновления меню игрокам
//
public Bet_UpdateMenu()
{
	new players[MAX_PLAYERS],pnum
	get_players(players,pnum,"ch")
	
	new Float:bet_left = bet_time - get_gametime()
	
	for(new i,player,menu,newmenu,menupage ; i < pnum ; i++)
	{
		player = players[i]
		
		player_menu_info(player,menu,newmenu,menupage)
		
		// обновляем меню ставок игроку
		if(newmenu == bet_menu)
		{
			// обновляем меню
			if(floatround(bet_left) > 0)
			{
				Bet_MenuFormat(player)
				menu_display(player,bet_menu)
			}
			// закрываем меню по истечению времени
			else
			{
				menu_cancel(player)
				show_menu(player,0,"^n")
			}
		}
	}
	
	// сбрасываем такс
	if(bet_left <= 0.0)
	{
		remove_task(taskid_updatemenu)
	}
}

//
// Показываем меню ставок
//
public Bet_ShowMenu(id)
{
	// hax
	if(id == t_id || id == ct_id)
	{
		return PLUGIN_HANDLED
	}
	
	// не показываем меню игрокам в спектаторах
	if(!(CS_TEAM_T <= cs_get_user_team(id) <= CS_TEAM_CT) || get_pdata_int(id,m_iJoinedState))
	{
		return PLUGIN_HANDLED
	}
	
	// меню можно вызвать только 1x1
	if(!t_id || !ct_id)
	{
		client_print_color(id,print_team_red,"%L %L",
			id,"SF_BET9",
			id,"SF_BET10"
		)
		
		return PLUGIN_CONTINUE
	}
	
	if(players_data[id][BET_FOR])
	{
		client_print_color(id,print_team_red,"%L %L",
			id,"SF_BET9",
			id,"SF_BET18"
		)
		
		return PLUGIN_CONTINUE
	}
	
	// меню можно вызвать только живым
	if(is_user_alive(id))
	{
		client_print_color(id,print_team_red,"%L %L",
			id,"SF_BET9",
			id,"SF_BET11"
		)
		
		return PLUGIN_CONTINUE
	}
	
	new Float:bet_left = bet_time - get_gametime()
	
	if(bet_left <= 0.0)
	{
		client_print_color(id,print_team_red,"%L %L",
			id,"SF_BET9",
			id,"SF_BET17"
		)
		
		return PLUGIN_CONTINUE
	}
	
	Bet_MenuFormat(id)
	menu_display(id,bet_menu)
	
	return PLUGIN_CONTINUE
	
}

//
// Обработка действий в меню
//
public Bet_MenuHandler(id,menu,r_item)
{
	if(r_item == MENU_EXIT)
	{
		return PLUGIN_HANDLED
	}
	
	new ri[2],di[2]
	menu_item_getinfo(menu,r_item,di[0],ri,charsmax(ri),di,charsmax(di),di[0])
	
	new item = str_to_num(ri)
	
	switch(item)
	{
		// делаем ставки
		case 0,1:
		{	
			// ставим деньги
			if(players_data[id][BET_MONEY])
			{
				new user_money = cs_get_user_money(id)
				
				// игроку не хватает денег
				if(user_money < players_data[id][BET_MONEY])
				{
					Bet_MenuFormat(id)
					menu_display(id,menu)
					
					return PLUGIN_HANDLED
				}
			}
			
			#if defined AES
			new rt[AES_ST_END]
			aes_get_player_stats(id,rt)
			
			// ставим опыт
			
			if(players_data[id][BET_EXP])
			{
				if(rt[AES_ST_EXP] < players_data[id][BET_EXP])
				{
					Bet_MenuFormat(id)
					menu_display(id,menu)
					
					return PLUGIN_HANDLED
				}
			}
			
			if(players_data[id][BET_BONUS])
			{
				if(rt[AES_ST_BONUSES] < players_data[id][BET_BONUS])
				{
					Bet_MenuFormat(id)
					menu_display(id,menu)
					
					return PLUGIN_HANDLED
				}
			}
			#endif
			
			#if defined ACP
			if(players_data[id][BET_POINTS])
			{
				if(acp_get_player_points(id) < players_data[id][BET_POINTS])
				{
					Bet_MenuFormat(id)
					menu_display(id,menu)
					
					return PLUGIN_HANDLED
				}
			}
			#endif
			
			// запоминаем на кого поставили
			players_data[id][BET_FOR] = item == 0 ? t_id : ct_id
			
			if(!players_data[id][BET_FOR])
			{
				return PLUGIN_HANDLED
			}
			
			// сообщение в чат
			new plr_name[MAX_NAME_LENGTH],bet_name[MAX_NAME_LENGTH]
			
			get_user_name(id,plr_name,charsmax(plr_name))
			get_user_name(players_data[id][BET_FOR],bet_name,charsmax(bet_name))
			
			// сообщение всем мертвым игрокам
			new players[MAX_PLAYERS],pnum
			get_players(players,pnum,"bch")
			
			for(new i,player ; i < pnum ; i++)
			{
				player = players[i]
				
				if(player == id)
				{
					client_print_color(player,
						print_team_default,
						"%L %L",
						player,"SF_BET9",
						player,"SF_BET27",
						bet_name
					)
				}
				else
				{
					client_print_color(player,
						(cs_get_user_team(player) == CS_TEAM_CT ? print_team_blue : print_team_red), // красим ник в цвет команды
						"%L %L",
						player,"SF_BET9",
						player,"SF_BET28",
						plr_name,bet_name
					)
				}
					
			}
		}
		// переключатели стаовк
		case 2,3,4,5:
		{
			new cp = lyl_array[item - 2][0]
			new sp = lyl_array[item - 2][1]
			
			new bet_str[128],bet_val[10],bool:set
			get_pcvar_string(cvar[cp],bet_str,charsmax(bet_str))
			
			while(argbreak(bet_str,
				bet_val,charsmax(bet_val),
				bet_str,charsmax(bet_str)) != -1
			)
			{
				if(!bet_val[0])
					break
				
				bet_val[0] = str_to_num(bet_val)
				
				// переключаем на большее значение
				if(bet_val[0] > players_data[id][sp])
				{
					set = true
					players_data[id][sp] = bet_val[0]
					break
				}
			}
			
			// сбрасываем переключатель
			if(bet_val[0] <= players_data[id][sp] && !set)
			{
				players_data[id][sp] = 0
			}
			
			switch(item)
			{
				case 2:
				{
					if(cs_get_user_money(id) < players_data[id][sp])
					{
						players_data[id][sp] = 0
					}
				}
				#if defined AES
				case 3,4:
				{
					new rt[AES_ST_END]
					aes_get_player_stats(id,rt)
					
					if(
						(item == 3 && rt[AES_ST_EXP] < players_data[id][sp])
						||
						(item == 4 && rt[AES_ST_BONUSES] < players_data[id][sp])
					)
					{
						players_data[id][sp] = 0
					}
				}
				#endif
				#if defined ACP
				case 5:
				{
					if(acp_get_player_points(id) < players_data[id][sp])
					{
						players_data[id][sp] = 0
					}
				}
				#endif
			}
			
			Bet_MenuFormat(id)
			menu_display(id,menu)
		}
	}
	
	return PLUGIN_HANDLED
}


//
// Настраиваем отображение меню
//
public Bet_MenuFormat(id)
{
	new fmt[512],len
	
	// --- ЗАГОЛОВОК --- //
	len += formatex(fmt[len],charsmax(fmt) - len,"%L^n%L^n%L",
		id,"SF_BET1",
		id,"SF_BET2",bet_time - get_gametime(),
		id,"SF_BET3",Bet_Menu_GetBetString(id)
	)
	menu_setprop(bet_menu,MPROP_TITLE,fmt)
	
	// --- ВЫХОД --- //
	formatex(fmt,charsmax(fmt),"%L",id,"EXIT")
	menu_setprop(bet_menu,MPROP_EXITNAME,fmt)
}

//
// Настраиваем кнопки в меню
//
public Bet_MenuCallback(id, menu, r_item)
{
	new fmt[256],len
	
	new ri[2],di[2]
	menu_item_getinfo(menu,r_item,di[0],ri,charsmax(ri),di,charsmax(di),di[0])
	
	new item = str_to_num(ri)
	
	if(item == 0)
	{
		Bet_MenuFormat(id)
	}
	
	switch(item)
	{
		// ставки на T или CT
		case 0,1:
		{
			new ct_name[MAX_NAME_LENGTH],bet_id = (item == 0 ? t_id : ct_id)
			new rt = ITEM_DISABLED
			
			get_user_name(bet_id,ct_name,charsmax(ct_name))
	
			len = formatex(fmt[len],charsmax(fmt) - len,"%L",
				id,"SF_BET6",
				ct_name,
				item == 0 ? "T" : "CT"
			)
			
			if(players_data[id][BET_MONEY])
			{
				rt = ITEM_ENABLED
			}
			
			new prize = Bet_GetWinPool(id,BET_MONEY,bet_id)
			new prize_str[128],prize_len
			
			if(prize)
			{
				prize_len += formatex(prize_str[prize_len],charsmax(prize_str) - prize_len,"%L",
					id,"SF_BET5",
					prize
				)	
			}
			
			#if defined AES
			prize = Bet_GetWinPool(id,BET_EXP,bet_id)
			
			if(prize)
			{
				prize_len += formatex(prize_str[prize_len],charsmax(prize_str) - prize_len,"%s%L",
					prize_len ? ", " : "",
					id,"SF_BET4",
					prize
				)
			}
			
			prize = Bet_GetWinPool(id,BET_BONUS,bet_id)
			
			if(prize)
			{
				prize_len += formatex(prize_str[prize_len],charsmax(prize_str) - prize_len,"%s%L",
					prize_len ? ", " : "",
					id,"SF_BET20",
					prize
				)
			}
			
			if(players_data[id][BET_EXP] || players_data[id][BET_EXP])
			{
				rt = ITEM_ENABLED
			}
			
			#endif
			
			#if defined ACP
			prize = Bet_GetWinPool(id,BET_POINTS,bet_id)
			
			if(prize)
			{
				prize_len += formatex(prize_str[prize_len],charsmax(prize_str) - prize_len,"%s%L",
					prize_len ? ", " : "",
					id,"SF_BET24",
					prize
				)
			}
			
			if(players_data[id][BET_POINTS])
			{
				rt = ITEM_ENABLED
			}
			#endif
			
			if(prize_str[0])
			{
				len += formatex(fmt[len],charsmax(fmt) - len," %L",
					id,"SF_BET16",
					prize_str
				)
			}
			
			if(item == 1)
			{
				len += formatex(fmt[len],charsmax(fmt) - len,"^n")
			}
			
			menu_item_setname(menu,r_item,fmt)
			return rt
		}
		// переключатели
		case 2,3,4,5:
		{
			new cp = lyl_array[item - 2][0]
			new sp = lyl_array[item - 2][1]
			
			switch(item)
			{
				case 2: len = formatex(fmt[len],charsmax(fmt) - len,"%L",id,"SF_BET7")
				
				#if defined AES
				case 3: len = formatex(fmt[len],charsmax(fmt) - len,"%L",id,"SF_BET8")
				case 4: len = formatex(fmt[len],charsmax(fmt) - len,"%L",id,"SF_BET19")
				#endif
				#if defined ACP
				case 5: 
				{
					len = formatex(fmt[len],charsmax(fmt) - len,"%L %L",id,"SF_BET23",id,"SF_BET26",acp_get_player_points(id))
					
					// игрок не зарегистрирован, выкл. этот пункт
					if(acp_get_player_auth(id) == 0)
					{
						menu_item_setname(bet_menu,r_item,fmt)
						return ITEM_DISABLED
					}
				}
				#endif
			}
			
			new bet_str[128],bet_val[10]
			get_pcvar_string(cvar[cp],bet_str,charsmax(bet_str))
			
			if(!bet_str[0])
			{
				menu_item_setname(bet_menu,r_item,fmt)
				return ITEM_DISABLED
			}
			
			while(argbreak(bet_str,
				bet_val,charsmax(bet_val),
				bet_str,charsmax(bet_str)) != -1
			)
			{
				if(!bet_val[0])
					break
				
				bet_val[0] = str_to_num(bet_val)
				
				if(bet_val[0] != players_data[id][sp])
				{
					len += formatex(fmt[len],charsmax(fmt) - len," \d[%d]",bet_val[0])
				}
				else
				{
					len += formatex(fmt[len],charsmax(fmt) - len," \r[\y%d\r]",bet_val[0])
				}
			}
			
			menu_item_setname(bet_menu,r_item,fmt)
		}
	}
	
	return ITEM_ENABLED
}

//
// лул
//
Bet_Menu_GetBetString(id)
{
	new fmt[512],len
	
	if(players_data[id][BET_MONEY])
	{
		len += formatex(fmt[len],charsmax(fmt) - len,"%L",id,"SF_BET5",
			players_data[id][BET_MONEY]
		)
	}
	
	#if defined AES
	if(players_data[id][BET_EXP])
	{
		len += formatex(fmt[len],charsmax(fmt) - len,"%s%L",fmt[0] ? ", " : "",id,"SF_BET4",
			players_data[id][BET_EXP]
		)
	}
	
	if(players_data[id][BET_BONUS])
	{
		len += formatex(fmt[len],charsmax(fmt) - len,"%s%L",fmt[0] ? ", " : "",id,"SF_BET20",
			players_data[id][BET_BONUS]
		)
	}
	#endif
	
	#if defined ACP
	if(players_data[id][BET_POINTS])
	{
		len += formatex(fmt[len],charsmax(fmt) - len,"%s%L",fmt[0] ? ", " : "",id,"SF_BET24",
			players_data[id][BET_POINTS]
		)
	}
	#endif
	
	if(!fmt[0])
	{
		copy(fmt,charsmax(fmt),"\d-\w")
	}
	
	return fmt
}

//
// Узнаем выигрыш ставки
//
Bet_GetWinPool(id,pool,practicant)
{
	new win_bet
	
	switch(get_pcvar_num(cvar[CVAR_BET_MODE]))
	{
		case 0:
		{
			new players[MAX_PLAYERS],pnum
			get_players(players,pnum,"ch")
			
			new bet_pool
			new win_pool
			
			for(new i,player ; i <pnum ; i++)
			{
				player = players[i]
				
				if(players_data[player][BET_FOR] == 0 && player != id)
				{
					continue
				}
				
				if(players_data[player][BET_FOR] == practicant || !players_data[player][BET_FOR])
					bet_pool += players_data[player][pool]
				else
					win_pool += players_data[player][pool]
			}
			
			if(!bet_pool)
				return 0
			
			// процент ставки игрока от общей суммы
			new Float:bet_perc = float(players_data[id][pool]) * 100.0 / float(bet_pool)
			win_bet = (win_pool * floatround(bet_perc) / 100)
		}
		case 1:
		{
			win_bet = (players_data[id][pool])
		}
	}
	
	win_bet = floatround(win_bet * get_pcvar_float(cvar[CVAR_BET_MULTIPLER]))
	
	return win_bet
}

//
// Функция проверки 1x1
//
Bet_Check1x1()
{
	if(t_id && ct_id)
		return false
	
	new players[MAX_PLAYERS],tnum,ctnum
	
	// живые игрока из T
	get_players(players,tnum,"aeh","TERRORIST")
	
	if(tnum == 1)
	{
		// запоминаем ID посл. живого T
		t_id  = players[0]
	}
	else
	{
		t_id = 0
		
		return false
	}
	
	// живые игроки за CT
	get_players(players,ctnum,"aeh","CT")
	
	if(ctnum == 1)
	{
		// запоминаем ID посл. живого CT
		ct_id = players[0]
	}
	else
	{
		ct_id = 0
		
		return false
	}
	
	// это 1x1
	return true
}
