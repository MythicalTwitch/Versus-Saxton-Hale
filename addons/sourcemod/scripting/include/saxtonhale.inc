#if defined _VSH_included
 #endinput
#endif
#define _VSH_included

new ignoreClient;
new los_target;

enum VSHVar
{
	EventArg1, //generic war3event arguments
	EventArg2,
	EventArg3,
	EventArg4,

	TransClient,//who to translate

	SmEvent, ///usual game events from sm hooked events
}

/* BEGIN GLOBAL VARS */
//retrieves specified values from the main vsh plugin, see VSHVar enum, only those values are allowed
//this mostly used for accessing a variable without creating a special native just for it
//this returns any:, you should tag it if return value is not suppose to be normal integer. like Float:VSHGetVar( or Handle:VSHGetVar(
//most are temporary variables and this function should be called immidiately in the right functions
//Do not get/set vars arbitrarily unless you know what you are doing
native any:VSHGetVar(VSHVar:variabletoretrieve);
native any:VSHSetVar(VSHVar:variabletoretrieve,any:value);

enum VSH_PlayerProp
{
	bool:bPutInServer,
	iMaxHP,
	iAdditionalMaxHealth,
	bIsDucking,

	bool:SpawnedOnce, //if player has spawned once
	Float:sqlStartLoadXPTime,

	Float:LastChangeTeamTime,
	bool:bStatefulSpawn, //set true if spawn is a non repeated spawn. set to true on join and death, set false after spawn forward is finished.
}

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

enum VSHChat {
	VSHChatFalse=0,
	VSHChatTrue,
	VSHChatBlock,
}


// VSHRoundState
#define ROUNDSTATE_INVALID						-1		/**< Invalid RoundState (VSH is disabled)*/
#define ROUNDSTATE_EVENT_ROUND_START			0		/**< set on a StartRound Timer and On event start round (preround freeze)*/
#define ROUNDSTATE_START_ROUND_TIMER			1		/**< Start of a timer for roundstart (during round) */
#define ROUNDSTATE_ROUND_END					2		/**< Found in SaxtonHale_Timers "StartHaleTimer" (after round end) */ //%50

// ========================================================================
// STOCK
// ========================================================================

stock bool:VSH_IsUbered(client)
{
	new m_nPlayerCond = FindSendPropInfo("CTFPlayer","m_nPlayerCond") ;
	new cond = GetEntData(client, m_nPlayerCond);
	if(cond & 32)
	{
		return true;
	}
	return false;
}


stock Directory_AddFileToDownloadsTable(String:custom_path[])
{
	//decl String:path2[PLATFORM_MAX_PATH];

	new String:path[1024];
	new FileType:type;

	new Handle:dir = OpenDirectory(custom_path);
	if (dir == INVALID_HANDLE)
	{
		return;
	}
	new String:ThePath[1024];

	while (ReadDirEntry(dir, path, sizeof(path), type))
	{
		if (type == FileType_File)
		{
			Format(ThePath, sizeof(ThePath), "%s%s",custom_path,path);

			if(StrContains(path,".mdl") != -1)
			{
				//LogDownloads("PrecacheModel:");
				PrecacheModel(ThePath,true);
			}

			AddFileToDownloadsTable(ThePath);
			//PrintToServer("[STORE-SKINS] Downloads table: %s",ThePath);
			//LogDownloads(ThePath);
		}
	}

	CloseHandle(dir);
}

public bool:LOSFilter(entity,mask)
{
	return !(entity==ignoreClient || (ValidPlayer(entity,true)&&entity!=los_target));
}
stock LOS(client,target)
{
	los_target=target;
	if(ValidPlayer(client,true)&&ValidPlayer(target,true))
	{
		new Float:PlayerEyePos[3];
		new Float:OtherPlayerPos[3];
		GetClientEyePosition(client,PlayerEyePos); //GetClientEyePosition(
		GetClientEyePosition(target,OtherPlayerPos); //GetClientAbsPosition
		//ignoreClient=client;
		TR_TraceRayFilter(PlayerEyePos,OtherPlayerPos,MASK_ALL,RayType_EndPoint,LOSFilter);
		if(TR_DidHit())
		{
			new entity=TR_GetEntityIndex();
			if(entity==target)
			{
				return true;
			}
		}
	}
	return false;
}

/**
 * Prints a message in the chat area with [VSH] pre-appended.
 * Support color tags: {default}, {green}, {lightgreen}, {red}, {blue}, {olive}.
 *
 * @param client      Client index, pass 0 for message to all.
 * @param szMessage   Message (formatting rules).
 * @return            No return
 */
stock VSH_ChatMessage(client, const String:szMessage[], any:...)
{
	if (client == 0)
	{
		decl String:szBuffer[250];
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				SetGlobalTransTarget(i);
				VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
				Format(szBuffer, sizeof(szBuffer), "{olive}[VSH]{default} %s", szBuffer);
				CPrintToChat(i, szBuffer);
			}
		}
	}
	else
	{
		decl String:szBuffer[250];
		SetGlobalTransTarget(client);
		VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
		Format(szBuffer, sizeof(szBuffer), "{olive}[VSH]{default} %s", szBuffer);
		if(ValidPlayer(client))
		{
			CPrintToChat(client, szBuffer);
		}
	}
}

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

//insensitive
//say foo
//say /foo
//say \foo
//say !foo
//returns TRUE if found
stock VSHChat:CommandCheck(String:compare[],String:commandwanted[])
{
	new String:commandwanted2[70];
	new String:commandwanted3[70];
	new String:commandwanted4[70];
	Format(commandwanted2,sizeof(commandwanted2),"\\%s",commandwanted);
	Format(commandwanted3,sizeof(commandwanted3),"/%s",commandwanted);
	Format(commandwanted4,sizeof(commandwanted4),"!%s",commandwanted);
	if(strcmp(compare,commandwanted,false)==0
	||strcmp(compare,commandwanted2,false)==0
	||strcmp(compare,commandwanted3,false)==0)
	{
		return VSHChatBlock;
	}
	else if(strcmp(compare,commandwanted4,false)==0)
	{
		return VSHChatTrue;
	}

	return VSHChatFalse;
}

// ========================================================================
// NATIVE
// ========================================================================
functag RegisterHaleCallback HaleCallback:public(client);

/**
 * Get's a Registered Hale's name.
 *
 * @param HaleIndex			Index of Hale.
 * @param retstr			Hale's registered name
 * @param maxlen			sizeof(retstr)
 * @return					none
 */
native VSH_GetHaleName(HaleIndex,String:retstr[],maxlen);

/**
 * Register's a Hale Boss.
 *
 * @param name			Name of the Hale Boss.
 * @param func			Callback for menu items.
 * @param denyreason	if exists, will display disabled menu with reason if denied access.  Leave "" to disable this feature.
 * @return				true is created new menu item, false if changed menu item.
 */
native bool:VSH_RegisterHale(const String:name[], RegisterHaleCallback:callback);

/**
 * Unregister a Hale Boss.
 *
 * @param name			Name of the Hale Boss.
 * @return				true if item found and removed, false if item does not exist
 */
native VSH_UnregisterHale(String:name[]);



native VSH_SetPlayerProp(client,VSH_PlayerProp:property,any:value);
native any:VSH_GetPlayerProp(client,VSH_PlayerProp:property);

//=============================================================================
// Chance Modifier
//=============================================================================

//helper, directly uses last inflictor and damagetype
// Acts like a DPS limiter
native Float:VSH_ChanceModifier(attacker);

//=============================================================================
// Get Damage Details
//=============================================================================

//get the actual damage dealt from War3_DealDamage, because real damage is different after taking account to magic/physical armor
//u wana call this immediately after War3_DealDamage cuz this is a single global variable. when someone else calls War3_DealDamage it will be changed
native VSH_GetVSHDamageDealt();

//get the depth of the damage stack, usually 1 or more
native VSH_GetDamageStack();

/*
 * forces the damage to be multiplied by @num
 * shall only be done inside SDKHOOKS damage forward (when damage hasnt been dealt yet)
 * @noreturn
 */
native VSH_DamageModPercent(Float:num);

//return the game damagetype (burn, laser, etc) of the last damage (TakeDmg forward)
native VSH_GetDamageType();

native VSH_SetDamageType(DamageTypeToSet);

//get inflictor of the last damage (TakeDmg forward) (ie sentry gun  is a different object than the attacker itself)
native VSH_GetDamageInflictor();

//=============================================================================
// Is client Sentry Owner?
//=============================================================================

/**
 * Basically checks to see if this is a Owner's sentry.
 *
 * best use inside OnW3TakeDmgBullet or OnW3TakeDmgBullet or SDKHooks calls that have inflictors
 * where you can use this code:
 *  new inflictor = W3GetDamageInflictor();
 *  then pass the inflictor as the entity below:
 *
 * @param client: client you wish to check as the owner
 * @param UseInternalInflictor: true if you wish the native to grab the W3GetDamageInflictor for you.
 *         ^ only use if you are using inside a OnW3TakeDamage function type, else use your own
 *         (Default true)
 * @param ExternalInflictor: entity you wish to check that maybe a sentry / optional
 *        Make sure you put UseInternalInflictor as false.
 *
 * @param return: true if the client is the sentry owner and the entity is the owned sentry
 *
 */
native bool:VSH_IsOwnerSentry(client,bool:UseInternalInflictor=true,ExternalInflictor=0);

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
 * Returns the Registered ID of the Addon Plugin being used for the Hale Boss.
 *
 * @return		    	 (-1 if invalid/doesn't exist).
 */
native VSH_GetHaleID();

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
 * Allows you to capture only Say
 *
 * VSHSayCommandCheckPre && VSHSayCommandCheckPost
 *
 * StripQuotes and TrimString is used on WholeString[]
 * also GetCmdArgString is used for WholeString[]
 *
 * TrimString is only used on ChatString[]
 * GetCmdArg(1,arg1,sizeof(arg1)) is used on ChatString[]
 *
 * you can change the strings for VSHSayCommandCheckPre,
 * but you can not change the strings for VSHSayCommandCheckPost.
 *
*/
forward Action:VSHSayCommandCheckPre(client,String:WholeString[],String:ChatString[]);
forward Action:VSHSayCommandCheckPost(client,String:WholeString[],String:ChatString[]);

/**
 * Allows you to capture only Team Say
 *
 * VSHSayTeamCommandCheckPre && VSHSayTeamCommandCheckPost
 *
 * StripQuotes and TrimString is used on WholeString[]
 * also GetCmdArgString is used for WholeString[]
 *
 * TrimString is only used on ChatString[]
 * GetCmdArg(1,arg1,sizeof(arg1)) is used on ChatString[]
 *
 * you can change the strings for VSHSayTeamCommandCheckPre,
 * but you can not change the strings for VSHSayTeamCommandCheckPost.
 *
*/
forward Action:VSHSayTeamCommandCheckPre(client,String:WholeString[],String:ChatString[]);
forward Action:VSHSayTeamCommandCheckPost(client,String:WholeString[],String:ChatString[]);

/**
 * Allows you to capture both Team Say and Say commands
 *
 * VSHSayAllCommandCheckPre && VSHSayAllCommandCheckPost
 *
 * This is called last.
 *
 * Both VSHSayCommandCheck* and VSHSayTeamCommandCheck* get called first,
 * Then VSHSayAllCommandCheck* is called last.
 *
 * StripQuotes and TrimString is used on WholeString[]
 * also GetCmdArgString is used for WholeString[]
 *
 * TrimString is only used on ChatString[]
 * GetCmdArg(1,arg1,sizeof(arg1)) is used on ChatString[]
 *
 *
 * you can change the strings for VSHSayAllCommandCheckPre,
 * but you can not change the strings for VSHSayAllCommandCheckPost.
 *
*/
forward Action:VSHSayAllCommandCheckPre(client,String:WholeString[],String:ChatString[]);
forward Action:VSHSayAllCommandCheckPost(client,String:WholeString[],String:ChatString[]);

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

//when player spawns
forward VSH_OnEventSpawn(client);

// when player dies
// does not include deadringer death!
forward VSH_OnEventDeath(victim, attacker, distance, attacker_hpleft);

//=============================================================================
// Fowards - DAMAGE
//=============================================================================
/**
 * Called when a an entity takes damage, requires SDK Hooks until SM natively supports this.
 * @param victim: Victim entity.
 * @param attacker: Attacker entity.
 * @param damage: How much damage is done.
 * @noreturn
 *
 * order of execution is
 * damageallpre
 * bulletpre (if bullet)
 * damageall
 * bullet  (if bullet)
 */
//FF triggers this function!!! even though it didnt damage any teammate
//THIS is a theoretical damage given by the engine, if u want real damage dealt use the hurt-event
//use natives to retrieve inflictor and game damagetype
//becareful when using this, u should only use this to reduce incoming damage. if you want to return damge, only use on bullet (first trigger damage)(below) or check IsBullet
//you may set damage mod percent HERE
//you may NOT DAMAGE IN HERE
forward OnVSH_TakeDmgAllPre(victim,attacker,&Float:damage,damagecustom);

//you may NOT set damage mod percent HERE
//you may DAMAGE in here, however damage will be engine theoretical damage, not actual damage dealt
forward OnVSH_TakeDmgAll(victim,attacker,Float:damage);

//very generic damage event
//derrived from the game engine's posthurt event
//FRIENDLY FIRE IS NOT FILTERED
forward OnVSHEventPostHurt(victim,attacker,dmgamount,const String:weapon[32]);

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

	MarkNativeAsOptional("VSH_ChanceModifier");
	MarkNativeAsOptional("VSH_GetVSHDamageDealt");
	MarkNativeAsOptional("VSH_GetDamageStack");
	MarkNativeAsOptional("VSH_DamageModPercent");
	MarkNativeAsOptional("VSH_GetDamageType");
	MarkNativeAsOptional("VSH_SetDamageType");
	MarkNativeAsOptional("VSH_GetDamageInflictor");
	MarkNativeAsOptional("VSH_IsOwnerSentry");
}
#endif
