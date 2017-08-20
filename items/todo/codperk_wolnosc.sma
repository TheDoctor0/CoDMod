#include <amxmodx>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
	
new const perk_name[] = "Wolnosc";
new const perk_desc[] = "Masz 350 gravity, podwojny skok, +30 kondychy, 1/20 na dostanie 2000exp za fraga";
    
new ma_perk[33], bool:skoki[33];

public plugin_init()
{
      register_plugin(perk_name, "1.0", "RiviT");

      cod_register_perk(perk_name, perk_desc);
      
      register_event("DeathMsg", "Death", "ade");

      RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

      register_forward(FM_CmdStart, "CmdStart");
}

public cod_perk_enabled(id)
{
      ma_perk[id] = true;
      entity_set_float(id, EV_FL_gravity, 350.0/800.0);
      cod_add_user_bonus_trim(id, 30);

      return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
    	ma_perk[id] = false;
	entity_set_float(id, EV_FL_gravity, 1.0);
	cod_add_user_bonus_trim(id, -30);
}

public fwSpawn_Grawitacja(id)
{
	if(ma_perk[id])
		entity_set_float(id, EV_FL_gravity, 350.0/800.0);
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

public Death(id)
{
	new attacker = read_data(1);

	if(!is_user_connected(attacker) ||get_user_team(id) == get_user_team(attacker))
		return PLUGIN_CONTINUE;
	
	if(!ma_perk[attacker])
		return PLUGIN_CONTINUE;
		
      if(!random(20))
      {
            cod_add_user_xp(attacker, 2000);
            client_print(attacker, print_center, "Dostales 2000 expa za frag!")
      }
	
	return PLUGIN_CONTINUE;
}