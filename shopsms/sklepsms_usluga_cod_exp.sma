#include <amxmodx>
#include <shop_sms>
#include <cod>

#define PLUGIN "Sklep-SMS: Usluga CoD Exp"
#define AUTHOR "O'Zone"

#if !defined VERSION
#define VERSION "3.3.7"
#endif

new const service_id[MAX_ID] = "cod_exp";

public plugin_init()
	register_plugin(PLUGIN, VERSION, AUTHOR);

public plugin_natives()
	set_native_filter("native_filter");

public plugin_cfg()
	ss_register_service(service_id);

public ss_service_chosen(id)
{
	if (!cod_get_user_class(id)) {
		client_print_color(id, id, "^3[SKLEPSMS]^1 Musisz^4 wybrac klase^1, aby moc zakupic^4 EXP^1.");

		return SS_STOP;
	}

	return SS_OK;
}

public ss_service_bought(id, amount)
	cod_set_user_exp(id, amount);

public native_filter(const native_name[], index, trap)
{
	if (trap == 0) {
		register_plugin(PLUGIN, VERSION, AUTHOR);

		pause_plugin();

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
