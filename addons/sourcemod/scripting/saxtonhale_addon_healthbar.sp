#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

// Require TF2 module to make it fail when loading any non-TF2 (or TF2 Beta) game
#include <tf2>
#include <saxtonhale>

#pragma semicolon 1

#define VERSION "1.2"

#define HEALTHBAR_CLASS "monster_resource"
#define HEALTHBAR_PROPERTY "m_iBossHealthPercentageByte"
#define HEALTHBAR_MAX 255

public Plugin:myinfo =
{
	name = "VSH Addon Health Bar",
	author = "Powerlord, modified by El Diablo",
	description = "Track Saxton's Health using the boss health bar",
	version = VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=146884"
}

new g_HealthBar = -1;
new g_Saxton = -1;

public OnPluginStart()
{
	HookEvent("teamplay_round_win", Event_RoundEnd);
}

public OnPluginEnd()
{
	if(g_HealthBar>-1 && IsValidEntity(g_HealthBar))
	{
		AcceptEntityInput(g_HealthBar, "Kill");
	}
}

public OnMapStart()
{
	FindHealthBar();
	g_Saxton = GetClientOfUserId(VSH_GetSaxtonHaleUserId());
	if(g_Saxton>0 && g_Saxton<=MaxClients && IsClientConnected(g_Saxton) && IsClientInGame(g_Saxton))
	{
		if(g_HealthBar == -1)
		{
			g_HealthBar = CreateEntityByName(HEALTHBAR_CLASS);
		}

		//PrintToChatAll("g_HealthBar: %d",g_HealthBar);

		SDKHook(g_Saxton, SDKHook_SpawnPost, UpdateBossHealth);
		SDKHook(g_Saxton, SDKHook_OnTakeDamagePost, OnBossDamaged);

		UpdateBossHealth(g_Saxton);
	}
}

public OnEntityCreated(entity, const String:classname[])
{
	if(entity<=MaxClients) return;

	if (StrEqual(classname, HEALTHBAR_CLASS))
	{
		g_HealthBar = entity;
	}
}

public FindHealthBar()
{
	g_HealthBar = FindEntityByClassname(-1, HEALTHBAR_CLASS);

	if (g_HealthBar == -1)
	{
		g_HealthBar = CreateEntityByName(HEALTHBAR_CLASS);
		if (g_HealthBar != -1)
		{
			DispatchSpawn(g_HealthBar);
		}
	}
}

public Action:VSH_OnHaleCreated(iHale)
{
	//if(iHale>0 && iHale<=MaxClients && IsClientConnected(iHale) && IsClientInGame(iHale))
	//{
		//new String:sTmpString[32];
		//GetClientName(iHale,sTmpString,sizeof(sTmpString));
		//PrintToChatAll("SAXTON HALE CREATED: %s",sTmpString);
	//}

	if(g_HealthBar == -1)
	{
		g_HealthBar = CreateEntityByName(HEALTHBAR_CLASS);
	}

	//PrintToChatAll("g_HealthBar: %d",g_HealthBar);

	g_Saxton = iHale;

	SDKHook(iHale, SDKHook_SpawnPost, UpdateBossHealth);
	SDKHook(iHale, SDKHook_OnTakeDamagePost, OnBossDamaged);

	UpdateBossHealth(iHale);

	return Plugin_Continue;
}

public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_Saxton = -1;
	UpdateBossHealth(g_Saxton);
}

public OnBossDamaged(victim, attacker, inflictor, Float:damage, damagetype)
{
	if(victim == g_Saxton)
	{
		UpdateBossHealth(g_Saxton);
	}
}


public UpdateBossHealth(entity)
{
	if (g_HealthBar == -1 || !IsValidEntity(g_HealthBar))
	{
		return;
	}

	//PrintToChatAll("UpdateBossHealth: %d",entity);

	new percentage;
	if (entity>0)
	{
		new maxHP = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
		new HP = GetEntProp(entity, Prop_Data, "m_iHealth");

		//new maxHealth = VSH_GetSaxtonHaleHealthMax();
		//new health = VSH_GetSaxtonHaleHealth();

		if (HP <= 0)
		{
			percentage = 0;
		}
		else
		{
			new Float:fHP = float(HP);
			new Float:fmaxHP = float(maxHP);
			new Float:fHEALTHBAR = float(HEALTHBAR_MAX);

			percentage = RoundToCeil(FloatMul(FloatDiv(fHP,fmaxHP),fHEALTHBAR));

			if(percentage>HEALTHBAR_MAX)
			{
				percentage=HEALTHBAR_MAX;
			}
		}
	}
	else
	{
		percentage = 0;
	}
	SetEntProp(g_HealthBar, Prop_Send, HEALTHBAR_PROPERTY, percentage);

	// In practice, the multiplier is 2.55
	//new Float:value = percent * (HEALTHBAR_MAX / 100.0);

	//SetEntProp(healthBar, Prop_Send, RESOURCE_PROP, RoundToNearest(value));
}
