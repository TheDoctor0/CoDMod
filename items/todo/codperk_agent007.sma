#include <amxmodx>
#include <hamsandwich>
#include fakemeta
#include <codmod>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Agent 007";
new const perk_desc[] = "1/6 na natychmiastowe zabicie z p228 i +10 obrazen z niego";

new bool:ma_perk[33];

public plugin_init()
{
      register_plugin(perk_name, "1.0", "RiviT");
  
      cod_register_perk(perk_name, perk_desc);
        
      RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_perk_enabled(id)
{
      cod_give_weapon(id, CSW_P228);
      ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
      cod_take_weapon(id, CSW_P228);
      ma_perk[id] = false;
}
  
public TakeDamage(this, idinflictor, idattacker, Float:damage, dmgbits)
{
	if(is_user_connected(idattacker) && get_user_team(idattacker) != get_user_team(this) && ma_perk[idattacker] && get_user_weapon(idattacker) == CSW_P228 && dmgbits & DMG_BULLET)
      {
      	if(!random(6))
            {
                  KillPlayer(this, idinflictor, idattacker, (1<<1))
                  return HAM_IGNORED
            }

            SetHamParamFloat(4, damage+10)
            return HAM_HANDLED
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
      write_string("p228")
	message_end()
}