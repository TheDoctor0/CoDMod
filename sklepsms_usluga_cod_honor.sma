#include <amxmodx>
#include <shop_sms>
#include <cod>

#define PLUGIN "Sklep-SMS: Usluga CoD Honor"
#define AUTHOR "O'Zone"
#define VERSION "3.3.7"

new const service_id[MAX_ID] = "cod_honor";

public plugin_init()
	register_plugin(PLUGIN, VERSION, AUTHOR);

public plugin_natives()
	set_native_filter("native_filter");

public plugin_cfg()
	ss_register_service(service_id)

public ss_service_bought(id,amount)
	cod_add_user_honor(id, amount);

public native_filter(const native_name[], index, trap) 
{
	if (trap == 0) {
		register_plugin(PLUGIN, VERSION, AUTHOR);

		pause_plugin();

		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
