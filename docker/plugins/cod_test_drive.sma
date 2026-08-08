#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Test Drive"
#define AUTHOR "O'Zone"

/**
 * Test environment only - never put this in a production plugin list.
 *
 * Lets rcon push client commands into a connected player, which is enough to
 * open every menu, pick items with menuselect and log in, so the whole client
 * side can be exercised from a script without synthetic keyboard input.
 *
 *   rcon cod_drive <player id> <command...>
 *   rcon cod_who
 *
 * It also mirrors the menu and MOTD payloads to the console, because the MOTD
 * panel a player gets on connect stays open and swallows every later MOTD, so
 * the top15 listings cannot be checked from a screenshot alone.
 */
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_srvcmd("cod_drive", "drive");
	register_srvcmd("cod_who", "who");

	register_message(get_user_msgid("ShowMenu"), "message_show_menu");
	register_message(get_user_msgid("MOTD"), "message_motd");
	register_message(get_user_msgid("SayText"), "message_say_text");
}

public message_show_menu(msgId, dest, id)
{
	new menuData[192];

	get_msg_arg_string(4, menuData, charsmax(menuData));

	replace_all(menuData, charsmax(menuData), "^n", " | ");

	server_print("[menu] %d %s", id, menuData);

	return PLUGIN_CONTINUE;
}

public message_motd(msgId, dest, id)
{
	new motdData[192];

	get_msg_arg_string(2, motdData, charsmax(motdData));

	replace_all(motdData, charsmax(motdData), "^n", " ");

	server_print("[motd] %d %s", id, motdData);

	return PLUGIN_CONTINUE;
}

public message_say_text(msgId, dest, id)
{
	new textData[192];

	get_msg_arg_string(2, textData, charsmax(textData));

	server_print("[chat] %d %s", id, textData);

	return PLUGIN_CONTINUE;
}

public drive()
{
	new idArg[4];

	read_argv(1, idArg, charsmax(idArg));

	new id = str_to_num(idArg);

	if (!is_user_connected(id)) {
		server_print("[drive] error not-connected %d", id);

		return PLUGIN_HANDLED;
	}

	new command[192], argument[64];

	for (new i = 2; i < read_argc(); i++) {
		read_argv(i, argument, charsmax(argument));

		if (command[0]) add(command, charsmax(command), " ");

		add(command, charsmax(command), argument);
	}

	if (!command[0]) {
		server_print("[drive] error no-command");

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "%s", command);

	server_print("[drive] sent %d %s", id, command);

	return PLUGIN_HANDLED;
}

public who()
{
	new players;

	for (new id = 1; id <= MAX_PLAYERS; id++) {
		if (!is_user_connected(id)) continue;

		new name[MAX_NAME];

		get_user_name(id, name, charsmax(name));

		server_print("[who] id=%d name=%s db_id=%d honor=%d account=%d class=%d class_row=%d",
			id, name, cod_get_user_db_id(id), cod_get_player_field(id, DB_PLAYER_HONOR),
			cod_check_account(id), cod_get_user_class(id), cod_get_user_class_row(id));

		players++;
	}

	server_print("[who] total=%d", players);

	return PLUGIN_HANDLED;
}
