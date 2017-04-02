#if defined _jailbreak_included
  #endinput
#endif
#define _jailbreak_included

enum
{
	NIEDZIELA = 0,
	PONIEDZIALEK,
	WTOREK,
	SRODA,
	CZWARTEK,
	PIATEK,
        SOBOTA,
	
	USUWANIE_DANYCH = 7
}

#define MAX 32

#define JAIL_CONTINUE 0
#define JAIL_HANDLED 9999
#define JAIL_FORCE_TT 1
#define JAIL_FORCE_CT 2

#define strip_user_weapons2(%0) strip_user_weapons(%0), set_pdata_int(%0, 116, 0)

#define VERSION_JAILBREAK_CYPIS 107.96

#define KILLDAY_DAY PIATEK

/*------------------------------
Rejstruje zabawe i dodaje ja do menu zabaw
@return - zwraca return index'u dodanej zabawy
------------------------------*/
native jail_register_game(name_game[]);

/*------------------------------
Rejstruje zyczenie i dodaje ja do menu zyczen
@return - zwraca return index'u dodanego zyczenia
------------------------------*/
native jail_register_wish(name_wish[]);

native jail_get_play_game();


/*------------------------------
Zwraca Bool wartoœci zmiennej, true - mikro dla wieŸniów w³¹czone | false - mikro dla wiêŸniów wy³¹czone
------------------------------*/
native bool:jail_get_prisoners_micro();


/*------------------------------
Zwraca Bool wartoœci zmiennej, true - walka dla wieŸniów w³¹czona | false - walka dla wiêŸniów wy³¹czona
------------------------------*/
native bool:jail_get_prisoners_fight();


/*------------------------------
Zwraca Bool wartoœci zmiennej, true - gracz ma freedaya | false - gracz nie ma freedaya
@bool:id - index gracza ktorego chcemy sprawdzic czy ma freeday'a
------------------------------*/
native bool:jail_get_prisoner_free(id);


/*------------------------------
Zwraca Bool wartoœci zmiennej, true - gracz ma duszka | false - gracz nie ma duszka
@bool:id - index gracza ktorego chcemy sprawdzic czy ma duszka
------------------------------*/
native bool:jail_get_prisoner_ghost(id);


/*------------------------------
Zwraca Bool wartoœci zmiennej, true - gracz nie moze podnosic broni, brac broni ich z automatu, leczyc sie i wyrzucac broni | false - przeciwnieñstwo "true"
@bool:id - index gracza ktorego chcemy sprawdzic czy ma ustawiona blokade
------------------------------*/
native bool:jail_get_user_block(id);


/*------------------------------
Zwraca Bool wartoœci zmiennej, true - gracz jest poszukiwany | false - nie jest poszukiwany
@bool:id - index gracza ktorego chcemy sprawdzic czy jest poszukiwany
------------------------------*/
native bool:jail_get_poszukiwany(id);


/*------------------------------
Zwraca Bool wartosci zmiennej, true - sa gracze poszukiwani | false - nie ma poszukiwanych
------------------------------*/
native bool:jail_get_poszukiwani();


/*------------------------------
Zwraca przez Return index ostatniego wiêŸnia
------------------------------*/
native jail_get_prisoner_last();


/*------------------------------
Zwraca przez Return index prowadzacego straznika
------------------------------*/
native jail_get_prowadzacy();


/*------------------------------
Zwraca przez Return numer dnia
------------------------------*/
native jail_get_days();


/*------------------------------
Zwraca przez Return numer zabawy
------------------------------*/
native jail_get_play_game_id();


/*------------------------------
@bool:wartosc - jak ustawimy true to mikro dla wiêŸniów bêdzie w³¹czone, jak false to mikro dla wiêŸniów bêdzie wy³¹czone
@bool:info - pokazuje informacje w say czy w³¹czy³o siê czy w³¹czy³o mikro dla wiêŸników
------------------------------*/
native jail_set_prisoners_micro(bool:wartosc, bool:info=true);


/*------------------------------
@bool:wartosc - jak ustawimy true to walka dla wiêŸniów bêdzie w³¹czona, jak false to walka dla wiêŸniów bêdzie wy³¹czona
@bool:modele - jak ustawimy true to modele rekawic bokserskich beda w³aczone, jak false to bêd¹ modele piesci
@bool:info - pokazuje informacje w say czy w³¹czono czy wy³¹czono walke dla wiêŸników
------------------------------*/
native jail_set_prisoners_fight(bool:wartosc, bool:modele=true, bool:info=true);


/*------------------------------
@bool:id - index gracza któremu chcemy daæ freeday
@bool:wartosc - jak damy true to ustawi freedaya, jak false to nie
@bool:nextround - jak damy true to ustawi freedaya w nastepnej rundzie, jak false to nie
@return - zwraca "return = 0" kiedy nie moze ustawic freedaya, zwraca "return = 1" kiedy ustawilo freedaya
------------------------------*/
native jail_set_prisoner_free(id, bool:wartosc=true, bool:nextround=true);


/*------------------------------
@bool:id - index gracza któremu chcemy daæ duszka
@bool:wartosc - jak damy true to ustawi duszka, jak false to nie
@bool:nextround - jak damy true to ustawi duszka w nastepnej rundzie, jak false to nie
@return - zwraca "return = 0" kiedy nie moze ustawic duszka, zwraca "return = 1" kiedy ustawilo duszka
------------------------------*/
native jail_set_prisoner_ghost(id, bool:wartosc=true, bool:nextround=true);


/*------------------------------
@bool:id - index gracza, któremu chcemy zablokowac podnoszenie broni, branie ich z automatu, wyrzucanie broni, leczenie sie
@bool:wartosc - true jak chcemy zablokowac, false jak odblokowac
------------------------------*/
native jail_set_user_block(id, bool:wartosc);


/*------------------------------
@bool:wartosc - jak ustawimy true to TT bedzie niesmiertelne, jake false to bedzie mozna ich zabic
------------------------------*/
native jail_set_god_tt(bool:wartosc);


/*------------------------------
@bool:wartosc - jak ustawimy true to CT bedzie niesmiertelne, jake false to bedzie mozna ich zabic
------------------------------*/
native jail_set_god_ct(bool:wartosc);


/*------------------------------
@bool:wartosc - jak ustawimy true to CT nie bedzie moglo zabic TT, jake false to bedzie mog³o zabic 
------------------------------*/
native jail_set_ct_hit_tt(bool:wartosc);


/*------------------------------
@bool:wartosc - jak ustawimy true to TT nie bedzie moglo zabic CT, jake false to bedzie mog³o zabic 
------------------------------*/
native jail_set_tt_hit_ct(bool:wartosc);


/*------------------------------
@bool:id - index gracza, któremu chcemy daæ prowadzacego straznika
Jak damy id=0 to wtedy usuniemy prowadzacego straznika
------------------------------*/
native jail_set_prowadzacy(id);


/*------------------------------
Wyswietla menu z broniami danemu graczowi
@id - index gracza
@bool:bronie - jak ustawimy na true to graczowi wyœwietli siê menu broni maszynowych do wyboru
@bool:pistolety - jak ustawimy na true to graczowi wyœwietli siê menu z pistoletami do wyboru
@bitsum_bronie - tu ustawiamy BITOWO jakich broni ma NIEBYÆ w menu broni maszynowych
@bitsum_pistolety - tu ustawiamy BITOWO jakich broni ma NIEBYÆ w menu pistoletów
Notka:
- Je¿eli bool:bronie i bool:pistolety bêd¹ ustawione na false to nie wyœwietli siê menu
- Je¿eli bool:bronie i bool:pistolety bêd¹ ustawione na true to najpierw wyœwietli siê menu broni maszynowych a póŸniej menu pistoletów

Przyk³ad usuniêcia AWP i SCOUTA z menu broni maszynowych:
jail_set_user_weapons(id, true, false, (1<<CSW_AWP)|(1<<CSW_SCOUT), 0);
------------------------------*/
native jail_set_user_menuweapons(id, bool:bronie, bool:pistolety, bitsum_bronie=0, bitsum_pistolety=0);


/*------------------------------
Otwiera wszystkie cele lub zamyka
------------------------------*/
native jail_open_cele();


/*------------------------------
Natyw ten mozna wykorzystac do wywolywania forwardu OnDayStartPre w celu uruchomienia jakiejs zabawy

@day - index dnia lub zabawy
@bool:fast - jezeli damy true to wywola forward bez sprawdzania czy nie minelo 60s lub nie zmienila sie ilosc graczy, jak false to musi sprawdzac
@return - zwraca "return = 1" je¿eli forwad OnDayStartPre wywo³a sie, zwraca "return = 0" je¿eli jest ro¿nica w graczach lub minelo 60s
------------------------------*/
native jail_set_play_game(day, bool:fast=false);

/*------------------------------
Pozwala wiezniom zaglosowac na zabawe w kolejnej rundzie
------------------------------*/
native jail_set_prisoners_game();


/*------------------------------
Ustawia predkosc danemu graczowi
@id - index gracza, ktoremu chcemy ustawic predkosc
@Float:speed - wartosc predkosci

Notatka:
Zeby gracz nie mogl chodzi wartosc Float:speed trzeba ustawic na 0.1 
Zeby zresetowac prekosc wartosc Float:speed trzeba ustawic na -1.0
------------------------------*/
native jail_set_user_speed(id, Float:speed);


/*------------------------------
Wywo³uje siê podczas rozpoczesnia dnia (rundy), przed frezztime. Dzieki temu forwardowi mozna dodawac w rozne dni zautomatyzowane zabawy.

@day - jest to index dnia/zabawy
@szInfo[256] - ustawienie informacji na hud (te na zielono)
@szInfo2[256] - ustawienie informacji na hud (te na zolto)
@setting[10] - tu ustawia sie dane jaki ma miec dzien/zabawa, resetuja sie one po zakonczeniu dnia (rundy)
@gTimeRound - zwraca czas w sekundach do konca dnia (rundy)
------------------------------*/
forward OnDayStartPre(day, szInfo[256], szInfo2[256], setting[10], gTimeRound);


/*------------------------------
Rozni sie od OnDayStartPre tym ze wywoluje sie po frezztime i ma mniej argumentow. Sluzy do otwierania cel, wyswietlania czasu na hud, itd. ...

@day - jest to numer dnia/zabawy
------------------------------*/
forward OnDayStartPost(day);


/*------------------------------
Wywo³uje siê podczas dania ostatniemu wiêŸniowi mo¿liwoœæ wybrania ¿yczenia.
Ten foward nadaje siê te¿ do resetowania/ustawiania jakiœ zmiennych.

@id - jest to index ostatniego wieŸnia
------------------------------*/
forward OnLastPrisonerShowWish(id);


/*------------------------------
Wywo³uje siê podczas wybrania zyczenie prze ostatniego wiêŸnia.
Ten foward nadaje siê te¿ do resetowania/ustawiania jakiœ zmiennych

@id - jest to index ostatniego wieŸnia
@wish - jest to index zyczenia wybranego przez wieznia

return JAIL_CONTINUE - nic nie zablokuje
return JAIL_HANDLED - zablokuje wybranie zyczenia
------------------------------*/
forward OnLastPrisonerTakeWish(id, wish);

/*------------------------------
Wywo³uje siê po wybraniu zyczenia przez ostatniego wiêŸnia.
Ten foward nadaje siê te¿ do resetowania/ustawiania jakiœ zmiennych

@id - jest to index ostatniego wieŸnia
------------------------------*/
forward OnLastPrisonerWishTaken(id);

/*------------------------------
Wywo³uje siê podczas zakonczenia kazdego dnia (rundy), przeznaczyony do resetowania zmiennych.
@day - jest to id_zabawy je¿eli w tym dniu takowa by³a, lub id_dnia
------------------------------*/
forward OnRemoveData(day);


/*------------------------------
Wywo³uje siê podczas dolaczania do druzny, nie wywoluje sie jak gracz wchodzi na spect.
@id - jest to index gracza
@team - jest to numer teamu do jakiego gracz chce dojsc
@tt - ilosc osob w TT
@ct - ilosc osob w CT

return JAIL_CONTINUE - nic nie zablokuje
return JAIL_HANDLED - blokuje wybranie teamu, czyli gracz nie wybierze teamu
return JAIL_FORCE_TT - gracz dolaczy do tt
return JAIL_FORCE_CT - gracz dolaczy do ct
------------------------------*/
forward OnJoinTeam(id, team, tt, ct);


/*------------------------------
Zwraca przez Return index losowego gracza, zwraca 0 jeœli nie ma znago gracza
@team - podajemy z ktorego teamu ma losowac gracz, 1 - TT, 2 - CT
------------------------------*/
stock RandomPlayer(team)
{
	if(!(1 <= team <= 2)) return 0;

	new Players[MAX+2], ile=0;
	
	for(new i=1; i<=MAX; i++)
	{
		if(!is_user_alive(i) || !is_user_connected(i) || get_user_team(i) != team || jail_get_prisoner_ghost(i) || jail_get_prisoner_free(i)) continue;

		Players[++ile] = i;
	}
	
	return Players[(ile? random_num(1, ile): 0)];
}

/*------------------------------
Usuwa "czas na HUD"
Nie u¿ywaæ tego w forwadzie OnRemoveData() !
------------------------------*/
public jail_remove_game_hud()
{
	remove_task(2761234, 1);
}

/*------------------------------
Zwraca przez Return czy jest "czas na HUD"
------------------------------*/
public jail_get_game_hud()
{
	return task_exists(2761234, 1);
}


/*------------------------------
Ustawia "czas na HUD"

@czas - podajemy czas w sekundach ile ma trwac odliczanie
@nazwa[64] - podajemy jaki napis ma wyswietlac na HUD
@r - wartosc koloru RED
@g - wartosc koloru GREEN
@b - wartosc koloru BLUE
@Float:x - wartosc wektora X na ekranie
@Float:y - wartosc wektora Y na ekranie

Notatka:
Co kazda sekunde wywo³uje sie forward OnGameHudTick(day, count) - count, oznacza ilosc do konca w sekundach
Po zakoñczeniu odliczania wywoluje sie forward OnGameHudEnd(day)
------------------------------*/

native jail_set_game_hud(czas, nazwa[64], r=0, g=127, b=255, Float:x=0.5, Float:y=0.7)

/*------------------------------
Ustawia czas do konca zabawy

Notatka:
Po uplynieciu wybranego czasu nastapi losowo jedno z wydarzen:
- Smierc straznikow
- Walka wiezniow ze straznikami
- Walka miedzy wiezniami
--------------------------------*/

native jail_set_game_end(Float:Time)