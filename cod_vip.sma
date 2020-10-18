#include <amxmodx>
#include <cod>

#define PLUGIN "CoD VIP"
#define AUTHOR "O'Zone"

#define VIP_FLAG ADMIN_LEVEL_H

new Array:listVIPs, vip;

new const commandVIP[][] = { "say /vip", "say_team /vip", "say /vip", "say_team /vip", "vip" };
new const commandVIPs[][] = { "say /vips", "say_team /vips", "say /vipy", "say_team /vipy", "vipy" };

forward amxbans_admin_connect(id);

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	for (new i; i < sizeof commandVIP; i++) register_clcmd(commandVIP[i], "show_vip_motd");
	for (new i; i < sizeof commandVIPs; i++) register_clcmd(commandVIPs[i], "show_vips");

	register_message(get_user_msgid("SayText"), "say_text");
	register_message(get_user_msgid("ScoreAttrib"), "vip_status");

	listVIPs = ArrayCreate(MAX_NAME, MAX_PLAYERS);
}

public plugin_natives()
	register_native("cod_get_user_vip", "_cod_get_user_vip", 1);

public plugin_end()
	ArrayDestroy(listVIPs);

public cod_flags_changed(id, flags)
{
	if (flags & VIP_FLAG) {
		set_bit(id, vip);

		new name[MAX_NAME], tempName[MAX_NAME], size = ArraySize(listVIPs);

		get_user_name(id, name, charsmax(name));

		for (new i = 0; i < size; i++) {
			ArrayGetString(listVIPs, i, tempName, charsmax(tempName));

			if (equal(name, tempName)) return PLUGIN_CONTINUE;
		}

		ArrayPushString(listVIPs, name);
	} else remove_vip(id);

	return PLUGIN_CONTINUE;
}

public client_disconnected(id)
	remove_vip(id);

public remove_vip(id)
{
	if (get_bit(id, vip)) {
		rem_bit(id, vip);

		new name[MAX_NAME], tempName[MAX_NAME], size = ArraySize(listVIPs);

		get_user_name(id, name,charsmax(name));

		for (new i = 0; i < size; i++) {
			ArrayGetString(listVIPs, i, tempName, charsmax(tempName));

			if (equal(tempName, name)) {
				ArrayDeleteItem(listVIPs, i);

				break;
			}
		}
	}

	return PLUGIN_CONTINUE;
}

public client_infochanged(id)
{
	if (get_bit(id, vip)) {
		new name[MAX_NAME], newName[MAX_NAME];

		get_user_info(id, "name", name, charsmax(name));

		get_user_name(id, newName,charsmax(newName));

		if (!equal(name, newName)) {
			ArrayPushString(listVIPs, name);

			new tempName[MAX_NAME], size = ArraySize(listVIPs);

			for (new i = 0; i < size; i++) {
				ArrayGetString(listVIPs, i, tempName, charsmax(tempName));

				if (equal(tempName, newName)) {
					ArrayDeleteItem(listVIPs,i);

					break;
				}
			}
		}
	}

	return PLUGIN_CONTINUE;
}

public show_vip_motd(id)
{
	new motdTitle[32];

	formatex(motdTitle, charsmax(motdTitle), "%L", id, "VIP_MOTD");

	show_motd(id, "vip.txt", motdTitle);
}

public show_vips(id)
{
	new message[192], name[MAX_NAME], size = ArraySize(listVIPs);

	for (new i = 0; i < size; i++) {
		ArrayGetString(listVIPs, i, name, charsmax(name));

		add(message, charsmax(message), name);

		if (i == size - 1) add(message, charsmax(message), ".");
		else add(message, charsmax(message), ", ");
	}

	cod_print_chat(id, "%L", id, "VIP_LIST", message);

	return PLUGIN_CONTINUE;
}

public cod_class_changed(id, class)
{
	if (get_bit(id, vip) && is_user_alive(id)) {
		cod_give_weapon(id, CSW_HEGRENADE);
		cod_give_weapon(id, CSW_FLASHBANG, 2);
		cod_give_weapon(id, CSW_SMOKEGRENADE);
	}
}

public cod_spawned(id, respawn)
{
	if (get_bit(id, vip) && is_user_alive(id)) {
		cod_give_weapon(id, CSW_HEGRENADE);
		cod_give_weapon(id, CSW_FLASHBANG, 2);
		cod_give_weapon(id, CSW_SMOKEGRENADE);
	}
}

public cod_damage_post(attacker, victim, weapon, Float:damage, damageBits, hitPlace)
{
	if (!get_bit(attacker, vip)) return PLUGIN_CONTINUE;

	cod_inflict_damage(attacker, victim, damage * 0.05, 0.0, damageBits);

	return PLUGIN_CONTINUE;
}

public cod_killed(killer, victim, weaponId, hitPlace)
{
	if (!get_bit(killer, vip)) return PLUGIN_CONTINUE;

	new bool:headshot = hitPlace == HIT_HEAD;

	cod_add_user_health(killer, headshot ? 15 : 10);

	if (headshot) cod_show_hud(killer, TYPE_DHUD, 38, 218, 116, -1.0, 0.39, 0, 0.0, 1.0, 0.0, 0.0, "%L", killer, "VIP_KILL_HS");
	else cod_show_hud(killer, TYPE_DHUD, 255, 212, 0, -1.0, 0.31, 0, 0.0, 1.0, 0.0, 0.0, "%L", killer, "VIP_KILL");

	return PLUGIN_CONTINUE;
}

public vip_status()
{
	new id = get_msg_arg_int(1);

	if (is_user_alive(id) && get_bit(id, vip)) set_msg_arg_int(2, ARG_BYTE, get_msg_arg_int(2) | 4);
}

public say_text(msgId, msgDest, msgEnt)
{
	new id = get_msg_arg_int(1);

	if (is_user_connected(id) && get_bit(id, vip)) {
		new tempMessage[192], message[192], chatPrefix[64], playerName[MAX_NAME];

		get_msg_arg_string(2, tempMessage, charsmax(tempMessage));

		formatex(chatPrefix, charsmax(chatPrefix), "^4[VIP]");

		if (!equal(tempMessage, "#Cstrike_Chat_All")) {
			add(message, charsmax(message), chatPrefix);
			add(message, charsmax(message), " ");
			add(message, charsmax(message), tempMessage);
		} else {
	        get_user_name(id, playerName, charsmax(playerName));

	        get_msg_arg_string(4, tempMessage, charsmax(tempMessage));
	        set_msg_arg_string(4, "");

	        add(message, charsmax(message), chatPrefix);
	        add(message, charsmax(message), "^3 ");
	        add(message, charsmax(message), playerName);
	        add(message, charsmax(message), "^1 :  ");
	        add(message, charsmax(message), tempMessage);
		}

		set_msg_arg_string(2, message);
	}

	return PLUGIN_CONTINUE;
}

public _cod_get_user_vip(id)
	return get_bit(id, vip);