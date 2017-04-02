#if defined _shop_sms_const_included
	#endinput
#endif
#define _shop_sms_const_included

#pragma library "shop_sms_const"

//#define VERSION "3.3.5"

#define PREFIX "SKLEP-SMS"

#define SS_OK -1
#define SS_ERROR -2
#define SS_STOP -3
#define SS_BAD_ARGS -4

#define MAX_SMS_TEXT 32
#define MAX_SERVICE_TAG 16
#define MAX_NAME 32
#define MAX_ID 32
#define MAX_PASSWORD 32
#define MAX_DESCRIPTION 28
#define MAX_CODE 16
#define MAX_CONFIG 512
#define MAX_NUMBER 16

#define ITEM_OFF 3

#define TYPE_NICK 1<<0
#define TYPE_IP 1<<1
#define TYPE_SID 1<<2
