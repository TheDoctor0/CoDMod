#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <cod>

#define PLUGIN "CoD Class Mag"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Mag"
#define DESCRIPTION  "Ukrywa siebie i czlonkow druzyny w promieniu 50 (+int) jednostek. Ma latarke (E) naswietlajaca niewidzialnych."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_AUG)|(1<<CSW_FIVESEVEN)
#define HEALTH       -10
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      20
#define CONDITION    10

#define TASK_CHARGE  30293
#define TASK_INFO    39221
#define TASK_DAMAGE  43532

#define FLASHLIGHT   15

new flashlightBattery[MAX_PLAYERS + 1], flashlightActive, classActive, playerDamage, playerInfo, playerHidden;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id)
{
	flashlightBattery[id] = FLASHLIGHT;

	set_bit(id, classActive);
}

public cod_class_disabled(id)
{
	remove_task(id + TASK_CHARGE);

	rem_bit(id, flashlightActive);
	rem_bit(id, classActive);
}

public cod_class_spawned(id, respawn)
{
	rem_bit(id, flashlightActive);

	if(!respawn) flashlightBattery[id] = FLASHLIGHT;
}

public cod_new_round()
{
	for (new id = 1; id <= MAX_PLAYERS; id++) {
		rem_bit(id, playerDamage);
		rem_bit(id, playerInfo);
		rem_bit(id, playerHidden);

		remove_task(id + TASK_DAMAGE);
		remove_task(id + TASK_INFO);
	}
}

public cod_damage_pre(attacker, victim, weapon, Float:damage, damageBits, hitPlace)
{
	if(get_bit(attacker, playerHidden)) {
		set_bit(attacker, playerDamage);

		set_task(5.0, "damage_reset", attacker + TASK_DAMAGE);

		cod_print_chat(attacker, "Zadales obrazenia. Koniec ukrycia!");
	}

	if(get_bit(victim, playerHidden)) {
		set_bit(victim, playerDamage);

		set_task(5.0, "damage_reset", victim + TASK_DAMAGE);

		cod_print_chat(victim, "Otrzymales obrazenia. Koniec ukrycia!");
	}
}

public cod_class_skill_used(id)
{
	if(get_bit(id, flashlightActive)) {
		rem_bit(id, flashlightActive);
	} else if(flashlightBattery[id]) set_bit(id, flashlightActive);

	if(!task_exists(id + TASK_CHARGE)) set_task(1.0, "flashlight_charge", id + TASK_CHARGE, .flags = "b");

	static msgFlashlight;

	if(!msgFlashlight) msgFlashlight = get_user_msgid("Flashlight");

	message_begin(MSG_ONE, msgFlashlight, {0, 0, 0}, id);
	write_byte(get_bit(id, flashlightActive));
	write_byte(flashlightBattery[id]);
	message_end();

	set_pev(id, pev_effects, pev(id, pev_effects) & ~EF_DIMLIGHT);
}

public cod_player_prethink(id)
{
	if(!get_bit(id, flashlightActive)) return;

	if(get_bit(id, flashlightActive) && flashlightBattery[id]) 
	{
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

		if(is_user_alive(target) && get_user_team(id) != get_user_team(target)) {
			render = pev(target, pev_renderamt);

			if(render < 255) cod_set_user_glow(target, kRenderFxGlowShell, flashlightR, flashlightG, flashlightB, kRenderNormal, 20, 5.0);
		}
	}

	new playersList[33], foundPlayers = find_sphere_class(id, "player", 50.0 + 0.25 * cod_get_user_intelligence(id), playersList, MAX_PLAYERS), player, bool:players;

	for (new i = 0; i < foundPlayers; i++) {
		player = playersList[i];

		if (!is_user_alive(player) || get_user_team(id) != get_user_team(player) || player == id || get_bit(player, playerDamage)) continue;

		cod_set_user_render(player, 30, ADDITIONAL);

		set_bit(player, playerHidden);

		if(!get_bit(player, playerInfo)) {
			set_bit(player, playerInfo);

			set_task(10.0, "info_reset", player + TASK_INFO);

			cod_print_chat(player, "Jestes ukryty. Nie strzelaj, aby pozostac niezauwazonym.");
		}

		players = true;
	}

	if(players) cod_set_user_render(id, 30, ADDITIONAL);
}

public flashlight_charge(id)
{
	id -= TASK_CHARGE;

	if(!is_user_alive(id)) {
		remove_task(id + TASK_CHARGE);

		return;
	}

	static msgFlashlight, msgFlashBat;

	if(!msgFlashlight) msgFlashlight = get_user_msgid("Flashlight");
	if(!msgFlashBat) msgFlashBat = get_user_msgid("FlashBat");

	if(get_bit(id, flashlightActive)) flashlightBattery[id] = max(0, --flashlightBattery[id]);
	else flashlightBattery[id] = min(++flashlightBattery[id], FLASHLIGHT);

	message_begin(MSG_ONE, msgFlashBat, {0, 0, 0}, id);
	write_byte(flashlightBattery[id]);
	message_end();

	if(!flashlightBattery[id])
	{
		rem_bit(id, flashlightActive);

		message_begin(MSG_ONE, msgFlashlight, {0, 0, 0}, id);
		write_byte(get_bit(id, flashlightActive));
		write_byte(flashlightBattery[id]);
		message_end();
	}
}

public damage_reset(id)
{
	id -= TASK_DAMAGE;

	rem_bit(id, playerDamage);
}

public info_reset(id)
{
	id -= TASK_DAMAGE;

	rem_bit(id, playerInfo);
}