#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <dhudmessage>
#include <ScreenMenu>

#define BOUNDING 5.0

#define TASK_UPDATE_OPTIONS 34567876
#define TASK_PLAYEDTIME 7367

#define MAX_ITEMS 8
#define LEN_ITEMNAME 32
#define LEN_DESC 128

#define PLUGIN "Screen Menu"
#define VERSION "0.4.2"
#define AUTHOR "R3X"

new const gszEmptySlot[] = "";

new const gszSelectSound[] = "common/menu2.wav";

//Pozycja kursora
new Float:gfPos[33][2];

//Przesuniecie menu
#define MOVING_BOUND 0.2
new Float:gfMenuOffset[33][2];

new giSelected[33];
new Float:gfCanSelect[33];
new giOptions[33][MAX_ITEMS];
new giOptionsNum[33];
new bool:gbOptionsAccess[33][MAX_ITEMS];

new Float:gfStaticAngles[33][3];

stock giMaxPlayers;

new Float:gfLastScan[33];
new bool:gbInPanel[33];
new Float:fEndOfFlash[33];

//Cvary
new gcvarCursor;
new gcvarDynamic;

#define ACCESS_ADMIN  	0
#define ACCESS_FW 	1

//Dane stworzonych menu
new Array:gMenuName;
new Array:gMenuFWSel;
new Array:gMenuFWOver;
new Array:gMenuItems;
new Array:gMenuDescs;
new Array:gMenuAccess;
new Array:gMenuShowDescs;
new Array:gMenuNormalColor;
new Array:gMenuOverColor;
new Array:gMenuDisabledColor;
new Array:gMenuPrefix;
new Array:gMenuTitleColor;

new giCurrentMenu[33];//aktualne menu gracza
new bool:gbInfo[33];

//Cache
new gszItems[33][MAX_ITEMS][LEN_ITEMNAME+1];
new gszItemsDesc[33][MAX_ITEMS][LEN_DESC+1];
new gfwItemAccess[33][MAX_ITEMS];
new gszTitle[33][32];
new giTitleColor[33][3];
new gbShowTitle[33];
new gszPrefix[33][8];

#include "natives.inl"

new Float:gfPosition[33][MAX_ITEMS][2];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	giMaxPlayers = get_maxplayers();
	
	register_forward(FM_PlayerPostThink, "fwPlayerPostThink", 1);
	register_forward(FM_PlayerPreThink, "fwPlayerPreThink", 1);
	register_forward(FM_CmdEnd, "fwCmdStart");
	
	register_event("CurWeapon", "eventCurWeapon", "be")
	register_event("DeathMsg", "eventDeathMsg", "a")
	register_event("ScreenFade","eventScreenFade", "be","4=255","5=255","6=255","7>199");
	RegisterHam(Ham_Spawn, "player", "fwHamSpawn", 1);
	
	gcvarCursor = register_cvar("amx_smenu_cursor", "0");
	gcvarDynamic  =register_cvar("amx_smenu_dynamic", "1");
	
	register_clcmd("+smenu", "cmdStartSMenu");
	register_clcmd("-smenu", "cmdStopSMenu");
}
public plugin_end(){
	ArrayDestroy(gMenuName);
	ArrayDestroy(gMenuFWSel);
	ArrayDestroy(gMenuFWOver);
	
	new iSize;
	new Array:temp;
	
	iSize = ArraySize(gMenuItems);
	for(new i=0;i<iSize;i++){
		temp = Array:ArrayGetCell(gMenuItems, i);
		if(temp) ArrayDestroy(temp);
	}
	ArrayDestroy(gMenuItems);
	
	iSize = ArraySize(gMenuDescs);
	for(new i=0;i<iSize;i++){
		temp = Array:ArrayGetCell(gMenuDescs, i);
		if(temp) ArrayDestroy(temp);
	}
	ArrayDestroy(gMenuDescs);
	
	iSize = ArraySize(gMenuAccess);
	for(new i=0;i<iSize;i++){
		temp = Array:ArrayGetCell(gMenuAccess, i);
		if(temp) ArrayDestroy(temp);
	}
	ArrayDestroy(gMenuAccess);
}

createMoveMenu(){
	new Array:acc = ArrayCreate(2);
	new Array:items = ArrayCreate(LEN_ITEMNAME);
	new Array:desc = ArrayCreate(LEN_DESC);
	
	new iAccess[2];
	iAccess[ACCESS_ADMIN] = 0;
	iAccess[ACCESS_FW] = -666;
	
	ArrayPushArray(acc, iAccess);
	ArrayPushString(items, "Gora");
	ArrayPushString(desc, "");
	
	ArrayPushArray(acc, iAccess);
	ArrayPushString(items, "Prawo");
	ArrayPushString(desc, "");
	
	ArrayPushArray(acc, iAccess);
	ArrayPushString(items, "Dol");
	ArrayPushString(desc, "");
	
	ArrayPushArray(acc, iAccess);
	ArrayPushString(items, "Lewo");
	ArrayPushString(desc, "");
	
	ArrayPushString(gMenuName, "Przesun menu");
	ArrayPushCell(gMenuFWSel, -1);
	ArrayPushCell(gMenuFWOver, -666);
	ArrayPushCell(gMenuItems, items);
	ArrayPushCell(gMenuDescs, desc);
	ArrayPushCell(gMenuAccess, acc);
	ArrayPushCell(gMenuShowDescs, 0);
	ArrayPushArray(gMenuNormalColor, {255, 255, 255});
	ArrayPushArray(gMenuOverColor, {255, 0, 0});
	ArrayPushArray(gMenuDisabledColor, {50, 50, 50});
	ArrayPushString(gMenuPrefix,  "");
	ArrayPushArray(gMenuTitleColor,  {255, 255, 255});
}
public plugin_natives(){
	gMenuName   = ArrayCreate(32);
	gMenuFWSel  = ArrayCreate();
	gMenuFWOver = ArrayCreate();
	gMenuItems  = ArrayCreate();
	gMenuDescs  = ArrayCreate();
	gMenuAccess = ArrayCreate();
	gMenuShowDescs= ArrayCreate();
	gMenuNormalColor = ArrayCreate(3);
	gMenuOverColor = ArrayCreate(3);
	gMenuDisabledColor = ArrayCreate(3);
	gMenuPrefix = ArrayCreate(8);
	gMenuTitleColor = ArrayCreate(3);
	
	createMoveMenu();
	
	register_library("ScreenMenu");
	register_native("smenu_create", 	"_smenu_create");
	register_native("smenu_makecallback", 	"_smenu_makecallback");
	register_native("smenu_additem", 	"_smenu_additem");
	register_native("smenu_items", 		"_smenu_items");
	register_native("smenu_display", 	"_smenu_display");
	register_native("smenu_item_getinfo", 	"_smenu_item_getinfo");
	register_native("smenu_item_setname", 	"_smenu_item_setname");
	register_native("smenu_item_setcmd", 	"_smenu_item_setcmd");
	register_native("smenu_item_setcall", 	"_smenu_item_setcall");
	register_native("smenu_destroy", 	"_smenu_destroy");
	register_native("smenu_addblank", 	"_smenu_addblank");
	register_native("smenu_setprop", 	"_smenu_setprop");
	register_native("smenu_cancel", 	"_smenu_cancel");
	register_native("player_smenu_info", 	"_player_smenu_info");
}
public plugin_precache(){
	precache_sound(gszSelectSound);
}
public client_putinserver(id){
	gbInfo[id] = true;
	
	giSelected[id] = -1;
	giCurrentMenu[id] = 0;
	
	gfMenuOffset[id][0] = gfMenuOffset[id][1] = 0.0;
}

showPanel(id){
	gfCanSelect[id] = get_gametime()+0.2;
	Send_ScreenFade(id, 0, 0, 4, 10, 10, 10, 120); //show layer
	
	pev(id, pev_v_angle, gfStaticAngles[id]);
	
	set_pev(id, pev_viewmodel2, "");
	gbInPanel[id] = true;
	
	displayOptions(id);
	if(task_exists(TASK_UPDATE_OPTIONS+id))
		remove_task(TASK_UPDATE_OPTIONS+id);
	set_task(0.1, "taskUpdateOptions", TASK_UPDATE_OPTIONS+id, _, _, "b");
	
	gfPos[id][0] = 0.0;
	gfPos[id][1] = 0.0;
}

hidePanel(id){
	Send_ScreenFade(id, 0, 0, 4, 0, 0, 0, 0); //hide layer
	gbInPanel[id] = false;
	
	if(task_exists(TASK_UPDATE_OPTIONS+id))
		remove_task(TASK_UPDATE_OPTIONS+id);
	
	restoreWeaponModel(id);
	
	new menu = giCurrentMenu[id];
	giCurrentMenu[id] = 0;
	selectOption(id, menu, giSelected[id], true);
	
}

//Przywracanie modelu broni po wyjsciu z menu
restoreWeaponModel(id){
	//client_cmd(id, "lastinv; wait; lastinv");
	static szModels[][] = {
		"",
		"models/v_p228.mdl","models/v_shield_r.mdl","models/v_scout.mdl",
		"models/v_hegrenade.mdl","models/v_xm1014.mdl","models/v_c4.mdl",
		"models/v_mac10.mdl","models/v_aug.mdl","models/v_smokegrenade.mdl",
		"models/v_elite.mdl","models/v_fiveseven.mdl","models/v_ump45.mdl",
		"models/v_sg550.mdl","models/v_galil.mdl","models/v_famas.mdl",
		"models/v_usp.mdl","models/v_glock18.mdl","models/v_awp.mdl",
		"models/v_mp5.mdl","models/v_m249.mdl","models/v_m3.mdl",
		"models/v_m4a1.mdl","models/v_tmp.mdl","models/v_g3sg1.mdl",
		"models/v_flashbang.mdl","models/v_deagle.mdl","models/v_sg552.mdl",
		"models/v_ak47.mdl","models/v_knife.mdl", "models/v_p90.mdl"
	};
	
	new wid = get_user_weapon(id);
	if(32 > wid > 0) 
		set_pev(id, pev_viewmodel2, szModels[wid]);
}

new Float:gfJump[33];
new Float:gfLast[33];

//Usuwa wszystkie opcje z menu
resetOptions(id){
	gfJump[id] = 0.0;
	gfLast[id] = -90.0;
	
	giOptionsNum[id] = 0;
	giSelected[id] = -1;
}
//Dodaje opcje do menu
setOption(id, caster, options){
	gfJump[id] = 360.0/options;
	
	new index = giOptionsNum[id];
	giOptions[id][index] = caster;
	
	gfPosition[id][index][0] = 0.46 + floatcos(gfLast[id], degrees)*0.23;
	gfPosition[id][index][1] = 0.5 + floatsin(gfLast[id], degrees)*0.23;
	
	giOptionsNum[id]++;
	gfLast[id] += gfJump[id];
}
//Odlegosc miedzy 2 punktam iw 2D
Float:getDistance(Float:A[2], Float:B[2]){
	new Float:x = A[0] - B[0];
	new Float:y = A[1] - B[1];
	return floatsqroot(x*x + y*y);
}
//Ograniczenie pola kursora do kola wokol srodka ekranu
afterBounding(&Float:X, &Float:Y){
	if(floatsqroot(X*X + Y*Y) < BOUNDING)
		return;
		
	//punkt na osi Y
	if(X == 0.0){
		Y = (Y < 0.0)?-BOUNDING:BOUNDING;
		return;
	}

	//punkt na osi X
	if(Y == 0.0){
		X = (X < 0.0)?-BOUNDING:BOUNDING;
		return;
	}
	
	new Float:Start[2];
	Start[0] = X, Start[1] = Y;
	
	new Float:a = Y/X;
	
	//Punkt przeciecia prostej od punktu do (0,0) z okregiem x^2+y^2=BOUNDING^2
	new Float:A1[2], Float:A2[2];
	A1[0] = BOUNDING/(floatsqroot(1+a*a));
	A1[1] = a*A1[0];
	
	A2[0] = -A1[0];
	A2[1] = -A1[1];
	
	//ten blizej staje sie nowym punktem kursora
	if(getDistance(A1, Start) < getDistance(A2, Start))
		X = A1[0], Y = A1[1];
	else
		X = A2[0], Y = A2[1];
}

//Zamiana ruchu mysza na ruch kursora i proba wybrania opcji z menu
translateMove(id){
	if(!gbInPanel[id] || get_gametime() < gfCanSelect[id]) return;
	
	new Float:fAngles[3];
	new Float:fAnglesH4X[3];
	pev(id, pev_v_angle, fAngles);
	xs_vec_copy(fAngles, fAnglesH4X);
	
	if(xs_vec_nearlyequal(fAngles, gfStaticAngles[id]))
		return;
		
	xs_vec_sub(fAngles, gfStaticAngles[id], fAngles);
	
	gfPos[id][0] = gfPos[id][0] - fAngles[1];
	gfPos[id][1] = gfPos[id][1] - fAngles[0];
	
	afterBounding( gfPos[id][0], gfPos[id][1] );
	
	new Float:alfa = floatatan2(gfPos[id][1], gfPos[id][0], degrees);
	alfa = 180.0 - alfa;
	alfa -= 90.0;
	
	if(alfa < 0)
		alfa += 360.0;

	alfa /= 360.0/giOptionsNum[id];
	trySelect(id, floatround(alfa));
	
	if(get_pcvar_num(gcvarDynamic))
		xs_vec_copy(fAnglesH4X, gfStaticAngles[id]);
}

//Proba wybrania opcji z menu
trySelect(id, option){
	if(!gbOptionsAccess[id][option])
		return;
	
	if(option != giSelected[id])
		selectOption(id, giCurrentMenu[id], option);
}

selectOption(id, menu, option, hide = false){
	giSelected[id] = option;
	
	if(ArrayGetCell(gMenuShowDescs,  menu)){
		new index = giOptions[id][option];
		client_print(id, print_center, "%s", gszItemsDesc[id][index]);
	}
	play(id, gszSelectSound);
	gfCanSelect[id] = get_gametime()+0.15;

	
	new fw = ArrayGetCell(hide?gMenuFWSel:gMenuFWOver, menu);
	if(fw == -666)
		mcbMoveMenu(id, menu, option);
	else
		ExecuteForward(fw, fw, id, menu, option);
}
//aktualizacja menu na HUD
public taskUpdateOptions(id){
	id -= TASK_UPDATE_OPTIONS;
	
	if(!is_user_connected(id))
		return;
	
	if(gbInPanel[id]){
		if(!is_user_alive(id)){
			hidePanel(id);
			return;
		}
		
		displayOptions(id);
		
	}else if(task_exists(TASK_UPDATE_OPTIONS+id))
		remove_task(TASK_UPDATE_OPTIONS+id);
}

displayOptions(id){		
	new index;
	new color[3];
	new Float:ox = gfMenuOffset[id][0];
	new Float:oy = gfMenuOffset[id][1];
	for(new i=0;i < giOptionsNum[id]; i++){
		index = giOptions[id][i];
		if(gszItems[id][index][0] == '^0')
			continue;
		
		if(!gbOptionsAccess[id][i]){
			ArrayGetArray(gMenuDisabledColor, giCurrentMenu[id], color);
		}
		else if(giSelected[id] == i){
			ArrayGetArray(gMenuOverColor, giCurrentMenu[id], color);
		}else{
			ArrayGetArray(gMenuNormalColor, giCurrentMenu[id], color);
		}
			
		
		
		set_dhudmessage(color[0], color[1], color[2], gfPosition[id][i][0]+ox, gfPosition[id][i][1]+oy, 0, 0.0, 0.11, 0.01, 0.02, false);
		show_dhudmessage(id, "%s%s", gszPrefix[id], gszItems[id][index]);
	}

	if(get_pcvar_num(gcvarCursor)){
		ArrayGetArray(gMenuNormalColor, giCurrentMenu[id], color);
		set_dhudmessage(color[0], color[1], color[2], ox+0.46+gfPos[id][0]/BOUNDING/4, oy+0.5-gfPos[id][1]/BOUNDING/4, 0, 0.0, 0.11, 0.01, 0.02, false);
		show_dhudmessage(id, "^^");
	}
	
	if(gbShowTitle[id]){
		set_dhudmessage(giTitleColor[id][0], giTitleColor[id][1], giTitleColor[id][2], -1.0, 0.2+oy, 1, 0.0, 0.11, 0.01, 0.02, false);
		show_dhudmessage(id, "%s", gszTitle[id]);
	}
}

stock play(id, const sound[]){
	new end=strlen(sound)-4;
	if(containi(sound,".mp3") == end && end>0)
		client_cmd(id,"mp3 play sound/%s",sound);
	else if(containi(sound,".wav") == end && end>0)
		client_cmd(id, "spk sound/%s",sound);
	else
		client_cmd(id, "speak %s",sound);
	
}

stock Send_ScreenFade(id, duration, holdTime, Flags, r, g, b, a){
	static msgid = 0;
	if(!msgid)
		msgid = get_user_msgid("ScreenFade");
		
	if(get_gametime() < fEndOfFlash[id])
			return;
			
	message_begin(MSG_ONE_UNRELIABLE, msgid, _, id);
	write_short(duration);
	write_short(holdTime);
	write_short(Flags);
	write_byte(r);
	write_byte(g);
	write_byte(b);
	write_byte(a);
	message_end();
}

public fwHamSpawn(id){
	fEndOfFlash[id] = 0.0;
}

public eventScreenFade(id){
	fEndOfFlash[id] = get_gametime() + float(read_data(1))/(1<<12);
}

public eventDeathMsg(){
	new victim = read_data(2);
	if(gbInPanel[victim])
		hidePanel(victim);
}

public eventCurWeapon(id){
	if(gbInPanel[id])
		set_pev(id, pev_viewmodel2, "");
}

public fwPlayerPreThink(id){
	if(!is_user_alive(id))
		return FMRES_IGNORED;
		
	if(gbInPanel[id]){
		if(!get_pcvar_num(gcvarDynamic)){
			set_pev(id, pev_angles, gfStaticAngles[id]);
			set_pev(id, pev_fixangle, 1);
		}
	}
	return FMRES_IGNORED;
}

public fwCmdStart(id, uc_handle, seed){
	if(gbInPanel[id] && !get_pcvar_num(gcvarDynamic)){
		set_uc(uc_handle, UC_ViewAngles, gfStaticAngles[id]);
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}

public fwPlayerPostThink(id){
	if(!is_user_alive(id)) 
		return FMRES_IGNORED;
		
	if(gbInPanel[id]){
		new Float:fNow = get_gametime();
		if(fNow > gfLastScan[id]){
			translateMove(id);
			gfLastScan[id] = fNow+0.02;
		}
		
		if(!get_pcvar_num(gcvarDynamic)){
			set_pev(id, pev_angles, gfStaticAngles[id]);
			set_pev(id, pev_fixangle, 1);
		}
	}
	
	return FMRES_IGNORED;
}

public cbAccessMoveMenu(id, menu, item){
	switch(item){
		case 0:{ 
			//Gora
			if(gfMenuOffset[id][1] <= -MOVING_BOUND)
				return ITEM_DISABLED;
		}
		case 1:{
			//Prawo
			if(gfMenuOffset[id][0] >= MOVING_BOUND)
				return ITEM_DISABLED;
		}
		case 2:{
			//Dol
			if(gfMenuOffset[id][1] >= MOVING_BOUND)
				return ITEM_DISABLED;
		}
		case 3:{
			//Lewo
			if(gfMenuOffset[id][0] <= -MOVING_BOUND)
				return ITEM_DISABLED;
		}
	}
	return ITEM_ENABLED;
}

public mcbMoveMenu(id, menu, item){
	switch(item){
		case 0:{ 
			//Gora
			gfMenuOffset[id][1] -= 0.02;
		}
		case 1:{
			//Prawo
			gfMenuOffset[id][0] += 0.02;
		}
		case 2:{
			//Dol
			gfMenuOffset[id][1] += 0.02;
		}
		case 3:{
			//Lewo
			gfMenuOffset[id][0] -= 0.02;
		}
	}
	displayMenu(id, 0);
}

public cmdStartSMenu(id){
	displayMenu(id, 0);
	return PLUGIN_HANDLED;
}

public cmdStopSMenu(id){
	client_print(id, print_chat, "Zapisano pozycje");
	client_cmd(id, "setinfo _smenu_off ^"%d %d^"", floatround(gfMenuOffset[id][0]/0.02), floatround(gfMenuOffset[id][1]/0.02));
	hidePanel(id);
	return PLUGIN_HANDLED;
}
