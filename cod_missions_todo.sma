#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#include <nvault>
#include <csx>
#include <fakemeta>

#pragma tabsize 0

#define DMG_HEGRENADE (1<<24)
#define DMG_BULLET (1<<1)

#define TASKID_HUD 687

/*-----------------KONFIGURACJA-----------------*/

new const prefix[] = "^4[Misje]^1"
#define VAULT_EXPIREDAYS 14            // po ilu dniach nieobecnosci na serwerze ma usuwac aktualny postep misji gracza
#define MAX_PLAYERS 32                 // max ilosc graczy (chcesz mniej zuzycia pamieci? ustaw wartosc: ilosc slotow+1

/*--------------KONIEC KONFIGURACJI--------------*/

enum _:typy
{
      BRAK = 0, 
      ZABIJ, 
      PLANT, 
      DEFUSE, 
      HEADSHOT, 
      HOSTY, 
      DMG_LACZNIE, 
      KILL_DGL_HS, 
      KNIFE, 
      KNIFE_HEADSHOT, 
      GRANAT, 
      DMG_GRANAT,
      KILL_AWP_HS,
      CELNOSC,
      KILLSROUND,
      HSRATIO,
      DOUBLE
}

new const QuestInfoMessage[typy][] =
{
      "Brak misji", 
      "Zabij", 
      "Podloz pake", 
      "Rozbroj pake", 
      "Strzel HS'y", 
      "Uratuj hosty", 
      "Zadaj obrazenia", 
      "Zabij deaglem HS", 
      "Zabij z noza", 
      "Zabij z noza HS", 
      "Zabij granatem", 
      "Zadaj dmg granatem",
      "Zabij awp HS",
      "Uzyskaj % celnosci w rundzie",
      "Uzyskaj fragi w rundzie",
      "Uzyskaj % hs'ow w rundzie",
      "Strzel doublekill'a"
}

new const QuestRozdzial[][] =
{
      "Podstawowy", 
      "Zaawansowany", 
      "Ekspert", 
      "Arcymistrz"
}

new iPlayerQuestID[MAX_PLAYERS+1], 
ePlayerQuestType[MAX_PLAYERS+1], 
iPlayerPrzedzial[MAX_PLAYERS+1], 
iPlayerQuestProgress[MAX_PLAYERS+1],
nazwa_gracza[MAX_PLAYERS+1][33];

new iDoubleKillVariable[MAX_PLAYERS+1]; // do double
new bool:bZrobilWszystkie[MAX_PLAYERS+1];


new HudObj, vault;

new Array: gPrzedzial, 
Array: gIleRazy, 
Array: gTyp, 
Array: gNagroda;

public plugin_init() 
{
      register_plugin("[CoD] Misje", "1.6", "Rivit")
      
      vault = nvault_open("Misje_by_Rivit")

      register_clcmd("say /questy", "cmdQuestMenu");
      register_clcmd("say /misje", "cmdQuestMenu");
      register_clcmd("say /misja", "cmdQuestMenu");
      register_clcmd("say /quest", "cmdQuestMenu");
      
      RegisterHam(Ham_TakeDamage, "player", "Obrazenia", 1);

      register_logevent("LogEvent_Quest", 3, "1=triggered");
      
      register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");

      HudObj = CreateHudSyncObj();
}

public plugin_cfg()
{
      gPrzedzial    = ArrayCreate();
      gIleRazy   = ArrayCreate();
      gTyp      = ArrayCreate();
      gNagroda   = ArrayCreate();

      new plik_tresc[64];
      formatex(plik_tresc, charsmax(plik_tresc), "addons/amxmodx/configs/cod_misje.ini");

      if(!file_exists(plik_tresc))
            set_fail_state("[Misje] Nie mozna znalesc pliku cod_misje.ini w addons/amxmodx/configs/");

      new fp = fopen(plik_tresc, "r");

      new dane[4][7];
      while(!feof(fp))
      {
            fgets(fp, plik_tresc, charsmax(plik_tresc));

            if(plik_tresc[0] == ';' || !plik_tresc[0] || plik_tresc[0] == '^n' || plik_tresc[0] == '^r' || plik_tresc[0] == '^t' || plik_tresc[0] == ' ')  continue;

            parse(plik_tresc, dane[0], 7, dane[1], 7, dane[2], 7, dane[3], 7);

            replace_all(plik_tresc, 63, "^"", "");

            ArrayPushCell(gPrzedzial, str_to_num(dane[0]));
            ArrayPushCell(gIleRazy, str_to_num(dane[1]));
            ArrayPushCell(gTyp, str_to_num(dane[2]));
            ArrayPushCell(gNagroda, str_to_num(dane[3]));   
      }

      fclose(fp);
      
      if(vault != INVALID_HANDLE)
            nvault_prune(vault, 0, get_systime() - (86400 * VAULT_EXPIREDAYS));
}

public client_disconnect(id)
{
      if(!bZrobilWszystkie[id])
            SaveAktQuest(id);

      remove_task(id+TASKID_HUD)

      iDoubleKillVariable[id] = 0
      bZrobilWszystkie[id] = false
      ResetQuest(id);
}

public client_putinserver(id)
{
	get_user_name(id, nazwa_gracza[id], 32)
      if(nvault_get(vault, nazwa_gracza[id]) >= sizeof(QuestRozdzial))
      {
            bZrobilWszystkie[id] = true
            set_task(1.0, "HudInfobZrobilWszystkie", id+TASKID_HUD, _, _, "b");
            return;
      }
      
      LoadAktQuest(id);
      
      set_task(1.0, "HudInfo", id+TASKID_HUD, _, _, "b");
}

public cmdQuestMenu(id)
{
      if(bZrobilWszystkie[id])
      {
            client_print_color(id, print_team_red, "%s Ukonczyles wszystkie misje!", prefix)
            return PLUGIN_HANDLED;
      }
      
      new team = get_user_team(id);
      if(!team || team == 3) return PLUGIN_CONTINUE;

      client_cmd(id, "spk QTM_CodMod/select");

      new menu = menu_create("\yMenu misji:", "cmdQuestMenu_Handle")
      new MenuCallback = menu_makecallback("menu_callback");
      
      if(ePlayerQuestType[id])
      {
            menu_additem(menu, "Wybierz questa", _, _, MenuCallback)
            menu_additem(menu, "Przerwij quest")
      }
      else
      {
            menu_additem(menu, "Wybierz questa")
            menu_additem(menu, "Przerwij quest", _, _, MenuCallback)
      }

      (task_exists(id+TASKID_HUD)) ? menu_additem(menu, "Wylacz HUD") : menu_additem(menu, "Wlacz HUD")

      menu_display(id, menu)
      
	return PLUGIN_CONTINUE
}

public cmdQuestMenu_Handle(id, menu, item)
{
      if(item == MENU_EXIT)
      {
            menu_destroy(menu);
            return;
      }

      switch(item)
      {
            case 0: Menu_Questow(id)
            case 1: ResetQuest(id);
            case 2:
            {
                  if(task_exists(id+TASKID_HUD))
                        remove_task(id+TASKID_HUD)
                  else
                        set_task(0.8, "HudInfo", id+TASKID_HUD, _, _, "b");
            }
      }

      menu_destroy(menu)
}

public menu_callback() return ITEM_DISABLED

public Menu_Questow(id)
{
      iPlayerPrzedzial[id] = nvault_get(vault, nazwa_gracza[id])

      new temp[80], bool:jestChociazJedna = false, idQuesta[3], i, wielkoscRozdzialu;

      formatex(temp, charsmax(temp), "\yPoziom questow: [\r%s\y]", QuestRozdzial[iPlayerPrzedzial[id]])
      new menu = menu_create(temp, "Menu_Questow_handle")

	wielkoscRozdzialu = ArraySize(gPrzedzial)
      for(i = 0; i < wielkoscRozdzialu; i++)
      {   
            if(ArrayGetCell(gPrzedzial, i) != iPlayerPrzedzial[id] || LoadQuest(id, i)) continue;

            switch(ArrayGetCell(gTyp, i))
            {
                  case ZABIJ: formatex(temp, charsmax(temp), "Zabij %i razy \y(%i expa)", ArrayGetCell(gIleRazy, i), ArrayGetCell(gNagroda, i))
                  case HEADSHOT: formatex(temp, charsmax(temp), "Strzel %i Headshotow \y(%i expa)",  ArrayGetCell(gIleRazy, i), ArrayGetCell(gNagroda, i))
                  case PLANT: formatex(temp, charsmax(temp), "Podloz %i bomb \y(%i expa)",  ArrayGetCell(gIleRazy, i), ArrayGetCell(gNagroda, i))
                  case HOSTY: formatex(temp, charsmax(temp), "Uratuj %i razy hosty \y(%i expa)",  ArrayGetCell(gIleRazy, i), ArrayGetCell(gNagroda, i))
                  case DEFUSE: formatex(temp, charsmax(temp), "Rozbroj %i bomb \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case DMG_LACZNIE: formatex(temp, charsmax(temp), "Zadaj lacznie %i obrazen \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case KILL_DGL_HS: formatex(temp, charsmax(temp), "Zabij %i osob deaglem HS \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case KNIFE: formatex(temp, charsmax(temp), "Zabij %i graczy nozem \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case KNIFE_HEADSHOT: formatex(temp, charsmax(temp), "Zabij %i graczy headshotem z noza \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case GRANAT: formatex(temp, charsmax(temp), "Zabij %i graczy granatem \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case DMG_GRANAT: formatex(temp, charsmax(temp), "Zadaj %i dmg granatem \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case KILL_AWP_HS: formatex(temp, charsmax(temp), "Zabij %i osob z awp HS \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case CELNOSC: formatex(temp, charsmax(temp), "Uzyskaj %i%% celnosci w rundzie \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case KILLSROUND: formatex(temp, charsmax(temp), "Uzyskaj %i fragow w rundzie \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case HSRATIO: formatex(temp, charsmax(temp), "Uzyskaj %i%% hs/kills w rundzie \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
                  case DOUBLE: formatex(temp, charsmax(temp), "Strzel %i razy doublekill'a \y(%i expa)",  ArrayGetCell(gIleRazy, i),  ArrayGetCell(gNagroda, i))
            }
            
            num_to_str(i, idQuesta, 2)
            menu_additem(menu, temp, idQuesta);
            
            jestChociazJedna = true
      }
      
      if(!jestChociazJedna)
      {
            SaveQuestLvl(id);
            
            if(iPlayerPrzedzial[id] >= sizeof(QuestRozdzial) - 1) //tu odejmuje 1 zeby nie wczytywac jeszcze raz przedialu
            {
			client_print_color(id, print_team_red, "%s Ukonczyles wszystkie misje!", prefix)
			client_print_color(id, print_team_red, "%s Dostales 30 000 expa!", prefix)

                  cod_add_user_xp(id, 30000)
                  remove_task(id+TASKID_HUD)
                  bZrobilWszystkie[id] = true
                  set_task(1.0, "HudInfobZrobilWszystkie", id+TASKID_HUD, _, _, "b");
                  
			formatex(temp, charsmax(temp), "%s-a", nazwa_gracza[id]);
			nvault_remove(vault, temp)

                  for(i = 0; i < wielkoscRozdzialu; i++)
                  {
                        formatex(temp, charsmax(temp), "%s-%i", nazwa_gracza[id], i);
                        nvault_remove(vault, temp)
                  }
                  
                  menu_destroy(menu);
                  
                  return;
            }

		client_print_color(id, print_team_red, "%s Ukonczyles poziom %s i awansowales na %s", prefix, QuestRozdzial[iPlayerPrzedzial[id]], QuestRozdzial[iPlayerPrzedzial[id]+1])
		client_print_color(id, print_team_red, "%s Dostales 10 000 expa!", prefix)

            cod_add_user_xp(id, 10000)
            
            menu_destroy(menu);
            
            return;
      }
      
      menu_setprop(menu, MPROP_PERPAGE, 7);
      menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
      menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");
      menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
   
      menu_display(id, menu)
}

public Menu_Questow_handle(id, menu, item)
{
      if(item == MENU_EXIT)
      {
            menu_destroy(menu);
            return;
      }
      new idQuesta, data[3], tmp[2] //idQuesta - do menu_item_getinfo musze, a potem wykorzystam :D
      menu_item_getinfo(menu, item, idQuesta, data, 2, tmp, 1, idQuesta)

      ResetQuest(id)
      
      idQuesta = str_to_num(data);
      iPlayerQuestID[id] = idQuesta
      ePlayerQuestType[id] = ArrayGetCell(gTyp, idQuesta)

	client_print_color(id, print_team_red, "%s Rozpoczales misje!", prefix)

      menu_destroy(menu)
}

add_progress(id, amount)
{
      if((iPlayerQuestProgress[id] += amount) >= ArrayGetCell(gIleRazy, iPlayerQuestID[id]))
            Nagroda(id);
}

Nagroda(id)
{
      client_cmd(id, "spk QTM_CodMod/missiondone");

      new award = ArrayGetCell(gNagroda, iPlayerQuestID[id]);
      cod_add_user_xp(id, award)
	client_print_color(id, print_team_red, "%s Ukonczyles misje! Nagroda %i expa", prefix, award)

      SaveQuest(id);
      ResetQuest(id);
}

ResetQuest(id)
{
      ePlayerQuestType[id] = BRAK;
      iPlayerQuestID[id]   = -1;
      iPlayerQuestProgress[id]  = 0;
}

public client_death(kid, vid, wid, hitplace, TK)
{
      if(!is_user_connected(kid) || !ePlayerQuestType[kid] || !kid || TK || kid == vid) return;

      switch(ePlayerQuestType[kid])
      {
            case ZABIJ, KILLSROUND: add_progress(kid, 1) 
            case HEADSHOT: 
            { 
                  if(hitplace == HIT_HEAD)
                        add_progress(kid, 1);
            }
            case KNIFE:
            {
                  if(wid == CSW_KNIFE)
                        add_progress(kid, 1)
            }
            case KNIFE_HEADSHOT:
            {
                  if(wid == CSW_KNIFE && hitplace == HIT_HEAD)
                        add_progress(kid, 1)
            }
            case GRANAT:
            {
                  if(wid == CSW_HEGRENADE)
                        add_progress(kid, 1)
            }
            case KILL_DGL_HS:
            {
                  if(wid == CSW_DEAGLE && hitplace == HIT_HEAD)
                        add_progress(kid, 1)
            }
            case KILL_AWP_HS:
            {
                  if(wid == CSW_AWP && hitplace == HIT_HEAD)
                        add_progress(kid, 1)
            }
            case DOUBLE:
            {
                  if(iDoubleKillVariable[kid] && iDoubleKillVariable[kid] == wid)
                  {  
                        add_progress(kid, 1)
         
                        iDoubleKillVariable[kid] = 0
                  }
                  else
                  {
                        iDoubleKillVariable[kid] = wid
                        set_task(0.1, "ClearDouble", kid)
                  }
            }
      }
}

public ClearDouble(id)
   iDoubleKillVariable[id] = 0

public NowaRunda()
{
      new stats[8], bdhits[8]
      for(new i = 1; i <= MAX_PLAYERS; i++)
      {
            if(!is_user_connected(i) || !ePlayerQuestType[i]) continue;
            
            get_user_rstats(i, stats, bdhits)
            
            switch(ePlayerQuestType[i])
            {
                  case CELNOSC:
                  {
                        if(stats[5])
                        {
                              new celnosc = 100 * stats[5] / stats[4];
                              
                              if(celnosc >= ArrayGetCell(gIleRazy, iPlayerQuestID[i]))
                              {
                                    Nagroda(i);
                                    return;
                              }

                              client_print(i, print_chat, "W poprzedniej rundzie miales %i%% celnosci!", celnosc)
                        }
                  }
                  case KILLSROUND:
                        iPlayerQuestProgress[i] = 0

                  case HSRATIO:
                  {
                        if(stats[2])
                        {
                              new hsratio = 100 * stats[2] / stats[0];
                              
                              if(hsratio >= ArrayGetCell(gIleRazy, iPlayerQuestID[i]))
                              {
                                    Nagroda(i);
                                    return;
                              }
                                    
                              client_print(i, print_chat, "W poprzedniej rundzie miales %i%% hs/kills!", hsratio)
                        }
                  }
            }
      }
}

public LogEvent_Quest()
{
	if(get_playersnum() < 4) return;
	
      new user[80], action[64], name[33]
   
      read_logargv(0, user, 79);
      read_logargv(2, action, 63);
      parse_loguser(user, name, 32);
      new id = get_user_index(name);
   
      if(!is_user_connected(id) || !ePlayerQuestType[id]) return

      if(equal(action, "Planted_The_Bomb"))
      { 
            if(ePlayerQuestType[id] == PLANT) 
                  add_progress(id, 1);
      }
      else if(equal(action, "Defused_The_Bomb"))
      { 
            if(ePlayerQuestType[id] == DEFUSE) 
                  add_progress(id, 1); 
      }
      else if(equal(action, "Rescued_A_Hostage"))
      { 
            if(ePlayerQuestType[id] == HOSTY)
                  add_progress(id, 1); 
      }
}

public Obrazenia(vid, idinflictor, kid, Float:damage, damagebits)
{          
      if(!is_user_connected(kid) || get_user_team(vid) == get_user_team(kid) || !ePlayerQuestType[kid] || kid == vid) return HAM_IGNORED;
      
      switch(ePlayerQuestType[kid])
      {
            case DMG_LACZNIE: add_progress(kid, floatround(damage))
            case DMG_GRANAT:
            {
                  if(damagebits & DMG_HEGRENADE)
                        add_progress(kid, floatround(damage));
            }
      }
   
      return HAM_IGNORED;
}

public HudInfo(id)
{
      id -= TASKID_HUD

      if(!is_user_alive(id))
      {
            new target = pev(id, pev_iuser2);

            if(!target) return;

		set_hudmessage(255, 255, 255, -1.0, 0.11, 0, _, 1.0)
            
            if(!ePlayerQuestType[target])
                  ShowSyncHudMsg(id, HudObj, "Brak misji")
            else
                  ShowSyncHudMsg(id, HudObj, "Rozdzial: %s^n%s [%i/%i]", QuestRozdzial[iPlayerPrzedzial[target]], QuestInfoMessage[ePlayerQuestType[target]], iPlayerQuestProgress[target], ArrayGetCell(gIleRazy, iPlayerQuestID[target]));

            return;
      }

      set_hudmessage(255, 0, 0, 0.1, 0.0, 0, _, 1.0)
      
      if(!ePlayerQuestType[id])
            ShowSyncHudMsg(id, HudObj, "|Brak misji^n|Napisz /misje")
      else
            ShowSyncHudMsg(id, HudObj, "|Rozdzial: %s^n|%s [%i/%i]", QuestRozdzial[iPlayerPrzedzial[id]], QuestInfoMessage[ePlayerQuestType[id]], iPlayerQuestProgress[id], ArrayGetCell(gIleRazy, iPlayerQuestID[id]));
}

public HudInfobZrobilWszystkie(id)
{
      id -= TASKID_HUD

      if(!is_user_alive(id))
      {
            new target = pev(id, pev_iuser2);

            if(!target) return;

            set_hudmessage(255, 255, 255, -1.0, 0.11, 0, _, 1.0)
            
            if(!ePlayerQuestType[target])
                  ShowSyncHudMsg(id, HudObj, "Brak misji")
            else
                  ShowSyncHudMsg(id, HudObj, "Rozdzial: %s^n%s [%i/%i]", QuestRozdzial[iPlayerPrzedzial[target]], QuestInfoMessage[ePlayerQuestType[target]], iPlayerQuestProgress[target], ArrayGetCell(gIleRazy, iPlayerQuestID[target]));
      }
}

/* -------------------- NVAULT -------------------- */

SaveQuestLvl(id)
{
      new vaultkey[33], PoziomQuesta[3];
      get_user_name(id, vaultkey, charsmax(vaultkey));
      
      num_to_str(nvault_get(vault, nazwa_gracza[id])+1, PoziomQuesta, 2)
      nvault_pset(vault, vaultkey, PoziomQuesta);
}

SaveAktQuest(id)
{
      new vaultkey[36], vaultdata[32];
      formatex(vaultkey, 35, "%s-a", nazwa_gracza[id])
      formatex(vaultdata, charsmax(vaultdata), "%i %i %i", ePlayerQuestType[id] ? iPlayerQuestID[id] : -1, ePlayerQuestType[id], iPlayerQuestProgress[id]);

      nvault_set(vault, vaultkey, vaultdata);
}

LoadAktQuest(id) 
{
      new vaultkey[36], vaultdata[32];
      formatex(vaultkey, 35, "%s-a", nazwa_gracza[id])

      nvault_get(vault, vaultkey, vaultdata, 31);
      nvault_touch(vault, vaultkey)

      new data[3][10];
      parse(vaultdata, data[0], 9, data[1], 9, data[2], 9)
      
      vaultkey[0] = str_to_num(data[1]) //nie uzywam juz vaultkey wiec wykorzystam sobie do ePlayerQuestType
      if(!vaultkey[0]) return;
      
      iPlayerQuestID[id] = str_to_num(data[0])
      ePlayerQuestType[id] = vaultkey[0]
      iPlayerQuestProgress[id] = str_to_num(data[2])
}

SaveQuest(id)
{
      new vaultkey[40];
      formatex(vaultkey, charsmax(vaultkey), "%s-%i", nazwa_gracza[id], iPlayerQuestID[id]);
      nvault_pset(vault, vaultkey, "1");
}

LoadQuest(id, QuestID)
{
      new vaultkey[40], name[33];
      get_user_name(id, name, charsmax(name));

      formatex(vaultkey, charsmax(vaultkey), "%s-%i", nazwa_gracza[id], QuestID);
      
      return nvault_get(vault, vaultkey);
}

public plugin_precache()
{
      precache_sound("QTM_CodMod/select.wav");
      precache_sound("QTM_CodMod/missiondone.wav");
}

public plugin_end()
{
      ArrayDestroy(gPrzedzial)
      ArrayDestroy(gIleRazy)
      ArrayDestroy(gTyp)
      ArrayDestroy(gNagroda)
      nvault_close(vault)
}