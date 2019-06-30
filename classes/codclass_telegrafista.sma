#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Telegrafista"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Telegrafista"
#define DESCRIPTION  "Moze aktywowac na 30s radar pokazujacy pozycje przeciwnikow. Ma ubranie wroga."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_AK47)|(1<<CSW_GLOCK18)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      20
#define CONDITION    0

#define TASK_RADAR 84722
#define TASK_STOP 89431

new classUsed;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id)
{
	rem_bit(id, classUsed);

	cod_set_user_model(id, true, CLASS);
}

public cod_class_disabled(id)
{
	remove_task(id + TASK_RADAR);
	remove_task(id + TASK_STOP);
}

public cod_class_spawned(id, respawn)
{
	remove_task(id + TASK_RADAR);
	remove_task(id + TASK_STOP);

	if (!respawn) {
		rem_bit(id, classUsed);
	}
}

public cod_class_skill_used(id)
{
	if (get_bit(id, classUsed)) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Radar mozesz aktywowac tylko raz na runde!");

		return PLUGIN_CONTINUE;
	}

	set_bit(id, classUsed);

	set_task(1.0, "radar_scan", id + TASK_RADAR, _, _, "b");
	set_task(30.0, "radar_stop", id + TASK_STOP);

	emit_sound(id, CHAN_ITEM, codSounds[SOUND_CHARGE], 0.5, ATTN_NORM, 0, PITCH_NORM);

	return PLUGIN_CONTINUE;
}

public radar_stop(id)
{
	id -= TASK_STOP;

	remove_task(id + TASK_RADAR);
}

public radar_scan(id)
{
	id -= TASK_RADAR;

	if (!is_user_alive(id)) {
		remove_task(id + TASK_RADAR);

		return;
	}

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
