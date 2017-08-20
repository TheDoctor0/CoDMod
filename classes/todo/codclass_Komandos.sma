#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#include fakemeta

#define DMG_BULLET (1<<1)

new const nazwa[] = "Komandos";
new const opis[] = "1/1 noz PPM, 1/7 na odbicie pocisku";
new const bronie = 1<<CSW_DEAGLE;
new const zdrowie = 20;
new const kondycja = 40;
new const inteligencja = 5;
new const wytrzymalosc = 10;

new bool:ma_klase[33];

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Darmowe");
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public cod_class_enabled(id)
	ma_klase[id] = true;
	
public cod_class_disabled(id)
	ma_klase[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
		
	if(ma_klase[idattacker] && get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET && get_pdata_float(get_pdata_cbase(idattacker, 373, 5), 47, 4) > 1.0)
		KillPlayer(this, idinflictor, idattacker, (1<<1))
		
      if(ma_klase[this] && !random(7))
            cod_inflict_damage(this, idattacker, damage, 0.0, idinflictor, damagebits);

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