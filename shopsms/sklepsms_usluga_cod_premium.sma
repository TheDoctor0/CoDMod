#include <amxmodx>
#include <shop_sms>

#define PLUGIN "Sklep-SMS: Usluga CoD Premium"
#define AUTHOR "O'Zone"
#define VERSION "3.3.7"

new const serviceID[MAX_ID] = "cod_premium";

public plugin_init()
	register_plugin(PLUGIN, VERSION, AUTHOR);

public plugin_cfg()
	ss_register_service(serviceID);