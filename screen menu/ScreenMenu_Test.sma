#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <ScreenMenu>

#define PLUGIN "ScreenMenu Test"
#define VERSION "1.0"
#define AUTHOR "R3X"

new menu;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_EmitSound, "fwEmitSound");
	register_forward(FM_PlayerPreThink, "fwPlayerPreThink", 1);
	
	menu = smenu_create("Menu testowe", "mcbScreenMenu", "mcbScreenMenuOver");

	smenu_additem(menu, "Opcja #1", "Opis opcji 1", ADMIN_IMMUNITY);
	smenu_additem(menu, "Opcja #2", "Opis opcji 2");
	smenu_additem(menu, "Opcja #3", "Opis opcji 3");
	smenu_additem(menu, "Opcja #4", "Opis opcji 4");
	smenu_additem(menu, "Opcja #5", "Opis opcji 5");
}

public mcbScreenMenu(id, menu, item){
	if(item > 0)
		client_print(id, print_chat, "Wybrales opcje %d", item);
}

public mcbScreenMenuOver(id, menu, item){
	client_print(id, print_chat, "Jestes nad opcja %d", item);
}

//Pokaz menu na E

new Float:gfLastUse[33];

public fwEmitSound(id, channel, const szSample[], Float:vol, Float:att, flags, pitch){
	if(!is_user_alive(id) || channel != 3)
		return FMRES_IGNORED;
		
	if(equal(szSample, "common/wpn_denyselect.wav"))
		return FMRES_SUPERCEDE;
	
		
	if(equal(szSample, "common/wpn_select.wav")){
		gfLastUse[id] = 0.0;
	}
	return FMRES_IGNORED;
}

public fwPlayerPreThink(id){
	if(!is_user_alive(id))
		return FMRES_IGNORED;
		
	static buttons, oldbuttons;
	buttons = pev(id, pev_button);
	oldbuttons = pev(id, pev_oldbuttons);
		
	if(player_smenu_info(id) == menu){		
		if(buttons&IN_USE == 0)
			smenu_exit(id);
	}else{
		new Float:fNow = get_gametime();
		if(buttons&IN_USE && oldbuttons&IN_USE == 0)
			gfLastUse[id] = fNow;
		else{
			if(fNow-gfLastUse[id] < 0.1)
				smenu_display(id, menu, -2);
		}
	}
	return FMRES_IGNORED;
}

