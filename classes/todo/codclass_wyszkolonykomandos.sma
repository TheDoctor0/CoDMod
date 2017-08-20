#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <fun>
        
#define DMG_HEGRENADE (1<<24)
	
new const nazwa[]   = "Wyszkolony Komandos";
new const opis[]    = "1/1 z kosy PPM, 1/4 z HE, mo¿e wykonaæ skok w powietrzu, zmniejszona widocznoœæ do 200";
new const bronie    = (1<<CSW_MAC10)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_DEAGLE);
new const zdrowie   = 40;
new const kondycja  = 50;
new const inteligencja = 10;
new const wytrzymalosc = 25;
    
new skoki[33];

new ostatnio_prawym[33];

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
   
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");


	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage_JedenCios");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fwPrimaryAttack_JedenCios");
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fwSecondaryAttack_JedenCios");
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

}

public cod_class_enabled(id)
{

	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 200);
	give_item(id, "weapon_smokegrenade");
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
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

public fwTakeDamage_JedenCios(id, ent, attacker)
{
	if(is_user_alive(attacker) && ma_klase[attacker] && get_user_weapon(attacker) == CSW_KNIFE && ostatnio_prawym[id])
	{
		cs_set_user_armor(id, 0, CS_ARMOR_NONE);
		SetHamParamFloat(4, float(get_user_health(id) + 1));
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}

public fwPrimaryAttack_JedenCios(ent)
{
	new id = pev(ent, pev_owner);
	ostatnio_prawym[id] = 1;
}

public fwSecondaryAttack_JedenCios(ent)
{
	new id = pev(ent, pev_owner);
	ostatnio_prawym[id] = 0;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if(!is_user_connected(idattacker))
                return HAM_IGNORED;

        if(!ma_klase[idattacker])
                return HAM_IGNORED;

        if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_HEGRENADE && damagebits & DMG_HEGRENADE && random_num(1,4) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
