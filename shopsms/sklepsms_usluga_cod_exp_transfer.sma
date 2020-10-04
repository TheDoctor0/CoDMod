#include <amxmodx>
#include <shop_sms>
#include <cod>

#define PLUGIN "Sklep-SMS: Usluga CoD Exp Transfer"
#define AUTHOR "O'Zone"

#if !defined VERSION
#define VERSION "3.3.7"
#endif

#define TASK_CHECK_FIRST 1000
#define TASK_CHECK_SECOND 2000

new const serviceID[MAX_ID] = "cod_exp_transfer";

new fromClass[MAX_PLAYERS + 1], toClass[MAX_PLAYERS + 1], currentClass[MAX_PLAYERS + 1], fromClassExp[MAX_PLAYERS + 1];

public plugin_init()
	register_plugin(PLUGIN, VERSION, AUTHOR);

public plugin_natives()
	set_native_filter("native_filter");

public plugin_cfg()
	ss_register_service(serviceID);

public ss_service_addingtolist(id)
	return cod_get_classes_num() >= 2 ? ITEM_ENABLED : ITEM_DISABLED;

public ss_service_chosen(id)
{
	fromClass[id] = toClass[id] = currentClass[id] = fromClassExp[id] = 0;

	new className[64], menu = menu_create("\yZ jakiej \rKlasy\y chcesz przeniesc exp?", "from_class_menu_handle");

	for (new i = 1; i <= cod_get_classes_num(); i++) {
		cod_get_class_name(i, _, className, charsmax(className));

		menu_additem(menu, className);
	}

	menu_setprop(menu, MPROP_EXITNAME, "Wyjscie");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednie");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepne");

	menu_display(id,menu);

	return SS_STOP;
}

public from_class_menu_handle(id, menu, item)
{
	if (item == MENU_EXIT) {
		menu_destroy(menu);

		return SS_STOP;
	}

	fromClass[id] = item + 1;

	menu_destroy(menu);

	new className[64], menu = menu_create("\yNa jaka \rKlase\y chcesz przeniesc exp?", "to_class_menu_handle");

	for (new i = 1; i <= cod_get_classes_num(); i++) {
		if (fromClass[id] == i) continue;

		cod_get_class_name(i, _, className, charsmax(className));

		menu_additem(menu, className);
	}

	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");

	menu_display(id, menu);

	return SS_STOP;
}

public to_class_menu_handle(id, menu, item)
{
	if(item == MENU_EXIT) {
		menu_destroy(menu);

		return SS_STOP;
	}

	toClass[id] = item + 1;

	menu_destroy(menu);

	currentClass[id] = cod_get_user_class(id);

	cod_set_user_class(id, fromClass[id]);

	check_first_class(TASK_CHECK_FIRST + id);

	return SS_STOP;
}

public check_first_class(id)
{
	id -= TASK_CHECK_FIRST;

	if (cod_get_user_class(id) == fromClass[id])
	{
		cod_set_user_class(id,toClass[id]);

		check_second_class(TASK_CHECK_SECOND + id);
	} else if (cod_get_user_class(id) == currentClass[id]) set_task(0.2, "check_first_class", TASK_CHECK_FIRST + id);
	else if (!cod_get_user_class(id)) client_print_color(id, id,"^4[SKLEP-SMS] ^1Nie masz uprawnien, aby skorzystac z klasy z ktorej chcesz przeniesc exp.");
}

public check_second_class(id)
{
	id -= TASK_CHECK_SECOND;

	if (cod_get_user_class(id) == toClass[id]) {
		cod_set_user_class(id, currentClass[id]);

		ss_show_sms_info(id);
	} else if (cod_get_user_class(id) == fromClass[id]) set_task(0.2, "check_second_class", TASK_CHECK_SECOND + id);
	else if (!cod_get_user_class(id)) client_print_color(id, id,"^4[SKLEP-SMS] ^1Nie masz uprawnien, aby skorzystac z klasy z ktorej chcesz przeniesc exp.");
}

public ss_service_bought(id, amount)
{
	cod_set_user_class(id,fromClass[id]);

	bought_check_first_class(TASK_CHECK_FIRST + id);
}

public bought_check_first_class(id)
{
	id -= TASK_CHECK_FIRST;

	if (cod_get_user_class(id) == fromClass[id]) {
		fromClassExp[id] = cod_get_user_exp(id);

		cod_set_user_exp(id, -fromClassExp[id]);

		new playerName[32], className[64];

		get_user_name(id, playerName, charsmax(playerName));
		cod_get_class_name(fromClass[id], _, className, charsmax(className));

		log_to_file("sklep_sms.log", "Zabrano graczowi %s %d EXPa z klasy %s", playerName, fromClassExp[id], className);

		cod_set_user_class(id, toClass[id]);

		bought_check_second_class(TASK_CHECK_SECOND + id);
	} else if (cod_get_user_class(id) == currentClass[id]) set_task(0.2, "bought_check_first_class", TASK_CHECK_FIRST + id);
}

public bought_check_second_class(id)
{
	id -= TASK_CHECK_SECOND;

	if (cod_get_user_class(id) == toClass[id]) {
		cod_set_user_exp(id, fromClassExp[id]);
		cod_set_user_class(id, currentClass[id]);

		new playerName[32], fromClassName[64], toClassName[64];

		get_user_name(id, playerName, charsmax(playerName));
		cod_get_class_name(fromClass[id], _, fromClassName, charsmax(fromClassName));
		cod_get_class_name(toClass[id], _, toClassName, charsmax(toClassName));

		log_to_file("sklep_sms.log", "Przeniesiono graczowi %s %d EXPa z klasy %s na klase %s", playerName, fromClassExp[id], fromClassName, toClassName);
	}
	else if (cod_get_user_class(id) == fromClass[id]) set_task(0.2, "bought_check_second_class", TASK_CHECK_SECOND + id);
}

public native_filter(const native_name[], index, trap)
{
	if (trap == 0) {
		register_plugin(PLUGIN, VERSION, AUTHOR);

		pause_plugin();

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
