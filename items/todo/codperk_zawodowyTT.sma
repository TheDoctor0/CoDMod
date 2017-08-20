#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <fun>

new const nazwa[] = "Zawodowy TT";
new const opis[] = "Masz glocka, za frag z niego +2k expa, 0 rozrzutu na nim, ciche kroki";

new bool:ma_perk[33]

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);
	
	register_forward(FM_PlayerPreThink, "PreThink");
	register_forward(FM_UpdateClientData, "UpdateClientData", 1)
	
	register_event("DeathMsg", "deathmsg", "a")
}

public cod_perk_enabled(id)
{
	if(get_user_team(id) == 2)
		return COD_STOP;
	
	cod_give_weapon(id, CSW_GLOCK18)
	set_user_footsteps(id, 1);
	
	ma_perk[id] = true
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_GLOCK18)
	set_user_footsteps(id, 0);
	ma_perk[id] = false
}

public PreThink(id)
{
	if(ma_perk[id] && get_user_weapon(id) == CSW_GLOCK18)
		set_pev(id, pev_punchangle, {0.0,0.0,0.0})
}

public UpdateClientData(id, sw, cd_handle)
{
	if(ma_perk[id] && get_user_weapon(id) == CSW_GLOCK18)
		set_cd(cd_handle, CD_PunchAngle, {0.0,0.0,0.0})   
}

public deathmsg()
{
      new kid = read_data(1)
	if(is_user_connected(kid) && ma_perk[kid])
	{
            new weaponname[33];
            read_data(4, weaponname, 32)
            if(equal(weaponname, "glock"))
                  cod_add_user_xp(kid, 2000);
      }
}