/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
        
#define DMG_BULLET (1<<1)
	
new const perk_name[] = "Tajemnica snajpera";
new const perk_desc[] = "Ma 1/1 z AWP i podczas kucania z nim jego widocznosc wynosi LW";
    
new bool:ma_perk[33], wartosc_perku[33]

public plugin_init()
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");

	cod_register_perk(perk_name, perk_desc, 50, 100);

	register_forward(FM_PlayerPreThink, "fwPrethink_Niewidzialnosc", 1);

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_AWP)
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
    	ma_perk[id] = false;
	cod_take_weapon(id, CSW_AWP)
}

public fwPrethink_Niewidzialnosc(id, idattacker)
{
	if(!ma_perk[id])
		return;

	new button = get_user_button(id);
	if( button & IN_DUCK && get_user_weapon(id) == CSW_AWP)
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, wartosc_perku[idattacker]);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if(!is_user_connected(idattacker))
                return HAM_IGNORED;
        
        if(!ma_perk[idattacker])
                return HAM_IGNORED;
        
        if(!(damagebits & DMG_BULLET))
                return HAM_IGNORED;
                
        if(get_user_weapon(idattacker) == CSW_SCOUT && random_num(1,1) == 1)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
