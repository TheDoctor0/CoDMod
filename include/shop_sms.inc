#if defined _shop_sms_included
	#endinput
#endif
#define _shop_sms_included

#pragma library "shop_sms"

#include <shop_sms_const>

native ss_register_service(const service_id[]);
/*------------------------------
 * Rejestruje usluge, ktora bedzie pozniej dostepna w sklepie
 * ---------------------------
 * service_id[] - id uslugi
------------------------------*/

native ss_show_sms_info(id);
/*------------------------------
 * Kontynuuje proces zakupu po zwroceniu wartosci SS_STOP w forwardzie ss_service_chosen
 * ---------------------------
 * id - index gracza dokonujacego zakupu
------------------------------*/

forward ss_service_data(name[],flags[]);
/*------------------------------
 * Forward wysylany ( do pluginu z ktorego zostala zarejstrowana usluga )
 * w momencie pobrania danych o usludze.
 * ---------------------------
 * name[] - nazwa uslugi
 * flags[] - flagi danej uslugi
 * ---------------------------
 */

forward ss_service_addingtolist(id);
/*------------------------------
 * Forward wysylany ( do pluginu z ktorego zostala zarejstrowana usluga )
 * w momencie dodawania uslugi do menu z uslugami.
 * Funkcja powinna zwracaæ jedn¹ z dwoch wartosci:
 *  ITEM_ENABLED - usluga ma byc dostepna
 *  ITEM_DISABLED - usluga ma byc niedostepna
 * ---------------------------
 * id - index gracza dokonujacego zakupu
------------------------------*/

forward ss_service_chosen(id, amount);
/*------------------------------
 * Forward wysylany ( do pluginu z ktorego zostala zarejstrowana usluga )
 * w momencie wybrania uslugi.
 * Funkcja powinna zwracaæ jedna z dwoch wartosci:
 *  SS_OK
 *  SS_STOP - gdy chcemy na pewien czas zatrzymaæ proces wykupowania us³ugi.
 *		Potem musimy go wznowiæ za pomoca natywu ss_show_sms_info.
 * ---------------------------
 * id - index gracza dokonujacego zakupu
 * amount - wybrana ilosc ( opcja )
------------------------------*/

forward ss_service_bought(id, amount);
/*------------------------------
 * Forward wysylany ( do pluginu z ktorego zostala zarejstrowana usluga ) w momencie zakupu uslugi.
 * Mozna zwrocic wartosc SS_ERROR w przypadku wystapienia bledu przy dodawaniu uslugi.
 * ---------------------------
 * id - index gracza dokonujacego zakupu
 * amount - ilosc wykupionej uslugi
------------------------------*/