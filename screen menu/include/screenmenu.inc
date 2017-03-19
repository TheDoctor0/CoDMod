#if defined _ScreenMenu_included
  #endinput
#endif
#define _ScreenMenu_included


//v0.4.2
#pragma library "ScreenMenu"

#define SMPROP_SHOW_DESCRIPTION 1 /* Czy pokazywac opis po najechaniu na opcje, param1=number */
#define SMPROP_NORMAL_COLOR 	2 /* Kolor normalny, param1=number[3] */
#define SMPROP_OVER_COLOR 	3 /* Kolor po najechaniu na opcje, param1=number[3] */
#define SMPROP_DISABLED_COLOR 	4 /* Kolor wylaczonej opcji, param1=number[3] */
#define SMPROP_TITLE_COLOR 	5 /* Kolor tytulu, param1=number[3] {0, 0, 0} ukrywa tytul*/
#define SMPROP_PREFIX 		6 /* Prefiks opcji, param1=string[8], domyslnie takie C z kropka*/


/**
 * Stworz nowe ScreeMenu
 *	@param	szName[]	Tytul menu
 *	@param  szCallback[]	Funkcja reagujaca na wybranie opcji z menu
 *	@param 	szSubCallback[] Funkcja reagujaca na najechanie na opcje w menu
 *
 *	Oba callbacki powinny miec postac:
 *
 *	jesli nie wybrano zadnej z opcji item=-2
 *
 *	public funkcja(id, menu, item){
 *		
 *	}
 */
native smenu_create(const szName[], const szCallback[] = "", const szSubCallback[] = "");

/**
 * Dodaje nowa opcje w menu
 *
 *	@param	smenu	Id menu
 *	@param	name[]	Nazwa opcji (wyswietlana w menu)
 *	@param  info[]	Dodatkowe pole na dane lub opis opcji
 *	@param	paccess	Poziom dostepu do opcji (np. ADMIN_BAN)
 *	@param  callback Funkcja kontrojaca dostepnosc opcji, skorzystaj z smenu_makecallback()
 */
native smenu_additem(smenu, const name[], const info[]="", paccess=0, callback=-1);

/**
 * Tworzy callback opcji w menu
 * Funkcja musi byc zgodna z prototypem:
 *	public funkcja(id, menu, item){
 *
 *		return ITEM_IGNORED;
 *	}
 *	Od tego co zwroci funkcja zalezy dostepnosc opcji:
 *		ITEM_IGNORED - zgodnie z paccess
 *		ITEM_ENABELD - dostepna
 *		ITEM_DISABLED - zablkokowana
 */
native smenu_makecallback(const function[]);

/**
 * Zwraca ilosc opcji w menu
 */
native smenu_items(smenu);

/**
 * Pokazuje graczowi menu, zacienia ekran, ukrywa bron i blokuje rozgladanie sie na rzecz wyboru opcji
 *
 *	@param	id	Indeks gracza
 *	@param	smenu	Id menu
 *	@param  selected Opcja zaznaczona na start, 
 *			-2 = zaden
 *			-1 = auto
 */
native smenu_display(id, smenu, selected = -2);

/**
 * Pobiera dane o opcji
 *
 *	@param	menu	Id menu
 *	@param  item	Numer opcji
 *	@param	access	Poziom dostepu
 *	@param	info	Info, opis
 *	@param 	infolen	Dlugosc bufora
 *	@param	name	Nazwa
 *	@param	namelen	Dlugosc bufora
 *	@param  callback Funkcja kontrolujaca dostep
 */
native smenu_item_getinfo(menu, item, &access, info[], infolen, name[]="", namelen=0, &callback);

/**
 * Dodaje pusta opcje w menu
 */
native smenu_addblank(menu);

/**
 * Ustawia wlasciwosci menu
 *
 *	@param	smenu	Id menu
 *	@param	prop, ... jedna ze sta³ych SMPROP_* i jej parametry
 */
native smenu_setprop(menu, prop, ...);

/**
 * Ustawia tekst w menu
 *
 * @param menu			Id menu
 * @param item			Numer opcji
 * @param name			Nowy tekst
 */
native smenu_item_setname(menu, item, const name[]);

/**
 * Ustawia info w menu
 *
 * @param menu			Id menu
 * @param item			Numer opcji
 * @param info			Nowy tekst
 */
native smenu_item_setcmd(menu, item, const info[]);

/**
 * Chowa menu, dla zgodnosci z newmenus.inc
 */
native smenu_cancel(player);

/**
 * Wychodzi z menu, lepsza nazwa ;)
 */
stock smenu_exit(player) {
	smenu_cancel(player);
}

/**
 * Zwraca menu id aktualnie wyswietlanego ScreeMenu lub 0, jesli gracz nie ma na ekranie zadnego z nich
 */
native player_smenu_info(id);

/**
 * Niszczy menu
 */
native smenu_destroy(menu);
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
