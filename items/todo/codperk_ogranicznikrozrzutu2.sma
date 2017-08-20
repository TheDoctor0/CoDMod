#include <amxmodx>
#include <codmod>
#include <fakemeta>

new const perk_name[] = "Ogranicznik Rozrzutu";
new const perk_desc[] = "Zmniejsza rozrzut broni o 60%%";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_forward(FM_PlayerPreThink, "PreThink");
	register_forward(FM_UpdateClientData, "UpdateClientData", 1)
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
	ma_perk[id] = false;

public PreThink(id)
{
	if(ma_perk[id])
	{
		static Float:punchangle[3]
		pev(id, pev_punchangle, punchangle)
		
		punchangle[0]*=0.4;
		punchangle[1]*=0.4;
		punchangle[2]*=0.4;

		set_pev(id, pev_punchangle, punchangle)
	}
}

public UpdateClientData(id, sw, cd_handle)
{
	if(ma_perk[id])
	{
		static Float:punchangle[3]
		set_cd(cd_handle, CD_PunchAngle, punchangle)
		
		punchangle[0]*=0.4;
		punchangle[1]*=0.4;
		punchangle[2]*=0.4;

		set_cd(cd_handle, CD_PunchAngle, punchangle)
	}
}