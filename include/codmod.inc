#if defined _codmod_included
  #endinput
#endif
#define _codmod_included

#define COD_CONTINUE 0

#define COD_STOP 4

#define DMG_CODSKILL (1<<31)



native cod_get_user_xp(id);
/*------------------------------
Zwraca doswiadczenie gracza
------------------------------*/

native cod_get_user_level(id);
/*------------------------------
Zwraca poziom gracza
------------------------------*/

native cod_set_user_xp(id, wartosc);
/*------------------------------
Ustawia doswiadczenie gracza
------------------------------*/

native cod_get_user_class(id);
/*------------------------------
Zwraca klase gracza
------------------------------*/

native cod_set_user_class(id, klasa, zmien=0);
/*------------------------------
Ustawia klase gracza, 
jezeli zmien=1 zmienia ja natychmiast
------------------------------*/

native cod_get_user_perk(id, &wartosc=0);
/*------------------------------
Zwraca perk gracza, 
oraz przypisuje zmiennej wartosc wartosc perku
------------------------------*/

native cod_set_user_perk(id, perk, wartosc=-1, pokaz_info=1);
/*------------------------------
Ustawia perk gracza. 
Jezeli wartosc = -1,
wartosc perku bedzie losowa.
Jezeli perk = -1 perk
bedzie losowy
------------------------------*/

native cod_set_user_upgraded_perk(id, perk, wartosc=-1);
/*------------------------------
Ustawia ulepszony perk gracza. 
------------------------------*/

native cod_get_user_health(id, zdrowie_zdobyte=1, zdrowie_klasy=1, zdrowie_bonusowe=1);
/*------------------------------
Zwraca punkty statystyki zdrowie
------------------------------*/

native cod_set_user_bonus_health(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki zdrowie
------------------------------*/

native cod_get_user_intelligence(id, inteligencja_zdobyta=1, inteligencja_klasy=1, inteligencja_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki inteligencja
------------------------------*/

native cod_set_user_bonus_intelligence(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki inteligencja
------------------------------*/

native cod_get_user_trim(id, kondycja_zdobyta=1, kondycja_klasy=1, kondycja_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki kondycja
------------------------------*/


native cod_set_user_bonus_trim(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki kondycja
------------------------------*/


native cod_get_user_stamina(id, wytrzymalosc_zdobyta=1, wytrzymalosc_klasy=1, wytrzymalosc_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki wytrzymalosc
------------------------------*/


native cod_set_user_bonus_stamina(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki wytrzymalosc
------------------------------*/


native cod_get_user_invisible(id, niewidzialnosc_zdobyta=1, niewidzialnosc_klasy=1, niewidzialnosc_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki niewidzialnosc
------------------------------*/


native cod_set_user_bonus_invisible(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki niewidzialnosc
------------------------------*/


native cod_inflict_damage(atakujacy, ofiara, Float:obrazenia, Float:czynnik_inteligencji=1.0, byt_uszkadzajacy=0, dodatkowe_flagi=0);
/*------------------------------
Zadaje obrazenia z uwzglednieniem inteligencji
------------------------------*/


native cod_get_perkid(const nazwa_perku[]);
/*------------------------------
Zwaca numer perku o podanej nazwie
------------------------------*/


native cod_get_perks_num();
/*------------------------------
Zwaca ilosc perkow
------------------------------*/


native cod_get_perk_name(perk, Return[], len);
/*------------------------------
Kopiuje nazwe perku do Return
------------------------------*/


native cod_get_perk_desc(perk, Return[], len);
/*------------------------------
Kopiuje opis perku do Return
------------------------------*/


native cod_get_classid(const nazwa_klasy[]);
/*------------------------------
Zwaca numer klasy o podanej nazwie
------------------------------*/


native cod_get_classes_num();
/*------------------------------
Zwaca ilosc klas
------------------------------*/

native cod_get_class_level(id);
/*------------------------------
Zwaca poziom klasy
------------------------------*/

native cod_get_class_name(perk, Return[], len);
/*------------------------------
Kopiuje nazwe klasy do Return
------------------------------*/


native cod_get_class_desc(perk, Return[], len);
/*------------------------------
Kopiuje opis klasy do Return
------------------------------*/


native cod_give_weapon(id, bron);
/*------------------------------
Daje okreslona bron oraz pozwala na jej posiadanie
------------------------------*/


native cod_take_weapon(id, bron);
/*------------------------------
Zabiera okreslona bron oraz zabrania jej posiadania
------------------------------*/


native cod_set_user_shield(id, wartosc);
/*------------------------------
Ustawia tarcze gracza. 
------------------------------*/


native cod_set_user_nightvision(id, wartosc);
/*------------------------------
Ustawia noktowizor gracza. 
------------------------------*/

native cod_set_user_resistance(id, wartosc);
/*------------------------------
Ustawia graczowi odpornosc na miny, rakiety, dynamit
------------------------------*/

native cod_get_user_resistance(id);
/*------------------------------
Sprawdza odpornosc gracza na miny, rakiety, dynamit
------------------------------*/


native cod_register_perk(const nazwa[], const opis[], min_wartosc=0, max_wartosc=0);
/*------------------------------
Rejestruje nowy perk oraz zwraca jego numer
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


native cod_set_perk_durability(id, wytrzymalosc);
/*------------------------------
Ustawia wytrzymalosc perku gracza
------------------------------*/


native cod_get_perk_durability(id);
/*------------------------------
Pobiera wytrzymalosc perku gracza
------------------------------*/


native cod_max_perk_durability(id)
/*------------------------------
Zwraca maksymalna wytrzymalosc perku
------------------------------*/

forward cod_perk_changed(id, perk);
/*------------------------------
Forward wysylany do wszystkich pluginow w momencie zmiany perku
------------------------------*/


forward cod_class_changed(id, klasa);
/*------------------------------
Forward wysylany do wszystkich pluginow w momencie zmiany klasy
------------------------------*/


forward cod_perk_enabled(id, wartosc, perk);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowany jest perk w momencie aktywacji
------------------------------*/


forward cod_perk_disabled(id, perk);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowany jest perk w momencie dezaktywacji
------------------------------*/


forward cod_perk_used(id);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowany jest perk w momencie uzycia perku
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

