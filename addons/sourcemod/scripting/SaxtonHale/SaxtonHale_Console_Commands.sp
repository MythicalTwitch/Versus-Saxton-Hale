public Load_RegConsoleCmd()
{
	//RegConsoleCmd("sm_hale", HalePanel);
	//RegConsoleCmd("sm_hale_hp", Command_GetHPCmd);
	//RegConsoleCmd("sm_halehp", Command_GetHPCmd);
	//RegConsoleCmd("sm_hale_next", QueuePanelCmd);
	//RegConsoleCmd("sm_halenext", QueuePanelCmd);
	//RegConsoleCmd("sm_hale_help", HelpPanelCmd);
	//RegConsoleCmd("sm_halehelp", HelpPanelCmd);
	//RegConsoleCmd("sm_hale_class", HelpPanel2Cmd);
	//RegConsoleCmd("sm_haleclass", HelpPanel2Cmd);
	//RegConsoleCmd("sm_hale_classinfotoggle", ClasshelpinfoCmd);
	//RegConsoleCmd("sm_haleclassinfotoggle", ClasshelpinfoCmd);
	//RegConsoleCmd("sm_infotoggle", ClasshelpinfoCmd);
	//RegConsoleCmd("sm_hale_new", NewPanelCmd);
	//RegConsoleCmd("sm_halenew", NewPanelCmd);
//  RegConsoleCmd("hale_me", SkipHalePanelCmd);
//  RegConsoleCmd("haleme", SkipHalePanelCmd);
	//RegConsoleCmd("sm_halemusic", MusicTogglePanelCmd);
	//RegConsoleCmd("sm_hale_music", MusicTogglePanelCmd);
	//RegConsoleCmd("sm_halevoice", VoiceTogglePanelCmd);
	//RegConsoleCmd("sm_hale_voice", VoiceTogglePanelCmd);

	// see: SaxtonHale_CommandHook.sp
	RegConsoleCmd("say",SaxtonHale_SayCommand);
	RegConsoleCmd("say_team",SaxtonHale_TeamSayCommand);
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

	if (args < 1)
	{
		ReplyToCommand(client, "[VSH] Usage: hale_special <hal, vag, hhh, chris>");
		return Plugin_Handled;
	}
	GetCmdArgString(arg, sizeof(arg));

	decl String:szName[32];

	Incoming = -1;

	for(new i = 0; i < GetArraySize(g_hHaleName); i++)
	{
		GetArrayString(g_hHaleName, i, szName, sizeof(szName));
		if(StrContains(szName, arg) != -1)
		{
			Incoming = i;
			strcopy(STRING(name), szName);

			break;
		}
	}

	if(Incoming==-1)
	{
		ReplyToCommand(client, "Could not find %s", name);
	}
	else
	{
		ReplyToCommand(client, "[VSH] Set the next Special to %s", name);
	}
	return Plugin_Handled;
}

public Action:Command_NextHale(client, args)
{
	if (Enabled)
		CreateTimer(0.2, MessageTimer);
	return Plugin_Continue;
}

public Action:DoSuicide(client, const String:command[], argc)
{
	if (Enabled && (VSHRoundState == ROUNDSTATE_EVENT_ROUND_START || VSHRoundState == ROUNDSTATE_START_ROUND_TIMER))
	{
		if (client == Hale && bTenSecStart[0])
		{
			CPrintToChat(client, "Do not suicide as Hale. Use !resetq instead.");
			return Plugin_Handled;
			//KickClient(client, "Next time, please remember to !hale_resetq");
			//if (VSHRoundState == ROUNDSTATE_EVENT_ROUND_START) return Plugin_Handled;
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

public Command_GetHP(client)
{
	if (!Enabled || VSHRoundState != ROUNDSTATE_START_ROUND_TIMER)
		return;
	if (client == Hale)
	{
		decl String:szHaleShortName[32],String:szBuffer[128];
		GetHaleShortName(HaleRaceID,STRING(szHaleShortName));
		Format(STRING(szBuffer), "vsh_%s_show_hp",szHaleShortName);

		PrintCenterTextAll("%t", szBuffer, HaleHealth, HaleHealthMax);
/*
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
		}*/
		HaleHealthLast = HaleHealth;
		return;
	}
	if (GetGameTime() >= HPTime)
	{
		healthcheckused++;

		decl String:szHaleShortName[32],String:szBuffer[128];
		GetHaleShortName(HaleRaceID,STRING(szHaleShortName));
		Format(STRING(szBuffer), "vsh_%s_hp",szHaleShortName);


		PrintCenterTextAll("%t", szBuffer, HaleHealth, HaleHealthMax);
		CPrintToChatAll("{olive}[VSH]{default} %t", szBuffer, HaleHealth, HaleHealthMax);
/*
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
		}*/
		HaleHealthLast = HaleHealth;
		HPTime = GetGameTime() + (healthcheckused < 3 ? 20.0 : 80.0);
	}
	else if (RedAlivePlayers == 1)
	{
		CPrintToChat(client, "{olive}[VSH]{default} %t", "vsh_already_see");
	}
	else
	{
		CPrintToChat(client, "{olive}[VSH]{default} %t", "vsh_wait_hp", RoundFloat(HPTime-GetGameTime()), HaleHealthLast);
	}
	return;
}

public Action:Destroy(client, const String:command[], argc)
{
	if (!Enabled || client == Hale)
		return Plugin_Continue;
	if (IsValidClient(client) && TF2_GetPlayerClass(client) == TFClass_Engineer && TF2_IsPlayerInCondition(client, TFCond_Taunting) && GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 589)
		return Plugin_Handled;
	return Plugin_Continue;
}

