#include <amxmodx>
#include <codmod>
#include <fakemeta>

new const perk_name[] = "Ogranicznik Rozrzutu";
new const perk_desc[] = "Zmniejsza rorzut broni";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "QTM_Peyote");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_forward(FM_CmdStart, "CmdStart");
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
	ma_perk[id] = false;


public CmdStart(id, uc_handle)
{
	if(ma_perk[id] && get_uc(uc_handle, UC_Buttons) & IN_ATTACK)
	{
		new Float:punchangle[3]
		pev(id, pev_punchangle, punchangle)
		for(new i=0; i<3;i++) 
				punchangle[i]*=0.9;
		set_pev(id, pev_punchangle, punchangle)
	}
}
