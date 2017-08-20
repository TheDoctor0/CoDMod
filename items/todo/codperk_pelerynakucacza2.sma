#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <engine>
#include hamsandwich

new bool:ma_perk[33], bool:b[33];

public plugin_init()
{
	new nazwa[] = "Peleryna Kucacza"
	new opis[] = "Twoja widocznosc spada do 50 gdy kucasz"
	register_plugin(nazwa, "1.0", "Vasto_Lorde");

	cod_register_perk(nazwa, opis);
	
	register_forward(FM_CmdStart, "CmdStart");
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);
}

public cod_perk_enabled(id, wartosc)
	ma_perk[id]=true;

public cod_perk_disabled(id)
{
	cod_remove_user_rendering(id)
	ma_perk[id]=false;
}

public CmdStart(id, uc)
{
	if(!ma_perk[id])
		return;

	if(get_uc(uc, UC_Buttons) & IN_DUCK)
	{
		if(!b[id])
		{
			cod_set_user_rendering(id, 50)
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

public fwSpawn_Grawitacja(id)
{
	if(ma_perk[id])
		cod_remove_user_rendering(id)
}
