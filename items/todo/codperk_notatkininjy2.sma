#include <amxmodx>
#include <fakemeta>
#include <codmod>

new const nazwa[] = "Notatki Ninji";
new const opis[] = "Mozesz wykonac 20 skokow w powierzu";

new bool:ma_perk[33],
skoki[33];

public plugin_init()
 {
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);
	
	register_forward(FM_CmdStart, "CmdStart");
}

public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
	ma_perk[id] = false;

public CmdStart(id, uc_handle)
{
        if(!is_user_alive(id) || !ma_perk[id])
                return FMRES_IGNORED;
        
        new flags = pev(id, pev_flags);
        
        if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id])
        {
                skoki[id]--;
                new Float:velocity[3];
                pev(id, pev_velocity,velocity);
                velocity[2] = random_float(265.0,285.0);
                set_pev(id, pev_velocity,velocity);
        }
        else if(flags & FL_ONGROUND)
                skoki[id] = 19; //tutaj podajemy iloœæ skokow w powietrzu
        
        return FMRES_IGNORED;
}