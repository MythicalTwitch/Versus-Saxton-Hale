public Load_Events()
{
	HookEvent("teamplay_round_start", event_round_start);
	HookEvent("teamplay_round_win", event_round_end);
	HookEvent("player_changeclass", event_changeclass);
	HookEvent("player_spawn", event_player_spawn);
	HookEvent("player_death", event_player_death, EventHookMode_Pre);
	HookEvent("player_chargedeployed", event_uberdeployed);
	HookEvent("player_hurt", event_hurt, EventHookMode_Pre);
	HookEvent("object_destroyed", event_destroy, EventHookMode_Pre);
	HookEvent("object_deflected", event_deflect, EventHookMode_Pre);
	HookEvent( "rocket_jump", OnHookedEvent );
	HookEvent( "rocket_jump_landed", OnHookedEvent );
	HookEvent( "player_death", OnHookedEvent );

	HookUserMessage(GetUserMessageId("PlayerJarated"), event_jarate);
}

public OnHookedEvent(Handle:hEvent, const String:strEventName[], bool:bHidden)
{
	SetRJFlag(GetClientOfUserId(GetEventInt(hEvent, "userid")), StrEqual(strEventName, "rocket_jump", false));
}

// event_round_start  event_round_start  event_round_start  event_round_start  event_round_start  event_round_start
// event_round_start  event_round_start  event_round_start  event_round_start  event_round_start  event_round_start
// event_round_start  event_round_start  event_round_start  event_round_start  event_round_start  event_round_start

public Action:event_round_start(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(cvarEnabled))
	{
#if defined _steamtools_included
		if (Enabled2 && steamtools)
		{
			Steam_SetGameDescription("Team Fortress");
		}
#endif
		Enabled2 = false;
	}
	Enabled = Enabled2;
	if (CheckNextSpecial() && !Enabled) //QueuePanelH(Handle:0, MenuAction:0, 9001, 0) is HaleEnabled
		return Plugin_Continue;
	if (FileExists("bNextMapToHale"))
		DeleteFile("bNextMapToHale");
	if (MusicTimer != INVALID_HANDLE)
	{
		KillTimer(MusicTimer);
		MusicTimer = INVALID_HANDLE;
	}
	if (hHHHTeleTimer != INVALID_HANDLE)
	{
		KillTimer(hHHHTeleTimer);
		hHHHTeleTimer = INVALID_HANDLE;
	}
	KSpreeCount = 0;
	CheckArena();
	GetCurrentMap(currentmap, sizeof(currentmap));
	new bool:bBluHale;
	new convarsetting = GetConVarInt(cvarForceHaleTeam);
	switch (convarsetting)
	{
		case 3: bBluHale = true;
		case 2: bBluHale = false;
		case 1: bBluHale = GetRandomInt(0, 1) == 1;
		default:
		{
			if (strncmp(currentmap, "vsh_", 4, false) == 0) bBluHale = true;
			else if (TeamRoundCounter >= 3 && GetRandomInt(0, 1))
			{
				bBluHale = (HaleTeam != 3);
				TeamRoundCounter = 0;
			}
			else bBluHale = (HaleTeam == 3);
		}
	}
	if (bBluHale)
	{
		new score1 = GetTeamScore(OtherTeam);
		new score2 = GetTeamScore(HaleTeam);
		SetTeamScore(2, score1);
		SetTeamScore(3, score2);
		OtherTeam = 2;
		HaleTeam = 3;
		bBluHale = false;
	}
	else
	{
		new score1 = GetTeamScore(HaleTeam);
		new score2 = GetTeamScore(OtherTeam);
		SetTeamScore(2, score1);
		SetTeamScore(3, score2);
		HaleTeam = 2;
		OtherTeam = 3;
		bBluHale = true;
	}
	playing = 0;
	for (new ionplay = 1; ionplay <= MaxClients; ionplay++)
	{
		Damage[ionplay] = 0;
		AirDamage[ionplay] = 0;
		uberTarget[ionplay] = -1;
		if (IsValidClient(ionplay))
		{
#if defined _tf2attributes_included
			if (IsPlayerAlive(ionplay))
			{
				TF2Attrib_RemoveByName(ionplay, "damage force reduction");
			}
#endif
			StopHaleMusic(ionplay);
			if (GetClientTeam(ionplay) > _:TFTeam_Spectator) playing++;
		}
	}
	if (GetClientCount() <= 1 || playing < 2)
	{
		CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_needmoreplayers");
		Enabled = false;
		VSHRoundState = -1;
		SetControlPoint(true);
		return Plugin_Continue;
	}
	else if (RoundCount > 0)
	{
		Enabled = true;
	}
	else if (!GetConVarBool(cvarFirstRound))
	{
		CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_first_round");
		Enabled = false;
		VSHRoundState = -1;
		SetArenaCapEnableTime(60.0);
		SearchForItemPacks();
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 1);
		CreateTimer(71.0, Timer_EnableCap, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}

	SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);

	if (GetTeamPlayerCount(TFTeam_Blue) <= 0 || GetTeamPlayerCount(TFTeam_Red) <= 0)
	{
		if (IsValidClient(Hale))
		{
			if (GetClientTeam(Hale) != HaleTeam)
			{
				SetEntProp(Hale, Prop_Send, "m_lifeState", 2);
				ChangeClientTeam(Hale, HaleTeam);
				SetEntProp(Hale, Prop_Send, "m_lifeState", 0);
				TF2_RespawnPlayer(Hale);
			}
		}
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != Hale && GetClientTeam(i) != _:TFTeam_Spectator && GetClientTeam(i) != _:TFTeam_Unassigned)
			{
				if (GetClientTeam(i) != OtherTeam)
				{
					SetEntProp(i, Prop_Send, "m_lifeState", 2);
					ChangeClientTeam(i, OtherTeam);
					SetEntProp(i, Prop_Send, "m_lifeState", 0);
					TF2_RespawnPlayer(i);
					TF2_RegeneratePlayer(i);
				}
			}
		}
		return Plugin_Continue;
	}
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		if (!IsPlayerAlive(i)) continue;
		if (!(VSHFlags[i] & VSHFLAG_HASONGIVED)) TF2_RespawnPlayer(i);
	}
	new bool:see[MAXPLAYERS + 1];
	new tHale = FindNextHale(see);
	if (tHale == -1)
	{
		CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_needmoreplayers");
		Enabled = false;
		VSHRoundState = -1;
		SetControlPoint(true);
		return Plugin_Continue;
	}
	if (NextHale > 0)
	{
		Hale = NextHale;
		NextHale = -1;
	}
	else
	{
		Hale = tHale;
	}

	SDKHook(Hale, SDKHook_GetMaxHealth, OnGetMaxHealth);

	bTenSecStart[0] = true;
	bTenSecStart[1] = true;
	CreateTimer(29.1, tTenSecStart, 0);
	CreateTimer(60.0, tTenSecStart, 1);
	CreateTimer(9.1, StartHaleTimer);
	CreateTimer(3.5, StartResponceTimer);
	CreateTimer(9.6, MessageTimer, 9001);
	bNoTaunt = false;
	HaleRage = 0;
	Stabbed = 0.0;
	Marketed = 0.0;
	HHHClimbCount = 0;
	PointReady = false;
	new ent = -1;
	while ((ent = FindEntityByClassname2(ent, "func_regenerate")) != -1)
		AcceptEntityInput(ent, "Disable");
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "func_respawnroomvisualizer")) != -1)
		AcceptEntityInput(ent, "Disable");
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "obj_dispenser")) != -1)
	{
		SetVariantInt(OtherTeam);
		AcceptEntityInput(ent, "SetTeam");
		AcceptEntityInput(ent, "skin");
		SetEntProp(ent, Prop_Send, "m_nSkin", OtherTeam-2);
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "mapobj_cart_dispenser")) != -1)
	{
		SetVariantInt(OtherTeam);
		AcceptEntityInput(ent, "SetTeam");
		AcceptEntityInput(ent, "skin");
	}

	SearchForItemPacks();

	CreateTimer(0.3, MakeHale);

	healthcheckused = 0;
	VSHRoundState = 0;

	return Plugin_Continue;
}

// event_round_end  event_round_end  event_round_end  event_round_end  event_round_end  event_round_end
// event_round_end  event_round_end  event_round_end  event_round_end  event_round_end  event_round_end
// event_round_end  event_round_end  event_round_end  event_round_end  event_round_end  event_round_end

public Action:event_round_end(Handle:event, const String:name[], bool:dontBroadcast)
{
	new String:s[265];
	decl String:s2[265];
	new bool:see = false;
	GetNextMap(s, 64);
	if (!strncmp(s, "Hale ", 5, false))
	{
		see = true;
		strcopy(s2, sizeof(s2), s[5]);
	}
	else if (!strncmp(s, "(Hale) ", 7, false))
	{
		see = true;
		strcopy(s2, sizeof(s2), s[7]);
	}
	else if (!strncmp(s, "(Hale)", 6, false))
	{
		see = true;
		strcopy(s2, sizeof(s2), s[6]);
	}
	if (see)
	{
		new Handle:fileh = OpenFile("bNextMapToHale", "w");
		WriteFileString(fileh, s2, false);
		CloseHandle(fileh);
		SetNextMap(s2);
		CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_nextmap", s2);
	}
	RoundCount++;
	if (!Enabled)
	{
		return Plugin_Continue;
	}
	VSHRoundState = 2;
	TeamRoundCounter++;
	if (GetEventInt(event, "team") == HaleTeam)
	{
		switch (Special)
		{
			case VSHSpecial_Hale:
			{
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleWin, GetRandomInt(1, 2));
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
				EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
			}
			case VSHSpecial_Vagineer:
			{
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
				EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
			}
			case VSHSpecial_Bunny:
			{
				strcopy(s, PLATFORM_MAX_PATH, BunnyWin[GetRandomInt(0, sizeof(BunnyWin)-1)]);
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
				EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, _, NULL_VECTOR, false, 0.0);
			}
		}
	}
	for (new i = 1 ; i <= MaxClients; i++)
	{
		VSHFlags[i] &= ~VSHFLAG_HASONGIVED;
		if (!IsValidClient(i)) continue;
		StopHaleMusic(i);
	}
	if (MusicTimer != INVALID_HANDLE)
	{
		KillTimer(MusicTimer);
		MusicTimer = INVALID_HANDLE;
	}
	if (IsValidClient(Hale))
	{
		SetEntProp(Hale, Prop_Send, "m_bGlowEnabled", 0);
		GlowTimer = 0.0;
		if (IsPlayerAlive(Hale))
		{
			decl String:translation[32];
			switch (Special)
			{
				case VSHSpecial_Bunny:      strcopy(translation, sizeof(translation), "vsh_bunny_is_alive");
				case VSHSpecial_Vagineer:   strcopy(translation, sizeof(translation), "vsh_vagineer_is_alive");
				case VSHSpecial_HHH:        strcopy(translation, sizeof(translation), "vsh_hhh_is_alive");
				case VSHSpecial_CBS:        strcopy(translation, sizeof(translation), "vsh_cbs_is_alive");
				default:                    strcopy(translation, sizeof(translation), "vsh_hale_is_alive");
			}
			CPrintToChatAll("{olive}[VSH]{default} %t", translation, Hale, HaleHealth, HaleHealthMax);
			SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
			for (new i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && !(GetClientButtons(i) & IN_SCORE))
				{
					ShowHudText(i, -1, "%T", translation, i, Hale, HaleHealth, HaleHealthMax);
				}
			}
		}
		else
		{
			if (GetClientTeam(Hale) != HaleTeam)
			{
				SetEntProp(Hale, Prop_Send, "m_lifeState", 2);
				ChangeClientTeam(Hale, HaleTeam);
				SetEntProp(Hale, Prop_Send, "m_lifeState", 0);
				TF2_RespawnPlayer(Hale);
			}
		}
		new top[3];
		Damage[0] = 0;
		for (new i = 0; i <= MaxClients; i++)
		{
			if (Damage[i] >= Damage[top[0]])
			{
				top[2]=top[1];
				top[1]=top[0];
				top[0]=i;
			}
			else if (Damage[i] >= Damage[top[1]])
			{
				top[2]=top[1];
				top[1]=i;
			}
			else if (Damage[i] >= Damage[top[2]])
			{
				top[2]=i;
			}
		}
		if (Damage[top[0]] > 9000)
		{
			CreateTimer(1.0, Timer_NineThousand, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		decl String:s1[80];
		if (IsValidClient(top[0]) && (GetClientTeam(top[0]) >= 1))
			GetClientName(top[0], s, 80);
		else
		{
			Format(s, 80, "---");
			top[0]=0;
		}
		if (IsValidClient(top[1]) && (GetClientTeam(top[1]) >= 1))
			GetClientName(top[1], s1, 80);
		else
		{
			Format(s1, 80, "---");
			top[1]=0;
		}
		if (IsValidClient(top[2]) && (GetClientTeam(top[2]) >= 1))
			GetClientName(top[2], s2, 80);
		else
		{
			Format(s2, 80, "---");
			top[2]=0;
		}
		SetHudTextParams(-1.0, 0.3, 10.0, 255, 255, 255, 255);
		PrintCenterTextAll(""); //Should clear center text
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && !(GetClientButtons(i) & IN_SCORE))
			{
				SetGlobalTransTarget(i);
//              if (numHaleKills < 2 && false) ShowHudText(i, -1, "%t\n1)%i - %s\n2)%i - %s\n3)%i - %s\n\n%t %i\n%t %i", "vsh_top_3", Damage[top[0]], s, Damage[top[1]], s1, Damage[top[2]], s2, "vsh_damage_fx", Damage[i], "vsh_scores", RoundFloat(Damage[i] / 600.0));
//              else
				ShowHudText(i, -1, "%t\n1)%i - %s\n2)%i - %s\n3)%i - %s\n\n%t %i\n%t %i", "vsh_top_3", Damage[top[0]], s, Damage[top[1]], s1, Damage[top[2]], s2, "vsh_damage_fx", Damage[i], "vsh_scores", RoundFloat(Damage[i] / 600.0));
			}
		}
	}
	CreateTimer(3.0, Timer_CalcScores, _, TIMER_FLAG_NO_MAPCHANGE);     //CalcScores();
	return Plugin_Continue;
}

// event_changeclass  event_changeclass  event_changeclass  event_changeclass  event_changeclass  event_changeclass
// event_changeclass  event_changeclass  event_changeclass  event_changeclass  event_changeclass  event_changeclass
// event_changeclass  event_changeclass  event_changeclass  event_changeclass  event_changeclass  event_changeclass

public Action:event_changeclass(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!Enabled)
		return Plugin_Continue;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client == Hale)
	{
		switch(Special)
		{
			case VSHSpecial_Hale:
				if (TF2_GetPlayerClass(client) != TFClass_Soldier)
					TF2_SetPlayerClass(client, TFClass_Soldier, _, false);
			case VSHSpecial_Vagineer:
				if (TF2_GetPlayerClass(client) != TFClass_Engineer)
					TF2_SetPlayerClass(client, TFClass_Engineer, _, false);
			case VSHSpecial_HHH, VSHSpecial_Bunny:
				if (TF2_GetPlayerClass(client) != TFClass_DemoMan)
					TF2_SetPlayerClass(client, TFClass_DemoMan, _, false);
			case VSHSpecial_CBS:
				if (TF2_GetPlayerClass(client) != TFClass_Sniper)
					TF2_SetPlayerClass(client, TFClass_Sniper, _, false);
		}
		TF2_RemovePlayerDisguise(client);
	}
	return Plugin_Continue;
}

// event_player_spawn  event_player_spawn  event_player_spawn  event_player_spawn  event_player_spawn  event_player_spawn
// event_player_spawn  event_player_spawn  event_player_spawn  event_player_spawn  event_player_spawn  event_player_spawn
// event_player_spawn  event_player_spawn  event_player_spawn  event_player_spawn  event_player_spawn  event_player_spawn

public Action:event_player_spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(g_healthBar == -1)
	{
		g_healthBar = CreateEntityByName(HEALTHBAR_CLASS);
	}

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client, false)) return Plugin_Continue;
	if (!Enabled) return Plugin_Continue;
	SetVariantString("");
	AcceptEntityInput(client, "SetCustomModel");
	if (client == Hale && VSHRoundState < 2 && VSHRoundState != -1) CreateTimer(0.1, MakeHale);

	if (VSHRoundState != -1)
	{
		CreateTimer(0.2, MakeNoHale, GetClientUserId(client));
		if (!(VSHFlags[client] & VSHFLAG_HASONGIVED))
		{
			VSHFlags[client] |= VSHFLAG_HASONGIVED;
			RemovePlayerBack(client, { 57, 133, 231, 405, 444, 608, 642 }, 7);
			RemovePlayerTarge(client);
			TF2_RemoveAllWeapons2(client);
			TF2_RegeneratePlayer(client);
			CreateTimer(0.1, Timer_RegenPlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	if (!(VSHFlags[client] & VSHFLAG_HELPED))
	{
		HelpPanel(client);
		VSHFlags[client] |= VSHFLAG_HELPED;
	}
	VSHFlags[client] &= ~VSHFLAG_UBERREADY;
	VSHFlags[client] &= ~VSHFLAG_CLASSHELPED;
	return Plugin_Continue;
}

// event_player_death  event_player_death  event_player_death  event_player_death  event_player_death  event_player_death
// event_player_death  event_player_death  event_player_death  event_player_death  event_player_death  event_player_death
// event_player_death  event_player_death  event_player_death  event_player_death  event_player_death  event_player_death

public Action:event_player_death(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:s[PLATFORM_MAX_PATH];
	if (!Enabled)
		return Plugin_Continue;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client))
		return Plugin_Continue;
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new deathflags = GetEventInt(event, "death_flags");
	new customkill = GetEventInt(event, "customkill");
	if (attacker == Hale && Special == VSHSpecial_Bunny && VSHRoundState == 1)  SpawnManyAmmoPacks(client, EggModel, 1, 5, 120.0);
	if (attacker == Hale && VSHRoundState == 1 && (deathflags & TF_DEATHFLAG_DEADRINGER))
	{
		numHaleKills++;
		if (customkill != TF_CUSTOM_BOOTS_STOMP)
		{
			if (Special == VSHSpecial_Hale) SetEventString(event, "weapon", "fists");
		}
		return Plugin_Continue;
	}
	if (GetClientHealth(client) > 0)
		return Plugin_Continue;
	CreateTimer(0.1, CheckAlivePlayers);
	if (client != Hale && VSHRoundState == 1)
		CreateTimer(1.0, Timer_Damage, GetClientUserId(client));
	if (client == Hale && VSHRoundState == 1)
	{
		switch (Special)
		{
			case VSHSpecial_HHH:
			{
				Format(s, PLATFORM_MAX_PATH, "vo/halloween_boss/knight_death0%d.wav", GetRandomInt(1, 2));
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				EmitSoundToAll("ui/halloween_boss_defeated_fx.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//              CreateTimer(0.1, Timer_ChangeRagdoll, any:GetEventInt(event, "userid"));
			}
			case VSHSpecial_Hale:
			{
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleFail, GetRandomInt(1, 3));
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//              CreateTimer(0.1, Timer_ChangeRagdoll, any:GetEventInt(event, "userid"));
			}
			case VSHSpecial_Vagineer:
			{
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerFail, GetRandomInt(1, 2));
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//              CreateTimer(0.1, Timer_ChangeRagdoll, any:GetEventInt(event, "userid"));
			}
			case VSHSpecial_Bunny:
			{
				strcopy(s, PLATFORM_MAX_PATH, BunnyFail[GetRandomInt(0, sizeof(BunnyFail)-1)]);
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//              CreateTimer(0.1, Timer_ChangeRagdoll, any:GetEventInt(event, "userid"));
				SpawnManyAmmoPacks(client, EggModel, 1);
			}
		}
		if (HaleHealth < 0)
			HaleHealth = 0;
		ForceTeamWin(OtherTeam);
		return Plugin_Continue;
	}
	if (attacker == Hale && VSHRoundState == 1)
	{
		numHaleKills++;
		switch (Special)
		{
			case VSHSpecial_Hale:
			{
				if (customkill != TF_CUSTOM_BOOTS_STOMP) SetEventString(event, "weapon", "fists");
				if (!GetRandomInt(0, 2) && RedAlivePlayers != 1)
				{
					strcopy(s, PLATFORM_MAX_PATH, "");
					new TFClassType:playerclass = TF2_GetPlayerClass(client);
					switch (playerclass)
					{
						case TFClass_Scout:     strcopy(s, PLATFORM_MAX_PATH, HaleKillScout132);
						case TFClass_Pyro:      strcopy(s, PLATFORM_MAX_PATH, HaleKillPyro132);
						case TFClass_DemoMan:   strcopy(s, PLATFORM_MAX_PATH, HaleKillDemo132);
						case TFClass_Heavy:     strcopy(s, PLATFORM_MAX_PATH, HaleKillHeavy132);
						case TFClass_Medic:     strcopy(s, PLATFORM_MAX_PATH, HaleKillMedic);
						case TFClass_Sniper:
						{
							if (GetRandomInt(0, 1)) strcopy(s, PLATFORM_MAX_PATH, HaleKillSniper1);
							else strcopy(s, PLATFORM_MAX_PATH, HaleKillSniper2);
						}
						case TFClass_Spy:
						{
							new see = GetRandomInt(0, 2);
							if (!see) strcopy(s, PLATFORM_MAX_PATH, HaleKillSpy1);
							else if (see == 1) strcopy(s, PLATFORM_MAX_PATH, HaleKillSpy2);
							else strcopy(s, PLATFORM_MAX_PATH, HaleKillSpy132);
						}
						case TFClass_Engineer:
						{
							new see = GetRandomInt(0, 3);
							if (!see) strcopy(s, PLATFORM_MAX_PATH, HaleKillEngie1);
							else if (see == 1) strcopy(s, PLATFORM_MAX_PATH, HaleKillEngie2);
							else Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, GetRandomInt(1, 2));
						}
					}
					if (!StrEqual(s, ""))
					{
						EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
						EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
					}
				}
			}
			case VSHSpecial_Vagineer:
			{
				strcopy(s, PLATFORM_MAX_PATH, VagineerHit);
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
//              CreateTimer(0.1, Timer_DissolveRagdoll, any:GetEventInt(event, "userid"));
			}
			case VSHSpecial_HHH:
			{
				Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HHHAttack, GetRandomInt(1, 4));
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			}
			case VSHSpecial_Bunny:
			{
				strcopy(s, PLATFORM_MAX_PATH, BunnyKill[GetRandomInt(0, sizeof(BunnyKill)-1)]);
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			}
			case VSHSpecial_CBS:
			{
				if (!GetRandomInt(0, 3) && RedAlivePlayers != 1)
				{
					new TFClassType:playerclass = TF2_GetPlayerClass(client);
					switch (playerclass)
					{
						case TFClass_Spy:
						{
							strcopy(s, PLATFORM_MAX_PATH, "vo/sniper_dominationspy04.wav");
							EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
							EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
						}
					}
				}
				new weapon = GetEntPropEnt(Hale, Prop_Send, "m_hActiveWeapon");
				if (weapon == GetPlayerWeaponSlot(Hale, TFWeaponSlot_Melee))
				{
					TF2_RemoveWeaponSlot2(Hale, TFWeaponSlot_Melee);
					new clubindex, wepswitch = GetRandomInt(0, 3);
					switch (wepswitch)
					{
						case 0: clubindex = 171;
						case 1: clubindex = 3;
						case 2: clubindex = 232;
						case 3: clubindex = 401;
					}
					weapon = SpawnWeapon(Hale, "tf_weapon_club", clubindex, 100, 5, "68 ; 2.0 ; 2 ; 3.1 ; 259 ; 1.0");
					SetEntPropEnt(Hale, Prop_Send, "m_hActiveWeapon", weapon);
					SetEntProp(weapon, Prop_Send, "m_nModelIndexOverrides", GetEntProp(weapon, Prop_Send, "m_iWorldModelIndex"), _, 0);
				}
			}
		}
		if (GetGameTime() <= KSpreeTimer)
			KSpreeCount++;
		else
			KSpreeCount = 1;
		if (KSpreeCount == 3 && RedAlivePlayers != 1)
		{
			switch (Special)
			{
				case VSHSpecial_Hale:
				{
					new see = GetRandomInt(0, 7);
					if (!see || see == 1)
						strcopy(s, PLATFORM_MAX_PATH, HaleKSpree);
					else if (see < 5)
						Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKSpreeNew, GetRandomInt(1, 5));
					else
						Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillKSpree132, GetRandomInt(1, 2));
				}
				case VSHSpecial_Vagineer:
				{
					if (GetRandomInt(0, 4) == 1)
						strcopy(s, PLATFORM_MAX_PATH, VagineerKSpree);
					else if (GetRandomInt(0, 3) == 1)
						strcopy(s, PLATFORM_MAX_PATH, VagineerKSpree2);
					else
						Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerKSpreeNew, GetRandomInt(1, 5));
				}
				case VSHSpecial_HHH: Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HHHLaught, GetRandomInt(1, 4));
				case VSHSpecial_CBS:
				{
					if (!GetRandomInt(0, 3))
						Format(s, PLATFORM_MAX_PATH, CBS0);
					else if (!GetRandomInt(0, 3))
						Format(s, PLATFORM_MAX_PATH, CBS1);
					else
						Format(s, PLATFORM_MAX_PATH, "%s%02i.wav", CBS2, GetRandomInt(1, 9));
					EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				}
				case VSHSpecial_Bunny:
				{
					strcopy(s, PLATFORM_MAX_PATH, BunnySpree[GetRandomInt(0, sizeof(BunnySpree)-1)]);
				}
			}
			EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
			KSpreeCount = 0;
		}
		else
			KSpreeTimer = GetGameTime() + 5.0;
	}
	if ((TF2_GetPlayerClass(client) == TFClass_Engineer) && !(deathflags & TF_DEATHFLAG_DEADRINGER))
	{
		for (new ent = MaxClients + 1; ent < ME; ent++)
		{
			if (IsValidEdict(ent))
			{
				if (GetEdictClassname(ent, s, sizeof(s)) && !strcmp(s, "obj_sentrygun", false) && GetEntPropEnt(ent, Prop_Send, "m_hBuilder") == client)
				{
//                  SDKHooks_TakeDamage(ent, Hale, Hale, Float:(GetEntProp(ent, Prop_Send, "m_iMaxHealth")+8), DMG_CLUB);
					SetVariantInt(GetEntProp(ent, Prop_Send, "m_iMaxHealth")+8);
					AcceptEntityInput(ent, "RemoveHealth");
				}
			}
		}
	}
	return Plugin_Continue;
}

// event_uberdeployed  event_uberdeployed  event_uberdeployed  event_uberdeployed  event_uberdeployed  event_uberdeployed
// event_uberdeployed  event_uberdeployed  event_uberdeployed  event_uberdeployed  event_uberdeployed  event_uberdeployed
// event_uberdeployed  event_uberdeployed  event_uberdeployed  event_uberdeployed  event_uberdeployed  event_uberdeployed

public Action:event_uberdeployed(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!Enabled)
		return Plugin_Continue;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new String:s[64];
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		new medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		if (IsValidEntity(medigun))
		{
			GetEdictClassname(medigun, s, sizeof(s));
			if (strcmp(s, "tf_weapon_medigun", false) == 0)
			{
				TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.5, client);
				new target = GetHealingTarget(client);
				if (IsValidClient(target, false) && IsPlayerAlive(target))
				{
					TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5, client);
					uberTarget[client] = target;
				}
				else uberTarget[client] = -1;
				SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", 1.51);
				CreateTimer(0.4, Timer_Lazor, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	return Plugin_Continue;
}

// event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt
// event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt
// event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt  event_hurt

public Action:event_hurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!Enabled)
		return Plugin_Continue;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new damage = GetEventInt(event, "damageamount");
	new custom = GetEventInt(event, "custom");
	new weapon = GetEventInt(event, "weaponid");
	if (client != Hale) // || !IsValidEdict(client) || !IsValidEdict(attacker) || (client <= 0) || (attacker <= 0) || (attacker > MaxClients))
		return Plugin_Continue;

	if (!IsValidClient(attacker) || !IsValidClient(client) || client == attacker) // || custom == TF_CUSTOM_BACKSTAB)
		return Plugin_Continue;

	if (custom == TF_CUSTOM_TELEFRAG) damage = (IsPlayerAlive(attacker) ? 9001:1);

	if (GetEventBool(event, "minicrit") && GetEventBool(event, "allseecrit")) SetEventBool(event, "allseecrit", false);

	HaleHealth -= damage;
	HaleRage += damage;

	if (custom == TF_CUSTOM_TELEFRAG) SetEventInt(event, "damageamount", damage);

	Damage[attacker] += damage;

	if (TF2_GetPlayerClass(attacker) == TFClass_Soldier && GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary) == 1104)
	{
		if (weapon == TF_WEAPON_ROCKETLAUNCHER)
		{
			AirDamage[attacker] += damage;
		}

		SetEntProp(attacker, Prop_Send, "m_iDecapitations", AirDamage[attacker]/200);
	}

	new healers[MAXPLAYERS];
	new healercount = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && (GetHealingTarget(i) == attacker))
		{
			healers[healercount] = i;
			healercount++;
		}
	}
	for (new i = 0; i < healercount; i++) // Medics now count as 3/5 of a backstab, similar to telefrag assists.
	{
		if (IsValidClient(healers[i]) && IsPlayerAlive(healers[i]))
		{
			if (damage < 10 || uberTarget[healers[i]] == attacker)
				Damage[healers[i]] += damage;
			else
				Damage[healers[i]] += damage/(healercount+1);
		}
	}

	if (HaleRage > RageDMG)
		HaleRage = RageDMG;
	return Plugin_Continue;
}

// event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy
// event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy
// event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy  event_destroy

public Action:event_destroy(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (Enabled)
	{
		new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		new customkill = GetEventInt(event, "customkill");
		if (attacker == Hale) /* || (attacker == Companion)*/
		{
			if (Special == VSHSpecial_Hale)
			{
				if (customkill != TF_CUSTOM_BOOTS_STOMP) SetEventString(event, "weapon", "fists");
				if (!GetRandomInt(0, 4))
				{
					decl String:s[PLATFORM_MAX_PATH];
					strcopy(s, PLATFORM_MAX_PATH, HaleSappinMahSentry132);
					EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
					EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, NULL_VECTOR, NULL_VECTOR, false, 0.0);
				}
			}
		}
	}
	return Plugin_Continue;
}

// event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect
// event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect
// event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect  event_deflect

public Action:event_deflect(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!Enabled) return Plugin_Continue;
	new deflector = GetClientOfUserId(GetEventInt(event, "userid"));
	new owner = GetClientOfUserId(GetEventInt(event, "ownerid"));
	new weaponid = GetEventInt(event, "weaponid");
	if (owner != Hale) return Plugin_Continue;
	if (weaponid != 0) return Plugin_Continue;
	new Float:rage = 0.04*RageDMG;
	HaleRage += RoundToCeil(rage);
	if (HaleRage > RageDMG)
		HaleRage = RageDMG;
	if (Special != VSHSpecial_Vagineer) return Plugin_Continue;
	if (!TF2_IsPlayerInCondition(owner, TFCond_Ubercharged)) return Plugin_Continue;
	if (UberRageCount > 11) UberRageCount -= 10;
	new newammo = GetAmmo(deflector, 0) - 5;
	SetAmmo(deflector, 0, newammo <= 0 ? 0 : newammo);
	return Plugin_Continue;
}

// event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate
// event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate
// event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate  event_jarate

public Action:event_jarate(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	new client = BfReadByte(bf);
	new victim = BfReadByte(bf);
	if (victim != Hale) return Plugin_Continue;
	new jar = GetPlayerWeaponSlot(client, 1);

	new jindex = GetEntProp(jar, Prop_Send, "m_iItemDefinitionIndex");

	if (jar != -1 && (jindex == 58 || jindex == 1083 || jindex == 1105) && GetEntProp(jar, Prop_Send, "m_iEntityLevel") != -122)    //-122 is the Jar of Ants and should not be used in this
	{
		new Float:rage = 0.08*RageDMG;
		HaleRage -= RoundToFloor(rage);
		if (HaleRage < 0)
			HaleRage = 0;
		if (Special == VSHSpecial_Vagineer && TF2_IsPlayerInCondition(victim, TFCond_Ubercharged) && UberRageCount < 99)
		{
			UberRageCount += 7.0;
			if (UberRageCount > 99) UberRageCount = 99.0;
		}
		new ammo = GetAmmo(Hale, 0);
		if (Special == VSHSpecial_CBS && ammo > 0) SetAmmo(Hale, 0, ammo - 1);
	}
	return Plugin_Continue;
}
