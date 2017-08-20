#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fakemeta_util> 
#include <hamsandwich>
#include <cstrike>

new bool:ma_perk[33];
new bool:zamrozenie[33];

new player_b_smokehit[33] = 0

public plugin_init()
{
	register_plugin( "Frostnade", "1.0", "GoldenKill" );
	cod_register_perk( "Frostnade", "Posiadasz 2 granaty zamrazajace" );
	register_event("SendAudio","eventGrenade","bc","2=%!MRAD_FIREINHOLE")
	register_event("ResetHUD", "ResetHUD", "abe");
}
public cod_perk_enabled( id )
{
	ma_perk[ id ] = true;
	player_b_smokehit[id] = 1
	cod_give_weapon(id, CSW_SMOKEGRENADE);
}

public cod_perk_disabled( id )
{
	ma_perk[ id ] = false;
	player_b_smokehit[id] = 0
	cod_take_weapon(id, CSW_SMOKEGRENADE);
}

public ResetHUD(id)

	set_task(0.1, "ResetHUDx", id);

	

public ResetHUDx(id)
{
	if(!is_user_connected(id)) return;	

	if(!ma_perk[id]) return;

	cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 2);
}

public pfn_touch ( ptr, ptd )
{	
	if (ptd == 0)
		return PLUGIN_CONTINUE

	if(!is_valid_ent(ptd))
	        return PLUGIN_CONTINUE
		
	new szClassName[32]
	entity_get_string(ptd, EV_SZ_classname, szClassName, 31)
	
	if (ptr != 0)
	{
                if(!is_valid_ent(ptr))
	                return PLUGIN_CONTINUE

		new szClassNameOther[32]
		entity_get_string(ptr, EV_SZ_classname, szClassNameOther, 31)
		
		if(equal(szClassName, "grenade") && equal(szClassNameOther, "player"))
		{
			new greModel[64]
			entity_get_string(ptd, EV_SZ_model, greModel, 63)
			
			if(equali(greModel, "models/w_smokegrenade.mdl" ))	
			{
				new id = entity_get_edict(ptd,EV_ENT_owner)
				
				if (is_user_connected(id) 
				&& is_user_alive(id) 
				&& is_user_connected(ptr) 
				&& is_user_alive(ptr) 
				&& player_b_smokehit[id] > 0
				&& get_user_team(id) != get_user_team(ptr))
				UTIL_Kill(id,ptr,"world")
			}
			
			
		}
		
	}
	
	return PLUGIN_CONTINUE
}

public UTIL_Kill(attacker,id,weapon[])
{
	if(!is_user_connected(attacker))
		return PLUGIN_CONTINUE
		
	if(ma_perk[attacker] && !zamrozenie[id])
        {
		fm_set_rendering(id, kRenderFxGlowShell, 0,0,255, kRenderGlow, 130)
		zamrozenie[id] = true
		set_pev(id, pev_flags, FL_FROZEN)
		set_task(5.0, "Odmroz", id)
	}
	if(zamrozenie[id])
		return HAM_SUPERCEDE
		
	return PLUGIN_HANDLED
	
}
public eventGrenade(id) 
{
	new id = read_data(1)
	if (player_b_smokehit[id] > 0)
	{
		set_task(0.1, "makeGlow", id)
	}
}

public makeGlow(id) 
{
	new grenade
	new greModel[100]
	grenade = get_grenade(id) 
	
	if( grenade ) 
	{	
		entity_get_string(grenade, EV_SZ_model, greModel, 99)

		if(equali(greModel, "models/w_smokegrenade.mdl" ))	
		{
			set_rendering(grenade, kRenderFxGlowShell, 0,255,255, kRenderNormal, 255)
		}
	}
}