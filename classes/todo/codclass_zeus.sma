#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>

#define MAX 32

#define x 0
#define y 1
#define z 2

new ilosc_blyskawic[33],poprzednia_blyskawica[33];
new const gszSound[] = "misc/piorun.wav";
new sprite_lgt, sprite_smoke;

new const nazwa[] = "Zeus";
new const opis[] = "Na E uderza piorunem, ktory rozpruwa przeciwka. Rozprucie spowalnia przeciwnika na 1 sekunde i zadaje mu 65 DMG + int/2";
new const bronie = 1<<CSW_P90;
new const zdrowie = 40;
new const kondycja = 30;
new const inteligencja = 0;
new const wytrzymalosc = 20;

new bool:ma_klase[33]

public plugin_init() {
	register_plugin(nazwa, "1.0", "sharkowy");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	
	register_event("ResetHUD", "ResetHUD", "abe");
}

public plugin_precache()
{
	sprite_smoke = precache_model("sprites/steam1.spr")
	sprite_lgt = precache_model("sprites/lgtning.spr")
	precache_sound(gszSound);
}

public cod_class_enabled(id)
{
	ilosc_blyskawic[id] = 5;
	ma_klase[id] = true;
}


public cod_class_disabled(id)
{
	ma_klase[id] = false;
	ilosc_blyskawic[id] = 0;
}

public cod_class_skill_used(id) {
	
	if (!is_user_alive(id)) return PLUGIN_HANDLED;
	
	if (!ilosc_blyskawic[id]) {
		return PLUGIN_HANDLED;
	}
	new target = Find_Best_Angle(id,750.0,false)
	
	if (!is_valid_ent(target))
	{
		client_print(id,print_center,"Brak celu w zasiegu 750")
		return PLUGIN_CONTINUE
	}
	
	if (is_user_alive(target)){
		if (get_user_team(target) == get_user_team(id)) {
			return PLUGIN_HANDLED;
		}
		
		if (poprzednia_blyskawica[id]+15.0>get_gametime()) {
			client_print(id,print_center,"Pioruna mozesz uzyc raz na 15 sek.");
			return PLUGIN_HANDLED;
		}
		poprzednia_blyskawica[id] = floatround(get_gametime());
		ilosc_blyskawic[id]--;
		
		puscBlyskawice(id, target);
	}
	return PLUGIN_HANDLED;
}

thunder_effects(Float:fl_Origin[3])
{
	new Float:fX = fl_Origin[0], Float:fY = fl_Origin[1], Float:fZ = fl_Origin[2]



	// Beam effect between two points
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, fl_Origin, 0)
	write_byte(TE_BEAMPOINTS)        // 0
	engfunc(EngFunc_WriteCoord, fX + 150.0)    // start position
	engfunc(EngFunc_WriteCoord, fY + 150.0)
	engfunc(EngFunc_WriteCoord, fZ + 800.0)
	engfunc(EngFunc_WriteCoord, fX)    // end position
	engfunc(EngFunc_WriteCoord, fY)
	engfunc(EngFunc_WriteCoord, fZ)
	write_short(sprite_lgt)    // sprite index
	write_byte(1)                    // starting frame
	write_byte(15)                    // frame rate in 0.1's
	write_byte(10)                    // life in 0.1's
	write_byte(80)                    // line width in 0.1's
	write_byte(30)                    // noise amplitude in 0.01's
	write_byte(232)                    // red
	write_byte(232)                    // green
	write_byte(0)                    // blue
	write_byte(250)                    // brightness
	write_byte(200)                    // scroll speed in 0.1's
	message_end()

	// Sparks
	message_begin(MSG_PVS, SVC_TEMPENTITY)
	write_byte(TE_SPARKS)            // 9
	engfunc(EngFunc_WriteCoord, fX)    // position
	engfunc(EngFunc_WriteCoord, fY)
	engfunc(EngFunc_WriteCoord, fZ + 10.0)
	message_end()

	// Smoke
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, fl_Origin, 0)
	write_byte(TE_SMOKE)            // 5
	engfunc(EngFunc_WriteCoord, fX)    // position
	engfunc(EngFunc_WriteCoord, fY)
	engfunc(EngFunc_WriteCoord, fZ + 10.0)
	write_short(sprite_smoke)        // sprite index
	write_byte(10)                    // scale in 0.1's
	write_byte(10)                    // framerate
	message_end()

	// Blood
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, fl_Origin, 0)
	write_byte(TE_LAVASPLASH)        // 10
	engfunc(EngFunc_WriteCoord, fX)    // position
	engfunc(EngFunc_WriteCoord, fY)
	engfunc(EngFunc_WriteCoord, fZ + 12.0)
	message_end()


}
puscBlyskawice(id, target){
	//Obrazenia
	new ent = create_entity("info_target");
	new Float:fl_Origin[3]
	pev(target, pev_origin, fl_Origin)   
	ExecuteHam(Ham_TakeDamage, target, id, id, 65.0+cod_get_user_intelligence(id)/2, 1);
	ScreenFade(target, 3, {232, 232, 0}, 80)
	message_begin(MSG_ONE,get_user_msgid("ScreenShake"),{0,0,0},target); 
	write_short(7<<14); 
	write_short(2<<13); 
	write_short(3<<14); 
	message_end();

	remove_entity(ent);

	//Piorun
	thunder_effects(fl_Origin)

	//Dzwiek
	emit_sound(id, CHAN_WEAPON, gszSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	emit_sound(target, CHAN_WEAPON, gszSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}


public ResetHUD(id) 
{
	if (ma_klase[id]) 
		ilosc_blyskawic[id] = 5;
}

stock Find_Best_Angle(id,Float:dist, same_team = false)
{
	new Float:bestangle = 0.0
	new winner = -1

	for (new i=0; i < MAX; i++)
	{
		if (!is_user_alive(i) || i == id || (get_user_team(i) == get_user_team(id) && !same_team))
		continue
		
		if (get_user_team(i) != get_user_team(id) && same_team)
		continue
		
		//User has spell immunity, don't target
		
		new Float:c_angle = Find_Angle(id,i,dist)
		
		if (c_angle > bestangle && Can_Trace_Line(id,i))
		{
			winner = i
			bestangle = c_angle
		}
		
	}
	
	return winner
}

stock Float:Find_Angle(Core,Target,Float:dist)
{
	new Float:vec2LOS[2]
	new Float:flDot	
	new Float:CoreOrigin[3]
	new Float:TargetOrigin[3]
	new Float:CoreAngles[3]
	
	pev(Core,pev_origin,CoreOrigin)
	pev(Target,pev_origin,TargetOrigin)
	
	if (get_distance_f(CoreOrigin,TargetOrigin) > dist)
	return 0.0
	
	pev(Core,pev_angles, CoreAngles)
	
	for ( new i = 0; i < 2; i++ )
	vec2LOS[i] = TargetOrigin[i] - CoreOrigin[i]
	
	new Float:veclength = Vec2DLength(vec2LOS)
	
	//Normalize V2LOS
	if (veclength <= 0.0)
	{
		vec2LOS[x] = 0.0
		vec2LOS[y] = 0.0
	}
	else
	{
		new Float:flLen = 1.0 / veclength;
		vec2LOS[x] = vec2LOS[x]*flLen
		vec2LOS[y] = vec2LOS[y]*flLen
	}
	
	//Do a makevector to make v_forward right
	engfunc(EngFunc_MakeVectors,CoreAngles)
	
	new Float:v_forward[3]
	new Float:v_forward2D[2]
	get_global_vector(GL_v_forward, v_forward)
	
	v_forward2D[x] = v_forward[x]
	v_forward2D[y] = v_forward[y]
	
	flDot = vec2LOS[x]*v_forward2D[x]+vec2LOS[y]*v_forward2D[y]
	
	if ( flDot > 0.5 )
	{
		return flDot
	}
	
	return 0.0	
}

stock Float:Vec2DLength( Float:Vec[2] )  
{ 
	return floatsqroot(Vec[x]*Vec[x] + Vec[y]*Vec[y] )
}

stock bool:Can_Trace_Line(id, target)
{	
	for (new i=-35; i < 60; i+=35)
	{		
		new Float:Origin_Id[3]
		new Float:Origin_Target[3]
		new Float:Origin_Return[3]
		
		pev(id,pev_origin,Origin_Id)
		pev(target,pev_origin,Origin_Target)
		
		Origin_Id[z] = Origin_Id[z] + i
		Origin_Target[z] = Origin_Target[z] + i
		
		trace_line(-1, Origin_Id, Origin_Target, Origin_Return) 
		
		if (get_distance_f(Origin_Return,Origin_Target) < 25.0)
		return true
		
	}
	
	return false
}

stock ScreenFade(target, Timer, Colors[3], Alpha) {	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, target);
	write_short((1<<12) * Timer)
	write_short(1<<12)
	write_short(0)
	write_byte(Colors[0])
	write_byte(Colors[1])
	write_byte(Colors[2])
	write_byte(Alpha)
	message_end()
}