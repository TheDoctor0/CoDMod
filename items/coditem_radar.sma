#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Item Radar"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME        "Radar"
#define DESCRIPTION "Widzisz wrogow na radarze"

#define TASK_RADAR 84722

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
	set_task(1.0, "radar_scan", id + TASK_RADAR, _, _, "b");

public cod_item_disabled(id)
	remove_task(id + TASK_RADAR);

public radar_scan(id)
{
	id -= TASK_RADAR;

	if (!is_user_alive(id)) return;

	static playerOrigin[3], msgHostageAdd, msgHostageDel;

	if (!msgHostageAdd) {
		msgHostageAdd = get_user_msgid("HostagePos");
	}

	if (!msgHostageDel) {
		msgHostageDel = get_user_msgid("HostageK");
	}

	for (new i = 1; i <= MAX_PLAYERS; i++) {
		if (!is_user_alive(i) || get_user_team(i) == get_user_team(id)) continue;

		get_user_origin(i, playerOrigin);

		message_begin(MSG_ONE_UNRELIABLE, msgHostageAdd, {0, 0, 0}, id);
		write_byte(id);
		write_byte(i);
		write_coord(playerOrigin[0]);
		write_coord(playerOrigin[1]);
		write_coord(playerOrigin[2]);
		message_end();

		message_begin(MSG_ONE_UNRELIABLE, msgHostageDel, {0, 0, 0}, id);
		write_byte(i);
		message_end();
	}
}
