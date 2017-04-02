/*

	Fake Queries - v1.1
		By Shooting King

*/

#if defined _sbutil_included
  #endinput
#endif
#define _sbutil_included

#if AMXX_VERSION_NUM >= 175
 #pragma reqlib fake_queries
 #if !defined AMXMODX_NOAUTOLOAD
  #pragma loadlib fake_queries
 #endif
#else
 #pragma library fake_queries
#endif

/* 
   Set Host Name on Sendto Quries
   MaxLen In SvBrowser - 63 + 1 (null)

   if an empty string ("") is passed, FL_SVNAME flag will be unset.  
*/
native fq_set_hostname( const szHostName[] );

/* 
   Set Map Name on Sendto Quries
   MaxLen In SvBrowser - 31 + 1 (null)

   if an empty string ("") is passed, FL_MAPNAME flag will be unset.
*/
native fq_set_mapname( const szMapName[] );

/* 
   Set Game Name on Sendto Quries
   MaxLen In SvBrowser - 63 + 1 (null)

   if an empty string ("") is passed, FL_GAMENAME flag will be unset.
*/
native fq_set_gamename( const szGameName[] );

/* 
   Set Players on Sendto Quries
   If iPlayers is less than 0 i.e a negative number
   Original playersnum will be set.
   if a Negative number is passed, FL_PLAYERS will be unset.

   returns 0 On Success and -1 on Failure ( Value is greater than 127 )
*/
native fq_set_players( const iPlayers );

/* 
   Set Hostname on Sendto Quries
   If iMaxPlayers is less than 0 i.e a negative number
   Original maxplayers will be set.
   if a Negative number is passed, FL_MAXPLAYERS will be unset.

   returns 0 On Success and -1 on Failure ( Value is greater than 127 )
*/
native fq_set_maxplayers( const iMaxPlayers );

/* 
   Set Hostname on Sendto Quries
   If iBotsNum is less than 0 i.e a negative number
   Original botsnum will be set.
   if a Negative number is passed, FL_BOTSNUM will be unset.

   returns 0 On Success and -1 on Failure ( Value is greater than 127 )
*/
native fq_set_botsnum( const iBotsNum );

enum FFlags(<<=1)
{
	FL_SVNAME = ( 1<<0 ),
	FL_MAPNAME,
	FL_GAMENAME,
	FL_PLAYERS,
	FL_MAXPLAYERS,
	FL_BOTSNUM
}

/* 
   Set Hostname on Sendto Quries
   UnSet respective variables. You can even pass the bitsum of the above flags
   eg. fq_unset( FL_SVNAME | FL_BOTSNUM );

   returns 0 on Success and -1 on Failure
*/
native fq_unset( const FFlags:iFlags );

forward Server_SendTo( const szIP[], const szHeader[] );
forward Server_SendTo_Multi( const szIP[], const szHeader[], iChallengeID );