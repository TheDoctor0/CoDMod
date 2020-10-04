#include <amxmodx>
#include <nvault>
#include <cod>

#define PLUGIN "CoD Free Honor"
#define VERSION "1.1.0"
#define AUTHOR "RevengeST & O'Zone"

new const commandHonor[][] = { "freehonor", "say /freehonor", "say_team /freehonor" };

new playerName[MAX_PLAYERS + 1][MAX_NAME], cvarFreeHonor, received, loaded, vault;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	bind_pcvar_num(create_cvar("cod_free_honor", "500"), cvarFreeHonor);

	for (new i; i < sizeof commandHonor; i++) register_clcmd(commandHonor[i], "receive_honor");

	vault = nvault_open("cod_free_honor");

	if (vault == INVALID_HANDLE) set_fail_state("[COD] Nie mozna otworzyc pliku cod_free_honor.vault");
}

public receive_honor(id)
{
	if (!get_bit(id, loaded)) return PLUGIN_HANDLED;

	if (!get_bit(id, received)) {
		cod_print_chat(id, "Otrzymales za darmo^3 %i honoru^1, milej gry!", cvarFreeHonor);

		cod_add_user_honor(id, cvarFreeHonor);

		set_bit(id, received);

		save(id);
	} else cod_print_chat(id, "Juz odebrales swoj^3 darmowy honor^1!");

	return PLUGIN_HANDLED;
}

public client_connect(id)
{
	rem_bit(id, received);
	rem_bit(id, loaded);

	if (is_user_bot(id) || is_user_hltv(id)) return;

	load(id);
}

public load(id)
{
	new vaultKey[MAX_NAME], vaultData[2];

	get_user_name(id, playerName[id], charsmax(playerName[]));

	formatex(vaultKey, charsmax(vaultKey), "%s-cod_honor", playerName[id]);

	if (nvault_get(vault, vaultKey, vaultData, charsmax(vaultData)) && str_to_num(vaultData) > 0) {
		set_bit(id, received);
	}

	set_bit(id, loaded);
}

public save(id)
{
	if (!get_bit(id, loaded)) return;

	new vaultKey[MAX_NAME], vaultData[2];

	formatex(vaultKey, charsmax(vaultKey), "%s-cod_honor", playerName[id]);
	formatex(vaultData, charsmax(vaultData), "%d", get_bit(id, received));

	nvault_set(vault, vaultKey, vaultData);
}