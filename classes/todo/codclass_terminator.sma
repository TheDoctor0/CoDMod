#include <amxmodx>
#include <amxmisc>
#include <codmod>
        
new const nazwa[]   = "Terminator";
new const opis[]    = "30 kondycja i 10 inteligencja";
new const bronie    = 0;
new const zdrowie   = 0;
new const kondycja  = 30;
new const inteligencja = 10;
new const wytrzymalosc = 0;
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
