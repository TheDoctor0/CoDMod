#include <amxmodx>
#include <codmod>
#include <engine>
#include cstrike
#include <hamsandwich>
        
new const nazwa[]   = "Kapral [P]";
new const opis[]    = "Ma 2 rakiety, 70 widocznosci na nozu";
new const bronie    = (1<<CSW_USP)|(1<<CSW_FLASHBANG)|(1<<CSW_SG552);
new const zdrowie   = 5;
new const kondycja  = -30;
new const inteligencja = -10;
new const wytrzymalosc = 10;
    
new sprite_blast, ilosc_rakiet_gracza[33], poprzednia_rakieta_gracza[33], bool:ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Premium");

	register_touch("rocket", "*" , "DotykRakiety");

	RegisterHam(Ham_Spawn, "player", "fwSpawn_Rakiety", 1);
	new const Nazwy_broni[][] = {
	"weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", 
	"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", 
	"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", 
	"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", 
	"weapon_ak47", "weapon_knife", "weapon_p90" }
	
      for(new i = 0; i < sizeof Nazwy_broni; i++)
            RegisterHam(Ham_Item_Deploy, Nazwy_broni[i], "fwHamItemDeploy", 1)
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model("models/rpgrocket.mdl");
}

public cod_class_enabled(id)
{
	if(!(cod_get_user_status(id) & STATUS_PREMIUM))
	{
		client_print(id, print_chat, "[%s] Nie masz premium, zeby grac ta klasa!", nazwa)
		return COD_STOP;
	}

	ilosc_rakiet_gracza[id] =2;
	ma_klase[id] = true
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
      cod_remove_user_rendering(id)
      ma_klase[id] = false
}

public cod_class_skill_used(id)
{
	if (!ilosc_rakiet_gracza[id])
		client_print(id, print_center, "Wykorzystales juz wszystkie rakiety!");
		
	else
	{
		if(poprzednia_rakieta_gracza[id] + 2.0 > get_gametime())
			client_print(id, print_center, "Rakiet mozesz uzywac co 2 sekundy!");

		else
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
		cod_remove_user_rendering(id)
		ilosc_rakiet_gracza[id] = 2;
	}
}

public DotykRakiety(ent)
{
	if (!is_valid_ent(ent))
		return;

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
      new attacker = entity_get_edict(ent, EV_ENT_owner);

	for (new i=0; i < iOrigin[0]; i++)
	{
		if (!is_user_alive(entlist[i]) || get_user_team(attacker) == get_user_team(entlist[i]))
			continue;
            
		cod_inflict_damage(attacker, entlist[i], 55.0, 1.0, ent, (1<<24));
	}
	remove_entity(ent);
}

#define m_pPlayer 41
public fwHamItemDeploy(ent)
{
	static id;
	id = get_pdata_cbase(ent, m_pPlayer, 4)
	
	if(!is_user_alive(id) || !ma_klase[id]) return;
	
	if(cs_get_weapon_id(ent) == CSW_KNIFE)
		cod_set_user_rendering(id, 70)
	else
		cod_remove_user_rendering(id)
}