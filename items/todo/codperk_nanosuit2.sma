#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include fun

#pragma tabsize 0

new bool:ma_perk[33];

public plugin_init() 
{
	new const perk_name[] = "Nanosuit";
	new const perk_desc[] = "Jestes niewidoczny, masz 1 hp";

	register_plugin(perk_name, "1.0", "RiviT");

	cod_register_perk(perk_name, perk_desc);
	
	register_message(get_user_msgid("Health"), "Health")
}
public cod_perk_enabled(id)
{
      cod_set_user_rendering(id, 1)
	set_user_health(id, 1)
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	cod_remove_user_rendering(id)
	ma_perk[id] = false;
}

public Health(msgId, msgDest, id)
{
	if(ma_perk[id] && get_msg_arg_int(1) > 1)
	{
		set_msg_arg_int(1, ARG_BYTE, 1)
		set_user_health(id, 1)
	}
}