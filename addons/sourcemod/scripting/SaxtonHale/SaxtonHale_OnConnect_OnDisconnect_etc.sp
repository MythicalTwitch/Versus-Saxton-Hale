public OnClientPutInServer(client)
{
	VSHFlags[client] = 0;
//  MusicDisabled[client] = false;
//  VoiceDisabled[client] = false;
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	//SDKHook(client, SDKHook_TraceAttack,  SDK_Forwarded_TraceAttack);
	//bSkipNextHale[client] = false;
	Damage[client] = 0;
	AirDamage[client] = 0;
	uberTarget[client] = -1;
}


public OnClientDisconnect(client)
{
	Damage[client] = 0;
	AirDamage[client] = 0;
	uberTarget[client] = -1;
	VSHFlags[client] = 0;
	if (Enabled)
	{
		if (client == Hale)
		{
			if (VSHRoundState == ROUNDSTATE_START_ROUND_TIMER || VSHRoundState == ROUNDSTATE_ROUND_END)
			{
				decl String:authid[32];
				GetClientAuthString(client, authid, sizeof(authid));
				new Handle:pack;
				CreateDataTimer(3.0, Timer_SetDisconQueuePoints, pack, TIMER_FLAG_NO_MAPCHANGE);
				WritePackString(pack, authid);
				new bool:see[MAXPLAYERS + 1];
				see[Hale] = true;
				new tHale = FindNextHale(see);
				if (NextHale > 0)
				{
					tHale = NextHale;
				}
				if (IsValidClient(tHale))
				{
					if (GetClientTeam(tHale) != HaleTeam)
					{
						SetEntProp(tHale, Prop_Send, "m_lifeState", 2);
						ChangeClientTeam(tHale, HaleTeam);
						SetEntProp(tHale, Prop_Send, "m_lifeState", 0);
						TF2_RespawnPlayer(tHale);
					}
				}
			}
			if (VSHRoundState == ROUNDSTATE_START_ROUND_TIMER)
			{
				ForceTeamWin(OtherTeam);
			}
			if (VSHRoundState == ROUNDSTATE_EVENT_ROUND_START)
			{
				new bool:see[MAXPLAYERS + 1];
				see[Hale] = true;
				new tHale = FindNextHale(see);
				if (NextHale > 0)
				{
					tHale = NextHale;
					NextHale = -1;
				}
				if (IsValidClient(tHale))
				{
					Hale = tHale;
					if (GetClientTeam(Hale) != HaleTeam)
					{
						SetEntProp(Hale, Prop_Send, "m_lifeState", 2);
						ChangeClientTeam(Hale, HaleTeam);
						SetEntProp(Hale, Prop_Send, "m_lifeState", 0);
						TF2_RespawnPlayer(Hale);
					}
					CreateTimer(0.1, MakeHale);
					CPrintToChat(Hale, "{olive}[VSH]{default} Surprise! You're on NOW!");
				}
			}
			CPrintToChatAll("{olive}[VSH]{default} %t", "vsh_hale_disconnected");
		}
		else
		{
			if (IsClientInGame(client))
			{
				if (IsPlayerAlive(client)) CreateTimer(0.0, CheckAlivePlayers);
				if (client == FindNextHaleEx()) CreateTimer(1.0, Timer_SkipHalePanel, _, TIMER_FLAG_NO_MAPCHANGE);
			}
			if (client == NextHale)
			{
				NextHale = -1;
			}
		}
	}
}


