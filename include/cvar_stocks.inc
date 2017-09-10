/**
* UpdateCvars() {
*	for(new i=0; i<eCvary; ++i) {
*		UpdateCvarValue(g_Cvary[i]);
*	}
* }
*/
#if defined _cvar_stocks_included
	#endinput
#endif
#define _cvar_stocks_included

enum ValueType {
	ValueType_Int = 0,
	ValueType_Bool,
	ValueType_Float,
	ValueType_Flag,
	ValueType_String
};

enum EnumCvar {
	CvarHandle,				// Handle of the cvar.
	ValueType:CvarType,	// Type of value. (int, bool, float, flag)
	any:LastCvarValue,
	any:PrevCvarValue,		// Previous value.
	any:CvarValue			// The value.
};

#define CVAR_MAX_LEN 256

enum EnumCvarT {
	CvarHandleT,
	LastCvarValueT[CVAR_MAX_LEN+1],
	PrevCvarValueT[CVAR_MAX_LEN+1],
	CvarValueT[CVAR_MAX_LEN+1]
};


stock AddCvar(newCvar[EnumCvar], ValueType:type, handle) {
	newCvar[CvarHandle] = handle;
	newCvar[CvarType] = _:type;

	if(handle) {
		SetCvarDefault(newCvar);
	}
}

stock AddCvarT(newCvar[EnumCvarT], handle) {
	newCvar[CvarHandleT] = handle;

	if(handle) {
		SetCvarDefaultT(newCvar);
	}
}

stock SetCvarDefault(setCvar[EnumCvar]) {
	new defCvar[32];
	get_pcvar_string(setCvar[CvarHandle], defCvar, 31);
	switch(setCvar[CvarType]) {
		case ValueType_Int:		setCvar[CvarValue] = setCvar[PrevCvarValue] = setCvar[LastCvarValue] = str_to_num(defCvar);
		case ValueType_Bool:		setCvar[CvarValue] = setCvar[PrevCvarValue] = setCvar[LastCvarValue] = bool:str_to_num(defCvar);
		case ValueType_Float:	setCvar[CvarValue] = setCvar[PrevCvarValue] = setCvar[LastCvarValue] = _:str_to_float(defCvar);
		case ValueType_Flag:		setCvar[CvarValue] = setCvar[PrevCvarValue] = setCvar[LastCvarValue] = read_flags(defCvar);
	}
}

stock SetCvarDefaultT(setCvar[EnumCvarT]) {
	get_pcvar_string(setCvar[CvarHandleT], setCvar[CvarValueT], CVAR_MAX_LEN);
	copy(setCvar[PrevCvarValueT], CVAR_MAX_LEN, setCvar[CvarValueT]);
	copy(setCvar[LastCvarValueT], CVAR_MAX_LEN, setCvar[CvarValueT]);
}

stock UpdateCvarValue(upCvar[EnumCvar]) {
	upCvar[PrevCvarValue] = upCvar[CvarValue];
	switch(upCvar[CvarType]) {
		case ValueType_Int:		upCvar[CvarValue] = get_pcvar_num(upCvar[CvarHandle]);
		case ValueType_Bool:		upCvar[CvarValue] = bool:get_pcvar_num(upCvar[CvarHandle]);
		case ValueType_Float:	upCvar[CvarValue] = _:get_pcvar_float(upCvar[CvarHandle]);
		case ValueType_Flag: {
			new flagCvar[32];
			get_pcvar_string(upCvar[CvarHandle], flagCvar, 31);
			upCvar[CvarValue] = read_flags(flagCvar);
		}
	}
}

stock UpdateCvarValueT(upCvar[EnumCvarT]) {
	copy(upCvar[PrevCvarValueT], CVAR_MAX_LEN, upCvar[CvarValueT]);
	get_pcvar_string(upCvar[CvarHandleT], upCvar[CvarValueT], CVAR_MAX_LEN);

	CheckCvarValueLenT(upCvar);
}

stock SetCvarValue(setCvar[EnumCvar], {_,bool,Float}:value) {
	setCvar[PrevCvarValue] = setCvar[CvarValue];
	switch(setCvar[CvarType]) {
		case ValueType_Int:		set_pcvar_num(setCvar[CvarHandle], _:value);
		case ValueType_Bool:		set_pcvar_num(setCvar[CvarHandle], bool:value);
		case ValueType_Float:	set_pcvar_float(setCvar[CvarHandle], Float:value);
		case ValueType_Flag: {
			new flagCvar[32];
			get_flags(_:value, flagCvar, 31);
			set_pcvar_string(setCvar[CvarHandle], flagCvar);
		}
	}
	setCvar[CvarValue] = value;
}

stock SetCvarValueT(setCvar[EnumCvarT], const value[]) {
	copy(setCvar[PrevCvarValueT], CVAR_MAX_LEN, setCvar[CvarValueT]);
	set_pcvar_string(setCvar[CvarHandleT], value);
	copy(setCvar[CvarValueT], CVAR_MAX_LEN, value);

	CheckCvarValueLenT(setCvar);
}

stock CheckCvarValueLenT(cheCvar[EnumCvarT], len=CVAR_MAX_LEN-1) {
	if(strlen(cheCvar[CvarValueT]) >= len) {
		log_amx("Cvar (id: %i, value: %s) probably have too much chars.", cheCvar[CvarHandleT], cheCvar[CvarValueT]);
	}
}

stock bool:IsCvarValueChanged(isCvar[EnumCvar]) {
	return bool:(isCvar[PrevCvarValue] != isCvar[CvarValue]);
}

stock bool:IsCvarValueChangedT(isCvar[EnumCvarT]) {
	return bool:(!equal(isCvar[PrevCvarValueT], isCvar[CvarValueT]));
}

stock CheckToggleCvarValue(cheCvar[EnumCvar]) {
	if(cheCvar[PrevCvarValue] && !cheCvar[CvarValue]) {
		return -1;
	}
	else if(!cheCvar[PrevCvarValue] && cheCvar[CvarValue]) {
		return 1;
	}
	return 0;
}
