#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <fakemeta>
#include cstrike
        
new const nazwa[] = "Noz szpiega";
new const opis[] = "Masz 55 widocznosci na nozu, 1 skok w powietrzu.";
    
new bool:skoki[33],
bool:ma_perk[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "Play 4FuN");

	cod_register_perk(nazwa, opis);

	new const Nazwy_broni[][] = {
	"weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", 
	"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", 
	"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", 
	"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", 
	"weapon_ak47", "weapon_knife", "weapon_p90" }
	
      for(new i = 0; i < sizeof Nazwy_broni; i++)
            RegisterHam(Ham_Item_Deploy, Nazwy_broni[i], "fwHamItemDeploy", 1)
            
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
}

public cod_perk_enabled(id)
{
        ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	cod_remove_user_rendering(id)
    	ma_perk[id] = false;
}

public fwSpawn_Grawitacja(id)
{
	if(ma_perk[id])
		cod_remove_user_rendering(id)
}

#define m_pPlayer 41
public fwHamItemDeploy(ent)
{
	static id;
	id = get_pdata_cbase(ent, m_pPlayer, 4)
	
	if(!is_user_alive(id) || !ma_perk[id]) return;
	
	if(cs_get_weapon_id(ent) == CSW_KNIFE)
		cod_set_user_rendering(id, 55)
	else
		cod_remove_user_rendering(id)
}

public fwCmdStart_MultiJump(id, uc_handle)
{
	if(!is_user_alive(id) || !ma_perk[id])
		return FMRES_IGNORED;

	new flags = pev(id, pev_flags);

	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id])
	{
		skoki[id] = false;
		new Float:velocity[3];
		pev(id, pev_velocity, velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity,velocity);
	}
	else if(flags & FL_ONGROUND)
		skoki[id] = true;

	return FMRES_IGNORED;
}
