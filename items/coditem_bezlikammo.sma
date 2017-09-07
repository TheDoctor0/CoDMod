#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cod>

#define PLUGIN "CoD Item Bezlik Amunicji"
#define VERSION "1.0.2"
#define AUTHOR "O'Zone"

#define NAME        "Bezlik Amunicji"
#define DESCRIPTION "Twoja amunicja sie nie konczy"

new const maxClips[CSW_P90 + 1] = { -1, 13, -1, 10, 1, 7, 1, 30, 30, 1, 30, 20, 
	25, 30, 35, 25, 12, 20, 10, 30, 100, 8, 30, 30, 20,  2, 7, 30, 30, -1, 50 };

new itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);

	register_message(get_user_msgid("CurWeapon"), "message_curweapon");
}

public cod_item_enabled(id, value)
	set_bit(id, itemActive);

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public message_curweapon(msgId, msgDest, id)
{
	if(get_msg_arg_int(1) && get_bit(id, itemActive))
	{
		new maxClip = maxClips[get_msg_arg_int(1)];

		if(get_msg_arg_int(2) < maxClip)
		{
			new weapon = get_pdata_cbase(id, 373, 5);

			if(weapon > 0 && (!(((1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4)) & (1<<weapon))))
			{
				set_pdata_int(weapon, 51, maxClip, 4);
				set_pdata_int(weapon, 52, maxClip, 4);

				set_msg_arg_int(2, ARG_BYTE, maxClip);
			}
		}
	}
}