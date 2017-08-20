#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
#include <fun>

#define PLUGIN "[Perk] Naznaczony"
#define VERSION "1.0"
#define AUTHOR "MAGNET" /// Pomagali R3X oraz HubertTM

new origin[33][3];
new originn[33][3];
new uzyl[33];
new namierzony[33];
new naznaczony[33];


#define nazwa "Naznaczony"
#define opis "Uzyj aby naznaczyc przeciwnika i teleportowac sie za niego."

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	cod_register_perk(nazwa, opis);
	
	register_event("ResetHUD", "ResetHUD", "abe");
}

public plugin_precache()
{
precache_sound("misc/naznaczony.wav")
}

public cod_perk_used(id)
{
	new ofiara, body;
	new Float:fVec[3];
	
	if(!is_user_alive(id))
	return PLUGIN_CONTINUE;
	
	if(uzyl[id])
	{
		client_print(id, print_center, "Juz uzyles ta umiejetnosc")
		return PLUGIN_CONTINUE;
	}
	
	if(!namierzony[id])
	{
		get_user_aiming(id, ofiara, body)
		naznaczony[id] = ofiara;
		namierzony[id] = 1;
		client_cmd(id, "spk misc/naznaczony.wav")
		client_print(id, print_center, "Naznaczyles obiekt")
	}
	else
	{
		if(!is_user_alive(naznaczony[id]))
		{
		client_print(id, print_center, "Obiekt nie zyje. Wybierz inny cel")
		namierzony[id] = 0;
		}
		get_user_origin(id, originn[id])
		get_user_origin(naznaczony[id], origin[id])//pobieranie pozycji
		pev(naznaczony[id], pev_v_angle, fVec ); 
		fVec[2] = -fVec[2];

		//Znormalizowany wektor przeciwny do wektora wzroku
		angle_vector( fVec, ANGLEVECTOR_FORWARD, fVec );

		//przed³u¿ony do 50 jednostek
		fVec[0] *= 50.0;
		fVec[1] *= 50.0;
		fVec[2] *= 50.0;
		origin[id][0] += floatround(fVec[0])
		origin[id][1] += floatround(fVec[1]) - 125
		origin[id][2] += floatround(fVec[2]) + 20
		set_user_origin(id, origin[id])
		Sprawdz(id)
	}
	
	return PLUGIN_CONTINUE;
}
public Sprawdz(id)
{
	if(is_player_stuck(id))
	{
		client_print(id, print_center, "Pozycja nieosiagalna")
		set_user_origin(id, originn[id])
	}
	else
	{
		uzyl[id] = 1;
		client_print(id, print_center, "Faza taktyczna zakonczona")
	}
}	
public ResetHUD(id)
{
	uzyl[id] = 0;
	naznaczony[id] = 0;
	namierzony[id] = 0;
	origin[id][0] = 0;
	origin[id][1] = 0;
	origin[id][2] = 0;
}
stock bool:is_player_stuck(id) 
{
	static Float:fOrigin[3];
	
	pev(id, pev_origin, fOrigin);


	engfunc(EngFunc_TraceHull, fOrigin, fOrigin, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0);

	

	if(get_tr2(0, TR_StartSolid) 

			|| get_tr2(0, TR_AllSolid) 

			|| !get_tr2(0, TR_InOpen))

	return true;

	

	return false;

}
