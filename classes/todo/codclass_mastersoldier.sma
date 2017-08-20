#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>

static const g_szWpnEntNames[] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
"weapon_ak47", "weapon_knife", "weapon_p90" }
        
new const nazwa[]   = "MasterSoldier";
new const opis[]    = "Ma 1/5 na wyrzucenie broni, 3 miny, widzi niewidzialnych, no recoil, 2x wieksza szybkostrzelnosc.";
new const bronie    = (1<<CSW_AUG)|(1<<CSW_SG552)|(1<<CSW_AK47);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;
    
new const modelMiny[] = "models/QTM_CodMod/mine.mdl"

new sprite_blast_miny;
new ilosc_min_gracza[33];

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_touch("mine", "player",  "DotykMiny");

	register_event("HLTV", "NowaRunda_Miny", "a", "1=0", "2=0");

	RegisterHam(Ham_Spawn, "player", "fwSpawn_Miny", 1);


	register_event("Damage", "Damage_Wyrzucenie", "b", "2!=0");
	register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1)
	register_forward(FM_PlayerPreThink, "PreThink");
	register_forward(FM_UpdateClientData, "UpdateClientData", 1)
	register_event("CurWeapon","CurWeapon","be", "1=1");

}

public plugin_precache()
{

	precache_model(modelMiny);
	sprite_blast_miny = precache_model("sprites/dexplo.spr");

}

public client_disconnect(id)
{

	new entMiny = find_ent_by_class(0, "mine");
	while(entMiny > 0)
	{
		if(entity_get_edict(entMiny, EV_ENT_owner) == id)
			remove_entity(entMiny);
		entMiny = find_ent_by_class(entMiny, "mine");
	}

}

public cod_class_enabled(id)
{

	ilosc_min_gracza[id] = 3;
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
	ma_klase[id] = false;

}

public cod_class_skill_used(id)
{
        
	if (!ilosc_min_gracza[id])
	{
		client_print(id, print_center, "Wykorzystales juz wszystkie miny!");
	}
	else
	{

		ilosc_min_gracza[id]--;

		new Float:origin[3];
		entity_get_vector(id, EV_VEC_origin, origin);

		new ent = create_entity("info_target");
		entity_set_string(ent ,EV_SZ_classname, "mine");
		entity_set_edict(ent ,EV_ENT_owner, id);
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
		entity_set_origin(ent, origin);
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);

		entity_set_model(ent, modelMiny);
		entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});

		drop_to_floor(ent);

		set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,50);
	}
}

public fwSpawn_Miny(id)
{
	if(is_user_alive(id))
		ilosc_min_gracza[id] = 3;
}

public DotykMiny(ent, id)
{
	if(!is_valid_ent(ent))
		return;

	new attacker = entity_get_edict(ent, EV_ENT_owner);
	if (get_user_team(attacker) != get_user_team(id))
	{
		new Float:fOrigin[3];
		entity_get_vector( ent, EV_VEC_origin, fOrigin);

		new iOrigin[3];
		for(new i=0;i<3;i++)
			iOrigin[i] = floatround(fOrigin[i]);

		message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_short(sprite_blast_miny);
		write_byte(32);
		write_byte(20);
		write_byte(0);
		message_end();

		new entlist[33];
		new numfound = find_sphere_class(ent,"player", 90.0 ,entlist, 32);

		for (new i=0; i < numfound; i++)
		{
			new pid = entlist[i];

			if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid))
				continue;

			cod_inflict_damage(attacker, pid, 70.0, 0.8, ent, (1<<24));
		}
		remove_entity(ent);
	}
}

public NowaRunda_Miny()
{
	new entMiny = find_ent_by_class(-1, "mine");
	while(entMiny > 0)
	{
		remove_entity(entMiny);
		entMiny = find_ent_by_class(entMiny, "mine");
	}
}

public Damage_Wyrzucenie(id)
{
	new idattacker = get_user_attacker(id);

	if(!is_user_alive(idattacker))
		return;

	if(!ma_klase[idattacker])
		return;

	if(random_num(1, 5) != 1)
		return;

	client_cmd(id, "drop");
}
public FwdAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
if(!is_user_connected(host) || !is_user_connected(ent))
return;

if(!ma_klase[host])
return;

set_es(es_handle, ES_RenderAmt, 255.0);
}
public PreThink(id)
{
if(ma_klase[id])
set_pev(id, pev_punchangle, {0.0,0.0,0.0})
}

public UpdateClientData(id, sw, cd_handle)
{
if(ma_klase[id])
set_cd(cd_handle, CD_PunchAngle, {0.0,0.0,0.0})
}
public CurWeapon(id)
{
if(!is_user_connected(id) || !is_user_alive(id) || !ma_klase[id])
return PLUGIN_CONTINUE;

new iEnt;

static Float:fSpeedMultiplier;

fSpeedMultiplier = floatdiv(1.0, 1.0+(float(50)/100.0));

for (new i = 1; i < sizeof g_szWpnEntNames; i++)
{
iEnt = fm_find_ent_by_owner(-1, g_szWpnEntNames[i], id)

if(iEnt)
{
set_pdata_float( iEnt, 46, ( get_pdata_float(iEnt, 46, 4) * fSpeedMultiplier), 4 );
set_pdata_float( iEnt, 47, ( get_pdata_float(iEnt, 47, 4) * fSpeedMultiplier), 4 );
}
}
return PLUGIN_CONTINUE;
}