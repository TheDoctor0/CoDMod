#if defined _surf_included
  #endinput
#endif
#define _surf_included

#define SURF_CONTINUE 0

#define SURF_STOP 4

#define DMG_SURFSKILL (1<<31)


native surf_get_user_xp(id);
/*------------------------------
Zwraca doswiadczenie gracza
------------------------------*/

native surf_get_user_level(id);
/*------------------------------
Zwraca poziom gracza
------------------------------*/

native surf_set_user_xp(id, wartosc);
/*------------------------------
Ustawia doswiadczenie gracza
------------------------------*/

native surf_get_user_class(id);
/*------------------------------
Zwraca klase gracza
------------------------------*/

native surf_set_user_class(id, klasa, zmien=0);
/*------------------------------
Ustawia klase gracza, 
jezeli zmien=1 zmienia ja natychmiast
------------------------------*/

native surf_get_user_health(id, zdrowie_zdobyte=1, zdrowie_klasy=1, zdrowie_bonusowe=1);
/*------------------------------
Zwraca punkty statystyki zdrowie
------------------------------*/

native surf_set_user_bonus_health(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki zdrowie
------------------------------*/

native surf_get_user_intelligence(id, inteligencja_zdobyta=1, inteligencja_klasy=1, inteligencja_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki inteligencja
------------------------------*/

native surf_set_user_bonus_inteligence(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki inteligencja
------------------------------*/

native surf_get_user_trim(id, kondycja_zdobyta=1, kondycja_klasy=1, kondycja_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki kondycja
------------------------------*/


native surf_set_user_bonus_trim(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki kondycja
------------------------------*/


native surf_get_user_stamina(id, wytrzymalosc_zdobyta=1, wytrzymalosc_klasy=1, wytrzymalosc_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki wytrzymalosc
------------------------------*/


native surf_set_user_bonus_stamina(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki wytrzymalosc
------------------------------*/


native surf_inflict_damage(atakujacy, ofiara, Float:obrazenia, Float:czynnik_inteligencji=1.0, byt_uszkadzajacy=0, dodatkowe_flagi=0);
/*------------------------------
Zadaje obrazenia z uwzglednieniem inteligencji
------------------------------*/


native surf_get_classid(const nazwa_klasy[]);
/*------------------------------
Zwaca numer klasy o podanej nazwie
------------------------------*/


native surf_get_classes_num();
/*------------------------------
Zwaca ilosc klas
------------------------------*/

native surf_get_class_level(id);
/*------------------------------
Zwaca poziom klasy
------------------------------*/

native surf_get_class_name(class, Return[], len);
/*------------------------------
Kopiuje nazwe klasy do Return
------------------------------*/


native surf_get_class_desc(class, Return[], len);
/*------------------------------
Kopiuje opis klasy do Return
------------------------------*/


native surf_give_weapon(id, bron);
/*------------------------------
Daje okreslona bron oraz pozwala na jej posiadanie
------------------------------*/


native surf_take_weapon(id, bron);
/*------------------------------
Zabiera okreslona bron oraz zabrania jej posiadania
------------------------------*/


native surf_set_user_shield(id, wartosc);
/*------------------------------
Ustawia tarcze gracza. 
------------------------------*/


native surf_set_user_nightvision(id, wartosc);
/*------------------------------
Ustawia noktowizor gracza. 
------------------------------*/

native surf_set_user_resistance(id, wartosc);
/*------------------------------
Ustawia graczowi odpornosc na miny, rakiety, dynamit
------------------------------*/


native surf_register_class(const nazwa[], const opis[], bronie, punkty_zdrowia, punkty_kondycji, punkty_inteligencji, punkty_wytrzymalosci);
/*------------------------------
Rejestruje nowa klase oraz zwraca jej numer
------------------------------*/


native surf_get_level_xp(poziom);
/*------------------------------
Zwraca ilosc potrzebnego doswiadczenia do przejscia danego poziomu
------------------------------*/


forward surf_class_changed(id, klasa);
/*------------------------------
Forward wysylany do wszystkich pluginow w momencie zmiany klasy
------------------------------*/


forward surf_class_enabled(id, klasa);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowana jest kasa w momencie aktywacji
------------------------------*/


forward surf_class_disabled(id, klasa);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowana jest kasa w momencie dezaktywacji
------------------------------*/

forward surf_class_skill_used(id);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowana jest kasa w momencie uzycia umiejetnosci klasy
------------------------------*/

