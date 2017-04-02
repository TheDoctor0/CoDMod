#if defined _serverquery_included
	#endinput
#endif

#define _serverquery_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib serverquery
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib serverquery
	#endif
#else
	#pragma library serverquery
#endif

#include < amxmodx >

#define SQ_RULE_NAME_SIZE  256
#define SQ_RULE_VALUE_SIZE 256

/*
 * Queries a server for information
 * 
 * @param		ip - IP of the server without port
 * @param		port - The port number of the server
 * @param		type - The type of query to perform (matches SQ_* constants)
 * @param		function - The callback function to be executed when the query is finished
 * @param		error - The error code given when there was a problem with the query (matches SQError_* constants)
 * @param		timeout - The time in seconds to wait for a response before setting as failed
 * @param		data - Extra data array to pass to the callback function
 * @param		data_size - Size of the extra data array being passed
 * 
 * @note		Only 1 query can be performed on the same ip:port combination at a time.
 * 			Trying to use a different query type on the same ip:port while another is already taking place will throw an error.
 * 
 * @return		Returns unique SQuery ID (integer) on success, 0 on failure (and passes error code to param)
 * 
 * 
 * Structure for callback function:
 * 
 * sq_query("127.0.0.1", 27015, SQ_Server, "SQueryResults", errcode)
 * 
 * public SQueryResults(squery_id, type, Trie:buffer, Float:query_time, bool:failed, data[], data_size)
 * 
 * @param		squery_id - The unique SQuery ID (integer) return value from sq_query()
 * @param		type - The type of query performed (matches SQ_* constants)
 * @param		buffer - The buffer containing the server info
 * @param		query_time - The time in seconds it took for the query to finish
 * @param		failed - false if results were found, true otherwise
 * @param		data - The data sent to the sq_query() native
 * @param		data_size - The size of the data sent to the sq_query() native
 * 
 * @note		The buffer is a Trie with key->value pairs for data
 * 			Do not destroy this (or any Arrays or Tries it contains) in the callback!
 * 
 * @return		Return value is ignored
 * 
 */
enum _:ServerQueryType
{
	SQ_Server,
	SQ_Players,
	SQ_Challenge,
	SQ_Ping,
	SQ_Rules,
};
native sq_query(const ip[],const port,const type,const function[],&error,const timeout=60,const data[]="",const data_size=0);

/*
 * Gets a description of the errcode when sq_query() fails
 * 
 * @param		errcode - The error code from the sq_query() function (matches SQError_* constants)
 * @param		error - The output string to contain the description
 * @param		len - The max length of the result string
 * 
 * @return		The length of the result on success, 0 on failure
 * 
 */
enum _:ServerQueryErrors
{
	SQError_NoError,
	SQError_InvalidParams,
	SQError_MaxConnections,
	SQError_InvalidQueryType,
	SQError_InvalidIP,
	SQError_CouldNotConnect,
	SQError_InvalidFunction,
	SQError_AlreadyConnected
};
stock sq_error(const errcode,error[],const len)
{
	switch( errcode )
	{
		/*case SQError_NoError:
		{
			return copy( error, len, "No error" );
		}*/
		case SQError_InvalidParams:
		{
			return copy( error, len, "Invalid function parameter list." );
		}
		case SQError_MaxConnections:
		{
			return copy( error, len, "Too many server queries are already taking place." );
		}
		case SQError_InvalidQueryType:
		{
			return copy( error, len, "Invalid server query type." );
		}
		case SQError_InvalidIP:
		{
			return copy( error, len, "Invalid IP given." );
		}
		case SQError_CouldNotConnect:
		{
			return copy( error, len, "Could not connect to given IP." );
		}
		case SQError_InvalidFunction:
		{
			return copy( error, len, "Invalid function handle." );
		}
		case SQError_AlreadyConnected:
		{
			return copy( error, len, "Connection exists for given IP." );
		}
	}
	
	return 0;
}

/*
 * Gets a description of the server type based on it's servertype info from the buffer
 * 
 * @param		servertype - The servertype retrieved from the server info buffer (matches SERVERTYPE_* constants)
 * @param		result - The output string to contain the description
 * @param		len - The max length of the result string
 * 
 * @return		The length of the result on success, 0 on failure
 * 
 */
#define SERVERTYPE_LISTEN    'l' // listen
#define SERVERTYPE_DEDICATED 'd' // dedicated
#define SERVERTYPE_HLTV      'p' // HLTV
stock sq_servertype(const servertype,result[],const len)
{
	switch( servertype )
	{
		case SERVERTYPE_LISTEN:
		{
			return copy( result, len, "Listen" );
		}
		case SERVERTYPE_DEDICATED:
		{
			return copy( result, len, "Dedicated" );
		}
		case SERVERTYPE_HLTV:
		{
			return copy( result, len, "HLTV" );
		}
	}
	
	return 0;
}

/*
 * Converts the time played in the server into a descriptive string
 * 
 * @param		time_played - The time played
 * @param		output - The output string
 * @param		output_len - The max length of the output string
 * @param		steam_format (optional) - If true, it will be in the Steam format of "View Game Info" (eg. 1h 59m 13s, or 12m 4s). If false, it will be in HH:MM:SS format (default: false)
 * 
 * @return		The length of the output string
 * 
 */
stock sq_timeplayed(const Float:time_played,output[],const output_len,bool:steam_format=false)
{
	new iSeconds = floatround(time_played, floatround_floor);
	new iMinutes = iSeconds / 60;
	new iHours = iMinutes / 60;
	
	iSeconds %= 60;
	iMinutes %= 60;
	
	new iLen;
	
	if( steam_format )
	{
		if( iHours )
		{
			iLen = formatex( output, output_len, "%dh ", iHours );
		}
		
		if( iMinutes || iLen )
		{
			iLen += formatex( output[ iLen ], output_len - iLen, "%dm ", iMinutes );
		}
		
		if( iSeconds || iLen )
		{
			iLen += formatex( output[ iLen ], output_len - iLen, "%ds", iSeconds );
		}
	}
	else
	{
		iLen = formatex( output, output_len, "%d:%02d:%02d", iHours, iMinutes, iSeconds );
	}
	
	return iLen;
}

/*
 * Converts The Ship's response for game mode into a string
 * 
 * @param		game_mode - The game mode of the server
 * @param		output - The output string
 * @param		output_len - The max length of the output string
 * 
 * @return		The length of the output string on success, 0 on failure
 * 
 */
enum _:SHIP_GAMEMODES
{
	SHIP_GAMEMODE_HUNT,
	SHIP_GAMEMODE_ELIM,
	SHIP_GAMEMODE_DUEL,
	SHIP_GAMEMODE_DM,
	SHIP_GAMEMODE_TEAM_VIP,
	SHIP_GAMEMODE_TEAM_ELIM
};
stock sq_theship_gamemode(const game_mode,output[],const output_len)
{
	// 0x00 for Hunt, 0x01 for Elimination, 0x02 for Duel, 0x03 for Deathmatch, 0x04 for Team VIP, 0x05 for Team Elimination
	
	static const szGameModes[ SHIP_GAMEMODES ][ ] =
	{
		"Hunt",
		"Elimination",
		"Duel",
		"Deathmatch",
		"Team VIP",
		"Team Elimination"
	};
	
	return ( 0 <= game_mode < SHIP_GAMEMODES ) ? copy( output, output_len, szGameModes[ game_mode ] ) : 0;
}

/*
 * Reads a long from a buffer at a given start position
 * 
 * @param		buffer - The buffer to read from
 * @param		buffer_len - The length of the buffer
 * @param		start - The start position of the buffer
 * @param		result - The integer that is read is passed into that variable by reference
 * 
 * @return		Returns the end position in the buffer where the integer stops
 * 
 */
stock sq_readlong(const {Array,_}:buffer,const buffer_len,start,&result)
{
	return sq_readint( buffer, buffer_len, start, 4, result, true );
}

/*
 * Reads a short from a buffer at a given start position
 * 
 * @param		buffer - The buffer to read from
 * @param		buffer_len - The length of the buffer
 * @param		start - The start position of the buffer
 * @param		result - The integer that is read is passed into that variable by reference
 * 
 * @return		Returns the end position in the buffer where the integer stops
 * 
 */
stock sq_readshort(const {Array,_}:buffer,const buffer_len,start,&result)
{
	return sq_readint( buffer, buffer_len, start, 2, result, false );
}

/*
 * Reads a byte from a buffer at a given start position
 * 
 * @param		buffer - The buffer to read from
 * @param		buffer_len - The length of the buffer
 * @param		start - The start position of the buffer
 * @param		result - The integer that is read is passed into that variable by reference
 * 
 * @return		Returns the end position in the buffer where the integer stops
 * 
 */
stock sq_readbyte(const {Array,_}:buffer,const buffer_len,start,&result)
{
	return sq_readint( buffer, buffer_len, start, 1, result, false );
}

/*
 * Reads a float from a buffer at a given start position
 * 
 * @param		buffer - The buffer to read from
 * @param		buffer_len - The length of the buffer
 * @param		start - The start position of the buffer
 * @param		result - The float that is read is passed into that variable by reference
 * 
 * @return		Returns the end position in the buffer where the float stops
 * 
 */
stock sq_readfloat(const {Array,_}:buffer,const buffer_len,start,&Float:result)
{
	return sq_readint( buffer, buffer_len, start, 4, _:result, false );
}

/*
 * Reads an integer from a buffer at a given start position for a specific number of bytes
 * 
 * @param		buffer - The buffer to read from
 * @param		buffer_len - The length of the buffer
 * @param		start - The start position of the buffer
 * @param		bytes - The number of bytes to read
 * @param		result - The float that is read is passed into that variable by reference
 * @param		check_neg (optional) - If true, it checks if the integer is negative, otherwise it doesn't check (default: true)
 * 
 * @return		Returns the end position in the buffer where the integer stops
 * 
 */
stock sq_readint(const {Array,_}:buffer,const buffer_len,start,bytes,&result,bool:check_neg=true)
{
	result = 0;
	
	new iPos = start;
	
	if( ( iPos + bytes - 1 ) < buffer_len )
	{
		new bool:bNegative = ( check_neg && ArrayGetCell( Array:buffer, iPos + bytes - 1 ) < 0 );
		new iTemp;
		
		for( new i = 0; i < bytes; i++ )
		{
			result = sq_fixedunsigned8( ArrayGetCell( Array:buffer, iPos++ ) );
			
			if( bNegative )
			{
				result = 0xFF - result;
			}
			
			iTemp += ( result << ( 8 * i ) );
		}
		
		if( bNegative )
		{
			iTemp = ( iTemp + 1 ) * -1;
		}
		
		result = iTemp;
	}
	else
	{
		iPos += bytes;
	}
	
	return iPos;
}

/*
 * Reads a string from a buffer at given start position
 * 
 * @param		buffer - The buffer to read from
 * @param		buffer_len - The length of the buffer
 * @param		start - The start position of the buffer
 * @param		output - The output string
 * @param		output_len - The max length of the output string
 * 
 * @return		Returns the end position of where the string stops
 * 
 */
stock sq_readstring(const {Array,_}:buffer,const buffer_len,start,output[],const output_len)
{
	new iPos = start - 1;
	
	new cChar, iLen;
	while( ++iPos < buffer_len && ( cChar = ArrayGetCell( Array:buffer, iPos ) ) != 0 )
	{
		if( iLen < output_len )
		{
			output[ iLen++ ] = cChar;
		}
	}
	
	output[ iLen ] = 0;
	
	return ( iPos + 1 );
}

/*
 * Fixes a value to an unsigned 8-bit integer
 * 
 * @param		value - The value to be fixed
 * 
 * @return		Returns the fixed unsigned 8-bit integer
 * 
 */
stock sq_fixedunsigned8(value)
{
	value = clamp( value, -0xFF, 0xFF );
	
	if( value < 0 )
	{
		value = 0xFF + value + 1;
	}
	
	return value;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
