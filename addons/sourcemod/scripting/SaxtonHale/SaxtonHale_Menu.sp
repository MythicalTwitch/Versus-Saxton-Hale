public SkipHalePanelH(Handle:menu, MenuAction:action, param1, param2)
{
	return;
}

public HintPanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if (!IsValidClient(param1)) return;
	if (action == MenuAction_Select || (action == MenuAction_Cancel && param2 == MenuCancel_Exit)) VSHFlags[param1] |= VSHFLAG_CLASSHELPED;
	return;
}

public Action:HintPanel(client)
{
	if (IsVoteInProgress())
		return Plugin_Continue;
	new Handle:panel = CreatePanel();
	decl String:s[512];
	SetGlobalTransTarget(client);
	switch (Special)
	{
		case VSHSpecial_Hale:
			Format(s, 512, "%t", "vsh_help_hale");
		case VSHSpecial_Vagineer:
			Format(s, 512, "%t", "vsh_help_vagineer");
		case VSHSpecial_HHH:
			Format(s, 512, "%t", "vsh_help_hhh");
		case VSHSpecial_CBS:
			Format(s, 512, "%t", "vsh_help_cbs");
		case VSHSpecial_Bunny:
			Format(s, 512, "%t", "vsh_help_bunny");
		case VSHSpecial_Miku:
			Format(s, 512, "%t", "vsh_help_miku");
	}
	DrawPanelText(panel, s);
	Format(s, 512, "%t", "vsh_menu_exit");
	DrawPanelItem(panel, s);
	SendPanelToClient(panel, client, HintPanelH, 9001);
	CloseHandle(panel);
	return Plugin_Continue;
}
public QueuePanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select && param2 == 10)
		TurnToZeroPanel(param1);
	return false;
}
public Action:QueuePanelCmd(client, Args)
{
	if (!IsValidClient(client)) return Plugin_Continue;
	QueuePanel(client);
	return Plugin_Handled;
}
public Action:QueuePanel(client)
{
	if (!Enabled2)
		return Plugin_Continue;
	new Handle:panel = CreatePanel();
	decl String:s[512];
	Format(s, 512, "%T", "vsh_thequeue", client);
	SetPanelTitle(panel, s);
	new bool:added[MAXPLAYERS + 1];
	new tHale = Hale;
	if (Hale >= 0) added[Hale] = true;
	if (!Enabled) DrawPanelItem(panel, "None");
	else if (IsValidClient(tHale))
	{
		Format(s, sizeof(s), "%N - %i", tHale, GetClientQueuePoints(tHale));
		DrawPanelItem(panel, s);
	}
	else DrawPanelItem(panel, "None");
	new i, pingas, bool:botadded;
	DrawPanelText(panel, "---");
	do
	{
		tHale = FindNextHale(added);
		if (IsValidClient(tHale))
		{
			if (client == tHale)
			{
				Format(s, 64, "%N - %i", tHale, GetClientQueuePoints(tHale));
				DrawPanelText(panel, s);
				i--;
			}
			else
			{
				if (IsFakeClient(tHale))
				{
					if (botadded)
					{
						added[tHale] = true;
						continue;
					}
					Format(s, 64, "BOT - %i", botqueuepoints);
					botadded = true;
				}
				else Format(s, 64, "%N - %i", tHale, GetClientQueuePoints(tHale));
				DrawPanelItem(panel, s);
			}
			added[tHale]=true;
			i++;
		}
		pingas++;
	}
	while (i < 8 && pingas < 100);
	for (; i < 8; i++)
		DrawPanelItem(panel, "");
	Format(s, 64, "%T %i (%T)", "vsh_your_points", client, GetClientQueuePoints(client), "vsh_to0", client);
	DrawPanelItem(panel, s);
	SendPanelToClient(panel, client, QueuePanelH, 9001);
	CloseHandle(panel);
	return Plugin_Continue;
}

public TurnToZeroPanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select && param2 == 1)
	{
		SetClientQueuePoints(param1, 0);
		CPrintToChat(param1, "{olive}[VSH]{default} %t", "vsh_to0_done");
		new cl = FindNextHaleEx();
		if (IsValidClient(cl)) SkipHalePanelNotify(cl);
	}
}

public Action:TurnToZeroPanel(client)
{
	if (!Enabled2)
		return Plugin_Continue;
	new Handle:panel = CreatePanel();
	decl String:s[512];
	SetGlobalTransTarget(client);
	Format(s, 512, "%t", "vsh_to0_title");
	SetPanelTitle(panel, s);
	Format(s, 512, "%t", "Yes");
	DrawPanelItem(panel, s);
	Format(s, 512, "%t", "No");
	DrawPanelItem(panel, s);
	SendPanelToClient(panel, client, TurnToZeroPanelH, 9001);
	CloseHandle(panel);
	return Plugin_Continue;
}
public HalePanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
				Command_GetHP(param1);
			case 2:
				HelpPanel(param1);
			case 3:
				HelpPanel2(param1);
			case 4:
				NewPanel(param1, maxversion);
			case 5:
				QueuePanel(param1);
			case 6:
				MusicTogglePanel(param1);
			case 7:
				VoiceTogglePanel(param1);
			case 8:
				ClasshelpinfoSetting(param1);
/*          case 9:
			{
				if (ACH_Enabled)
					FakeClientCommandEx(param1, "haleach");
				else
					return;
			}
			case 0:
			{
				if (ACH_Enabled)
					FakeClientCommandEx(param1, "haleach_stats");
				else
					return;
			}*/
			default: return;
		}
	}
}

public Action:HalePanel(client, args)
{
	if (!Enabled2 || !IsValidClient(client, false))
		return Plugin_Continue;
	new Handle:panel = CreatePanel();
	new size = 256;
	decl String:s[size];
	SetGlobalTransTarget(client);
	Format(s, size, "%t", "vsh_menu_1");
	SetPanelTitle(panel, s);
	Format(s, size, "%t", "vsh_menu_2");
	DrawPanelItem(panel, s);
	Format(s, size, "%t", "vsh_menu_3");
	DrawPanelItem(panel, s);
	Format(s, size, "%t", "vsh_menu_7");
	DrawPanelItem(panel, s);
	Format(s, size, "%t", "vsh_menu_4");
	DrawPanelItem(panel, s);
	Format(s, size, "%t", "vsh_menu_5");
	DrawPanelItem(panel, s);
	Format(s, size, "%t", "vsh_menu_8");
	DrawPanelItem(panel, s);
	Format(s, size, "%t", "vsh_menu_9");
	DrawPanelItem(panel, s);
	Format(s, size, "%t", "vsh_menu_9a");
	DrawPanelItem(panel, s);
/*  if (ACH_Enabled)
	{
		Format(s, size, "%t", "vsh_menu_10");
		DrawPanelItem(panel, s);
		Format(s, size, "%t", "vsh_menu_11");
		DrawPanelItem(panel, s);
	}*/
	Format(s, size, "%t", "vsh_menu_exit");
	DrawPanelItem(panel, s);
	SendPanelToClient(panel, client, HalePanelH, 9001);
	CloseHandle(panel);
	return Plugin_Handled;
}
public NewPanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 1:
			{
				if (curHelp[param1] <= 0)
					NewPanel(param1, 0);
				else
					NewPanel(param1, --curHelp[param1]);
			}
			case 2:
			{
				if (curHelp[param1] >= maxversion)
					NewPanel(param1, maxversion);
				else
					NewPanel(param1, ++curHelp[param1]);
			}
			default: return;
		}
	}
}

public HelpPanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		return;
	}
}

public Action:HelpPanel(client)
{
	if (!Enabled2 || IsVoteInProgress())
		return Plugin_Continue;
	new Handle:panel = CreatePanel();
	decl String:s[512];
	SetGlobalTransTarget(client);
	Format(s, 512, "%t", "vsh_help_mode");
	DrawPanelItem(panel, s);
	Format(s, 512, "%t", "vsh_menu_exit");
	DrawPanelItem(panel, s);
	SendPanelToClient(panel, client, HelpPanelH, 9001);
	CloseHandle(panel);
	return Plugin_Continue;
}

public Action:HelpPanel2(client)
{
	if (!Enabled2 || IsVoteInProgress())
		return Plugin_Continue;
	decl String:s[512];
	new TFClassType:class = TF2_GetPlayerClass(client);
	SetGlobalTransTarget(client);
	switch (class)
	{
		case TFClass_Scout:
			Format(s, 512, "%t", "vsh_help_scout");
		case TFClass_Soldier:
			Format(s, 512, "%t", "vsh_help_soldier");
		case TFClass_Pyro:
			Format(s, 512, "%t", "vsh_help_pyro");
		case TFClass_DemoMan:
			Format(s, 512, "%t", "vsh_help_demo");
		case TFClass_Heavy:
			Format(s, 512, "%t", "vsh_help_heavy");
		case TFClass_Engineer:
			Format(s, 512, "%t", "vsh_help_eggineer");
		case TFClass_Medic:
			Format(s, 512, "%t", "vsh_help_medic");
		case TFClass_Sniper:
			Format(s, 512, "%t", "vsh_help_sniper");
		case TFClass_Spy:
			Format(s, 512, "%t", "vsh_help_spie");
		default:
			Format(s, 512, "");
	}
	new Handle:panel = CreatePanel();
	if (class != TFClass_Sniper)
		Format(s, 512, "%t\n%s", "vsh_help_melee", s);
	SetPanelTitle(panel, s);
	DrawPanelItem(panel, "Exit");
	SendPanelToClient(panel, client, HintPanelH, 12);
	CloseHandle(panel);
	return Plugin_Continue;
}

public Action:ClasshelpinfoSetting(client)
{
	if (!Enabled2)
		return Plugin_Continue;
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Turn the VS Saxton Hale class info...");
	DrawPanelItem(panel, "On");
	DrawPanelItem(panel, "Off");
	SendPanelToClient(panel, client, ClasshelpinfoTogglePanelH, 9001);
	CloseHandle(panel);
	return Plugin_Handled;
}

public ClasshelpinfoTogglePanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if (IsValidClient(param1))
	{
		if (action == MenuAction_Select)
		{
			if (param2 == 2)
				SetClientCookie(param1, ClasshelpinfoCookie, "0");
			else
				SetClientCookie(param1, ClasshelpinfoCookie, "1");
			CPrintToChat(param1, "{olive}[VSH]{default} %t", "vsh_classinfo", param2 == 2 ? "off" : "on");
		}
	}
}
/*public HelpPanelH1(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 1)
			HelpPanel(param1);
		else if (param2 == 2)
			return;
	}
}
public Action:HelpPanel1(client, Args)
{
	if (!Enabled2)
		return Plugin_Continue;
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Hale is unusually strong.\nBut he doesn't use weapons, because\nhe believes that problems should be\nsolved with bare hands.");
	DrawPanelItem(panel, "Back");
	DrawPanelItem(panel, "Exit");
	SendPanelToClient(panel, client, HelpPanelH1, 9001);
	CloseHandle(panel);
	return Plugin_Continue;
}*/

public Action:MusicTogglePanel(client)
{
	if (!Enabled2 || !IsValidClient(client))
		return Plugin_Continue;
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Turn the VS Saxton Hale music...");
	DrawPanelItem(panel, "On");
	DrawPanelItem(panel, "Off");
	SendPanelToClient(panel, client, MusicTogglePanelH, 9001);
	CloseHandle(panel);
	return Plugin_Continue;
}
public MusicTogglePanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if (IsValidClient(param1))
	{
		if (action == MenuAction_Select)
		{
			if (param2 == 2)
			{
				SetClientSoundOptions(param1, SOUNDEXCEPT_MUSIC, false);
				StopHaleMusic(param1);
			}
			else
				SetClientSoundOptions(param1, SOUNDEXCEPT_MUSIC, true);
			CPrintToChat(param1, "{olive}[VSH]{default} %t", "vsh_music", param2 == 2 ? "off" : "on");
		}
	}
}

public Action:VoiceTogglePanel(client)
{
	if (!Enabled2 || !IsValidClient(client))
		return Plugin_Continue;
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Turn the VS Saxton Hale voices...");
	DrawPanelItem(panel, "On");
	DrawPanelItem(panel, "Off");
	SendPanelToClient(panel, client, VoiceTogglePanelH, 9001);
	CloseHandle(panel);
	return Plugin_Continue;
}
public VoiceTogglePanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if (IsValidClient(param1))
	{
		if (action == MenuAction_Select)
		{
			if (param2 == 2)
				SetClientSoundOptions(param1, SOUNDEXCEPT_VOICE, false);
			else
				SetClientSoundOptions(param1, SOUNDEXCEPT_VOICE, true);
			CPrintToChat(param1, "{olive}[VSH]{default} %t", "vsh_voice", param2 == 2 ? "off" : "on");
			if (param2 == 2) CPrintToChat(param1, "%t", "vsh_voice2");
		}
	}
}

public Action:NewPanel(client, versionindex)
{
	if (!Enabled2)
		return Plugin_Continue;
	curHelp[client] = versionindex;
	new Handle:panel = CreatePanel();
	decl String:s[90];
	SetGlobalTransTarget(client);
	Format(s, 90, "=%t%s:=", "vsh_whatsnew", haleversiontitles[versionindex]);
	SetPanelTitle(panel, s);
	FindVersionData(panel, versionindex);

	if (versionindex > 0)
	{
		if (strcmp(haleversiontitles[versionindex], haleversiontitles[versionindex-1], false) == 0)
		{
			Format(s, 90, "Next Page");
		}
		else
		{
			Format(s, 90, "Older v%s", haleversiontitles[versionindex-1]);
		}
		DrawPanelItem(panel, s);
	}
	else
	{
		Format(s, 90, "%t", "vsh_noolder");
		DrawPanelItem(panel, s, ITEMDRAW_DISABLED);
	}

	if (versionindex < maxversion)
	{
		if (strcmp(haleversiontitles[versionindex], haleversiontitles[versionindex+1], false) == 0)
		{
			Format(s, 90, "Prev Page");
		}
		else
		{
			Format(s, 90, "Newer v%s", haleversiontitles[versionindex+1]);
		}
		DrawPanelItem(panel, s);
	}
	else
	{
		Format(s, 90, "%t", "vsh_nonewer");
		DrawPanelItem(panel, s, ITEMDRAW_DISABLED);
	}

	Format(s, 512, "%t", "vsh_menu_exit");
	DrawPanelItem(panel, s);

	SendPanelToClient(panel, client, NewPanelH, 9001);
	CloseHandle(panel);
	return Plugin_Continue;
}


