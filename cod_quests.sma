#include <amxmodx>
#include <cod>
#include <cstrike>
#include <nvault>

#define PLUGIN "CoD Quests"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define MAX_PLAYERS 32

enum { NONE = 0, KILL, SUBSTRATES, DISARM, HEADSHOT, RESCUE, DMG, CLASS, ITEM };

enum Player { ID = 0, TYPE, ADDITIONAL, PROGRESS, CHAPTER };

new QuestsInfo[][] = 
{
	"Brak Questa %i",
	"Musisz zabic jeszcze %i osob",
	"Musisz zabic klase %s jeszcze %i razy",
	"Musisz znalezc item %s jeszcze %i razy",
	"Musisz podlozyc bombe jeszcze %i razy",
	"Musisz rozbroic bombe jeszcze %i razy",
	"Musisz zabic jeszcze %i osob headshotem",
	"Musisz uratowac jeszcze %i hostow",
	"Musisz zadac jeszcze %i obrazen"
};

new QuestsChapter[][] = { {1, 100}, {101, 200}, {201, 300}, {301, 400}, {401, 501} };

new QuestsChapterName[][] = { "Nowy Poczatek", "Walka Na Froncie", "Za Linia Wroga", "Wszystko Albo Nic", "Legenda Zyje Wiecznie" };

new const szCommandQuest[][] = { "say /quest", "say_team /quest", "say /misje", "say_team /misje", "say /questy", "say_team /questy", "questy" };

new szClass[MAX_PLAYERS + 1][64], szPlayer[MAX_PLAYERS + 1][64], iPlayer[Player][MAX_PLAYERS + 1];

new Array:gChapter, Array:gAmount, Array:gType, Array:gReward;

new iMaxQuest;

new gVault;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof szCommandQuest; i++) register_clcmd(szCommandQuest[i], "QuestMenu");
	
	register_event("DeathMsg", "DeathMsg", "a");
	register_event("Damage", "Damage", "b", "2!=0");
	
	register_logevent("LogEventQuest", 3, "1=triggered");
	
	gVault = nvault_open("quests");
	
	if(gVault == INVALID_HANDLE) set_fail_state("Nie mozna otworzyc pliku");
	
	gChapter = ArrayCreate();
	gAmount	= ArrayCreate();
	gType = ArrayCreate();
	gReward = ArrayCreate();
}

public plugin_cfg() 
{
	new szFile[64]; 
	
	get_localinfo("amxx_configsdir", szFile, charsmax(szFile));
	format(szFile, charsmax(szFile), "%s/cod_quests.ini", szFile);
	
	if(!file_exists(szFile))
	{
		new szError[128];
		
		formatex(szError, charsmax(szError), "[QUESTS] Nie mozna znalezc pliku cod_quests.ini w lokalizacji %s", szFile);
		set_fail_state(szError);
	}
	
	new iFile = fopen(szFile, "r");
	
	new szTemp[128], szData[4][32];
	
	while(!feof(iFile)) 
	{
		fgets(iFile, szTemp, charsmax(szTemp));
		
		if(szTemp[0] == ';' || szTemp[0] == '^0') continue;

		parse(szTemp, szData[0], charsmax(szData), szData[1], charsmax(szData), szData[2], charsmax(szData), szData[3], charsmax(szData));
		
		ArrayPushCell(gChapter, str_to_num(szData[0]));
		ArrayPushCell(gAmount, str_to_num(szData[1]));
		ArrayPushCell(gType, str_to_num(szData[2]));
		ArrayPushCell(gReward, str_to_num(szData[3]));	
	}
	fclose(iFile);
	
	iMaxQuest = ArraySize(gChapter);
}

public plugin_end()
	nvault_close(gVault);
	
public client_connect(id)
{
	get_user_name(id, szPlayer[id], charsmax(szPlayer));
	
	ResetQuest(id);
}

public QuestMenu(id)
{
	if(!cod_check_account(id)) return PLUGIN_HANDLED;
	
	client_cmd(id, "spk CodMod/select");
	
	new menu = menu_create("\wMenu \rQuestow:", "QuestMenu_Handle");
	new callback = menu_makecallback("QuestMenu_Callback");
	
	menu_additem(menu, "Wybierz \yQuest", _, _, callback);
	menu_additem(menu, "Zakoncz \yQuest", _, _, callback);
	menu_additem(menu, "Sprawdz \yPostep", _, _, callback);
	
	menu_addtext(menu, "^n\rQuesty sa misjami, po ktorych wykonaniu otrzymasz wyznaczona ilosc Expa.", 2);

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public QuestMenu_Handle(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;

	client_cmd(id, "spk CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0: SelectChapter(id);
		case 1: ResetQuest(id);
		case 2: CheckQuest(id);
	}
	
	return PLUGIN_HANDLED;
}

public QuestMenu_Callback(id, menu, item)
{
	switch(item)
	{
		case 0: if(iPlayer[TYPE][id]) return ITEM_DISABLED;
		case 1, 2: if(!iPlayer[TYPE][id]) return ITEM_DISABLED;
	}
	
	return ITEM_ENABLED;
}

public SelectChapter(id)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;

	client_cmd(id, "spk CoDMod/select");
	
	if(iPlayer[TYPE][id]) cod_print_chat(id, "Najpierw wykonaj poprzedni quest.");

	new menu = menu_create("\wWybierz \rRozdzial:", "SelectChapter_Handler");
	new callback = menu_makecallback("SelectChapter_Callback");
	
	new szTemp[128];

	for(new i = 0; i < sizeof(QuestsChapter); i++)
	{
		formatex(szTemp, 127, "Rozdzial \r%s \y(%i Poziom - %i Poziom)", QuestsChapterName[i], QuestsChapter[i][0], QuestsChapter[i][1]);
		menu_additem(menu, szTemp, _, _, callback);
	}
	
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_display(id, menu, 0);

	return PLUGIN_CONTINUE;
}

public SelectChapter_Callback(id, menu, item)
{
	if(cod_get_user_level(id) < QuestsChapter[item][0])	return ITEM_DISABLED;

	return ITEM_ENABLED;
}

public SelectQuest(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;

	client_cmd(id, "spk CoDMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_CONTINUE;
	}
	
	iPlayer[CHAPTER][id] = item;
	
	menu_destroy(menu);
	
	new menu = menu_create("\wWybierz \rQuest:", "SelectQuest_Handler");
	
	new szTemp[128];
	
	for(new i = 0; i < iMaxQuest; i++)
	{	
		if(ArrayGetCell(gChapter, i) == item)
		{		
			new iAmount, iReward;
			
			iAmount = ArrayGetCell(gAmount, i);
			iReward = ArrayGetCell(gReward, i);
			
			switch(ArrayGetCell(gType, i))
			{
				case KILL: formatex(szTemp, charsmax(szTemp), "Zabij %i osob \y(Nagroda: %i Expa)", iAmount, iReward);
				case HEADSHOT: formatex(szTemp, charsmax(szTemp), "Zabij %i osob z HS \y(Nagroda: %i Expa)",  iAmount, iReward);
				case SUBSTRATES: formatex(szTemp, charsmax(szTemp), "Podloz %i bomb \y(Nagroda: %i Expa)",  iAmount, iReward);
				case RESCUE: formatex(szTemp, charsmax(szTemp), "Uratuj %i razy hosty \y(Nagroda: %i Expa)",  iAmount, iReward);
				case DISARM: formatex(szTemp, charsmax(szTemp), "Rozbroj %i bomb \y(Nagroda: %i Expa)",  iAmount, iReward);
				case DMG: formatex(szTemp, charsmax(szTemp), "Zadaj %i obrazen \y(Nagroda: %i Expa)",  iAmount, iReward);
				case CLASS: formatex(szTemp, charsmax(szTemp), "Zabij %i razy wybrana klase \y(Nagroda: %i Expa)", iAmount, iReward);
				case ITEM: formatex(szTemp, charsmax(szTemp), "Znajdz %i razy wybrany item \y(Nagroda: %i Expa)", iAmount, iReward);
				case NONE: continue;
			}
			
			menu_additem(menu, szTemp);
		}
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu, 0);
	
	return PLUGIN_HANDLED;
}

public SelectQuest_Handler(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CoDMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}

	new iAmount = 0;
	
	for(new i = 0; i < iMaxQuest; i++)
	{
		if(ArrayGetCell(gChapter, i) != iPlayer[CHAPTER][id]) continue;
		
		if(iAmount == item)
		{
			item = i + 1;
			
			break;
		}
		
		iAmount++;
	}

	ResetQuest(id);
	
	iPlayer[ID][id] = item;
	iPlayer[TYPE][id] = ArrayGetCell(gType, item);
	
	switch(iPlayer[ID][id])
	{
		case CLASS: SelectClass(id);
		case ITEM: SelectItem(id);
		default: cod_print_chat(id, "Rozpoczales wykonywac quest. Powodzenia!");
	}
	
	menu_destroy(menu);
	
	return PLUGIN_CONTINUE;
}

public SelectClass(id)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;

	client_cmd(id, "spk CoDMod/select");
	
	new menu = menu_create("\wWybierz \rKlase \wdo \yQuesta:", "Select_Handler");
	
	new szTmp[128], szNum[64], szClass[64];
	
	for(new i = 1; i <= cod_get_classes_num(); i++)
	{
		cod_get_class_name(i, szClass, charsmax(szClass));
		
		formatex(szTmp,charsmax(szTmp), szClass);
		num_to_str(i, szNum, charsmax(szNum));
		
		menu_additem(menu, szTmp, szNum);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	
	menu_display(id, menu, 0);
	
	return PLUGIN_CONTINUE;
}

public SelectItem(id)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;

	client_cmd(id, "spk CoDMod/select");
	
	new menu = menu_create("\wWybierz \rItem \wdo \yQuesta:", "Select_Handler");
	
	new szTmp[128], szNum[64], szItem[64];
	
	for(new i = 1; i <= cod_get_items_num(); i++)
	{
		cod_get_item_name(i, szItem, charsmax(szItem));
		
		formatex(szTmp,charsmax(szTmp), szItem);
		num_to_str(i, szNum, charsmax(szNum));
		
		menu_additem(menu, szTmp, szNum);
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	
	menu_display(id, menu, 0);
	
	return PLUGIN_CONTINUE;
}

public Choose_Handler(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
		
	client_cmd(id, "spk CoDMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		
		return PLUGIN_HANDLED;
	}
	
	new szData[16], iAccess, iCallback;
	
	menu_item_getinfo(menu, item, iAccess, szData, charsmax(szData), _, _, iCallback);
	
	iPlayer[ADDITIONAL][id] = str_to_num(szData);
	
	cod_print_chat(id, "Rozpoczales wykonywac quest. Powodzenia!");
	
	menu_destroy(menu);
	
	return PLUGIN_CONTINUE;
}

public DeathMsg()
{
	new iKiller = read_data(1), iVictim = read_data(2), iHS = read_data(3);
	
	if(!is_user_alive(iKiller) || get_user_team(iKiller) == get_user_team(iVictim)) return PLUGIN_CONTINUE;
		
	switch(iPlayer[TYPE][iKiller])
	{
		case KILL: AddProgress(iKiller);
		case HEADSHOT: if(iHS) AddProgress(iKiller);
		case CLASS: if(iPlayer[ADDITIONAL][iKiller] == cod_get_user_class(iVictim)) AddProgress(iKiller);
	}
	
	return PLUGIN_CONTINUE;
}

public cod_item_get(id, item)
	if(iPlayer[TYPE][id] == ITEM && item == iPlayer[ADDITIONAL][id]) AddProgress(id);

public LogEventQuest()
{
	new szUser[80], szAction[64], szName[32], iType, id;
	
	read_logargv(0, szUser, charsmax(szUser));
	read_logargv(2, szAction, charsmax(szAction));
	parse_loguser(szUser, szName, charsmax(szName));
	
	id = get_user_index(szName);
	
	iType = iPlayer[TYPE][id];
	
	if(!is_user_connected(id) || iType == NONE) return PLUGIN_CONTINUE;
	
	if(equal(szAction, "Planted_The_Bomb") && iType == SUBSTRATES) AddProgress(id);
	
	if(equal(szAction, "Defused_The_Bomb") && iType == DISARM) AddProgress(id);
	
	if(equal(szAction, "Rescued_A_Hostage") && iType == RESCUE) AddProgress(id);

	return PLUGIN_CONTINUE;
}

public Damage(id)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;

	new player = get_user_attacker(id);

	if(!is_user_connected(player) || iPlayer[TYPE][player] != DMG) return PLUGIN_CONTINUE;
		
	AddProgress(player, read_data(2));

	return PLUGIN_CONTINUE;
}

AddProgress(id, amount = 1)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
	
	if(CheckProgress(id)) iPlayer[PROGRESS][id] += amount;
	else GiveReward(id);

	SaveQuest(id, iPlayer[TYPE][id]);
	
	return PLUGIN_CONTINUE;
}

GetProgress(id)
	return iPlayer[PROGRESS][id] ? iPlayer[PROGRESS][id] : 0;

GetProgressNeed(id)
	return iPlayer[TYPE][id] ? ArrayGetCell(gAmount, iPlayer[ID][id]) : 0;

CheckProgress(id)
	return GetProgress(id) >= GetProgressNeed(id) - 1 ? 0 : 1;

public GiveReward(id)
{
	if(!is_user_connected(id)) return PLUGIN_CONTINUE;
	
	new iReward = ArrayGetCell(gReward, iPlayer[ID][id]);
	
	cod_set_user_exp(id, cod_get_user_exp(id) + iReward);
	
	SaveQuest(id, iPlayer[ID][id]);
	ResetQuest(id);
	
	cod_print_chat(id, "Gratulacje! Ukonczyles Quest - otrzymujesz^x03 %i Expa^x01.", iReward);
	
	return PLUGIN_CONTINUE;
}

public ResetQuest(id)
{
	iPlayer[TYPE][id] = NONE;
	iPlayer[ID][id] = -1;
	iPlayer[PROGRESS][id] = 0;
}

public CheckQuest(id)
{
	if(!iPlayer[TYPE][id]) cod_print_chat(id, "Nie wykonujesz zadnej misji");
	else
	{
		new szInfo[128];
		
		formatex(szInfo, charsmax(szInfo), QuestsInfo[iPlayer[TYPE][id]], (GetProgressNeed(id)- GetProgress(id)));
		cod_print_chat(id, "Zakres:^x03 %s^x01. Postep:^x03 %i/%i^x01. Info:^x03 %s", QuestsChapter[iPlayer[CHAPTER][id]], GetProgress(id), GetProgressNeed(id), szInfo);
	}
	
	return PLUGIN_CONTINUE;
}

public cod_class_changed(id)
{
	if(is_user_bot(id) || is_user_hltv(id)) return PLUGIN_CONTINUE;
	
	SaveQuest(id, iPlayer[TYPE][id]);
	cod_get_class_name(cod_get_user_class(id), szClass[id], charsmax(szClass));
	
	ResetQuest(id);
	LoadQuest(id);
	
	return PLUGIN_CONTINUE;
}

public SaveQuest(id, quest) 
{
	if(is_user_bot(id) || is_user_hltv(id) || !quest) return PLUGIN_CONTINUE;
	
	new szVaultKey[64], szVaultData[64];
	
	formatex(szVaultKey, charsmax(szVaultKey), "%s-%s", szPlayer[id], szClass[id]);
	formatex(szVaultData, charsmax(szVaultData), "%i %i %i %i %i", iPlayer[ID][id], iPlayer[TYPE][id], iPlayer[ADDITIONAL][id], iPlayer[PROGRESS][id], iPlayer[CHAPTER][id]);
	nvault_set(gVault, szVaultKey, szVaultData);
	
	return PLUGIN_CONTINUE;
}

public LoadQuest(id) 
{
	if(is_user_bot(id) || is_user_hltv(id)) return PLUGIN_CONTINUE;
	
	new szVaultKey[64], szVaultData[64], szData[5][64], iData[5];
	
	formatex(szVaultKey, charsmax(szVaultKey), "%s-%s", szPlayer[id], szClass[id]);
	nvault_get(gVault, szVaultKey, szVaultData, charsmax(szVaultData));
	
	parse(szVaultData, szData[0], charsmax(szData), szData[1], charsmax(szData), szData[2], charsmax(szData), szData[3], charsmax(szData), szData[4], charsmax(szData));
	
	for(new i = 0; i < sizeof iData; i++) iData[i] = str_to_num(iData[i]);

	if(!iData[0]) return PLUGIN_HANDLED;

	iPlayer[ID][id] = iData[0];
	iPlayer[TYPE][id] = iData[1];
	iPlayer[ADDITIONAL][id] = iData[2];
	iPlayer[PROGRESS][id] = iData[3];
	iPlayer[CHAPTER][id] = iData[4];
	
	return PLUGIN_CONTINUE;
}