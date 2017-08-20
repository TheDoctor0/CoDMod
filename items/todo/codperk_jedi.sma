#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#include <fakemeta>

#define DMG_BULLET (1<<1)

#define m_pPlayer 41

new const nazwa[] = "Miecz Jedi";
new const opis[] = "1/1 noz PPM, 1/3 na odbicie pocisku";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_perk(nazwa, opis);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "fwHamItemDeployPost", 1)
}

public cod_perk_enabled(id)
	ma_perk[id] = true;
	
public cod_perk_disabled(id)
	ma_perk[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(idattacker) == get_user_team(this))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker] && get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET && get_pdata_float(get_pdata_cbase(idattacker, 373, 5), 47, 4) > 1.0)
		KillPlayer(this, idinflictor, idattacker, (1<<1))
		
      if(ma_perk[this] && !random(3))
            cod_inflict_damage(this, idattacker, damage, 0.0, idinflictor, damagebits);

	return HAM_IGNORED;
}

public plugin_precache()
{
	precache_model("models/QTM_CodMod/p_jedi.mdl");
	precache_model("models/QTM_CodMod/v_jedi.mdl");
}

public fwHamItemDeployPost(ent)
{
	new id = get_pdata_cbase(ent, m_pPlayer, 4);

	if(!ma_perk[id]) return;
	
	set_pev(id, pev_viewmodel2, "models/QTM_CodMod/v_jedi.mdl")
	set_pev(id, pev_weaponmodel2, "models/QTM_CodMod/p_jedi.mdl")
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