#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
        
#define DMG_BULLET (1<<1)	

new const nazwa[]   = "Oficer (Premium)";
new const opis[]    = "Ma 1/3 z M3, posiada lekko grawitacje 550/800 i mo¿e wykonaæ 2 skoki w powietrzu. ";
new const bronie    = (1<<CSW_M3);
new const zdrowie   = -20;
new const kondycja  = 30;
new const inteligencja = 10;
new const wytrzymalosc = 20;
    
new skoki[33];

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);   
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

   
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}

 	entity_set_float(id, EV_FL_gravity, 550.0/800.0);
	ma_klase[id] = true;
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{

 	entity_set_float(id, EV_FL_gravity, 1.0);
	ma_klase[id] = false;

}

public fwSpawn_Grawitacja(id)
{
	if (ma_klase[id])
		entity_set_float(id, EV_FL_gravity, 550.0/800.0);
}


public fwCmdStart_MultiJump(id, uc_handle)
{
	if (!is_user_alive(id) || !ma_klase[id])
		return FMRES_IGNORED;

	new flags = pev(id, pev_flags);

	if ((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id])
	{
		skoki[id]--;
		new Float:velocity[3];
		pev(id, pev_velocity,velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity,velocity);
	}
	else if (flags & FL_ONGROUND)
		skoki[id] = 2;

	return FMRES_IGNORED;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if (!is_user_connected(idattacker))
                return HAM_IGNORED;
        
        if (!ma_klase[idattacker])
                return HAM_IGNORED;
        
        if (!(damagebits & DMG_BULLET))
                return HAM_IGNORED;
                
        if (get_user_weapon(idattacker) == CSW_M3 && random_num(1,3) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
