#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Flags"
#define VERSION "1.0.0"
#define AUTHOR "O'Zone"

forward amxbans_admin_connect(id);
forward client_admin(id, flags);

new playerFlags[MAX_PLAYERS + 1], flagsChanged;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	flagsChanged = CreateMultiForward("cod_flags_changed", ET_IGNORE, FP_CELL, FP_CELL);
}

public plugin_natives()
{
	register_native("cod_get_user_flags", "_cod_get_user_flags", 1);
	register_native("cod_set_user_flags", "_cod_set_user_flags", 1);
}

public client_connect(id)
	playerFlags[id] = 0;

public amxbans_admin_connect(id)
	update_user_flags(id, get_user_flags(id));

public client_authorized(id)
	update_user_flags(id, get_user_flags(id));

public client_admin(id, flags)
	update_user_flags(id, flags);

public update_user_flags(id, flags)
{
	playerFlags[id] = flags;

	set_user_flags(id, playerFlags[id]);

	static ret;

	ExecuteForward(flagsChanged, ret, id, flags);
}

public _cod_get_user_flags(id)
	return playerFlags[id];

public _cod_set_user_flags(id, flags)
	update_user_flags(id, get_user_flags(id) | flags);