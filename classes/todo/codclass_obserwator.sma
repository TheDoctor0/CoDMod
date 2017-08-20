#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
        
new const nazwa[]   = "Obserwator";
new const opis[]    = "Posiada snajperkê 1/10 z AWP, Deagle Lekko Niewidzialny(255/200).";
new const bronie    = (1<<CSW_AWP)|(1<<CSW_DEAGLE);
new const zdrowie   = 20;
new const kondycja  = 20;
new const inteligencja = 20;
new const wytrzymalosc = 20;
    
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}

public cod_class_enabled(id)
{

	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 200);
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
    	ma_klase[id] = false;

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
