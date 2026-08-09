#include <amxmodx>
#include <nvault>
#include <cod>

#define PLUGIN "CoD Free Honor"
#define AUTHOR "O'Zone"

new const commandHonor[][] = { "freehonor", "say /freehonor", "say_team /freehonor", "say /darmowyhonor", "say_team /darmowyhonor" };

new playerName[MAX_PLAYERS + 1][MAX_NAME], cvarFreeHonor, received, loaded, vault;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	bind_pcvar_num(create_cvar("cod_free_honor", "500"), cvarFreeHonor);

	for (new i; i < sizeof commandHonor; i++) register_clcmd(commandHonor[i], "receive_honor");

	// Only kept around to import servers that ran on the vault based version.
	vault = nvault_open("cod_free_honor");
}

public plugin_end()
	if (vault != INVALID_HANDLE) nvault_close(vault);

public receive_honor(id)
{
	if (!get_bit(id, loaded)) return PLUGIN_HANDLED;

	if (!get_bit(id, received)) {
		cod_print_chat(id, "Otrzymales za darmo^3 %i honoru^1, milej gry!", cvarFreeHonor);

		cod_add_user_honor(id, cvarFreeHonor);

		set_bit(id, received);

		save(id);
	} else {
		cod_print_chat(id, "Juz odebrales swoj^3 darmowy honor^1!");
	}

	return PLUGIN_HANDLED;
}

public client_connect(id)
{
	rem_bit(id, received);
	rem_bit(id, loaded);
}

public cod_player_loaded(id, playerId)
{
	get_user_name(id, playerName[id], charsmax(playerName[]));

	if (cod_get_player_field(id, DB_PLAYER_BONUS)) set_bit(id, received);
	else if (import_vault(id)) set_bit(id, received);

	set_bit(id, loaded);

	if (get_bit(id, received)) save(id);
}

/**
 * One time move of the pre database bonus flag. The vault entry is left alone
 * so the import stays repeatable if the database is reset.
 */
stock bool:import_vault(id)
{
	if (vault == INVALID_HANDLE) return false;

	new vaultKey[MAX_NAME + 16], vaultData[2];

	formatex(vaultKey, charsmax(vaultKey), "%s-cod_honor", playerName[id]);

	return nvault_get(vault, vaultKey, vaultData, charsmax(vaultData)) && str_to_num(vaultData) > 0;
}

public save(id)
{
	if (!get_bit(id, loaded)) return;

	cod_set_player_field(id, DB_PLAYER_BONUS, get_bit(id, received) ? 1 : 0);
}
