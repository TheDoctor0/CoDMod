#include <amxmodx>
#include <cstrike>
#include <cod>

#define PLUGIN "CoD VIP"
#define VERSION "1.0.1"
#define AUTHOR "O'Zone"

new Array:listVIPs, vip;

new const commandVIP[][] = { "say /vip", "say_team /vip", "say /vip", "say_team /vip", "vip" };
new const commandVIPs[][] = { "say /vips", "say_team /vips", "say /vipy", "say_team /vipy", "vipy" };

forward amxbans_admin_connect(id);

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < sizeof commandVIP; i++) register_clcmd(commandVIP[i], "show_vip_motd");
	for(new i; i < sizeof commandVIPs; i++) register_clcmd(commandVIPs[i], "show_vips");

	register_message(get_user_msgid("SayText"), "say_text");
	register_message(get_user_msgid("ScoreAttrib"), "vip_status");
	
	listVIPs = ArrayCreate(64, 32);
}

public plugin_natives()
{
	register_native("cod_get_user_vip", "_cod_get_user_vip", 1);
	register_native("cod_set_user_vip", "_cod_set_user_vip", 1);
}

public plugin_end()
	ArrayDestroy(listVIPs);

public client_authorized(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_H) {
		set_bit(id, vip);
		
		new name[32], tempName[32], size = ArraySize(listVIPs);

		get_user_name(id, name, charsmax(name));
	
		for(new i = 0; i < size; i++) {
			ArrayGetString(listVIPs, i, tempName, charsmax(tempName));
		
			if(equal(name, tempName)) return PLUGIN_CONTINUE;
		}
		
		ArrayPushString(listVIPs, name);
	}

	return PLUGIN_CONTINUE;
}

public client_disconnected(id)
{
	if(get_bit(id, vip)) {
		rem_bit(id, vip);
		
		new name[32], tempName[32], size = ArraySize(listVIPs);

		get_user_name(id, name,charsmax(name));
	
		for(new i = 0; i < size; i++) {
			ArrayGetString(listVIPs, i, tempName, charsmax(tempName));
		
			if(equal(tempName, name)) {
				ArrayDeleteItem(listVIPs, i);

				break;
			}
		}
	}

	return PLUGIN_CONTINUE;
}

public client_infochanged(id)
{
	if(get_bit(id, vip)) {
		new name[64], newName[64];

		get_user_info(id, "name", name, charsmax(name));
		
		get_user_name(id, newName,charsmax(newName));
		
		if(!equal(name, newName)) {
			ArrayPushString(listVIPs, name);
			
			new tempName[64], size = ArraySize(listVIPs);

			for(new i = 0; i < size; i++) {
				ArrayGetString(listVIPs, i, tempName, charsmax(tempName));
				
				if(equal(tempName, newName)) {
					ArrayDeleteItem(listVIPs,i);

					break;
				}
			}
		}
	}

	return PLUGIN_CONTINUE;
}

public show_vip_motd(id)
	show_motd(id, "vip.txt", "Informacje o VIPie");
	
public show_vips(id)
{
	new message[192], name[64], size = ArraySize(listVIPs);
	
	for(new i = 0; i < size; i++) {
		ArrayGetString(listVIPs, i, name, charsmax(name));
		
		add(message, charsmax(message), name);
		
		if(i == size - 1) add(message, charsmax(message), ".");
		else add(message, charsmax(message), ", ");
	}
	
	cod_print_chat(id, "^x03VIPy^x01 na serwerze:^x04 %s", message);
	
	return PLUGIN_CONTINUE;
}

public cod_spawned(id)
{
	if(get_bit(id, vip) && is_user_alive(id)) {
		cod_give_weapon(id, CSW_HEGRENADE);
	
		cod_give_weapon(id, CSW_FLASHBANG);
		cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
	
		cod_give_weapon(id, CSW_SMOKEGRENADE);
	}
}

public cod_damage_post(attacker, victim, weapon, Float:damage, damageBits)
{
	if(!get_bit(attacker, vip)) return PLUGIN_CONTINUE;

	cod_inflict_damage(attacker, victim, damage * 0.05, 0.0, damageBits);

	return PLUGIN_CONTINUE;
}

public cod_killed(killer, victim, weaponId, hitPlace)
{
	if(!get_bit(killer, vip)) return PLUGIN_CONTINUE;

	new bool:hs = hitPlace == HIT_HEAD;

	cod_add_user_health(killer, hs ? 15 : 10);

	cs_set_user_money(killer, cs_get_user_money(killer) + (hs ? 1000 : 500));
	
	if(hs) cod_show_hud(killer, TYPE_DHUD, 38, 218, 116, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0, "HeadShot! +15HP");
	else cod_show_hud(killer, TYPE_DHUD, 255, 212, 0, 0.50, 0.31, 0, 0.0, 1.0, 0.0, 0.0, "Zabiles! +10HP");

	return PLUGIN_CONTINUE;
}

public bomb_planted(id)
	if(get_bit(id, vip)) cs_set_user_money(id, cs_get_user_money(id) + 500);

public bomb_defused(id)
	if(get_bit(id, vip)) cs_set_user_money(id, cs_get_user_money(id) + 500);

public vip_status()
{
	new id = get_msg_arg_int(1);
	
	if(is_user_alive(id) && get_bit(id, vip)) set_msg_arg_int(2, ARG_BYTE, get_msg_arg_int(2) | 4);
}

public say_text(msgId, msgDest, msgEnt)
{
	new id = get_msg_arg_int(1);
	
	if(is_user_connected(id) && get_bit(id, vip)) {
		new tempMessage[192], message[192], chatPrefix[64], steamId[33], playerName[32];
		
		get_msg_arg_string(2, tempMessage, charsmax(tempMessage));
		get_user_authid(id, steamId, charsmax(steamId)); 

		if(equali(steamId, "STEAM_0:1:55664") || equali(steamId, "STEAM_0:1:6389510")) formatex(chatPrefix, charsmax(chatPrefix), "^x04[WLASCICIEL]");
		else formatex(chatPrefix, charsmax(chatPrefix), "^x04[VIP]");
		
		if(!equal(tempMessage, "#Cstrike_Chat_All")) {
			add(message, charsmax(message), chatPrefix);
			add(message, charsmax(message), " ");
			add(message, charsmax(message), tempMessage);
		}
		else {
	        get_user_name(id, playerName, charsmax(playerName));
	        
	        get_msg_arg_string(4, tempMessage, charsmax(tempMessage)); 
	        set_msg_arg_string(4, "");
	    
	        add(message, charsmax(message), chatPrefix);
	        add(message, charsmax(message), "^x03 ");
	        add(message, charsmax(message), playerName);
	        add(message, charsmax(message), "^x01 :  ");
	        add(message, charsmax(message), tempMessage);
		}
		
		set_msg_arg_string(2, message);
	}
	
	return PLUGIN_CONTINUE;
}

public amxbans_admin_connect(id)
	client_authorized(id, "");
	
public _cod_get_user_vip(id)
	return get_bit(id, vip);

public _cod_set_user_vip(id)
	client_authorized(id, "");