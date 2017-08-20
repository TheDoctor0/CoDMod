#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
        
new const nazwa[]   = "Krol Strzelcow";
new const opis[]    = "Posiada on M4A1 oraz Deagle + Eliminator Rozrzutu";
new const bronie    = (1<<CSW_M4A1)|(1<<CSW_DEAGLE);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;
    
    new ma_klase[33];
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_forward(FM_CmdStart, "CmdStart");
}
public cod_class_enabled(id)
        ma_klase[id] = true;
        
public cod_class_disabled(id)
        ma_klase[id] = false;
	public CmdStart(id, uc_handle)
{
        if(ma_klase[id] && get_uc(uc_handle, UC_Buttons) & IN_ATTACK)
        {
                new Float:punchangle[3]
                pev(id, pev_punchangle, punchangle)
                for(new i=0; i<3;i++)
                                punchangle[i]*=0.9;
                set_pev(id, pev_punchangle, punchangle)
        }
}
	
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
