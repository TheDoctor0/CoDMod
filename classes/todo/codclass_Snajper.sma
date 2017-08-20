#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include fakemeta

#define DMG_BULLET (1<<1)

#define zdrowie 20
#define kondycja 15
#define inteligencja 5
#define wytrzymalosc 20

new bool:ma_klase[33];
    
public plugin_init()
{
      new const nazwa[]   = "Snajper";
      new const opis[]    = "1/3 z noza PPM i LPM, zadaje 1+int dmg wiecej ze scouta";
      new const bronie    = (1<<CSW_SCOUT)|(1<<CSW_FLASHBANG)|(1<<CSW_DEAGLE);

	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Darmowe");

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
	ma_klase[id] = true

public cod_class_disabled(id)
    ma_klase[id] = false

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;

	if(!ma_klase[idattacker])
		return HAM_IGNORED;

      if(damagebits & DMG_BULLET)
      {
            switch(get_user_weapon(idattacker))
            {
                  case CSW_SCOUT:
                  {
                        SetHamParamFloat(4, damage+1+cod_get_user_intelligence(idattacker, 1, 1, 1))
                        return HAM_HANDLED
                  }
                  case CSW_KNIFE:
                  {
                        if(!random(3)) KillPlayer(this, idinflictor, idattacker, (1<<1))
                  }
            }
      }
	return HAM_IGNORED;
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
      write_string("knife")
	message_end()
}