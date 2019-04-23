#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Class Jasnowidz"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Jasnowidz"
#define DESCRIPTION  "Co 30 sekund moze przechodzic w cialo przeciwnika, zeby go sledzic i oznaczyc na radarze."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_SG552)|(1<<CSW_DEAGLE)
#define HEALTH       20
#define INTELLIGENCE 5
#define STRENGTH     5
#define STAMINA      0
#define CONDITION    0

#define TASK_RADAR 84722

new classLastUsed[MAX_PLAYERS + 1];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);

	register_forward(FM_Think, "camera_think");
}

public cod_class_enabled(id, promotion)
	classLastUsed[id] = 0;

public cod_class_skill_used(id)
{
	if (classLastUsed[id] + 30.0 > get_gametime()) {
		cod_show_hud(id, TYPE_DHUD, 0, 255, 210, -1.0, 0.35, 0, 0.0, 1.25, 0.0, 0.0, "Jasnowidzenia mozesz uzyc raz na 30 sekund!");

		return PLUGIN_CONTINUE;
	}

	new playerName[32], playerId[3], menu = menu_create("\wWybierz \rGracza\w, ktorego chcesz \ysledzic\w:", "cod_class_skill_used_handle");

	for (new i = 1; i <= MAX_PLAYERS; i++) {
		if (!is_user_alive(i) || get_user_team(i) == get_user_team(id) || i == id) continue;

		num_to_str(i, playerId, charsmax(playerId));

		get_user_name(i, playerName, charsmax(playerName));

		menu_additem(menu, playerName, playerId);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");

	menu_display(id, menu);

	return PLUGIN_CONTINUE;
}

public cod_class_skill_used_handle(id, menu, item)
{
	if (!is_user_alive(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new playerName[32], playerId[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, playerId, charsmax(playerId), playerName, charsmax(playerName), itemCallback);

	menu_destroy(menu);

	new player = str_to_num(playerId);

	if (!is_user_alive(player)) {
		cod_print_chat(id, "Wybrany gracz juz nie zyje.");

		return PLUGIN_HANDLED;
	}

	cod_show_hud(id, TYPE_DHUD, 59, 255, 0, -1.0, 0.36, 0, 0.0, 3.0, 0.0, 0.0, "Obserwujesz %s", playerName);
	cod_display_fade(id, 1, 1, 0x0000, 254, 254, 254, 25);
	cod_set_user_render(id, 10, .timer = 3.0);
	cod_make_bartimer(id, 3);

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

	engfunc(EngFunc_SetModel, ent, "models/w_c4.mdl");
	engfunc(EngFunc_SetView, id, ent);

	set_pev(ent, pev_classname, "player_camera");
	set_pev(ent, pev_solid, SOLID_TRIGGER);
	set_pev(ent, pev_movetype, MOVETYPE_FLYMISSILE);
	set_pev(ent, pev_owner, player);
	set_pev(ent, pev_rendermode, kRenderTransTexture);
	set_pev(ent, pev_renderamt, 0.0);
	set_pev(ent, pev_nextthink, get_gametime());

	new data[3];
	data[0] = id;
	data[1] = player;
	data[2] = ent;

	emit_sound(player, CHAN_VOICE, codSounds[SOUND_CHARGE], 0.6, ATTN_NORM, 0, PITCH_NORM);

	set_task(3.0, "deactivate_class", .parameter = data, .len = sizeof(data));

	classLastUsed[id] = floatround(get_gametime());

	return PLUGIN_HANDLED;
}

public deactivate_class(data[])
{
	new id = data[0], player = data[1], ent = data[2];

	engfunc(EngFunc_RemoveEntity, ent);

	if (!is_user_connected(id)) return;

	engfunc(EngFunc_SetView, id, id);

	if (!is_user_alive(player)) return;

	if (!is_user_alive(id)) {
		cod_print_chat(id, "Niestety zginales. Nie udostepnisz namiarow wroga swojej druzynie.");

		return;
	}

	set_task(1.0, "radar_scan", id + TASK_RADAR, .flags = "a", .repeat = 5);
}

public radar_scan(id)
{
	id -= TASK_RADAR;

	if (!is_user_alive(id)) {
		remove_task(id + TASK_RADAR);

		return;
	}

	static playerOrigin[3], msgHostageAdd, msgHostageDel;

	if (!msgHostageAdd) msgHostageAdd = get_user_msgid("HostagePos");
	if (!msgHostageDel) msgHostageDel = get_user_msgid("HostageK");

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

public camera_think(ent)
{
	if(!pev_valid(ent)) return FMRES_IGNORED;

	static className[32], owner;

	pev(ent, pev_classname, className, charsmax(className));

	if (!equal(className, "player_camera")) return FMRES_IGNORED;

	owner = pev(ent, pev_owner);

	if (!is_user_alive(owner)) return FMRES_IGNORED;

	static Float:origin[3], Float:angle[3], Float:back[3];

	pev(owner, pev_origin, origin);
	pev(owner, pev_v_angle, angle);

	angle_vector(angle, ANGLEVECTOR_FORWARD, back);

	origin[2] += 40.0;
	origin[0] += (-back[0] * 150.0);
	origin[1] += (-back[1] * 150.0);
	origin[2] += (-back[2] * 150.0);

	engfunc(EngFunc_SetOrigin, ent, origin);

	set_pev(ent, pev_angles, angle);
	set_pev(ent, pev_nextthink, get_gametime());

	return FMRES_HANDLED;
}