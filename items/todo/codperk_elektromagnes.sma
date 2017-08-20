#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

new const perk_name[] = "Elektromagnes";
new const perk_desc[] = "Co runde mozesz polozyc elektromagnes";
new bitsum_omin = ((1<<2)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_KNIFE)|(1<<CSW_C4))
new const Nazwy_broni[][] = {
	"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", 
	"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", 
	"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", 
	"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", 
	"weapon_ak47", "weapon_knife", "weapon_p90" }


new bool:wykorzystal[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	register_event("ResetHUD", "ResetHUD", "abe");

	cod_register_perk(perk_name, perk_desc);
	
	register_think("magnet","MagnetThink");
}

public plugin_precache()
{
	precache_model("models/QTM_CodMod/electromagnet.mdl");
	precache_sound("weapons/mine_charge.wav");
	precache_sound("weapons/mine_activate.wav");
	precache_sound("weapons/mine_deploy.wav");
}

public cod_perk_enabled(id)
	wykorzystal[id] = false

public cod_perk_used(id)
{
	if (wykorzystal[id])
	{
		client_print(id, print_center, "Wykorzystales juz elektromagnes!");
		return;
	}
	
	wykorzystal[id] = true
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	
	new ent = create_entity("info_target");
	entity_set_string(ent, EV_SZ_classname, "magnet");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	
	entity_set_model(ent, "models/QTM_CodMod/electromagnet.mdl");
	drop_to_floor(ent);
	
	emit_sound(ent, CHAN_VOICE, "weapons/mine_charge.wav", 0.5, ATTN_NORM, 0, PITCH_NORM );
	emit_sound(ent, CHAN_ITEM, "weapons/mine_deploy.wav", 0.5, ATTN_NORM, 0, PITCH_NORM );
	
	set_task(3.5, "sound", ent)
	
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 3.5);
}

public sound(ent)
	emit_sound(ent, CHAN_VOICE, "weapons/mine_activate.wav", 0.5, ATTN_NORM, 0, PITCH_NORM );

public ResetHUD(id)
	wykorzystal[id] = false

stock get_velocity_to_origin( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3] )
{
      new Float:fEntOrigin[3];
      entity_get_vector( ent, EV_VEC_origin, fEntOrigin );

      // Velocity = Distance / Time

      new Float:fDistance[3];
      fDistance[0] = fEntOrigin[0] - fOrigin[0];
      fDistance[1] = fEntOrigin[1] - fOrigin[1];
      fDistance[2] = fEntOrigin[2] - fOrigin[2];

      new Float:fTime = -( vector_distance( fEntOrigin,fOrigin ) / fSpeed );

      fVelocity[0] = fDistance[0] / fTime;
      fVelocity[1] = fDistance[1] / fTime;
      fVelocity[2] = fDistance[2] / fTime + 50.0;

      return ( fVelocity[0] && fVelocity[1] && fVelocity[2] );
}

stock set_velocity_to_origin( ent, Float:fOrigin[3], Float:fSpeed )
{
      new Float:fVelocity[3];
      get_velocity_to_origin( ent, fOrigin, fSpeed, fVelocity )

      entity_set_vector( ent, EV_VEC_velocity, fVelocity );
}

public MagnetThink(ent)
{
	static id, Float:forigin[3], entlist[33], numfound, i, n, pid, num, wpn[32]
	id = entity_get_edict(ent, EV_ENT_owner);
	numfound = find_sphere_class(ent, "player", 450.0, entlist, 32);
	
	num = 0
	
	for (i = 0; i < numfound; i++)
	{
		pid = entlist[i]
		if (!is_user_alive(pid) || get_user_team(pid) == get_user_team(id)) continue;
		
		get_user_weapons(pid, wpn, num)

		for(n = 1; n < num; n++)
		{
			if(1<<wpn[n] & bitsum_omin) continue;

			engclient_cmd(pid, "drop", Nazwy_broni[wpn[n]]);
		}
	}
	
	numfound = find_sphere_class(ent, "weaponbox", 550.0, entlist, 32);
	
	for (i = 0; i < numfound; i++)
		if(get_entity_distance(ent, entlist[i]) > 50.0)
		{
			entity_get_vector(ent, EV_VEC_origin, forigin);
			set_velocity_to_origin(entlist[i], forigin, 700.0);
		}

	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.2);
}