/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Zloty deagle";
new const perk_desc[] = "Dostajesz zlotego deagle'a oraz + 20dmg z niego";

new bool:ma_perk[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem")
	cod_register_perk(perk_name, perk_desc);
	
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
	
	register_forward(FM_SetModel, "fw_SetModel");
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_DEAGLE);
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_DEAGLE);
	ma_perk[id] = false;
}

public plugin_precache()
{
	precache_model("models/zlote_bronie/w_deagle.mdl");
	precache_model("models/zlote_bronie/p_deagle.mdl");
	precache_model("models/zlote_bronie/v_deagle.mdl");
}

public CurWeapon(id)
{
	new weapon = read_data(2);
	if(ma_perk[id])
	{
	if(weapon == CSW_DEAGLE)
	{
	set_pev(id, pev_viewmodel2, "models/zlote_bronie/v_deagle.mdl")
	set_pev(id, pev_weaponmodel2, "models/zlote_bronie/p_deagle.mdl")
	}
	}
}

public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity))
	return FMRES_IGNORED
	
	if(!equali(model, "models/w_deagle.mdl"))
	return FMRES_IGNORED;
	
	new entityowner = pev(entity, pev_owner);
	if(!ma_perk[entityowner])
	return FMRES_IGNORED;
	
	engfunc(EngFunc_SetModel, entity, "models/zlote_bronie/w_deagle.mdl")
	return FMRES_SUPERCEDE
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_DEAGLE && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 20.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1250\\ deff0\\ deflang1045{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
