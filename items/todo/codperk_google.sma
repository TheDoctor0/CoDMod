/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <codmod>

new const perk_name[] = "Google";
new const perk_desc[] = "Mozesz zamknac oczy i uchronic sie przed flashem. Uzycie [E]";

new bool:ma_perk[33];
     
new g_msgScreenFade,
     g_msgScreenFade_1;

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "creepMP3");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("ScreenFade", "eventFlash", "be", "4=255", "5=255", "6=255", "7>199");
	
	register_forward(FM_PlayerPreThink,"google");
	
	g_msgScreenFade = get_user_msgid("ScreenFade");
	g_msgScreenFade_1 = get_user_msgid("ScreenFade");
}

public cod_perk_enabled(id)
{
	client_print(id, print_chat,"[Google] Nacisnij klawisz [E] aby zamknac oczy !");
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}

public eventFlash(id)
{        
	if(!ma_perk[id] || !is_user_alive(id))
		return PLUGIN_CONTINUE;
		
	new button = get_user_button(id)
	
	if(button & IN_USE) 
	{
		message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, id)
		write_short(1<<1)
		write_short(1<<1)
		write_short(1<<1)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(255)
		message_end()
	}
	
	return PLUGIN_CONTINUE;
}
public google(id)
{
	if(!ma_perk[id] || !is_user_alive(id))
		return PLUGIN_CONTINUE;
		
	new button = get_user_button(id)
	
	if(button & IN_USE) 
	{
		message_begin(MSG_ONE,g_msgScreenFade_1,{0,0,0},id);
		write_short(1<<8)
		write_short(1<<8)
		write_short(1<<1)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(255)
		message_end() 
	}
	
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/