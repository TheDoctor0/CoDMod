#include <amxmodx>
#include <amxmisc>
#include <codmod>

#define PLUGIN "New Plug-In"
#define VERSION "1.0"
#define AUTHOR "DarkGL"

new bool:bMaPerk[33];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_message(get_user_msgid("ScreenFade"), "messageScreenFade");

	cod_register_perk("Ciemne Okulary","Nie dzialaja na ciebie flashe");
}

public cod_perk_disabled(id)	bMaPerk[id] = false
public cod_perk_enabled(id)	bMaPerk[id] = true

public messageScreenFade(msgtype, msgid, id){
	if(bMaPerk[id])	return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}
