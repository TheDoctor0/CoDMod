#include <amxmodx>
#include <amxmisc>
#include <codmod>
        
new const nazwa[]   = "Kolos";
new const opis[]    = "Jest bardzo wytrzyma³y, ma m4 i deagle";
new const bronie    = (1<<CSW_M4A1)|(1<<CSW_DEAGLE);
new const zdrowie   = 30;
new const kondycja  = 15;
new const inteligencja = 10;
new const wytrzymalosc = 50;
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
