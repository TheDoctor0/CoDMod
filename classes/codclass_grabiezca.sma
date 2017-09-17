#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Class Grabiezca"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Grabiezca"
#define DESCRIPTION  "Masz 1/4 szansy na kradziez itemu swojej ofiary. Pelny magazynek po zabiciu."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_FAMAS)|(1<<CSW_USP)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     5
#define STAMINA      0
#define CONDITION    15

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_kill(killer, victim)
{
	cod_refill_ammo(killer);

	if(cod_get_user_item(victim) && cod_get_user_item(killer) != cod_get_user_item(victim) && random_num(1, 4) == 1) show_question(killer, victim);
}

public show_question(id, victim)
{
	new menuTitle[64], itemName[64], tempId[4];

	cod_get_item_name(cod_get_user_item(victim), itemName, charsmax(itemName));

	num_to_str(victim, tempId, charsmax(tempId));

	format(menuTitle, charsmax(menuTitle), "\yCzy chcesz ukrasc item: \r%s\y?", itemName);

	new menu = menu_create(menuTitle, "show_question_handle");
	
	menu_additem(menu, "Tak", tempId);
	menu_setprop(menu, MPROP_EXITNAME, "Nie");
	
	menu_display(id, menu);
}

public show_question_handle(id, menu, item)
{
	if(item) {
		client_cmd(id, "spk %s", codSounds[SOUND_EXIT]);

		menu_destroy(menu);

		return;
	}

	client_cmd(id, "spk %s", codSounds[SOUND_SELECT]);

	new itemData[4], victim, itemAccess, menuCallback;

	menu_item_getinfo(menu, item, itemAccess, itemData, charsmax(itemData), _, _, menuCallback);

	victim = str_to_num(itemData);

	new itemValue, item = cod_get_user_item(victim, itemValue);

	menu_destroy(menu);

	if(!cod_get_user_item(victim) || cod_get_user_item(id) == cod_get_user_item(victim)) return;
	
	new thiefName[32];

	get_user_name(id, thiefName, charsmax(thiefName));

	cod_print_chat(victim, "Twoj item zostal skradziony przez^x03 %s^x01.", thiefName);

	cod_set_user_item(victim);
	cod_set_user_item(id, item, itemValue);
}