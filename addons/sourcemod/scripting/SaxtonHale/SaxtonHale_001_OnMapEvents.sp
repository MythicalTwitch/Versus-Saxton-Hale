// SaxtonHale_001_OnMapEvents.sp

public OnMapStart()
{
	HPTime = 0.0;
	MusicTimer = INVALID_HANDLE;
	hHHHTeleTimer = INVALID_HANDLE;
	TeamRoundCounter = 0;
	doorchecktimer = INVALID_HANDLE;
	Hale = -1;
	for (new i = 1; i <= MaxClients; i++)
	{
		VSHFlags[i] = 0;
	}
	if (IsSaxtonHaleMap(true))
	{
		//AddToDownload();
		IsDecemberHoliday(true);
		MapHasMusic(true);
		CheckToChangeMapDoors();
		CheckToTeleportToSpawn();
	}
	RoundCount = 0;
}
public OnMapEnd()
{
	if (Enabled2 || Enabled)
	{
		SetConVarInt(FindConVar("tf_arena_use_queue"), tf_arena_use_queue);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), mp_teams_unbalance_limit);
		SetConVarInt(FindConVar("tf_arena_first_blood"), tf_arena_first_blood);
		SetConVarInt(FindConVar("mp_forcecamera"), mp_forcecamera);
		SetConVarFloat(FindConVar("tf_scout_hype_pep_max"), tf_scout_hype_pep_max);
#if defined _steamtools_included
		if (steamtools)
		{
			Steam_SetGameDescription("Team Fortress");
		}
#endif
	}
	if (MusicTimer != INVALID_HANDLE)
	{
		KillTimer(MusicTimer);
		MusicTimer = INVALID_HANDLE;
	}
}

