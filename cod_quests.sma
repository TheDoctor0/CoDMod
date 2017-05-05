#include <amxmodx>
#include <cstrike>
#include <nvault>
#include <cod>

#define PLUGIN "CoD Quests"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

enum _:questType { TYPE_NONE, TYPE_KILL, TYPE_HEADSHOT, TYPE_PLANT, TYPE_DEFUSE, TYPE_RESCUE, TYPE_DAMAGE, TYPE_CLASS, TYPE_ITEM };

enum _:playerInfo { PLAYER_ID, PLAYER_TYPE, PLAYER_ADDITIONAL, PLAYER_PROGRESS, PLAYER_CHAPTER };

enum _:questInfo { QUEST_CHAPTER, QUEST_AMOUNT, QUEST_TYPE, QUEST_REWARD };

new questDescription[][] = 
{
	"Brak misji %i",
	"Musisz zabic jeszcze %i osob",
	"Musisz zabic jeszcze %i osob headshotem",
	"Musisz podlozyc bombe jeszcze %i razy",
	"Musisz rozbroic bombe jeszcze %i razy",
	"Musisz uratowac jeszcze %i hostow",
	"Musisz zadac jeszcze %i obrazen",
	"Musisz zabic klase %s jeszcze %i razy",
	"Musisz znalezc item %s jeszcze %i razy"
};

new questChapter[][] = { {1, 100}, {101, 200}, {201, 300}, {301, 400}, {401, 501} };

new questChapterName[][] = { "Nowy Poczatek", "Walka Na Froncie", "Za Linia Wroga", "Wszystko Albo Nic", "Legenda Zyje Wiecznie" };

new const commandQuest[][] = { "say /quest", "say_team /quest", "say /misja", "say_team /misja", "say /misje", "say_team /misje", "say /questy", "say_team /questy", "misje" };
new const commandProgress[][] = { "say /progress", "say_team /progress", "say /progres", "say_team /progres", "say /postep", "say_team /postep", "postep" };
new const commandEnd[][] = { "say /koniec", "say_team /koniec", "say /zakoncz", "say_team /zakoncz", "zakoncz", "say_team /przerwij", "say /przerwij", "przerwij" };

new playerClass[MAX_PLAYERS + 1][64], playerName[MAX_PLAYERS + 1][64], playerData[MAX_PLAYERS + 1][playerInfo], Array:codQuests, quests;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof commandQuest; i++) register_clcmd(commandQuest[i], "quest_menu");
	for(new i; i < sizeof commandProgress; i++) register_clcmd(commandProgress[i], "check_quest");
	for(new i; i < sizeof commandEnd; i++) register_clcmd(commandEnd[i], "reset_quest");
	
	register_logevent("log_event_quest", 3, "1=triggered");
	
	quests = nvault_open("cod_quests");
	
	if(quests == INVALID_HANDLE) set_fail_state("Nie mozna otworzyc pliku cod_quests.vault");
	
	codQuests = ArrayCreate(questInfo);
}

public plugin_natives()
{
	register_native("cod_get_user_quest", "get_quest", 1);
	register_native("cod_get_user_quest_progress", "get_progress", 1);
	register_native("cod_get_user_quest_need", "get_progress_need", 1);
}

public plugin_cfg() 
{
	new filePath[64]; 
	
	get_localinfo("amxx_configsdir", filePath, charsmax(filePath));
	format(filePath, charsmax(filePath), "%s/cod_quests.ini", filePath);
	
	if(!file_exists(filePath))
	{
		new error[128];

		formatex(error, charsmax(error), "[CoD] Nie mozna znalezc pliku cod_quests.ini w lokalizacji %s", filePath);

		set_fail_state(error);
	}
	
	new lineData[128], questData[4][16], codQuest[questInfo], file = fopen(filePath, "r");
	
	while(!feof(file)) 
	{
		fgets(file, lineData, charsmax(lineData));
		
		if(lineData[0] == ';' || lineData[0] == '^0') continue;

		parse(lineData, questData[0], charsmax(questData[]), questData[1], charsmax(questData[]), questData[2], charsmax(questData[]), questData[3], charsmax(questData[]));

		codQuest[QUEST_CHAPTER] = str_to_num(questData[0]);
		codQuest[QUEST_AMOUNT] = str_to_num(questData[1]);
		codQuest[QUEST_TYPE] = str_to_num(questData[2]);
		codQuest[QUEST_REWARD] = str_to_num(questData[3]);

		ArrayPushArray(codQuests, codQuest);
	}

	fclose(file);
}

public plugin_end()
	nvault_close(quests);
	
public client_connect(id)
{
	get_user_name(id, playerName[id], charsmax(playerName));
	
	reset_quest(id, 1);
}

public quest_menu(id)
{
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new menu = menu_create("\yMenu \rMisji\w:", "quest_menu_handle"), callback = menu_makecallback("quest_menu_callback");
	
	menu_additem(menu, "Wybierz \yMisje", _, _, callback);
	menu_additem(menu, "Przerwij \yMisje", _, _, callback);
	menu_additem(menu, "Postep \yMisji", _, _, callback);
	
	menu_addtext(menu, "^n\wPo wykonaniu \ymisji\w zostaniesz wynagrodzony \rdoswiadczeniem\w.", 0);
	menu_addtext(menu, "\wMozesz \ywielokrotnie\w wykonywac ta sama misje.", 0);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public quest_menu_handle(id, menu, item)
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
		case 0: select_chapter(id);
		case 1: reset_quest(id, 0);
		case 2: check_quest(id);
	}
	
	return PLUGIN_HANDLED;
}

public quest_menu_callback(id, menu, item)
{
	switch(item)
	{
		case 0: if(playerData[id][PLAYER_TYPE]) return ITEM_DISABLED;
		case 1, 2: if(!playerData[id][PLAYER_TYPE]) return ITEM_DISABLED;
	}
	
	return ITEM_ENABLED;
}

public select_chapter(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(playerData[id][PLAYER_TYPE])
	{
		cod_print_chat(id, "Najpierw wykonaj lub zrezygnuj z obecnej misji.");

		return PLUGIN_HANDLED;
	} 

	new menuData[128], menu = menu_create("\yWybierz \rRozdzial\w:", "select_quest"), callback = menu_makecallback("select_chapter_callback");

	for(new i = 0; i < sizeof(questChapter); i++)
	{
		formatex(menuData, charsmax(menuData), "Rozdzial \y%s \w(\r%i \wPoziom - \r%i \wPoziom)", questChapterName[i], questChapter[i][0], questChapter[i][1]);

		menu_additem(menu, menuData, _, _, callback);
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public select_chapter_callback(id, menu, item)
{
	if(cod_get_user_level(id) < questChapter[item][0]) return ITEM_DISABLED;

	return ITEM_ENABLED;
}

public select_quest(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
    
	if(item == MENU_EXIT)
    {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
    }

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	playerData[id][PLAYER_CHAPTER] = item;
	
	menu_destroy(menu);
	
	new menuData[128], questId[6], codQuest[questInfo], menu = menu_create("\yWybierz \rMisje\w:", "select_quest_handle");
	
	for(new i = 0; i < ArraySize(codQuests); i++)
	{	
		ArrayGetArray(codQuests, i, codQuest);

		if(playerData[id][PLAYER_CHAPTER] == codQuest[QUEST_CHAPTER])
		{		
			switch(codQuest[QUEST_TYPE])
			{
				case TYPE_KILL: formatex(menuData, charsmax(menuData), "Zabij %i osob \y(Nagroda: %i Expa)", codQuest[QUEST_AMOUNT], codQuest[QUEST_REWARD]);
				case TYPE_HEADSHOT: formatex(menuData, charsmax(menuData), "Zabij %i osob z HS \y(Nagroda: %i Expa)",  codQuest[QUEST_AMOUNT], codQuest[QUEST_REWARD]);
				case TYPE_PLANT: formatex(menuData, charsmax(menuData), "Podloz %i bomb \y(Nagroda: %i Expa)",  codQuest[QUEST_AMOUNT], codQuest[QUEST_REWARD]);
				case TYPE_RESCUE: formatex(menuData, charsmax(menuData), "Uratuj %i razy hosty \y(Nagroda: %i Expa)",  codQuest[QUEST_AMOUNT], codQuest[QUEST_REWARD]);
				case TYPE_DEFUSE: formatex(menuData, charsmax(menuData), "Rozbroj %i bomb \y(Nagroda: %i Expa)",  codQuest[QUEST_AMOUNT], codQuest[QUEST_REWARD]);
				case TYPE_DAMAGE: formatex(menuData, charsmax(menuData), "Zadaj %i obrazen \y(Nagroda: %i Expa)",  codQuest[QUEST_AMOUNT], codQuest[QUEST_REWARD]);
				case TYPE_CLASS: formatex(menuData, charsmax(menuData), "Zabij %i razy wybrana klase \y(Nagroda: %i Expa)", codQuest[QUEST_AMOUNT], codQuest[QUEST_REWARD]);
				case TYPE_ITEM: formatex(menuData, charsmax(menuData), "Znajdz %i razy wybrany item \y(Nagroda: %i Expa)", codQuest[QUEST_AMOUNT], codQuest[QUEST_REWARD]);
				case TYPE_NONE: continue;
			}

			num_to_str(i, questId, charsmax(questId));
			
			menu_additem(menu, menuData, questId);
		}
	}

	menu_addblank(menu);
	menu_additem(menu, "\wWyjscie");
	
	menu_setprop(menu, MPROP_PERPAGE, 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public select_quest_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
    
	if(item == TYPE_ITEM + 2)
    {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new questId[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, questId, charsmax(questId), _, _, itemCallback);

	reset_quest(id, 1);

	playerData[id][PLAYER_ID] = str_to_num(questId);
	playerData[id][PLAYER_TYPE] = get_quest_info(playerData[id][PLAYER_ID], QUEST_TYPE);
	
	switch(playerData[id][PLAYER_TYPE])
	{
		case TYPE_CLASS: select_class(id);
		case TYPE_ITEM: select_item(id);
		default:
		{
			cod_print_chat(id, "Rozpoczales wykonywac^x03 misje^x01. Powodzenia!");

			save_quest(id);
		}
	}
	
	menu_destroy(menu);
	
	return PLUGIN_HANDLED;
}

public select_class(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	new menuData[128], className[64], classId[6], menu = menu_create("\yWybierz \rKlase \ydo \yMisji\w:", "select_handle");
	
	for(new i = 1; i < cod_get_classes_num(); i++)
	{
		cod_get_class_name(i, className, charsmax(className));
		
		formatex(menuData,charsmax(menuData), className);

		num_to_str(i, classId, charsmax(classId));
		
		menu_additem(menu, menuData, classId);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public select_item(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	new menuData[128], itemName[64], itemId[6], menu = menu_create("\yWybierz \rItem \ydo \yMisji\w:", "select_handle");
	
	for(new i = 1; i < cod_get_items_num(); i++)
	{
		cod_get_item_name(i, itemName, charsmax(itemName));
		
		formatex(menuData,charsmax(menuData), itemName);

		num_to_str(i, itemId, charsmax(itemId));
		
		menu_additem(menu, menuData, itemId);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
	
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public select_handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
    
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new questData[6], itemAccess, itemCallback;
	
	menu_item_getinfo(menu, item, itemAccess, questData, charsmax(questData), _, _, itemCallback);
	
	playerData[id][PLAYER_ADDITIONAL] = str_to_num(questData);
	
	cod_print_chat(id, "Rozpoczales wykonywac^x03 misje^x01. Powodzenia!");

	save_quest(id);

	menu_destroy(menu);
	
	return PLUGIN_HANDLED;
}

public cod_killed(killer, victim, weaponId, hitPlace)
{
	switch(playerData[killer][PLAYER_TYPE])
	{
		case TYPE_KILL: add_progress(killer);
		case TYPE_HEADSHOT: if(hitPlace == HIT_HEAD) add_progress(killer);
		case TYPE_CLASS: if(playerData[killer][PLAYER_ADDITIONAL] == cod_get_user_class(victim)) add_progress(killer);
	}
}

public cod_item_changed(id, item)
	if(playerData[id][PLAYER_TYPE] == TYPE_ITEM && item == playerData[id][PLAYER_ADDITIONAL]) add_progress(id);

public cod_damage_post(attacker, victim, weapon, Float:damage, damageBits)
	if(playerData[attacker][PLAYER_TYPE] == TYPE_DAMAGE) add_progress(attacker, floatround(damage));

public log_event_quest()
{
	new userLog[80], userAction[64], userName[32];
	
	read_logargv(0, userLog, charsmax(userLog));
	read_logargv(2, userAction, charsmax(userAction));
	parse_loguser(userLog, userName, charsmax(userName));
	
	new id = get_user_index(userName);
	
	if(!is_user_connected(id) || playerData[id][PLAYER_TYPE] == TYPE_NONE) return PLUGIN_HANDLED;
	
	if(equal(userAction, "Planted_The_Bomb") && playerData[id][PLAYER_TYPE] == TYPE_PLANT) add_progress(id);
	
	if(equal(userAction, "Defused_The_Bomb") && playerData[id][PLAYER_TYPE] == TYPE_DEFUSE) add_progress(id);
	
	if(equal(userAction, "Rescued_A_Hostage") && playerData[id][PLAYER_TYPE] == TYPE_RESCUE) add_progress(id);

	return PLUGIN_HANDLED;
}

public give_reward(id)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	new reward = cod_get_user_bonus_exp(id, get_quest_info(playerData[id][PLAYER_ID], QUEST_REWARD));
	
	cod_set_user_exp(id, reward);
	
	save_quest(id);

	reset_quest(id, 1);
	
	cod_print_chat(id, "Gratulacje! Ukonczyles swoja misje - otrzymujesz w nagrode^x03 %i^x01 doswiadczenia.", reward);
	
	return PLUGIN_HANDLED;
}

public check_quest(id)
{
	if(!playerData[id][PLAYER_TYPE]) cod_print_chat(id, "Nie wykonujesz zadnej misji.");
	else
	{
		new message[128], additional[64];

		if(playerData[id][PLAYER_TYPE] == TYPE_CLASS) cod_get_class_name(playerData[id][PLAYER_ADDITIONAL], additional, charsmax(additional));
		else if(playerData[id][PLAYER_TYPE] == TYPE_ITEM) cod_get_item_name(playerData[id][PLAYER_ADDITIONAL], additional, charsmax(additional));

		if(additional[0]) formatex(message, charsmax(message), questDescription[playerData[id][PLAYER_TYPE]], additional, (get_progress_need(id) - get_progress(id)));
		else formatex(message, charsmax(message), questDescription[playerData[id][PLAYER_TYPE]], (get_progress_need(id) - get_progress(id)));

		cod_print_chat(id, "Rozdzial:^x03 %s^x01. Postep:^x03 %i/%i^x01.", questChapterName[playerData[id][PLAYER_CHAPTER]], get_progress(id), get_progress_need(id));
		cod_print_chat(id, "Misja:^x03 %s^x01.", message);
	}
	
	return PLUGIN_HANDLED;
}

public cod_class_changed(id, class)
{
	if(is_user_bot(id) || is_user_hltv(id)) return PLUGIN_HANDLED;
	
	save_quest(id);

	cod_get_class_name(cod_get_user_class(id), playerClass[id], charsmax(playerClass[]));
	
	reset_quest(id, 1);

	load_quest(id);
	
	return PLUGIN_HANDLED;
}

public save_quest(id) 
{
	if(is_user_bot(id) || is_user_hltv(id) || !playerData[id][PLAYER_TYPE]) return PLUGIN_HANDLED;
	
	new vaultKey[64], vaultData[64];
	
	formatex(vaultKey, charsmax(vaultKey), "%s-%s", playerName[id], playerClass[id]);
	formatex(vaultData, charsmax(vaultData), "%i %i %i %i %i", playerData[id][PLAYER_ID], playerData[id][PLAYER_TYPE], playerData[id][PLAYER_ADDITIONAL], playerData[id][PLAYER_PROGRESS], playerData[id][PLAYER_CHAPTER]);

	nvault_set(quests, vaultKey, vaultData);
	
	return PLUGIN_HANDLED;
}

public load_quest(id) 
{
	if(is_user_bot(id) || is_user_hltv(id)) return PLUGIN_HANDLED;
	
	new vaultKey[64], vaultData[64], questData[5][16], questParam[5];
	
	formatex(vaultKey, charsmax(vaultKey), "%s-%s", playerName[id], playerClass[id]);

	if(nvault_get(quests, vaultKey, vaultData, charsmax(vaultData)))
	{
		parse(vaultData, questData[0], charsmax(questData[]), questData[1], charsmax(questData[]), questData[2], charsmax(questData[]), questData[3], charsmax(questData[]), questData[4], charsmax(questData[]));
	
		for(new i = 0; i < sizeof questParam; i++) questParam[i] = str_to_num(questData[i]);

		if(!questParam[1]) return PLUGIN_HANDLED;

		playerData[id][PLAYER_ID] = questParam[0];
		playerData[id][PLAYER_TYPE] = questParam[1];
		playerData[id][PLAYER_ADDITIONAL] = questParam[2];
		playerData[id][PLAYER_PROGRESS] = questParam[3];
		playerData[id][PLAYER_CHAPTER] = questParam[4];
	}
	
	return PLUGIN_HANDLED;
}

public reset_quest(id, silent)
{
	playerData[id][PLAYER_TYPE] = TYPE_NONE;
	playerData[id][PLAYER_ID] = -1;
	playerData[id][PLAYER_PROGRESS] = 0;

	if(!silent) cod_print_chat(id, "Zrezygnowales z wykonywania wybranej wczesniej^x03 misji^x01.");

	return PLUGIN_HANDLED;
}

stock get_quest_info(quest, info)
{
	new codQuest[questInfo];
	
	ArrayGetArray(codQuests, quest, codQuest);
	
	return codQuest[info];
}

stock add_progress(id, amount = 1)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(check_progress(id)) playerData[id][PLAYER_PROGRESS] += amount;
	else give_reward(id);

	save_quest(id);
	
	return PLUGIN_HANDLED;
}

public get_quest(id)
	return playerData[id][PLAYER_ID];

public get_progress(id)
	return playerData[id][PLAYER_PROGRESS] ? playerData[id][PLAYER_PROGRESS] : 0;

public get_progress_need(id)
	return playerData[id][PLAYER_TYPE] ? get_quest_info(playerData[id][PLAYER_ID], QUEST_AMOUNT) : 0;

public check_progress(id)
	return get_progress(id) >= get_progress_need(id) - 1 ? 0 : 1;
