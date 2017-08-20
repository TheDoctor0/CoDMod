#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <cstrike>

new const perk_name[] = "Fach zlodzieja";
new const perk_desc[] = "Dostajesz UZI, 53 widocznosci na nim";
    
new bool:ma_perk[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "RiviT");

	cod_register_perk(perk_name, perk_desc);

	new const Nazwy_broni[][] = {
	"weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", 
	"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", 
	"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", 
	"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", 
	"weapon_ak47", "weapon_knife", "weapon_p90" }
	
      for(new i = 0; i < sizeof Nazwy_broni; i++)
            RegisterHam(Ham_Item_Deploy, Nazwy_broni[i], "fwHamItemDeploy", 1)
            
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	
	cod_give_weapon(id, CSW_MAC10)
}

public cod_perk_disabled(id)
{
    	ma_perk[id] = false;
	cod_take_weapon(id, CSW_MAC10)
	cod_remove_user_rendering(id)
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
	
	if(cs_get_weapon_id(ent) == CSW_MAC10)
		cod_set_user_rendering(id, 53)
	else
		cod_remove_user_rendering(id)
}