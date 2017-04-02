/*
	by xPaw
*/

#if defined _cmdunban_included
    #endinput
#endif
#define _cmdunban_included

public cmdUnBan( id, level, cid ) {
	if( !cmd_access( id, level, cid, 2 ) )
		return PLUGIN_HANDLED;
	
	new text[ 128 ];
	read_args( text, 127 );
	trim( text );
	remove_quotes( text );
	mysql_escape_string( text, text, 127 );
	
	new szQuery[ 512 ];
	formatex( szQuery, 511, "SELECT bid,player_nick,player_id FROM %s%s WHERE (`player_ip`='%s' OR `player_id`='%s') AND `expired`=0 LIMIT 1", g_dbPrefix, tbl_bans, text, text );
	
	if ( get_pcvar_num(pcvar_debug) >= 1 )
		log_amx( "[AMXBans cmdUnBan] Trying to unban a player: %s", text );
	
	new data[ 1 ];
	data[ 0 ] = id;
	SQL_ThreadQuery( g_SqlX, "HandleSelectBan", szQuery, data, 1 );
	
	return PLUGIN_HANDLED;
}

public HandleNullRoute( failstate, Handle:hQuery, error[], errnum, data[], size ) {
	if( failstate ) {
		new szQuery[ 256 ];
		SQL_GetQueryString( hQuery, szQuery, 255 );
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 6 );
	}
}

public HandleSelectBan( failstate, Handle:hQuery, error[], errnum, data[], size ) {
	if( failstate ) {
		new szQuery[ 256 ];
		SQL_GetQueryString( hQuery, szQuery, 255 );
		MySqlX_ThreadError( szQuery, error, errnum, failstate, 6 );
	} else {
		new id = data[ 0 ];
		
		if( !SQL_NumResults( hQuery ) ) {
			console_print( id, "[AMXBans] %L", LANG_PLAYER, "PLAYER_NOT_FOUND", g_ident );
		} else {
			if ( get_pcvar_num(pcvar_debug) >= 1 )
				log_amx( "[AMXBans HandleSelectBan] Player found, trying to unban" );
			
			new iBanId = SQL_ReadResult( hQuery, 0 );
			
			new szQuery[ 512 ];
			#if defined UNBAN_GAME_DEL
			formatex( szQuery, 511, "DELETE FROM %s%s WHERE `expired`=0 AND `bid`='%i' LIMIT 1", g_dbPrefix, tbl_bans, iBanId );
			#else
			formatex( szQuery, 511, "UPDATE `%s%s` SET expired=1 WHERE bid=%d", g_dbPrefix, tbl_bans, iBanId );
			#endif
			SQL_ThreadQuery( g_SqlX, "HandleNullRoute", szQuery );
			
			new szAdminIp[ 16 ], szAdminName[ 32 ] = "Server";
			get_user_ip( id, szAdminIp, 15, true );
			if( id > 0 ) get_user_name( id, szAdminName, 31 );
			
			new szName[ 32 ], szSteamId[ 34 ];
			SQL_ReadResult( hQuery, 1, szName, 31 );
			SQL_ReadResult( hQuery, 2, szSteamId, 33 );
			
			#if defined UNBAN_GAME_DEL
			formatex( szQuery, 511, "INSERT INTO %s_logs VALUES (NULL,'%i','%s',^"%s^",'In-Game Unban',^"Deleted ban: ID %i (<%s><%s>)^")",
				g_dbPrefix, get_systime( ), szAdminIp, szAdminName, iBanId, szName, szSteamId );
			#else
			formatex( szQuery, 511, "INSERT INTO %s_logs VALUES (NULL,'%i','%s',^"%s^",'In-Game Unban',^"Set expire ban: ID %i (<%s><%s>)^")",
				g_dbPrefix, get_systime( ), szAdminIp, szAdminName, iBanId, szName, szSteamId );
			#endif
			
			SQL_ThreadQuery( g_SqlX, "HandleNullRoute", szQuery );
			
			console_print( id, "[AMXBans] ^"%s^"<%s> has been successfully unbanned", szName, szSteamId );
		}
	}
}