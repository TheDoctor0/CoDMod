#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Item Latarka"
#define VERSION "1.0.10"
#define AUTHOR "O'Zone"

#define NAME        "Latarka"
#define DESCRIPTION "Masz latarke naswietlajaca wszystkich niewidzialnych graczy"

#define TASK_CHARGE  30293

#define FLASHLIGHT   15

new flashlightBattery[MAX_PLAYERS + 1], flashlightActive, itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION);
}

public cod_item_enabled(id, value)
{
	flashlightBattery[id] = FLASHLIGHT;

	set_bit(id, itemActive);
}

public cod_item_disabled(id)
{
	remove_task(id + TASK_CHARGE);

	rem_bit(id, flashlightActive);
	rem_bit(id, itemActive);
}

public cod_item_spawned(id, respawn)
{
	rem_bit(id, flashlightActive);

	if (!respawn) flashlightBattery[id] = FLASHLIGHT;
}

public cod_item_skill_used(id)
{
	if (get_bit(id, flashlightActive)) {
		rem_bit(id, flashlightActive);
	} else if (flashlightBattery[id]) set_bit(id, flashlightActive);

	if (!task_exists(id + TASK_CHARGE)) set_task(1.0, "flashlight_charge", id + TASK_CHARGE, .flags = "b");

	static msgFlashlight;

	if (!msgFlashlight) msgFlashlight = get_user_msgid("Flashlight");

	message_begin(MSG_ONE, msgFlashlight, {0, 0, 0}, id);
	write_byte(get_bit(id, flashlightActive));
	write_byte(flashlightBattery[id]);
	message_end();

	set_pev(id, pev_effects, pev(id, pev_effects) & ~EF_DIMLIGHT);
}

public cod_player_prethink(id)
{
	if (!get_bit(id, flashlightActive)) return;

	if (get_bit(id, flashlightActive) && flashlightBattery[id]) {
		static flashlightR, flashlightG, flashlightB;
		
		if ((flashlightR += 1 + random_num(0, 2)) > 250) flashlightR -= 245;
		
		if ((flashlightG += 1 + random_num(-1, 1)) > 250) flashlightG -= 245;
		
		if ((flashlightB += -1 + random_num(-1, 1)) < 5) flashlightB += 240;
		
		static origin[3];

		get_user_origin(id, origin, 3);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(27);
		write_coord(origin[0]);
		write_coord(origin[1]);
		write_coord(origin[2]);
		write_byte(8);
		write_byte(flashlightR);
		write_byte(flashlightG);
		write_byte(flashlightB);
		write_byte(1);
		write_byte(90);
		message_end();
		
		static target, bodyPart, render;

		get_user_aiming(id, target, bodyPart);

		if (is_user_alive(target) && get_user_team(id) != get_user_team(target)) {
			render = pev(target, pev_renderamt);

			if (render < 255) cod_set_user_glow(target, kRenderFxGlowShell, flashlightR, flashlightG, flashlightB, kRenderNormal, 20, 5.0);
		}
	}
}

public flashlight_charge(id)
{
	id -= TASK_CHARGE;

	if (!is_user_alive(id)) {
		remove_task(id + TASK_CHARGE);

		return;
	}

	static msgFlashlight, msgFlashBat;

	if (!msgFlashlight) msgFlashlight = get_user_msgid("Flashlight");
	if (!msgFlashBat) msgFlashBat = get_user_msgid("FlashBat");

	if (get_bit(id, flashlightActive)) flashlightBattery[id] = max(0, --flashlightBattery[id]);
	else flashlightBattery[id] = min(++flashlightBattery[id], FLASHLIGHT);

	message_begin(MSG_ONE, msgFlashBat, {0, 0, 0}, id);
	write_byte(flashlightBattery[id]);
	message_end();

	if (!flashlightBattery[id]) {
		rem_bit(id, flashlightActive);

		message_begin(MSG_ONE, msgFlashlight, {0, 0, 0}, id);
		write_byte(get_bit(id, flashlightActive));
		write_byte(flashlightBattery[id]);
		message_end();
	}
}