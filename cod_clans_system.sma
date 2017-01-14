#include <amxmodx>
#include <cod>
#include <hamsandwich>
#include <fun>
#include <sqlx>

#define PLUGIN "CoD Clans System"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define Set(%2,%1)	(%1 |= (1<<(%2&31)))
#define Rem(%2,%1)	(%1 &= ~(1 <<(%2&31)))
#define Get(%2,%1)	(%1 & (1<<(%2&31)))

enum _:ClanInfo
{
	NAME[64],
	PASSWORD[32],
	LEVEL,
	HONOR,
	SPEED,
	GRAVITY,
	DAMAGE,
	DROP,
	KILLS,
	MEMBERS,
	Trie:STATUS,
};

enum
{
	NONE = 0,
	MEMBER,
	DEPUTY,
	LEADER
};

new const szCommandClan[][] = { "say /clan", "say_team /clan", "say /clans", "say_team /clans", "say /klany", "say_team /klany", "say /klan", "say_team /klan", "klan" };

new const szFile[] = "cod_clans.ini";

new iLevelCost, iNextLevelCost, iSpeedCost, iNextSpeedCost, iGravityCost, iNextGravityCost, iDamageCost, iNextDamageCost, iWeaponDropCost, iNextWeaponDropCost;
new iLevelMax, iSpeedMax, iGravityMax, iDamageMax, iWeaponDropMax;
new iMembersPerLevel, iSpeedPerLevel, iGravityPerLevel, iDamagePerLevel, iWeaponDropPerLevel;
new iCreateLevel, iMaxMembers;

new szMemberName[MAX_PLAYERS + 1][64], szChosenName[MAX_PLAYERS + 1][64];

new iClan[MAX_PLAYERS + 1], iChosenID[MAX_PLAYERS + 1];

new iPassword;

new bool:bFreezeTime;

new szCache[512], szMessage[2048];

new Handle:hSqlTuple;

new Array:gClans;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_cvar("cod_clans_sql_host", "sql.pukawka.pl", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_clans_sql_user", "310529", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_clans_sql_pass", "IzQsAjTnjuPnJu41", FCVAR_SPONLY|FCVAR_PROTECTED); 
	register_cvar("cod_clans_sql_db", "310529_cod", FCVAR_SPONLY|FCVAR_PROTECTED); 
	
	for(new i; i < sizeof szCommandClan; i++)
		register_clcmd(szCommandClan[i], "ClanMenu");
	
	register_clcmd("Nazwa", "CmdCreateClan");
	register_clcmd("Ustaw_Haslo", "CmdSetPassword");
	register_clcmd("Podaj_Haslo", "CmdCheckPassword");
	register_clcmd("Nowa_Nazwa", "ChangeName_Handle");
	register_clcmd("Ilosc_Honoru", "DepositHonor_Handle");
	
	register_event("DeathMsg", "DeathMsg", "a");
	register_event("HLTV", "NewRound", "a", "1=0", "2=0");
	
	register_logevent("RoundStart", 2, "1=Round_Start");
	
	register_message(get_user_msgid("SayText"), "HandleSayText");
	
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
	RegisterHam(get_player_resetmaxspeed_func(), "player", "PlayerResetMaxSpeed", 1);
	
	gClans = ArrayCreate(ClanInfo);
	
	new aClan[ClanInfo];
	
	aClan[NAME] = "Brak";
	aClan[LEVEL] = 0;
	aClan[HONOR] = 0;
	aClan[SPEED] = 0;
	aClan[GRAVITY] = 0;
	aClan[DROP] = 0;
	aClan[DAMAGE] = 0;
	aClan[PASSWORD] = 0;
	aClan[MEMBERS] = 0;
	aClan[STATUS] = _:TrieCreate();
	
	ArrayPushArray(gClans, aClan);
}

public plugin_cfg()
{
	ConfigLoad();
	SqlInit();
}

public plugin_end()
{
	SQL_FreeHandle(hSqlTuple);
	ArrayDestroy(gClans);
}

public client_putinserver(id)
{
	iClan[id] = 0;
	LoadMember(id);
}

public client_disconnect(id)
{
	Rem(id, iPassword);
	iClan[id] = 0;
}

public NewRound()
	bFreezeTime = true;

public RoundStart()
	bFreezeTime = false;

public PlayerSpawn(id)
{
	if(!is_user_alive(id) || !iClan[id])
		return HAM_IGNORED;
	
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iClan[id], aClan);
	
	if(equal(aClan[PASSWORD], "") && get_user_status(id, iClan[id]) == LEADER)
	{
		cod_print_chat(id, DontChange, "Nie wpisano hasla zarzadzania klanem. Wpisz je teraz!");
		client_cmd(id, "messagemode Ustaw_Haslo");
	}
	
	new iGravity = 800 - (iGravityPerLevel*aClan[GRAVITY]);
	set_user_gravity(id, float(iGravity)/800.0);
	
	return HAM_IGNORED;
}

public PlayerResetMaxSpeed(id)
{
	if(!iClan[id] || bFreezeTime || !is_user_alive(id))
		return HAM_IGNORED;
	
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iClan[id], aClan);
	
	if(aClan[SPEED])
		set_user_maxspeed(id, get_user_maxspeed(id) + (iSpeedPerLevel * aClan[SPEED]));

	return HAM_IGNORED;
}

public TakeDamage(iVictim, iInflictor, iAttacker, Float:Damage, iBits)
{
	if(!is_user_alive(iAttacker) || !is_user_connected(iVictim))
		return HAM_IGNORED;
	
	if(get_user_team(iVictim) == get_user_team(iAttacker) || !iClan[iAttacker])
		return HAM_IGNORED;
	
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iClan[iAttacker], aClan);
	
	if(aClan[DAMAGE])
		SetHamParamFloat(4, Damage + (iDamagePerLevel*(aClan[DAMAGE])));
	
	if(aClan[DROP])
	{
		if(random_num(1, (iWeaponDropMax*1.6 - (aClan[DROP] * iWeaponDropPerLevel)) == 1))
			client_cmd(iVictim, "drop");
	}
	
	return HAM_IGNORED;
}

public DeathMsg()
{
	new iKiller = read_data(1);
	
	if(!is_user_alive(iKiller) || !iClan[iKiller])
		return PLUGIN_CONTINUE;
	
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iClan[iKiller], aClan);
	
	aClan[KILLS]++;
	ArraySetArray(gClans, iClan[iKiller], aClan);
	
	SaveClan(iClan[iKiller]);
	
	return PLUGIN_CONTINUE;
}

public ClanMenu(id)
{	
	if(!is_user_connected(id))
		return PLUGIN_HANDLED;
		
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
	
	client_cmd(id, "spk CodMod/select2");
	
	new aClan[ClanInfo], szMenu[128], menu;
	
	if(iClan[id])
	{
		ArrayGetArray(gClans, iClan[id], aClan);
		
		formatex(szMenu, charsmax(szMenu), "\wMenu \rKlanu^n\wAktualny Klan:\y %s^n\w(\y%i/%i %s | %i Honoru\w)", aClan[NAME], aClan[MEMBERS], aClan[LEVEL]*iMembersPerLevel+iMaxMembers, aClan[MEMBERS] > 1 ? "Czlonkow" : "Czlonek", aClan[HONOR]);
		
		menu = menu_create(szMenu, "ClanMenu_Handler");
		
		if(get_user_status(id, iClan[id]) > MEMBER)
			menu_additem(menu, "\wZarzadzaj \yKlanem");
		else 
		{
			formatex(szMenu, charsmax(szMenu), "\wStworz \yKlan \r(Wymagany %i Poziom)", iCreateLevel);
			menu_additem(menu, szMenu);
		}
	}
	else
	{
		menu = menu_create("\wMenu \rKlanu^n\wAktualny Klan:\y Brak", "ClanMenu_Handler");
		formatex(szMenu, charsmax(szMenu), "\wStworz \yKlan \r(Wymagany %i Poziom)", iCreateLevel);
		menu_additem(menu, szMenu);
	}
	
	new callback = menu_makecallback("ClanMenu_Callback");

	menu_additem(menu, "\wOpusc \yKlan", _, _, callback);
	menu_additem(menu, "\wCzlonkowie \yOnline", _, _, callback);
	menu_additem(menu, "\wWplac \yHonor", _, _, callback);
	menu_additem(menu, "\wTop15 \yKlanow", _, _, callback);
	
	menu_setprop(menu, MPROP_NOCOLORS, 1);
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r");
	
	menu_setprop(menu, MPROP_EXITNAME, "\wWyjdz");
	
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public ClanMenu_Callback(id, menu, item)
{
	switch(item)
	{
		case 1, 3, 4: return iClan[id] ? ITEM_ENABLED : ITEM_DISABLED;
		case 2: 
		{
			if(iClan[id] && get_user_status(id, iClan[id]) > MEMBER)
			{
				new aClan[ClanInfo];
				ArrayGetArray(gClans, iClan[id], aClan);
				
				if(((aClan[LEVEL]*iMembersPerLevel) + iMaxMembers) > aClan[MEMBERS])
					return ITEM_ENABLED;
			}
			return ITEM_DISABLED;
		}
	}
	return ITEM_ENABLED;
}

public ClanMenu_Handler(id, menu, item)
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
		case 0: 
		{
			if(get_user_status(id, iClan[id]) > MEMBER)
			{
				ShowLeaderMenu(id);
				return PLUGIN_HANDLED;
			}
			
			if(iClan[id])
			{
				cod_print_chat(id, DontChange, "Nie mozesz utworzyc klanu, jesli w jakims jestes!");
				return PLUGIN_HANDLED;
			}
			
			if(cod_get_user_level(id) < iCreateLevel)
			{
				cod_print_chat(id, DontChange, "Nie masz wystarczajacego poziomu by stworzyc klan (Wymagany^x03 %i^x01)!", iCreateLevel);
				return PLUGIN_HANDLED;
			}
			
			client_cmd(id, "messagemode Nazwa");
		}
		case 1: ShowLeaveConfirmMenu(id);
		case 2: ShowMembersOnlineMenu(id);
		case 3: 
		{
			client_cmd(id, "messagemode Ilosc_Honoru");
			cod_print_chat(id, DontChange, "Wpisz ilosc Honoru, ktora chcesz wplacic.");
		}
		case 4: Clans_Top15(id);
	}
	
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public CmdCreateClan(id)
{
	if(iClan[id])
	{
		cod_print_chat(id, DontChange, "Nie mozesz utworzyc klanu, jesli w jakims jestes!");
		return PLUGIN_HANDLED;
	}
	
	if(cod_get_user_level(id) < iCreateLevel)
	{
		cod_print_chat(id, DontChange, "Nie masz wystarczajaco duzego poziomu (Wymagany: %i)!", iCreateLevel);
		return PLUGIN_HANDLED;
	}
	
	new szName[64], szTempName[64];
	
	read_args(szName, charsmax(szName));
	remove_quotes(szName);
	
	if(equal(szName, ""))
	{
		cod_print_chat(id, DontChange, "Nie wpisano nazwy klanu.");
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	mysql_escape_string(szName, szTempName, charsmax(szTempName));
	
	if(CheckClanName(szTempName))
	{
		cod_print_chat(id, DontChange, "Klan z taka nazwa juz istnieje.");
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new aClan[ClanInfo];
	
	copy(aClan[NAME], charsmax(aClan[NAME]), szName);
	aClan[LEVEL] = 0;
	aClan[HONOR] = 0;
	aClan[SPEED] = 0;
	aClan[GRAVITY] = 0;
	aClan[DROP] = 0;
	aClan[DAMAGE] = 0;
	aClan[PASSWORD] = 0;
	aClan[MEMBERS] = 0;
	aClan[STATUS] = _:TrieCreate();
	
	ArrayPushArray(gClans, aClan);
	
	formatex(szCache, charsmax(szCache), "INSERT INTO `clans` (`clan_name`) VALUES ('%s');", szTempName);
	log_to_file("addons/amxmodx/logs/cod_clans.log", "Utworzenie Klanu: %s", szCache);
	SQL_ThreadQuery(hSqlTuple, "Table_Handle", szCache);
	
	set_user_clan(id, ArraySize(gClans) - 1, 1);
	set_user_status(id, ArraySize(gClans) - 1, LEADER);
	
	cod_print_chat(id, DontChange, "Pomyslnie zalozyles klan^x03 %s^01.", szName);
	cod_print_chat(id, DontChange, "Teraz wpisz haslo, ktore pozwoli na zarzadzanie klanem.");
	client_print(id, print_center, "Wpisz haslo pozwalajace zarzadzac klanem!");
	
	client_cmd(id, "messagemode Ustaw_Haslo");
	
	return PLUGIN_HANDLED;
}

public CmdSetPassword(id)
{
	if(!iClan[id])
	{
		cod_print_chat(id, DontChange, "Nie mozesz ustawic hasla, bo nie masz klanu!");
		return PLUGIN_HANDLED;
	}
	
	new szPassword[32];
	
	read_args(szPassword, charsmax(szPassword));
	remove_quotes(szPassword);
	
	if(equal(szPassword, ""))
	{
		cod_print_chat(id, DontChange, "Nie wpisano hasla zarzadzania klanem. Wpisz je teraz!");
		client_cmd(id, "messagemode Ustaw_Haslo");
		return PLUGIN_HANDLED;
	}
	
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iClan[id], aClan);
	
	copy(aClan[PASSWORD], charsmax(aClan[PASSWORD]), szPassword);
	ArraySetArray(gClans, iClan[id], aClan);
	
	SaveClan(iClan[id]);
	
	client_print(id, print_center, "Haslo zostalo ustawione!");
	cod_print_chat(id, DontChange, "Haslo zarzadzania klanem zostalo ustawione.");
	cod_print_chat(id, DontChange, "Wpisz w konsoli^x03 setinfo ^"_klan^" ^"%s^"^x01.", szPassword);
	
	Set(id, iPassword);
	
	cmd_execute(id, "setinfo _klan %s", szPassword);
	cmd_execute(id, "writecfg klan");
	
	return PLUGIN_HANDLED;
}

public ShowLeaveConfirmMenu(id)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
	
	new menu = menu_create("\wJestes \ypewien\w, ze chcesz \ropuscic \wklan?", "LeaveConfirmMenu_Handler");
	
	menu_additem(menu, "Tak", "0");
	menu_additem(menu, "Nie^n", "1");
	
	menu_setprop(menu, MPROP_EXITNAME, "\wWyjdz");
	
	menu_display(id, menu, 0);
	return PLUGIN_CONTINUE;
}

public LeaveConfirmMenu_Handler(id, menu, item)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_HANDLED;
		
	client_cmd(id, "spk CodMod/select2");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new szData[6], iAccess, iCallback;
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), _, _, iCallback);
	
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iClan[id], aClan);
	
	switch(str_to_num(szData))
	{
		case 0: 
		{
			if(get_user_status(id, iClan[id]) == LEADER)
			{
				cod_print_chat(id, DontChange, "Oddaj przywodctwo klanu jednemu z czlonkow zanim go upuscisz.");
				ClanMenu(id);
				return PLUGIN_HANDLED;
			}
			
			log_to_file("addons/amxmodx/logs/cod_clans.log", "Opuszczenie Klanu: %s", szMemberName[id]);
			
			cod_print_chat(id, DontChange, "Opusciles swoj klan.");
			
			set_user_clan(id);
			
			ClanMenu(id);
		}
		case 1: ClanMenu(id);
	}
	return PLUGIN_HANDLED;
}

public ShowMembersOnlineMenu(id)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
	
	new szName[64], iPlayers[32], iNum, iNumPlayers = 0;
	get_players(iPlayers, iNum);
	
	new menu = menu_create("\wCzlonkowie \rOnline:", "MembersOnlineMenu_Handler");
	
	for(new i = 0, iPlayer; i < iNum; i++)
	{
		iPlayer = iPlayers[i];
		
		if(iClan[id] != iClan[iPlayer])
			continue;
			
		iNumPlayers++;
		
		get_user_name(iPlayer, szName, charsmax(szName));
		
		switch(get_user_status(iPlayer, iClan[id]))
		{
			case MEMBER: add(szName, charsmax(szName), " \y[Czlonek]");
			case DEPUTY: add(szName, charsmax(szName), " \y[Zastepca]");
			case LEADER: add(szName, charsmax(szName), " \y[Przywodca]");
		}
		menu_additem(menu, szName);
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "\wWyjdz");
	menu_display(id, menu, 0);
	
	if(!iNumPlayers)
	{
		menu_destroy(menu);
		cod_print_chat(id, DontChange, "Na serwerze nie ma zadnego czlonka twojego klanu!");
	}
	return PLUGIN_CONTINUE;
}

public MembersOnlineMenu_Handler(id, menu, item)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	menu_destroy(menu);
	
	ShowMembersOnlineMenu(id);
	
	return PLUGIN_HANDLED;
}

public CmdCheckPassword(id)
{
	if(!iClan[id] || get_user_status(id, iClan[id]) < DEPUTY)
		return PLUGIN_HANDLED;
	
	new szPassword[32];
	read_args(szPassword, charsmax(szPassword));
	
	remove_quotes(szPassword);
	
	if(equal(szPassword, ""))
	{
		cod_print_chat(id, DontChange, "Nie wpisales hasla zarzadzania klanem!");
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iClan[id], aClan);
	
	if(!equal(aClan[PASSWORD], szPassword))
	{
		cod_print_chat(id, DontChange, "Podane haslo zarzadzania klanem jest nieprawidlowe!");
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	Set(id, iPassword);
	
	cod_print_chat(id, DontChange, "Wpisane haslo jest prawidlowe.");
	
	ShowLeaderMenu(id);
	
	return PLUGIN_HANDLED;
}

public ShowLeaderMenu(id)
{
	if(Get(id, iPassword))
	{
		if(!is_user_connected(id) || !iClan[id])
			return PLUGIN_CONTINUE;
		
		client_cmd(id, "spk CodMod/select2");
	
		new menu = menu_create("\wZarzadzaj \rKlanem", "LeaderMenu_Handler");
		
		new callback = menu_makecallback("LeaderMenu_Callback");

		menu_additem(menu, "\wRozwiaz \yKlan", _, _, callback);
		menu_additem(menu, "\wUlepsz \yUmiejetnosci", _, _, callback);
		menu_additem(menu, "\wZapros \yGracza", "3", _, callback);
		menu_additem(menu, "\wZarzadzaj \yCzlonkami", "4", _, callback);
		menu_additem(menu, "\wZmien \yNazwe Klanu^n", "5", _, callback);
		menu_additem(menu, "\wWroc", "6", _, callback);
		
		menu_setprop(menu, MPROP_EXITNAME, "\wWyjdz");
	
		menu_display(id, menu, 0);
	}
	else
	{
		client_cmd(id, "messagemode Podaj_Haslo");
		cod_print_chat(id, DontChange, "Wpisz jednorazowo haslo zarzadzania klanem.");
		client_print(id, print_center, "Wpisz haslo zarzadzania klanem");
	}
	return PLUGIN_CONTINUE;
}

public LeaderMenu_Callback(id, menu, item)
{
	switch(item)
	{
		case 1: get_user_status(id, iClan[id]) == LEADER ? ITEM_ENABLED : ITEM_DISABLED;
		case 2: 
		{
			new aClan[ClanInfo];
			ArrayGetArray(gClans, iClan[id], aClan);
				
			if(((aClan[LEVEL]*iMembersPerLevel) + iMaxMembers) <= aClan[MEMBERS])
				return ITEM_DISABLED;
		}
	}
	return ITEM_ENABLED;
}

public LeaderMenu_Handler(id, menu, item)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_HANDLED;
		
	client_cmd(id, "spk CodMod/select2");
	
	if(item == MENU_EXIT)
	{
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	switch(item)
	{
		case 0: ShowDisbandConfirmMenu(id);
		case 1: ShowSkillsMenu(id);
		case 2: ShowInviteMenu(id);
		case 3: ShowMembersMenu(id);
		case 4: client_cmd(id, "messagemode Nowa_Nazwa");
		case 5: ClanMenu(id);
	}
	return PLUGIN_HANDLED;
}

public ShowDisbandConfirmMenu(id)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
	
	new menu = menu_create("\wJestes \ypewien\w, ze chcesz \rrozwiazac\w klan?", "DisbandConfirmMenu_Handler");
	
	menu_additem(menu, "Tak", "0");
	menu_additem(menu, "Nie^n", "1");
	
	menu_setprop(menu, MPROP_EXITNAME, "\wWyjdz");
	
	menu_display(id, menu, 0);
	return PLUGIN_CONTINUE;
}

public DisbandConfirmMenu_Handler(id, menu, item)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_HANDLED;
		
	client_cmd(id, "spk CodMod/select2");
	
	if(item == MENU_EXIT)
		return PLUGIN_HANDLED;
	
	new szData[6], iAccess, iCallback;
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), _, _, iCallback);
	
	switch(str_to_num(szData))
	{
		case 0: 
		{
			new szTempName[64], iPlayers[32], aClan[ClanInfo], iNum, iPlayer, iPlayerClan;
			
			ArrayGetArray(gClans, iClan[id], aClan);
			
			get_players(iPlayers, iNum);
			
			for(new i = 0; i < iNum; i++)
			{
				iPlayer = iPlayers[i];
				
				if(iPlayer == id)
					continue;
				
				if(iClan[id] != iClan[iPlayer] || is_user_hltv(iPlayer) || !is_user_connected(iPlayer))
					continue;

				set_user_clan(iPlayer);
				
				cod_print_chat(iPlayer, DontChange, "Twoj klan zostal rozwiazany.");
			}
			
			iPlayerClan = iClan[id];
			set_user_clan(id);
			
			cod_print_chat(id, DontChange, "Rozwiazales swoj klan.");
			
			mysql_escape_string(aClan[NAME], szTempName, charsmax(szTempName));
			
			formatex(szCache, charsmax(szCache), "DELETE FROM `clans` WHERE clan_name = '%s'", szTempName);
			SQL_ThreadQuery(hSqlTuple, "Table_Handle", szCache);
			log_to_file("addons/amxmodx/logs/cod_clans.log", "Rozwiazanie Klanu (1): %s", szCache);
			
			formatex(szCache, charsmax(szCache), "UPDATE `clans_members` SET flag = '0', clan = '' WHERE clan = '%s'", szTempName);
			SQL_ThreadQuery(hSqlTuple, "Table_Handle", szCache);
			log_to_file("addons/amxmodx/logs/cod_clans.log", "Rozwiazanie Klanu (2): %s", szCache);
			
			ArrayDeleteItem(gClans, iPlayerClan);
			
			ClanMenu(id);
		}
		case 1: ClanMenu(id);
	}
	return PLUGIN_HANDLED;
}

public ShowSkillsMenu(id)
{	
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
		
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iClan[id], aClan);
	
	new szMenu[128];
	
	formatex(szMenu, charsmax(szMenu), "\wMenu \rUmiejetnosci^n\rHonor Klanu: %i", aClan[HONOR]);
	new menu = menu_create(szMenu, "SkillsMenu_Handler");
	
	formatex(szMenu, charsmax(szMenu), "Poziom Klanu \w[\rLevel: \y%i/%i\w] [\rKoszt: \y%i AP\w]", aClan[LEVEL], iLevelMax, iLevelCost+iNextLevelCost*aClan[LEVEL]);
	menu_additem(menu, szMenu, "0");
	formatex(szMenu, charsmax(szMenu), "Predkosc \w[\rLevel: \y%i/%i\w] [\rKoszt: \y%i AP\w]", aClan[SPEED], iSpeedMax, iSpeedCost+iNextSpeedCost*aClan[SPEED]);
	menu_additem(menu, szMenu, "1");
	formatex(szMenu, charsmax(szMenu), "Grawitacja \w[\rLevel: \y%i/%i\w] [\rKoszt: \y%i AP\w]", aClan[GRAVITY], iGravityMax, iGravityCost+iNextGravityCost*aClan[GRAVITY]);
	menu_additem(menu, szMenu, "2");
	formatex(szMenu, charsmax(szMenu), "Obrazenia \w[\rLevel: \y%i/%i\w] [\rKoszt: \y%i AP\w]", aClan[DAMAGE], iDamageMax, iDamageCost+iNextDamageCost*aClan[DAMAGE]);
	menu_additem(menu, szMenu, "3");
	formatex(szMenu, charsmax(szMenu), "Obezwladnienie \w[\rLevel: \y%i/%i\w] [\rKoszt: \y%i AP\w]", aClan[DROP], iWeaponDropMax, iWeaponDropCost+iNextWeaponDropCost*aClan[DROP]);
	menu_additem(menu, szMenu, "4");
	
	menu_setprop(menu, MPROP_NOCOLORS, 1);
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\r");
	menu_setprop(menu, MPROP_EXITNAME, "\wWyjdz");
	
	menu_display(id, menu);
	
	return PLUGIN_CONTINUE;
}

public SkillsMenu_Handler(id, menu, item)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
		
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		ClanMenu(id);
		return PLUGIN_CONTINUE;
	}
	
	new aClan[ClanInfo], iUpgraded;
	ArrayGetArray(gClans, iClan[id], aClan);
	
	switch(item)
	{
		case 0:
		{
			if(aClan[LEVEL] == iLevelMax)
			{
				cod_print_chat(id, DontChange, "Twoj klan ma juz maksymalny Poziom.");
				ShowSkillsMenu(id);
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = aClan[HONOR] - (iLevelCost + iNextLevelCost*aClan[LEVEL]);
			
			if(iRemaining < 0)
			{
				cod_print_chat(id, DontChange, "Twoj klan nie ma wystarczajacej ilosci Honoru.");
				ShowSkillsMenu(id);
				return PLUGIN_HANDLED;
			}
			
			iUpgraded = 1;
			
			aClan[LEVEL]++;
			aClan[HONOR] = iRemaining;
			
			cod_print_chat(id, DontChange, "Ulepszyles klan na^x03 %i Poziom^x01!", aClan[LEVEL]);
		}
		case 1:
		{
			if(aClan[SPEED] == iSpeedMax)
			{
				cod_print_chat(id, DontChange, "Twoj klan ma juz maksymalny poziom tej umiejetnosci.");
				ShowSkillsMenu(id);
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = aClan[HONOR] - (iSpeedCost + iNextSpeedCost*aClan[SPEED]);
			
			if(iRemaining < 0)
			{
				cod_print_chat(id, DontChange, "Twoj klan nie ma wystarczajacej ilosci Honoru.");
				ShowSkillsMenu(id);
				return PLUGIN_HANDLED;
			}
			
			iUpgraded = 2;
			
			aClan[SPEED]++;
			aClan[HONOR] = iRemaining;
			
			cod_print_chat(id, DontChange, "Ulepszyles umiejetnosc^x03 Predkosc^x01 na^x03 %i^x01 poziom!", aClan[SPEED]);
		}
		case 2:
		{
			if(aClan[GRAVITY] == iGravityMax)
			{
				cod_print_chat(id, DontChange, "Twoj klan ma juz maksymalny poziom tej umiejetnosci.");
				ShowSkillsMenu(id);
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = aClan[HONOR] - (iGravityCost + iNextGravityCost*aClan[GRAVITY]);
			
			if(iRemaining < 0)
			{
				cod_print_chat(id, DontChange, "Twoj klan nie ma wystarczajacej ilosci Honoru.");
				ShowSkillsMenu(id);
				return PLUGIN_HANDLED;
			}
			
			iUpgraded = 3;
			
			aClan[GRAVITY]++;
			aClan[HONOR] = iRemaining;
			
			cod_print_chat(id, DontChange, "Ulepszyles umiejetnosc^x03 Grawitacja^x01 na^x03 %i^x01 poziom!", aClan[GRAVITY]);
		}
		case 3:
		{
			if(aClan[DAMAGE] == iDamageMax)
			{
				cod_print_chat(id, DontChange, "Twoj klan ma juz maksymalny poziom tej umiejetnosci.");
				ShowSkillsMenu(id);
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = aClan[HONOR] - (iDamageCost + iNextDamageCost*aClan[DAMAGE]);
			
			if(iRemaining < 0)
			{
				cod_print_chat(id, DontChange, "Twoj klan nie ma wystarczajacej ilosci Honoru.");
				ShowSkillsMenu(id);
				return PLUGIN_HANDLED;
			}
			
			iUpgraded = 4;
			
			aClan[DAMAGE]++;
			aClan[HONOR] = iRemaining;
			
			cod_print_chat(id, DontChange, "Ulepszyles umiejetnosc^x03 Obrazenia^x01 na^x03 %i^x01 poziom!", aClan[DAMAGE]);
		}
		case 4:
		{
			if(aClan[DROP] == iWeaponDropMax)
			{
				cod_print_chat(id, DontChange, "Twoj klan ma juz maksymalny poziom tej umiejetnosci.");
				ShowSkillsMenu(id);
				return PLUGIN_HANDLED;
			}
			
			new iRemaining = aClan[HONOR] - (iWeaponDropCost + iNextWeaponDropCost*aClan[DROP]);
			
			if(iRemaining < 0)
			{
				cod_print_chat(id, DontChange, "Twoj klan nie ma wystarczajacej ilosci Honoru.");
				ShowSkillsMenu(id);
				return PLUGIN_HANDLED;
			}
			
			iUpgraded = 5;
			
			aClan[DROP]++;
			aClan[HONOR] = iRemaining;
			
			cod_print_chat(id, DontChange, "Ulepszyles umiejetnosc^x03 Obezwladnienie^x01 na^x03 %i^x01 poziom!", aClan[DROP]);
		}
	}
	
	ArraySetArray(gClans, iClan[id], aClan);
	
	new iPlayers[32], iNum, iPlayer, szName[32];
	
	get_players(iPlayers, iNum);
	get_user_name(id, szName, charsmax(szName));
	
	for(new i = 0 ; i < iNum; i++)
	{
		iPlayer = iPlayers[i];
		
		if(iPlayer == id || iClan[iPlayer] != iClan[id])
			continue;
		
		switch(iUpgraded)
		{
			case 1: cod_print_chat(iPlayer, DontChange, "^x03 %s^x01 ulepszyl klan na^x03 %i Poziom^x01!", szName, aClan[LEVEL]);
			case 2: cod_print_chat(iPlayer, DontChange, "^x03 %s^x01 ulepszyl umiejetnosc^x03 Predkosc^x01 na^x03 %i^x01 poziom!", szName, aClan[SPEED]);
			case 3: cod_print_chat(iPlayer, DontChange, "^x03 %s^x01 ulepszyl umiejetnosc^x03 Grawitacja^x01 na^x03 %i^x01 poziom!", szName, aClan[GRAVITY]);
			case 4: cod_print_chat(iPlayer, DontChange, "^x03 %s^x01 ulepszyl umiejetnosc^x03 Obrazenia^x01 na^x03 %i^x01 poziom!", szName, aClan[DAMAGE]);
			case 5: cod_print_chat(iPlayer, DontChange, "^x03 %s^x01 ulepszyl umiejetnosc^x03 Obezwladnienie^x01 na^x03 %i^x01 poziom!", szName, aClan[DROP]);
		}
	}
	
	SaveClan(iClan[id]);
	
	ShowSkillsMenu(id);
	
	return PLUGIN_HANDLED;
}

public ShowInviteMenu(id)
{	
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
	
	new szName[32], iPlayers[32], szInfo[6], iNum, iNumPlayers = 0;
	get_players(iPlayers, iNum);
	
	new menu = menu_create("\wWybierz \rGracza \wdo zaproszenia:", "InviteMenu_Handler");
	
	for(new i = 0, iPlayer; i < iNum; i++)
	{
		iPlayer = iPlayers[i];
		
		if(iPlayer == id || iClan[iPlayer] == iClan[id] || is_user_hltv(iPlayer) || !is_user_connected(iPlayer))
			continue;

		iNumPlayers++;
		
		get_user_name(iPlayer, szName, charsmax(szName));
		num_to_str(iPlayer, szInfo, charsmax(szInfo));
		menu_additem(menu, szName, szInfo);
	}	
	
	menu_display(id, menu, 0);
	
	if(!iNumPlayers)
	{
		menu_destroy(menu);
		cod_print_chat(id, DontChange, "Na serwerze nie ma gracza, ktorego moglbys zaprosic!");
	}
	return PLUGIN_CONTINUE;
}

public InviteMenu_Handler(id, menu, item)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
	
	if(item == MENU_EXIT)
	{
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new szName[32], szData[6], iAccess, iCallback;
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), szName, charsmax(szName), iCallback);
	
	new iPlayer = str_to_num(szData);

	if(!is_user_connected(iPlayer))
		return PLUGIN_HANDLED;
		
	if(!cod_check_password(id))
	{
		cod_force_password(iPlayer);
		return PLUGIN_HANDLED;
	}
	
	ShowInviteConfirmMenu(id, iPlayer);

	cod_print_chat(id, DontChange, "Zaprosiles %s do do twojego klanu.", szName);
	
	ClanMenu(id);
	
	return PLUGIN_HANDLED;
}

public ShowInviteConfirmMenu(id, iPlayer)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
	
	new szMenuTitle[128], szName[32], szInfo[6], aClan[ClanInfo], menu;
	
	get_user_name(id, szName, charsmax(szName));
	
	ArrayGetArray(gClans, iClan[id], aClan);
	
	formatex(szMenuTitle, charsmax(szMenuTitle), "%s zaprosil cie do klanu %s", szName, aClan[NAME]);
	
	menu = menu_create(szMenuTitle, "InviteConfirmMenu_Handler");
	
	num_to_str(iClan[id], szInfo, charsmax(szInfo));
	
	menu_additem(menu, "Dolacz", szInfo);
	menu_additem(menu, "Odrzuc", "-1");
	
	menu_display(iPlayer, menu, 0);	
	return PLUGIN_CONTINUE;
}

public InviteConfirmMenu_Handler(id, menu, item)
{
	if(!is_user_connected(id) || iClan[id])
		return PLUGIN_HANDLED;
		
	client_cmd(id, "spk CodMod/select2");
	
	if(item == MENU_EXIT)
		return PLUGIN_HANDLED;
	
	new szData[6], iAccess, iCallback;
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), _, _, iCallback);
	
	new iPlayerClan = str_to_num(szData);
	
	if(!iPlayerClan) return PLUGIN_HANDLED;
	
	if(get_user_status(id, iClan[id]) == LEADER)
	{
		cod_print_chat(id, DontChange, "Nie mozesz dolaczyc do klanu, jesli jestes zalozycielem innego.");
		return PLUGIN_HANDLED;
	}
	
	new aClan[ClanInfo];
	
	ArrayGetArray(gClans, iPlayerClan, aClan);
	
	if(((aClan[LEVEL]*iMembersPerLevel) + iMaxMembers) <= aClan[MEMBERS])
	{
		cod_print_chat(id, DontChange, "Niestety, w tym klanie nie ma juz wolnego miejsca.");
		return PLUGIN_HANDLED;
	}
	
	set_user_clan(id, iPlayerClan);
	
	cod_print_chat(id, DontChange, "Dolaczyles do klanu^x03 %s^01.", aClan[NAME]);
	
	return PLUGIN_HANDLED;
}

public ChangeName_Handle(id)
{
	if(!iClan[id] || get_user_status(id, iClan[id]) != LEADER)
		return PLUGIN_HANDLED;
	
	new szName[64], szTempName[64], szOldName[64];
	
	read_args(szName, charsmax(szName));
	remove_quotes(szName);
	
	if(equal(szName, ""))
	{
		cod_print_chat(id, DontChange, "Nie wpisano nowej nazwy klanu.");
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	mysql_escape_string(szName, szTempName, charsmax(szTempName));
	
	if(CheckClanName(szTempName))
	{
		cod_print_chat(id, DontChange, "Klan z taka nazwa juz istnieje.");
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iClan[id], aClan);
	
	mysql_escape_string(aClan[NAME], szOldName, charsmax(szOldName));
	
	copy(aClan[NAME], charsmax(aClan[NAME]), szName);
	ArraySetArray(gClans, iClan[id], aClan);
	
	formatex(szCache, charsmax(szCache), "UPDATE `clans_members` SET clan = '%s' WHERE clan = '%s'", szTempName, szOldName);
	SQL_ThreadQuery(hSqlTuple, "Table_Handle", szCache);
	log_to_file("addons/amxmodx/logs/cod_clans.log", "Zmiana Nazwy Klanu (1): %s", szCache);
	
	formatex(szCache, charsmax(szCache), "UPDATE `clans` SET clan_name = '%s' WHERE clan_name = '%s'", szTempName, szOldName);
	SQL_ThreadQuery(hSqlTuple, "Table_Handle", szCache);
	log_to_file("addons/amxmodx/logs/cod_clans.log", "Zmiana Nazwy Klanu (2): %s", szCache);
	
	cod_print_chat(id, DontChange, "Zmieniles nazwe klanu na^x03 %s^x01.", aClan[NAME]);
	
	return PLUGIN_CONTINUE;
}

public ShowMembersMenu(id)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CodMod/select2");
	
	new szTempName[64], szData[1], aClan[ClanInfo];
	
	ArrayGetArray(gClans, iClan[id], aClan);
	
	mysql_escape_string(aClan[NAME], szTempName, charsmax(szTempName));
	
	szData[0] = id;
	
	formatex(szCache, charsmax(szCache), "SELECT * FROM `clans_members` WHERE clan = '%s' ORDER BY flag DESC", szTempName);
	SQL_ThreadQuery(hSqlTuple, "MembersMenuHandler", szCache, szData, charsmax(szData));
	
	return PLUGIN_CONTINUE;
}

public MembersMenuHandler(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_to_file("addons/amxmodx/logs/cod_clans.log", "<Query> Error: %s", szError);
		return;
	}
	
	new id = szData[0];

	new szName[33], szInfo[64], iStatus;
	
	new menu = menu_create("\wZarzadzaj \rCzlonkami:^n\rWybierz czlonka, aby pokazac mozliwe opcje.", "MemberMenu_Handler");
	
	while(SQL_MoreResults(hQuery))
	{
		SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "name"), szName, charsmax(szName));
		iStatus = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "flag"));
		
		formatex(szInfo, charsmax(szInfo), "%s#%i", szName, iStatus);
		
		switch(iStatus)
		{
			case MEMBER: add(szName, charsmax(szName), " \y[Czlonek]");
			case DEPUTY: add(szName, charsmax(szName), " \y[Zastepca]");
			case LEADER: add(szName, charsmax(szName), " \y[Przywodca]");
		}
		
		menu_additem(menu, szName, szInfo);
		SQL_NextRow(hQuery);
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	menu_setprop(menu, MPROP_EXITNAME, "\wWyjdz");
	
	menu_display(id, menu, 0);
}

public MemberMenu_Handler(id, menu, item)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_HANDLED;
		
	client_cmd(id, "spk CodMod/select2");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new szInfo[64], szName[33], szTempFlag[2], iAccess, iCallback, iFlag, iID;
	menu_item_getinfo(menu, item, iAccess, szInfo, charsmax(szInfo), _, _, iCallback);
	
	menu_destroy(menu);

	strtok(szInfo, szName, charsmax(szName), szTempFlag, charsmax(szTempFlag), '#');
	
	iFlag = str_to_num(szTempFlag);
	iID = get_user_index(szName);

	if(iID == id)
	{
		cod_print_chat(id, DontChange, "Nie mozesz zarzadzac soba!");
		ShowMembersMenu(id);
		return PLUGIN_HANDLED;
	}
	
	if(iClan[iID])	
		iChosenID[id] = get_user_userid(iID);

	if(iFlag == LEADER)
	{
		cod_print_chat(id, DontChange, "Nie mozna zarzadzac przywodca klanu!");
		ShowMembersMenu(id);
		return PLUGIN_HANDLED;
	}

	formatex(szChosenName[id], charsmax(szChosenName), szName);
	
	new menu = menu_create("\wWybierz \rOpcje:", "MemberOption_Handler");
	
	if(get_user_status(id, iClan[id]) == LEADER)
	{
		menu_additem(menu, "Przekaz \yPrzywodctwo", "1");
		
		if(iFlag == MEMBER)
			menu_additem(menu, "Mianuj \yZastepce", "2");

		if(iFlag == DEPUTY)
			menu_additem(menu, "Degraduj \yZastepce", "3");
	}
	menu_additem(menu, "Wyrzuc \yGracza", "4");
	
	menu_setprop(menu, MPROP_EXITNAME, "\wWyjdz");
	
	menu_display(id, menu, 0);
	
	return PLUGIN_CONTINUE;
}

public MemberOption_Handler(id, menu, item)
{
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_HANDLED;
		
	client_cmd(id, "spk CodMod/select2");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		ClanMenu(id);
		return PLUGIN_HANDLED;
	}
	
	new szInfo[3], iAccess, iCallback;
	menu_item_getinfo(menu, item, iAccess, szInfo, charsmax(szInfo), _, _, iCallback);

	switch(str_to_num(szInfo))
	{
		case 1: UpdateMember(id, LEADER);
		case 2:	UpdateMember(id, DEPUTY);
		case 3:	UpdateMember(id, MEMBER);
		case 4: UpdateMember(id, NONE);
	}
	
	menu_destroy(menu);
	
	return PLUGIN_CONTINUE;
}

public UpdateMember(id, status)
{
	new iPlayers[32], iNum, iPlayer, bool:bPlayerOnline;
	
	get_players(iPlayers, iNum);

	for(new i = 0; i < iNum; i++)
	{
		iPlayer = iPlayers[i];

		if(iClan[iPlayer] != iClan[id] || is_user_hltv(iPlayer) || !is_user_connected(iPlayer))
			continue;
	
		if(get_user_userid(iPlayer) == iChosenID[id])
		{
			switch(status)
			{
				case LEADER:
				{
					set_user_status(id, iClan[id], DEPUTY);
					set_user_status(iPlayer, iClan[id], LEADER);
					cod_print_chat(iPlayer, DontChange, "Zostales mianowany przywodca klanu!");
				}
				case DEPUTY:
				{
					set_user_status(iPlayer, iClan[id], DEPUTY);
					cod_print_chat(iPlayer, DontChange, "^x01 Zostales zastepca przywodcy klanu!");		
				}
				case MEMBER:
				{
					set_user_status(iPlayer, iClan[id], MEMBER);
					cod_print_chat(iPlayer, DontChange, "^x01 Zostales zdegradowany do rangi czlonka klanu.");
				}
				case NONE:
				{
					log_to_file("addons/amxmodx/logs/cod_clans.log", "Wyrzucenie z Klanu: %s", szChosenName[id]);
					set_user_clan(iPlayer);
					cod_print_chat(iPlayer, DontChange, "Zostales wyrzucony z klanu.");
				}
			}

			bPlayerOnline = true;
			continue;
		}
		
		switch(status)
		{
			case LEADER: cod_print_chat(iPlayer, DontChange, "^x03 %s^01 zostal nowym przywodca klanu.", szChosenName[id]);
			case DEPUTY: cod_print_chat(iPlayer, DontChange, "^x03 %s^x01 zostal zastepca przywodcy klanu.", szChosenName[id]);
			case MEMBER: cod_print_chat(iPlayer, DontChange, "^x03 %s^x01 zostal zdegradowany do rangi czlonka klanu.", szChosenName[id]);
			case NONE: cod_print_chat(iPlayer, DontChange, "^x03 %s^01 zostal wyrzucony z klanu.", szChosenName[id]);
		}
	}
	
	if(!bPlayerOnline)
	{
		new TempName[64];
		mysql_escape_string(szChosenName[id], TempName, charsmax(TempName));
		
		SaveMember(id, status, TempName);
		
		if(status == NONE)
		{
			new aClan[ClanInfo];
			ArrayGetArray(gClans, iClan[id], aClan);
			
			aClan[MEMBERS]--;
			ArraySetArray(gClans, iClan[id], aClan);
			
			SaveClan(iClan[id]);
			
			log_to_file("addons/amxmodx/logs/cod_clans.log", "Wyrzucenie z Klanu: %s", szChosenName[id]);
		}
	}
	
	ClanMenu(id);
	
	return PLUGIN_HANDLED;
}

public DepositHonor_Handle(id)
{
	if(!iClan[id])
		return PLUGIN_HANDLED;
		
	if(!cod_check_password(id))
	{
		cod_force_password(id);
		return PLUGIN_HANDLED;
	}
		
	new szArgs[10], aClan[ClanInfo], iHonor;
	
	ArrayGetArray(gClans, iClan[id], aClan);
	
	read_args(szArgs, charsmax(szArgs));
	remove_quotes(szArgs);
	iHonor = str_to_num(szArgs);
	
	if(!iHonor)
	{
		cod_print_chat(id, DontChange, "Probujesz wplacic ujemna lub zerowa ilosc Honoru!");
		return PLUGIN_HANDLED;
	}
	
	if(iHonor > cod_get_user_honor(id))
	{
		cod_print_chat(id, DontChange, "Nie masz tyle Honoru!");
		return PLUGIN_HANDLED;
	}
	
	cod_set_user_honor(id, cod_get_user_honor(id) - iHonor);
	
	aClan[HONOR] += iHonor;
	ArraySetArray(gClans, iClan[id], aClan);
	
	SaveClan(iClan[id]);
	
	cod_print_chat(id, DontChange, "Wplaciles^x03 %i^x01 Honoru na rzecz klanu.", iHonor);
	cod_print_chat(id, DontChange, "Aktualnie twoj klan ma^x03 %i^x01 Honoru.", aClan[HONOR]);
	
	return PLUGIN_HANDLED;
}

public Clans_Top15(id)
{
	new szTemp[512], szData[1];
	szData[0] = id;
	
	format(szTemp, charsmax(szTemp), "SELECT clan_name, members, honor, kills, level, speed, gravity, weapondrop, damage FROM `clans` ORDER BY kills DESC LIMIT 15");
	SQL_ThreadQuery(hSqlTuple, "ShowClans_Top15", szTemp, szData, charsmax(szData));
}

public ShowClans_Top15(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState) 
	{
		log_to_file("addons/amxmodx/logs/cod_clans.log", "SQL Error: %s (%d)", szError, iError);
		return PLUGIN_HANDLED;
	}
	
	new id = szData[0];
	
	static iLen, iPlace = 0;
	
	iLen = format(szMessage, charsmax(szMessage), "<body bgcolor=#000000><font color=#FFB000><pre>");
	iLen += format(szMessage[iLen], charsmax(szMessage) - iLen, "%1s %-22.22s %4s %8s %6s %8s %9s %12s %11s^n", "#", "Nazwa", "Czlonkowie", "Poziom", "Zabicia", "Honor", "Predkosc", "Grawitacja", "Obezwladnienie", "Obrazenia");
	
	while(SQL_MoreResults(hQuery))
	{
		iPlace++;
		
		static szName[32], iMembers, iLevel, iKills, iHonor, iSpeed, iGravity, iWeaponDrop, iDamage;
		
		SQL_ReadResult(hQuery, 0, szName, charsmax(szName));
		replace_all(szName, charsmax(szName), "<", "");
		replace_all(szName,charsmax(szName), ">", "");
		
		iMembers = SQL_ReadResult(hQuery, 1);
		iHonor = SQL_ReadResult(hQuery, 2);
		iKills = SQL_ReadResult(hQuery, 3);
		iLevel = SQL_ReadResult(hQuery, 4);
		iSpeed = SQL_ReadResult(hQuery, 5);
		iGravity = SQL_ReadResult(hQuery, 6);
		iWeaponDrop = SQL_ReadResult(hQuery, 7);
		iDamage = SQL_ReadResult(hQuery, 8);
		
		if(iPlace >= 10)
			iLen += format(szMessage[iLen], charsmax(szMessage) - iLen, "%1i %22.22s %5d %8d %10d %8d %7d %10d %14d^n", iPlace, szName, iMembers, iLevel, iKills, iHonor, iSpeed, iGravity, iWeaponDrop, iDamage);
		else
			iLen += format(szMessage[iLen], charsmax(szMessage) - iLen, "%1i %22.22s %6d %8d %10d %8d %7d %10d %14d^n", iPlace, szName, iMembers, iLevel, iKills, iHonor, iSpeed, iGravity, iWeaponDrop, iDamage);

		SQL_NextRow(hQuery);
	}
	
	show_motd(id, szMessage, "Top 15 Klanow");
	
	return PLUGIN_HANDLED;
}

public HandleSayText(msgId, msgDest, msgEnt)
{
	new id = get_msg_arg_int(1);
	
	if(!is_user_connected(id) || !iClan[id])
		return PLUGIN_CONTINUE;
	
	new szTmp[192], szTmp2[192], szPrefix[20], aClan[ClanInfo], i = iClan[id];
	
	get_msg_arg_string(2, szTmp, charsmax(szTmp))

	ArrayGetArray(gClans, i, aClan);
	
	formatex(szPrefix, charsmax(szPrefix), "^x04[%s]", aClan[NAME]);
	
	if(!equal(szTmp, "#Cstrike_Chat_All"))
	{
		add(szTmp2, charsmax(szTmp2), szPrefix);
		add(szTmp2, charsmax(szTmp2), " ");
		add(szTmp2, charsmax(szTmp2), szTmp);
	}
	else
	{
		add(szTmp2, charsmax(szTmp2), szPrefix);
		add(szTmp2, charsmax(szTmp2), "^x03 %s1^x01 :  %s2");
	}
	
	set_msg_arg_string(2, szTmp2);
	
	return PLUGIN_CONTINUE;
}

set_user_clan(id, iPlayerClan = 0, iOwner = 0)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;

	new aClan[ClanInfo];
	
	if(iPlayerClan == 0)
	{
		ArrayGetArray(gClans, iClan[id], aClan);
		aClan[MEMBERS]--;
		ArraySetArray(gClans, iClan[id], aClan);
		TrieDeleteKey(aClan[STATUS], szMemberName[id]);
		
		SaveClan(iClan[id]);
		
		SaveMember(id, NONE);
		
		Rem(id, iPassword);
		
		iClan[id] = 0;
	}
	else
	{
		iClan[id] = iPlayerClan;
		
		ArrayGetArray(gClans, iClan[id], aClan);
		
		new szTempName[64];
		mysql_escape_string(aClan[NAME], szTempName, charsmax(szTempName));
		
		aClan[MEMBERS]++;
		ArraySetArray(gClans, iClan[id], aClan);
		TrieSetCell(aClan[STATUS], szMemberName[id], iOwner ? LEADER : MEMBER);
		
		SaveMember(id, iOwner ? LEADER : MEMBER, _, szTempName);
		
		SaveClan(iClan[id]);
	}
	
	return PLUGIN_CONTINUE;
}

set_user_status(id, iPlayerClan, iStatus)
{
	if(!is_user_connected(id) || !iPlayerClan)
		return PLUGIN_CONTINUE;
		
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iPlayerClan, aClan);
	TrieSetCell(aClan[STATUS], szMemberName[id], iStatus);
	
	SaveMember(id, iStatus);
	
	return PLUGIN_CONTINUE;
}

get_user_status(id, iPlayerClan)
{
	if(!is_user_connected(id) || iPlayerClan == 0)
		return NONE;
	
	new aClan[ClanInfo];
	ArrayGetArray(gClans, iPlayerClan, aClan);
	
	new iStatus;
	TrieGetCell(aClan[STATUS], szMemberName[id], iStatus);
	
	return iStatus;
}

public SqlInit()
{
	new szData[4][64];
	get_cvar_string("cod_clans_sql_host", szData[0], charsmax(szData)); 
	get_cvar_string("cod_clans_sql_user", szData[1], charsmax(szData)); 
	get_cvar_string("cod_clans_sql_pass", szData[2], charsmax(szData)); 
	get_cvar_string("cod_clans_sql_db", szData[3], charsmax(szData)); 
	
	hSqlTuple = SQL_MakeDbTuple(szData[0], szData[1], szData[2], szData[3]);
	
	formatex(szCache, charsmax(szCache), "CREATE TABLE IF NOT EXISTS `clans` (`clan_name` varchar(64) NOT NULL, `password` varchar(64) NOT NULL, `members` int(5) NOT NULL DEFAULT '1', `honor` int(5) NOT NULL DEFAULT '0', `kills` int(5) NOT NULL DEFAULT '0', ");
	add(szCache, charsmax(szCache), "`level` int(5) NOT NULL DEFAULT '0', `speed` int(5) NOT NULL DEFAULT '0', `gravity` int(5) NOT NULL DEFAULT '0', `damage` int(5) NOT NULL DEFAULT '0', `weapondrop` int(5) NOT NULL DEFAULT '0', PRIMARY KEY (`clan_name`));");
	SQL_ThreadQuery(hSqlTuple, "Table_Handle", szCache);
	
	formatex(szCache, charsmax(szCache), "CREATE TABLE IF NOT EXISTS `clans_members` (`name` varchar(64) NOT NULL, `clan` varchar(64) NOT NULL, `flag` int(5) NOT NULL DEFAULT '0', PRIMARY KEY (`name`));");
	SQL_ThreadQuery(hSqlTuple, "Table_Handle", szCache);
}

public Table_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState)
	{
		if(iFailState == TQUERY_CONNECT_FAILED)
			log_to_file("addons/amxmodx/logs/cod_clans.log", "Table - Could not connect to SQL database.  [%d] %s", iError, szError);
		else if(iFailState == TQUERY_QUERY_FAILED)
			log_to_file("addons/amxmodx/logs/cod_clans.log", "Table Query failed. [%d] %s", iError, szError);

		return;
	}
}

public SaveClan(iClan)
{
	new szTempName[64], aClan[ClanInfo];
	
	ArrayGetArray(gClans, iClan, aClan);

	mysql_escape_string(aClan[NAME], szTempName, charsmax(szTempName));
	
	formatex(szCache, charsmax(szCache), "UPDATE `clans` SET password = '%s', level = '%i', honor = '%i', kills = '%i', members = '%i', speed = '%i', gravity = '%i', weapondrop = '%i', damage = '%i' WHERE clan_name = '%s'", 
	aClan[PASSWORD], aClan[LEVEL], aClan[HONOR], aClan[KILLS], aClan[MEMBERS], aClan[SPEED], aClan[GRAVITY], aClan[DROP], aClan[DAMAGE], szTempName);
	SQL_ThreadQuery(hSqlTuple, "Table_Handle", szCache);
	log_to_file("addons/amxmodx/logs/cod_clans.log", "Zapis Klanu: %s", szCache);
}

public LoadMember(id)
{
	get_user_name(id, szMemberName[id], charsmax(szMemberName));
	mysql_escape_string(szMemberName[id], szMemberName[id], charsmax(szMemberName))
	
	new szData[1];
	szData[0] = id;
	
	formatex(szCache, charsmax(szCache), "SELECT * FROM `clans_members` a JOIN `clans` b ON a.clan = b.clan_name WHERE a.name = '%s'", szMemberName[id]);
	SQL_ThreadQuery(hSqlTuple, "LoadMember_Handle", szCache, szData, charsmax(szData));
}

SaveMember(id, iStatus, szName[] = "", szClan[] = "")
{
	if(!iClan[id])
		return;
	
	if(iStatus)
	{
		if(strlen(szClan))
			formatex(szCache, charsmax(szCache), "UPDATE `clans_members` SET clan = '%s', flag = '%i' WHERE name = '%s'", szClan, iStatus, szMemberName[id]);
		else
			formatex(szCache, charsmax(szCache), "UPDATE `clans_members` SET flag = '%i' WHERE name = '%s'", iStatus, !strlen(szName) ? szMemberName[id] : szName);
	}
	else
		formatex(szCache, charsmax(szCache), "UPDATE `clans_members` SET clan = '', flag = '0' WHERE name = '%s'", !strlen(szName) ? szMemberName[id] : szName);

	log_to_file("addons/amxmodx/logs/cod_clans.log", "Zapis Czlonka Klanu: %s", szCache);

	SQL_ThreadQuery(hSqlTuple, "Table_Handle", szCache);
}

public LoadMember_Handle(iFailState, Handle:hQuery, szError[], iError, szData[], iDataSize)
{
	if(iFailState != TQUERY_SUCCESS)
	{
		log_to_file("addons/amxmodx/logs/cod_clans.log", "<Query> Error: %s", szError);
		return;
	}
	
	new id = szData[0];
	
	if(!is_user_connected(id))
		return;
	
	if(SQL_NumRows(hQuery))
	{
		new szClan[64], szPassword[32], aClan[ClanInfo], iStatus;

		SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "clan_name"), szClan, charsmax(szClan));
		if(!GetClanID(szClan))
		{
			copy(aClan[NAME], charsmax(szClan), szClan);
			aClan[STATUS] = _:TrieCreate();
		
			SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "password"), aClan[PASSWORD], charsmax(aClan[PASSWORD]));

			aClan[LEVEL] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "level"));
			aClan[HONOR] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "honor"));
			aClan[SPEED] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "speed"));
			aClan[GRAVITY] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "gravity"));
			aClan[DROP] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "weapondrop"));
			aClan[DAMAGE] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "damage"));
			aClan[KILLS] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "kills"));
			aClan[MEMBERS] = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "members"));

			ArrayPushArray(gClans, aClan);
		}
		
		iClan[id] = GetClanID(szClan);
		ArrayGetArray(gClans, iClan[id], aClan);
		iStatus = SQL_ReadResult(hQuery, SQL_FieldNameToNum(hQuery, "flag"));
		TrieSetCell(aClan[STATUS], szMemberName[id], iStatus);

		if(get_user_status(id, iClan[id]) < DEPUTY)
			return;

		cmd_execute(id, "exec klan.cfg");
		get_user_info(id, "_klan", szPassword, charsmax(szPassword));

		if(equal(aClan[PASSWORD], szPassword))
			Set(id, iPassword);
	}
	else
	{
		formatex(szCache, charsmax(szCache), "INSERT IGNORE INTO `clans_members` (`name`) VALUES ('%s');", szMemberName[id]);
		SQL_ThreadQuery(hSqlTuple, "Table_Handle", szCache);
	}
}

public CheckClanName(const szName[])
{
	new szCache[128], szError[128], iError, bool:bFound;
	
	formatex(szCache, charsmax(szCache), "SELECT * FROM `clans` WHERE `clan_name` = '%s'", szName);
	
	new Handle:g_Connect = SQL_Connect(hSqlTuple, iError, szError, charsmax(szError));
	
	if(iError)
	{
		log_to_file("addons/amxmodx/logs/cod_clans.log", "<Query> Error: %s", szError);
		return true;
	}
	
	new Handle:Query = SQL_PrepareQuery(g_Connect, szCache);
	
	SQL_Execute(Query);
	
	if(SQL_NumResults(Query))
		bFound = true;

	SQL_FreeHandle(Query);
	SQL_FreeHandle(g_Connect);
	
	return bFound;
}

public ConfigLoad() 
{
	new szPath[64];
	
	get_localinfo("amxx_configsdir", szPath, charsmax(szPath));
	format(szPath, charsmax(szPath), "%s/%s", szPath, szFile);
    
	if(!file_exists(szPath)) 
	{
		new szError[100];
		
		formatex(szError, charsmax(szError), "Brak pliku konfiguracyjnego: %s!", szPath);
		set_fail_state(szError);
		
		return;
	}
    
	new szLine[256], szValue[256], szKey[64], iSection, iValue;
	new iFile = fopen(szPath, "rt");
    
	while(iFile && !feof(iFile)) 
	{
		fgets(iFile, szLine, charsmax(szLine));
		replace(szLine, charsmax(szLine), "^n", "");
       
		if(!szLine[0] || szLine[0] == '/') continue;
		if(szLine[0] == '[') { iSection++; continue; }
       
		strtok(szLine, szKey, charsmax(szKey), szValue, charsmax(szValue), '=');
		trim(szKey);
		trim(szValue);
		
		iValue = str_to_num(szValue);
		
		switch (iSection) 
		{ 
			case 1: 
			{
				if(equal(szKey, "CREATE_LEVEL"))
					iCreateLevel = iValue;
				else if(equal(szKey, "MAX_MEMBERS"))
					iMaxMembers = iValue;
				else if(equal(szKey, "LEVEL_MAX"))
					iLevelMax = iValue;
				else if(equal(szKey, "SPEED_MAX"))
					iSpeedMax = iValue;
				else if(equal(szKey, "GRAVITY_MAX"))
					iGravityMax = iValue;
				else if(equal(szKey, "DAMAGE_MAX"))
					iDamageMax = iValue;
				else if(equal(szKey, "DROP_MAX"))
					iWeaponDropMax = iValue;
			}
			case 2: 
			{
				if(equal(szKey, "LEVEL_COST"))
					iLevelCost = iValue;
				else if(equal(szKey, "SPEED_COST"))
					iSpeedCost = iValue;
				else if(equal(szKey, "GRAVITY_COST"))
					iGravityCost = iValue;
				else if(equal(szKey, "DAMAGE_COST"))
					iDamageCost = iValue;
				else if(equal(szKey, "DROP_COST"))
					iWeaponDropCost = iValue;
				else if(equal(szKey, "LEVEL_COST_NEXT"))
					iNextLevelCost = iValue;
				else if(equal(szKey, "SPEED_COST_NEXT"))
					iNextSpeedCost = iValue;
				else if(equal(szKey, "GRAVITY_COST_NEXT"))
					iNextGravityCost = iValue;
				else if(equal(szKey, "DAMAGE_COST_NEXT"))
					iNextDamageCost = iValue;
				else if(equal(szKey, "DROP_COST_NEXT"))
					iNextWeaponDropCost = iValue;
			}
			case 3: 
			{
				if(equal(szKey, "MEMBERS_PER"))
					iMembersPerLevel = iValue;
				else if(equal(szKey, "SPEED_PER"))
					iSpeedPerLevel = iValue;
				else if(equal(szKey, "GRAVITY_PER"))
					iGravityPerLevel = iValue;
				else if(equal(szKey, "DAMAGE_PER"))
					iDamagePerLevel = iValue;
				else if(equal(szKey, "DROP_PER"))
					iWeaponDropPerLevel = iValue;
			}
		}
	}
	if(iFile) fclose(iFile);
}

stock mysql_escape_string(const szSource[], szDest[], iLen)
{
	copy(szDest, iLen, szSource);
	replace_all(szDest, iLen, "\\", "\\\\");
	replace_all(szDest, iLen, "\0", "\\0");
	replace_all(szDest, iLen, "\n", "\\n");
	replace_all(szDest, iLen, "\r", "\\r");
	replace_all(szDest, iLen, "\x1a", "\Z");
	replace_all(szDest, iLen, "'", "\'");
	replace_all(szDest, iLen, "`", "\`");
	replace_all(szDest, iLen, "^"", "\^"");
}

stock GetClanID(const szClan[])
{
	new aClan[ClanInfo];
	
	for(new i = 1; i < ArraySize(gClans); i++)
	{
		ArrayGetArray(gClans, i, aClan);
		
		if(equal(aClan[NAME], szClan))
			return i;
	}
	
	return 0;
}

stock cmd_execute(id, const szText[], any:...) 
{
    #pragma unused szText

    if (id == 0 || is_user_connected(id))
	{
    	new szMessage[256];

    	format_args(szMessage, charsmax(szMessage), 1);

        message_begin(id == 0 ? MSG_ALL : MSG_ONE, 51, _, id);
        write_byte(strlen(szMessage) + 2);
        write_byte(10);
        write_string(szMessage);
        message_end();
    }
}

Ham:get_player_resetmaxspeed_func()
{
	#if defined Ham_CS_Player_ResetMaxSpeed
	return IsHamValid(Ham_CS_Player_ResetMaxSpeed)?Ham_CS_Player_ResetMaxSpeed:Ham_Item_PreFrame;
	#else
	return Ham_Item_PreFrame;
	#endif
}