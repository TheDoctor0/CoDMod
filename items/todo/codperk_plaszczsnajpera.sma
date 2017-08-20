#include <amxmodx>
#include <fakemeta>
#include <codmod>
#include hamsandwich

new const perk_name[] = "Plaszcz Snajpera";
new const perk_desc[] = "Masz 13 widocznosci, kiedy sie nie ruszasz";

new bool:ma_perk[33];
new bool:b[33]

public plugin_init()
 {
	register_plugin(perk_name, "1.0", "sharkowy");
	
	cod_register_perk(perk_name, perk_desc);

	register_forward(FM_CmdStart, "CmdStart");
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_remove_user_rendering(id)
}

public fwSpawn_Grawitacja(id)
{
	if(ma_perk[id])
		cod_remove_user_rendering(id)
}

public CmdStart(id, uc)
{
	if(!ma_perk[id]) return;
	
	static Float:fmove, Float:smove;
	get_uc(uc, UC_ForwardMove, fmove);
	get_uc(uc, UC_SideMove, smove);
	
	if(fmove == 0.0 && smove == 0.0)
	{
		if(!b[id])
		{
			cod_set_user_rendering(id, 13)
			b[id] = true
		}
	}
	else
	{
		if(b[id])
		{
			cod_remove_user_rendering(id)
			b[id] = false
		}
	}
}