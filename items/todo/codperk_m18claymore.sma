
/*
Perk "M18 ClayMore" stworzono na potrzeby Call of Duty Mod by QTM. Peyote
Zastosowanie: Dostajesz mine przeciwpiechotna, ktora mozesz zdetonowac:
-Recznie - dostajesz joysticka (jako NOZ) ktory mozesz uzyc w kazdej chwili. Gdy zginiesz a bomba nie zdetonowana, idzie na straty
-Automatycznie - wybuch wyzwalany jest przez zblizenie sie przeciwnika
-Przez wyzwalacz - wybuch wyzwalany jest przez sensor, ktory wykrywa ruch przeciwnika.
Autor perku: Hleb
*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <codmod>
#include <hamsandwich>
#include <fakemeta_util>

#define TASK_PLANTING 841
#define TASK_DETONATE_MANUAL 873

new const perk_name[] = "M18 ClayMore"
new const perk_desc[] = "Dostajesz mine przeciwpiechotna ktora mozesz recznie lub automatycznie zdetonowac"

enum {DETONATE_NONE = 0, MANUAL_DETONATE, SCAN_DETONATE, TRIGGER_DETONATE}  // rodzaj detonacji
enum {PLANT_NONE = 0, PLANTING, PLANTED}
new bool: ma_perk[33], M18_planting[33], M18_detonate[33], bool: freezetime;
new white;
new explo;
new smoke;
new nadeexp;
new beamspr;
new Float:idle[33], Float: knife_idle[33];
new cvar_dmg_auto, cvar_int_auto, cvar_dmg_manual, 
	cvar_int_manual, cvar_dmg_trigger, cvar_int_trigger,
	cvar_exp_distance, cvar_auto_to_exp, cvar_trigger_to_exp;


public plugin_init() 
{
	register_plugin(perk_name, "1.2", "Hleb")
	
	cod_register_perk(perk_name, perk_desc)
	RegisterHam(Ham_Item_Deploy, "weapon_tmp", "Weapon_Deploy", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Weapon_Deploy_Knife", 1);
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_tmp", "Claymore_Idle");
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_knife", "Joystick_Idle");
	
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	register_event("ResetHUD", "ResetHUD", "abe");
	register_logevent("PoczatekRundy", 2, "1=Round_Start"); 
	register_forward(FM_CmdStart, "CmdStart");
	register_forward(FM_SetModel,"fwSetModel",1);
	register_forward(FM_Think, "M18_Detonate_Scan");
	register_forward(FM_Think, "M18_Detonate_Trigger");
	
	cvar_dmg_auto = register_cvar("claymore_damage_auto", "90.0")
	cvar_int_auto = register_cvar("claymore_int_auto", "1.0")
	cvar_dmg_manual = register_cvar("claymore_damage_manual", "150.0")
	cvar_int_manual = register_cvar("claymore_int_manual", "1.2")
	cvar_dmg_trigger = register_cvar("claymore_damage_trigger", "120.0")
	cvar_int_trigger = register_cvar("claymore_int_trigger", "1.1")
	cvar_exp_distance = register_cvar("claymore_damage_distance", "300.0")
	cvar_auto_to_exp = register_cvar("claymore_auto_to_explode", "125.0")
	cvar_trigger_to_exp = register_cvar("claymore_trigger_to_explode", "75.0")
	
}
public cod_perk_enabled(id)
{
	if(cod_get_user_class(id) == cod_get_classid("Taktykant"))
		return COD_STOP
	cod_give_weapon(id, CSW_TMP)	
	ma_perk[id] = true
	M18_planting[id] = PLANT_NONE;
	M18_detonate[id] = DETONATE_NONE;
	return COD_CONTINUE;
}
public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_TMP)
	ma_perk[id] = false
}
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, "models/QTM_CodMod/v_claymore.mdl")
	engfunc(EngFunc_PrecacheModel, "models/QTM_CodMod/p_claymore.mdl")
	engfunc(EngFunc_PrecacheModel, "models/QTM_CodMod/w_claymore.mdl")
	engfunc(EngFunc_PrecacheModel, "models/QTM_CodMod/v_claymore_radio.mdl")
	nadeexp = engfunc(EngFunc_PrecacheModel, "sprites/exp.spr");
	smoke = engfunc(EngFunc_PrecacheModel, "sprites/smoke.spr");
	explo = engfunc(EngFunc_PrecacheModel, "sprites/explo.spr");
	white = engfunc(EngFunc_PrecacheModel, "sprites/white.spr");
	beamspr = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr");
	engfunc(EngFunc_PrecacheSound, "misc/claymore_plant.wav");
	engfunc(EngFunc_PrecacheSound, "misc/claymore_trigger.wav");
}
public Weapon_Deploy(ent)
{
	if(!pev_valid(ent))
		return HAM_IGNORED
		
	new id = get_pdata_cbase(ent, 41, 4);
	if(ma_perk[id])
	{
		set_pev(id, pev_viewmodel2, "models/QTM_CodMod/v_claymore.mdl");
		set_pev(id, pev_weaponmodel2, "models/QTM_CodMod/p_claymore.mdl");
		set_pev(id, pev_weaponanim, 3);
	}
	return HAM_IGNORED;
}
public Weapon_Deploy_Knife(ent)
{
	if(!pev_valid(ent))
		return HAM_IGNORED;
		
	new id = get_pdata_cbase(ent, 41, 4)
	if(ma_perk[id] && M18_detonate[id] == MANUAL_DETONATE)
	{
		set_pev(id, pev_viewmodel2, "models/QTM_CodMod/v_claymore_radio.mdl");
		set_pev(id, pev_weaponanim, 2);
	}
	return HAM_IGNORED;
}
public Claymore_Idle(ent)
{	
	new id = get_pdata_cbase(ent, 41, 4);
	if(get_user_weapon(id) == CSW_TMP && ma_perk[id])
	{
		if(!idle[id]) 
			idle[id] = get_gametime();
	}
}
public Joystick_Idle(ent)
{
	
	new id = get_pdata_cbase(ent, 41, 4);
	if(get_user_weapon(id) == CSW_KNIFE && ma_perk[id])
	{
		if(!knife_idle[id]) 
			knife_idle[id] = get_gametime();
	}
}
public CmdStart(id, uc_handle)
{	
	if(!is_user_alive(id))
		return FMRES_IGNORED
		
	if(!is_user_connected(id))
		return FMRES_IGNORED
		
	new Button = get_uc(uc_handle, UC_Buttons)
	new OldButton = pev(id, pev_oldbuttons)		
		
	if(get_user_weapon(id) == CSW_TMP)
	{
		if(!ma_perk[id])
			return FMRES_IGNORED
		
		if(!idle[id]) 
			return FMRES_IGNORED;
		if(idle[id] && (get_gametime()-idle[id]<=35.0/50.0)) 
			return FMRES_IGNORED;

		new M18= fm_find_ent_by_owner(-1, "weapon_tmp", id);
		
		if(Button & IN_ATTACK && !(OldButton & IN_ATTACK) && !M18_planting[id] && !freezetime) 
		{
			set_pev(id, pev_weaponanim, 1);
			Button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, Button);
			bartime(id, 1);
			M18_planting[id] = PLANTING
			set_task(1.0, "claymore_planting", id+TASK_PLANTING)
		}
		if(M18_planting[id] == PLANTING && (Button & (IN_USE | IN_ATTACK2 | IN_BACK | IN_FORWARD | IN_CANCEL | IN_JUMP | IN_MOVELEFT | IN_MOVERIGHT | IN_RIGHT)))
		{
			set_pev(id, pev_weaponanim, 0);
			remove_task(id+TASK_PLANTING)
			bartime(id, 0);
			M18_planting[id] = PLANT_NONE;
		}
		if(M18)
			cs_set_weapon_ammo(M18, -1);
	}
	else if(get_user_weapon(id) != CSW_TMP && ma_perk[id])
	{
		if(task_exists(id+TASK_PLANTING))
		{
			remove_task(id+TASK_PLANTING)
			bartime(id, 0);
			M18_planting[id] = PLANT_NONE;
			return FMRES_IGNORED
		}
	}
	if(get_user_weapon(id) == CSW_KNIFE && M18_detonate[id] == MANUAL_DETONATE && Button & IN_ATTACK && !(OldButton & IN_ATTACK))	
	{
		if(!knife_idle[id]) 
				return FMRES_IGNORED;
		if(knife_idle[id] && (get_gametime()-knife_idle[id]<=19.0/30.0)) 
				return FMRES_IGNORED;
				
		new M18 = fm_find_ent_by_class(-1, "claymore");
		if(M18 && pev(M18, pev_owner) == id)
		{
			new joystick = fm_find_ent_by_owner(-1, "weapon_knife", id)
			if(joystick)
				set_pdata_float(joystick, 48, 1.5+3.0, 4)
			set_pdata_float(id, 83, 1.5, 4)
			set_pev(id, pev_weaponanim, 3)
			set_task(0.3, "M18_Detonate_Manual", M18+TASK_DETONATE_MANUAL)
		}
	}
	return FMRES_IGNORED
}
public ResetHUD(id)
{
	M18_detonate[id] = DETONATE_NONE;
	M18_planting[id] = PLANT_NONE;
}
public claymore_planting(id)
{
	id-=TASK_PLANTING
	M18_planting[id] = PLANTED
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_wall"));
	engfunc(EngFunc_SetModel, ent, "models/QTM_CodMod/w_claymore.mdl");
	engfunc(EngFunc_SetSize, ent, Float:{-4.0, -4.0, 0.0}, Float:{4.0, 4.0, 14.0});
	set_pev(ent, pev_classname, "claymore");
	set_pev(ent, pev_owner, id);
	set_pev(ent, pev_solid, 2);
	set_pev(ent, pev_movetype, 6);
	set_pev(ent, pev_gravity, 1.3);
	set_pev(ent, pev_friction, 1.0);
	set_pev(ent, pev_health, 20.0);
	set_pev(ent, pev_takedamage, DAMAGE_YES);
	
	new Float:angles[3], Float:origin[3], Float: fov;
	pev(id, pev_v_angle, angles);
	pev(id, pev_origin, origin);
	angles[0] = 0.0;
	origin[0] += floatcos(angles[1], degrees) * 11.0;
	origin[1] += floatsin(angles[1], degrees) * 11.0;
	origin[2] -= 10.0;
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_angles, angles);
	set_pev(ent, pev_v_angle, angles);
	pev(id, pev_fov, fov);
	set_pev(ent, pev_fov, fov);
	
	fm_drop_to_floor(ent)
	emit_sound(ent, CHAN_AUTO, "misc/claymore_plant.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	new ent1 = fm_find_ent_by_owner(-1, "weapon_tmp", id);
	if(ent1 && M18_planting[id] == PLANTED)
		engclient_cmd(id, "drop", "weapon_tmp")
	M18_Menu(id)
	
}
public fwSetModel(ent, model[])
{
	new id = pev(ent, pev_owner)
	if(M18_planting[id] != PLANTED)
		return FMRES_IGNORED
		
	new szClass[32];
	pev(ent, pev_classname,szClass, 31);
	if(equal(szClass,"weaponbox"))
	{
		if(!equal(model, "models/w_tmp.mdl"))
			return FMRES_HANDLED;
		dllfunc(DLLFunc_Think, ent);
	}
	return FMRES_IGNORED;
}
public M18_Menu(id)
{
	new menu = menu_create("Wybierz tryb detonacji:", "M18_Menu_Handle");
	menu_additem(menu, "Automatyczna (radar)");
	menu_additem(menu, "Reczna (radio)");	
	menu_additem(menu, "Automatyczna (wyzwalacz)");
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	
	menu_display(id, menu);
}
public M18_Menu_Handle(id, menu, item)
{
	new m18 = fm_find_ent_by_class(0, "claymore")
	switch(item)
	{
		case 0: 
		{
			M18_detonate[id] = SCAN_DETONATE
			client_print(id, print_chat, "[COD:MW] Wybrales automatyczna detonacje!")
			client_print(id, print_chat, "[COD:MW] Wybuch wyzwalany jest przez zblizenie sie wroga do miny!");
			if(m18)
				if(pev(m18, pev_owner) == id)
					set_pev(m18, pev_nextthink, get_gametime() + 0.1);
		}
		case 1:
		{
			M18_detonate[id] = MANUAL_DETONATE;
			client_print(id, print_chat, "[COD:MW] Wybrales reczna detonacje!");
			client_print(id, print_chat, "[COD:MW] By otrzymac detonatora, wybierz noz!");
			client_print(id, print_chat, "[COD:MW] Nacisnij LPM, aby zdetonowac mine!");
		}
		case 2:
		{
			M18_detonate[id] = TRIGGER_DETONATE;
			client_print(id, print_chat, "[COD:MW] Wybrales detonacje przez wyzwalacz!");
			client_print(id, print_chat, "[COD:MW] Wybuch wyzwalany jest przez najscie przeciwnika na sensor!");
			if(m18)
			{
				create_sensor(m18);
				if(pev(m18, pev_owner) == id)
					set_pev(m18, pev_nextthink, get_gametime() + 0.1);
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_CONTINUE
}
public create_sensor(ent)
{
	if (!pev_valid(ent))
		return;

	for(new i = 0; i <= 1; i++)
		draw_sensor(ent, (i)?30.0:-30.0, get_pcvar_float(cvar_trigger_to_exp))

	set_task(0.5, "create_sensor", ent);
}
public draw_sensor(ent, Float:angle, Float: distance)
{
	if (!pev_valid(ent))
		return;

	// gets start and end origins for beam
	new Float:angles[3], Float:origin[3], Float:origin2[3], user_team = get_user_team(pev(ent, pev_owner));
	pev(ent, pev_v_angle, angles);
	pev(ent, pev_origin, origin);
	origin2[0] = origin[0] + (floatcos(angles[1] + angle, degrees) * distance);
	origin2[1] = origin[1] + (floatsin(angles[1] + angle, degrees) * distance);
	origin[2] += 12.0;

	// draws beam
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(0);		//TE_BEAMPOINTS
	write_coord(floatround(origin[0]));	//centerpoint
	write_coord(floatround(origin[1]));	//left top corner
	write_coord(floatround(origin[2]));	//horizontal height
	write_coord(floatround(origin2[0]));//centerpoint
	write_coord(floatround(origin2[1]));//left right corner
	write_coord(floatround(origin[2]));	//horizontal height
	write_short(beamspr);	//sprite to use
	write_byte(1);		// framestart
	write_byte(1);		// framerate
	write_byte(6);		// life in 0.1's
	write_byte(3);		// width
	write_byte(0);		// noise
	write_byte((user_team == 1) ? 255 : 0);	// red
	write_byte(0);					// green
	write_byte((user_team == 1) ? 0 : 255);	// blue
	write_byte(200);		// brightness
	write_byte(0);		// speed
	message_end();
}

public M18_Detonate_Manual(ent)
{
	ent -= TASK_DETONATE_MANUAL
	set_pev(ent, pev_iuser1, 1);
		
	new attacker = pev(ent, pev_owner);
	
	new Float:fOrigin[3];
	pev(ent, pev_origin, fOrigin);
	
	claymore_explode(attacker, ent, fOrigin, get_pcvar_float(cvar_dmg_manual), get_pcvar_float(cvar_int_manual))
	return PLUGIN_CONTINUE
}
public M18_Detonate_Scan(ent)
{
	if(!pev_valid(ent))
		return FMRES_IGNORED;
		
	new classname[10];
	pev(ent, pev_classname, classname, charsmax(classname));
	
	if(!equal(classname, "claymore"))
		return FMRES_IGNORED;
		
	new attacker = pev(ent, pev_owner)
	new bool: Detonate = false;
	
	if(M18_detonate[attacker] != SCAN_DETONATE)
		return FMRES_IGNORED;
		
	if(pev(ent, pev_iuser2))
		return FMRES_IGNORED;
	
	set_pev(ent, pev_iuser1, 1);
		

		
	new Float:fOrigin[3], iOrigin[3];
	pev(ent, pev_origin, fOrigin);
	
	new pid = -1
	while((pid = engfunc(EngFunc_FindEntityInSphere, pid, fOrigin, get_pcvar_float(cvar_auto_to_exp))) != 0)
	{
		if (is_user_alive(pid) && get_user_team(attacker) != get_user_team(pid))
		{
			Detonate = true;
			break;
		}
	}
	if(Detonate)
	{	
		claymore_explode(attacker, ent, fOrigin, get_pcvar_float(cvar_dmg_auto), get_pcvar_float(cvar_int_auto))
		return FMRES_IGNORED;
	}
	FVecIVec(fOrigin, iOrigin);
			
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iOrigin);
	write_byte(TE_BEAMCYLINDER);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1] + 125);
	write_coord(iOrigin[2] + 125);
	write_short(white);
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(10); // life
	write_byte(10); // width
	write_byte(255); // noise
	write_byte(0); // r, g, b
	write_byte(100);// r, g, b
	write_byte(255); // r, g, b
	write_byte(4); // brightness
	write_byte(0); // speed
	message_end();

	set_pev(ent, pev_nextthink, get_gametime() + 0.3);	
	
	return FMRES_IGNORED;
}
public M18_Detonate_Trigger(ent)
{
	if(!pev_valid(ent))
		return FMRES_IGNORED;
		
	new classname[10];
	pev(ent, pev_classname, classname, charsmax(classname));
	
	if(!equal(classname, "claymore"))
		return FMRES_IGNORED;
		
	new attacker = pev(ent, pev_owner)	
		
	if(M18_detonate[attacker] != TRIGGER_DETONATE)
		return FMRES_IGNORED;
		
	if(pev(ent, pev_iuser2))
		return FMRES_IGNORED;
	
	set_pev(ent, pev_iuser1, 1);
			
	new Float:fOrigin[3], iOrigin[3], Float: idOrigin[3];
	pev(ent, pev_origin, fOrigin);
	new pid = -1
	while((pid = engfunc(EngFunc_FindEntityInSphere, pid, fOrigin, get_pcvar_float(cvar_trigger_to_exp))) != 0)
	{
		pev(pid, pev_origin, idOrigin);
		if (is_user_alive(pid) && get_user_team(attacker) != get_user_team(pid) && fm_is_visible(pid, fOrigin) && fm_is_in_viewcone(ent, idOrigin))
		{
			emit_sound(ent, CHAN_AUTO, "misc/claymore_trigger.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			new data[5];
			FVecIVec(fOrigin, iOrigin)
			data[0] = attacker
			data[1] = ent
			data[2] = iOrigin[0];
			data[3] = iOrigin[1];
			data[4] = iOrigin[2];
			set_task(0.4, "explode", attacker, data, 5);
			break;
		}
	}	
	set_pev(ent, pev_nextthink, get_gametime() + 0.5);
	
	return FMRES_IGNORED;
}
public explode(param[])
{
	new id, ent, origin[3], Float: forigin[3];
	id = param[0]
	ent = param[1]
	origin[0] = param[2];
	origin[1] = param[3];
	origin[2] = param[4];
	IVecFVec(origin, forigin)
	claymore_explode(id, ent, forigin, get_pcvar_float(cvar_dmg_trigger), get_pcvar_float(cvar_int_trigger))
}
public NowaRunda()
{
	new ent = fm_find_ent_by_class(-1, "claymore"), id = pev(ent, pev_owner);
	while(ent > 0) 
	{
		M18_detonate[id] = DETONATE_NONE
		M18_planting[id] = PLANT_NONE
		fm_remove_entity(ent);
		ent = fm_find_ent_by_class(ent, "claymore");	
	}
	freezetime = true;
}
public client_disconnect(id)
{
	new ent = fm_find_ent_by_class(0, "claymore");
	while(ent > 0)
	{
		if(pev(ent, pev_owner) == id)
			fm_remove_entity(ent);
		ent = fm_find_ent_by_class(ent, "claymore");
	}
}
public PoczatekRundy()	
{
	freezetime = false;
}
stock claymore_explode(id, ent, const Float: origin[3], Float: damage, Float: int)
{
	new iOrigin[3];
	FVecIVec(origin, iOrigin);
		
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(nadeexp); 
	write_byte(40); 
	write_byte(30); 
	write_byte(14); 
	message_end(); 
		
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
	write_byte(TE_EXPLOSION); 
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(explo); 
	write_byte(40);
	write_byte(30);
	write_byte(TE_EXPLFLAG_NONE); 
	message_end(); 
		
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(5)
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(smoke);
	write_byte(35);
	write_byte(5);
	message_end();
	
	new pid = -1
	while((pid = engfunc(EngFunc_FindEntityInSphere, pid, origin, get_pcvar_float(cvar_exp_distance))) != 0)
	{
		if (is_user_alive(pid) && get_user_team(id) != get_user_team(pid))
		{
			cod_inflict_damage(id, pid, damage, int, ent, (1<<24));
		}
	}
	M18_detonate[id] = DETONATE_NONE;
	M18_planting[id] = PLANT_NONE;
	fm_remove_entity(ent)
	return PLUGIN_CONTINUE;
}
stock bartime(id, number)
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("BarTime"), .player = id);
	write_short(number);
	message_end();	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
