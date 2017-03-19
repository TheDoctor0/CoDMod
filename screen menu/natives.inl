#include <amxmodx>
#include <amxmisc>

stock isValidMenuid(menu){
	return (0 < menu < ArraySize(gMenuName))
}
stock menuHasSlot(menu){
	new Array:temp = Array:ArrayGetCell(gMenuItems, menu);
	return (isValidMenuid(menu) && ArraySize(temp) < MAX_ITEMS);
}

public _smenu_create(plugin, params){
	if(params < 3){
		return 0;
	}
	
	new szString[64], fw;
	get_string(1, szString, 31);
	ArrayPushString(gMenuName, szString);

	get_string(2, szString, 31);
	fw = CreateOneForward(plugin, szString, FP_CELL, FP_CELL, FP_CELL);
	ArrayPushCell(gMenuFWSel, fw);
	
	get_string(3, szString, 31);
	fw = CreateOneForward(plugin, szString, FP_CELL, FP_CELL, FP_CELL);
	ArrayPushCell(gMenuFWOver, fw);
	
	new Array:acc = ArrayCreate(2);
	new Array:items = ArrayCreate(LEN_ITEMNAME);
	new Array:desc = ArrayCreate(LEN_DESC);
	
	ArrayPushCell(gMenuAccess, acc);
	ArrayPushCell(gMenuItems, items);
	ArrayPushCell(gMenuDescs, desc);
	
	ArrayPushCell(gMenuShowDescs, 0);
	
	ArrayPushArray(gMenuNormalColor, {240, 240, 120});
	ArrayPushArray(gMenuOverColor, {240, 120, 0});
	ArrayPushArray(gMenuDisabledColor, {50, 50, 50});
	
	ArrayPushString(gMenuPrefix,  "^xCF^xBE ");
	ArrayPushArray(gMenuTitleColor,  {255, 255, 255});
	
	return ArraySize(gMenuName)-1;
}

public _smenu_makecallback(plugin, params){
	if(params < 1)
		return 0;
	new szFunction[32];
	get_string(1, szFunction, 31);
	
	return CreateOneForward(plugin, szFunction, FP_CELL, FP_CELL, FP_CELL);
}


public _smenu_additem(plugin, params){
	if(params < 5)
		return 0;
	
	new menu = get_param(1);
	if(!isValidMenuid(menu)){
		log_error(AMX_ERR_NOTFOUND, "Invalid menu id")
		return 0;
	}
	
	new szName[LEN_ITEMNAME], szDesc[LEN_DESC];
	get_string(2, szName, LEN_ITEMNAME-1);
	get_string(3, szDesc, LEN_DESC-1);
	
	new itemaccess[2];
	itemaccess[ACCESS_ADMIN] = get_param(4);
	itemaccess[ACCESS_FW] = get_param(5);
	
	new Array:items = Array:ArrayGetCell(gMenuItems, menu);
	new Array:descs = Array:ArrayGetCell(gMenuDescs, menu);
	new Array:acc = Array:ArrayGetCell(gMenuAccess, menu);
	
	ArrayPushString(items, szName);
	ArrayPushString(descs, szDesc);
	ArrayPushArray(acc, itemaccess);
	
	return ArraySize(items)-1;
}

public _smenu_items(plugin, params){
	new menu = get_param(1);
	if(!isValidMenuid(menu)){
		log_error(AMX_ERR_NOTFOUND, "Invalid menu id")
		return 0;
	}
	new Array:items = Array:ArrayGetCell(gMenuItems, menu);
	return ArraySize(items);
}

hasItemAccess(id, menu, item){
	if(gfwItemAccess[id][item] == -1)
		return ITEM_IGNORE;
	
	if(gfwItemAccess[id][item] == -666)
		return cbAccessMoveMenu(id, menu, item);
		
	new iRet;
	if(!ExecuteForward(gfwItemAccess[id][item], iRet ,id, menu, item))
		return ITEM_IGNORE;
	return iRet;
}

displayMenu(id, menu, selected=-2){
	if(gbInPanel[id])
		hidePanel(id);
		
	new Array:items = Array:ArrayGetCell(gMenuItems, menu);
	new Array:descs = Array:ArrayGetCell(gMenuDescs, menu);
	new Array:acc = Array:ArrayGetCell(gMenuAccess, menu);
	
	new iSize = ArraySize(items);
	if(iSize == 0) 
		return 0;
		
	new itemaccess[2];
	new ret;
	
	resetOptions(id);
	
	//-2 : zadne
	//-1:  auto
	//0..iSize-1 : item
	giSelected[id] = clamp(selected, -2, iSize-1);
	
	for(new i=0; i<iSize; i++){
		ArrayGetString(items, i, gszItems[id][i], LEN_ITEMNAME-1);
		ArrayGetString(descs, i, gszItemsDesc[id][i], LEN_DESC-1);
		ArrayGetArray(acc, i, itemaccess);
		
		gfwItemAccess[id][i] = itemaccess[ACCESS_FW];
		
		if(itemaccess[ACCESS_ADMIN] == -1)
			ret = ITEM_DISABLED;
		else
			ret = hasItemAccess(id, menu, i)
			;
		switch(ret){
			case ITEM_ENABLED:  	gbOptionsAccess[id][i] = true;
			case ITEM_DISABLED: 	gbOptionsAccess[id][i] = false;
			case ITEM_IGNORE: 	gbOptionsAccess[id][i] = get_user_flags(id)&itemaccess[0] == itemaccess[0];
		}
		if(giSelected[id] == -1 && gbOptionsAccess[id][i])
			giSelected[id] = i;
		
		setOption(id, i, iSize);
	}

	if(giSelected[id] == -1)
		return 0;
		
	ArrayGetString(gMenuName, menu, gszTitle[id], 31);
	ArrayGetString(gMenuPrefix, menu, gszPrefix[id], 7);
	ArrayGetArray(gMenuTitleColor, menu, giTitleColor[id]);
	gbShowTitle[id] = giTitleColor[id][0] + giTitleColor[id][1] + giTitleColor[id][2];
		
		
	new szInfo[10];	
	if(menu){
		if(get_user_info(id, "_smenu_off", szInfo, 8)){
			new szX[5], szY[5];
			if(parse(szInfo, szX, 4, szY, 4) == 2){
				gfMenuOffset[id][0] = clamp(str_to_num(szX), -11, 11)*0.02;
				gfMenuOffset[id][1] = clamp(str_to_num(szY), -11, 11)*0.02;
			}
		}else if(gbInfo[id]){
			gbInfo[id] = false;
			client_print(id, print_chat, "* Jesli nie podoba Ci sie miejsce polozenia kolowego menu uzyj komendy +smenu");
			client_print(id, print_chat, "* np. bind j +smenu");
		}
	}
	
	giCurrentMenu[id] = menu;
	showPanel(id);
	return 1;
}
public _smenu_display(plugin, params){
	if(params < 3)
		return 0;
		
	new id = get_param(1);
	if(!is_user_connected(id))
		return 0;
	
	new menu = get_param(2);
	if(!isValidMenuid(menu)){
		log_error(AMX_ERR_NOTFOUND, "Invalid menu id")
		return 0;
	}
	
	
	return displayMenu(id, menu, get_param(3));
}


public _smenu_item_getinfo(plugin, params){
	if(params < 8)
		return 0;
		
	new menu = get_param(1);
	if(!isValidMenuid(menu)){
		log_error(AMX_ERR_NOTFOUND, "Invalid menu id")
		return 0;
	}
	
	new item = get_param(2);
	if(item < 0)
		return 0;
		
	new Array:items = Array:ArrayGetCell(gMenuItems, menu);
	new Array:descs = Array:ArrayGetCell(gMenuDescs, menu);
	new Array:acc = Array:ArrayGetCell(gMenuAccess, menu);
	if(item >= ArraySize(descs))
		return 0;
	
	new iAccess[2];
	ArrayGetArray(acc, item, iAccess);
	
	new szName[LEN_ITEMNAME];
	ArrayGetString(items, item, szName, LEN_ITEMNAME-1);
	
	new szDesc[LEN_DESC];
	ArrayGetString(descs, item, szDesc, LEN_DESC-1);
	
	set_param_byref(3, iAccess[ACCESS_ADMIN]);
	set_string(4, szDesc, get_param(5));
	set_string(6, szName, get_param(7));
	set_param_byref(8, iAccess[ACCESS_FW]);
	
	return 1;
}


public _smenu_item_setname(plugin, params){
	if(params < 3)
		return 0;
		
	new menu = get_param(1);
	if(!isValidMenuid(menu)){
		log_error(AMX_ERR_NOTFOUND, "Invalid menu id")
		return 0;
	}
	
	new item = get_param(2);
	if(item < 0)
		return 0;
		
	new Array:items = Array:ArrayGetCell(gMenuItems, menu);
	if(item >= ArraySize(items))
		return 0;
		
	new szName[LEN_ITEMNAME];
	get_string(3, szName, LEN_ITEMNAME-1);
	ArraySetString(items, item, szName);
	return 1;
}


public _smenu_item_setcmd(plugin, params){
	if(params < 3)
		return 0;
		
	new menu = get_param(1);
	if(!isValidMenuid(menu)){
		log_error(AMX_ERR_NOTFOUND, "Invalid menu id")
		return 0;
	}
	
	new item = get_param(2);
	if(item < 0)
		return 0;
		
	new Array:descs = Array:ArrayGetCell(gMenuDescs, menu);
	if(item >= ArraySize(descs))
		return 0;
		
	new szDesc[LEN_DESC];
	get_string(3, szDesc, LEN_DESC-1);
	ArraySetString(descs, item, szDesc);
	return 1;
}


public _smenu_item_setcall(plugin, params){
	if(params < 3)
		return 0;
		
	new menu = get_param(1);
	if(!isValidMenuid(menu)){
		log_error(AMX_ERR_NOTFOUND, "Invalid menu id")
		return 0;
	}
	
	new item = get_param(2);
	if(item < 0)
		return 0;
		
	new Array:acc= Array:ArrayGetCell(gMenuAccess, menu);
	if(item >= ArraySize(acc))
		return 0;
	
	new iAccess[2];
	ArrayGetArray(acc, item, iAccess);
	iAccess[ACCESS_FW] = get_param(3);
	ArraySetArray(acc, item, iAccess);
	return 1;
}


public _smenu_destroy(plugin, params){
	if(params < 1)
		return 0;
		
	new menu = get_param(1);
	if(!isValidMenuid(menu)){
		log_error(AMX_ERR_NOTFOUND, "Invalid menu id")
		return 0;
	}
	
	new Array:items = Array:ArrayGetCell(gMenuItems, menu);
	new Array:descs = Array:ArrayGetCell(gMenuDescs, menu);
	new Array:acc = Array:ArrayGetCell(gMenuAccess, menu);
	
	ArrayDestroy(items);
	ArrayDestroy(descs);
	ArrayDestroy(acc);
	
	ArraySetString(gMenuName, menu, "");
	ArraySetCell(gMenuFWOver, menu, 0);
	ArraySetCell(gMenuFWSel, menu, 0);
	return 0;
}

public _smenu_addblank(plugin, params){
	if(params < 1)
		return 0;
	
	new menu = get_param(1);
	if(!isValidMenuid(menu)){
		log_error(AMX_ERR_NOTFOUND, "Invalid menu id")
		return 0;
	}
	
	
	new itemaccess[2];
	itemaccess[ACCESS_ADMIN] = -1;
	itemaccess[ACCESS_FW] = -1;
	
	new Array:items = Array:ArrayGetCell(gMenuItems, menu);
	new Array:descs = Array:ArrayGetCell(gMenuDescs, menu);
	new Array:acc = Array:ArrayGetCell(gMenuAccess, menu);
	
	ArrayPushString(items, gszEmptySlot);
	ArrayPushString(descs, "");
	ArrayPushArray(acc, itemaccess);
	
	return ArraySize(items)-1;
}


public _smenu_setprop(plugin, params){
	if(params < 2)
		return 0;
		
	new menu = get_param(1);
	if(!isValidMenuid(menu)){
		log_error(AMX_ERR_NOTFOUND, "Invalid menu id")
		return 0;
	}
	
	new prop = get_param(2);
	new iArray[3];
	
	switch(prop){
		case SMPROP_SHOW_DESCRIPTION:{
			ArraySetCell(gMenuShowDescs, menu, get_param_byref(3));
		}
		case SMPROP_NORMAL_COLOR:{
			get_array(3, iArray, 3);
			ArraySetArray(gMenuNormalColor, menu, iArray);
		}
		case SMPROP_OVER_COLOR:{
			get_array(3, iArray, 3);
			ArraySetArray(gMenuOverColor, menu, iArray);
		}
		case SMPROP_DISABLED_COLOR:{
			get_array(3, iArray, 3);
			ArraySetArray(gMenuDisabledColor, menu, iArray);
		}
		case SMPROP_TITLE_COLOR:{
			get_array(3, iArray, 3);
			ArraySetArray(gMenuTitleColor, menu, iArray);
		}
		case SMPROP_PREFIX:{
			new szPrefix[8];
			get_string(3, szPrefix, 7);
			ArraySetString(gMenuPrefix, menu, szPrefix);
		}
	}
	return 1;
}


public _smenu_cancel(plugin, params){
	new id = get_param(1);
	if(!is_user_connected(id))
		return 0;
		
	if(gbInPanel[id])
		hidePanel(id);
	return 1;
}


public _player_smenu_info(plugin, params){
	new id = get_param(1);
	if(!is_user_connected(id))
		return 0;
		
	if(gbInPanel[id])
		return giCurrentMenu[id];
	return 0;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
