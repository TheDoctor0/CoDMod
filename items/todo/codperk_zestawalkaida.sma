#include <amxmodx>
#include <hamsandwich>
#include fakemeta
#include <codmod>

#define DMG_HEGRENADE (1<<24)

new const perk_name[] = "Zestaw Alkaida";
new const perk_desc[] = "Dostajesz AK47 oraz 1/4 z HE";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Hajto");
	
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 1);
}

public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_AK47);
      cod_give_weapon(id, CSW_HEGRENADE);
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_AK47);
      cod_take_weapon(id, CSW_HEGRENADE);
	ma_perk[id] = false;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(is_user_connected(idattacker) && get_user_team(this) != get_user_team(idattacker) && ma_perk[idattacker] && !random(4) && damagebits & DMG_HEGRENADE)
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