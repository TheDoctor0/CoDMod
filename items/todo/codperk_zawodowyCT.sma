#include <amxmodx>
#include <codmod>
#include <cstrike>
#include <fakemeta>
#include hamsandwich

new const nazwa[] = "Zawodowy CT";
new const opis[] = "Masz 2FB, defuser, FiveSeven, 0 rozrzutu na nim, +2k expa za frag z niego";

new bool:ma_perk[33]

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);
	
	register_forward(FM_PlayerPreThink, "PreThink");
	register_forward(FM_UpdateClientData, "UpdateClientData", 1)
	
      register_event("DeathMsg", "deathmsg", "a")
      RegisterHam(Ham_Spawn, "player", "fwSpawn_Rakiety", 1);
}

public cod_perk_enabled(id)
{
	if(get_user_team(id) == 1)
		return COD_STOP;
	
	cod_give_weapon(id, CSW_FLASHBANG)
	cod_give_weapon(id, CSW_FIVESEVEN)
	cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
	cs_set_user_defuse(id, 1);
	
	ma_perk[id] = true
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_FLASHBANG)
	cod_take_weapon(id, CSW_FIVESEVEN)
	cs_set_user_defuse(id, 0);
	
	ma_perk[id] = false
}

public PreThink(id)
{
	if(ma_perk[id] && get_user_weapon(id) == CSW_FIVESEVEN)
		set_pev(id, pev_punchangle, {0.0,0.0,0.0})
}

public UpdateClientData(id, sw, cd_handle)
{
	if(ma_perk[id] && get_user_weapon(id) == CSW_FIVESEVEN)
		set_cd(cd_handle, CD_PunchAngle, {0.0,0.0,0.0})   
}

public fwSpawn_Rakiety(id)
{
      if(ma_perk[id])
            cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
}

public deathmsg()
{
      new kid = read_data(1)
	if(is_user_connected(kid) && ma_perk[kid])
	{
            new weaponname[33];
            read_data(4, weaponname, 32)
            if(equal(weaponname, "fiveseven"))
                  cod_add_user_xp(kid, 2000);
      }
}