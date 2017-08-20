#include <amxmodx>
#include <fakemeta>
#include <hamsandwich> 
#include <engine>  
#include <codmod>
#include <xs>
#include <ColorChat>

new bool:ma_klase[33];

new const nazwa[] = "Astronauta";
new const opis[] = "Kazdy skok ma inny (od 150 do 650 unitow/sec).Ma no recoila.Dostaje galila i he.";
new const bronie = 1<<CSW_GALIL | 1<<CSW_HEGRENADE;
new const zdrowie = 0;
new const kondycja = 10;
new const inteligencja = 5;
new const wytrzymalosc = 15;

new Float: cl_pushangle[33][3]


const WEAPONS_BITSUM = (1<<CSW_KNIFE|1<<CSW_HEGRENADE|1<<CSW_FLASHBANG|1<<CSW_SMOKEGRENADE|1<<CSW_C4)
//Tutaj wyzej nic nie zmieniaj


public plugin_init()   
{   
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	new weapon_name[24]
	for (new i = 1; i <= 30; i++)
	{
		if (!(WEAPONS_BITSUM & 1 << i) && get_weaponname(i, weapon_name, 23))
		{
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_Weapon_PrimaryAttack_Pre")
			RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_Weapon_PrimaryAttack_Post", 1)
                        RegisterHam(Ham_TakeDamage, "player", "TakeDamage")
		}
	}


}

public cod_class_enabled(id)
{
	ColorChat(id, GREEN, "Zapraszamy na www.OnlyFPS.pl", nazwa);
	ma_klase[id] = true;
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
}
public client_PreThink(id)   
{
	if(ma_klase[id]==true){

	if(!is_user_connected(id) || !is_user_alive(id)) 
		return PLUGIN_CONTINUE 
           
	if((get_user_button(id) & IN_JUMP) && !(get_user_oldbutton(id) & IN_JUMP))   
	{   
		new flags = entity_get_int(id, EV_INT_flags)   
		new waterlvl = entity_get_int(id, EV_INT_waterlevel)   
           
		if (!(flags & FL_ONGROUND))   
			return PLUGIN_CONTINUE   
		if (flags & FL_WATERJUMP)   
			return PLUGIN_CONTINUE   
		if (waterlvl > 1)   
			return PLUGIN_CONTINUE   
                   
		new Float:fVelocity[3]   
		entity_get_vector(id, EV_VEC_velocity, fVelocity)   
		fVelocity[2] += random_float(150.0 ,650.0)  
           
		entity_set_vector(id, EV_VEC_velocity, fVelocity)   
		entity_set_int(id, EV_INT_gaitsequence, 6)   
  	}  
 	} 
	return PLUGIN_CONTINUE
}    
public fw_Weapon_PrimaryAttack_Post(entity)
{
	new id = pev(entity, pev_owner)

	if (ma_klase[id]==true)
	{
		new Float: push[3]
		pev(id, pev_punchangle, push)
		xs_vec_sub(push, cl_pushangle[id], push)
		xs_vec_mul_scalar(push, 0.0, push)
		xs_vec_add(push, cl_pushangle[id], push)
		set_pev(id, pev_punchangle, push)
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
}

public fw_Weapon_PrimaryAttack_Pre(entity)
{
	new id = pev(entity, pev_owner)

	if (ma_klase[id]==true)
	{
		pev(id, pev_punchangle, cl_pushangle[id])
		return HAM_IGNORED;
	}
	return HAM_IGNORED;
} 

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(this))
		return HAM_IGNORED;
	
	if(!ma_klase[this])
		return HAM_IGNORED;
	
	if(damagebits & DMG_FALL)
		return HAM_SUPERCEDE;
		
	return HAM_IGNORED;
}