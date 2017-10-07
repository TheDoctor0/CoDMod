#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <xs>

new const nazwa[] = "Mnich";
new const opis[] = "Posiada teleport (Mozna uzyc co 10s)";
new const bronie = 1<<CSW_AK47 | 1<<CSW_FLASHBANG;
new const zdrowie = 0;
new const kondycja = 17;
new const inteligencja = 0;
new const wytrzymalosc = 6;


new bool:uzyl[33];


public plugin_init() {
    register_plugin(nazwa, "1.0", "QTM_Peyote");
    
    cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
    register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_class_enabled(id)
{
   if (!(get_user_flags(id) & ADMIN_LEVEL_B))
	{
		client_print(id, print_chat, "[Mnich] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	
    uzyl[id] = false;
    return COD_CONTINUE;
}



public cod_class_skill_used(id)
{    

if (!uzyl[id]==false)
	{
		client_print(id, print_center, "Teleport mozna uzywac co 10s");
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
    set_task ( 10.0, "ResetHUD", id )
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