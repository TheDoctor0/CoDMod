#include <amxmodx>
#include <codmod>
#include fakemeta
#include <hamsandwich>

new const perk_name[] = "Bron Smierci";
new const perk_desc[] = "Dostajesz AUG oraz 1/10 na zabicie z niego.";

new bool:ma_perk[33]

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 1)
}
public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_AUG)
	ma_perk[id] = true
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_AUG)
	ma_perk[id] = false
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(idattacker) == get_user_team(this))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker] && !random(10) && get_user_weapon(idattacker) == CSW_AUG && damagebits & (1<<1))
		KillPlayer(this, idinflictor, idattacker, (1<<1))
		
	return HAM_IGNORED	
}

KillPlayer(id, inflictor, attacker, damagebits)
{
	static DeathMsgId
	
	new msgblock, effect
	if (!DeathMsgId)	DeathMsgId = get_user_msgid("DeathMsg")
	
	msgblock = get_msg_block(DeathMsgId)
	set_msg_block(DeathMsgId, BLOCK_ONCE)
	
	set_pdata_int(id, 75, HIT_CHEST , 5)
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
      write_string("aug")
	message_end()
}