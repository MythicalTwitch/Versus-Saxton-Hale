// SaxtonHale_Configuration.sp

public Load_ConVars()
{
	cvarVersion = CreateConVar("hale_version", haleversiontitles[maxversion], "VS Saxton Hale Version", FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_DONTRECORD);
	cvarHaleSpeed = CreateConVar("hale_speed", "340.0", "Speed of Saxton Hale", FCVAR_PLUGIN);
	cvarPointType = CreateConVar("hale_point_type", "0", "Select condition to enable point (0 - alive players, 1 - time)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarPointDelay = CreateConVar("hale_point_delay", "6", "Addition (for each player) delay before point's activation.", FCVAR_PLUGIN);
	cvarAliveToEnable = CreateConVar("hale_point_alive", "5", "Enable control points when there are X people left alive.", FCVAR_PLUGIN);
	cvarRageDMG = CreateConVar("hale_rage_damage", "3500", "Damage required for Hale to gain rage", FCVAR_PLUGIN, true, 0.0);
	cvarRageDist  = CreateConVar("hale_rage_dist", "800.0", "Distance to stun in Hale's rage. Vagineer and CBS are /3 (/2 for sentries)", FCVAR_PLUGIN, true, 0.0);
	cvarAnnounce = CreateConVar("hale_announce", "120.0", "Info about mode will show every X seconds. Must be greater than 1.0 to show.", FCVAR_PLUGIN, true, 0.0);
	cvarSpecials = CreateConVar("hale_specials", "1", "Enable Special Rounds (Vagineer, HHH, CBS)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarEnabled = CreateConVar("hale_enabled", "1", "Do you really want set it to 0?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarCrits = CreateConVar("hale_crits", "0", "Can Hale get crits?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarDemoShieldCrits = CreateConVar("hale_shield_crits", "0", "Does Demoman's shield grant crits (1) or minicrits (0)?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarDisplayHaleHP = CreateConVar("hale_hp_display", "1", "Display Hale Health at all times.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarRageSentry = CreateConVar("hale_ragesentrydamagemode", "1", "If 0, to repair a sentry that has been damaged by rage, the Engineer must pick it up and put it back down.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarFirstRound = CreateConVar("hale_first_round", "0", "Disable(0) or Enable(1) VSH in 1st round.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	//cvarCircuitStun = CreateConVar("hale_circuit_stun", "0", "0 to disable Short Circuit stun, >0 to make it stun Hale for x seconds", FCVAR_PLUGIN, true, 0.0);
	cvarForceSpecToHale = CreateConVar("hale_spec_force_boss", "0", "1- if a spectator is up next, will force them to Hale + spectators will gain queue points, else spectators are ignored by plugin", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarEnableEurekaEffect = CreateConVar("hale_enable_eureka", "0", "1- allow Eureka Effect, else disallow", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarForceHaleTeam = CreateConVar("hale_force_team", "0", "0- Use plugin logic, 1- random team, 2- red, 3- blue", FCVAR_PLUGIN, true, 0.0, true, 3.0);

	cvarEndRoundOnReload = CreateConVar("hale_endround_on_reload", "1", "0- disabled 1- enabled", FCVAR_PLUGIN, true, 0.0, true, 1.0);
}

public Load_ConVarChange()
{
	HookConVarChange(cvarEnabled, CvarChange);
	HookConVarChange(cvarHaleSpeed, CvarChange);
	HookConVarChange(cvarRageDMG, CvarChange);
	HookConVarChange(cvarRageDist, CvarChange);
	HookConVarChange(cvarAnnounce, CvarChange);
	HookConVarChange(cvarSpecials, CvarChange);
	HookConVarChange(cvarPointType, CvarChange);
	HookConVarChange(cvarPointDelay, CvarChange);
	HookConVarChange(cvarAliveToEnable, CvarChange);
	HookConVarChange(cvarCrits, CvarChange);
	HookConVarChange(cvarDemoShieldCrits, CvarChange);
	HookConVarChange(cvarDisplayHaleHP, CvarChange);
	HookConVarChange(cvarRageSentry, CvarChange);
	//HookConVarChange(cvarCircuitStun, CvarChange);
}

public OnConfigsExecuted()
{
	decl String:oldversion[64];
	GetConVarString(cvarVersion, oldversion, sizeof(oldversion));
	if (strcmp(oldversion, haleversiontitles[maxversion], false) != 0) LogError("[VS Saxton Hale] Warning: your config may be outdated. Back up your tf/cfg/sourcemod/SaxtonHale.cfg file and delete it, and this plugin will generate a new one that you can then modify to your original values.");
	SetConVarString(FindConVar("hale_version"), haleversiontitles[maxversion]);
	HaleSpeed = GetConVarFloat(cvarHaleSpeed);
	RageDMG = GetConVarInt(cvarRageDMG);
	RageDist = GetConVarFloat(cvarRageDist);
	Announce = GetConVarFloat(cvarAnnounce);
	bSpecials = GetConVarBool(cvarSpecials);
	PointType = GetConVarInt(cvarPointType);
	PointDelay = GetConVarInt(cvarPointDelay);
	if (PointDelay < 0) PointDelay *= -1;
	AliveToEnable = GetConVarInt(cvarAliveToEnable);
	haleCrits = GetConVarBool(cvarCrits);
	bDemoShieldCrits = GetConVarBool(cvarDemoShieldCrits);
	bAlwaysShowHealth = GetConVarBool(cvarDisplayHaleHP);
	newRageSentry = GetConVarBool(cvarRageSentry);
	//circuitStun = GetConVarFloat(cvarCircuitStun);
	if (IsSaxtonHaleMap() && GetConVarBool(cvarEnabled))
	{
		tf_arena_use_queue = GetConVarInt(FindConVar("tf_arena_use_queue"));
		mp_teams_unbalance_limit = GetConVarInt(FindConVar("mp_teams_unbalance_limit"));
		tf_arena_first_blood = GetConVarInt(FindConVar("tf_arena_first_blood"));
		mp_forcecamera = GetConVarInt(FindConVar("mp_forcecamera"));
		tf_scout_hype_pep_max = GetConVarFloat(FindConVar("tf_scout_hype_pep_max"));
		SetConVarInt(FindConVar("tf_arena_use_queue"), 0);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), GetConVarBool(cvarFirstRound)?0:1);
		SetConVarInt(FindConVar("tf_arena_first_blood"), 0);
		SetConVarInt(FindConVar("mp_forcecamera"), 0);
		SetConVarFloat(FindConVar("tf_scout_hype_pep_max"), 100.0);
		SetConVarInt(FindConVar("tf_damage_disablespread"), 1);
#if defined _steamtools_included
		if (steamtools)
		{
			decl String:gameDesc[64];
			Format(gameDesc, sizeof(gameDesc), "VS Saxton Hale (%s)", haleversiontitles[maxversion]);
			Steam_SetGameDescription(gameDesc);
		}
#endif

		Enabled = true;
		Enabled2 = true;
		if (Announce > 1.0)
		{
			CreateTimer(Announce, Timer_Announce, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		Enabled2 = false;
		Enabled = false;
	}
}

public CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (convar == cvarHaleSpeed)
		HaleSpeed = GetConVarFloat(convar);
	else if (convar == cvarPointDelay)
	{
		PointDelay = GetConVarInt(convar);
		if (PointDelay < 0) PointDelay *= -1;
	}
	else if (convar == cvarRageDMG)
		RageDMG = GetConVarInt(convar);
	else if (convar == cvarRageDist)
		RageDist = GetConVarFloat(convar);
	else if (convar == cvarAnnounce)
		Announce = GetConVarFloat(convar);
	else if (convar == cvarSpecials)
		bSpecials = GetConVarBool(convar);
	else if (convar == cvarPointType)
		PointType = GetConVarInt(convar);
	else if (convar == cvarAliveToEnable)
		AliveToEnable = GetConVarInt(convar);
	else if (convar == cvarCrits)
		haleCrits = GetConVarBool(convar);
	else if (convar == cvarDemoShieldCrits)
		bDemoShieldCrits = GetConVarBool(cvarDemoShieldCrits);
	else if (convar == cvarDisplayHaleHP)
		bAlwaysShowHealth = GetConVarBool(cvarDisplayHaleHP);
	else if (convar == cvarRageSentry)
		newRageSentry = GetConVarBool(convar);
	//else if (convar == cvarCircuitStun)
	//  circuitStun = GetConVarFloat(convar);
	else if (convar == cvarEnabled)
	{
		if (GetConVarBool(convar) && IsSaxtonHaleMap())
		{
			Enabled2 = true;
#if defined _steamtools_included
			if (steamtools)
			{
				decl String:gameDesc[64];
				Format(gameDesc, sizeof(gameDesc), "VS Saxton Hale (%s)", haleversiontitles[maxversion]);
				Steam_SetGameDescription(gameDesc);
			}
#endif
		}
	}
}
