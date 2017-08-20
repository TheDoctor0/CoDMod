

#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>
#include <fun>

new bool:g_NitrogenGalil[33]
new NitrogenGalilSpr

new const nazwa[] = "Weteran Galil";
new const opis[] = "1/2 szansy na zamrozenie wroga";
new const bronie = 1<<CSW_GALIL;
new const zdrowie = 10;
new const kondycja = 20;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new bool:ma_klase[33];

public plugin_init() {
	register_plugin(nazwa, "1.1", "edit by Eustachy8");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
}

public plugin_precache() 
{
	NitrogenGalilSpr = precache_model("sprites/shockwave.spr");
}

public cod_class_enabled(id, itemid)
{
	ma_klase[id] = true;
	g_NitrogenGalil[id] = true;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	g_NitrogenGalil[id] = false
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim) || attacker == victim || !attacker)
	return HAM_IGNORED
	
	if(!ma_klase[attacker])
	return HAM_IGNORED;
	
	static Float:originF[3]
	pev(victim, pev_origin, originF)
		
	if (g_NitrogenGalil[attacker] && get_user_weapon(attacker) == CSW_GALIL &&  random_num(1,2) == 1)
	{	
		if(cs_get_user_team(attacker) == cs_get_user_team(victim))
		return HAM_IGNORED
		
		set_pev(victim, pev_velocity, Float:{0.0,0.0,0.0}) // stop motion
		set_pev(victim, pev_maxspeed, 15.0) // prevent from moving
		
		
		Effects(originF)
		
	}

	return PLUGIN_HANDLED;
}

//___________/ Effects \___________________________________________________________________________________________
//**************************************************************************************************************************/
Effects(const Float:originF3[3])
{
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF3, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF3[0]) // x
	engfunc(EngFunc_WriteCoord, originF3[1]) // y
	engfunc(EngFunc_WriteCoord, originF3[2]) // z
	engfunc(EngFunc_WriteCoord, originF3[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF3[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF3[2]+100.0) // z axis
	write_short(NitrogenGalilSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(41) // red
	write_byte(138) // green
	write_byte(255) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}
