#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
        
new const perk_name[] = "Atak od tylu";
new const perk_desc[] = "Przy trafieniu masz szanse na teleport za gracza";

new ma_perk[33];
new origin[33][3];
new originn[33][3];

new bool:ma_perk[33], wartosc_perku[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "amxx.pl :)");
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);

}
public cod_perk_enabled(id)
{
	ma_perk[id] = true;
}
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}	
 
public SzansaNaHeadshot_TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
if(!is_user_alive(idattacker) || !ma_perk[idattacker])
return HAM_IGNORED;
 
if(get_user_team(idattacker) == get_user_team(this)) //ofiara musi byc wrogiem
return HAM_IGNORED;
 
if(damagebits & (1<<1) && random_num(1,7)==1) //zamieniamy sama 7, teraz jest 1/7
{
new Float:fVec[3];
if(!is_user_alive(this)) //ofiara musi zyc
return HAM_IGNORED;
get_user_origin(idattacker, originn[idattacker]) //zapamietywanie pozycji gracza
get_user_origin(this, origin[idattacker])//pobieranie pozycji przeciwnika
pev(this, pev_v_angle, fVec ); 
fVec[2] = -fVec[2];
 
//Znormalizowany wektor przeciwny do wektora wzroku
angle_vector( fVec, ANGLEVECTOR_FORWARD, fVec );
 
//przedłużony do 50 jednostek
fVec[0] *= 50.0;
fVec[1] *= 50.0;
fVec[2] *= 50.0;
origin[idattacker][0] += floatround(fVec[0]) //os X, czyli lewo, prawo
origin[idattacker][1] += floatround(fVec[1]) - 125 //os Y czyli przod, tyl. jest na - zeby pojawic sie za przeciwnikiem
origin[idattacker][2] += floatround(fVec[2]) + 20 //os Z czyli ora, dol. jest na + zeby nie utknac w ziemi
set_user_origin(idattacker, origin[idattacker])
if(is_player_stuck(idattacker)) //sprawdzanie czy nie utknie sie w scianie
{
client_print(idattacker, print_center, "Pozycja nieosiagalna")
set_user_origin(idattacker, originn[idattacker]) //jezeli utnie sie w scia, to wraca do pozycji przed teleportem
}
}
 
return HAM_IGNORED;
}
 
stock bool:is_player_stuck(id) 
{
static Float:fOrigin[3];
pev(id, pev_origin, fOrigin);
engfunc(EngFunc_TraceHull, fOrigin, fOrigin, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0);
if(get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
return true;
return false;
}