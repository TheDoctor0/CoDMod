#include <amxmodx>
#include <fakemeta>
#include <xs>
#include <codmod>
#include <engine>

#define ADMIN_FLAG_X (1<<23)

new bool:caughtJump[33]
new bool:doJump[33]
new Float:jumpVeloc[33][3]
new newButton[33]
new numJumps[33]

new g_pCvar;

new const nazwa[] = "Ninja";
new const opis[] = "Ma daleki zasieg noza oraz moze skakac po scianach";
new const bronie = 1<<CSW_MP5NAVY | 1<<CSW_SCOUT;
new const zdrowie = 30;
new const kondycja = 20;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new ma_klase[33]

public plugin_init()
{
	register_plugin(nazwa, "1.0", "SeeK");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	g_pCvar = register_cvar("codclass_ninja_zasieg", "30.0");
	register_cvar("codclass_ninja_sila", "300.0")
	
	register_forward(FM_TraceLine, "fwTraceline")
	register_forward(FM_TraceHull, "fwTracehull", 1)
	
	register_touch("player", "worldspawn", "Touch_World")
	register_touch("player", "func_wall", "Touch_World")
	register_touch("player", "func_breakable", "Touch_World")
}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_FLAG_X))
	{
		client_print(id, print_chat, "[%s] Nie masz uprawnien, aby uzywac tej klasy.",nazwa)
		ma_klase[id] = false
		return COD_STOP;
	}
	ma_klase[id] = true
	
	return COD_CONTINUE
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
}

public fwTraceline(Float:fStart[3], Float:fEnd[3], conditions, id, ptr){
	return vTrace(id, ptr,fStart,fEnd,conditions)
}

public fwTracehull(Float:fStart[3], Float:fEnd[3], conditions, hull, id, ptr){
	return vTrace(id, ptr,fStart,fEnd,conditions,true,hull)
}

vTrace(id, ptr,Float:fStart[3],Float:fEnd[3],iNoMonsters,bool:hull = false,iHull = 0)
{
		
	if (is_user_alive(id) && get_user_weapon(id) == CSW_KNIFE && ma_klase[id])
	{
		
		xs_vec_sub(fEnd,fStart,fEnd)
		xs_vec_mul_scalar(fEnd,get_pcvar_float(g_pCvar),fEnd);
		xs_vec_add(fEnd,fStart,fEnd);
		
		hull ? engfunc(EngFunc_TraceHull,fStart,fEnd,iNoMonsters,iHull,id,ptr) : engfunc(EngFunc_TraceLine,fStart,fEnd,iNoMonsters, id,ptr)
	}
	
	return FMRES_IGNORED;
}

public client_disconnect(id) 
{
	if (!ma_klase[id])
		return;
		
	caughtJump[id] = false
	doJump[id] = false
	for(new x=0;x<3;x++)
		jumpVeloc[id][x] = 0.0
	newButton[id] = 0
	numJumps[id] = 0
}

public client_PreThink(id)
{
	if (!ma_klase[id])
		return;
		
	if (is_user_alive(id)) 
	{
		newButton[id] = get_user_button(id)
		new oldButton = get_user_oldbutton(id)
		new flags = get_entity_flags(id)
		
		//reset if we are on ground
		if (caughtJump[id] && (flags & FL_ONGROUND)) 
		{
			numJumps[id] = 0
			caughtJump[id] = false
		}
		
		//begin when we jump
		if ((newButton[id] & IN_JUMP) && (flags & FL_ONGROUND) && !caughtJump[id] && !(oldButton & IN_JUMP) && !numJumps[id]) 
		{
			caughtJump[id] = true
			entity_get_vector(id,EV_VEC_velocity,jumpVeloc[id])
			jumpVeloc[id][2] = get_cvar_float("codclass_ninja_sila")
		}
	}
}

public client_PostThink(id) 
{
	if (!ma_klase[id])
		return;
		
	if (is_user_alive(id)) 
	{
		//do velocity if we walljumped
		if (doJump[id]) 
		{
			entity_set_vector(id,EV_VEC_velocity,jumpVeloc[id])
			
			doJump[id] = false
		}
	}
}

public Touch_World(id, world) 
{
	if (!ma_klase[id])
		return;
		
	if (is_user_alive(id)) 
	{
		//if we touch wall and have jump pressed, setup for jump
		if (caughtJump[id] && (newButton[id] & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND)) 
		{
			
			//reverse velocity
			for(new x=0;x<2;x++)
				jumpVeloc[id][x] *= -1.0
				
			numJumps[id]++
			doJump[id] = true
		}	
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
