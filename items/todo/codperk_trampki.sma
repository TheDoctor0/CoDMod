/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <engine>

#define	FL_WATERJUMP	(1<<11)	// popping out of the water
#define	FL_ONGROUND	(1<<9)	// not moving on the ground

new nazwa[] = "Trampki";
new opis[] = "Dostajesz 20 kondycji oraz masz auto bh";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "bulka_z_maslem");
	
	cod_register_perk(nazwa, opis);
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0)+20);
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	cod_set_user_bonus_trim(id, cod_get_user_trim(id, 0, 0)-20);
}
	
public client_PreThink(id)
{
	if(!ma_perk[id])
		return PLUGIN_CONTINUE
	if (entity_get_int(id, EV_INT_button) & 2) {	
		new flags = entity_get_int(id, EV_INT_flags)
		
		if (flags & FL_WATERJUMP)
			return PLUGIN_CONTINUE
		if ( entity_get_int(id, EV_INT_waterlevel) >= 2 )
			return PLUGIN_CONTINUE
		if ( !(flags & FL_ONGROUND) )
			return PLUGIN_CONTINUE
		
		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)
		velocity[2] += 250.0
		entity_set_vector(id, EV_VEC_velocity, velocity)
		
		entity_set_int(id, EV_INT_gaitsequence, 6)
		
	}
	return PLUGIN_CONTINUE
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
