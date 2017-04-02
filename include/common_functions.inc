/*	AMX Mod X script.

	Common functions include by AGHL.RU Dev Team.
	Contains fixed or extended functions.

	Version 1.2
*/

#if defined _common_functions_inñ
  #endinput
#endif
#define _common_functions_inñ

#include <fakemeta>

#define COMMON_FUNCTIONS_NUM	12

/**
 * Outputs long multi-line text in client or server console (it splits text into small chunks or lines).
 *
 * @note	Function doesn't has any limit on text size, but take into account that printing to the client console
 *			has limits on the network buffer.
 *
 * @param	id		The index of the player or 0 for the server.
 * @param	text	Multi-line text to output. No max limit for the server, but has some limits for printing to the client console.
 * @noreturn
 */
stock ConsolePrintLongText(id, text[])
{
	new maxLineLen = 79;
	new len = strlen(text);
	// Print lines while left text size is more than maxLineLen
	new pos, lineEnd, lineLen, c;
	while (pos + maxLineLen < len)
	{
		lineEnd = strfind(text[pos], "^n");
		lineLen = lineEnd >= 0 && lineEnd < maxLineLen ? lineEnd : maxLineLen;
		lineEnd = pos + lineLen;
		c = text[lineEnd];
		text[lineEnd] = 0;
		console_print(id, "%s", text[pos]);
		text[lineEnd] = c;
		pos = lineEnd;
		if (c == '^n') pos++;
		if (text[pos] == '^r') pos++;
	}
    // Print last text
	console_print(id, "%s", text[pos]);
}

/**
 * Prints text to the client or server console.
 *
 * @note	Function avoids text limits in console_print.
 * @note	Function has ability to format string, but also has limit on maximum size after formatting.
 *
 * @param	id		The index of the player or 0 for the server who changed.
 * @param	fmt		Format string.
 * @param	...		Parameters for format string.
 * @noreturn
 */
stock ConsolePrint(id, const fmt[], any:...)
{
	new text[1024];
	vformat(text, charsmax(text), fmt, 3);
	if (id == 0)
	{
		console_print(id, text);
		return;
	}
	new len = strlen(text);
	new pos = 0, c;
	while (pos < len)
	{
		pos += 127;
		c = text[pos];
		text[pos] = 0;
		console_print(id, text[pos - 127]);
		text[pos] = c;
	}
}

/**
 * Converts string of flags into an integer value.
 *
 * @note	Only chars from 'a' to 'z' are converted, others are skipped.
 *
 * @param	flags	String with flags to parse.
 * @return			Integer value represeting given flags string.
 */
stock ReadFlags(const flags[])
{
	new result, i = 0;
	while (flags[i] != 0)
	{
		if (flags[i] >= 'a' && flags[i] <= 'z')
			result |= 1 << (flags[i] - 'a');
		i++;	
	}
	return result;
}

/**
 * Converts string HEX representation to an integer value.
 *
 * @note	Function converts chars in ranges 0-9, a-f, A-F. Strings are parsed up to 8 chars length.
 *
 * @param	hexstr	HEX string to parse.
 * @return			Integer value represeting given HEX string or 0 if HEX string contains invalid characters.
 */
stock HexToNum(const hexstr[])
{
	new num = 0, c;
	new len = strlen(hexstr);
	if (len == 0) return 0;
	if (len > 8) len = 8;
	for (new i = 0; i < len; i++)
	{
		c = hexstr[i];
		if (!(c >= '0' && c <= '9' || c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z'))
			return 0;
		num = (num << 4) + (c >= 'a' ? c - 'a' + 10 : (c >= 'A' ? c - 'A' + 10 : c - '0'));
	}
	return num;
}

/**
 * Compares two integers as unsigned values.
 *
 * @param	first	First value to compare.
 * @param	second	Second value to compare.
 * @return			-1 if first is smaller than second
 *					 0 if first is equal to second
 *					 1 if first is greater than second.
 */
stock CompareUnsigned(first, second)
{
	if (first == second)
		return 0;
	new bool:highFirst, bool:highSecond;
	if (first < 0)
	{
		highFirst = true;
		first = first & (~(1 << 31));
	}
	if (second < 0)
	{
		highSecond = true;
		second = second & (~(1 << 31));
	}
	if (highFirst && !highSecond)
		return 1;
	if (!highFirst && highSecond)
		return -1;
	if (first > second)
		return 1;
	return -1;
}

/**
 * Plays given sound for all players excluding bots.
 *
 * @param	excludePlayer	one player to exclude.
 */
stock PlaySoundForAll(const snd[], excludePlayer)
{
	if (snd[0] == 0)
		return;
	new players[32], num;
	get_players(players, num);
	for (new i = 0; i < num; i++)
	{
		new id = players[i];
		if (!is_user_bot(id) && id != excludePlayer)
			client_cmd(id, "spk %s", snd);
	}
}

/**
 * Flags for LocatePlayers function.
 */
enum LocatePlayerFlags
{
	LP_NONE				= 0,		/* 0  - no special flags, all players are included in search */
	LP_OBEY_IMMUNITY	= (1<<0),	/* 1  - obey immunity */
	LP_ALLOW_SELF		= (1<<1),	/* 2  - allow yourself even if has immunity */
	LP_ONLY_ALIVE		= (1<<2),	/* 4  - must be alive */
	LP_NO_BOTS			= (1<<3),	/* 8  - can't be bot */
	LP_NO_HLTV			= (1<<4),	/* 16 - can't be HLTV */
}

/**
 * Finds player index based on Steam ID, partial player name, user IP or user ID.
 *
 * @note	Function outputs information in console if player is not located.
 *
 * @return			-1 if player is not found or multiple players found or found player doesn't match options given via flags
 *					index of located player on success.
 */
stock LocatePlayer(id, const identStr[], const pluginTag[], LocatePlayerFlags:flags = LP_OBEY_IMMUNITY)
{
	new player, player1[4], player2[4];
	// Find based on steam ID
	player1[0] = find_player("c", identStr);
	player2[0] = find_player("cj", identStr);

	// Find based on a partial non-case sensitive name
	player1[1] = find_player("bl", identStr);
	player2[1] = find_player("blj", identStr);

	// Find based on IP address
	player1[2] = find_player("d", identStr);
	player2[2] = find_player("dj", identStr);

	// Find based on user ID
	if (identStr[0]=='#' && identStr[1])
		player1[3] = player2[3] = find_player("k", str_to_num(identStr[1]));

	// Check if multiple players found
	for (new i = 0; i < 4; i++)
	{
		if (player1[i] != 0)
		{
			if ((player != 0 && player != player1[i]) || player1[i] != player2[i])
			{
				console_print(id, "[%s] %L.", pluginTag, id, "MORE_CL_MATCHT", identStr);
				return -1;
			}
			player = player1[i];
		}
	}

	// Check if player not found
	if (!player)
	{
		console_print(id, "[%s] %L.", pluginTag, id, "CL_NOT_FOUND");
		return -1;
	}

	// Check for immunity (ignore immunity if found player is himself and flag LP_ALLOW_SELF set)
	if ((flags & LP_OBEY_IMMUNITY) && (get_user_flags(player) & ADMIN_IMMUNITY) && 
		((flags & LP_ALLOW_SELF) != LP_ALLOW_SELF || id != player))
	{
		new name[32];
		get_user_name(player, name, charsmax(name));
		console_print(id, "[%s] %L.", pluginTag, id, "CLIENT_IMM", name);
		return -1;
	}

	// Check if player is alive
	if ((flags & LP_ONLY_ALIVE) && !is_user_alive(player))
	{
		new name[32];
		get_user_name(player, name, charsmax(name));
		console_print(id, "[%s] %L.", pluginTag, id, "CANT_PERF_DEAD", name);
		return -1;
	}

	// Check for a bot
	if ((flags & LP_NO_BOTS) && is_user_bot(player))
	{
		new name[32];
		get_user_name(player, name, charsmax(name));
		console_print(id, "[%s] %L.", pluginTag, id, "CANT_PERF_BOT", name);
		return -1;
	}

	// Check for a HLTV
	if ((flags & LP_NO_HLTV) && (pev(player, pev_flags) & FL_PROXY) == FL_PROXY)
	{
		new name[32];
		get_user_name(player, name, charsmax(name));
		console_print(id, "[%s] That action can't be performed on HLTV ^"%s^".", pluginTag, name);
		return -1;
	}

	return player;
}
