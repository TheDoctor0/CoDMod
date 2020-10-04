#include <amxmodx>
#include <fakemeta>
#include <nvault>
#include <cod>

#define PLUGIN "CoD Knives"
#define VERSION "1.3.0"
#define AUTHOR "O'Zone"

new const knifeModels[][][] =
{
	{ "Standardowy", "(+2 Kazdej Statystyki)", "models/v_knife.mdl" },
	{ "Mysliwski", "(+10 Zdrowia)", "models/CoDMod/hunting.mdl" },
	{ "Kieszonkowy", "(+10 Inteligencji)", "models/CoDMod/pocket.mdl" },
	{ "Tasak", "(+10 Wytrzymalosci)", "models/CoDMod/chopper.mdl" },
	{ "Maczeta", "(+10 Sily)", "models/CoDMod/machete.mdl" },
	{ "Katana", "(+10 Kondycji)", "models/CoDMod/katana.mdl" },
	{ "Siekiera", "(+4 Kazdej Statystyki)", "models/CoDMod/axe.mdl" }
};

new const commandKnives[][] = { "noze", "say /noz", "say_team /noz", "say /noze", "say_team /noze", "say /knife", "say_team /knife",
"say /knifes", "say_team /knifes", "say /kosa", "say_team /kosa", "say /kosy", "say_team /kosy" };

enum _:knifeInfo { NAME, BONUS, MODEL };
enum _:knifeTypes { DEFAULT, HEALTH, INTELLIGENCE, STAMINA, STRENGTH, CONDITION, VIP };

new playerName[MAX_PLAYERS + 1][MAX_NAME], playerKnife[MAX_PLAYERS + 1], bool:mapEnd, dataLoaded, knives, cvarKnifeVIP;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	bind_pcvar_num(create_cvar("cod_knife_vip", "1"), cvarKnifeVIP);

	for (new i; i < sizeof commandKnives; i++) register_clcmd(commandKnives[i], "change_knife");

	knives = nvault_open("cod_knives");

	if (knives == INVALID_HANDLE) set_fail_state("[COD] Nie mozna otworzyc pliku cod_knives.vault");
}

public plugin_precache()
	for (new i = 1; i < sizeof(knifeModels); i++) precache_model(knifeModels[i][MODEL]);

public plugin_end()
	nvault_close(knives);

public client_putinserver(id)
{
	rem_bit(id, dataLoaded);

	if (is_user_bot(id) || is_user_hltv(id)) return;

	playerKnife[id] = DEFAULT;

	load_knife(id);
}

public cod_end_map()
	mapEnd = true;

public cod_reset_all_data()
{
	for (new i = 1; i <= MAX_PLAYERS; i++) rem_bit(i, dataLoaded);

	mapEnd = true;

	nvault_prune(knives, 0, get_systime() + 1);
}

public change_knife(id)
{
	if (!cod_check_account(id)) return PLUGIN_HANDLED;

	cod_play_sound(id, SOUND_SELECT);

	new knifeData[64], knifeId[3], menu = menu_create("\yWybierz \rModel Noza\w:", "change_knife_handle"), callback = menu_makecallback("change_knife_callback");

	for (new i = 0; i < sizeof(knifeModels); i++) {
		if (i == VIP && !cvarKnifeVIP) continue;

		formatex(knifeData, charsmax(knifeData), "%s \y%s%s", knifeModels[i][NAME], knifeModels[i][BONUS], i == VIP ? " \r(VIP)": "");

		num_to_str(i, knifeId, charsmax(knifeId));

		menu_additem(menu, knifeData, knifeId, _, callback);
	}

	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");

	menu_display(id, menu);

	return PLUGIN_HANDLED;
}

public change_knife_callback(id, menu, item)
	return (item == VIP && !cod_get_user_vip(id)) ? ITEM_DISABLED : ITEM_ENABLED;

public change_knife_handle(id, menu, item)
{
	if (!is_user_connected(id)) return PLUGIN_HANDLED;

	if (item == MENU_EXIT) {
		cod_play_sound(id, SOUND_EXIT);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	cod_play_sound(id, SOUND_SELECT);

	new knifeId[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, knifeId, charsmax(knifeId), _, _, itemCallback);

	set_bonus(id, playerKnife[id], str_to_num(knifeId));

	save_knife(id);

	cod_print_chat(id, "Twoj nowy noz to:^x03 %s %s^x01.", knifeModels[playerKnife[id]][NAME], knifeModels[playerKnife[id]][BONUS]);

	menu_destroy(menu);

	set_knife(id, 1);

	return PLUGIN_HANDLED;
}

public cod_weapon_deploy(id, weapon, ent)
	if (weapon == CSW_KNIFE) set_knife(id);

public cod_spawned(id, respawn)
{
	if (!cod_get_user_vip(id) && playerKnife[id] == VIP) {
		set_bonus(id, playerKnife[id], DEFAULT);

		save_knife(id);
	}

	set_knife(id, 1);
}

stock set_knife(id, check = 0)
{
	if (!is_user_alive(id) || (check && get_user_weapon(id) != CSW_KNIFE)) return PLUGIN_CONTINUE;

	set_pev(id, pev_viewmodel2, knifeModels[playerKnife[id]][MODEL]);

	return PLUGIN_CONTINUE;
}

public set_bonus(id, oldKnife, newKnife)
{
	switch (oldKnife) {
		case DEFAULT: {
			cod_add_user_bonus_health(id, -2);
			cod_add_user_bonus_intelligence(id, -2);
			cod_add_user_bonus_stamina(id, -2);
			cod_add_user_bonus_strength(id, -2);
			cod_add_user_bonus_condition(id, -2);
		} case HEALTH: cod_add_user_bonus_health(id, -10);
		case INTELLIGENCE: cod_add_user_bonus_intelligence(id, -10);
		case STAMINA: cod_add_user_bonus_stamina(id, -10);
		case STRENGTH: cod_add_user_bonus_strength(id, -10);
		case CONDITION: cod_add_user_bonus_condition(id, -10);
		case VIP: {
				cod_add_user_bonus_health(id, -4);
				cod_add_user_bonus_intelligence(id, -4);
				cod_add_user_bonus_stamina(id, -4);
				cod_add_user_bonus_strength(id, -4);
				cod_add_user_bonus_condition(id, -4);
			}
		}

	switch (newKnife) {
		case DEFAULT: {
			cod_add_user_bonus_health(id, 2);
			cod_add_user_bonus_intelligence(id, 2);
			cod_add_user_bonus_stamina(id, 2);
			cod_add_user_bonus_strength(id, 2);
			cod_add_user_bonus_condition(id, 2);
		} case HEALTH: cod_add_user_bonus_health(id, 10);
		case INTELLIGENCE: cod_add_user_bonus_intelligence(id, 10);
		case STAMINA: cod_add_user_bonus_stamina(id, 10);
		case STRENGTH: cod_add_user_bonus_strength(id, 10);
		case CONDITION: cod_add_user_bonus_condition(id, 10);
		case VIP: {
			cod_add_user_bonus_health(id, 4);
			cod_add_user_bonus_intelligence(id, 4);
			cod_add_user_bonus_stamina(id, 4);
			cod_add_user_bonus_strength(id, 4);
			cod_add_user_bonus_condition(id, 4);
		}
	}

	playerKnife[id] = newKnife;

	return PLUGIN_CONTINUE;
}

public save_knife(id)
{
	if (!get_bit(id, dataLoaded) || mapEnd) return PLUGIN_CONTINUE;

	new vaultKey[MAX_NAME], vaultData[3];

	formatex(vaultKey, charsmax(vaultKey), "%s-cod_knife", playerName[id]);
	formatex(vaultData, charsmax(vaultData), "%d", playerKnife[id]);

	nvault_set(knives, vaultKey, vaultData);

	return PLUGIN_CONTINUE;
}

public load_knife(id)
{
	if (mapEnd) return PLUGIN_CONTINUE;

	new vaultKey[MAX_NAME], vaultData[3];

	get_user_name(id, playerName[id], charsmax(playerName[]));

	formatex(vaultKey, charsmax(vaultKey), "%s-cod_knife", playerName[id]);

	if (nvault_get(knives, vaultKey, vaultData, charsmax(vaultData))) {
		playerKnife[id] = str_to_num(vaultData);

		set_bonus(id, NONE, playerKnife[id]);
	} else set_bonus(id, NONE, DEFAULT);

	set_bit(id, dataLoaded);

	return PLUGIN_CONTINUE;
}