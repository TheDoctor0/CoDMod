#if defined _cod_included
  #endinput
#endif
#define _cod_included

#define get_bit(%2,%1) (%1 & (1<<(%2&31)))
#define set_bit(%2,%1) (%1 |= (1<<(%2&31)))
#define rem_bit(%2,%1) (%1 &= ~(1 <<(%2&31)))

#define MAX_TRANSLATION_LENGTH 2048
#define MAX_PLAYERS 32

#define COD_CONTINUE 0
#define COD_STOP 4

#define DMG_CODSKILL (1<<31)
#define DMG_HEGRENADE (1<<24)
#define DMG_BULLET (1<<1)

enum 
{
	DontChange = 0,
	Grey = -1,
	Red = -2,
	Blue = -3
};

native cod_get_user_exp(id);
/*------------------------------
Zwraca doswiadczenie gracza.
------------------------------*/

native cod_set_user_exp(id, wartosc);
/*------------------------------
Ustawia doswiadczenie gracza.
------------------------------*/

native cod_get_user_level(id);
/*------------------------------
Zwraca poziom gracza.
------------------------------*/

native cod_get_user_highest_level(id);
/*------------------------------
Zwraca najwyzszy poziom gracza.
------------------------------*/

native cod_get_user_class(id);
/*------------------------------
Zwraca klase gracza.
------------------------------*/

native cod_set_user_class(id, class, force = 0);
/*------------------------------
Ustawia klase gracza, jezeli force = 1 zmienia ja natychmiastowo.
------------------------------*/

native cod_get_classid(szClass[]);
/*------------------------------
Zwraca klase o podanej nazwie.
------------------------------*/

native cod_get_class_name(class, dataReturn[], dataLenght);
/*------------------------------
Zwraca nazwe klasy.
------------------------------*/

native cod_get_class_desc(class, dataReturn[], dataLenght);
/*------------------------------
Zwraca opis klasy.
------------------------------*/

native cod_get_class_health(class);
/*------------------------------
Zwraca bazowe zycie klasy.
------------------------------*/

native cod_get_classes_num();
/*------------------------------
Zwraca ilosc klas.
------------------------------*/

native cod_get_user_item(id, &value = 0);
/*------------------------------
Zwraca item gracza oraz przypisuje zmiennej value wartosc itemu.
------------------------------*/

native cod_set_user_item(id, item = -1, value = -1);
/*------------------------------
Ustawia item gracza. 
Jezeli item = -1 item bedzie losowy.
Jezeli value = -1 wartosc itemu bedzie losowa.
------------------------------*/

native cod_upgrade_user_item(id);
/*------------------------------
Ulepsza item gracza
------------------------------*/

native cod_get_itemid(szItem[]);
/*------------------------------
Zwraca item o podanej nazwie.
------------------------------*/

native cod_get_item_name(item, dataReturn[], dataLenght);
/*------------------------------
Zwraca nazwe itemu.
------------------------------*/

native cod_get_item_desc(item, dataReturn[], dataLenght);
/*------------------------------
Zwraca opis itemu.
------------------------------*/

native cod_get_items_num();
/*------------------------------
Zwraca nazwe itemu.
------------------------------*/

native cod_get_user_rockets(id);
/*------------------------------
Zwraca ilosc rakiet gracza
------------------------------*/

native cod_set_user_rockets(id, value);
/*------------------------------
Ustawia ilosc rakiet gracza
------------------------------*/

native cod_get_user_mines(id);
/*------------------------------
Zwraca ilosc min gracza
------------------------------*/

native cod_set_user_mines(id, value);
/*------------------------------
Ustawia ilosc min gracza
------------------------------*/

native cod_get_user_vip(id);
/*------------------------------
Sprawdza, czy gracz ma vipa
------------------------------*/

native cod_get_user_health(id, class_health = 1, gained_health = 1, bonus_health = 1);
/*------------------------------
Zwraca punkty statystyki zdrowie
------------------------------*/

native cod_get_user_max_health(id);
/*------------------------------
Zwraca maksymalne punkty zycia gracza
------------------------------*/

native cod_set_user_bonus_health(id, value);
/*------------------------------
Ustawia dodatkowe punkty statystyki zdrowie
------------------------------*/

native cod_get_user_intelligence(id, gained_intelligence = 1, bonus_intelligence = 1);
/*------------------------------
Zwraca punkty statystyki inteligencja
------------------------------*/

native cod_set_user_bonus_intelligence(id, value);
/*------------------------------
Ustawia dodatkowe punkty statystyki inteligencja
------------------------------*/

native cod_get_user_stamina(id, gained_stamina = 1, bonus_stamina = 1);
/*------------------------------
Zwraca punkty statystyki wytrzymalosc
------------------------------*/


native cod_set_user_bonus_stamina(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki wytrzymalosc
------------------------------*/

native cod_get_user_strength(id, gained_strength = 1, bonus_strength = 1);
/*------------------------------
Zwraca punkty statystyki sila
------------------------------*/

native cod_set_user_bonus_strength(id, value);
/*------------------------------
Ustawia dodatkowe punkty statystyki sila
------------------------------*/

native cod_get_user_strength(id, gained_condition = 1, bonus_condition = 1);
/*------------------------------
Zwraca punkty statystyki kondycja
------------------------------*/

native cod_set_user_bonus_strength(id, value);
/*------------------------------
Ustawia dodatkowe punkty statystyki kondycja
------------------------------*/


native cod_inflict_damage(attacker, victim, Float:damage, Float:factor = 0.5, flags = 0);
/*------------------------------
Zadaje obrazenia z uwzglednieniem inteligencji
------------------------------*/


native cod_give_weapon(id, weapon);
/*------------------------------
Daje okreslona bron oraz pozwala na jej posiadanie
------------------------------*/


native cod_take_weapon(id, weapon);
/*------------------------------
Zabiera okreslona bron oraz zabrania jej posiadania
------------------------------*/

native cod_set_user_resistance(id, wartosc);
/*------------------------------
Ustawia graczowi odpornosc na miny, rakiety, dynamit
------------------------------*/

native cod_get_user_resistance(id);
/*------------------------------
Sprawdza odpornosc gracza na miny, rakiety, dynamit
------------------------------*/


native cod_register_item(const nazwa[], const opis[], min_wartosc=0, max_wartosc=0);
/*------------------------------
Rejestruje nowy item oraz zwraca jego numer
------------------------------*/


native cod_register_class(const nazwa[], const opis[], bronie, punkty_zdrowia, punkty_kondycji, punkty_inteligencji, punkty_wytrzymalosci);
/*------------------------------
Rejestruje nowa klase oraz zwraca jej numer
------------------------------*/

native cod_register_advance(z_klasy, od_levela, const nazwa[], const opis[], bronie, punkty_zdrowia, punkty_kondycji, punkty_inteligencji, punkty_wytrzymalosci, punkty_niewidzialnosci, bonus_niewidzialnosci);
/*------------------------------
Rejestruje nowa klase z awansem oraz zwraca jej numer
------------------------------*/	


native cod_get_level_xp(poziom);
/*------------------------------
Zwraca ilosc potrzebnego doswiadczenia do przejscia danego poziomu
------------------------------*/


native cod_set_item_durability(id, wytrzymalosc);
/*------------------------------
Ustawia wytrzymalosc itemu gracza
------------------------------*/


native cod_get_item_durability(id);
/*------------------------------
Pobiera wytrzymalosc itemu gracza
------------------------------*/


native cod_max_item_durability()
/*------------------------------
Zwraca maksymalna wytrzymalosc itemu
------------------------------*/

native cod_display_fade(id, duration, holdtime, fadetype, red, green, blue, alpha);
/*------------------------------
Wyświetla fade o podanych parametrach
------------------------------*/

native cod_check_register_system(id)
/*------------------------------
Sprawdza, czy gracz wpisal juz haslo i ewentualnie wymusza jego wpisanie
------------------------------*/

native cod_get_user_honor(id);
/*------------------------------
Zwraca honor gracza
------------------------------*/

native cod_set_user_honor(id, wartosc);
/*------------------------------
Ustawia honor gracza.
------------------------------*/

forward cod_item_get(id, item);
/*------------------------------
Forward wysylany do wszystkich pluginow w momencie znalezienia itemu
------------------------------*/

forward cod_item_changed(id, item);
/*------------------------------
Forward wysylany do wszystkich pluginow w momencie zmiany itemu
------------------------------*/


forward cod_class_changed(id, klasa);
/*------------------------------
Forward wysylany do wszystkich pluginow w momencie zmiany klasy
------------------------------*/


forward cod_item_enabled(id, wartosc, item);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowany jest item w momencie aktywacji
------------------------------*/


forward cod_item_disabled(id, item);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowany jest item w momencie dezaktywacji
------------------------------*/


forward cod_item_used(id);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowany jest item w momencie uzycia itemu
------------------------------*/


forward cod_class_enabled(id, klasa);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowana jest kasa w momencie aktywacji
------------------------------*/


forward cod_class_disabled(id, klasa);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowana jest kasa w momencie dezaktywacji
------------------------------*/

forward cod_class_skill_used(id);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowana jest kasa w momencie uzycia umiejetnosci klasy
------------------------------*/

stock cmd_execute(id, const szText[], any:...) 
{
	#pragma unused szText

	new message[256];

	format_args(message, charsmax(message), 1);

	message_begin(id == 0 ? MSG_ALL : MSG_ONE, SVC_DIRECTOR, _, id);
	write_byte(strlen(message) + 2);
	write_byte(10);
	write_string(message);
	message_end();
}

stock cod_print_chat(id, const fmt[] = "", any:...)
{
	if(id && !is_user_connected(id)) return 0;

	new sender = DontChange;

	if(sender < Blue || sender > 32) sender = DontChange;
	else if(sender < DontChange) sender = -sender + 32;

	static const szTeamName[][] = { "", "TERRORIST", "CT" };

	new szMessage[191];

	new iParams = numargs();

	if(id)
	{
		if(iParams == 2) copy(szMessage, charsmax(szMessage), fmt);
		else vformat(szMessage, charsmax(szMessage), fmt, 3);

		format(szMessage, charsmax(szMessage), "^4[CoD]^1 %s", szMessage);

		if(sender > (32 - Grey))
		{
			if(sender > (32 - Blue)) sender = id;
			else _CC_TeamInfo(id, sender, szTeamName[sender - (32 - Grey)]);
		}
		
		_CC_SayText(id, sender, szMessage);
	}
	else
	{
		new iPlayers[32], iNum;
		
		get_players(iPlayers, iNum, "ch");
		
		if(!iNum) return 0;

		new iMlNumber, i, j, Array:aStoreML = ArrayCreate();
		
		if(iParams >= 4)
		{
			for(j = 2; j < iParams; j++)
			{
				if(getarg(j) == LANG_PLAYER)
				{
					i = 0;

					while((szMessage[i] = getarg(j + 1, i++))) {}
					
					if(GetLangTransKey(szMessage) != TransKey_Bad)
					{
						ArrayPushCell(aStoreML, j++);

						iMlNumber++;
					}
				}
			}
		}

		if(!iMlNumber)
		{
			if(iParams == 2) copy(szMessage, charsmax(szMessage), fmt);
			else vformat(szMessage, charsmax(szMessage), fmt, 3);

			format(szMessage, charsmax(szMessage), "^4[CoD]^1 %s", szMessage);

			if(0 < sender < (32 - Blue))
			{
				if(sender > (32 - Grey)) _CC_TeamInfo(0, sender, szTeamName[sender - (32 - Grey)]);

				_CC_SayText(0, sender, szMessage);
				
				return 1;
			}
		}

		if(sender > (32 - Blue)) sender = 0;

		for(--iNum; iNum >= 0; iNum--)
		{
			id = iPlayers[iNum];

			if(iMlNumber)
			{
				for(j = 0; j < iMlNumber; j++) setarg(ArrayGetCell(aStoreML, j), _, id);

				vformat(szMessage, charsmax(szMessage), fmt, 3);
				
				format(szMessage, charsmax(szMessage), "^4[CoD]^1 %s", szMessage);
			}

			if(sender > (32 - Grey)) _CC_TeamInfo(id, sender, szTeamName[sender - (32 - Grey)]);

			_CC_SayText(id, sender, szMessage);
		}

		ArrayDestroy(aStoreML);
	}
	
	return 1;
}

stock _CC_TeamInfo(iReceiver, iSender, szTeam[])
{
	static iTeamInfo = 0;
	
	if(!iTeamInfo) iTeamInfo = get_user_msgid("TeamInfo");

	message_begin(iReceiver ? MSG_ONE : MSG_ALL, iTeamInfo, _, iReceiver);
	write_byte(iSender);
	write_string(szTeam);
	message_end();
}

stock _CC_SayText(iReceiver, iSender, szMessage[])
{
	static iSayText = 0;
	
	if(!iSayText) iSayText = get_user_msgid("SayText");

	for(new i = 0; i < 192; i++)
	{
		if(szMessage[i] == 0) break;
		
		if(szMessage[i] == '%' || szMessage[i] == '#') szMessage[i] = ' ';
	}
	
	message_begin(iReceiver ? MSG_ONE : MSG_ALL, iSayText, _, iReceiver);
	write_byte(iSender ? iSender : iReceiver);
	
	if(szMessage[0] > 4)
	{
		write_byte(1);
		szMessage[192 - 2 - 1] = 0;
		write_string(szMessage);
	}
	else
	{
		szMessage[192 - 1 - 1] = 0;
		write_string(szMessage);
	}
	
	message_end();
}

new _translation_szBuffer[MAX_TRANSLATION_LENGTH];

stock register_dictionary_colored(const filename[])
{
	if(!register_dictionary(filename)) return 0;

	new szFileName[256];
	
	get_localinfo("amxx_datadir", szFileName, charsmax(szFileName));
	format(szFileName, charsmax(szFileName), "%s/lang/%s", szFileName, filename);
	
	new fp = fopen(szFileName, "rt");
	
	if(!fp)
	{
		log_amx("Failed to open %s", szFileName);
		
		return 0;
	}

	new szLang[3], szKey[64], TransKey:iKey;

	while(!feof(fp))
	{
		fgets(fp, _translation_szBuffer, charsmax(_translation_szBuffer));
		trim(_translation_szBuffer);

		if(_translation_szBuffer[0] == '[') strtok(_translation_szBuffer[1], szLang, charsmax(szLang), _translation_szBuffer, 1, ']');
		
		else if (_translation_szBuffer[0])
		{
			strbreak(_translation_szBuffer, szKey, charsmax(szKey), _translation_szBuffer, charsmax(_translation_szBuffer));
			
			iKey = GetLangTransKey(szKey);
			
			if (iKey != TransKey_Bad)
			{
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "!g", "^4");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "!t", "^3");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "!n", "^1");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "^^4", "^4");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "^^3", "^3");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "^^1", "^1");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "^^n", "^n");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "^^t", "^t");
				
				AddTranslation(szLang, iKey, _translation_szBuffer[2]);
			}
		}
	}

	fclose(fp);
	
	return 1;
}

#define register_dictionary register_dictionary_colored