#if defined _VSH_included
 #endinput
#endif
#define _VSH_included

enum VSHSpecials_id
{
	VSHSpecial_None = -1,
	VSHSpecial_Hale,
	VSHSpecial_Vagineer,
	VSHSpecial_HHH,
	VSHSpecial_CBS,
	VSHSpecial_Bunny, //ohgodwhy
	VSHSpecial_Miku
}

stock const String:SpecialNames[][] = {
	"Hale",
	"The Vagineer",
	"The Horseless Headless Horsemann Jr.",
	"The Christian Brutal Sniper",
	"The Easter Bunny",
	"Hatsunemiku"
};


// VSHRoundState
#define ROUNDSTATE_INVALID						-1		/**< Invalid RoundState (VSH is disabled)*/
#define ROUNDSTATE_EVENT_ROUND_START			0		/**< set on a StartRound Timer and On event start round (preround freeze)*/
#define ROUNDSTATE_START_ROUND_TIMER			1		/**< Start of a timer for roundstart (during round) */
#define ROUNDSTATE_ROUND_END					2		/**< Found in SaxtonHale_Timers "StartHaleTimer" (after round end) */ //%50

// ========================================================================
// STOCK
// ========================================================================

stock bool:ValidPlayer(client,bool:check_alive=false,bool:alivecheckbyhealth=false) {
	if(client>0 && client<=MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{
		if(check_alive && !IsPlayerAlive(client))
		{
			return false;
		}
		if(alivecheckbyhealth&&GetClientHealth(client)<1) {
			return false;
		}
		return true;
	}
	return false;
}

// ========================================================================
// NATIVE
// ========================================================================

/**
 * If special is enabled
 *
 * @return		true if enabled - false if disabled
 */
native bool:VSH_IsSpecialEnabled(VSHSpecials_id:idSpecial);

/**
 * Returns the next Saxton Hale userid.
 *
 * @return		    	Userid of current Hale/boss (-1 if invalid/doesn't exist).
 */
native VSH_GetNextSaxtonHaleUserId();

/**
 * Will VSH be played on the current map?
 * Use this check in OnMapStart() or OnPluginStart(),
 * since VSH_IsSaxtonHaleModeEnabled() returns 0 before the 1st round.
 *
 * @return 1 if it's a VSH map, 0 otherwise.
 */
native bool:VSH_IsSaxtonHaleModeMap();

/**
 *
 * @return True if VSH is enabled, false otherwise.
 */
native bool:VSH_IsSaxtonHaleModeEnabled();

/**
 * Returns the userid of the current Hale.
 *
 * @return		    	Userid of current Hale/boss (-1 if invalid/doesn't exist).
 */
native VSH_GetSaxtonHaleUserId();

/**
 * Current team number for the boss.
 *
 * @return		    	Hale's team number (as in the TFTeam enum)
 */
native VSH_GetSaxtonHaleTeam();

/**
 * Current special
 *
 * @return		    	0 - Saxton Hale
 *						1 - Vagineer
 *						2 - HHH
 *						4 - CBS
 */
native VSH_GetSpecialRoundIndex();

/**
 * Hale's current health.
 *
 * @return		    	An integer representing Hale's health.
 */
native VSH_GetSaxtonHaleHealth();

/**
 * Hale's initial health.
 *
 * @return		    	An integer representing Hale's max/initial health.
 */
native VSH_GetSaxtonHaleHealthMax();

/**
 * Damage dealt by a client.
 *
 * @param client 		Client index.
 * @return		    	Damage dealt by the client for the current round.
 */
native VSH_GetClientDamage(client);

/**
 * The current round state for VSH.
 *
 * @return		     -1 - VSH is disabled
 *				0 - VSH preround freeze
 *				1 - VSH during round
 *				2 - VSH after round end
 */
native VSH_GetRoundState();

// ========================================================================
// FORWARD
// ========================================================================

/**
 * Before Hale is created.
 *
 * @param iSpecial 	integer index of the Special.
 * @return		    Change iSpecial and return Plugin_Changed to change it. Plugin_Continue to keep the current Special.
 */
forward Action:VSH_OnSpecialSelection(&VSHSpecials_id:iSpecial);

/**
 * When Hale is created.
 *
 * @param iHale 	integer index of Hale.
 * @return		    Returning does nothing.
 */
forward VSH_OnHaleCreated(iHale);

/**
 * When Hale attempts to superjump/teleport.
 *
 * @param bSuperDuper 	Boolean for whether the jump is a superjump.
 * @return		    Change bSuperDuper and return Plugin_Changed to change it. Plugin_Stop or Plugin_Handled to stop the jump.
 */
forward Action:VSH_OnDoJump(&bool:bSuperDuper);

/**
 * When Hale attemps to use rage.
 *
 * @param RageDist 	Distance that the boss's rage reaches.
 * @return		    Plugin_Stop or Plugin_Handled will prevent rage, change RageDist and return Plugin_Changed to change the distance.
 */
forward Action:VSH_OnDoRage(&Float:RageDist);

/**
 * When Hale uses the weighdown.
 *
 * @return		    Plugin_Stop/Plugin_Handled will prevent Weighdown
 */
forward Action:VSH_OnDoWeighdown();

/**
 * Called at the start of each round, when the music begins to play (even if the round has no music).
 * Also called each time the music is set to start up again in the loop.
 *
 * @param sound		Sound that is being played for music. Change it and return Plugin_Changed to change.
 *				Set to "" for silence that does not stop the forward firing every <time> seconds.
 * @param time		Duration of the sound (seconds). Must change this to the duration of whatever the music was changed to,
 * 				but +2 to 4 seconds so that your song doesn't overlap itself. Set to -1.0 to play the music only once.
 * @return			Plugin_Stop or Plugin_Handled to prevent the music from playing (stops the music/forward for the entire round),
 *				or change the values and return Plugin_Changed to change the music. REMEMBER TO CHANGE THE TIME AS WELL.
 */
forward Action:VSH_OnMusic(String:sound[], &Float:time);

public SharedPlugin:__pl_SaxtonHale =
{
	name = "saxtonhale",
	file = "saxtonhale.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_SaxtonHale_SetNTVOptional()
{
	MarkNativeAsOptional("VSH_IsSaxtonHaleModeMap");
	MarkNativeAsOptional("VSH_IsSaxtonHaleModeEnabled");
	MarkNativeAsOptional("VSH_GetSaxtonHaleUserId");
	MarkNativeAsOptional("VSH_GetSaxtonHaleTeam");
	MarkNativeAsOptional("VSH_GetSpecialRoundIndex");
	MarkNativeAsOptional("VSH_GetSaxtonHaleHealth");
	MarkNativeAsOptional("VSH_GetSaxtonHaleHealthMax");
	MarkNativeAsOptional("VSH_GetClientDamage");
	MarkNativeAsOptional("VSH_GetRoundState");
}
#endif
