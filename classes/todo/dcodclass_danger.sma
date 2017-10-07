#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <ColorChat>
#include <fun>
#include <fakemeta_util>
#include <engine>

#define DMG_BULLET (1<<1)

native cod_get_class_invisible(id);

new const nazwa[] = "Danger";
new const opis[] = "Ma 30% widocznosci podczas kucania z nozem, ciche chodzenie, ma teleport (co 10s), odbija 2 pociski na runde";
new const bronie = (1<<CSW_M4A1)|(1<<CSW_DEAGLE);
new const zdrowie = 30;
new const kondycja = 30;
new const inteligencja = 0;
new const wytrzymalosc = 20;
new const niewidzialnosc = 0;
new const bonus_niewidzialnosci = 0;

new bool:ma_klase[33];
new bool:teleport[33];
new pozostale_odbicia[33];

public plugin_init() {
	register_plugin(nazwa, "1.0", "O'Zone");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, niewidzialnosc, bonus_niewidzialnosci);
	register_forward(FM_PlayerPreThink, "Niewidzialnosc", 1);
	register_event("CurWeapon","CurWeapon","be", "1=1");
	register_event("ResetHUD", "ResetHUD", "abe");
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public plugin_precache()
{
	precache_model("models/cod_slowexp/vip/v_goldm4a1.mdl");
	precache_model("models/cod_slowexp/vip/p_goldm4a1.mdl");
}

public cod_class_enabled(id)
{
	new dostepna = 60;
	if (cod_get_class_level(id)<dostepna)
	{
		ColorChat(id, GREEN, "[COD:MW]^x01 Aby uzywac tej klasy musisz zdobyc^x04 %i^x01 poziom na dowolnej klasie!", dostepna);
		return COD_STOP;
	}
	ma_klase[id] = true;
	teleport[id] = true;
	pozostale_odbicia[id] = 2;
	set_user_footsteps(id, 1);
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	fm_set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	pozostale_odbicia[id] = 0;
	set_user_footsteps(id, 0);
}

public cod_class_skill_used(id)
{    
    if (!teleport[id])
	{
		client_print(id, print_center, "Teleportu mozna uzywac co 10s");
		return PLUGIN_CONTINUE;
	}

    if (!is_user_alive(id))
        return PLUGIN_CONTINUE;
    
    new Float:start[3], Float:view_ofs[3];
    pev(id, pev_origin, start);
    pev(id, pev_view_ofs, view_ofs);
    xs_vec_add(start, view_ofs, start);

    new Float:dest[3];
    pev(id, pev_v_angle, dest);
    engfunc(EngFunc_MakeVectors, dest);
    global_get(glb_v_forward, dest);
    xs_vec_mul_scalar(dest, 9999.0, dest);
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
    teleport[id] = false;
    set_task(10.0, "Teleport",id);
	
    return PLUGIN_CONTINUE;
}

public ResetHUD(id){
	if (ma_klase[id]) {
		teleport[id] = false;
		pozostale_odbicia[id] = 2;
		set_task(20.0, "Teleport", id);
	}
}

public Teleport(id){
	if (ma_klase[id])
		teleport[id] = true;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if (!ma_klase[this])
		return HAM_IGNORED;

	if (pozostale_odbicia[this] > 0 && damagebits & DMG_BULLET)
	{
		pozostale_odbicia[this]--;
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public Niewidzialnosc(id)
{
	if (!ma_klase[id])
	return;

	new render = cod_get_class_invisible(id);
	new button = get_user_button(id);
	if ( button & IN_DUCK && get_user_weapon(id) == CSW_KNIFE)
		fm_set_rendering(id, kRenderFxNone, 0,0,0, kRenderTransAlpha, 76);
	else
	{
		fm_set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255-render);
	}
}

public CurWeapon(id)
{
	if (!ma_klase[id])
		return PLUGIN_CONTINUE;
	
	new bron = read_data(2)  

	if (bron == CSW_M4A1){
		set_pev(id,pev_viewmodel2,"models/cod_slowexp/vip/v_goldm4a1.mdl")
		set_pev(id,pev_weaponmodel2,"models/cod_slowexp/vip/p_goldm4a1.mdl")
	}
	return PLUGIN_CONTINUE;
}
