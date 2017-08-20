#include <amxmodx>
#include <codmod>
#include <fun>

new const perk_name[] = "Betonowe cialo";
new const perk_desc[] = "Przez 10 sekund mozna cie zabic tylko w glowe";

new bool:wykorzystal[33]

public plugin_init()
{
	register_plugin(perk_name, "1.0", "fbang");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("ResetHUD", "ResetHUD", "abe");
}

public cod_perk_enabled(id)
	wykorzystal[id] = false;
	
public cod_perk_used(id)
{
	if(wykorzystal[id])
	{
		client_print(id, print_center, "Wykorzystales juz umiejetnosc w tej rundzie.");
		return;
	}
	
	wykorzystal[id] = true;
	
	set_user_hitzones(0, id, 2)
	set_task(10.0, "WylaczGod", id);
	
	message_begin(MSG_ONE, get_user_msgid("BarTime"), _, id)
	write_short(10)
	message_end()
}

public WylaczGod(id)
{
	if(!is_user_connected(id)) return;
	
	set_user_hitzones(0, id, 255)
}

public ResetHUD(id)
	wykorzystal[id] = false;
