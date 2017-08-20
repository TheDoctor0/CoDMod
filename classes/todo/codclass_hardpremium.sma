#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
 
#define DMG_BULLET (1<<1)
        
new const nazwa[]   = "HardPremium";
new const opis[]    = "Na no¿u widocznoœæ spada do 20 , DMG z mp5 +30, 2 skoki w powietrzu.";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_FAMAS)|(1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE);
new const zdrowie   = 60;
new const kondycja  = 60;
new const inteligencja = 0;
new const wytrzymalosc = 30;
    
new skoki[33];

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_event("CurWeapon", "eventKnife_Niewidzialnosc", "be", "1=1");

   
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

}

public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_E))
	{
		client_print(id, print_chat, "[HardPremium] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	give_item(id, "weapon_hegrenade");
	ma_klase[id] = true;
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
    	ma_klase[id] = false;

}

public eventKnife_Niewidzialnosc(id)
{
	if(!ma_klase[id])
		return;

	if( read_data(2) == CSW_KNIFE )
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 20);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}

public fwCmdStart_MultiJump(id, uc_handle)
{
	if(!is_user_alive(id) || !ma_klase[id])
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
		skoki[id] = 2;

	return FMRES_IGNORED;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if(!is_user_connected(idattacker))
                return HAM_IGNORED;
        
        if(!ma_klase[idattacker])
                return HAM_IGNORED;
        
        if(damagebits & DMG_BULLET)
        {
                new weapon = get_user_weapon(idattacker);
                        
                if(weapon == CSW_MP5NAVY)
                        cod_inflict_damage(idattacker, this, 30.0, 0.0, idinflictor, damagebits);
        }
        
        return HAM_IGNORED;
}
