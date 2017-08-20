#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <xs>

#define nazwa "Plonace Naboje"
#define opis "Masz 1/LW szans jak strzelisz do gracza to go podpalisz."

new sprite_fire,
	sprite_smoke;

new ma_perk[33] ,wartosc_perku[33], palenie_gracza[33];

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "Cypis")
	cod_register_perk(nazwa, opis, 2, 6);
	
	register_event("Damage", "Damage", "b", "2!=0");
}

public plugin_precache()
{
	sprite_fire = precache_model("sprites/fire.spr")
	sprite_smoke = precache_model("sprites/steam1.spr")
}

public cod_perk_enabled(id, wartosc)
{
	wartosc_perku[id] = wartosc;
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public Damage(id)
{
	new attacker = get_user_attacker(id);
	if(!is_user_alive(attacker) || id == attacker)
		return PLUGIN_CONTINUE;
	
	if(ma_perk[attacker] && random_num(1, wartosc_perku[attacker]) == 1)
	{
		if(task_exists(id+2936))
			remove_task(id+2936);
		palenie_gracza[id] = 25;
		new data[2]
		data[0] = id
		data[1] = attacker
		set_task(0.2, "burning_flame", id+2936, data, 2, "b");
	}
	return PLUGIN_CONTINUE;
}

public burning_flame(data[2])
{
	new id = data[0]
	
	if(!is_user_alive(id))
	{
		palenie_gracza[id] = 0
		remove_task(id+2936);
		return PLUGIN_CONTINUE;
	}
	
	new origin[3], flags = pev(id, pev_flags)
	get_user_origin(id, origin)
	
	if(flags & FL_INWATER || palenie_gracza[id] < 1 || !get_user_health(id))
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_SMOKE)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]-50)
		write_short(sprite_smoke)
		write_byte(random_num(15,20))
		write_byte(random_num(10,20))
		message_end()
		
		remove_task(id+2936);
		return PLUGIN_CONTINUE;
	}
	
	if(flags & FL_ONGROUND)
	{
		static Float:velocity[3]
		pev(id, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, 0.5, velocity)
		set_pev(id, pev_velocity, velocity)
	}
	cod_inflict_damage(data[1], id, 1.0, 0.0, 0, 1<<24);
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE)
	write_coord(origin[0]+random_num(-5,5))
	write_coord(origin[1]+random_num(-5,5))
	write_coord(origin[2]+random_num(-10,10))
	write_short(sprite_fire)
	write_byte(random_num(5,10))
	write_byte(200)
	message_end()
	
	palenie_gracza[id]--
	return PLUGIN_CONTINUE;
}	
