#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>

new gfwCreateFinish;
new gfwFinished;
new gfwStarted;

new const giColorRun[][3]= {
	{100, 0, 0},
	{50, 0, 0},
	{10, 0, 0}
};

new const giColorFinished[][3]= {
	{0, 100, 0},
	{0, 50, 0},
	{0, 10, 0}
}

#define BLIFE 3

new const gszFinish[] = "drfinish";

public cmdFinish(id, level, cid){
	if(!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED;
		
	gbFinished[id] = true;
		
	new Float:fOrigin[3];
	pev(id, pev_origin, fOrigin);
		
	createFinish(id, fOrigin);
	
	gbEntityMoved = true;
	
	return PLUGIN_HANDLED;
}
createFinishI(id, x, y, z){
	if(!x && !y && !z) return;
	
	new Float:fOrigin[3];
	fOrigin[0] = float(x);
	fOrigin[1] = float(y);
	fOrigin[2] = float(z);
	
	createFinish(id, fOrigin);
}
public createFinish(id, const Float:fOrigin[3]){	
	if(pev_valid(gEntFinish))
		remove_entity(gEntFinish);
		
	gEntFinish = 0;
	if(ExecuteForward(gfwCreateFinish, gEntFinish, id, PrepareArray(_:fOrigin, 3), get_pcvar_num(gcvarDrawFinish)) && pev_valid(gEntFinish))
		return;
		
	new ent = create_entity("trigger_multiple");
	set_pev(ent, pev_classname, gszFinish);
	
	set_pev(ent, pev_origin, fOrigin);
	dllfunc(DLLFunc_Spawn, ent);
	
	entity_set_size(ent, Float:{-100.0, -100.0, -50.0}, Float:{100.0, 100.0, 50.0});
	
	
	set_pev(ent, pev_solid, SOLID_TRIGGER);
	set_pev(ent, pev_movetype, MOVETYPE_NONE);
	
	gEntFinish = ent;
	
	set_pev(ent, pev_nextthink, get_gametime()+BLIFE);
}

public fwThink(ent){
	if(get_pcvar_num(gcvarDrawFinish)){
		for(new id=0;id<33;id++)
			is_user_alive(id) && Create_Box(id, ent);
	}
			
	set_pev(ent, pev_nextthink, get_gametime()+BLIFE);
}
public fwTouch(ent, id){
	if(gfStartRun[id] <= 0.0)
		return;
		
	if(!gbFinished[id]){
		Create_Box(id, ent);
		gbFinished[id] = true;
		fwFinished(id);
	}
	
}
public fwTouch2(id, ent){
	fwTouch(ent, id);
}

//Based on m_eel`s code by Miczu
stock Create_Box(id, ent){
	if(gfStartRun[id] <= 0.0) return;
	
	new Float:maxs[3], Float:mins[3];
	pev(ent, pev_absmax, maxs);
	pev(ent, pev_absmin, mins);
	
	new Float:fOrigin[3];
	pev(ent, pev_origin, fOrigin);
	
	new Float:fOff = -5.0;
	new Float:z;
	for(new i=0;i<3; i++){
		z = fOrigin[2]+fOff;
		DrawLine(id, i, maxs[0], maxs[1], z, mins[0], maxs[1], z);
		DrawLine(id, i, maxs[0], maxs[1], z, maxs[0], mins[1], z);
		DrawLine(id, i, maxs[0], mins[1], z, mins[0], mins[1], z);
		DrawLine(id, i, mins[0], mins[1], z, mins[0], maxs[1], z);
		
		fOff += 5.0;
	}
}

public DrawLine(id, i, Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2) {
	new Float:start[3], Float:stop[3];
	start[0] = x1;
	start[1] = y1;
	start[2] = z1;
	
	stop[0] = x2;
	stop[1] = y2;
	stop[2] = z2;
	Create_Line(id, i, start, stop);
}

stock Create_Line(id, num, const Float:start[], const Float:stop[])
{
	new iColor[3];
	if(gbFinished[id]){
		iColor[0] = giColorFinished[num][0];
		iColor[1] = giColorFinished[num][1];
		iColor[2] = giColorFinished[num][2];
	}else{
		iColor[0] = giColorRun[num][0];
		iColor[1] = giColorRun[num][1];
		iColor[2] = giColorRun[num][2];
	}
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord, start[0])
	engfunc(EngFunc_WriteCoord, start[1])
	engfunc(EngFunc_WriteCoord, start[2])
	engfunc(EngFunc_WriteCoord, stop[0])
	engfunc(EngFunc_WriteCoord, stop[1])
	engfunc(EngFunc_WriteCoord, stop[2])
	write_short(gsprite)
	write_byte(1)
	write_byte(5)
	write_byte(10*BLIFE)
	write_byte(50)
	write_byte(0)
	write_byte(iColor[0])	// RED
	write_byte(iColor[1])	// GREEN
	write_byte(iColor[2])	// BLUE					
	write_byte(250)	// brightness
	write_byte(5)
	message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
