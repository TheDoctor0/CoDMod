#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <engine>
#include <fakemeta>

#define FL_ONGROUND2    (FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER | FL_CONVEYOR | FL_FLOAT | FL_FLY) 

new const nazwa[]   = "Lewiter";
new const opis[]    = "Masz 1/6 szansy na wybicie wroga w powietrze oraz gdy on sie w nim znajduje zadajesz mu 2 razy wieksze dmg";
new const bronie    = (1<<CSW_M4A1);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new ma_klase[33];

public plugin_init()
{
	register_plugin( "Lewiter", "1.0", "GoldenKill" );

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	ma_klase[id] = 1;
}

public cod_class_disabled(id)
{
	ma_klase[id] = 0;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
	return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
	return HAM_IGNORED;

	if(random_num(1,6) == 1)
	{
		new Float: polozenie[3];
		polozenie[0]= 0.0;
		polozenie[1]= 0.0;
		polozenie[2]= 0.0;
		set_pev(this, pev_velocity, polozenie);
		polozenie[2] = random_float( 800.0 , 1000.0 );
		set_pev(this, pev_velocity, polozenie);
	}
	if(is_user_in_air(this))
	cod_inflict_damage(idattacker, this, damage*2, 0.0, idinflictor, damagebits);

	return HAM_IGNORED;
}

stock bool:is_user_in_air(id) 
{ 
	if( !(pev(id, pev_flags) & FL_ONGROUND2) ) 
	return true 
	else 
	return false 
	return false 
}