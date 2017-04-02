#if defined _colorchat_included
	#endinput
#endif
#define _colorchat_included

/* ColorChat Support */
#define NORMAL	DontChange
#define GREEN	DontChange
#define RED		Red
#define BLUE	Blue
#define GREY	Grey
#define ColorChat client_print_color

#define MAX_TRANSLATION_LENGTH 2048

enum {
	DontChange = 0,
	Grey = -1,
	Red = -2,
	Blue = -3
};

#define print_team_default  DontChange
#define print_team_grey     Grey
#define print_team_red      Red
#define print_team_blue     Blue

stock client_print_color(id, sender, const fmt[], any:...)
{
	// check if id is different from 0
	if (id && !is_user_connected(id))
	{
		return 0;
	}

	if (sender < Blue || sender > 32)
	{
		sender = DontChange;
	}
	else if (sender < DontChange)
	{
		sender = -sender + 32; // align indexes to the TeamInfo ones
	}

	static const szTeamName[][] =
	{
		"",
		"TERRORIST",
		"CT"
	};

	new szMessage[191];

	new iParams = numargs();

	// Specific player code
	if (id)
	{
		if (iParams == 3)
		{
			copy(szMessage, charsmax(szMessage), fmt); // copy so message length doesn't exceed critical 192 value
		}
		else
		{
			vformat(szMessage, charsmax(szMessage), fmt, 4);
		}

		if (sender > (32 - Grey))
		{
			if (sender > (32 - Blue))
			{
				sender = id;
			}
			else
			{
				_CC_TeamInfo(id, sender, szTeamName[sender - (32 - Grey)]);
			}
		}
		_CC_SayText(id, sender, szMessage);
	}

	// Send message to all players
	else
	{
		// Figure out if at least 1 player is connected
		// so we don't execute useless useless code if not
		new iPlayers[32], iNum;
		get_players(iPlayers, iNum, "ch");
		if (!iNum)
		{
			return 0;
		}

		new iMlNumber, i, j;
		new Array:aStoreML = ArrayCreate();
		if (iParams >= 5) // ML can be used
		{
			for (j = 3; j < iParams; j++)
			{
				// retrieve original param value and check if it's LANG_PLAYER value
				if (getarg(j) == LANG_PLAYER)
				{
					i = 0;
					// as LANG_PLAYER == -1, check if next parm string is a registered language translation
					while ((szMessage[i] = getarg(j + 1, i++))) {}
					if (GetLangTransKey(szMessage) != TransKey_Bad)
					{
						// Store that arg as LANG_PLAYER so we can alter it later
						ArrayPushCell(aStoreML, j++);

						// Update ML array saire so we'll know 1st if ML is used,
						// 2nd how many args we have to alterate
						iMlNumber++;
					}
				}
			}
		}

		// If arraysize == 0, ML is not used
		// we can only send 1 MSG_ALL message if sender != 0
		if (!iMlNumber)
		{
			if (iParams == 3)
			{
				copy(szMessage, charsmax(szMessage), fmt);
			}
			else
			{
				vformat(szMessage, charsmax(szMessage), fmt, 4);
			}
			if (0 < sender < (32 - Blue)) // if 0 is passed, need to loop
			{
				if (sender > (32 - Grey))
				{
					_CC_TeamInfo(0, sender, szTeamName[sender - (32 - Grey)]);
				}
				_CC_SayText(0, sender, szMessage);
				return 1;
			}
		}

		if (sender > (32 - Blue))
		{
			sender = 0; // use receiver index
		}

		for (--iNum; iNum >= 0; iNum--)
		{
			id = iPlayers[iNum];

			if (iMlNumber)
			{
				for (j = 0; j < iMlNumber; j++)
				{
					// Set all LANG_PLAYER args to player index ( = id )
					// so we can format the text for that specific player
					setarg(ArrayGetCell(aStoreML, j), _, id);
				}

				// format string for specific player
				vformat(szMessage, charsmax(szMessage), fmt, 4);
			}

			if (sender > (32 - Grey))
			{
				_CC_TeamInfo(id, sender, szTeamName[sender - (32 - Grey)]);
			}
			_CC_SayText(id, sender, szMessage);
		}

		ArrayDestroy(aStoreML);
	}
	return 1;
}

stock _CC_TeamInfo(iReceiver, iSender, szTeam[])
{
	static iTeamInfo = 0;
	if (!iTeamInfo)
	{
		iTeamInfo = get_user_msgid("TeamInfo");
	}
	message_begin(iReceiver ? MSG_ONE : MSG_ALL, iTeamInfo, _, iReceiver);
	write_byte(iSender);
	write_string(szTeam);
	message_end();
}

stock _CC_SayText(iReceiver, iSender, szMessage[])
{
	static iSayText = 0;
	if (!iSayText)
	{
		iSayText = get_user_msgid("SayText");
	}

	// Prevent sending format and localization strings via chat
	for (new i = 0; i < 192; i++)
	{
		if (szMessage[i] == 0) break;
		if (szMessage[i] == '%' ||
			szMessage[i] == '#')
			szMessage[i] = ' ';
	}
	
	message_begin(iReceiver ? MSG_ONE : MSG_ALL, iSayText, _, iReceiver);
	write_byte(iSender ? iSender : iReceiver);
	if (szMessage[0] > 4)
	{
		write_byte(1);
		szMessage[192 - 2 - 1] = 0;	// Two write_byte + string terminator
		write_string(szMessage);
	}
	else
	{
		szMessage[192 - 1 - 1] = 0;	// One write_byte + string terminator
		write_string(szMessage);
	}
	message_end();
}

new _translation_szBuffer[MAX_TRANSLATION_LENGTH];

stock register_dictionary_colored(const filename[])
{
	if (!register_dictionary(filename))
	{
		return 0;
	}

	new szFileName[256];
	get_localinfo("amxx_datadir", szFileName, charsmax(szFileName));
	format(szFileName, charsmax(szFileName), "%s/lang/%s", szFileName, filename);
	new fp = fopen(szFileName, "rt");
	if (!fp)
	{
		log_amx("Failed to open %s", szFileName);
		return 0;
	}

	new szLang[3], szKey[64], TransKey:iKey;

	while (!feof(fp))
	{
		fgets(fp, _translation_szBuffer, charsmax(_translation_szBuffer));
		trim(_translation_szBuffer);

		if (_translation_szBuffer[0] == '[')
		{
			strtok(_translation_szBuffer[1], szLang, charsmax(szLang), _translation_szBuffer, 1, ']');
		}
		else if (_translation_szBuffer[0])
		{
			strbreak(_translation_szBuffer, szKey, charsmax(szKey), _translation_szBuffer, charsmax(_translation_szBuffer));
			iKey = GetLangTransKey(szKey);
			if (iKey != TransKey_Bad)
			{
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "!g", "^4");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "!t", "^3");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "!n", "^1");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "^^4", "^4");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "^^3", "^3");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "^^1", "^1");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "^^n", "^n");
				replace_all(_translation_szBuffer, charsmax(_translation_szBuffer), "^^t", "^t");
				AddTranslation(szLang, iKey, _translation_szBuffer[2]);
			}
		}
	}

	fclose(fp);
	return 1;
}

/* ML from AMXX 1.8.3 support */
#define register_dictionary register_dictionary_colored
