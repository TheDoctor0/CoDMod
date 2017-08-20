#include <amxmodx>
#include <engine>
#include <codmod>
#include hamsandwich

new sprite_blast;
new ma_perk[33];
new wartosc_perku[33];

#define DMG_BULLET (1<<1)

public plugin_init()
{
      new const nazwa[] = "Generator rakiet";
      new const opis[] = "1/LW szans na wypuszczenie rakiety po trafieniu w przeciwnika";

	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis, 4, 8);
	
      RegisterHam(Ham_TakeDamage, "player", "TakeDmg", 1)
	register_touch("rocket", "*" , "DotykRakiety");
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model("models/rpgrocket.mdl");
}

public cod_perk_enabled(id, wartosc)
{
      ma_perk[id] = true
      wartosc_perku[id] = wartosc
}

public cod_perk_disabled(id)
      ma_perk[id] = false
	
public TakeDmg(this, idinflictor, idattacker, Float:damage, dmgbits)
{	
	if(is_user_connected(idattacker) && get_user_team(this) != get_user_team(idattacker) && dmgbits & DMG_BULLET && ma_perk[idattacker] && !random(wartosc_perku[idattacker]))
	{
		new Float: Origin[3], Float: vAngle[3];
		
		entity_get_vector(idattacker, EV_VEC_v_angle, vAngle);
		entity_get_vector(idattacker, EV_VEC_origin , Origin);
	
		new Ent = create_entity("info_target");
	
		entity_set_string(Ent, EV_SZ_classname, "rocket");
		entity_set_model(Ent, "models/rpgrocket.mdl");
	
		vAngle[0] *= -1.0;
	
		entity_set_origin(Ent, Origin);
		entity_set_vector(Ent, EV_VEC_angles, vAngle);
	
		entity_set_int(Ent, EV_INT_effects, 2);
		entity_set_int(Ent, EV_INT_solid, SOLID_BBOX);
		entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY);
		entity_set_edict(Ent, EV_ENT_owner, idattacker);
	
		VelocityByAim(idattacker, 1000, vAngle);
		entity_set_vector(Ent, EV_VEC_velocity ,vAngle);
	}
}

public DotykRakiety(ent)
{
	if (!is_valid_ent(ent))
		return;

	new attacker = entity_get_edict(ent, EV_ENT_owner);

	new Float:fOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, fOrigin);	
	
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
	iOrigin[0] = find_sphere_class(ent, "player", 190.0, entlist, 32);
	
	for (new i=0; i < iOrigin[0]; i++)
	{
		if (!is_user_alive(entlist[i]) || get_user_team(attacker) == get_user_team(entlist[i]))
			continue;
		cod_inflict_damage(attacker, entlist[i], 55.0, 1.0, ent, (1<<24));
	}
	remove_entity(ent);
}