// SaxtonHale_001_OnPluginStart.sp

//=============================================================================
// OnPluginStart
//=============================================================================
public OnPluginStart()
{
	InitGamedata();
//  RegAdminCmd("hale_eggs", Command_Eggs, ADMFLAG_ROOT);   //WILL CRASH.
	//ACH_Enabled=LibraryExists("hale_achievements");
	LogMessage("===Versus Saxton Hale Initializing - v%s===", haleversiontitles[maxversion]);

	Load_ConVars();

	Load_Events();

	Load_ConVarChange();

	Load_RegConsoleCmd();

	Load_RegAdminCmd();

	Load_AddCommandListener();

	AutoExecConfig(true, "SaxtonHale");

	Load_Cookies();

	jumpHUD = CreateHudSynchronizer();
	rageHUD = CreateHudSynchronizer();
	healthHUD = CreateHudSynchronizer();

	LoadTranslations("saxtonhale.phrases");
#if defined EASTER_BUNNY_ON
	LoadTranslations("saxtonhale_bunny.phrases");
#endif
#if defined MIKU_ON
	LoadTranslations("saxtonhale_miku.phrases");
#endif
	LoadTranslations("common.phrases");
	for (new client = 0; client <= MaxClients; client++)
	{
		VSHFlags[client] = 0;
		Damage[client] = 0;
		AirDamage[client] = 0;
		uberTarget[client] = -1;
		if (IsValidClient(client, false))
		{
			SDKHook(client, SDKHook_OnTakeDamage, SDK_Forwarded_OnTakeDamage);
			SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);

#if defined _tf2attributes_included
			if (IsPlayerAlive(client))
			{
				TF2Attrib_RemoveByName(client, "damage force reduction");
			}
#endif
		}
	}

	// need to add into the addon files
	//AddNormalSoundHook(HookSound);
#if defined _steamtools_included
	steamtools = LibraryExists("SteamTools");
#endif
	AddMultiTargetFilter("@hale", HaleTargetFilter, "the current Boss", false);
	AddMultiTargetFilter("@!hale", HaleTargetFilter, "all non-Boss players", false);

	// Events for all games
	if(!HookEventEx("player_spawn",VSH_PlayerSpawnEvent,EventHookMode_Pre)) //,EventHookMode_Pre
	{
		LogError("[VSH] Could not hook the player_spawn event.");
	}
	if(!HookEventEx("player_death",VSH_PlayerDeathEvent,EventHookMode_Pre))
	{
		LogError("[VSH] Could not hook the player_death event.");
	}

	SaxtonHale_DamageSystem_OnPluginStart();
	SaxtonHale_PlayerClass_OnPluginStart();
	SaxtonHale_Register_Hale_OnPluginStart();
}

