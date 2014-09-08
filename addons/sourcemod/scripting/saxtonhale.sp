/*
===Versus Saxton Hale Mode===
Created by Rainbolt Dash (formerly Dr.Eggman): programmer, model-maker, mapper.
Notoriously famous for creating plugins with terrible code and then abandoning them

FlaminSarge - He makes cool things. He improves on terrible things until they're good.
Chdata - A Hale enthusiast and a coder. An Integrated Data Sentient Entity.
nergal - Added some very nice features to the plugin and fixed important bugs.

New plugin thread on AlliedMods: https://forums.alliedmods.net/showthread.php?p=2167912
*/

#include "SaxtonHale/SaxtonHaleIncludes/SaxtonHale_Interface.inc"

#include "SaxtonHale/SaxtonHale_001_Clients.sp"
#include "SaxtonHale/SaxtonHale_001_Engine_InitForwards.sp"
#include "SaxtonHale/SaxtonHale_001_Engine_InitNatives.sp"
#include "SaxtonHale/SaxtonHale_001_GameEvents.sp"
#include "SaxtonHale/SaxtonHale_001_HookSound.sp"
#include "SaxtonHale/SaxtonHale_001_OnEntityCreated.sp"
#include "SaxtonHale/SaxtonHale_001_OnGameFrame.sp"
#include "SaxtonHale/SaxtonHale_001_OnMapEvents.sp"
#include "SaxtonHale/SaxtonHale_001_OnPlayerRunCmd.sp"
#include "SaxtonHale/SaxtonHale_001_OnPluginEnd.sp"
#include "SaxtonHale/SaxtonHale_001_OnPluginStart.sp"
#include "SaxtonHale/SaxtonHale_001_OnPreThinkPost.sp"
#include "SaxtonHale/SaxtonHale_001_TF2_CalcIsAttackCritical.sp"
#include "SaxtonHale/SaxtonHale_CommandHook.sp"
#include "SaxtonHale/SaxtonHale_Configuration.sp"
#include "SaxtonHale/SaxtonHale_Console_Commands.sp"
#include "SaxtonHale/SaxtonHale_Cookies.sp"
#include "SaxtonHale/SaxtonHale_DamageSystem.sp"
#include "SaxtonHale/SaxtonHale_Downloads.sp"
#include "SaxtonHale/SaxtonHale_Equipment.sp"
#include "SaxtonHale/SaxtonHale_Events.sp"
#include "SaxtonHale/SaxtonHale_Health.sp"
#include "SaxtonHale/SaxtonHale_Menu.sp"
#include "SaxtonHale/SaxtonHale_Timers.sp"

public Plugin:myinfo = {
	name = "Versus Saxton Hale",
	author = "Rainbolt Dash, FlaminSarge, Chdata, nergal, fiagram, El Diablo",
	description = "RUUUUNN!! COWAAAARRDSS!",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2167912",
};

InitGamedata()
{
#if defined EASTER_BUNNY_ON
	new Handle:hGameConf = LoadGameConfigFile("saxtonhale");
	if (hGameConf == INVALID_HANDLE)
	{
		SetFailState("[VSH] Unable to load gamedata file 'saxtonhale.txt'");
		return;
	}
/*  StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	hEquipWearable = EndPrepSDKCall();
	if (hEquipWearable == INVALID_HANDLE)
	{
		SetFailState("[VSH] Failed to initialize call to CTFPlayer::EquipWearable");
		return;
	}*/
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CTFAmmoPack::SetInitialVelocity");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	hSetAmmoVelocity = EndPrepSDKCall();
	if (hSetAmmoVelocity == INVALID_HANDLE)
	{
		SetFailState("[VSH] Failed to initialize call to CTFAmmoPack::SetInitialVelocity");
		CloseHandle(hGameConf);
		return;
	}
	CloseHandle(hGameConf);
#endif
}
/*public Action:Command_Eggs(client, args)
{
	SpawnManyAmmoPacks(client, EggModel, 1);
}*/
public bool:HaleTargetFilter(const String:pattern[], Handle:clients)
{
	new bool:non = StrContains(pattern, "!", false) != -1;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && FindValueInArray(clients, client) == -1)
		{
			if (Enabled && client == Hale)
			{
				if (!non)
				{
					PushArrayCell(clients, client);
				}
			}
			else if (non)
			{
				PushArrayCell(clients, client);
			}
		}
	}

	return true;
}
public OnLibraryAdded(const String:name[])
{
#if defined _steamtools_included
	if (strcmp(name, "SteamTools", false) == 0)
		steamtools = true;
#endif
//  if (strcmp(name, "hale_achievements", false) == 0)
//      ACH_Enabled = true;
}
public OnLibraryRemoved(const String:name[])
{
#if defined _steamtools_included
	if (strcmp(name, "SteamTools", false) == 0)
		steamtools = false;
#endif
//  if (strcmp(name, "hale_achievements", false) == 0)
//      ACH_Enabled = false;
}

public DoForward_VSHOnHaleCreated()
{
	SDKHook(Hale, SDKHook_GetMaxHealth, OnGetMaxHealth);

	Call_StartForward(OnHaleCreated);
	Call_PushCell(Hale);
	Call_Finish();
}

/*public Action:OnGetGameDescription(String:gameDesc[64])
{
	if (Enabled2)
	{
		Format(gameDesc, sizeof(gameDesc), "VS Saxton Hale (%s)", haleversiontitles[maxversion]);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}*/

// TF2_OnConditionRemoved TF2_OnConditionRemoved TF2_OnConditionRemoved TF2_OnConditionRemoved TF2_OnConditionRemoved
// TF2_OnConditionRemoved TF2_OnConditionRemoved TF2_OnConditionRemoved TF2_OnConditionRemoved TF2_OnConditionRemoved
// TF2_OnConditionRemoved TF2_OnConditionRemoved TF2_OnConditionRemoved TF2_OnConditionRemoved TF2_OnConditionRemoved

public TF2_OnConditionRemoved(client, TFCond:condition)
{
	if (TF2_GetPlayerClass(client) == TFClass_Scout && condition == TFCond_CritHype)
	{
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);   //recalc their speed
	}
}

/*
DissolveRagdoll(ragdoll)
{
	new dissolver = CreateEntityByName("env_entity_dissolver");

	if (!IsValidEntity(dissolver))
	{
		return;
	}
	DispatchKeyValue(dissolver, "dissolvetype", "0");
	DispatchKeyValue(dissolver, "magnitude", "200");
	DispatchKeyValue(dissolver, "target", "!activator");
	AcceptEntityInput(dissolver, "Dissolve", ragdoll);
	AcceptEntityInput(dissolver, "Kill");
	return;
}
*/


/*
 Teleports a client to a random spawn location
 By: Chdata

 iClient - Client to teleport
 iTeam - Team of spawn points to use. If not specified or invalid team number, teleport to ANY spawn point.

stock RandomlyDisguise(client)  //original code was mecha's, but the original code is broken and this uses a better method now.
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
//      TF2_AddCondition(client, TFCond_Disguised, 99999.0);
		new disguisetarget = -1;
		new team = GetClientTeam(client);
		new Handle:hArray = CreateArray();
		for (new clientcheck = 0; clientcheck <= MaxClients; clientcheck++)
		{
			if (IsValidClient(clientcheck) && GetClientTeam(clientcheck) == team && clientcheck != client)
			{
//              new TFClassType:class = TF2_GetPlayerClass(clientcheck);
//              if (class == TFClass_Scout || class == TFClass_Medic || class == TFClass_Engineer || class == TFClass_Sniper || class == TFClass_Pyro)
				PushArrayCell(hArray, clientcheck);
			}
		}
		if (GetArraySize(hArray) <= 0) disguisetarget = client;
		else disguisetarget = GetArrayCell(hArray, GetRandomInt(0, GetArraySize(hArray)-1));
		if (!IsValidClient(disguisetarget)) disguisetarget = client;
//      new disguisehealth = GetRandomInt(75, 125);
		new class = GetRandomInt(0, 4);
		new TFClassType:classarray[] = { TFClass_Scout, TFClass_Pyro, TFClass_Medic, TFClass_Engineer, TFClass_Sniper };
//      new disguiseclass = classarray[class];
//      new disguiseclass = _:(disguisetarget != client ? (TF2_GetPlayerClass(disguisetarget)) : classarray[class]);
//      new weapon = GetEntPropEnt(disguisetarget, Prop_Send, "m_hActiveWeapon");
		CloseHandle(hArray);
		if (TF2_GetPlayerClass(client) == TFClass_Spy) TF2_DisguisePlayer(client, TFTeam:team, classarray[class], disguisetarget);
		else
		{
			TF2_AddCondition(client, TFCond_Disguised, -1.0);
			SetEntProp(client, Prop_Send, "m_nDisguiseTeam", team);
			SetEntProp(client, Prop_Send, "m_nDisguiseClass", classarray[class]);
			SetEntProp(client, Prop_Send, "m_iDisguiseTargetIndex", disguisetarget);
			SetEntProp(client, Prop_Send, "m_iDisguiseHealth", 200);
		}
	}
}*/

// SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls
// SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls
// SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls SickleClimbWalls

public SickleClimbWalls(client, weapon)     //Credit to Mecha the Slag
{
	if (!IsValidClient(client) || (GetClientHealth(client)<=15) )return;

	decl String:classname[64];
	decl Float:vecClientEyePos[3];
	decl Float:vecClientEyeAng[3];
	GetClientEyePosition(client, vecClientEyePos);   // Get the position of the player's eyes
	GetClientEyeAngles(client, vecClientEyeAng);       // Get the angle the player is looking

	//Check for colliding entities
	TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);

	if (!TR_DidHit(INVALID_HANDLE)) return;

	new TRIndex = TR_GetEntityIndex(INVALID_HANDLE);
	GetEdictClassname(TRIndex, classname, sizeof(classname));
	if (!StrEqual(classname, "worldspawn")) return;

	decl Float:fNormal[3];
	TR_GetPlaneNormal(INVALID_HANDLE, fNormal);
	GetVectorAngles(fNormal, fNormal);

	if (fNormal[0] >= 30.0 && fNormal[0] <= 330.0) return;
	if (fNormal[0] <= -30.0) return;

	decl Float:pos[3];
	TR_GetEndPosition(pos);
	new Float:distance = GetVectorDistance(vecClientEyePos, pos);

	if (distance >= 100.0) return;

	new Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);

	fVelocity[2] = 600.0;

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);

	SDKHooks_TakeDamage(client, client, client, 15.0, DMG_CLUB, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));

	if (client != Hale) ClientCommand(client, "playgamesound \"%s\"", "player\\taunt_clip_spin.wav");

	CreateTimer(0.0, Timer_NoAttacking, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
}
public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	return (entity != data);
}

// OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned
// OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned
// OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned OnEggBombSpawned

public OnEggBombSpawned(entity)
{
	new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (IsValidClient(owner) && owner == Hale && Special == VSHSpecial_Bunny)
		CreateTimer(0.0, Timer_SetEggBomb, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
}

// Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives
// Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives
// Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives Natives

public Native_IsVSHMap(Handle:plugin, numParams)
{
	return IsSaxtonHaleMap();
/*  new result = IsSaxtonHaleMap();
	new result2 = result;

	new Action:act = Plugin_Continue;
	Call_StartForward(OnIsVSHMap);
	Call_PushCellRef(result2);
	Call_Finish(act);
	if (act == Plugin_Changed)
		result = result2;
	return result;*/
}
/*
public Native_IsEnabled(Handle:plugin, numParams)
{
	new result = Enabled;
	new result2 = result;

	new Action:act = Plugin_Continue;
	Call_StartForward(OnIsEnabled);
	Call_PushCellRef(result2);
	Call_Finish(act);
	if (act == Plugin_Changed)
		result = result2;
	return result;
}

public Native_GetHale(Handle:plugin, numParams)
{
	new result = -1;
	if (IsValidClient(Hale))
		result = GetClientUserId(Hale);
	new result2 = result;

	new Action:act = Plugin_Continue;
	Call_StartForward(OnGetHale);
	Call_PushCellRef(result2);
	Call_Finish(act);
	if (act == Plugin_Changed)
		result = result2;
	return result;

}

public Native_GetTeam(Handle:plugin, numParams)
{
	new result = HaleTeam;
	new result2 = result;

	new Action:act = Plugin_Continue;
	Call_StartForward(OnGetTeam);
	Call_PushCellRef(result2);
	Call_Finish(act);
	if (act == Plugin_Changed)
		result = result2;
	return result;
}

public Native_GetSpecial(Handle:plugin, numParams)
{
	new result = Special;
	new result2 = result;

	new Action:act = Plugin_Continue;
	Call_StartForward(OnGetSpecial);
	Call_PushCellRef(result2);
	Call_Finish(act);
	if (act == Plugin_Changed)
		result = result2;
	return result;
}

public Native_GetHealth(Handle:plugin, numParams)
{
	new result = HaleHealth;
	new result2 = result;

	new Action:act = Plugin_Continue;
	Call_StartForward(OnGetHealth);
	Call_PushCellRef(result2);
	Call_Finish(act);
	if (act == Plugin_Changed)
		result = result2;

	return result;
}

public Native_GetHealthMax(Handle:plugin, numParams)
{
	new result = HaleHealthMax;
	new result2 = result;

	new Action:act = Plugin_Continue;
	Call_StartForward(OnGetHealthMax);
	Call_PushCellRef(result2);
	Call_Finish(act);
	if (act == Plugin_Changed)
		result = result2;
	return result;
}

public Native_GetRoundState(Handle:plugin, numParams)
{
	new result = VSHRoundState;
	new result2 = result;

	new Action:act = Plugin_Continue;
	Call_StartForward(OnGetRoundState);
	Call_PushCellRef(result2);
	Call_Finish(act);
	if (act == Plugin_Changed)
		result = result2;
	return result;
}
public Native_GetDamage(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new result = 0;
	if (IsValidClient(client))
		result = Damage[client];
	new result2 = result;

	new Action:act = Plugin_Continue;
	Call_StartForward(OnGetDamage);
	Call_PushCell(client);
	Call_PushCellRef(result2);
	Call_Finish(act);
	if (act == Plugin_Changed)
		result = result2;
	return result;
}*/

public Native_IsEnabled(Handle:plugin, numParams)
{
	return Enabled;
}
public Native_GetHale(Handle:plugin, numParams)
{
	if (IsValidClient(Hale))
		return GetClientUserId(Hale);
	return -1;
}
public Native_GetTeam(Handle:plugin, numParams)
{
	return HaleTeam;
}
public Native_GetSpecial(Handle:plugin, numParams)
{
	return _:Special;
}
public Native_GetHealth(Handle:plugin, numParams)
{
	return HaleHealth;
}
public Native_GetHealthMax(Handle:plugin, numParams)
{
	return HaleHealthMax;
}
public Native_GetRoundState(Handle:plugin, numParams)
{
	return VSHRoundState;
}
public Native_GetDamage(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (!IsValidClient(client))
		return 0;
	return Damage[client];
}
public Native_GetNextSaxtonHaleUserId(Handle:plugin, numParams)
{
	new client = FindNextHaleEx();
	if (ValidPlayer(client))
		return GetClientUserId(client);
	return -1;
}
public Native_IsSpecialEnabled(Handle:plugin, numParams)
{
	new VSHSpecials_id:Special_id = VSHSpecials_id:GetNativeCell(1);
	return Special_Enabled[Special_id];
}
