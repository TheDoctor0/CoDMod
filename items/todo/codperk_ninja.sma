#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <codmod>
#include cstrike

#define DMG_BULLET (1<<1) 

new const perk_name[] = "Ninja"
new const perk_desc[] = "+30 kondychy, podwojny skok, na nozu 80 widocznosci, o 40(+int) dmg wiecej z noza"

new bool:ma_perk[33], bool:skoki[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT")
	
	cod_register_perk(perk_name, perk_desc)
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage")
	
	new const Nazwy_broni[][] = {
	"weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", 
	"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", 
	"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", 
	"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", 
	"weapon_ak47", "weapon_knife", "weapon_p90" }
	
      for(new i = 0; i < sizeof Nazwy_broni; i++)
            RegisterHam(Ham_Item_Deploy, Nazwy_broni[i], "fwHamItemDeploy", 1)
            
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

	register_forward(FM_CmdStart, "CmdStart");
}


public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_add_user_bonus_trim(id, 30)
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	entity_set_float(id, EV_FL_gravity, 1.0);
	cod_remove_user_rendering(id)
	cod_add_user_bonus_trim(id, -30);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
		
	if(get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET)
	{
		SetHamParamFloat(4, damage+40.0+cod_get_user_intelligence(idattacker, 1, 1, 1))
		return HAM_HANDLED
      }
		
	return HAM_IGNORED;
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
		cod_set_user_rendering(id, 80)
	else
		cod_remove_user_rendering(id)
}

public CmdStart(id, uc_handle)
{
        if(!is_user_alive(id) || !ma_perk[id])
                return FMRES_IGNORED;
        
        new flags = pev(id, pev_flags);
        
        if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id])
        {
                skoki[id] = false
                new Float:velocity[3];
                pev(id, pev_velocity,velocity);
                velocity[2] = random_float(265.0,285.0);
                set_pev(id, pev_velocity,velocity);
        }
        else if(flags & FL_ONGROUND)
                skoki[id] = true;
        
        return FMRES_IGNORED;
}