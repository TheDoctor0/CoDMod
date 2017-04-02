#if defined _deathrun_stats_included
  #endinput
#endif
#define _deathrun_stats_included

#pragma library "DeathrunStats"


/**
 * Called when player reach the end
 *
 *	@param		id		player`s id
 *	@param		iTime		time in milis
 *	@param		newrecord	true when its a new record!
 */
forward fwPlayerFinished(id, iTime, bool:newrecord);

/**
 * Usuallly spawn event :) Start of running
 */
forward fwPlayerStarted(id);


/**
 *
 * Your own finish entity
 *
 */

/**
 * Called when someone want create finish entity. 
 * When id is player, fOrigin mean his/her position, but when id==0 fOrigin is saved position.
 *
 * IMPORTANT
 *	You have to return index of new entity
 *	
 *	@param		id		admin`s id or 0 on startmap creation
 *	@param		fOrigin		position
 *	@param		draw		should or shouldn`t draw entity (from cvar)
 *
 *	@return		new entity index
 */
forward fwFinishCreate(id, Float:fOrigin[3], draw);

/**
 * Use this native to finish player`s run. It will stop timer for player and display few statistics.
 *
 *	@param		id		player`s id
 */
native playerFinished(id);
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
