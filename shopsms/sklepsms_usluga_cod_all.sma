#include <amxmodx>
#include <shop_sms>

#define PLUGIN "Sklep-SMS: Usluga CoD All"
#define AUTHOR "O'Zone"

#if !defined VERSION
#define VERSION "3.3.7"
#endif

new const serviceID[MAX_ID] = "cod_all";

public plugin_init()
	register_plugin(PLUGIN, VERSION, AUTHOR);

public plugin_cfg()
	ss_register_service(serviceID);