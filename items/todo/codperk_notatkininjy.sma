#include <amxmodx>
#include <fakemeta>
#include <codmod>

new const nazwa[] = "Notatki Ninji";
new const opis[] = "Mozesz wykonac SW skok w powietrzu";

new wartosc_perku[33] = 0;
new bool:ma_perk[33];
new ma_skok[33];

public plugin_init()
 {
	register_plugin(nazwa, "1.0", "O'Zone");
	
	cod_register_perk(nazwa, opis, 1, 1);
	
	register_forward(FM_CmdStart, "CmdStart");
}

public cod_perk_enabled(id, wartosc)
{
	if(cod_get_user_class(id) == cod_get_classid("Admiral"))
		return COD_STOP;	
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	ma_skok[id] = wartosc_perku[id];
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public CmdStart(id, uc_handle)
{
	if(!is_user_alive(id) || !ma_perk[id])
		return FMRES_IGNORED;
	
	new flags = pev(id, pev_flags);
	
	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && ma_skok[id]>0)
	{
			ma_skok[id]--;
			new Float:velocity[3];
			pev(id, pev_velocity,velocity);
			velocity[2] = random_float(265.0,285.0);
			set_pev(id, pev_velocity,velocity);
	}
	else if(flags & FL_ONGROUND)
		ma_skok[id] = wartosc_perku[id];
		
	return FMRES_IGNORED;
}
