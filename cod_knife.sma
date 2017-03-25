#include <amxmodx>
#include <fakemeta>
#include <nvault>
#include <cod>

#define PLUGIN "CoD Knives"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

enum _:knife { NAME, BONUS, MODEL, DEFAULT, HEALTH, INTELLIGENCE, STAMINA, STRENGTH, CONDITION };

new const knifeModels[][][] =
{
	{ "Standardowy", "(+2 Kazdej Statystyki)", "models/v_knife.mdl" },
	{ "Mysliwski", "(+10 Zdrowia)", "models/CoDMod/hunting.mdl" },
	{ "Kieszonkowy", "(+10 Inteligencji)", "models/CoDMod/pocket.mdl" },
	{ "Tasak", "(+10 Wytrzymalosci)", "models/CoDMod/chopper.mdl" },
	{ "Maczeta", "(+10 Sily)", "models/CoDMod/machete.mdl" },
	{ "Katana", "(+10 Kondycji)", "models/CoDMod/katana.mdl" }
};

new const commandKnives[][] = { "say /noz", "say_team /noz", "say /noze", "say_team /noze", "say /knife", "say_team /knife", 
"say /knifes", "say_team /knifes", "say /kosa", "say_team /kosa", "say /kosy", "say_team /kosy", "noze" };

new playerName[MAX_PLAYERS + 1][64], playerKnife[MAX_PLAYERS + 1], knives;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
 
	for(new i; i < sizeof commandKnives; i++) register_clcmd(commandKnives[i], "change_knife");
	
	knives = nvault_open("cod_knives");
	
	if(knives == INVALID_HANDLE) set_fail_state("[COD] Nie mozna otworzyc pliku cod_knives.vault");
}

public plugin_precache() 
	for(new i = 1; i < sizeof(knifeModels); i++) precache_model(knifeModels[i][MODEL]);

public plugin_end()
	nvault_close(knives);

public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id)) return;

	playerKnife[id] = DEFAULT;
	
	load_knife(id);
}

public change_knife(id)
{
	if(!cod_check_account(id)) return PLUGIN_HANDLED;

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new knifeData[64], knifeId[3], menu = menu_create("\wWybierz \yModel Noza\w:", "change_knife_handle");
	
	for(new i = 0; i < sizeof(knifeModels); i++)
	{
		formatex(knifeData, charsmax(knifeData), "%s \r%s", knifeModels[i][NAME], knifeModels[i][BONUS]);

		num_to_str(i + DEFAULT, knifeId, charsmax(knifeId));
		
		menu_additem(menu, knifeData, knifeId);
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public ChangeKnife_Handler(id, menu, item)
{
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return PLUGIN_HANDLED;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);
	
	new knifeId[3], itemAccess, itemCallback;

	menu_item_getinfo(menu, item, itemAccess, knifeId, charsmax(knifeId), _, _, itemCallback);

	set_bonus(id, playerKnife[id], str_to_num(knifeId));
	
	save_knife(id);
	
	cod_print_chat(id, "Twoj nowy noz to:^x03 %s %s^x01!", knifeModels[id][NAME], knifeModels[id][BONUS]);

	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public cod_weapon_deploy(id, weapon, ent)
	if(weapon == CSW_KNIFE) set_knife(id);

public cod_spawn(id)
	set_knife(id, 1);

stock set_knife(id, check = 1)
{
	if(!is_user_alive(id) || (check && get_user_weapon(id) != CSW_KNIFE)) return PLUGIN_CONTINUE;
	
	set_pev(id, pev_viewmodel2, knifeModels[MODEL][playerKnife[id]]); 

	return PLUGIN_CONTINUE;
}

public set_bonus(id, oldKnife, newKnife)
{
	switch(oldKnife)
	{
		case DEFAULT:
		{
			cod_set_user_bonus_health(id, cod_get_user_bonus_health(id) - 2);
			cod_set_user_bonus_intelligence(id, cod_get_user_bonus_intelligence(id) - 2);
			cod_set_user_bonus_stamina(id, cod_get_user_bonus_stamina(id) - 2);
			cod_set_user_bonus_strength(id, cod_get_user_bonus_strength(id) - 2);
			cod_set_user_bonus_condition(id, cod_get_user_bonus_condition(id) - 2);
		}
		case HEALTH: cod_set_user_bonus_health(id, cod_get_user_bonus_health(id) - 10);
		case INTELLIGENCE: cod_set_user_bonus_intelligence(id, cod_get_user_bonus_intelligence(id) - 10);
		case STAMINA: cod_set_user_bonus_stamina(id, cod_get_user_bonus_stamina(id) - 10);
		case STRENGTH: cod_set_user_bonus_strength(id, cod_get_user_bonus_strength(id) - 10);
		case CONDITION: cod_set_user_bonus_condition(id, cod_get_user_bonus_condition(id) - 10);
	}

	switch(newKnife)
	{
		 case DEFAULT:
		{
			cod_set_user_bonus_health(id, cod_get_user_bonus_health(id) + 2);
			cod_set_user_bonus_intelligence(id, cod_get_user_bonus_intelligence(id) + 2);
			cod_set_user_bonus_stamina(id, cod_get_user_bonus_stamina(id) + 2);
			cod_set_user_bonus_strength(id, cod_get_user_bonus_strength(id) + 2);
			cod_set_user_bonus_condition(id, cod_get_user_bonus_condition(id) + 2);
		}
		case HEALTH: cod_set_user_bonus_health(id, cod_get_user_bonus_health(id) + 10);
		case INTELLIGENCE: cod_set_user_bonus_intelligence(id, cod_get_user_bonus_intelligence(id) + 10);
		case STAMINA: cod_set_user_bonus_stamina(id, cod_get_user_bonus_stamina(id) + 10);
		case STRENGTH: cod_set_user_bonus_strength(id, cod_get_user_bonus_strength(id) + 10);
		case CONDITION: cod_set_user_bonus_condition(id, cod_get_user_bonus_condition(id) + 10);
	}

	playerKnife[id] = newKnife;

	return PLUGIN_CONTINUE;
}

public save_knife(id)
{
	new vaultKey[64], vaultData[3];
	
	formatex(vaultKey, charsmax(vaultKey), "%s-cod_knife", playerName[id]);
	formatex(vaultData, charsmax(vaultData), "%d", playerKnife[id]);
	
	nvault_set(knives, vaultKey, vaultData);
	
	return PLUGIN_CONTINUE;
}

public load_knife(id)
{
	new vaultKey[64], vaultData[3];

	get_user_name(id, playerName[id], charsmax(playerName[]));
	
	formatex(vaultKey, charsmax(vaultKey), "%s-cod_knife", playerName[id]);
	
	if(nvault_get(knives, vaultKey, vaultData, charsmax(vaultData)))
	{
		playerKnife[id] = str_to_num(vaultData);

		set_bonus(id, DEFAULT, playerKnife[id]);
	}
	else set_bonus(id, BONUS, DEFAULT);

	return PLUGIN_CONTINUE;
} 