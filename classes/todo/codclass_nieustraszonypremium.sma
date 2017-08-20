#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
#include <hamsandwich>
        
new const nazwa[]   = "Nieustraszony (Premium) ";
new const opis[]    = "Dostaje M4 oraz 20 wiecej dmg, moze wykonac skok w powietrzu.na no¿u. 70/255";
new const bronie    = (1<<CSW_M4A1)|(1<<CSW_DEAGLE);
new const zdrowie   = 30;
new const kondycja  = 20;
new const inteligencja = 20;
new const wytrzymalosc = 30;
    
new skoki[33];

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
   
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

}

public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[Nieustraszony (Premium) ] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	ma_klase[id] = true;
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;

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
		skoki[id] = 1;

	return FMRES_IGNORED;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits) 
{ 
	if(!is_user_connected(idattacker)) 
		return HAM_IGNORED; 
	
	if(!ma_klase[idattacker]) 
		return HAM_IGNORED; 
	
	if(!(damagebits & (1<<1))) 
		return HAM_IGNORED; 
		
	if(get_user_weapon(idattacker) && CSW_M4A1)
	{
		damage+=20;
	}
	
	return HAM_IGNORED; 
}