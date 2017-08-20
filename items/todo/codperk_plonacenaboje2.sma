#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include hamsandwich

#define nazwa "Plonace Naboje"
#define opis "Masz 1/LW szans jak strzelisz do gracza to go podpalisz."

#define TASKID_FLAME 9183

new sprite_fire,
bool:ma_perk[33],
wartosc_perku[33];

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "Cypis")
	
	cod_register_perk(nazwa, opis, 2, 6);

	RegisterHam(Ham_Spawn, "player", "fwSpawnPost", 1)
	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamagePost", 1)
}

public plugin_precache()
{
	sprite_fire = precache_model("sprites/fire.spr")
}

public cod_perk_enabled(id, wartosc)
{
	wartosc_perku[id] = wartosc;
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public fwSpawnPost(id)
      remove_task(id+TASKID_FLAME)

public fwTakeDamagePost(id, idinflictor, attacker, Float:damage, dmgbits)
{
	if(!is_user_connected(attacker) || get_user_team(id) == get_user_team(attacker)) return;
	
	if((dmgbits & 1<<1) && ma_perk[attacker] && !random(wartosc_perku[attacker]))
	{
		if(task_exists(id+TASKID_FLAME))
			remove_task(id+TASKID_FLAME);
      
		new data[2]
		data[0] = id
		data[1] = attacker
		set_task(0.8, "burning_flame", id+TASKID_FLAME, data, 2, "a", 20);
	}
}

public burning_flame(data[2])
{
	new id = data[0]
	
	if(!is_user_alive(id))
	{
		remove_task(id+TASKID_FLAME);
		return;
	}
	
	new origin[3];
	get_user_origin(id, origin)

	ExecuteHam(Ham_TakeDamage, id, data[1], data[1], 1.0, 1<<3)
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE)
	write_coord(origin[0]+random_num(-5,5))
	write_coord(origin[1]+random_num(-5,5))
	write_coord(origin[2]+random_num(-10,10))
	write_short(sprite_fire)
	write_byte(random_num(5,10))
	write_byte(200)
	message_end()
}	