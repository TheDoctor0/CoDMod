#include <amxmodx>
#include <codmod>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <xs>

#define SENTRY_THINK 0.4
#define OFFSET_WPN_LINUX  4
#define OFFSET_WPN_WIN 	  41
#define fm_point_contents(%1) engfunc(EngFunc_PointContents, %1)
#define fm_DispatchSpawn(%1) dllfunc(DLLFunc_Spawn, %1)

new const nazwa[]   = "Inzynier [P]";
new const opis[]    = "Ma dzialko straznicze [e], +20 hp za fraga, defuser";
new const bronie    = (1<<CSW_AUG)|(1<<CSW_FIVESEVEN);
new const zdrowie   = 10;
new const kondycja  = 10;
new const inteligencja = 10;
new const wytrzymalosc = 0;

new bool:ma_dzialko[33];

new g_maxplayers;

new pcvarPercent, pcvarHealth;

new bool:ma_klase[33];
new bool:pokazacModel[33];


public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Premium");

	RegisterHam(Ham_Spawn, "player", "DajNoweDzialko", 1);
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack_Building")
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "ham_ItemDeploy_Post", 1)
	RegisterHam(Ham_TakeDamage, "func_breakable", "fwHamTakeDamage_Dzialko" );

	register_event("DeathMsg", "DeathMsg", "ade");

	register_think("sentry_shot", "sentry_shot")

	g_maxplayers = get_maxplayers();

	pcvarPercent = register_cvar("inzynier_percent", "15")
	pcvarHealth = register_cvar("inzynier_health", "600")
}

public plugin_precache()
{
	precache_sound("sentry_shoot.wav");
	
	precache_model("models/v_tfc_spanner.mdl")
	precache_model("models/base2.mdl")
	precache_model("models/sentry2.mdl")

	precache_sound("debris/bustmetal1.wav");
	precache_sound("debris/bustmetal2.wav");
	
	engfunc(EngFunc_PrecacheModel,"models/computergibs.mdl")
}
	
public cod_class_enabled(id)
{
	if(!(cod_get_user_status(id) & STATUS_PREMIUM))
	{
		client_print(id, print_chat, "[%s] Nie masz premium, zeby grac ta klasa!", nazwa)
		return COD_STOP;
	}

	ma_dzialko[id] = true;
	cs_set_user_defuse(id, 1);
	ma_klase[id] = true;
	pokazacModel[id] = true
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
	ma_klase[id] = false;

public DeathMsg()
{
	new killer = read_data(1);
	
	if(!is_user_connected(killer))
		return PLUGIN_CONTINUE;
	
	if(ma_klase[killer])
	{
		new cur_health = pev(killer, pev_health);
		new Float:max_health = 100.0+cod_get_user_health(killer);
		new Float:new_health = cur_health+20.0<max_health? cur_health+20.0: max_health;
		set_pev(killer, pev_health, new_health);
	}
	
	return PLUGIN_CONTINUE;
}

public fwHamTakeDamage_Dzialko(this, idinflictor, idattacker)
{
	static classname[13];
	pev(this, pev_classname, classname, 12);
	
	if((equal(classname, "sentry_shot") || equal(classname, "sentry_base")) && is_user_connected(idattacker) && get_user_team(pev(this, pev_iuser1)) == get_user_team(idattacker))
		return HAM_SUPERCEDE;

	return HAM_IGNORED;
}

public ham_ItemDeploy_Post(weapon_ent)
{
	static owner
	owner = get_pdata_cbase(weapon_ent, OFFSET_WPN_WIN, OFFSET_WPN_LINUX);
	
	if(!is_user_alive(owner) || !ma_klase[owner]) return;

	if(pokazacModel[owner])
		entity_set_string(owner, EV_SZ_viewmodel, "models/v_tfc_spanner.mdl")

	if(ma_dzialko[owner])
		client_print(owner, print_center, "Wcisnij c, aby postawic dzialko")
}	

public cod_class_skill_used(id)
{
	if(ma_dzialko[id])
	{
		new Float:Origin[3]
		pev(id, pev_origin, Origin)

		new Float:vTraceDirection[3]
		new Float:vTraceEnd[3]
		new Float:vTraceResult[3]
		
		velocity_by_aim(id, 64, vTraceDirection) // get a velocity in the directino player is aiming, with a multiplier of 64...
		
		vTraceEnd[0] = vTraceDirection[0] + Origin[0]
		vTraceEnd[1] = vTraceDirection[1] + Origin[1]
		vTraceEnd[2] = vTraceDirection[2] + Origin[2]
		
		fm_trace_line(id, Origin, vTraceEnd, vTraceResult)
		
		vTraceEnd[0] = vTraceResult[0]
		vTraceEnd[1] = vTraceResult[1]
		vTraceEnd[2] = Origin[2]
		
		if(!(StawDzialo(vTraceEnd, id)))
			client_print(id, print_center, "Nie mozesz tu postawic dziala!")
		else
		{
			client_print(id, print_center, "Uderz kluczem (noz), aby zbudowac!")
			ma_dzialko[id] = false;
		}
	}
}

public bool:StawDzialo(Float:origin[3], id)
{
	if (fm_point_contents(origin) != CONTENTS_EMPTY || is_hull_default(origin, 32.0)) return false

	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0
	fm_trace_line(0, origin, originDown, hitPoint)
	
	new Float:difference = 36.0 - vector_distance(origin, hitPoint)
	if (difference < -10.0 || difference > 10.0) return false
	
	new sentry_base = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"))
	if (!sentry_base) return false
	
	set_pev(sentry_base, pev_classname, "sentry_base")
	
	engfunc(EngFunc_SetModel, sentry_base, "models/base2.mdl")
	engfunc(EngFunc_SetSize, sentry_base, {-16.0, -16.0, 0.0}, {16.0, 16.0, 25.0})
	engfunc(EngFunc_SetOrigin, sentry_base, origin)
	pev(id, pev_v_angle, originDown)
	originDown[0] = 0.0
	originDown[1] += 180.0
	originDown[2] = 0.0
	set_pev(sentry_base, pev_angles, originDown)
	set_pev(sentry_base, pev_solid, SOLID_BBOX)
	set_pev(sentry_base, pev_movetype, MOVETYPE_TOSS)
	set_pev(sentry_base, pev_iuser1, id)
	set_pev(sentry_base, pev_iuser2, 0)
	set_pev(sentry_base, pev_iuser3, 0)
	
	return true;
}

public DajNoweDzialko(id)
{
	if(is_user_alive(id) && ma_klase[id])
		ma_dzialko[id] = true;
}

set_animation(id, anim)
{
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}

public fw_TraceAttack_Building(id, enemy)
{
	if (!(1 <= enemy <= g_maxplayers) || !is_user_alive(enemy))
		return HAM_IGNORED

	if(ma_klase[enemy] && get_user_weapon(enemy) == CSW_KNIFE && pev(id, pev_iuser1) == enemy && pev(id, pev_iuser2) < 100)
	{
		new classname[14]
		pev(id, pev_classname, classname, 13)
		if(!equal(classname, "sentry_base")) return HAM_IGNORED
		
		set_pev(id, pev_iuser2, pev(id, pev_iuser2)+get_pcvar_num(pcvarPercent) > 100 ? 100 : pev(id, pev_iuser2)+get_pcvar_num(pcvarPercent));
		set_animation(enemy, 8);
		if(pev(id, pev_iuser2) >= 100 && !pev(id, pev_iuser3))
		{
			client_print(enemy, print_center, "%d %%", pev(id, pev_iuser2))
			set_pev(id, pev_iuser3, stawdzialo2(id));
			pokazacModel[enemy] = false
		}
		else
			client_print(enemy, print_center, "%d %%", pev(id, pev_iuser2))
	}
	
	return HAM_IGNORED
}

public stawdzialo2(ent)
{
	new sentry_shot2 = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"))
	if (!sentry_shot2) return 0
	
	new szHealth[6]
	get_pcvar_string(pcvarHealth, szHealth, charsmax(szHealth))
	
	fm_set_kvd(sentry_shot2, "health", szHealth, "func_breakable")
	fm_set_kvd(sentry_shot2, "material", "6", "func_breakable")
	fm_DispatchSpawn(sentry_shot2)
	
	set_pev(sentry_shot2, pev_classname, "sentry_shot")
	
	new Float:origin[3];
	pev(ent, pev_origin, origin);

	engfunc(EngFunc_SetModel, sentry_shot2, "models/sentry2.mdl")
	engfunc(EngFunc_SetSize, sentry_shot2, {-16.0, -16.0, 0.0}, {16.0, 16.0, 20.0})
	origin[2] += 25.0;
	engfunc(EngFunc_SetOrigin, sentry_shot2, origin)
	pev(pev(ent, pev_iuser1), pev_v_angle, origin)
	origin[0] = 0.0
	origin[1] += 180.0
	origin[2] = 0.0
	set_pev(sentry_shot2, pev_angles, origin)
	set_pev(sentry_shot2, pev_solid, SOLID_BBOX)
	set_pev(sentry_shot2, pev_movetype, MOVETYPE_TOSS)
	set_pev(sentry_shot2, pev_iuser1, pev(ent, pev_iuser1))
	set_pev(sentry_shot2, pev_iuser2, ent)
	
	set_pev( sentry_shot2, pev_sequence, 0 );
	set_pev( sentry_shot2, pev_animtime, get_gametime() );
	set_pev( sentry_shot2, pev_framerate, 1.0 );
	
	set_pev(sentry_shot2, pev_nextthink, get_gametime() + SENTRY_THINK)

	return sentry_shot2;
}

public sentry_find_player(ent)
{
	new Float:fOrigin[3], Float:fOrigin2[3], Float:distance = 9999.0, Float:hitOrigin[3], iCloseId = 0, iOwner = 0;
	iOwner = pev(ent, pev_iuser1)
	pev(ent, pev_origin, fOrigin)
	for(new i = 1; i < g_maxplayers; i++)
	{
		if(!is_user_alive(i) || get_user_team(i) == get_user_team(iOwner))
			continue;

		pev(i, pev_origin, fOrigin2)

		if(distance > vector_distance(fOrigin, fOrigin2) && fm_trace_line(ent, fOrigin, fOrigin2, hitOrigin) == i)
		{
			distance = vector_distance(fOrigin, fOrigin2)
			iCloseId = i;
		}
	}
	return iCloseId;
}

public sentry_shot(ent)
{
	if(!pev_valid(ent)) return;

	if(entity_get_float(ent, EV_FL_health) <= 0.0)
	{
		new entt = pev(ent, pev_iuser2)
		if(pev_valid(entt))
			remove_entity(entt);

		remove_entity(ent);
		return;
	}
	
	static iFind = 0;
	if((iFind = sentry_find_player(ent)))
	{
		remove_task(ent+45676);
		turntotarget(ent, iFind);
		sentry_shot3(ent, iFind);
		set_task(0.5, "stop_anim", ent+45676)
	}
	
	set_pev(ent, pev_nextthink, get_gametime() + SENTRY_THINK)
}

public sentry_shot3(ent, target)
{
	new Float:sentryOrigin[3], Float:targetOrigin[3], Float:hitOrigin[3]

	pev(ent, pev_origin, sentryOrigin)
	sentryOrigin[2] += 18.0
	pev(target, pev_origin, targetOrigin)
	targetOrigin[0] += random_float(-16.0, 16.0)
	targetOrigin[1] += random_float(-16.0, 16.0)
	targetOrigin[2] += random_float(-16.0, 16.0)

	if(fm_trace_line(ent, sentryOrigin, targetOrigin, hitOrigin) == target)
	{
		knockback_explode(target, sentryOrigin)
		ExecuteHam(Ham_TakeDamage, target, 0, pev(ent, pev_iuser1), float(random_num(15, 40)), 1);
		set_pev( ent, pev_sequence, 1 );
		set_pev( ent, pev_animtime, get_gametime() );
		set_pev( ent, pev_framerate, 1.0 );
	}
	
	FX_Trace(sentryOrigin, hitOrigin)

	engfunc(EngFunc_EmitSound, ent, CHAN_STATIC, "sentry_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public stop_anim(ent)
{
	ent -= 45676;
	if(pev_valid(ent))
	{
		set_pev( ent, pev_sequence, 0 );
		set_pev(ent, pev_animtime, get_gametime() );
		set_pev( ent, pev_framerate, 1.0 );
	}
}

public knockback_explode(id, const Float:exp_origin[3])
{
	if(!is_user_alive(id)) return
	
	new Float:velocity[3], Float:id_origin[3], Float:output[3];

	pev(id, pev_origin, id_origin);
	get_speed_vector(exp_origin, id_origin, 5.0, velocity);
	pev(id, pev_velocity, id_origin);
	xs_vec_add(velocity, id_origin, output)
	set_pev(id, pev_velocity, output)
}

public turntotarget(ent, target)
{
	if (target)
	{
		new Float:closestOrigin[3], Float:sentryOrigin[3], Float:newAngle[3]
		pev(target, pev_origin, closestOrigin)
		pev(ent, pev_origin, sentryOrigin)
		pev(ent, pev_angles, newAngle)

		newAngle[1] = floatatan((closestOrigin[1] - sentryOrigin[1]) / (closestOrigin[0] - sentryOrigin[0]), radian) * 57
		if (closestOrigin[0] < sentryOrigin[0])
			newAngle[1] -= 180.0
		
		set_pev(ent, pev_angles, newAngle)
		set_pev(ent, pev_controller_1, floatround(127.0 - (3 * (floatatan((closestOrigin[2] - sentryOrigin[2]) / vector_distance(sentryOrigin, closestOrigin), radian) * 57))))
	}
}

stock FX_Trace(const Float:idorigin[3], const Float:targetorigin[3])
{
	new id[3], target[3]
	FVecIVec(idorigin, id)
	FVecIVec(targetorigin, target)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(6)//TE_TRACER
	write_coord(id[0])
	write_coord(id[1])
	write_coord(id[2])
	write_coord(target[0])
	write_coord(target[1])
	write_coord(target[2])
	message_end()
}

stock bool:is_hull_default(Float:origin[3], const Float:BOUNDS)
{
	new Float:traceEnds[8][3], Float:traceHit[3], j;
	traceEnds[0][0] = origin[0] - BOUNDS
	traceEnds[0][1] = origin[1] - BOUNDS
	traceEnds[0][2] = origin[2] - BOUNDS
	
	traceEnds[1][0] = origin[0] - BOUNDS
	traceEnds[1][1] = origin[1] - BOUNDS
	traceEnds[1][2] = origin[2] + BOUNDS
	
	traceEnds[2][0] = origin[0] + BOUNDS
	traceEnds[2][1] = origin[1] - BOUNDS
	traceEnds[2][2] = origin[2] + BOUNDS
	
	traceEnds[3][0] = origin[0] + BOUNDS
	traceEnds[3][1] = origin[1] - BOUNDS
	traceEnds[3][2] = origin[2] - BOUNDS
	
	traceEnds[4][0] = origin[0] - BOUNDS
	traceEnds[4][1] = origin[1] + BOUNDS
	traceEnds[4][2] = origin[2] - BOUNDS
	
	traceEnds[5][0] = origin[0] - BOUNDS
	traceEnds[5][1] = origin[1] + BOUNDS
	traceEnds[5][2] = origin[2] + BOUNDS
	
	traceEnds[6][0] = origin[0] + BOUNDS
	traceEnds[6][1] = origin[1] + BOUNDS
	traceEnds[6][2] = origin[2] + BOUNDS
	
	traceEnds[7][0] = origin[0] + BOUNDS
	traceEnds[7][1] = origin[1] + BOUNDS
	traceEnds[7][2] = origin[2] - BOUNDS
	
	for (new i = 0; i < 8; i++)
	{
		if (fm_point_contents(traceEnds[i]) != CONTENTS_EMPTY) return true
		if (fm_trace_line(0, origin, traceEnds[i], traceHit) != 0) return true

		for (j = 0; j < 3; j++)
			if (traceEnds[i][j] != traceHit[j]) return true
	}
	
	return false
}

stock get_speed_vector(const Float:origin1[3], const Float:origin2[3], Float:force, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(force*force / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
}