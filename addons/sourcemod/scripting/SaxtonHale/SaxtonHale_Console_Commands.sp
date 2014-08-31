public Load_RegConsoleCmd()
{
	RegConsoleCmd("sm_hale", HalePanel);
	RegConsoleCmd("sm_hale_hp", Command_GetHPCmd);
	RegConsoleCmd("sm_halehp", Command_GetHPCmd);
	RegConsoleCmd("sm_hale_next", QueuePanelCmd);
	RegConsoleCmd("sm_halenext", QueuePanelCmd);
	RegConsoleCmd("sm_hale_help", HelpPanelCmd);
	RegConsoleCmd("sm_halehelp", HelpPanelCmd);
	RegConsoleCmd("sm_hale_class", HelpPanel2Cmd);
	RegConsoleCmd("sm_haleclass", HelpPanel2Cmd);
	RegConsoleCmd("sm_hale_classinfotoggle", ClasshelpinfoCmd);
	RegConsoleCmd("sm_haleclassinfotoggle", ClasshelpinfoCmd);
	RegConsoleCmd("sm_infotoggle", ClasshelpinfoCmd);
	RegConsoleCmd("sm_hale_new", NewPanelCmd);
	RegConsoleCmd("sm_halenew", NewPanelCmd);
//  RegConsoleCmd("hale_me", SkipHalePanelCmd);
//  RegConsoleCmd("haleme", SkipHalePanelCmd);
	RegConsoleCmd("sm_halemusic", MusicTogglePanelCmd);
	RegConsoleCmd("sm_hale_music", MusicTogglePanelCmd);
	RegConsoleCmd("sm_halevoice", VoiceTogglePanelCmd);
	RegConsoleCmd("sm_hale_voice", VoiceTogglePanelCmd);
}

public Load_RegAdminCmd()
{
	RegAdminCmd("sm_hale_resetqueuepoints", ResetQueuePointsCmd, 0);
	RegAdminCmd("sm_hale_resetq", ResetQueuePointsCmd, 0);
	RegAdminCmd("sm_halereset", ResetQueuePointsCmd, 0);
	RegAdminCmd("sm_resetq", ResetQueuePointsCmd, 0);
	RegAdminCmd("sm_hale_special", Command_MakeNextSpecial, 0, "Call a special to next round.");

	RegAdminCmd("sm_hale_select", Command_HaleSelect, ADMFLAG_CHEATS, "hale_select <target> - Select a player to be next boss");
	//RegAdminCmd("sm_hale_special", Command_MakeNextSpecial, ADMFLAG_CHEATS, "Call a special to next round.");
	RegAdminCmd("sm_hale_addpoints", Command_Points, ADMFLAG_CHEATS, "hale_addpoints <target> <points> - Add queue points to user.");
	RegAdminCmd("sm_hale_point_enable", Command_Point_Enable, ADMFLAG_CHEATS, "Enable CP. Only with hale_point_type = 0");
	RegAdminCmd("sm_hale_point_disable", Command_Point_Disable, ADMFLAG_CHEATS, "Disable CP. Only with hale_point_type = 0");
	RegAdminCmd("sm_hale_stop_music", Command_StopMusic, ADMFLAG_CHEATS, "Stop any currently playing Boss music.");
}

public Load_AddCommandListener()
{
	AddCommandListener(DoTaunt, "taunt");
	AddCommandListener(DoTaunt, "+taunt");
	AddCommandListener(cdVoiceMenu, "voicemenu");
	AddCommandListener(DoSuicide, "explode");
	AddCommandListener(DoSuicide, "kill");
	AddCommandListener(DoSuicide2, "jointeam");
	AddCommandListener(Destroy, "destroy");
}

public Action:ResetQueuePointsCmd(client, args)
{
	if (!Enabled2)
		return Plugin_Continue;
	if (!IsValidClient(client))
		return Plugin_Continue;
	if (GetCmdReplySource() == SM_REPLY_TO_CHAT)
		TurnToZeroPanel(client);
	else
		TurnToZeroPanelH(INVALID_HANDLE, MenuAction_Select, client, 1);
	return Plugin_Handled;
}

public Action:NewPanelCmd(client, args)
{
	if (!IsValidClient(client)) return Plugin_Continue;
	NewPanel(client, maxversion);
	return Plugin_Handled;
}

public Action:HelpPanelCmd(client, args)
{
	if (!IsValidClient(client)) return Plugin_Continue;
	HelpPanel(client);
	return Plugin_Handled;
}

public Action:HelpPanel2Cmd(client, args)
{
	if (!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	if (client == Hale)
	{
		HintPanel(Hale);
	}
	else
	{
		HelpPanel2(client);
	}

	return Plugin_Handled;
}

public Action:ClasshelpinfoCmd(client, args)
{
	if (!IsValidClient(client)) return Plugin_Continue;
	ClasshelpinfoSetting(client);
	return Plugin_Handled;
}

public Action:MusicTogglePanelCmd(client, args)
{
	if (!IsValidClient(client)) return Plugin_Continue;
	MusicTogglePanel(client);
	return Plugin_Handled;
}

public Action:VoiceTogglePanelCmd(client, args)
{
	if (!IsValidClient(client)) return Plugin_Continue;
	VoiceTogglePanel(client);
	return Plugin_Handled;
}

public Action:Command_GetHPCmd(client, args)
{
	if (!IsValidClient(client)) return Plugin_Continue;
	Command_GetHP(client);
	return Plugin_Handled;
}

public Action:Command_HaleSelect(client, args)
{
	if (!Enabled2)
		return Plugin_Continue;
	if (args < 1)
	{
		ReplyToCommand(client, "[VSH] Usage: hale_select <target> [\"hidden\"]");
		return Plugin_Handled;
	}
	decl String:s2[80];
	decl String:targetname[32];
	GetCmdArg(1, targetname, sizeof(targetname));
	GetCmdArg(2, s2, sizeof(s2));
	if (strcmp(targetname, "@me", false) == 0 && IsValidClient(client))
		ForceHale(client, client, StrContains(s2, "hidden", false) > 0);
	else
	{
		new target = FindTarget(client, targetname);
		if (IsValidClient(target))
		{
			ForceHale(client, target, StrContains(s2, "hidden", false) >= 0);
		}
	}
	return Plugin_Handled;
}
public Action:Command_Points(client, args)
{
	if (!Enabled2)
		return Plugin_Continue;
	if (args != 2)
	{
		ReplyToCommand(client, "[VSH] Usage: hale_addpoints <target> <points>");
		return Plugin_Handled;
	}
	decl String:s2[80];
	decl String:targetname[PLATFORM_MAX_PATH];
	GetCmdArg(1, targetname, sizeof(targetname));
	GetCmdArg(2, s2, sizeof(s2));
	new points = StringToInt(s2);
	/**
	 * target_name - stores the noun identifying the target(s)
	 * target_list - array to store clients
	 * target_count - variable to store number of clients
	 * tn_is_ml - stores whether the noun must be translated
	 */
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
	if ((target_count = ProcessTargetString(
			targetname,
			client,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetClientQueuePoints(target_list[i], GetClientQueuePoints(target_list[i])+points);
		LogAction(client, target_list[i], "\"%L\" added %d VSH queue points to \"%L\"", client, points, target_list[i]);
	}
	ReplyToCommand(client, "[VSH] Added %d queue points to %s", points, target_name);
	return Plugin_Handled;
}

public Action:Command_StopMusic(client, args)
{
	if (!Enabled2)
		return Plugin_Continue;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		StopHaleMusic(i);
	}
	ReplyToCommand(client, "[VSH] Stopped boss music.");
	return Plugin_Handled;
}

public Action:Command_Point_Disable(client, args)
{
	if (Enabled) SetControlPoint(false);
	return Plugin_Handled;
}

public Action:Command_Point_Enable(client, args)
{
	if (Enabled) SetControlPoint(true);
	return Plugin_Handled;
}

public Action:Command_MakeNextSpecial(client, args)
{
	if (!CheckCommandAccess(client, "sm_hale_special", ADMFLAG_CHEATS, true))
	{
		ReplyToCommand(client, "[SM] You do not have access to this command.");
		return Plugin_Handled;
	}

	decl String:arg[32];
	decl String:name[64];
	if (!bSpecials)
	{
		ReplyToCommand(client, "[VSH] This server isn't set up to use special bosses! Set the cvar hale_specials 1 in the VSH config to enable on next map!");
		return Plugin_Handled;
	}
	if (args < 1)
	{
		ReplyToCommand(client, "[VSH] Usage: hale_special <hale, vagineer, hhh, christian>");
		return Plugin_Handled;
	}
	GetCmdArgString(arg, sizeof(arg));
	if (StrContains(arg, "hal", false) != -1)
	{
		Incoming = VSHSpecial_Hale;
		name = "Saxton Hale";
	}
	else if (StrContains(arg, "vag", false) != -1)
	{
		Incoming = VSHSpecial_Vagineer;
		name = "the Vagineer";
	}
	else if (StrContains(arg, "hhh", false) != -1)
	{
		Incoming = VSHSpecial_HHH;
		name = "the Horseless Headless Horsemann Jr.";
	}
	else if (StrContains(arg, "chr", false) != -1 || StrContains(arg, "cbs", false) != -1)
	{
		Incoming = VSHSpecial_CBS;
		name = "the Christian Brutal Sniper";
	}
#if defined EASTER_BUNNY_ON
	else if (StrContains(arg, "bun", false) != -1 || StrContains(arg, "eas", false) != -1)
	{
		Incoming = VSHSpecial_Bunny;
		name = "the Easter Bunny";
	}
#endif
#if defined MIKU_ON
	else if (StrContains(arg, "mik", false) != -1 || StrContains(arg, "miku", false) != -1)
	{
		Incoming = VSHSpecial_Miku;
		name = "the Hatsunemiku";
	}
#endif
	else
	{
		ReplyToCommand(client, "[VSH] Usage: hale_special <hale, vagineer, hhh, christian>");
		return Plugin_Handled;
	}
	ReplyToCommand(client, "[VSH] Set the next Special to %s", name);
	return Plugin_Handled;
}

public Action:Command_NextHale(client, args)
{
	if (Enabled)
		CreateTimer(0.2, MessageTimer);
	return Plugin_Continue;
}

/*
 Call medic to rage update by Chdata

*/
public Action:cdVoiceMenu(iClient, const String:sCommand[], iArgc)
{
	if (iArgc < 2) return Plugin_Handled;

	decl String:sCmd1[8], String:sCmd2[8];

	GetCmdArg(1, sCmd1, sizeof(sCmd1));
	GetCmdArg(2, sCmd2, sizeof(sCmd2));

	// Capture call for medic commands (represented by "voicemenu 0 0")

	if (sCmd1[0] == '0' && sCmd2[0] == '0' && IsPlayerAlive(iClient) && iClient == Hale)
	{
		if (HaleRage / RageDMG >= 1)
		{
			DoTaunt(iClient, "", 0);
			return Plugin_Handled;
		}
	}

	return (iClient == Hale && Special != VSHSpecial_CBS && Special != VSHSpecial_Bunny && Special != VSHSpecial_Miku) ? Plugin_Handled : Plugin_Continue;
}

public Action:DoTaunt(client, const String:command[], argc)
{
	if (!Enabled || (client != Hale))
		return Plugin_Continue;

	if (bNoTaunt) // Prevent double-tap rages
	{
		return Plugin_Handled;
	}

	decl String:s[PLATFORM_MAX_PATH];
	if (HaleRage/RageDMG >= 1)
	{
		decl Float:pos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		pos[2] += 20.0;
		new Action:act = Plugin_Continue;
		Call_StartForward(OnHaleRage);
		new Float:dist;
		new Float:newdist;
		switch (Special)
		{
			case VSHSpecial_Vagineer: dist = RageDist/(1.5);
			case VSHSpecial_Bunny: dist = RageDist/(1.5);
			case VSHSpecial_Miku: dist = RageDist*1.5;
			case VSHSpecial_CBS: dist = RageDist/(2.5);
			default: dist = RageDist;
		}
		newdist = dist;
		Call_PushFloatRef(newdist);
		Call_Finish(act);
		if (act != Plugin_Continue && act != Plugin_Changed)
			return Plugin_Continue;
		if (act == Plugin_Changed) dist = newdist;
		TF2_AddCondition(Hale, TFCond:42, 4.0);
		switch (Special)
		{
			case VSHSpecial_Vagineer:
			{
				if (GetRandomInt(0, 2))
					strcopy(s, PLATFORM_MAX_PATH, VagineerRageSound);
				else
					Format(s, PLATFORM_MAX_PATH, "%s%i.wav", VagineerRageSound2, GetRandomInt(1, 2));
				TF2_AddCondition(Hale, TFCond_Ubercharged, 99.0);
				UberRageCount = 0.0;

				CreateTimer(0.6, UseRage, dist);
				CreateTimer(0.1, UseUberRage, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
			case VSHSpecial_HHH:
			{
				Format(s, PLATFORM_MAX_PATH, "%s", HHHRage2);
				CreateTimer(0.6, UseRage, dist);
			}
			case VSHSpecial_Bunny:
			{
				strcopy(s, PLATFORM_MAX_PATH, BunnyRage[GetRandomInt(1, sizeof(BunnyRage)-1)]);
				EmitSoundToAll(s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				new weapon = SpawnWeapon(client, "tf_weapon_grenadelauncher", 19, 100, 5, "1 ; 0.6 ; 6 ; 0.1 ; 411 ; 150.0 ; 413 ; 1.0 ; 37 ; 0.0 ; 280 ; 17 ; 477 ; 1.0 ; 467 ; 1.0 ; 181 ; 2.0 ; 252 ; 0.7");
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
				SetEntProp(weapon, Prop_Send, "m_iClip1", 50);
//              new vm = CreateVM(client, ReloadEggModel);
//              SetEntPropEnt(vm, Prop_Send, "m_hWeaponAssociatedWith", weapon);
//              SetEntPropEnt(weapon, Prop_Send, "m_hExtraWearableViewModel", vm);
				SetAmmo(client, TFWeaponSlot_Primary, 0);
				//add charging?
				CreateTimer(0.6, UseRage, dist);
			}
#if defined MIKU_ON
			case VSHSpecial_Miku:
			{
				strcopy(s, PLATFORM_MAX_PATH, MikuRage[GetRandomInt(1, sizeof(MikuRage)-1)]);
				EmitSoundToAll(s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
				//TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				//new weapon = SpawnWeapon(client, "tf_weapon_grenadelauncher", 19, 100, 5, "1 ; 0.6 ; 6 ; 0.1 ; 411 ; 150.0 ; 413 ; 1.0 ; 37 ; 0.0 ; 280 ; 17 ; 477 ; 1.0 ; 467 ; 1.0 ; 181 ; 2.0 ; 252 ; 0.7");
				//SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
				//SetEntProp(weapon, Prop_Send, "m_iClip1", 50);
//              new vm = CreateVM(client, ReloadEggModel);
//              SetEntPropEnt(vm, Prop_Send, "m_hWeaponAssociatedWith", weapon);
//              SetEntPropEnt(weapon, Prop_Send, "m_hExtraWearableViewModel", vm);
				//SetAmmo(client, TFWeaponSlot_Primary, 0);
				//add charging?
				VSHSpecial_Miku_Rage=true;
				CreateTimer(10.0, EndMikuRage);
				CreateTimer(0.6, UseRage, dist);
			}
#endif
			case VSHSpecial_CBS:
			{
				if (GetRandomInt(0, 1))
					Format(s, PLATFORM_MAX_PATH, "%s", CBS1);
				else
					Format(s, PLATFORM_MAX_PATH, "%s", CBS3);
				EmitSoundToAll(s, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, pos, NULL_VECTOR, false, 0.0);
				TF2_RemoveWeaponSlot2(client, TFWeaponSlot_Primary);
				SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", SpawnWeapon(client, "tf_weapon_compound_bow", 1005, 100, 5, "2 ; 2.1 ; 6 ; 0.5 ; 37 ; 0.0 ; 280 ; 19 ; 551 ; 1"));
				SetAmmo(client, TFWeaponSlot_Primary, ((RedAlivePlayers >= CBS_MAX_ARROWS) ? CBS_MAX_ARROWS : RedAlivePlayers));
				CreateTimer(0.6, UseRage, dist);
				CreateTimer(0.1, UseBowRage);
			}
			default:
			{
				Format(s, PLATFORM_MAX_PATH, "%s%i.wav", HaleRageSound, GetRandomInt(1, 4));
				CreateTimer(0.6, UseRage, dist);
			}
		}
		EmitSoundToAll(s, client, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, true, 0.0);
		EmitSoundToAll(s, client, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, true, 0.0);
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && i != Hale)
			{
				EmitSoundToClient(i, s, client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, true, 0.0);
				EmitSoundToClient(i, s, client, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, client, pos, NULL_VECTOR, true, 0.0);
			}
		}
		HaleRage = 0;
		VSHFlags[Hale] &= ~VSHFLAG_BOTRAGE;
	}

	bNoTaunt = true;
	CreateTimer(1.5, Timer_NoTaunting, _, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

public Action:DoSuicide(client, const String:command[], argc)
{
	if (Enabled && (VSHRoundState == 0 || VSHRoundState == 1))
	{
		if (client == Hale && bTenSecStart[0])
		{
			CPrintToChat(client, "Do not suicide as Hale. Use !resetq instead.");
			return Plugin_Handled;
			//KickClient(client, "Next time, please remember to !hale_resetq");
			//if (VSHRoundState == 0) return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:DoSuicide2(client, const String:command[], argc)
{
	if (Enabled && client == Hale && bTenSecStart[0])
	{
		CPrintToChat(client, "You can't change teams this early.");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_GetHP(client)
{
	if (!Enabled || VSHRoundState != 1)
		return Plugin_Continue;
	if (client == Hale)
	{
		switch (Special)
		{
#if defined MIKU_ON
			case VSHSpecial_Miku:
				PrintCenterTextAll("%t", "vsh_miku_show_hp", HaleHealth, HaleHealthMax);
#endif
			case VSHSpecial_Bunny:
				PrintCenterTextAll("%t", "vsh_bunny_show_hp", HaleHealth, HaleHealthMax);
			case VSHSpecial_Vagineer:
				PrintCenterTextAll("%t", "vsh_vagineer_show_hp", HaleHealth, HaleHealthMax);
			case VSHSpecial_HHH:
				PrintCenterTextAll("%t", "vsh_hhh_show_hp", HaleHealth, HaleHealthMax);
			case VSHSpecial_CBS:
				PrintCenterTextAll("%t", "vsh_cbs_show_hp", HaleHealth, HaleHealthMax);
			default:
				PrintCenterTextAll("%t", "vsh_hale_show_hp", HaleHealth, HaleHealthMax);
		}
		HaleHealthLast = HaleHealth;
		return Plugin_Continue;
	}
	if (GetGameTime() >= HPTime)
	{
		healthcheckused++;
		switch (Special)
		{
#if defined MIKU_ON
			case VSHSpecial_Miku:
			{
				PrintCenterTextAll("%t", "vsh_miku_hp", HaleHealth, HaleHealthMax);
				CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_miku_hp", HaleHealth, HaleHealthMax);
			}
#endif
			case VSHSpecial_Bunny:
			{
				PrintCenterTextAll("%t", "vsh_bunny_hp", HaleHealth, HaleHealthMax);
				CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_bunny_hp", HaleHealth, HaleHealthMax);
			}
			case VSHSpecial_Vagineer:
			{
				PrintCenterTextAll("%t", "vsh_vagineer_hp", HaleHealth, HaleHealthMax);
				CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_vagineer_hp", HaleHealth, HaleHealthMax);
			}
			case VSHSpecial_HHH:
			{
				PrintCenterTextAll("%t", "vsh_hhh_hp", HaleHealth, HaleHealthMax);
				CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_hhh_hp", HaleHealth, HaleHealthMax);
			}
			case VSHSpecial_CBS:
			{
				PrintCenterTextAll("%t", "vsh_cbs_hp", HaleHealth, HaleHealthMax);
				CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_cbs_hp", HaleHealth, HaleHealthMax);
			}
			default:
			{
				PrintCenterTextAll("%t", "vsh_hale_hp", HaleHealth, HaleHealthMax);
				CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_hale_hp", HaleHealth, HaleHealthMax);
			}
		}
		HaleHealthLast = HaleHealth;
		HPTime = GetGameTime() + (healthcheckused < 3 ? 20.0 : 80.0);
	}
	else if (RedAlivePlayers == 1)
		CPrintToChat(client, "{olive}[VSH]{default} %t", "vsh_already_see");
	else
		CPrintToChat(client, "{olive}[VSH]{default} %t", "vsh_wait_hp", RoundFloat(HPTime-GetGameTime()), HaleHealthLast);
	return Plugin_Continue;
}

public Action:Destroy(client, const String:command[], argc)
{
	if (!Enabled || client == Hale)
		return Plugin_Continue;
	if (IsValidClient(client) && TF2_GetPlayerClass(client) == TFClass_Engineer && TF2_IsPlayerInCondition(client, TFCond_Taunting) && GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 589)
		return Plugin_Handled;
	return Plugin_Continue;
}

