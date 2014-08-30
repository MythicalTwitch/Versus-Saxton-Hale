public Action:Timer_Announce(Handle:hTimer)
{
	static announcecount=-1;
	announcecount++;
	if (Announce > 1.0 && Enabled2)
	{
		switch (announcecount)
		{
			case 1:
			{
				CPrintToChatAll("{olive}[VSH]{default} VS Saxton Hale group: {olive}http://steamcommunity.com/groups/vssaxtonhale{default}");
			}
			case 3:
			{
				CPrintToChatAll("{default}VSH v%s by {olive}Rainbolt Dash{default}, {olive}FlaminSarge{default}, & {lightsteelblue}Chdata{default}.", haleversiontitles[maxversion]);
			}
			case 5:
			{
				announcecount = 0;
				CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_last_update", haleversiontitles[maxversion], haleversiondates[maxversion]);
			}
			default:
			{
//              if (ACH_Enabled)
//                  CPrintToChatAll("{olive}[VSH]{default} %t\n%t (experimental)", "vsh_open_menu", "vsh_open_ach");
//              else
					CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_open_menu");
			}
		}
	}
	return Plugin_Continue;
}

public Action:Timer_EnableCap(Handle:timer)
{
	if (VSHRoundState == -1)
	{
		SetControlPoint(true);
		if (checkdoors)
		{
			new ent = -1;
			while ((ent = FindEntityByClassname2(ent, "func_door")) != -1)
			{
				AcceptEntityInput(ent, "Open");
				AcceptEntityInput(ent, "Unlock");
			}
			if (doorchecktimer == INVALID_HANDLE)
				doorchecktimer = CreateTimer(5.0, Timer_CheckDoors, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}
public Action:Timer_CheckDoors(Handle:hTimer)
{
	if (!checkdoors)
	{
		doorchecktimer = INVALID_HANDLE;
		return Plugin_Stop;
	}

	if ((!Enabled && VSHRoundState != -1) || (Enabled && VSHRoundState != 1)) return Plugin_Continue;
	new ent = -1;
	while ((ent = FindEntityByClassname2(ent, "func_door")) != -1)
	{
		AcceptEntityInput(ent, "Open");
		AcceptEntityInput(ent, "Unlock");
	}
	return Plugin_Continue;
}

public Action:Timer_NineThousand(Handle:timer)
{
	EmitSoundToAll("saxton_hale/9000.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, false, 0.0);
	EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, "saxton_hale/9000.wav", _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, false, 0.0);
	EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, "saxton_hale/9000.wav", _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, 1.0, 100, _, _, NULL_VECTOR, false, 0.0);
}
public Action:Timer_CalcScores(Handle:timer)
{
	CalcScores();
}

public Action:Timer_MusicTheme(Handle:timer, any:pack)
{
	decl String:sound[PLATFORM_MAX_PATH];
	ResetPack(pack);
	ReadPackString(pack, sound, sizeof(sound));
	new Float:time = ReadPackFloat(pack);
	if (Enabled && VSHRoundState == 1)
	{
/*      new String:sound[PLATFORM_MAX_PATH] = "";
		switch (Special)
		{
			case VSHSpecial_CBS:
				strcopy(sound, sizeof(sound), CBSTheme);
			case VSHSpecial_HHH:
				strcopy(sound, sizeof(sound), HHHTheme);
		}*/
		new Action:act = Plugin_Continue;
		Call_StartForward(OnMusic);
		decl String:sound2[PLATFORM_MAX_PATH];
		new Float:time2 = time;
		strcopy(sound2, PLATFORM_MAX_PATH, sound);
		Call_PushStringEx(sound2, PLATFORM_MAX_PATH, 0, SM_PARAM_COPYBACK);
		Call_PushFloatRef(time2);
		Call_Finish(act);
		switch (act)
		{
			case Plugin_Stop, Plugin_Handled:
			{
				strcopy(sound, sizeof(sound), "");
				time = -1.0;
				MusicTimer = INVALID_HANDLE;
				return Plugin_Stop;
			}
			case Plugin_Changed:
			{
				strcopy(sound, PLATFORM_MAX_PATH, sound2);
				if (time2 != time)
				{
					time = time2;
					if (MusicTimer != INVALID_HANDLE)
					{
						KillTimer(MusicTimer);
						MusicTimer = INVALID_HANDLE;
					}
					if (time != -1.0)
					{
						new Handle:datapack;
						MusicTimer = CreateDataTimer(time, Timer_MusicTheme, datapack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						WritePackString(datapack, sound);
						WritePackFloat(datapack, time);
					}
				}
			}
		}
		if (sound[0] != '\0')
		{
//          Format(sound, sizeof(sound), "#%s", sound);
			EmitSoundToAllExcept(SOUNDEXCEPT_MUSIC, sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
	}
	else
	{
		MusicTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:Timer_ReEquipSaxton(Handle:timer)
{
	if (IsValidClient(Hale))
	{
		EquipSaxton(Hale);
	}
}
public Action:Timer_SkipHalePanel(Handle:hTimer)
{
	new bool:added[MAXPLAYERS + 1];
	new i, j;
	new client = Hale;
	do
	{
		client = FindNextHale(added);
		if (client >= 0) added[client] = true;
		if (IsValidClient(client) && client != Hale)
		{
			if (!IsFakeClient(client))
			{
				CPrintToChat(client, "{olive}[VSH]{default} %t", "vsh_to0_near");
				if (i == 0) SkipHalePanelNotify(client);
			}
			i++;
		}
		j++;
	}
	while (i < 3 && j < MAXPLAYERS + 1);
}
public Action:Timer_NoHonorBound(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		new weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		new index = ((IsValidEntity(weapon) && weapon > MaxClients) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
		new active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		new String:classname[64];
		if (IsValidEdict(active)) GetEdictClassname(active, classname, sizeof(classname));
		if (index == 357 && active == weapon && strcmp(classname, "tf_weapon_katana", false) == 0)
		{
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if (GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
				SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
		}
	}
}

public Action:Timer_Lazor(Handle:hTimer, any:medigunid)
{
	new medigun = EntRefToEntIndex(medigunid);
	if (medigun && IsValidEntity(medigun) && VSHRoundState == 1)
	{
		new client = GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
		new Float:charge = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
		if (IsValidClient(client, false) && IsPlayerAlive(client) && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == medigun)
		{
			new target = GetHealingTarget(client);
			if (charge > 0.05)
			{
				TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.5);
				if (IsValidClient(target, false) && IsPlayerAlive(target))
				{
					TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5);
					uberTarget[client] = target;
				}
				else uberTarget[client] = -1;
			}
		}
		if (charge <= 0.05)
		{
			CreateTimer(3.0, Timer_Lazor2, EntIndexToEntRef(medigun));
			VSHFlags[client] &= ~VSHFLAG_UBERREADY;
			return Plugin_Stop;
		}
	}
	else
		return Plugin_Stop;
	return Plugin_Continue;
}
public Action:Timer_Lazor2(Handle:hTimer, any:medigunid)
{
	new medigun = EntRefToEntIndex(medigunid);
	if (IsValidEntity(medigun))
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")+0.31);
	return Plugin_Continue;
}

public Action:Timer_SetDisconQueuePoints(Handle:timer, Handle:pack)
{
	ResetPack(pack);
	decl String:authid[32];
	ReadPackString(pack, authid, sizeof(authid));
	SetAuthIdQueuePoints(authid, 0);
}
public Action:Timer_RegenPlayer(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client))
	{
		TF2_RegeneratePlayer(client);
	}
}
public Action:Timer_StunHHH(Handle:timer, Handle:pack)
{
	if (!IsValidClient(Hale, false)) return;
	ResetPack(pack);
	new superduper = ReadPackCell(pack);
	new targetid = ReadPackCell(pack);
	new target = GetClientOfUserId(targetid);
	if (!IsValidClient(target, false)) target = 0;
	VSHFlags[Hale] &= ~VSHFLAG_NEEDSTODUCK;
	TF2_StunPlayer(Hale, (superduper ? 4.0 : 2.0), 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
}
public Action:Timer_BotRage(Handle:timer)
{
	if (!IsValidClient(Hale, false)) return;
	if (!TF2_IsPlayerInCondition(Hale, TFCond_Taunting)) FakeClientCommandEx(Hale, "taunt");
}

public Action:Timer_GravityCat(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (IsValidClient(client)) SetEntityGravity(client, 1.0);
}

public Action:Timer_NoTaunting(Handle:timer)
{
	bNoTaunt = false;
}

public Action:Timer_Damage(Handle:hTimer, any:id)
{
	new client = GetClientOfUserId(id);
	if (IsValidClient(client, false))
		CPrintToChat(client, "{olive}[VSH] %t. %t %i{default}", "vsh_damage", Damage[client], "vsh_scores", RoundFloat(Damage[client] / 600.0));
	return Plugin_Continue;
}

/*public Action:Timer_RemoveCandycaneHealthPack(Handle:timer, any:ref)
{
	new entity = EntRefToEntIndex(ref);
	if (entity > MaxClients && IsValidEntity(entity))
	{
		AcceptEntityInput(entity, "Kill");
	}
}*/
public Action:Timer_StopTickle(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return;
	if (!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner"))) TF2_RemoveCondition(client, TFCond_Taunting);
}
public Action:Timer_CheckBuffRage(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 100.0);
	}
}


public Action:Timer_NoAttacking(Handle:timer, any:ref)
{
	new weapon = EntRefToEntIndex(ref);
	SetNextAttack(weapon, 1.56);
}

public Action:Timer_SetEggBomb(Handle:timer, any:ref)
{
	new entity = EntRefToEntIndex(ref);
	if (FileExists(EggModel) && IsModelPrecached(EggModel) && IsValidEntity(entity))
	{
		new att = AttachProjectileModel(entity, EggModel);
		SetEntProp(att, Prop_Send, "m_nSkin", 0);
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SetEntityRenderColor(entity, 255, 255, 255, 0);
	}
}

public Action:Timer_MusicPlay(Handle:timer)
{
	if (VSHRoundState != 1) return Plugin_Stop;
	new String:sound[PLATFORM_MAX_PATH] = "";
	new Float:time = -1.0;
	if (MusicTimer != INVALID_HANDLE)
	{
		KillTimer(MusicTimer);
		MusicTimer = INVALID_HANDLE;
	}
	if (MapHasMusic())
	{
		strcopy(sound, sizeof(sound), "");
		time = -1.0;
	}
	else
	{
		switch (Special)
		{
//          case VSHSpecial_Hale:
//          {
//              strcopy(sound, sizeof(sound), HaleTempTheme);
//              time = 162.0;
//          }
			case VSHSpecial_CBS:
			{
				strcopy(sound, sizeof(sound), CBSTheme);
				time = 137.0;
			}
			case VSHSpecial_HHH:
			{
				strcopy(sound, sizeof(sound), HHHTheme);
				time = 87.0;
			}
		}
	}
	new Action:act = Plugin_Continue;
	Call_StartForward(OnMusic);
	decl String:sound2[PLATFORM_MAX_PATH];
	new Float:time2 = time;
	strcopy(sound2, PLATFORM_MAX_PATH, sound);
	Call_PushStringEx(sound2, PLATFORM_MAX_PATH, 0, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time2);
	Call_Finish(act);
	switch (act)
	{
		case Plugin_Stop, Plugin_Handled:
		{
			strcopy(sound, sizeof(sound), "");
			time = -1.0;
		}
		case Plugin_Changed:
		{
			strcopy(sound, PLATFORM_MAX_PATH, sound2);
			time = time2;
		}
	}
	if (sound[0] != '\0')
	{
//      Format(sound, sizeof(sound), "#%s", sound);
		EmitSoundToAllExcept(SOUNDEXCEPT_MUSIC, sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
	if (time != -1.0)
	{
		new Handle:pack;
		MusicTimer = CreateDataTimer(time, Timer_MusicTheme, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		WritePackString(pack, sound);
		WritePackFloat(pack, time);
	}
	return Plugin_Continue;
}
/*public Action:Timer_DissolveRagdoll(Handle:timer, any:userid)
{
	new victim = GetClientOfUserId(userid);
	new ragdoll = (IsValidClient(victim) ? GetEntPropEnt(victim, Prop_Send, "m_hRagdoll") : -1);
	if (IsValidEntity(ragdoll))
	{
		DissolveRagdoll(ragdoll);
	}
}

public Action:Timer_ChangeRagdoll(Handle:timer, any:userid)
{
	new victim = GetClientOfUserId(userid);
	new ragdoll;
	if (IsValidClient(victim)) ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");
	else ragdoll = -1;
	if (IsValidEntity(ragdoll))
	{
		switch (Special)
		{
			case VSHSpecial_Hale:       SetEntityModel(ragdoll, HaleModel);
			case VSHSpecial_Vagineer:   SetEntityModel(ragdoll, VagineerModel);
			case VSHSpecial_HHH:        SetEntityModel(ragdoll, HHHModel);
			case VSHSpecial_CBS:        SetEntityModel(ragdoll, CBSModel);
			case VSHSpecial_Bunny:      SetEntityModel(ragdoll, BunnyModel);
		}
	}
}

public Action:Timer_DisguiseBackstab(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (IsValidClient(client, false))
	{
		RandomlyDisguise(client);
	}
}
*/

public Action:GottamTimer(Handle:hTimer)
{
	for (new i = 1; i <= MaxClients; i++)
		if (IsValidClient(i) && IsPlayerAlive(i))
			SetEntityMoveType(i, MOVETYPE_WALK);
}
public Action:StartRound(Handle:hTimer)
{
	VSHRoundState = 1;
	if (IsValidClient(Hale))
	{
		if (!IsPlayerAlive(Hale) && TFTeam:GetClientTeam(Hale) != TFTeam_Spectator && TFTeam:GetClientTeam(Hale) != TFTeam_Unassigned)
		{
			TF2_RespawnPlayer(Hale);
		}
		if (GetClientTeam(Hale) != HaleTeam)
		{
			SetEntProp(Hale, Prop_Send, "m_lifeState", 2);
			ChangeClientTeam(Hale, HaleTeam);
			SetEntProp(Hale, Prop_Send, "m_lifeState", 0);
			TF2_RespawnPlayer(Hale);
		}
		if (GetClientTeam(Hale) == HaleTeam)
		{
			new bool:pri = IsValidEntity(GetPlayerWeaponSlot(Hale, TFWeaponSlot_Primary));
			new bool:sec = IsValidEntity(GetPlayerWeaponSlot(Hale, TFWeaponSlot_Secondary));
			new bool:mel = IsValidEntity(GetPlayerWeaponSlot(Hale, TFWeaponSlot_Melee));
			TF2_RemovePlayerDisguise(Hale);

			if (pri || sec || !mel)
				CreateTimer(0.05, Timer_ReEquipSaxton, _, TIMER_FLAG_NO_MAPCHANGE);
			//EquipSaxton(Hale);
		}
	}
	CreateTimer(10.0, Timer_SkipHalePanel);
	return Plugin_Continue;
}

public Action:tTenSecStart(Handle:hTimer, any:ofs)
{
	bTenSecStart[ofs] = false;
}
public Action:StartHaleTimer(Handle:hTimer)
{
	CreateTimer(0.1, GottamTimer);
	if (!IsValidClient(Hale))
	{
		VSHRoundState = 2;
		return Plugin_Continue;
	}
	if (!IsPlayerAlive(Hale))
	{
		TF2_RespawnPlayer(Hale);
	}
	playing = 0; // nergal's FRoG fix
	for (new client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || !IsPlayerAlive(client) || client == Hale) continue;
		playing++;
		CreateTimer(0.2, MakeNoHale, GetClientUserId(client));
	}
	//if (playing < 5)
	//  playing += 2;
	// Chdata's slightly reworked Hale HP calculation (in light of removing the above two lines)
	HaleHealthMax = RoundFloat(Pow(((760.8+playing)*(playing-1)), 1.0341)) + 2046;
	//HaleHealthMax = RoundFloat(Pow(((760.0+playing)*(playing-1)), 1.04));
	if (HaleHealthMax < 2046)
	{
		HaleHealthMax = 2046;
	}
	//SetEntProp(Hale, Prop_Data, "m_iMaxHealth", HaleHealthMax);
//  SetEntProp(Hale, Prop_Data, "m_iHealth", HaleHealthMax);
//  SetEntProp(Hale, Prop_Send, "m_iHealth", HaleHealthMax);
	SetHaleHealthFix(Hale, HaleHealth, HaleHealthMax);
	HaleHealth = HaleHealthMax;
	HaleHealthLast = HaleHealth;
	CreateTimer(0.2, CheckAlivePlayers);
	CreateTimer(0.2, HaleTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.2, StartRound);
	CreateTimer(0.2, ClientTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	if (!PointType && playing > GetConVarInt(cvarAliveToEnable))
	{
		SetControlPoint(false);
	}
	if (VSHRoundState == 0)
	{
		CreateTimer(2.0, Timer_MusicPlay, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Continue;
}

public Action:EnableSG(Handle:hTimer, any:iid)
{
	new i = EntRefToEntIndex(iid);
	if (VSHRoundState == 1 && IsValidEdict(i) && i > MaxClients)
	{
		decl String:s[64];
		GetEdictClassname(i, s, 64);
		if (StrEqual(s, "obj_sentrygun"))
		{
			SetEntProp(i, Prop_Send, "m_bDisabled", 0);
			for (new ent = MaxClients+1; ent < ME; ent++)
			{
				if (IsValidEdict(ent))
				{
					new String:s2[64];
					GetEdictClassname(ent, s2, 64);
					if (StrEqual(s2, "info_particle_system") && (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == i))
					{
						AcceptEntityInput(ent, "Kill");
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
public Action:RemoveEnt(Handle:timer, any:entid)
{
	new ent = EntRefToEntIndex(entid);
	if (ent > 0 && IsValidEntity(ent))
		AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
public Action:MessageTimer(Handle:hTimer, any:client)
{
	if (!IsValidClient(Hale) || ((client != 9001) && !IsValidClient(client)))
		return Plugin_Continue;
	if (checkdoors)
	{
		new ent = -1;
		while ((ent = FindEntityByClassname2(ent, "func_door")) != -1)
		{
			AcceptEntityInput(ent, "Open");
			AcceptEntityInput(ent, "Unlock");
		}
		if (doorchecktimer == INVALID_HANDLE)
			doorchecktimer = CreateTimer(5.0, Timer_CheckDoors, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	decl String:translation[32];
	switch (Special)
	{
		case VSHSpecial_Miku: strcopy(translation, sizeof(translation), "vsh_start_miku");
		case VSHSpecial_Bunny: strcopy(translation, sizeof(translation), "vsh_start_bunny");
		case VSHSpecial_Vagineer: strcopy(translation, sizeof(translation), "vsh_start_vagineer");
		case VSHSpecial_HHH: strcopy(translation, sizeof(translation), "vsh_start_hhh");
		case VSHSpecial_CBS: strcopy(translation, sizeof(translation), "vsh_start_cbs");
		default: strcopy(translation, sizeof(translation), "vsh_start_hale");
	}
	SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
	if (client != 9001 && !(GetClientButtons(client) & IN_SCORE)) //bad
		ShowHudText(client, -1, "%T", translation, client, Hale, HaleHealthMax);
	else
		for (new i = 1; i <= MaxClients; i++)
			if (IsValidClient(i) && !(GetClientButtons(i) & IN_SCORE))
				ShowHudText(i, -1, "%T", translation, i, Hale, HaleHealthMax);
	return Plugin_Continue;
}
public Action:MakeModelTimer(Handle:hTimer)
{
	if (!IsValidClient(Hale) || !IsPlayerAlive(Hale) || VSHRoundState == 2)
	{
		return Plugin_Stop;
	}
	new body = 0;
	switch (Special)
	{
		case VSHSpecial_Miku:
		{
			SetVariantString(MikuModel);
		}
		case VSHSpecial_Bunny:
		{
			SetVariantString(BunnyModel);
		}
		case VSHSpecial_Vagineer:
		{
			SetVariantString(VagineerModel);
//          SetEntProp(Hale, Prop_Send, "m_nSkin", GetClientTeam(Hale)-2);
		}
		case VSHSpecial_HHH:
			SetVariantString(HHHModel);
		case VSHSpecial_CBS:
			SetVariantString(CBSModel);
		default:
		{
			SetVariantString(HaleModel);
//          decl String:steamid[32];
//          GetClientAuthString(Hale, steamid, sizeof(steamid));
			if (GetUserFlagBits(Hale) & ADMFLAG_CUSTOM1) body = (1 << 0)|(1 << 1);
		}
	}
//  DispatchKeyValue(Hale, "targetname", "hale");
	AcceptEntityInput(Hale, "SetCustomModel");
	SetEntProp(Hale, Prop_Send, "m_bUseClassAnimations", 1);
	SetEntProp(Hale, Prop_Send, "m_nBody", body);
	return Plugin_Continue;
}

public Action:MakeHale(Handle:hTimer)
{
	if (!IsValidClient(Hale))
	{
		return Plugin_Continue;
	}

	switch (Special)
	{
		case VSHSpecial_Miku:
			TF2_SetPlayerClass(Hale, TFClass_Scout, _, false);
		case VSHSpecial_Hale:
			TF2_SetPlayerClass(Hale, TFClass_Soldier, _, false);
		case VSHSpecial_Vagineer:
			TF2_SetPlayerClass(Hale, TFClass_Engineer, _, false);
		case VSHSpecial_HHH, VSHSpecial_Bunny:
			TF2_SetPlayerClass(Hale, TFClass_DemoMan, _, false);
		case VSHSpecial_CBS:
			TF2_SetPlayerClass(Hale, TFClass_Sniper, _, false);
	}
	TF2_RemovePlayerDisguise(Hale);

	if (GetClientTeam(Hale) != HaleTeam)
	{
		SetEntProp(Hale, Prop_Send, "m_lifeState", 2);
		ChangeClientTeam(Hale, HaleTeam);
		SetEntProp(Hale, Prop_Send, "m_lifeState", 0);
		TF2_RespawnPlayer(Hale);
	}
	if (VSHRoundState < 0)
		return Plugin_Continue;
	if (!IsPlayerAlive(Hale))
	{
		if (VSHRoundState == 0) TF2_RespawnPlayer(Hale);
		else return Plugin_Continue;
	}
	new iFlags = GetCommandFlags("r_screenoverlay");
	SetCommandFlags("r_screenoverlay", iFlags & ~FCVAR_CHEAT);
	ClientCommand(Hale, "r_screenoverlay \"\"");
	SetCommandFlags("r_screenoverlay", iFlags);
	CreateTimer(0.2, MakeModelTimer, _);
	CreateTimer(20.0, MakeModelTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	new ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_wearable")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == Hale)
		{
			new index = GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex");
			switch (index)
			{
				case 438, 463, 167, 477, 493, 233, 234, 241, 280, 281, 282, 283, 284, 286, 288, 362, 364, 365, 536, 542, 577, 599, 673, 729, 791, 839, 1015, 5607: {}
				default:    TF2_RemoveWearable(Hale, ent); //AcceptEntityInput(ent, "kill");
			}
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_powerup_bottle")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == Hale)
		{
			new index = GetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex");
			switch (index)
			{
				case 438, 463, 167, 477, 493, 233, 234, 241, 280, 281, 282, 283, 284, 286, 288, 362, 364, 365, 536, 542, 577, 599, 673, 729, 791, 839, 1015, 5607: {}
				default:    TF2_RemoveWearable(Hale, ent); //AcceptEntityInput(ent, "kill");
			}
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_wearable_demoshield")) != -1)
	{
		if (GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity") == Hale)
		{
			TF2_RemoveWearable(Hale, ent);
			//AcceptEntityInput(ent, "kill");
		}
	}
	EquipSaxton(Hale);

	if (VSHRoundState >= 0 && GetClientClasshelpinfoCookie(Hale))
	{
		HintPanel(Hale);

		DoForward_VSHOnHaleCreated();
	}

	return Plugin_Continue;
}


public Action:MakeNoHale(Handle:hTimer, any:clientid)
{
	new client = GetClientOfUserId(clientid);
	if (!IsValidClient(client) || !IsPlayerAlive(client) || VSHRoundState == 2 || client == Hale)
		return Plugin_Continue;
//  SetVariantString("");
//  AcceptEntityInput(client, "SetCustomModel");
	if (GetClientTeam(client) != OtherTeam)
	{
		SetEntProp(client, Prop_Send, "m_lifeState", 2);
		ChangeClientTeam(client, OtherTeam);
		SetEntProp(client, Prop_Send, "m_lifeState", 0);
		TF2_RespawnPlayer(client);
		TF2_RegeneratePlayer(client);   // Added fix by Chdata to correct team colors
	}
//  SetEntityRenderColor(client, 255, 255, 255, 255);
	if (!VSHRoundState && GetClientClasshelpinfoCookie(client) && !(VSHFlags[client] & VSHFLAG_CLASSHELPED))
		HelpPanel2(client);
	new weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	new index = -1;
	if (weapon > MaxClients && IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index)
		{
			case 41:    // ReplacelistPrimary
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				weapon = SpawnWeapon(client, "tf_weapon_minigun", 15, 1, 0, "");
			}
			case 402:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				SpawnWeapon(client, "tf_weapon_sniperrifle", 14, 1, 0, "");
			}
			case 772, 448: // Block BFB and Soda Popper
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				weapon = SpawnWeapon(client, "tf_weapon_scattergun", 13, 1, 0, "");
			}
			case 237:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				weapon = SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 1, 0, "265 ; 99999.0");
				SetAmmo(client, 0, 20);
			}
			case 17, 204, 36, 412:
			{
				if (GetEntProp(weapon, Prop_Send, "m_iEntityQuality") != 10)
				{
					TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
					SpawnWeapon(client, "tf_weapon_syringegun_medic", 17, 1, 10, "17 ; 0.05 ; 144 ; 1");
				}
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (weapon > MaxClients && IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index)
		{
//          case 226:
//          {
//              TF2_RemoveWeaponSlot2(client, 1);
//              weapon = SpawnWeapon(client, "tf_weapon_shotgun_soldier", 10, 1, 0, "");
//          }
			case 528:   // ReplacelistSecondary
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_laser_pointer", 140, 1, 0, "");
			}
			case 46:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_lunchbox_drink", 163, 1, 0, "144 ; 2");
			}
			case 57:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, "");
			}
			case 265:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
				weapon = SpawnWeapon(client, "tf_weapon_pipebomblauncher", 20, 1, 0, "");
				SetAmmo(client, 1, 24);
			}
//          case 39, 351:
//          {
//              if (GetEntProp(weapon, Prop_Send, "m_iEntityQuality") != 10)
//              {
//                  TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
//                  weapon = SpawnWeapon(client, "tf_weapon_flaregun", 39, 5, 10, "25 ; 0.5 ; 207 ; 1.33 ; 144 ; 1.0 ; 58 ; 3.2")
//              }
//          }
		}
	}
	if (IsValidEntity(FindPlayerBack(client, { 57 }, 1)))
	{
		RemovePlayerBack(client, { 57 }, 1);
		weapon = SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, "");
	}
	if (IsValidEntity(FindPlayerBack(client, { 642 }, 1)))
	{
		weapon = SpawnWeapon(client, "tf_weapon_smg", 16, 1, 6, "149 ; 1.5 ; 15 ; 0.0 ; 1 ; 0.85");
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (weapon > MaxClients && IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index)
		{
			case 331:
			{
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Melee);
				weapon = SpawnWeapon(client, "tf_weapon_fists", 195, 1, 6, "");
			}
			case 357:
			{
				CreateTimer(1.0, Timer_NoHonorBound, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
			case 589:
			{
				if (!GetConVarBool(cvarEnableEurekaEffect))
				{
					TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Melee);
					weapon = SpawnWeapon(client, "tf_weapon_wrench", 7, 1, 0, "");
				}
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, 4);
	if (weapon > MaxClients && IsValidEdict(weapon) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 60)
	{
		TF2_RemoveWeaponSlot2(client, 4);
		weapon = SpawnWeapon(client, "tf_weapon_invis", 30, 1, 0, "");
	}
	if (TF2_GetPlayerClass(client) == TFClass_Medic)
	{
		weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		new mediquality = (weapon > MaxClients && IsValidEdict(weapon) ? GetEntProp(weapon, Prop_Send, "m_iEntityQuality") : -1);
		if (mediquality != 10)
		{
			TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Secondary);
			weapon = SpawnWeapon(client, "tf_weapon_medigun", 35, 5, 10, "18 ; 0.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0");  //200 ; 1 for area of effect healing    // ; 178 ; 0.75 ; 128 ; 1.0 Faster switch-to
			if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 142)
			{
				SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
				SetEntityRenderColor(weapon, 255, 255, 255, 75);
			}
			SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.41);
		}
	}
	return Plugin_Continue;
}

public Action:ClientTimer(Handle:hTimer)
{
	if (VSHRoundState > 1 || VSHRoundState == -1)
	{
		return Plugin_Stop;
	}
	decl String:wepclassname[32];
	new i = -1;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && client != Hale && GetClientTeam(client) == OtherTeam)
		{
			SetHudTextParams(-1.0, 0.88, 0.35, 90, 255, 90, 255, 0, 0.35, 0.0, 0.1);
			if (!IsPlayerAlive(client))
			{
				new obstarget = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
				if (IsValidClient(obstarget) && obstarget != Hale && obstarget != client)
				{
					if (!(GetClientButtons(client) & IN_SCORE)) ShowSyncHudText(client, rageHUD, "Damage: %d - %N's Damage: %d", Damage[client], obstarget, Damage[obstarget]);
				}
				else
				{
					if (!(GetClientButtons(client) & IN_SCORE)) ShowSyncHudText(client, rageHUD, "Damage: %d", Damage[client]);
				}
				continue;
			}
			if (!(GetClientButtons(client) & IN_SCORE)) ShowSyncHudText(client, rageHUD, "Damage: %d", Damage[client]);
			new TFClassType:class = TF2_GetPlayerClass(client);
			new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if (weapon <= MaxClients || !IsValidEntity(weapon) || !GetEdictClassname(weapon, wepclassname, sizeof(wepclassname))) strcopy(wepclassname, sizeof(wepclassname), "");
			new bool:validwep = (strncmp(wepclassname, "tf_wea", 6, false) == 0);
			new index = (validwep ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
			if (TF2_IsPlayerInCondition(client, TFCond_Cloaked))
			{
				if (GetClientCloakIndex(client) == 59)
				{
					if (TF2_IsPlayerInCondition(client, TFCond_DeadRingered)) TF2_RemoveCondition(client, TFCond_DeadRingered);
				}
				else TF2_AddCondition(client, TFCond_DeadRingered, 0.3);
			}

			new bool:bHudAdjust = false;

			// Chdata's Deadringer Notifier
			if (TF2_GetPlayerClass(client) == TFClass_Spy)
			{
				if (GetClientCloakIndex(client) == 59)
				{
					bHudAdjust = true;
					new drstatus = TF2_IsPlayerInCondition(client, TFCond_Cloaked) ? 2 : GetEntProp(client, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;

					decl String:s[32];

					switch (drstatus)
					{
						case 1:
						{
							SetHudTextParams(-1.0, 0.83, 0.35, 90, 255, 90, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Feign Death Ready");
						}
						case 2:
						{
							SetHudTextParams(-1.0, 0.83, 0.35, 255, 64, 64, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Deadringed");
						}
						default:
						{
							SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Inactive");
						}
					}

					if (!(GetClientButtons(client) & IN_SCORE))
					{
						ShowSyncHudText(client, jumpHUD, "%s", s);
					}
				}
			}

			if (class == TFClass_Medic)
			{
				new medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);

				decl String:mediclassname[64];

				if (IsValidEdict(medigun) && GetEdictClassname(medigun, mediclassname, sizeof(mediclassname)) && strcmp(mediclassname, "tf_weapon_medigun", false) == 0)
				{
					bHudAdjust = true;
					SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);

					new charge = RoundToFloor(GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") * 100);

					if (!(GetClientButtons(client) & IN_SCORE))
					{
						ShowSyncHudText(client, jumpHUD, "%T: %i", "vsh_uber-charge", client, charge);
					}

					if (charge == 100 && !(VSHFlags[client] & VSHFLAG_UBERREADY))
					{
						FakeClientCommandEx(client, "voicemenu 1 7");
						VSHFlags[client] |= VSHFLAG_UBERREADY;
					}
				}

				if (weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))
				{
					new healtarget = GetHealingTarget(client);
					if (IsValidClient(healtarget) && TF2_GetPlayerClass(healtarget) == TFClass_Scout)
					{
						TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.3);
					}
				}
			}

			if (class == TFClass_Soldier)
			{
				if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Primary) == 1104)
				{
					bHudAdjust = true;
					SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);

					if (!(GetClientButtons(client) & IN_SCORE))
					{
						ShowSyncHudText(client, jumpHUD, "Air Strike Damage: %i", AirDamage[client]);
					}
				}
			}

			if (bAlwaysShowHealth)
			{
				SetHudTextParams(-1.0, bHudAdjust?0.78:0.83, 0.35, 255, 255, 255, 255);
				if (!(GetClientButtons(client) & IN_SCORE)) ShowSyncHudText(client, healthHUD, "%t", "vsh_health", HaleHealth, HaleHealthMax);
			}

//          else if (AirBlastReload[client]>0)
//          {
//              SetHudTextParams(-1.0, 0.83, 0.15, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
//              ShowHudText(client, -1, "%t", "vsh_airblast", RoundFloat(AirBlastReload[client])+1);
//              AirBlastReload[client]-=0.2;
//          }
			if (RedAlivePlayers == 1 && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
			{
				TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.3);
				new primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
				if (class == TFClass_Engineer && weapon == primary && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false)) SetEntProp(client, Prop_Send, "m_iRevengeCrits", 3);
				TF2_AddCondition(client, TFCond_Buffed, 0.3);
				continue;
			}
			if (RedAlivePlayers == 2 && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
				TF2_AddCondition(client, TFCond_Buffed, 0.3);
			new TFCond:cond = TFCond_HalloweenCritCandy;
			if (TF2_IsPlayerInCondition(client, TFCond_CritCola) && (class == TFClass_Scout || class == TFClass_Heavy))
			{
				TF2_AddCondition(client, cond, 0.3);
				continue;
			}
			new bool:addmini = false;
			for (i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && IsPlayerAlive(i) && GetHealingTarget(i) == client)
				{
					addmini = true;
					break;
				}
			}
			new bool:addthecrit = false;
			if (validwep && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Melee))  //&& index != 4 && index != 194 && index != 225 && index != 356 && index != 461 && index != 574) addthecrit = true; //class != TFClass_Spy
			{
				//slightly longer check but makes sure that any weapon that can backstab will not crit (e.g. Saxxy)
				if (strcmp(wepclassname, "tf_weapon_knife", false) != 0 && index != 416)
					addthecrit = true;
			}
			switch (index)
			{
				case 305, 1079, 1081, 56, 16, 203, 58, 1083, 1105, 1100, 1005, 1092, 812, 833, 997, 39, 351, 740, 588, 595: //Critlist
				{
					new flindex = GetIndexOfWeaponSlot(client, TFWeaponSlot_Primary);

					if (TF2_GetPlayerClass(client) == TFClass_Pyro && flindex == 594) // No crits if using phlog
						addthecrit = false;
					else
						addthecrit = true;
				}
				case 22, 23, 160, 209, 294, 449, 773:
				{
					addthecrit = true;
					if (class == TFClass_Scout && cond == TFCond_HalloweenCritCandy) cond = TFCond_Buffed;
				}
				case 656:
				{
					addthecrit = true;
					cond = TFCond_Buffed;
				}
			}
			if (index == 16 && addthecrit && IsValidEntity(FindPlayerBack(client, { 642 }, 1)))
			{
				addthecrit = false;
			}
			if (class == TFClass_DemoMan && !IsValidEntity(GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary)))
			{
				addthecrit = true;

				if (!bDemoShieldCrits && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") != GetPlayerWeaponSlot(client, TFWeaponSlot_Melee))
				{
					cond = TFCond_Buffed;
				}
			}

/*          if (Special != VSHSpecial_HHH && index != 56 && index != 1005 && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Primary))
			{
				new meleeindex = GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee);
				new melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
				if (melee <= MaxClients || !IsValidEntity(melee) || !GetEdictClassname(melee, wepclassname, sizeof(wepclassname))) strcopy(wepclassname, sizeof(wepclassname), "");
				new meleeindex = ((strncmp(wepclassname, "tf_wea", 6, false) == 0) ? GetEntProp(melee, Prop_Send, "m_iItemDefinitionIndex") : -1);
				if (meleeindex == 232) addthecrit = false;
			}
*/
			if (addthecrit)
			{
				TF2_AddCondition(client, cond, 0.3);
				if (addmini && cond != TFCond_Buffed) TF2_AddCondition(client, TFCond_Buffed, 0.3);
			}
			if (class == TFClass_Spy && validwep && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Primary))
			{
				if (!TF2_IsPlayerCritBuffed(client) && !TF2_IsPlayerInCondition(client, TFCond_Buffed) && !TF2_IsPlayerInCondition(client, TFCond_Cloaked) && !TF2_IsPlayerInCondition(client, TFCond_Disguised) && !GetEntProp(client, Prop_Send, "m_bFeignDeathReady"))
				{
					TF2_AddCondition(client, TFCond_CritCola, 0.3);
				}
			}
			if (class == TFClass_Engineer && weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
			{
				new sentry = FindSentry(client);
				if (IsValidEntity(sentry) && GetEntPropEnt(sentry, Prop_Send, "m_hEnemy") == Hale)
				{
					SetEntProp(client, Prop_Send, "m_iRevengeCrits", 3);
					TF2_AddCondition(client, TFCond_Kritzkrieged, 0.3);
				}
				else
				{
					if (GetEntProp(client, Prop_Send, "m_iRevengeCrits")) SetEntProp(client, Prop_Send, "m_iRevengeCrits", 0);
					else if (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(client, TFCond_Healing))
					{
						TF2_RemoveCondition(client, TFCond_Kritzkrieged);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}


public Action:HaleTimer(Handle:hTimer)
{
	if (VSHRoundState == 2)
	{
		if (IsValidClient(Hale, false) && IsPlayerAlive(Hale)) TF2_AddCondition(Hale, TFCond_SpeedBuffAlly, 14.0);
		return Plugin_Stop;
	}
	if (!IsValidClient(Hale))
		return Plugin_Continue;
	if (TF2_IsPlayerInCondition(Hale, TFCond_Jarated))
		TF2_RemoveCondition(Hale, TFCond_Jarated);
	if (TF2_IsPlayerInCondition(Hale, TFCond_MarkedForDeath))
		TF2_RemoveCondition(Hale, TFCond_MarkedForDeath);
	if (TF2_IsPlayerInCondition(Hale, TFCond_Disguised))
		TF2_RemoveCondition(Hale, TFCond_Disguised);
	if (TF2_IsPlayerInCondition(Hale, TFCond:42) && TF2_IsPlayerInCondition(Hale, TFCond_Dazed))
		TF2_RemoveCondition(Hale, TFCond_Dazed);
	new Float:speed = HaleSpeed + 0.7 * (100 - HaleHealth * 100 / HaleHealthMax);
	SetEntPropFloat(Hale, Prop_Send, "m_flMaxspeed", speed);
//  SetEntProp(Hale, Prop_Data, "m_iHealth", HaleHealth);
//  SetEntProp(Hale, Prop_Send, "m_iHealth", HaleHealth);
	if (HaleHealth <= 0 && IsPlayerAlive(Hale)) HaleHealth = 1;
	SetHaleHealthFix(Hale, HaleHealth, HaleHealthMax);
	SetHudTextParams(-1.0, 0.77, 0.35, 255, 255, 255, 255);
	SetGlobalTransTarget(Hale);
	if (!(GetClientButtons(Hale) & IN_SCORE)) ShowSyncHudText(Hale, healthHUD, "%t", "vsh_health", HaleHealth, HaleHealthMax);
	if (HaleRage/RageDMG >= 1)
	{
		if (IsFakeClient(Hale) && !(VSHFlags[Hale] & VSHFLAG_BOTRAGE))
		{
			CreateTimer(1.0, Timer_BotRage, _, TIMER_FLAG_NO_MAPCHANGE);
			VSHFlags[Hale] |= VSHFLAG_BOTRAGE;
		}
		else if (!(GetClientButtons(Hale) & IN_SCORE))
		{
			SetHudTextParams(-1.0, 0.83, 0.35, 255, 64, 64, 255);
			ShowSyncHudText(Hale, rageHUD, "%t", "vsh_do_rage");
		}
	}
	else if (!(GetClientButtons(Hale) & IN_SCORE))
	{
		SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255);
		ShowSyncHudText(Hale, rageHUD, "%t", "vsh_rage_meter", HaleRage*100/RageDMG);
	}
	SetHudTextParams(-1.0, 0.88, 0.35, 255, 255, 255, 255);
	if (GlowTimer <= 0.0)
	{
		SetEntProp(Hale, Prop_Send, "m_bGlowEnabled", 0);
		GlowTimer = 0.0;
	}
	else
		GlowTimer -= 0.2;
	if (bEnableSuperDuperJump)
	{
		/*if (HaleCharge <= 0)
		{
			HaleCharge = 0;
			if (!(GetClientButtons(Hale) & IN_SCORE)) ShowSyncHudText(Hale, jumpHUD, "%t", "vsh_super_duper_jump");
		}*/
		SetHudTextParams(-1.0, 0.88, 0.35, 255, 64, 64, 255);
	}

	new buttons = GetClientButtons(Hale);
	if (((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && (HaleCharge >= 0)) // && !(buttons & IN_JUMP)
	{
		if (Special == VSHSpecial_HHH)
		{
			if (HaleCharge + 5 < HALEHHH_TELEPORTCHARGE)
				HaleCharge += 5;
			else
				HaleCharge = HALEHHH_TELEPORTCHARGE;
			if (!(GetClientButtons(Hale) & IN_SCORE))
			{
				if (bEnableSuperDuperJump)
				{
					ShowSyncHudText(Hale, jumpHUD, "%t", "vsh_super_duper_jump");
				}
				else
				{
					ShowSyncHudText(Hale, jumpHUD, "%t", "vsh_teleport_status", HaleCharge * 2);
				}
			}
		}
		else
		{
			if (HaleCharge + 5 < HALE_JUMPCHARGE)
				HaleCharge += 5;
			else
				HaleCharge = HALE_JUMPCHARGE;
			if (!(GetClientButtons(Hale) & IN_SCORE))
			{
				if (bEnableSuperDuperJump)
				{
					ShowSyncHudText(Hale, jumpHUD, "%t", "vsh_super_duper_jump");
				}
				else
				{
					ShowSyncHudText(Hale, jumpHUD, "%t", "vsh_jump_status", HaleCharge * 4);
				}

			}
		}
	}
	else if (HaleCharge < 0)
	{
		HaleCharge += 5;
		if (Special == VSHSpecial_HHH)
		{
			if (!(GetClientButtons(Hale) & IN_SCORE)) ShowSyncHudText(Hale, jumpHUD, "%t %i", "vsh_teleport_status_2", -HaleCharge/20);
		}
		else if (!(GetClientButtons(Hale) & IN_SCORE)) ShowSyncHudText(Hale, jumpHUD, "%t %i", "vsh_jump_status_2", -HaleCharge/20);
	}
	else
	{
		decl Float:ang[3];
		GetClientEyeAngles(Hale, ang);
		if ((ang[0] < -45.0) && (HaleCharge > 1))
		{
			new Action:act = Plugin_Continue;
			new bool:super = bEnableSuperDuperJump;
			Call_StartForward(OnHaleJump);
			Call_PushCellRef(super);
			Call_Finish(act);
			if (act != Plugin_Continue && act != Plugin_Changed)
				return Plugin_Continue;
			if (act == Plugin_Changed) bEnableSuperDuperJump = super;
			decl Float:pos[3];
			if (Special == VSHSpecial_HHH && (HaleCharge == HALEHHH_TELEPORTCHARGE || bEnableSuperDuperJump))
			{
				decl target;
				do
				{
					target = GetRandomInt(1, MaxClients);
				}
				while ((RedAlivePlayers > 0) && (!IsValidClient(target, false) || (target == Hale) || !IsPlayerAlive(target) || GetClientTeam(target) != OtherTeam));
				if (IsValidClient(target))
				{
					// Chdata's HHH teleport rework
					if (TF2_GetPlayerClass(target) != TFClass_Scout && TF2_GetPlayerClass(target) != TFClass_Soldier)
					{
						SetEntProp(Hale, Prop_Send, "m_CollisionGroup", 2); //Makes HHH clipping go away for player and some projectiles
						hHHHTeleTimer = CreateTimer(bEnableSuperDuperJump ? 4.0:2.0, HHHTeleTimer, TIMER_FLAG_NO_MAPCHANGE);
					}

					GetClientAbsOrigin(target, pos);
					SetEntPropFloat(Hale, Prop_Send, "m_flNextAttack", GetGameTime() + (bEnableSuperDuperJump ? 4.0 : 2.0));
					if (GetEntProp(target, Prop_Send, "m_bDucked"))
					{
						VSHFlags[Hale] |= VSHFLAG_NEEDSTODUCK;
						decl Float:collisionvec[3];
						collisionvec[0] = 24.0;
						collisionvec[1] = 24.0;
						collisionvec[2] = 62.0;
						SetEntPropVector(Hale, Prop_Send, "m_vecMaxs", collisionvec);
						SetEntProp(Hale, Prop_Send, "m_bDucked", 1);
						SetEntityFlags(Hale, GetEntityFlags(Hale)|FL_DUCKING);
						new Handle:timerpack;
						CreateDataTimer(0.2, Timer_StunHHH, timerpack, TIMER_FLAG_NO_MAPCHANGE);
						WritePackCell(timerpack, bEnableSuperDuperJump);
						WritePackCell(timerpack, GetClientUserId(target));
					}
					else TF2_StunPlayer(Hale, (bEnableSuperDuperJump ? 4.0 : 2.0), 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
					TeleportEntity(Hale, pos, NULL_VECTOR, NULL_VECTOR);
					SetEntProp(Hale, Prop_Send, "m_bGlowEnabled", 0);
					GlowTimer = 0.0;
					CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(Hale, "ghost_appearation")));
					CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(Hale, "ghost_appearation", _, false)));

					// Chdata's HHH teleport rework
					decl Float:vPos[3];
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", vPos);

					EmitSoundToClient(Hale, "misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);
					EmitSoundToClient(target, "misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);

					PrintCenterText(target, "You've been teleported to!");

					HaleCharge=-1100;
				}
				if (bEnableSuperDuperJump)
					bEnableSuperDuperJump = false;
			}
			else if (Special != VSHSpecial_HHH)
			{
				decl Float:vel[3];
				GetEntPropVector(Hale, Prop_Data, "m_vecVelocity", vel);
				if (bEnableSuperDuperJump)
				{
					vel[2]=750 + HaleCharge * 13.0 + 2000;
					bEnableSuperDuperJump = false;
				}
				else
					vel[2]=750 + HaleCharge * 13.0;
				SetEntProp(Hale, Prop_Send, "m_bJumping", 1);
				vel[0] *= (1+Sine(float(HaleCharge) * FLOAT_PI / 50));
				vel[1] *= (1+Sine(float(HaleCharge) * FLOAT_PI / 50));
				TeleportEntity(Hale, NULL_VECTOR, NULL_VECTOR, vel);
				HaleCharge=-120;
				new String:s[PLATFORM_MAX_PATH];
				switch (Special)
				{
					case VSHSpecial_Vagineer:
						Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerJump, GetRandomInt(1, 2));
					case VSHSpecial_CBS:
						strcopy(s, PLATFORM_MAX_PATH, CBSJump1);
					case VSHSpecial_Bunny:
						strcopy(s, PLATFORM_MAX_PATH, BunnyJump[GetRandomInt(0, sizeof(BunnyJump)-1)]);
					case VSHSpecial_Hale:
					{
						Format(s, PLATFORM_MAX_PATH, "%s%i.wav", GetRandomInt(0, 1) ? HaleJump : HaleJump132, GetRandomInt(1, 2));
					}
				}
				if (s[0] != '\0')
				{
					GetEntPropVector(Hale, Prop_Send, "m_vecOrigin", pos);
					EmitSoundToAll(s, Hale, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, true, 0.0);
					EmitSoundToAll(s, Hale, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, true, 0.0);
					for (new i = 1; i <= MaxClients; i++)
						if (IsValidClient(i) && (i != Hale))
						{
							EmitSoundToClient(i, s, Hale, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, true, 0.0);
							EmitSoundToClient(i, s, Hale, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, true, 0.0);
						}
				}
			}
		}
		else
			HaleCharge = 0;
	}
	if (RedAlivePlayers == 1)
	{
		switch (Special)
		{
			case VSHSpecial_Bunny:
				PrintCenterTextAll("%t", "vsh_bunny_hp", HaleHealth, HaleHealthMax);
			case VSHSpecial_Vagineer:
				PrintCenterTextAll("%t", "vsh_vagineer_hp", HaleHealth, HaleHealthMax);
			case VSHSpecial_HHH:
				PrintCenterTextAll("%t", "vsh_hhh_hp", HaleHealth, HaleHealthMax);
			case VSHSpecial_CBS:
				PrintCenterTextAll("%t", "vsh_cbs_hp", HaleHealth, HaleHealthMax);
			default:
				PrintCenterTextAll("%t", "vsh_hale_hp", HaleHealth, HaleHealthMax);
		}
	}
	if (OnlyScoutsLeft())
	{
		new Float:rage = 0.001*RageDMG;
		HaleRage += RoundToCeil(rage);
		if (HaleRage > RageDMG)
			HaleRage = RageDMG;
	}

	if (!(GetEntityFlags(Hale) & FL_ONGROUND))
	{
		WeighDownTimer += 0.2;
	}
	else
	{
		HHHClimbCount = 0;
		WeighDownTimer = 0.0;
	}

	if (WeighDownTimer >= 4.0 && buttons & IN_DUCK && GetEntityGravity(Hale) != 6.0)
	{
		decl Float:ang[3];
		GetClientEyeAngles(Hale, ang);
		if ((ang[0] > 60.0))
		{
			new Action:act = Plugin_Continue;
			Call_StartForward(OnHaleWeighdown);
			Call_Finish(act);
			if (act != Plugin_Continue)
				return Plugin_Continue;
			new Float:fVelocity[3];
			GetEntPropVector(Hale, Prop_Data, "m_vecVelocity", fVelocity);
			fVelocity[2] = -1000.0;
			TeleportEntity(Hale, NULL_VECTOR, NULL_VECTOR, fVelocity);
			SetEntityGravity(Hale, 6.0);
			CreateTimer(2.0, Timer_GravityCat, GetClientUserId(Hale), TIMER_FLAG_NO_MAPCHANGE);
			CPrintToChat(Hale, "{olive}[VSH]{default} %t", "vsh_used_weighdown");
			WeighDownTimer = 0.0;
		}
	}
	return Plugin_Continue;
}

public Action:HHHTeleTimer(Handle:timer)
{
	SetEntProp(Hale, Prop_Send, "m_CollisionGroup", 5); //Fix HHH's clipping.
	hHHHTeleTimer = INVALID_HANDLE;
}

public Action:UseRage(Handle:hTimer, any:dist)
{
	decl Float:pos[3];
	decl Float:pos2[3];
	decl i;
	decl Float:distance;
	if (!IsValidClient(Hale, false)) return Plugin_Continue;
	if (!GetEntProp(Hale, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(Hale, Prop_Send, "m_hHighFivePartner")))
	{
		TF2_RemoveCondition(Hale, TFCond_Taunting);
		MakeModelTimer(INVALID_HANDLE); // should reset Hale's animation
	}
	GetEntPropVector(Hale, Prop_Send, "m_vecOrigin", pos);
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && (i != Hale))
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (!TF2_IsPlayerInCondition(i, TFCond_Ubercharged) && distance < dist)
			{
				new flags = TF_STUNFLAGS_GHOSTSCARE;
				if (Special != VSHSpecial_HHH)
				{
					flags |= TF_STUNFLAG_NOSOUNDOREFFECT;
					CreateTimer(5.0, RemoveEnt, EntIndexToEntRef(AttachParticle(i, "yikes_fx", 75.0)));
				}
				if (VSHRoundState != 0) TF2_StunPlayer(i, 5.0, _, flags, (Special == VSHSpecial_HHH ? 0 : Hale));
			}
		}
	}
	i = -1;
	while ((i = FindEntityByClassname2(i, "obj_sentrygun")) != -1)
	{
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
		distance = GetVectorDistance(pos, pos2);
		if (dist <= RageDist/3) dist = RageDist/2;
		if (distance < dist)    //(!mode && (distance < RageDist)) || (mode && (distance < RageDist/2)))
		{
			SetEntProp(i, Prop_Send, "m_bDisabled", 1);
			AttachParticle(i, "yikes_fx", 75.0);
			if (newRageSentry)
			{
				SetVariantInt(GetEntProp(i, Prop_Send, "m_iHealth")/2);
				AcceptEntityInput(i, "RemoveHealth");
			}
			else
				SetEntProp(i, Prop_Send, "m_iHealth", GetEntProp(i, Prop_Send, "m_iHealth")/2);
			CreateTimer(8.0, EnableSG, EntIndexToEntRef(i));
		}
	}
	i = -1;
	while ((i = FindEntityByClassname2(i, "obj_dispenser")) != -1)
	{
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
		distance = GetVectorDistance(pos, pos2);
		if (dist <= RageDist/3) dist = RageDist/2;
		if (distance < dist)    //(!mode && (distance < RageDist)) || (mode && (distance < RageDist/2)))
		{
			SetVariantInt(1);
			AcceptEntityInput(i, "RemoveHealth");
		}
	}
	i = -1;
	while ((i = FindEntityByClassname2(i, "obj_teleporter")) != -1)
	{
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
		distance = GetVectorDistance(pos, pos2);
		if (dist <= RageDist/3) dist = RageDist/2;
		if (distance < dist)    //(!mode && (distance < RageDist)) || (mode && (distance < RageDist/2)))
		{
			SetVariantInt(1);
			AcceptEntityInput(i, "RemoveHealth");
		}
	}

	return Plugin_Continue;
}
public Action:UseUberRage(Handle:hTimer, any:param)
{
	if (!IsValidClient(Hale))
		return Plugin_Stop;
	if (UberRageCount == 1)
	{
		if (!GetEntProp(Hale, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(Hale, Prop_Send, "m_hHighFivePartner")))
		{
			TF2_RemoveCondition(Hale, TFCond_Taunting);
			MakeModelTimer(INVALID_HANDLE); // should reset Hale's animation
		}
//      TF2_StunPlayer(Hale, 0.0, _, TF_STUNFLAG_NOSOUNDOREFFECT);
	}
	else if (UberRageCount >= 100)
	{
		if (defaulttakedamagetype == 0) defaulttakedamagetype = 2;
		SetEntProp(Hale, Prop_Data, "m_takedamage", defaulttakedamagetype);
		defaulttakedamagetype = 0;
		TF2_RemoveCondition(Hale, TFCond_Ubercharged);
		return Plugin_Stop;
	}
	else if (UberRageCount >= 85 && !TF2_IsPlayerInCondition(Hale, TFCond_UberchargeFading))
	{
		TF2_AddCondition(Hale, TFCond_UberchargeFading, 3.0);
	}
	if (!defaulttakedamagetype)
	{
		defaulttakedamagetype = GetEntProp(Hale, Prop_Data, "m_takedamage");
		if (defaulttakedamagetype == 0) defaulttakedamagetype = 2;
	}
	SetEntProp(Hale, Prop_Data, "m_takedamage", 0);
	UberRageCount += 1.0;
	return Plugin_Continue;
}
public Action:UseBowRage(Handle:hTimer)
{
	if (!GetEntProp(Hale, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(Hale, Prop_Send, "m_hHighFivePartner")))
	{
		TF2_RemoveCondition(Hale, TFCond_Taunting);
		MakeModelTimer(INVALID_HANDLE); // should reset Hale's animation
	}
//  TF2_StunPlayer(Hale, 0.0, _, TF_STUNFLAG_NOSOUNDOREFFECT);
//  UberRageCount = 9.0;
	SetAmmo(Hale, 0, ((RedAlivePlayers >= CBS_MAX_ARROWS) ? CBS_MAX_ARROWS : RedAlivePlayers));
	return Plugin_Continue;
}

public Action:CheckAlivePlayers(Handle:hTimer)
{
	if (VSHRoundState != 1) //(VSHRoundState == 2 || VSHRoundState == -1)
	{
		return Plugin_Continue;
	}
	RedAlivePlayers = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && (GetClientTeam(i) == OtherTeam))
			RedAlivePlayers++;
	}
	if (Special == VSHSpecial_CBS && GetAmmo(Hale, 0) > RedAlivePlayers && RedAlivePlayers != 0) SetAmmo(Hale, 0, RedAlivePlayers);
	if (RedAlivePlayers == 0)
		ForceTeamWin(HaleTeam);
	else if (RedAlivePlayers == 1 && IsValidClient(Hale) && VSHRoundState == 1)
	{
		decl Float:pos[3];
		decl String:s[PLATFORM_MAX_PATH];
		GetEntPropVector(Hale, Prop_Send, "m_vecOrigin", pos);
		if (Special != VSHSpecial_HHH)
		{
			if (Special == VSHSpecial_CBS)
			{
				if (!GetRandomInt(0, 2))
					Format(s, PLATFORM_MAX_PATH, "%s", CBS0);
				else
				{
					Format(s, PLATFORM_MAX_PATH, "%s%02i.wav", CBS4, GetRandomInt(1, 25));
				}
				EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
			}
			else if (Special == VSHSpecial_Bunny)
				strcopy(s, PLATFORM_MAX_PATH, BunnyLast[GetRandomInt(0, sizeof(BunnyLast)-1)]);
			else if (Special == VSHSpecial_Vagineer)
				strcopy(s, PLATFORM_MAX_PATH, VagineerLastA);
			else
			{
				new see = GetRandomInt(0, 5);
				switch (see)
				{
					case 0: strcopy(s, PLATFORM_MAX_PATH, HaleComicArmsFallSound);
					case 1: Format(s, PLATFORM_MAX_PATH, "%s0%i.wav", HaleLastB, GetRandomInt(1, 4));
					case 2: strcopy(s, PLATFORM_MAX_PATH, HaleKillLast132);
					default: Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleLastMan, GetRandomInt(1, 5));
				}
			}
			EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, false, 0.0);
			EmitSoundToAll(s, _, SNDCHAN_ITEM, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, false, 0.0);
		}
	}

	if (!PointType && (RedAlivePlayers <= (AliveToEnable = GetConVarInt(cvarAliveToEnable))) && !PointReady)
	{
		PrintHintTextToAll("%t", "vsh_point_enable", RedAlivePlayers);
		if (RedAlivePlayers == AliveToEnable) EmitSoundToAll("vo/announcer_am_capenabled02.wav");
		else if (RedAlivePlayers < AliveToEnable)
		{
			decl String:s[PLATFORM_MAX_PATH];
			Format(s, PLATFORM_MAX_PATH, "vo/announcer_am_capincite0%i.wav", GetRandomInt(0, 1) ? 1 : 3);
			EmitSoundToAll(s);
		}
		SetControlPoint(true);
		PointReady = true;
	}
	return Plugin_Continue;
}

public Action:StartResponceTimer(Handle:hTimer)
{
	decl String:s[PLATFORM_MAX_PATH];
	decl Float:pos[3];
	switch (Special)
	{
		case VSHSpecial_Bunny:
		{
			strcopy(s, PLATFORM_MAX_PATH, BunnyStart[GetRandomInt(0, sizeof(BunnyStart)-1)]);
		}
		case VSHSpecial_Vagineer:
		{
			if (!GetRandomInt(0, 1))
				strcopy(s, PLATFORM_MAX_PATH, VagineerStart);
			else
				strcopy(s, PLATFORM_MAX_PATH, VagineerRoundStart);
		}
		case VSHSpecial_HHH: Format(s, PLATFORM_MAX_PATH, "ui/halloween_boss_summoned_fx.wav");
		case VSHSpecial_CBS: strcopy(s, PLATFORM_MAX_PATH, CBS0);
		default:
		{
			if (!GetRandomInt(0, 1))
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRoundStart, GetRandomInt(1, 5));
			else
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleStart132, GetRandomInt(1, 5));
		}
	}
	EmitSoundToAll(s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, false, 0.0);
	EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, Hale, pos, NULL_VECTOR, false, 0.0);
	if (Special == VSHSpecial_CBS)
	{
		EmitSoundToAll(s, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
		EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
	}
	return Plugin_Continue;
}

