#include <amxmodx>
#include <engine>
#include <codmod>
#include <hamsandwich>
#include <fun>

#define DMG_BULLET (1<<1)

new const nazwa[] = "Dziki Jumper";
new const opis[] = "Ma autoBH, natychmiastowe z noza oraz jego widocznosc spada do 25";
new const bronie = 1<<CSW_KNIFE;
new const zdrowie = 100;
new const kondycja = 100;
new const inteligencja = 20;
new const wytrzymalosc = 30;

#define	FL_WATERJUMP	(1<<11)	// popping out of the water
#define	FL_ONGROUND	(1<<9)	// not moving on the ground

new bool:ma_klase[33]

public plugin_init() {
	register_plugin(nazwa, "1.0", "Harsay");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	RegisterHam(Ham_Spawn, "player", "Spawn", 1);	

        RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 25);
}
public cod_class_disabled(id)
{
	ma_klase[id] = false;
        set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255);
}

public client_PreThink(id)
{
	if (!ma_klase[id])
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
public Spawn(id)
{
	if (ma_klase[id])
	{
		strip_user_weapons(id);
		give_item(id, "weapon_knife");
	}
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if (!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if (!ma_klase[idattacker])
		return HAM_IGNORED;
		
	if (get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET && damage > 20.0)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}

