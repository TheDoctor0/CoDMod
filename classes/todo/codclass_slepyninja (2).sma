#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
#include <fakemeta>


#define ZADANIE_WSKRZES 6240
#define DMG_BULLET (1<<1)

new const nazwa[]   = "Slepy Ninja [Premium Gold]";
new const opis[]    = "1/4 na odrodzenie siê, 1/2awp, 15% widoczny na no¿u, 1/2 z no¿a [PPM], 300 grawitacji ";
new const bronie    = (1<<CSW_AWP)|(1<<CSW_MP5NAVY);
new const zdrowie   = 35;
new const kondycja  = 50;
new const inteligencja = 10;
new const wytrzymalosc = 40;

new ostatnio_prawym[33];

new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("CurWeapon", "eventKnife_Niewidzialnosc", "be", "1=1");
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);
	
	
	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage_JedenCios");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fwPrimaryAttack_JedenCios");
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fwSecondaryAttack_JedenCios");
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	RegisterHam(Ham_Killed, "player", "Killed", 1);
}

public cod_class_enabled(id)
{
	if (!(get_user_flags(id) & ADMIN_LEVEL_E))
	{
		client_print(id, print_chat, "[Slepy Ninja [Premium Gold]] Nie masz uprawnien, aby uzywac tej klasy.")
		return COD_STOP;
	}
	entity_set_float(id, EV_FL_gravity, 300.0/800.0);
	ma_klase[id] = true;
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	
	entity_set_float(id, EV_FL_gravity, 1.0);
	ma_klase[id] = false;
	
}

public eventKnife_Niewidzialnosc(id)
{
	if (!ma_klase[id])
		return;
	
	if ( read_data(2) == CSW_KNIFE )
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 40);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}

public fwSpawn_Grawitacja(id)
{
	if (ma_klase[id])
		entity_set_float(id, EV_FL_gravity, 300.0/800.0);
}


public fwTakeDamage_JedenCios(id, ent, attacker)
{
	if (is_user_alive(attacker) && ma_klase[attacker] && get_user_weapon(attacker) == CSW_KNIFE && random_num(1,2) == 1 && ostatnio_prawym[id])
	{
		cs_set_user_armor(id, 0, CS_ARMOR_NONE);
		SetHamParamFloat(4, float(get_user_health(id) + 1));
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}

public fwPrimaryAttack_JedenCios(ent)
{
	new id = pev(ent, pev_owner);
	ostatnio_prawym[id] = 1;
}

public fwSecondaryAttack_JedenCios(ent)
{
	new id = pev(ent, pev_owner);
	ostatnio_prawym[id] = 0;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if (!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if (!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if (!(damagebits & DMG_BULLET))
		return HAM_IGNORED;
	
	if (get_user_weapon(idattacker) == CSW_AWP && random_num(1,2) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
public Killed(id)
{
	if (ma_klase[id] && random_num(1, 4) == 1)
		set_task(0.1, "Wskrzes", id+ZADANIE_WSKRZES);
}

public Wskrzes(id)
	ExecuteHamB(Ham_CS_RoundRespawn, id-ZADANIE_WSKRZES);

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
