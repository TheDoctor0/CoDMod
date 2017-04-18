#if defined _cod_included
  #endinput
#endif
#define _cod_included

#define get_bit(%2,%1) (%1 & (1<<(%2&31)))
#define set_bit(%2,%1) (%1 |= (1<<(%2&31)))
#define rem_bit(%2,%1) (%1 &= ~(1 <<(%2&31)))

#define is_user_valid(%1) (1 <= %1 <= maxPlayers)

#define COD_CONTINUE 0
#define COD_STOP 4

#define DMG_CODSKILL (1<<31)
#define DMG_HEGRENADE (1<<24)
#define DMG_BULLET (1<<1)

#define	RENDER_ALWAYS (1<<1)
#define	RENDER_MOVE (1<<2)
#define	RENDER_STAND (1<<3)
#define	RENDER_DUCK (1<<4)
#define	RENDER_SHIFT (1<<5)

enum _:promotions { PROMOTION_NONE, PROMOTION_FIRST, PROMOTION_SECOND, PROMOTION_THIRD };

enum _:renderType { RENDER_CLASS, RENDER_ITEM, RENDER_ADDITIONAL };

enum _:hud { TYPE_HUD, TYPE_DHUD };

enum _:sounds { SOUND_SELECT, SOUND_EXIT, SOUND_START, SOUND_START2, SOUND_LVLUP, SOUND_LVLUP2, SOUND_LVLUP3, SOUND_ONE, SOUND_LAST, SOUND_FORCE, SOUND_HUMILIATION, SOUND_BOMB, SOUND_BOX };

new const codSounds[sounds][] =
{
	"CoDMod/select.wav",
	"CoDMod/close.wav",
	"CoDMod/start.wav",
	"CoDMod/start2.wav",
	"CoDMod/levelup.wav",
	"CoDMod/levelup2.wav",
	"CoDMod/levelup3.wav",
	"CoDMod/one.wav",
	"CoDMod/last.wav",
	"CoDMod/force.wav",
	"CoDMod/humiliation.wav",
	"CoDMod/bomb.wav",
	"CoDMod/box.wav"
};

native cod_check_account(id);
/*------------------------------
Sprawdza, czy gracz zalogowal sie na konto.
Wyświetla menu logowania na konto, jeśli nie jest zalogowany.
------------------------------*/

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

native cod_get_class_name(class, dataReturn[], dataLength);
/*------------------------------
Zwraca nazwe klasy.
------------------------------*/

native cod_get_class_desc(class, dataReturn[], dataLength);
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

native cod_upgrade_user_item(id, check = 0);
/*------------------------------
Ulepsza item gracza
Parametr check pozwala na sprawdzenie,
czy dany przedmiot da sie ulepszych
------------------------------*/

native cod_get_itemid(szItem[]);
/*------------------------------
Zwraca item o podanej nazwie.
------------------------------*/

native cod_get_item_name(item, dataReturn[], dataLength);
/*------------------------------
Zwraca nazwe itemu.
------------------------------*/

native cod_get_item_desc(item, dataReturn[], dataLength);
/*------------------------------
Zwraca opis itemu.
------------------------------*/

native cod_get_items_num();
/*------------------------------
Zwraca liczbe itemow.
------------------------------*/

native cod_get_user_rockets(id);
/*------------------------------
Zwraca liczbe rakiet gracza
------------------------------*/

native cod_set_user_rockets(id, value);
/*------------------------------
Ustawia liczbe rakiet gracza
------------------------------*/

native cod_add_user_rockets(id, value);
/*------------------------------
Dodaje graczowi liczbe rakiet
------------------------------*/

native cod_get_user_mines(id);
/*------------------------------
Zwraca liczbe min gracza
------------------------------*/

native cod_set_user_mines(id, value);
/*------------------------------
Ustawia liczbe min gracza
------------------------------*/

native cod_add_user_mines(id, value);
/*------------------------------
Dodaje graczowi liczbe min
------------------------------*/

native cod_get_user_medkits(id);
/*------------------------------
Zwraca liczbe apteczek gracza
------------------------------*/

native cod_set_user_medkits(id, value);
/*------------------------------
Ustawia liczbe apteczek gracza
------------------------------*/

native cod_add_user_medkits(id, value);
/*------------------------------
Dodaje graczowi liczbe apteczek
------------------------------*/

native cod_get_user_dynamites(id);
/*------------------------------
Zwraca liczbe dynamitow gracza
------------------------------*/

native cod_set_user_dynamites(id, value);
/*------------------------------
Ustawia liczbe dynamitow gracza
------------------------------*/

native cod_add_user_dynamites(id, value);
/*------------------------------
Dodaje graczowi liczbe dynamitow
------------------------------*/

native cod_get_user_multijumps(id);
/*------------------------------
Zwraca liczbe skokow gracza
------------------------------*/

native cod_set_user_multijumps(id, value);
/*------------------------------
Ustawia liczbe skoskow gracza
------------------------------*/

native cod_add_user_multijumps(id, value);
/*------------------------------
Dodaje graczowi liczbe skoskow
------------------------------*/

native cod_get_user_armor(id);
/*------------------------------
Zwraca punkty kamizelki gracza
------------------------------*/

native cod_set_user_armor(id, value);
/*------------------------------
Ustawia punkty kamizelki gracza
------------------------------*/

native cod_add_user_armor(id, value);
/*------------------------------
Dodaje graczowi punkty kamizelki
------------------------------*/

native cod_get_user_bunnyhop(id);
/*------------------------------
Zwraca czy gracz ma bunnyhop
------------------------------*/

native cod_set_user_bunnyhop(id, value);
/*------------------------------
Ustawia graczowi wartosc logiczna bunnyhop
------------------------------*/

native cod_get_user_footsteps(id);
/*------------------------------
Zwraca czy gracz ma ciche chodzenie
------------------------------*/

native cod_set_user_footsteps(id, value);
/*------------------------------
Ustawia graczowi wartosc logiczna cichego chodzenia
------------------------------*/

native cod_get_user_vip(id);
/*------------------------------
Sprawdza, czy gracz ma vipa
------------------------------*/

native cod_get_user_health(id, class_health = 1, stats_health = 1, bonus_health = 1);
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

native cod_get_user_bonus_health(id);
/*------------------------------
Zwraca dodatkowe punkty statystyki zdrowie
------------------------------*/

native cod_get_user_intelligence(id, class_intelligence = 1, stats_intelligence = 1, bonus_intelligence = 1);
/*------------------------------
Zwraca punkty statystyki inteligencja
------------------------------*/

native cod_set_user_bonus_intelligence(id, value);
/*------------------------------
Ustawia dodatkowe punkty statystyki inteligencja
------------------------------*/

native cod_get_user_bonus_intelligence(id);
/*------------------------------
Zwraca dodatkowe punkty statystyki inteligencja
------------------------------*/

native cod_get_user_stamina(id, class_stamina = 1, stats_stamina = 1, bonus_stamina = 1);
/*------------------------------
Zwraca punkty statystyki wytrzymalosc
------------------------------*/

native cod_set_user_bonus_stamina(id, value);
/*------------------------------
Ustawia dodatkowe punkty statystyki wytrzymalosc
------------------------------*/

native cod_get_user_bonus_stamina(id);
/*------------------------------
Zwraca dodatkowe punkty statystyki wytrzymalosc
------------------------------*/

native cod_get_user_strength(id, class_strength = 1, stats_strength = 1, bonus_strength = 1);
/*------------------------------
Zwraca punkty statystyki sila
------------------------------*/

native cod_set_user_bonus_strength(id, value);
/*------------------------------
Ustawia dodatkowe punkty statystyki sila
------------------------------*/

native cod_get_user_bonus_strength(id);
/*------------------------------
Zwraca dodatkowe punkty statystyki sila
------------------------------*/

native cod_get_user_condition(id, class_condition = 1, stats_condition = 1, bonus_condition = 1);
/*------------------------------
Zwraca punkty statystyki kondycja
------------------------------*/

native cod_set_user_bonus_condition(id, value);
/*------------------------------
Ustawia dodatkowe punkty statystyki kondycja
------------------------------*/

native cod_get_user_bonus_condition(id);
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

native cod_get_user_gravity(id)
/*------------------------------
Zwraca wartosc grawitacji gracza
------------------------------*/

native cod_set_user_gravity(id, value)
/*------------------------------
Ustawia podana wartosc grawitacji
------------------------------*/

native cod_add_user_gravity(id, value)
/*------------------------------
Dodaje podana wartosc grawitacji
------------------------------*/

native cod_register_item(const nazwa[], const opis[]);
/*------------------------------
Rejestruje nowy item oraz zwraca jego numer
------------------------------*/

native cod_register_class(const nazwa[], const opis[], const frakcja[], bronie, punkty_zdrowia, punkty_inteligencji, punkty_sily, punkty_wytrzymalosci, punkty_kondycji);
/*------------------------------
Rejestruje nowa klase oraz zwraca jej numer
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


native cod_max_item_durability();
/*------------------------------
Zwraca maksymalna wytrzymalosc itemu
------------------------------*/

native cod_show_hud(id, const text[], type=0, red=255, green=255, blue=255, Float:x=-1.0, Float:y=0.35, effects=0, Float:fxtime=6.0, Float:holdtime=12.0, Float:fadeintime=0.1, Float:fadeouttime=0.2)
/*------------------------------
Wyświetla hud o podanych parametrach
------------------------------*/

native cod_get_user_bonus_exp(id, value);
/*------------------------------
Zwraca exp powiekszony bonus dla danego gracza
------------------------------*/

native cod_display_fade(id, duration, holdtime, fadetype, red, green, blue, alpha);
/*------------------------------
Wyświetla fade o podanych parametrach
------------------------------*/

native cod_check_register_system(id);
/*------------------------------
Sprawdza, czy gracz wpisal juz haslo i ewentualnie wymusza jego wpisanie
------------------------------*/

native cod_get_user_clan(id);
/*------------------------------
Zwraca klan gracza
------------------------------*/

native cod_get_clan_name(clan, dataReturn[], dataLength);
/*------------------------------
Zwraca nazwe klanu
------------------------------*/

native cod_get_user_honor(id);
/*------------------------------
Zwraca honor gracza
------------------------------*/

native cod_set_user_honor(id, wartosc);
/*------------------------------
Ustawia honor gracza.
------------------------------*/

native cod_add_user_honor(id, wartosc);
/*------------------------------
Dodaje honor graczowi.
------------------------------*/

native cod_kill_player(attacker, victim, damageBits);
/*------------------------------
Zabija podanego gracza.
------------------------------*/

native cod_spawn_box_icon(ent);
/*------------------------------
Wyswietla ikone nad paczka.
------------------------------*/

native cod_remove_box_icon(ent);
/*------------------------------
Usuwa ent paczki i jej ikony.
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

stock cmd_execute(id, const text[], any:...) 
{
	#pragma unused text

	new message[256];

	format_args(message, charsmax(message), 1);

	message_begin(id == 0 ? MSG_ALL : MSG_ONE, SVC_DIRECTOR, _, id);
	write_byte(strlen(message) + 2);
	write_byte(10);
	write_string(message);
	message_end();
}

stock cod_print_chat(id, const text[] = "", any:...)
{
	new message[192];

	if(numargs() == 2) copy(message, charsmax(message), text);
	else vformat(message, charsmax(message), text, 3);

	client_print_color(id, id, "^x04[CoD]^x01 %s", message);
}

stock mysql_escape_string(const source[], dest[], length)
{
	copy(dest, length, source);
	
	replace_all(dest, length, "\\", "\\\\");
	replace_all(dest, length, "\0", "\\0");
	replace_all(dest, length, "\n", "\\n");
	replace_all(dest, length, "\r", "\\r");
	replace_all(dest, length, "\x1a", "\Z");
	replace_all(dest, length, "'", "\'");
	replace_all(dest, length, "`", "\`");
	replace_all(dest, length, "^"", "\^"");
}