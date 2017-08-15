#include <amxmodx>
#include <shop_sms>
#include <cod>

#define PLUGIN "Sklep-SMS: Usluga CoD Exp Transfer"
#define AUTHOR "O'Zone"
#define VERSION "3.3.7"

#define TASK_CHECK_FIRST 1000
#define TASK_CHECK_SECOND 2000

new const service_id[MAX_ID] = "zp_exp_transfer";

new fromClass[33], toClass[33], currentClass[33], fromClassExp[33];

public plugin_init()
	register_plugin(PLUGIN, VERSION, AUTHOR);

public plugin_natives()
	set_native_filter("native_filter");

public plugin_cfg()
	ss_register_service(service_id);

public ss_service_addingtolist(id)
	return cod_get_classes_num() >= 2 ? ITEM_ENABLED : ITEM_OFF;

public ss_service_chosen(id) {
	fromClass[id] = toClass[id] = currentClass[id] = fromClassExp[id] = 0;

	new className[64], menu = menu_create("Z jakiej klasy chcesz przeniesc exp?","fromClassMenu_handle");

	for(new i = 1; i <= cod_get_classes_num(); i++)
	{
		cod_get_class_name(i, _, className, charsmax(className));
		
		menu_additem(menu, className);
	}
	
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	
	menu_display(id,menu);
	
	return SS_STOP;
}

public fromClassMenu_handle(id, menu, item) 
{
	if(item == MENU_EXIT) 
	{
		menu_destroy(menu);

		return SS_STOP;
	}
	
	fromClass[id] = item + 1;

	menu_destroy(menu);
		
	new className[64], menu = menu_create("Na jaka klase chcesz przeniesc exp?","toClassMenu_handle"), menu_callback = menu_makecallback("toClassMenu_callback");

	for(new i = 1; i <= cod_get_classes_num(); i++)
	{
		cod_get_class_name(i, _, className, charsmax(className));
		
		menu_additem(menu, className, _, _, menu_callback);
	}
		
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	
	menu_display(id, menu);

	return SS_STOP;
}

public toClassMenu_callback(id, menu, item)
	return fromClass[id] == item + 1 ? ITEM_DISABLED : ITEM_ENABLED;

public toClassMenu_handle(id, menu, item) 
{
	if(item == MENU_EXIT) 
	{
		menu_destroy(menu);

		return SS_STOP;
	}
	
	toClass[id] = item+1;
		
	menu_destroy(menu);
	
	currentClass[id] = cod_get_user_class(id);
	
	cod_set_user_class(id, fromClass[id]);

	chosen_checkFirstClass(TASK_CHECK_FIRST + id);

	return SS_STOP;
}

public chosen_checkFirstClass(id) 
{
	id -= TASK_CHECK_FIRST;

	if(cod_get_user_class(id) == fromClass[id]) 
	{
		cod_set_user_class(id,toClass[id]);

		chosen_checkSecondClass(TASK_CHECK_SECOND + id);
	}
	else if(cod_get_user_class(id) == currentClass[id]) set_task(0.2, "chosen_checkFirstClass", TASK_CHECK_FIRST + id);
	else if(!cod_get_user_class(id)) client_print_color(id, id,"^x04[SKLEPSMS] ^x01Nie masz uprawnien, aby skorzystac z klasy z ktorej chcesz przeniesc EXP.");
}

public chosen_checkSecondClass(id) 
{
	id -= TASK_CHECK_SECOND;

	if(cod_get_user_class(id) == toClass[id]) 
	{
		cod_set_user_class(id, currentClass[id]);

		ss_show_sms_info(id);
	}
	else if(cod_get_user_class(id) == fromClass[id]) set_task(0.2, "chosen_checkSecondClass", TASK_CHECK_SECOND + id);
	else if(!cod_get_user_class(id)) client_print_color(id, id,"^x04[SKLEPSMS] ^x01Nie masz uprawnien, aby skorzystac z klasy z ktorej chcesz przeniesc EXP.");
}

public ss_service_bought(id, amount) 
{	
	cod_set_user_class(id,fromClass[id]);
	
	bought_checkFirstClass(TASK_CHECK_FIRST + id);
}

public bought_checkFirstClass(id) 
{
	id -= TASK_CHECK_FIRST;

	if(cod_get_user_class(id) == fromClass[id]) 
	{
		fromClassExp[id] = cod_get_user_exp(id);
		
		cod_set_user_exp(id, -fromClassExp[id]);
		
		new playerName[32], className[64]; 

		get_user_name(id, playerName, charsmax(playerName));
		cod_get_class_name(fromClass[id], _, className, charsmax(className));

		ss_log("Zabrano graczowi %s %d EXPa z klasy %s", playerName, fromClassExp[id], className);
		
		cod_set_user_class(id, toClass[id]);

		bought_checkSecondClass(TASK_CHECK_SECOND + id);
	}
	else if(cod_get_user_class(id) == currentClass[id]) set_task(0.2, "bought_checkFirstClass", TASK_CHECK_FIRST + id);
}

public bought_checkSecondClass(id) 
{
	id -= TASK_CHECK_SECOND;

	if(cod_get_user_class(id) == toClass[id])
	{
		cod_set_user_exp(id, fromClassExp[id]);
		
		cod_set_user_class(id, currentClass[id]);
		
		new playerName[32], fromClassName[64], toClassName[64]; 

		get_user_name(id, playerName, charsmax(playerName));
		cod_get_class_name(fromClass[id], _, fromClassName, charsmax(fromClassName));
		cod_get_class_name(toClass[id], _, toClassName, charsmax(toClassName));

		ss_log("Przeniesiono graczowi %s %d EXPa z klasy %s na klase %s", playerName, fromClassExp[id], fromClassName, toClassName);
	}
	else if(cod_get_user_class(id) == fromClass[id]) set_task(0.2, "bought_checkSecondClass", TASK_CHECK_SECOND + id);
}

public native_filter(const native_name[], index, trap) 
{
	if(trap == 0) 
	{
		register_plugin(PLUGIN, VERSION, AUTHOR);

		pause_plugin();

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
