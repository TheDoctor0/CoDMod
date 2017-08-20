#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <codmod>
#include <hamsandwich>

#define CZAS 2 //SEKUNDY NIEWIDZIALNOSCI
#define DMG_HEGRENADE (1<<24)

new const nazwa[] = "Predator";
new const opis[] = "Ma 2 sekundy niewidzialnosci co runde, 1/3 z HE, 480 grawitacji";
new const bronie = 1<<CSW_FAMAS | 1<<CSW_HEGRENADE;
new const zdrowie = 5;
new const kondycja = 5;
new const inteligencja = 5;
new const wytrzymalosc = 15;

new bool:wykorzystal[33], bool:ma_klase[33];

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Darmowe");
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1)
	
      RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	wykorzystal[id] = false;
	set_pev(id, pev_gravity, 0.6);
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	cod_remove_user_rendering(id)
}

public cod_class_skill_used(id)
{
	if(wykorzystal[id])
	{
		client_print (id, print_center, "Wykorzystales niewidzialnosc");
		return;
	}
	
	wykorzystal[id] = true;
	
	cod_set_user_rendering(id, 1)
	set_task(CZAS.0, "wylacz", id);
	
	message_begin(MSG_ONE, get_user_msgid("BarTime"), _, id)
	write_short(CZAS)
	message_end()
}

public wylacz(id)
{
	if(!is_user_connected(id)) return;
	
	cod_remove_user_rendering(id)
}

public Spawn(id)
{
	if(ma_klase[id])
	{
		set_pev(id, pev_gravity, 0.6);
            wykorzystal[id] = false;
	}
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
      if(!is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker))
            return HAM_IGNORED;

      if(!ma_klase[idattacker])
            return HAM_IGNORED;

      if(damagebits & DMG_HEGRENADE && !random(3))
            KillPlayer(this, idinflictor, idattacker, DMG_HEGRENADE)

      return HAM_IGNORED;
}

KillPlayer(id, inflictor, attacker, damagebits)
{
	static DeathMsgId
	
	new msgblock, effect
	if (!DeathMsgId)	DeathMsgId = get_user_msgid("DeathMsg")
	
	msgblock = get_msg_block(DeathMsgId)
	set_msg_block(DeathMsgId, BLOCK_ONCE)
	
	set_pdata_int(id, 75, HIT_GENERIC, 5)
	set_pdata_int(id, 76, damagebits, 5)
	
	ExecuteHamB(Ham_Killed, id, attacker, 1)
	
	set_pev(id, pev_dmg_inflictor, inflictor)
	
	effect = pev(id, pev_effects)
	if(effect & 128)	set_pev(id, pev_effects, effect-128)
	
	set_msg_block(DeathMsgId, msgblock)

	message_begin(MSG_ALL, DeathMsgId)
	write_byte(attacker)
	write_byte(id)
	write_byte(0)
      write_string("grenade")
	message_end()
}