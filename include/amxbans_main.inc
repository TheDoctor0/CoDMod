#if defined _amxbans_main_included
	#endinput
#endif
#define _amxbans_main_included

/* called after the ban motd is shown to the player */
forward amxbans_ban_motdopen(index);

/* called if a flagged player is found */
forward amxbans_player_flagged(index,sec_left,reason[]);

/* called if a flagged player was unflagged */
forward amxbans_player_unflagged(index);