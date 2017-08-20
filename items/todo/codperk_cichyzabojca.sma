#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <engine>
#include <fakemeta>

#define m_fWeaponState 74
#define WEAPONSTATE_USP_SILENCED 1

new const perk_name[] = "Cichy Zabojca";
new const perk_desc[] = "-20hp, 1/5 na natychmiastowe zabicie z USP jesli ma zalozony tlumik.";

new bool:ma_perk[33]

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
}

public cod_perk_enabled(id)
{
	cod_give_weapon(id, CSW_USP);
	ma_perk[id] = true;
	cod_add_user_bonus_health(id, -20);
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_USP);
	ma_perk[id] = false;
	cod_add_user_bonus_health(id, 20);
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
    if(!is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker) || !ma_perk[idattacker])
        return HAM_IGNORED;

    if(get_user_weapon(idattacker) == CSW_USP && damagebits & (1<<1) && !random(5)) 
    {
            if(get_pdata_int(get_pdata_cbase(idattacker, 373, 5), m_fWeaponState, 4) & WEAPONSTATE_USP_SILENCED)
                  KillPlayer(this, idinflictor, idattacker, (1<<1))
    }
        
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
      write_string("usp")
	message_end()
}