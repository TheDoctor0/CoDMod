#include <amxmodx>
#include <amxmisc>
#include <codmod>
        
new const nazwa[]   = "Smouke";
new const opis[]    = "20 kondycja, 20 inteligencja, 20 wytrzymalosc";
new const bronie    = 0;
new const zdrowie   = 0;
new const kondycja  = 20;
new const inteligencja = 20;
new const wytrzymalosc = 20;
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
