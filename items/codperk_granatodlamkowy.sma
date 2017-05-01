#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>
#include <codmod>

#define ODLAMKI 6
#define DAMAGE 40.0
#define DAMAGE_INT 0.1

new const perk_name[] = "Granat Odlamkowy";
new const perk_desc[] = "Posiadasz 2 granaty odlamkowe, ktory rozpadaja sie na kilka odlamkow zadajacych 40(+int) dmg";

new sprite_blast;
new bool: ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone")
	
	cod_register_perk(perk_name, perk_desc)
	
	register_forward(FM_SetModel, "fw_SetModel");
	
	RegisterHam(Ham_Think,"grenade","ham_grenade_think",0);
	
	register_touch("fragmentation nade", "*", "fragmentation_nade_touch")
	
	RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "ItemDeploy", 1);
	
	register_event("ResetHUD", "ResetHUD", "abe");
}
public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_HEGRENADE);
	set_task(0.1, "Granaty", id);
}
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_take_weapon(id, CSW_HEGRENADE);
	cs_set_user_bpammo(id, CSW_HEGRENADE, 0);
}
public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model("models/QTM_CodMod/v_hegrenade.mdl");
	precache_model("models/QTM_CodMod/w_hegrenade.mdl");
	precache_model("models/QTM_CodMod/p_hegrenade.mdl");
	precache_model("models/QTM_CodMod/fragment.mdl");
}

public ItemDeploy(wpn){
	static id;
	id = pev(wpn,pev_owner);
	if(is_user_alive(id) && ma_perk[id]){
		set_pev(id, pev_viewmodel2, "models/QTM_CodMod/v_hegrenade.mdl")
		set_pev(id, pev_weaponmodel2, "models/QTM_CodMod/p_hegrenade.mdl")
	}
}
public ham_grenade_think(ent)
{
	new models[34]
	if(!pev_valid(ent)) 
		return HAM_IGNORED;	
	
	entity_get_string(ent, EV_SZ_model, models, 33)
	if(!equali(models, "models/QTM_CodMod/w_hegrenade.mdl")) 
		return HAM_IGNORED
	
	new Float:damagetime;
	pev(ent,pev_dmgtime,damagetime);
	damagetime+=0.1
	if(damagetime > get_gametime()) 
		return HAM_IGNORED;
		
	fragmentation_explode(ent);
	
	return HAM_IGNORED
}

public fragmentation_explode(ent)
{
	new id = pev(ent,pev_owner);
	
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	if(!ma_perk[id])
		return PLUGIN_CONTINUE;
	
	new Float:origin[3];
		
	pev(ent, pev_origin, origin);
	
	for(new i=1; i <= ODLAMKI; i++)
	{	
		new ent = fm_create_entity("info_target");
		set_pev(ent, pev_classname, "fragmentation nade");
		set_pev(ent, pev_owner, id);
		set_pev(ent, pev_movetype, MOVETYPE_TOSS);
		set_pev(ent, pev_origin, origin);
		set_pev(ent, pev_solid, SOLID_BBOX);
		engfunc(EngFunc_SetModel, ent, "models/QTM_CodMod/fragment.mdl");
		
		new Float:fVelocity[3];
		
		fVelocity[0] = floatsin(360.0/ODLAMKI*i, degrees)*200.0;
		fVelocity[1] = floatcos(360.0/ODLAMKI*i, degrees)*200.0;
		fVelocity[2] = 100.0
		
		set_pev(ent, pev_velocity, fVelocity);
		set_pev(ent, pev_gravity,  1.0);
	}
	
	return PLUGIN_CONTINUE
}	

public fragmentation_nade_touch(ent)
{
	if (!is_valid_ent(ent))
		return;

	new attacker = entity_get_edict(ent, EV_ENT_owner);
	

	new Float:fOrigin[3];
	pev(ent, pev_origin, fOrigin);	
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32); 
	write_byte(20); 
	write_byte(0);
	message_end();

	new entlist[33];
	new numfound = find_sphere_class(ent, "player", 120.0, entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if(!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid))
			continue;
			
		cod_inflict_damage(attacker, pid, DAMAGE, DAMAGE_INT, ent, (1<<24));
	}
	remove_entity(ent);
}		

public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity)) 
		return FMRES_IGNORED

	if(!equali(model, "models/w_hegrenade.mdl"))
		return FMRES_IGNORED;

	new entityowner = pev(entity, pev_owner);
        
	if(!ma_perk[entityowner])
		return FMRES_IGNORED;

	engfunc(EngFunc_SetModel, entity, "models/QTM_CodMod/w_hegrenade.mdl") 
	
	return FMRES_SUPERCEDE
}

public ResetHUD(id)
	set_task(0.1, "Granaty", id);
	
public Granaty(id)
{
	if(!is_user_alive(id)) 
		return;

	if(!ma_perk[id]) 
		return;
		
	cod_give_weapon(id, CSW_HEGRENADE);
	cs_set_user_bpammo(id, CSW_HEGRENADE, 2);
}
