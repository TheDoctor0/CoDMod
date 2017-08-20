#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <codmod>

new const perk_name[] = "Zaskoczenie Wroga";
new const perk_desc[] = "Atakujac wroga od tylu zadajesz podwojne obrazenia";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
}

public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
	ma_perk[id] = false;
	
public TakeDamage(this, idinflictor, idattacker, Float:damage)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
		
	if(UTIL_In_FOV(idattacker, this) && !UTIL_In_FOV(this, idattacker))
		SetHamParamFloat(4, damage * 2);
		
	return HAM_IGNORED;
}

stock bool:UTIL_In_FOV(id,target)
{
	if (Find_Angle(id,target,9999.9) > 0.0)
		return true;
	
	return false;
}

stock Float:Find_Angle(Core,Target,Float:dist)
{
	new Float:vec2LOS[2];
	new Float:flDot;
	new Float:CoreOrigin[3];
	new Float:TargetOrigin[3];
	new Float:CoreAngles[3];
	
	pev(Core,pev_origin,CoreOrigin);
	pev(Target,pev_origin,TargetOrigin);
	
	if (get_distance_f(CoreOrigin,TargetOrigin) > dist)
		return 0.0;
	
	pev(Core,pev_angles, CoreAngles);
	
	for ( new i = 0; i < 2; i++ )
		vec2LOS[i] = TargetOrigin[i] - CoreOrigin[i];
	
	new Float:veclength = Vec2DLength(vec2LOS);
	
	//Normalize V2LOS
	if (veclength <= 0.0)
	{
		vec2LOS[0] = 0.0;
		vec2LOS[1] = 0.0;
	}
	else
	{
		new Float:flLen = 1.0 / veclength;
		vec2LOS[0] = vec2LOS[0]*flLen;
		vec2LOS[1] = vec2LOS[1]*flLen;
	}
	
	//Do a makevector to make v_forward right
	engfunc(EngFunc_MakeVectors,CoreAngles);
	
	new Float:v_forward[3];
	new Float:v_forward2D[2];
	get_global_vector(GL_v_forward, v_forward);
	
	v_forward2D[0] = v_forward[0];
	v_forward2D[1] = v_forward[1];
	
	flDot = vec2LOS[0]*v_forward2D[0]+vec2LOS[1]*v_forward2D[1];
	
	if ( flDot > 0.5 )
	{
		return flDot;
	}
	
	return 0.0;
}

stock Float:Vec2DLength( Float:Vec[2] )  
	return floatsqroot(Vec[0]*Vec[0] + Vec[1]*Vec[1] );
