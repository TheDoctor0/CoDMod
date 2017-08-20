#include <amxmodx>
#include <codmod>
#include <hamsandwich>

#define DMG_BULLET (1<<1) 

new const perk_name[] = "Oslepiajacy Fiveseven";
new const perk_desc[] = "Masz 1/4 na oslepienie z Fiveseven";

new bool:ma_perk[33],
g_msg_screenfade;

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Hajmus");

	g_msg_screenfade = get_user_msgid("ScreenFade");

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");

	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_FIVESEVEN);	
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_FIVESEVEN);
	ma_perk[id] = false;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || get_user_team(idattacker) == get_user_team(this))
		return HAM_IGNORED; 
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(damagebits & DMG_BULLET)
	{
		if(get_user_weapon(idattacker) == CSW_FIVESEVEN && !random(4))
			Display_Fade(this,1<<12,1<<10,1<<16,255,0,0,255);
	}
	
	return HAM_IGNORED;
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin( MSG_ONE, g_msg_screenfade,{0,0,0},id );
	write_short( duration );	// Duration of fadeout
	write_short( holdtime );	// Hold time of color
	write_short( fadetype );	// Fade type
	write_byte ( red );		// Red
	write_byte ( green );		// Green
	write_byte ( blue );		// Blue
	write_byte ( alpha );	// Alpha
	message_end();
}