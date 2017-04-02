#if defined _chatcolor_included
  #endinput
#endif
#define _chatcolor_included

/* Инклюд цветного чата*/
stock ChatColor(const id, const input[], any:...) 
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4") // Зелёный
	replace_all(msg, 190, "!y", "^1") // Стандартный
	replace_all(msg, 190, "!t", "^3") // Цвет команды
	
	if (id) players[0] = id; else get_players(players, count, "ch")
	{
		for (new i = 0; i < count; i++)
		{
			if (is_user_connected(players[i]))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}
