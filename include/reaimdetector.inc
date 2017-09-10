#if defined _reaimdetector_included
	#endinput
#endif

#define _reaimdetector_included

#if AMXX_VERSION_NUM >= 175
	#pragma reqlib reaimdetector
	#if !defined AMXMODX_NOAUTOLOAD
		#pragma loadlib reaimdetector
	#endif
#else
	#pragma library reaimdetector
#endif

enum NotifyType
{
	WARNING,
	DETECT
};

enum PunishType
{
	AIMBOT,
	NOSPREAD
};

enum ResetType
{
	KILLED,
	SHOTS,
	TIME
};

enum ADSet
{
	AimSens,
	AimMultiWarns,
	AimNotifyWarns,
	AimMaxWarns,
	AimShotsReset,
	AimKillsReset,
	AimTimeReset,
	NoSpreadNotifyWarns,
	NoSpreadMaxWarns
};

enum ADClient
{
	AimCheck,
	AimWarn,
	AimShots,
	AimKills,
	AimTimeTask,
	NoSpreadCheck,
	NoSpreadWarn
};

/*
* Module initialization.
*
* @param Version
* @param Map
*
* @noreturn
*/
forward ad_init(const Version[], const Map[]);

/*
* Notifies about warnings the player, also detection aim.
*
* @param index			Client index
* @param pType			Punish type
* @param nType			Notify type
* @param Kills			The amount of kills a enemies
* @param Shots			The amount of clean shots
* @param Warn			The current amount of warnings for player
*
* @noreturn
*/
forward ad_notify(const index, const PunishType:pType, const NotifyType:nType, const Kills, const Shots, const Warn);

/*
* Reset the player warnings.
*
* @param index			Client index
* @param rType			Reset type
* @param Kills			The amount of kills a enemies
* @param Shots			The amount of clean shots
*
* @noreturn
*/
forward ad_aim_reset_warn(const index, const ResetType:rType, const Kills, const Shots);

/*
* Returns setting from config.
*
* @param Type		enum ADSet
*
*/
native ad_get_cfg(const ADSet:Type);

/*
* Sets setting config.
*
* @param Type		enum ADSet
* @param Value		Type int
*
* @noreturn
*
*/
native ad_set_cfg(const ADSet:Type, const Value);

/*
* Returns a data of the player.
*
* @param index		Client index
* @param Type		enum ADClient
*
*/
native ad_get_client(const index, const ADClient:Type);

/*
* Sets a data of the player.
*
* @param index		Client index
* @param Type		enum ADClient
* @param Value		Type int
*
* @noreturn
*
*/
native ad_set_client(const index, const ADClient:Type, const Value);

#define REAIMDETECTOR_VERSION			"0.1.8"
#define REAIMDETECTOR_VERSION_MAJOR	2
#define REAIMDETECTOR_VERSION_MINOR	1

public __reaimdetector_version_check(const majorVersion, const minorVersion)
{
	if (majorVersion != REAIMDETECTOR_VERSION_MAJOR)
	{
		new temp[512];
		formatex(temp, sizeof temp - 1, "[ReAimDetector]: Api major version mismatch; expected %d, real %d", REAIMDETECTOR_VERSION_MAJOR, majorVersion);
		set_fail_state(temp);
		return;
	}

	if (minorVersion < REAIMDETECTOR_VERSION_MINOR)
	{
		new temp[512];
		formatex(temp, sizeof temp - 1, "[ReAimDetector]: Api minor version mismatch; expected at least %d, real %d", REAIMDETECTOR_VERSION_MINOR, minorVersion);
		set_fail_state(temp);
		return;
	}
}