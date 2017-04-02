#pragma reqlib AMXBansCore
#if !defined AMXMODX_NOAUTOLOAD
	#pragma loadlib AMXBansCore
#endif

#if defined _amxbans_core_included
	#endinput
#endif
#define _amxbans_core_included

// get amxbans db prefix
// standalone native, see forward amxbans_sql_initialized
native amxbans_get_db_prefix(output[],len=32);

// get admin nick from web
native amxbans_get_admin_nick(id,output[],len=32);

// returns 1 if admin has to use static bantime
// param id: the player id
native amxbans_get_static_bantime(id);

// executed if the db is initialized
// value sqlTuble: the db info tuble Handle which you can use to connect, don´t free it!!
// value dbPrefix: the db Prefix from amxbans
forward amxbans_sql_initialized(Handle:sqlTuple,dbPrefix[]);

// executed if a player gets admin
// value id: the player id
forward amxbans_admin_connect(id);

// executed if a admin disconnects
// value id: the player id
forward amxbans_admin_disconnect(id);