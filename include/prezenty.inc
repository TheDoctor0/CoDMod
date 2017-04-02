#if defined _prezenty_included
  #endinput
#endif
#define _prezenty_included

#define MAX_GIFTS 32


enum Gift
{
	GIFT_RANDOM = 0
};

/**
 * Dodaj nowy prezent mozliwy do trafienia w paczce
 *
 *	@param	szName			nazwa wyswietlana po najechaniu mysza
 *	@param	szFunction		funkcja wykonywana po zebraniu prezentu
 * 	@param 	chance			liczba od 1 do 10
 */
native Gift:register_gift( const szName[], const szFunction[], chance = 5 );

/**
 * Utworz na mapie prezent
 *	@param	gift			numer nagrody lub GIFT_RANDOM gdy ma byc losowo
 *	@param 	Float:fOrigin[3]	Punkt na mapie gdzie ma byc stworzona paczka, 
 *					mozna nie podawac, wtedy wybrane zostanie losowe miejsce
 */
native gift_spawn( Gift:gift = GIFT_RANDOM, Float:... );

/**
 * Sprzata mape z prezentow
 */
native gifts_clear_map();


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
