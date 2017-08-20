#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include fakemeta_util
#include cstrike

new const nazwa[]   = "Stalker [SP]";
new const opis[]    = "Ma 2 rakiety, 1/6 na wyrzucenie broni przeciwnika, +(0.2*int)dmg z USP";
new const bronie    = (1<<CSW_USP)|(1<<CSW_M4A1)|(1<<CSW_FLASHBANG)|(1<<CSW_HEGRENADE);
new const zdrowie   = 35;
new const kondycja  = 15;
new const inteligencja = 15;
new const wytrzymalosc = 30;

new sprite_blast, ilosc_rakiet_gracza[33], poprzednia_rakieta_gracza[33], bool:ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Super Premium");
	
	register_touch("rocket", "*" , "DotykRakiety");

	RegisterHam(Ham_Spawn, "player", "fwSpawn_Rakiety", 1);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model("models/rpgrocket.mdl");
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(idattacker) == get_user_team(this))
            return HAM_IGNORED;

	if(!ma_klase[idattacker])
            return HAM_IGNORED;

      if(!random(6))
      {
            new wpnname[33]
            get_weaponname(get_user_weapon(this), wpnname, charsmax(wpnname))
		engclient_cmd(this, "drop", wpnname);
      }
	
	if(get_user_weapon(idattacker) == CSW_USP && damagebits & DMG_BULLET)
	{
            SetHamParamFloat(4, damage+(0.2*cod_get_user_intelligence(idattacker, 1, 1, 1)))
            return HAM_HANDLED
      }

	return HAM_IGNORED;
}

public cod_class_enabled(id)
{
	if(!(cod_get_user_status(id) & STATUS_SPREMIUM))
	{
		client_print(id, print_chat, "[%s] Nie masz super premium, zeby grac ta klasa!", nazwa)
		return COD_STOP;
	}

	ma_klase[id] = true;

	set_task(0.2, "fwSpawn_Rakiety", id)
	
	return COD_CONTINUE
}

public cod_class_disabled(id)
	ma_klase[id] = false;

public cod_class_skill_used(id)
{
	if (!ilosc_rakiet_gracza[id])
		client_print(id, print_center, "Wykorzystales juz wszystkie rakiety!");
	else
	{
		if(poprzednia_rakieta_gracza[id] + 0.5 < get_gametime())
		{
				poprzednia_rakieta_gracza[id] = floatround(get_gametime());
				ilosc_rakiet_gracza[id]--;

				new Float: Origin[3], Float: vAngle[3]

				entity_get_vector(id, EV_VEC_v_angle, vAngle);
				entity_get_vector(id, EV_VEC_origin , Origin);

				new Ent = create_entity("info_target");

				entity_set_string(Ent, EV_SZ_classname, "rocket");
				entity_set_model(Ent, "models/rpgrocket.mdl");

				vAngle[0] *= -1.0;

				entity_set_origin(Ent, Origin);
				entity_set_vector(Ent, EV_VEC_angles, vAngle);

				entity_set_int(Ent, EV_INT_effects, 2);
				entity_set_int(Ent, EV_INT_solid, SOLID_BBOX);
				entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY);
				entity_set_edict(Ent, EV_ENT_owner, id);

				VelocityByAim(id, 1000 , vAngle);
				entity_set_vector(Ent, EV_VEC_velocity ,vAngle);
            }
	}
}

public fwSpawn_Rakiety(id)
{
      if(ma_klase[id])
      {
            ilosc_rakiet_gracza[id] = 2;
            cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
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
		cod_inflict_damage(attacker, entlist[i], 55.0, 0.9, ent, (1<<24));
	}
	remove_entity(ent);
}