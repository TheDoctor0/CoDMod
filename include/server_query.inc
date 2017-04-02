
#if defined _server_query_included
	#endinput
#endif
#define _server_query_included

#include <amxmodx>
#include <amxmisc>
#include <sockets>
#include <celltrie>


#if !defined TASKID_FETCHING
	#define TASKID_FETCHING 256437
#endif

#define TASKTIME 0.1


#define A2A_PING 			1
#define A2A_SERVERQUERY_GETCHALLENGE 	2
#define A2A_INFO 			3
#define A2A_PLAYER 			4
#define A2A_RULES 			5

stock Array:__gszServers;
stock Array:__giA2ACodes;
stock Array:__giCallbacks;
stock Array:__giData


/**
 * Request sending
 */

stock ServerPing(const szServer[], const szCallback[])
{
	__ServerQueryAdd(szServer, A2A_PING, szCallback);
}

stock ServerChallenge(const szServer[], const szCallback[])
{
	__ServerQueryAdd(szServer, A2A_SERVERQUERY_GETCHALLENGE,  szCallback);
}

stock ServerInfo(const szServer[], const szCallback[],szData[] = 0)
{	
	__ServerQueryAdd(szServer, A2A_INFO,  szCallback,szData);
}

stock ServerRules(const szServer[], const szCallback[])
{	
	__ServerQueryAdd(szServer, A2A_RULES,  szCallback);
}

stock ServerPlayer(const szServer[], const szCallback[])
{	
	__ServerQueryAdd(szServer, A2A_PLAYER,  szCallback);
}




/**
 * Challenge manager
 */
 
new Trie:__gChallenges;
 
stock ServerSetChallenge(const szServer[], challenge)
{
	if(_:__gChallenges == 0)
	{
		__gChallenges = TrieCreate();
	}
	
	TrieSetCell(__gChallenges, szServer, challenge);
}

stock ServerGetChallenge(const szServer[])
{
	if(_:__gChallenges == 0)
	{
		__gChallenges = TrieCreate();
	}
	
	new challenge;
	if(TrieGetCell(__gChallenges, szServer, challenge))
	{
		return challenge;
	}
	
	return 0;
}

/**
 * Response Parsing
 */
stock ServerResponseSave(const szFile[], const Response[], len)
{
	new fp = fopen(szFile, "wb");
	fwrite_blocks(fp, Response, len, BLOCK_CHAR);
	fclose(fp);
}

stock ServerResponseParseInfo
(
	const Response[], 
	szName[], namelen,
	szMap[], maplen,
	szDirectory[], dirlen,
	szDescription[], desclen,
	&iPlayers, 
	&iMaxPlayers
)
{
	new iType;
	new iTemp;
	new current = 0;
	current += ServerResponseReadByte(Response[current], iType);
	
	switch(iType)
	{
		case 0x49:
		{
			current += ServerResponseReadByte(Response[current], iTemp);
			current += ServerResponseReadString(Response[current], szName, namelen);
			current += ServerResponseReadString(Response[current], szMap, maplen);
			current += ServerResponseReadString(Response[current], szDirectory, dirlen);
			current += ServerResponseReadString(Response[current], szDescription, desclen);
			current += ServerResponseReadWord(Response[current], iTemp);
			current += ServerResponseReadByte(Response[current], iPlayers);
			current += ServerResponseReadByte(Response[current], iMaxPlayers);
			
		}
		case 0x6D:
		{
			current += ServerResponseReadString(Response[current], szName, namelen); //IP
			current += ServerResponseReadString(Response[current], szName, namelen);
			current += ServerResponseReadString(Response[current], szMap, maplen);
			current += ServerResponseReadString(Response[current], szDirectory, dirlen);
			current += ServerResponseReadString(Response[current], szDescription, desclen);
			current += ServerResponseReadByte(Response[current], iPlayers);
			current += ServerResponseReadByte(Response[current], iMaxPlayers);
		}
	}
}

stock ServerResponseParseChallenge(const Response[])
{
	if(Response[0] == 0x41)
	{
		new res = 0;
		res |= (Response[1]&0xFF) << 24;
		res |= (Response[2]&0xFF) << 16;
		res |= (Response[3]&0xFF) << 8;
		res |= (Response[4]&0xFF) << 0;
		return res;
	}
	return 0xFFFFFFFF;
}

stock ServerResponseParseRules(const Response[], length, const RuleName[], RuleValue[]="", len=0)
{	
	new iTemp;
	new current = 0;
	current += ServerResponseReadByte(Response[current], iTemp);
	current += ServerResponseReadInt(Response[current], iTemp);

	new szKey[64], szValue[64];
	while(current < length)
	{
		current += ServerResponseReadString(Response[current], szKey, 63);
		current += ServerResponseReadString(Response[current], szValue, 63);
		
		if(equali(szKey, RuleName))
		{
			copy(RuleValue, len, szValue);
			return 1;
		}
	}
	
	return 0;
}

stock ServerResponseParsePlayerNum(const Response[])
{
	new iHeader;
	new current = 0;
	current += ServerResponseReadByte(Response[current], iHeader);
	
	if(iHeader == 0x44)
	{
		new iPlayers = 0;
		current += ServerResponseReadByte(Response[current], iPlayers);
		return iPlayers;
	}
	return 0;
}

stock ServerResponseParsePlayer(const Response[], num, &id=0, szNick[]="", len=0, &kills=0, &Float:uptime=0.0)
{
	new iHeader;
	new current = 0;
	current += ServerResponseReadByte(Response[current], iHeader);
	
	if(iHeader == 0x44)
	{
		new iPlayers = 0;
		current += ServerResponseReadByte(Response[current], iPlayers);
		
		if(num >= iPlayers)
			return 0;
		
		for(new i=0;i<=num;i++)
		{
			current += ServerResponseReadByte(Response[current], id);
			current += ServerResponseReadString(Response[current], szNick, len);
			current += ServerResponseReadInt(Response[current], kills);
			current += ServerResponseReadInt(Response[current], _:uptime);
		}
		
		return 1;
	}
	return 0;
}


stock ServerResponseReadByte(const Response[], &res)
{
	res = Response[0] & 0xFF;
	return 1;
}

stock ServerResponseReadWord(const Response[], &res)
{
	res = Response[0] & 0xFF;
	res |= (Response[1] & 0xFF) << 8;
	return 2;
}

stock ServerResponseReadInt(const Response[], &res)
{
	res = Response[0] & 0xFF;
	res |= (Response[1] & 0xFF) << 8;
	res |= (Response[2] & 0xFF) << 16;
	res |= (Response[3] & 0xFF) << 24;
	return 4;
}

stock ServerResponseReadString(const Response[], szString[], len)
{
	return copy(szString, len, Response)+1;
}




/**
 * Inner functions
 */
stock __ServerQueryAdd(const szServer[], _A2A_TYPE, const szCallback[], szData[])
{
	if(!__gszServers)
	{
		__gszServers = ArrayCreate(32);
		__giA2ACodes = ArrayCreate();
		__giCallbacks = ArrayCreate();

		// TODO: recode this shit
		__giData = ArrayCreate(64);
	}
	
	ArrayPushString(__gszServers, szServer);
	ArrayPushCell(__giA2ACodes, _A2A_TYPE);
	ArrayPushCell(__giCallbacks, get_func_id(szCallback));
	ArrayPushArray(__giData,szData);	

	if(!task_exists(TASKID_FETCHING))
	{
		__ServerQuerying();
	}
}



stock __ServerQuerying()
{
	if(!__gszServers)
		return;
		
	if(ArraySize(__gszServers) == 0)
		return;
		
	new szServer[64];
	new iA2A;
	
	ArrayGetString(__gszServers, 0, szServer,63);
	iA2A = ArrayGetCell(__giA2ACodes, 0);
	
	__ServerQueryExec(szServer, iA2A);
}
stock __BuildChallengeString(challenge, szString[], len)
{
	formatex(szString, len, "%c%c%c%c", 
		(challenge&0xFF000000) >> 24,
		(challenge&0x00FF0000) >> 16,
		(challenge&0x0000FF00) >> 8,
		(challenge&0x000000FF) >> 0
	);
}

new Float:__gfStart;
stock __giLastSocket;

stock __ServerQueryExec(const szServer[],  _A2A_TYPE)
{
	__gfStart = get_gametime();
	
	new szIP[32], szPort[11];
	strtok(szServer, szIP, 31, szPort, 10, ':', 1);
	
	new iPort = str_to_num(szPort);
	if(!iPort)
		iPort = 27015;
		
	new socket,error;
	socket = socket_open(szIP, iPort, SOCKET_UDP, error);
	
	if(socket <= 0 || error)
	{
		__ResponseCallback({0}, 0, false);
		__ServerQueryRemove();
		return 0;
	}
	
	__giLastSocket = socket;
	
	switch(_A2A_TYPE)
	{
		case A2A_PING:
		{
			socket_send2(socket, "^xFF^xFF^xFF^xFFping", 9);
			
			new params[1];
			params[0] = 50;
			set_task(TASKTIME, "__ResponseFetchingTask", TASKID_FETCHING, params, 1);
			
		}
			
		
		case A2A_SERVERQUERY_GETCHALLENGE:
		{
			socket_send2(socket, "^xFF^xFF^xFF^xFF^x56^xFF^xFF^xFF^xFF", 9);
			
			new params[1];
			params[0] = 50;
			set_task(TASKTIME, "__ResponseFetchingTask", TASKID_FETCHING, params, 1);
		}
		
		case A2A_INFO:
		{
			socket_send2(socket, "^xFF^xFF^xFF^xFFTSource Engine Query^x00", 25);
			
			new params[1];
			params[0] = 50;
			set_task(TASKTIME, "__ResponseFetchingTask", TASKID_FETCHING, params, 1);
		}
		
		case A2A_RULES:
		{
			new challenge_value = ServerGetChallenge(szServer);
			
			new data[10] = "^xFF^xFF^xFF^xFF^x56";
			__BuildChallengeString(challenge_value, data[5], 4);
			socket_send2(socket, data, 9);
			
			new params[1];
			params[0] = 50;
			set_task(TASKTIME, "__ResponseFetchingTask", TASKID_FETCHING, params, 1);
		}
		
		case A2A_PLAYER:
		{
			new challenge_value = ServerGetChallenge(szServer);
			
			new data[10] = "^xFF^xFF^xFF^xFF^x55";
			__BuildChallengeString(challenge_value, data[5], 4);
			socket_send2(socket, data, 9);
			
			new params[1];
			params[0] = 50;
			set_task(TASKTIME, "__ResponseFetchingTask", TASKID_FETCHING, params, 1);
		}
		
	}
	
	return 1;
}


stock __ResponsePartially(const Response[], &Curr=0, &Max=0)
{	
	if(Response[0] == 0xFFFFFFFE)
	{
		new Packet = Response[8];
		
		Max = Packet&0xF;
		Curr = (Packet&0xF0) >> 4;
		return 1;
	}
	else
	{
		Max = Curr = 0;
	}
	return 0;
}


public __ResponseFetchingTask(const data[1])
{
	static Response[2048];
	
	if(socket_change(__giLastSocket, 100))
	{	
		new Max, Curr;
		new len = socket_recv(__giLastSocket, Response, charsmax(Response));
		
		if(__ResponsePartially(Response, Curr, Max) && ((Curr+1) < Max))
		{	
			//One of Part
			__ResponseCallback(Response, len, true);
			
			new params[1];
			params[0] = 50;
			set_task(TASKTIME, "__ResponseFetchingTask", TASKID_FETCHING, params, 1);
		}
		else
		{	//LastPart or the only part
			socket_close(__giLastSocket);
			__ResponseCallback(Response, len, true);
			__ServerQueryRemove();
		}		
	}
	else
	{		
		new iTriesLeft = data[0]-1;

		if(iTriesLeft <= 0)
		{
			socket_close(__giLastSocket);
			__ResponseCallback({0}, 0, false);
			__ServerQueryRemove();
		}
		else
		{
			new params[1];
			params[0] = iTriesLeft;
			set_task(TASKTIME, "__ResponseFetchingTask", TASKID_FETCHING, params, 1);
		}
	}
}

stock __ServerQueryRemove()
{
	ArrayDeleteItem(__gszServers, 0);
	ArrayDeleteItem(__giA2ACodes, 0);
	ArrayDeleteItem(__giCallbacks, 0);
	ArrayDeleteItem(__giData, 0);
	
	//Back to querying
	__ServerQuerying();
}

stock __ResponseCallback(const Response[], len, bool:success)
{	
	new Float:fStop = get_gametime();
	
	new latency = floatround(1000*(fStop - __gfStart));
	
	new szServer[64];
	new iA2A, iCallback;
	
	ArrayGetString(__gszServers, 0, szServer,63);
	iA2A = ArrayGetCell(__giA2ACodes, 0);
	iCallback = ArrayGetCell(__giCallbacks, 0);

	new data[64]
	ArrayGetArray(__giData,0,data)
	
	if(callfunc_begin_i(iCallback))
	{
		callfunc_push_str(szServer);
		callfunc_push_int(iA2A);
		callfunc_push_array(Response[4], max(1, len-4));
		callfunc_push_int(len);
		callfunc_push_int(success);
		callfunc_push_int(latency);
		callfunc_push_array(data,strlen(data));
		callfunc_end();
	}
}

stock ServerQueryCleanup()
{
	socket_close(__giLastSocket);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
