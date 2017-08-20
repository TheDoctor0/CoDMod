#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <codmod>
#include engine

new bool:ma_perk[33];

new const max_clip[31] = { -1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 10,  30, 100,  8, 30,  30, 20,  2,  7, 30, 30, -1,  50 };

public plugin_init()
{
	new const nazwa[] = "Zwinne Palce";
	new const opis[] = "Natychmiastowe przeladowanie po wcisnieciu reloadu";

	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);

	register_forward(FM_CmdStart, "CmdStart");
}

public cod_perk_enabled(id)
{
	cod_user_fast_reload(id, true) //zobacz w silniku na funkcje od tego natywu
	ma_perk[id] = true;
}
	
public cod_perk_disabled(id)
{
	cod_user_fast_reload(id, false)
	ma_perk[id] = false;
}

public CmdStart(id, uc_handle)
{
	if(!is_user_alive(id) || !ma_perk[id]) return FMRES_IGNORED;
	
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(max_clip[weapon] == -1 || !ammo || clip == max_clip[weapon]) return FMRES_IGNORED;
	
	new buttons = get_uc(uc_handle, UC_Buttons);

	if((buttons & IN_RELOAD && !(pev(id, pev_oldbuttons) & IN_RELOAD) && !(buttons & IN_ATTACK)))
	{
		new weaponname[20];
		get_weaponname(weapon, weaponname, 19);

		new ent;
		while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", weaponname)) != 0)
		{
			if(id == pev(ent, pev_owner))
			{
				cs_set_user_bpammo(id, weapon, max(ammo - (max_clip[weapon] - clip), 0))
				set_pdata_int(ent, 51, ((max_clip[weapon] > ammo) ? clip + ammo : max_clip[weapon]), 4);
				break;
			}
		}
	}
	
	return FMRES_IGNORED;
}