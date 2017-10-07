#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <xs>
#include <hamsandwich>

#define DMG_BULLET (1<<1)
#define DMG_HEGRENADE (1<<24)

new const nazwa[] = "Starszy Teleporter";
new const opis[] = "Posiada Teleport (Mozna Uzyc Co 30 Sekund), 25 Dmg Z M4, 1/3 z SG550(Snajperka)";
new const bronie = 1<<CSW_SG550 | 1<<CSW_M4A1 | 1<<CSW_HEGRENADE | 1<<CSW_MP5NAVY | 1<<CSW_DEAGLE;
new const zdrowie = 25;
new const kondycja = 45;
new const inteligencja = 15;
new const wytrzymalosc = 25;

new bool:uzyl[33];
new skoki[33];
new ma_klase[33];

public plugin_init() {
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("ResetHUD", "ResetHUD", "abe");
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
}

public cod_class_enabled(id)
{	
	if (!(get_user_flags(id) & ADMIN_LEVEL_E))
	{
		client_print(id, print_chat, "[] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	ma_klase[id] = true;  
	
	uzyl[id] = false;
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
}

public cod_class_skill_used(id)
{
	
	if (!uzyl[id]==false)
	{
		client_print(id, print_center, "Teleport Mozna Uzywac Co 30 Sekund");
		return PLUGIN_CONTINUE;
	}
	
	if (uzyl[id] || !is_user_alive(id))
		return PLUGIN_CONTINUE;
	
	new Float:start[3], Float:view_ofs[3];
	pev(id, pev_origin, start);
	pev(id, pev_view_ofs, view_ofs);
	xs_vec_add(start, view_ofs, start);
	
	new Float:dest[3];
	pev(id, pev_v_angle, dest);
	engfunc(EngFunc_MakeVectors, dest);
	global_get(glb_v_forward, dest);
	xs_vec_mul_scalar(dest, 999.0, dest);
	xs_vec_add(start, dest, dest);
	
	engfunc(EngFunc_TraceLine, start, dest, 0, id, 0);
	
	new Float:fDstOrigin[3];
	get_tr2(0, TR_vecEndPos, fDstOrigin);
	
	if (engfunc(EngFunc_PointContents, fDstOrigin) == CONTENTS_SKY)
		return PLUGIN_CONTINUE;
	
	new Float:fNormal[3];
	get_tr2(0, TR_vecPlaneNormal, fNormal);
	
	xs_vec_mul_scalar(fNormal, 50.0, fNormal);
	xs_vec_add(fDstOrigin, fNormal, fDstOrigin);
	set_pev(id, pev_origin, fDstOrigin);
	uzyl[id] = true;
	set_task ( 30.0, "ResetHUD", id )
	set_task ( 10.0, "InfoTel", id )
}

public ResetHUD(id)
{
	uzyl[id] = false;
}

public InfoTel(id)
{
	client_print(id, print_center, "Mozesz uzyc Teleportacji");
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if (!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if (!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if (get_user_weapon(idattacker) == CSW_M4A1 && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 25.0, 0.0, idinflictor, damagebits);
	
	if (get_user_weapon(idattacker) == CSW_MP5NAVY && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 25.0, 0.0, idinflictor, damagebits);
	
	if (damagebits & DMG_BULLET && get_user_weapon(idattacker) == CSW_SG550 && random_num(1, 3) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	if (damagebits & DMG_HEGRENADE && random_num(1, 2) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
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
	if (ma_klase[id] && get_user_weapon(id) == CSW_MP5NAVY && get_uc(uc_handle, UC_Buttons) & IN_ATTACK)
	{
		new Float:punchangle[3]
		pev(id, pev_punchangle, punchangle)
		for(new i=0; i<3;i++)
			punchangle[i]*=0.9;
		set_pev(id, pev_punchangle, punchangle)
	}
	else if (flags & FL_ONGROUND)
		skoki[id] = 15;
	
	return FMRES_IGNORED;
}
