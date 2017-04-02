/**
 * Counter-Strike Team Changer
 * by Hattrick (Claudiu HKS)
 */

#if defined _cs_team_changer_included
  #endinput
#endif

#define _cs_team_changer_included

#if AMXX_VERSION_NUM >= 175
  #pragma reqlib cs_team_changer

  #if !defined AMXMODX_NOAUTOLOAD
    #pragma loadlib cs_team_changer
  #endif
#else
  #pragma library cs_team_changer
#endif

/** There are the teams you may use.
 */
enum CSTeam
{
  CSTEAM_UNASSIGNED = 0,
  CSTEAM_TERRORIST = 1,
  CSTEAM_CT = 2,
  CSTEAM_SPECTATOR = 3
};

/** You may do 64 transfers once a second using this extension! Server will not crash!
 * CStrike extension using cs_set_user_team native will crash server when approximately 24 transfers are reached!
 */

/** Transfers a player from a team to other one. The player's model will not be touched. The server will not be forged.
 * This native will automatically send a TeamInfo message. Will also change the team offset and the team index declared by AMX Mod X extension.
 */
native cs_set_team(Client, CSTeam:Team);

/** Changes the player's team index declared by AMX Mod X extension. The team offset and the scores' table will not be touched.
 * There will not be a TeamInfo message.
 */
native cs_set_team_id(Client, CSTeam:Team);

/** Changes the player's team offset. Scores' table will not be touched.
 */
native cs_set_team_offset(Client, CSTeam:Team);

/** Sends a fast TeamInfo message. The player will be transfered at the team you want but only in the scores' table.
*/
native cs_set_team_tablescore(Client, CSTeam:Team);
