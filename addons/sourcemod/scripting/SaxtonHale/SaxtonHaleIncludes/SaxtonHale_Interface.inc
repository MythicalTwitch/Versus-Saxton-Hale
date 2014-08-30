// This file is the main interface for saxtonhale.sp and should not be used by
// external plugins.   Use saxtonhale.inc instead of this file.

#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <morecolors>
#include <nextmap>
#include <tf2items>
#include <clientprefs>

#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS

#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#define REQUIRE_PLUGIN

// The saxtonhale.inc is what is used by external plugins
#include <saxtonhale>

#include "SaxtonHale/SaxtonHaleIncludes/SaxtonHale_Constants.inc"
#include "SaxtonHale/SaxtonHaleIncludes/SaxtonHale_Variables.inc"

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("GetUserMessageType");
	MarkNativeAsOptional("PbSetInt");
	MarkNativeAsOptional("PbSetBool");
	MarkNativeAsOptional("PbSetString");
	MarkNativeAsOptional("PbAddString");
/*  CreateNative("VSH_IsSaxtonHaleModeMap", Native_IsVSHMap);
	OnIsVSHMap = CreateGlobalForward("VSH_OnIsSaxtonHaleModeMap", ET_Hook, Param_CellByRef);

	CreateNative("VSH_IsSaxtonHaleModeEnabled", Native_IsEnabled);
	OnIsEnabled = CreateGlobalForward("VSH_OnIsSaxtonHaleModeEnabled", ET_Hook, Param_CellByRef);

	CreateNative("VSH_GetSaxtonHaleUserId", Native_GetHale);
	OnGetHale = CreateGlobalForward("VSH_OnGetSaxtonHaleUserId", ET_Hook, Param_CellByRef);

	CreateNative("VSH_GetSaxtonHaleTeam", Native_GetTeam);
	OnGetTeam = CreateGlobalForward("VSH_OnGetSaxtonHaleTeam", ET_Hook, Param_CellByRef);

	CreateNative("VSH_GetSpecialRoundIndex", Native_GetSpecial);
	OnGetSpecial = CreateGlobalForward("VSH_OnGetSpecialRoundIndex", ET_Hook, Param_CellByRef);

	CreateNative("VSH_GetSaxtonHaleHealth", Native_GetHealth);
	OnGetHealth = CreateGlobalForward("VSH_OnGetSaxtonHaleHealth", ET_Hook, Param_CellByRef);

	CreateNative("VSH_GetSaxtonHaleHealthMax", Native_GetHealthMax);
	OnGetHealthMax = CreateGlobalForward("VSH_OnGetSaxtonHaleHealthMax", ET_Hook, Param_CellByRef);

	CreateNative("VSH_GetClientDamage", Native_GetDamage);
	OnGetDamage = CreateGlobalForward("VSH_OnGetClientDamage", ET_Hook, Param_Cell,Param_CellByRef);

	CreateNative("VSH_GetRoundState", Native_GetRoundState);
	OnGetRoundState = CreateGlobalForward("VSH_OnGetRoundState", ET_Hook, Param_CellByRef);*/

	CreateNative("VSH_IsSaxtonHaleModeMap", Native_IsVSHMap);
	CreateNative("VSH_IsSaxtonHaleModeEnabled", Native_IsEnabled);
	CreateNative("VSH_GetSaxtonHaleUserId", Native_GetHale);
	CreateNative("VSH_GetSaxtonHaleTeam", Native_GetTeam);
	CreateNative("VSH_GetSpecialRoundIndex", Native_GetSpecial);
	CreateNative("VSH_GetSaxtonHaleHealth", Native_GetHealth);
	CreateNative("VSH_GetSaxtonHaleHealthMax", Native_GetHealthMax);
	CreateNative("VSH_GetClientDamage", Native_GetDamage);
	CreateNative("VSH_GetRoundState", Native_GetRoundState);
	OnHaleCreated = CreateGlobalForward("VSH_OnHaleCreated", ET_Ignore, Param_Cell);
	OnHaleJump = CreateGlobalForward("VSH_OnDoJump", ET_Hook, Param_CellByRef);
	OnHaleRage = CreateGlobalForward("VSH_OnDoRage", ET_Hook, Param_FloatByRef);
	OnHaleWeighdown = CreateGlobalForward("VSH_OnDoWeighdown", ET_Hook);
	OnMusic = CreateGlobalForward("VSH_OnMusic", ET_Hook, Param_String, Param_FloatByRef);
	RegPluginLibrary("saxtonhale");
#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
#endif
	return APLRes_Success;
}

// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS
// STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS STOCKS

stock bool:IsSaxtonHaleMap(bool:forceRecalc = false)
{
	static bool:found = false;
	static bool:isVSHMap = false;
	if (forceRecalc)
	{
		isVSHMap = false;
		found = false;
	}
	if (!found)
	{
		decl String:s[PLATFORM_MAX_PATH];
		GetCurrentMap(currentmap, sizeof(currentmap));
		if (FileExists("bNextMapToHale"))
		{
			isVSHMap = true;
			found = true;
			return true;
		}
		BuildPath(Path_SM, s, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_hale_maps.cfg");
		if (!FileExists(s))
		{
			LogError("[VSH] Unable to find %s, disabling plugin.", s);
			isVSHMap = false;
			found = true;
			return false;
		}
		new Handle:fileh = OpenFile(s, "r");
		if (fileh == INVALID_HANDLE)
		{
			LogError("[VSH] Error reading maps from %s, disabling plugin.", s);
			isVSHMap = false;
			found = true;
			return false;
		}
		new pingas = 0;
		while (!IsEndOfFile(fileh) && ReadFileLine(fileh, s, sizeof(s)) && (pingas < 100))
		{
			pingas++;
			if (pingas == 100)
				LogError("[VS Saxton Hale] Breaking infinite loop when trying to check the map.");
			Format(s, strlen(s)-1, s);
			if (strncmp(s, "//", 2, false) == 0) continue;
			if ((StrContains(currentmap, s, false) != -1) || (StrContains(s, "all", false) == 0))
			{
				CloseHandle(fileh);
				isVSHMap = true;
				found = true;
				return true;
			}
		}
		CloseHandle(fileh);
	}
	return isVSHMap;
}
stock bool:MapHasMusic(bool:forceRecalc = false)
{
	static bool:hasMusic;
	static bool:found = false;
	if (forceRecalc)
	{
		found = false;
		hasMusic = false;
	}
	if (!found)
	{
		new i = -1;
		decl String:name[64];
		while ((i = FindEntityByClassname2(i, "info_target")) != -1)
		{
			GetEntPropString(i, Prop_Data, "m_iName", name, sizeof(name));
			if (strcmp(name, "hale_no_music", false) == 0) hasMusic = true;
		}
		found = true;
	}
	return hasMusic;
}
stock bool:CheckToChangeMapDoors()
{
	decl String:s[PLATFORM_MAX_PATH];
	GetCurrentMap(currentmap, sizeof(currentmap));
	checkdoors = false;
	BuildPath(Path_SM, s, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_hale_doors.cfg");
	if (!FileExists(s))
	{
		if (strncmp(currentmap, "vsh_lolcano_pb1", 15, false) == 0)
			checkdoors = true;
		return;
	}
	new Handle:fileh = OpenFile(s, "r");
	if (fileh == INVALID_HANDLE)
	{
		if (strncmp(currentmap, "vsh_lolcano_pb1", 15, false) == 0)
			checkdoors = true;
		return;
	}
	while (!IsEndOfFile(fileh) && ReadFileLine(fileh, s, sizeof(s)))
	{
		Format(s, strlen(s)-1, s);
		if (strncmp(s, "//", 2, false) == 0) continue;
		if (StrContains(currentmap, s, false) != -1 || StrContains(s, "all", false) == 0)
		{
			CloseHandle(fileh);
			checkdoors = true;
			return;
		}
	}
	CloseHandle(fileh);
}
stock CheckToTeleportToSpawn()
{
	decl String:s[PLATFORM_MAX_PATH];
	GetCurrentMap(currentmap, sizeof(currentmap));
	bSpawnTeleOnTriggerHurt = false;

	BuildPath(Path_SM, s, PLATFORM_MAX_PATH, "configs/saxton_hale/saxton_spawn_teleport.cfg");

	if (!FileExists(s))
	{
		return;
	}

	new Handle:fileh = OpenFile(s, "r");

	if (fileh == INVALID_HANDLE)
	{
		return;
	}

	while (!IsEndOfFile(fileh) && ReadFileLine(fileh, s, sizeof(s)))
	{
		Format(s, strlen(s) - 1, s);
		if (strncmp(s, "//", 2, false) == 0)
		{
			continue;
		}

		if (StrContains(currentmap, s, false) != -1 || StrContains(s, "all", false) == 0)
		{
			bSpawnTeleOnTriggerHurt = true;
			CloseHandle(fileh);
			return;
		}
	}

	CloseHandle(fileh);
}
stock bool:CheckNextSpecial()
{
	if (!bSpecials)
	{
		Special = VSHSpecial_Hale;
		return true;
	}
	if (Incoming != VSHSpecial_None)
	{
		Special = Incoming;
		Incoming = VSHSpecial_None;
		return true;
	}
	while (Incoming == VSHSpecial_None || (Special && Special == Incoming))
	{
		Incoming = GetRandomInt(0, 8);
		if (Special != VSHSpecial_Hale && !GetRandomInt(0, 5)) Incoming = VSHSpecial_Hale;
		else
		{
			switch (Incoming)
			{
				case 1: Incoming = VSHSpecial_Vagineer;
				case 2: Incoming = VSHSpecial_HHH;
				case 3: Incoming = VSHSpecial_CBS;
#if defined EASTER_BUNNY_ON
				case 4: Incoming = VSHSpecial_Bunny;
#endif
				default: Incoming = VSHSpecial_Hale;
			}
			if (IsDecemberHoliday() && !GetRandomInt(0, 7)) Incoming = VSHSpecial_CBS;
#if defined EASTER_BUNNY_ON
			if (IsEasterHoliday() && !GetRandomInt(0, 7)) Incoming = VSHSpecial_Bunny;
#endif
		}
	}
	Special = Incoming;
	Incoming = VSHSpecial_None;
	return true;        //OH GOD WHAT AM I DOING THIS ALWAYS RETURNS TRUE (still better than using QueuePanelH as a dummy)
}
stock bool:IsEasterHoliday(bool:forceRecalc = false)
{
	static iMonth;
	static iDate;
	static bool:found = false;
	if (forceRecalc)
	{
		found = false;
		iMonth = 0;
		iDate = 0;
	}
	if (!found)
	{
		new timestamp = GetTime();
		decl String:month[32], String:date[32];
		FormatTime(month, sizeof(month), "%m", timestamp);
		FormatTime(date, sizeof(date), "%d", timestamp);
		iMonth = StringToInt(month);
		iDate = StringToInt(date);
		found = true;
	}
	return (iMonth == 3 && iDate >= 25) || (iMonth == 4 && iDate < 20);
}
stock bool:IsDecemberHoliday(bool:forceRecalc = false)
{
	static iMonth;
	static iDate;
	static bool:found = false;
	if (forceRecalc)
	{
		found = false;
		iMonth = 0;
		iDate = 0;
	}
	if (!found)
	{
		new timestamp = GetTime();
		decl String:month[32], String:date[32];
		FormatTime(month, sizeof(month), "%m", timestamp);
		FormatTime(date, sizeof(date), "%d", timestamp);
		iMonth = StringToInt(month);
		iDate = StringToInt(date);
		found = true;
	}
	return (iMonth == 12 && iDate >= 15);
}

stock SearchForItemPacks()
{
	new bool:foundAmmo = false, bool:foundHealth = false;
	new ent = -1;
	decl Float:pos[3];
	while ((ent = FindEntityByClassname2(ent, "item_ammopack_full")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", Enabled?OtherTeam:0, 4);

		if (Enabled)
		{
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");
			new ent2 = CreateEntityByName("item_ammopack_small");
			TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(ent2);
			SetEntProp(ent2, Prop_Send, "m_iTeamNum", Enabled?OtherTeam:0, 4);
			foundAmmo = true;
		}

	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_ammopack_medium")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", Enabled?OtherTeam:0, 4);

		if (Enabled)
		{
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");
			new ent2 = CreateEntityByName("item_ammopack_small");
			TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(ent2);
			SetEntProp(ent2, Prop_Send, "m_iTeamNum", Enabled?OtherTeam:0, 4);
		}

		foundAmmo = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "Item_ammopack_small")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", Enabled?OtherTeam:0, 4);
		foundAmmo = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_small")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", Enabled?OtherTeam:0, 4);
		foundHealth = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_medium")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", Enabled?OtherTeam:0, 4);
		foundHealth = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_large")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", Enabled?OtherTeam:0, 4);
		foundHealth = true;
	}
	if (!foundAmmo) SpawnRandomAmmo();
	if (!foundHealth) SpawnRandomHealth();
}

stock SpawnRandomAmmo()
{
}
stock SpawnRandomHealth()
{
}

stock GetTeamPlayerCount(TFTeam:team)
{
	new count = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) == _:team)
			count++;
	}
	return count;
}

stock CalcScores()
{
	decl j, damage;
	new bool:spec = GetConVarBool(cvarForceSpecToHale);
	botqueuepoints += 5;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			damage = Damage[i];
			new Handle:aevent = CreateEvent("player_escort_score", true);
			SetEventInt(aevent, "player", i);
			for (j = 0; damage - 600 > 0; damage -= 600, j++){}
			SetEventInt(aevent, "points", j);
			FireEvent(aevent);
			if (i == Hale)
			{
				if (IsFakeClient(Hale)) botqueuepoints = 0;
				else SetClientQueuePoints(i, 0);
			}
			else if (!IsFakeClient(i) && (GetClientTeam(i) > _:TFTeam_Spectator || spec))
			{
				CPrintToChat(i, "{olive}[VSH]{default} %t", "vsh_add_points", 10);
				SetClientQueuePoints(i, GetClientQueuePoints(i)+10);
			}
		}
	}
}

stock EmitSoundToAllExcept(exceptiontype = SOUNDEXCEPT_MUSIC, const String:sample[],
				 entity = SOUND_FROM_PLAYER,
				 channel = SNDCHAN_AUTO,
				 level = SNDLEVEL_NORMAL,
				 flags = SND_NOFLAGS,
				 Float:volume = SNDVOL_NORMAL,
				 pitch = SNDPITCH_NORMAL,
				 speakerentity = -1,
				 const Float:origin[3] = NULL_VECTOR,
				 const Float:dir[3] = NULL_VECTOR,
				 bool:updatePos = true,
				 Float:soundtime = 0.0)
{
	new clients[MaxClients];
	new total = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && CheckSoundException(i, exceptiontype))
		{
			clients[total++] = i;
		}
	}
	if (!total)
	{
		return;
	}
	EmitSound(clients, total, sample, entity, channel,
		level, flags, volume, pitch, speakerentity,
		origin, dir, updatePos, soundtime);
}

stock SkipHalePanelNotify(client, bool:newchoice = true)
{
	if (!Enabled || !IsValidClient(client) || IsVoteInProgress())
	{
		return;
	}

	new Handle:panel = CreatePanel();
	decl String:s[256];

	SetPanelTitle(panel, "[VSH] You're Hale next!");
	Format(s, sizeof(s), "%t\nAlternatively, use !resetq.", "vsh_to0_near");
	CRemoveTags(s, sizeof(s));

	ReplaceString(s, sizeof(s), "{olive}", "");
	ReplaceString(s, sizeof(s), "{default}", "");

	DrawPanelItem(panel, s);
	SendPanelToClient(panel, client, SkipHalePanelH, 30);
	CloseHandle(panel);

	return;
}
stock Handle:PrepareItemHandle(Handle:hItem, String:name[] = "", index = -1, const String:att[] = "", bool:dontpreserve = false)
{
	static Handle:hWeapon;
	new addattribs = 0;

	new String:weaponAttribsArray[32][32];
	new attribCount = ExplodeString(att, " ; ", weaponAttribsArray, 32, 32);

	new flags = OVERRIDE_ATTRIBUTES;
	if (!dontpreserve) flags |= PRESERVE_ATTRIBUTES;
	if (hWeapon == INVALID_HANDLE) hWeapon = TF2Items_CreateItem(flags);
	else TF2Items_SetFlags(hWeapon, flags);
//  new Handle:hWeapon = TF2Items_CreateItem(flags);    //INVALID_HANDLE;
	if (hItem != INVALID_HANDLE)
	{
		addattribs = TF2Items_GetNumAttributes(hItem);
		if (addattribs > 0)
		{
			for (new i = 0; i < 2 * addattribs; i += 2)
			{
				new bool:dontAdd = false;
				new attribIndex = TF2Items_GetAttributeId(hItem, i);
				for (new z = 0; z < attribCount+i; z += 2)
				{
					if (StringToInt(weaponAttribsArray[z]) == attribIndex)
					{
						dontAdd = true;
						break;
					}
				}
				if (!dontAdd)
				{
					IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
					FloatToString(TF2Items_GetAttributeValue(hItem, i), weaponAttribsArray[i+1+attribCount], 32);
				}
			}
			attribCount += 2 * addattribs;
		}
		CloseHandle(hItem); //probably returns false but whatever
	}

	if (name[0] != '\0')
	{
		flags |= OVERRIDE_CLASSNAME;
		TF2Items_SetClassname(hWeapon, name);
	}
	if (index != -1)
	{
		flags |= OVERRIDE_ITEM_DEF;
		TF2Items_SetItemIndex(hWeapon, index);
	}
	if (attribCount > 1)
	{
		TF2Items_SetNumAttributes(hWeapon, (attribCount/2));
		new i2 = 0;
		for (new i = 0; i < attribCount && i < 32; i += 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(hWeapon, 0);
	}
	TF2Items_SetFlags(hWeapon, flags);
	return hWeapon;
}
stock RemovePlayerTarge(client)
{
	new edict = MaxClients+1;
	while((edict = FindEntityByClassname2(edict, "tf_wearable_demoshield")) != -1)
	{
		new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
		if ((idx == 131 || idx == 406 || idx == 1099) && GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
		{
			TF2_RemoveWearable(client, edict);
			//AcceptEntityInput(edict, "Kill");
		}
	}
}
stock RemovePlayerBack(client, indices[], len)
{
	if (len <= 0) return;
	new edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
	{
		decl String:netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (new i = 0; i < len; i++)
				{
					if (idx == indices[i])
					{
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_powerup_bottle")) != -1)
	{
		decl String:netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (new i = 0; i < len; i++)
				{
					if (idx == indices[i])
					{
						TF2_RemoveWearable(client, edict);
						//AcceptEntityInput(edict, "Kill");
					}
				}
			}
		}
	}
}
stock FindPlayerBack(client, indices[], len)
{
	if (len <= 0) return -1;
	new edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
	{
		decl String:netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (new i = 0; i < len; i++)
				{
					if (idx == indices[i]) return edict;
				}
			}
		}
	}
	edict = MaxClients+1;
	while ((edict = FindEntityByClassname2(edict, "tf_powerup_bottle")) != -1)
	{
		decl String:netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFPowerupBottle"))
		{
			new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				for (new i = 0; i < len; i++)
				{
					if (idx == indices[i]) return edict;
				}
			}
		}
	}
	return -1;
}
stock StopHaleMusic(client)
{
	if (!IsValidClient(client)) return;
//  StopSound(client, SNDCHAN_AUTO, HaleTempTheme);
	StopSound(client, SNDCHAN_AUTO, HHHTheme);
	StopSound(client, SNDCHAN_AUTO, CBSTheme);
}

stock SetControlPoint(bool:enable)
{
	new CPm=-1; //CP = -1;
	while ((CPm = FindEntityByClassname2(CPm, "team_control_point")) != -1)
	{
		if (CPm > MaxClients && IsValidEdict(CPm))
		{
			AcceptEntityInput(CPm, (enable ? "ShowModel" : "HideModel"));
			SetVariantInt(enable ? 0 : 1);
			AcceptEntityInput(CPm, "SetLocked");
		}
	}
}
stock SetArenaCapEnableTime(Float:time)
{
	new ent = -1;
	decl String:strTime[32];
	FloatToString(time, strTime, sizeof(strTime));
	if ((ent = FindEntityByClassname2(-1, "tf_logic_arena")) != -1 && IsValidEdict(ent))
	{
		DispatchKeyValue(ent, "CapEnableDelay", strTime);
	}
}
stock ForceHale(admin, client, bool:hidden, bool:forever = false)
{
	if (forever)
		Hale = client;
	else
		NextHale = client;
	if (!hidden)
	{
		CPrintToChatAllEx(client, "{olive}[VSH] {teamcolor}%N {default}%t", client, "vsh_hale_select_text");
	}
}
stock GetRJFlag(client)
	return (0 < client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) ? g_bClientRJFlag[client] : false);

stock SetRJFlag(client, bool:bState)
{
	if (0 < client <= MaxClients)
		g_bClientRJFlag[client] = bState;
}

stock bool:IsNearSpencer(client)
{
	new bool:dispenserheal, medics = 0;
	new healers = GetEntProp(client, Prop_Send, "m_nNumHealers");
	if (healers > 0)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsPlayerAlive(i) && GetHealingTarget(i) == client)
				medics++;
		}
	}
	dispenserheal = (healers > medics) ? true : false;
	return dispenserheal;
}

stock FindSentry(client)
{
	new i=-1;
	while ((i = FindEntityByClassname2(i, "obj_sentrygun")) != -1)
	{
		if (GetEntPropEnt(i, Prop_Send, "m_hBuilder") == client) return i;
	}
	return -1;
}
stock OnlyScoutsLeft()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client) && client != Hale && TF2_GetPlayerClass(client) != TFClass_Scout)
			return false;
	}
	return true;
}

stock GetIndexOfWeaponSlot(client, slot)
{
	new weapon = GetPlayerWeaponSlot(client, slot);
	return (weapon > MaxClients && IsValidEntity(weapon) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
}

stock SpawnManyAmmoPacks(client, String:model[], skin=0, num=14, Float:offsz = 30.0)
{
	if (hSetAmmoVelocity == INVALID_HANDLE) return;
	decl Float:pos[3], Float:vel[3], Float:ang[3];
	ang[0] = 90.0;
	ang[1] = 0.0;
	ang[2] = 0.0;
	GetClientAbsOrigin(client, pos);
	pos[2] += offsz;
	for (new i = 0; i < num; i++)
	{
		vel[0] = GetRandomFloat(-400.0, 400.0);
		vel[1] = GetRandomFloat(-400.0, 400.0);
		vel[2] = GetRandomFloat(300.0, 500.0);
		pos[0] += GetRandomFloat(-5.0, 5.0);
		pos[1] += GetRandomFloat(-5.0, 5.0);
		new ent = CreateEntityByName("tf_ammo_pack");
		if (!IsValidEntity(ent)) continue;
		SetEntityModel(ent, model);
		DispatchKeyValue(ent, "OnPlayerTouch", "!self,Kill,,0,-1"); //for safety, but it shouldn't act like a normal ammopack
		SetEntProp(ent, Prop_Send, "m_nSkin", skin);
		SetEntProp(ent, Prop_Send, "m_nSolidType", 6);
//      SetEntityMoveType(ent, MOVETYPE_FLYGRAVITY);
//      SetEntProp(ent, Prop_Send, "movetype", 5);
//      SetEntProp(ent, Prop_Send, "movecollide", 0);
		SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
		SetEntProp(ent, Prop_Send, "m_triggerBloat", 24);
		SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
		SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(ent, Prop_Send, "m_iTeamNum", 2);
		TeleportEntity(ent, pos, ang, vel);
		DispatchSpawn(ent);
		TeleportEntity(ent, pos, ang, vel);
		SDKCall(hSetAmmoVelocity, ent, vel);
		SetEntProp(ent, Prop_Data, "m_iHealth", 900);
		new offs = GetEntSendPropOffs(ent, "m_vecInitialVelocity", true);
		SetEntData(ent, offs-4, 1, _, true);    //Sets to crit candy, offs-8 sets crit candy duration (is a float, 3*float = duration)
		//1358 is offs-14, that byte is for being a sandwich with +50hp, +75 for scouts. The byte after that, 1359, is to... not give the health? I don't know.
/*      SetEntData(ent, offs-13, 0, 1, true);
		SetEntData(ent, offs-11, 1, 1, true);
		SetEntData(ent, offs-15, 1, 1, true);
		SetEntityMoveType(ent, MOVETYPE_FLYGRAVITY);
		SetEntProp(ent, Prop_Data, "m_nNextThinkTick", GetEntProp(client, Prop_Send, "m_nTickBase") + 3);
		SetEntPropVector(ent, Prop_Data, "m_vecAbsVelocity", vel);
		SetEntPropVector(ent, Prop_Data, "m_vecVelocity", vel);
		SetEntPropVector(ent, Prop_Send, "m_vecInitialVelocity", vel);
		SetEntProp(ent, Prop_Send, "m_bClientSideAnimation", 1);
		PrintToChatAll("aeiou %d %d %d %d %d", GetEntData(ent, offs-16, 1), GetEntData(ent, offs-15, 1), GetEntData(ent, offs-14, 1), GetEntData(ent, offs-13, 1), GetEntData(ent, offs-12, 1));
		*/
	}
}

stock TeleportToSpawn(iClient, iTeam = 0)
{
	new iEnt = -1;
	decl Float:vPos[3];
	decl Float:vAng[3];
	new Handle:hArray = CreateArray();
	while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
	{
		if (iTeam <= 1) // Not RED (2) nor BLu (3)
		{
			PushArrayCell(hArray, iEnt);
		}
		else
		{
			new iSpawnTeam = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");
			if (iSpawnTeam == iTeam)
			{
				PushArrayCell(hArray, iEnt);
			}
		}
	}

	iEnt = GetArrayCell(hArray, GetRandomInt(0, GetArraySize(hArray) - 1));
	CloseHandle(hArray);

	// Technically you'll never find a map without a spawn point. Not a good map at least.
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
	GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);
	TeleportEntity(iClient, vPos, vAng, NULL_VECTOR);

	if (Special == VSHSpecial_HHH)
	{
		CreateTimer(3.0, RemoveEnt, EntIndexToEntRef(AttachParticle(iEnt, "ghost_appearation", _, false)));
		EmitSoundToAll("misc/halloween/spell_teleport.wav", _, _, SNDLEVEL_GUNFIRE, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, vPos, NULL_VECTOR, false, 0.0);
	}

	/*if (GetArraySize(hArray) <= 0)
	{
		// No iEnt was found. This should be impossible.
	}
	else
	{
		iEnt = GetArrayCell(hArray, GetRandomInt(0, GetArraySize(hArray) - 1))
	}*/
}

stock GetClientCloakIndex(client)
{
	if (!IsValidClient(client, false)) return -1;
	new wep = GetPlayerWeaponSlot(client, 4);
	if (!IsValidEntity(wep)) return -1;
	new String:classname[64];
	GetEntityClassname(wep, classname, sizeof(classname));
	if (strncmp(classname, "tf_wea", 6, false) != 0) return -1;
	return GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex");
}

stock SpawnSmallHealthPackAt(client, ownerteam = 0)
{
	if (!IsValidClient(client, false) || !IsPlayerAlive(client)) return;
	new healthpack = CreateEntityByName("item_healthkit_small");
	decl Float:pos[3];
	GetClientAbsOrigin(client, pos);
	pos[2] += 20.0;
	if (IsValidEntity(healthpack))
	{
		DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");  //for safety, though it normally doesn't respawn
		DispatchSpawn(healthpack);
		SetEntProp(healthpack, Prop_Send, "m_iTeamNum", ownerteam, 4);
		SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
		new Float:vel[3];
		vel[0] = float(GetRandomInt(-10, 10)), vel[1] = float(GetRandomInt(-10, 10)), vel[2] = 50.0;
		TeleportEntity(healthpack, pos, NULL_VECTOR, vel);
//      CreateTimer(17.0, Timer_RemoveCandycaneHealthPack, EntIndexToEntRef(healthpack), TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock IncrementHeadCount(client)
{
	if (!TF2_IsPlayerInCondition(client, TFCond_DemoBuff)) TF2_AddCondition(client, TFCond_DemoBuff, -1.0);
	new decapitations = GetEntProp(client, Prop_Send, "m_iDecapitations");
	SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations+1);
	new health = GetClientHealth(client);
//  health += (decapitations >= 4 ? 10 : 15);
	health += 15;
	SetEntProp(client, Prop_Data, "m_iHealth", health);
	//SetEntProp(client, Prop_Send, "m_iHealth", health);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);   //recalc their speed
}

stock SwitchToOtherWeapon(client)
{
	new ammo = GetAmmo(client, 0);
	new weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	new clip = (IsValidEntity(weapon) ? GetEntProp(weapon, Prop_Send, "m_iClip1") : -1);
	if (!(ammo == 0 && clip <= 0)) SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	else SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary));
}

stock FindTeleOwner(client)
{
	if (!IsValidClient(client)) return -1;
	if (!IsPlayerAlive(client)) return -1;
	new tele = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
	decl String:classname[32];
	if (IsValidEntity(tele) && GetEdictClassname(tele, classname, sizeof(classname)) && strcmp(classname, "obj_teleporter", false) == 0)
	{
		new owner = GetEntPropEnt(tele, Prop_Send, "m_hBuilder");
		if (IsValidClient(owner, false)) return owner;
	}
	return -1;
}

stock TF2_IsPlayerCritBuffed(client)
{
	return (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged)
			|| TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy)
			|| TF2_IsPlayerInCondition(client, TFCond:34)
			|| TF2_IsPlayerInCondition(client, TFCond:35)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnWin)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture)
			|| TF2_IsPlayerInCondition(client, TFCond_CritOnKill)
			|| TF2_IsPlayerInCondition(client, TFCond_CritMmmph)
			);
}
stock SetNextAttack(weapon, Float:duration = 0.0)
{
	if (weapon <= MaxClients) return;
	if (!IsValidEntity(weapon)) return;
	new Float:next = GetGameTime() + duration;
	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", next);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", next);
}

stock FindNextHale(bool:array[])
{
	new tBoss = -1;
	new tBossPoints = -1073741824;
	new bool:spec = GetConVarBool(cvarForceSpecToHale);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && (GetClientTeam(i) > _:TFTeam_Spectator || (spec && GetClientTeam(i) != _:TFTeam_Unassigned)))   // GetClientTeam(i) != _:TFTeam_Unassigned)
		{
			new points = GetClientQueuePoints(i);
			if (points >= tBossPoints && !array[i])
			{
				tBoss = i;
				tBossPoints = points;
			}
		}
	}
	return tBoss;
}

stock FindNextHaleEx()
{
	new bool:added[MAXPLAYERS + 1];
	if (Hale >= 0) added[Hale] = true;
	return FindNextHale(added);
}

stock ForceTeamWin(team)
{
	new ent = FindEntityByClassname2(-1, "team_control_point_master");
	if (ent == -1)
	{
		ent = CreateEntityByName("team_control_point_master");
		DispatchSpawn(ent);
		AcceptEntityInput(ent, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(ent, "SetWinner");
}

stock AttachParticle(ent, String:particleType[], Float:offset = 0.0, bool:battach = true)
{
	new particle = CreateEntityByName("info_particle_system");
	decl String:tName[128];
	decl Float:pos[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	pos[2] += offset;
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	Format(tName, sizeof(tName), "target%i", ent);
	DispatchKeyValue(ent, "targetname", tName);
	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", tName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(tName);
	if (battach)
	{
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", ent);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	return particle;
}
stock SpawnWeapon(client, String:name[], index, level, qual, String:att[])
{
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon == INVALID_HANDLE)
		return -1;
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	new String:atts[32][32];
	new count = ExplodeString(att, " ; ", atts, 32, 32);
	if (count > 1)
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		new i2 = 0;
		for (new i = 0; i < count; i += 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(hWeapon, 0);

	new entity = TF2Items_GiveNamedItem(client, hWeapon);
	CloseHandle(hWeapon);
	EquipPlayerWeapon(client, entity);
	return entity;
}
stock FindVersionData(Handle:panel, versionindex)
{
	switch (versionindex)
	{
		case 66: //1.49
		{
			DrawPanelText(panel, "1) Updated again for the latest version of sourcemod (1.6.1 or higher)");
			DrawPanelText(panel, "2) Hopefully botkillers are fixed now?");
			DrawPanelText(panel, "3) Fixed wrong number of players displaying when control point is enabled.");
			DrawPanelText(panel, "4) Fixed festive GRU's stats and festive/bread jarate not removing rage.");
			DrawPanelText(panel, "5) Fixed issues with HHH teleporting to spawn.");
			DrawPanelText(panel, "6) Added configs/saxton_spawn_teleport.cfg");
			DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
		}
		case 65: //1.48
		{
			DrawPanelText(panel, "1) Can call medic to rage.");
			DrawPanelText(panel, "2) Harder to double tap taunt and fail rage.");
			DrawPanelText(panel, "3) Cannot spam super duper jump as much when falling into pits.");
			DrawPanelText(panel, "4) Hale only takes 5% of his max health as damage while in pits, at a max of 500.");
			DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
		}
		case 64: //1.48
		{
			DrawPanelText(panel, "5) Blocked boss from using voice commands unless he's CBS or Bunny");
			DrawPanelText(panel, "6) HHH always teleports to spawn after falling off the map.");
			DrawPanelText(panel, "7) HHH takes 50 seconds to get his first teleport instead of 25.");
			DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
		}
		case 63: //1.47
		{
			DrawPanelText(panel, "1) Updated for the latest version of sourcemod (1.6.1)");
			DrawPanelText(panel, "2) Fixed final player disconnect not giving the remaining players mini/crits.");
			DrawPanelText(panel, "3) Fixed cap not starting enabled when the round starts with low enough players to enable it.");
			DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
		}
		case 62: //1.47
		{
			DrawPanelText(panel, "5) !haleclass as Hale now shows boss info instead of class info.");
			DrawPanelText(panel, "6) Fixed Hale's anchor to work against sentries. Crouch walking negates all knockback.");
			DrawPanelText(panel, "7) Being cloaked next to a dispenser now drains your cloak to prevent camping.");
			DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
		}
		case 61: //1.46
		{
			DrawPanelText(panel, "1) Fixed botkillers (thanks rswallen).");
			DrawPanelText(panel, "2) Fixed Tide Turner & Razorback not being unequipped/removed properly.");
			DrawPanelText(panel, "3) Hale can no longer pick up health packs.");
			DrawPanelText(panel, "4) Fixed maps like military area where BLU can't pick up ammo packs in the first arena round.");
			DrawPanelText(panel, "5) Fixed unbalanced team joining in the first arena round.");
			DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
		}
		case 60: //1.46
		{
			DrawPanelText(panel, "6) Can now type !resetq to reset your queue points.");
			DrawPanelText(panel, "7) !infotoggle can disable the !haleclass info popups on round start.");
			DrawPanelText(panel, "8) Easter Bunny has 40pct knockback resist in light of the crit eggs.");
			DrawPanelText(panel, "9) Phlog damage reduced by half when not under the effects of CritMmmph.");
			DrawPanelText(panel, "10) Quiet decloak moved from Letranger to Your Eternal Reward / Wanga Prick.");
			DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
		}
		case 59: //1.46
		{
			DrawPanelText(panel, "11) YER no longer disguises you.");
			DrawPanelText(panel, "12) Changed /halenew pagination a little.");
			DrawPanelText(panel, "13) Nerfed demo shield crits to minicrits. He was overpowered compared to other classes.");
			DrawPanelText(panel, "14) Added Cvar 'hale_shield_crits' to re-enable shield crits for servers balanced around taunt crits/goomba.");
			DrawPanelText(panel, "15) Added cvar 'hale_hp_display' to toggle displaying Hale's Health at all times on the hud.");
			DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
		}
		case 58: //1.45
		{
			DrawPanelText(panel, "1) Fixed equippable wearables (thanks fiagram & Powerlord).");
			DrawPanelText(panel, "2) Fixed flickering HUD text.");
			DrawPanelText(panel, "3) Implemented anti-suicide as Hale measures.");
			DrawPanelText(panel, "4) Hale cannot suicide until around 30 seconds have passed.");
			DrawPanelText(panel, "5) Hale can no longer switch teams to suicide.");
			DrawPanelText(panel, "6) Repositioned 'player became x boss' message off of your crosshair.");
			DrawPanelText(panel, "--) This version courtesy of the TF2Data community."); // Blatant advertising
		}
		case 57: //1.45
		{
			DrawPanelText(panel, "7) Removed annoying no yes no no you're Hale next message.");
			DrawPanelText(panel, "8) Market Gardens do damage similar to backstabs.");
			DrawPanelText(panel, "9) Deadringer now displays its status.");
			DrawPanelText(panel, "10) Phlog is invulnerable during taunt activation.");
			DrawPanelText(panel, "11) Phlog Crit Mmmph duration has 75% damage resistance.");
			DrawPanelText(panel, "12) Phlog disables flaregun crits.");
			DrawPanelText(panel, "13) Fixed Bread Bite and Festive Eyelander.");
			DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
		}
		case 56: //1.45
		{
			DrawPanelText(panel, "14) Can now see uber meter with melee or syringe equipped.");
			DrawPanelText(panel, "15) Soda Popper & BFB replaced with scattergun.");
			DrawPanelText(panel, "16) Bonk replaced with crit-a-cola.");
			DrawPanelText(panel, "17) All 3 might be rebalanced in the future.");
			DrawPanelText(panel, "18) Reserve shooter crits in place of minicrits. Still 3 clip.");
			DrawPanelText(panel, "19) Re-enabled Darwin's Danger Shield. Overhealed sniper can tank a hit!");
			DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
		}
		case 55: //1.45
		{
			DrawPanelText(panel, "20) Batt's Backup has 75% knockback resist.");
			DrawPanelText(panel, "21) Air Strike relaxed to 200 dmg per clip.");
			DrawPanelText(panel, "22) Fixed backstab rarely doing 1/3 damage glitch.");
			DrawPanelText(panel, "23) Big Earner gives full cloak on backstab.");
			DrawPanelText(panel, "24) Fixed SteamTools not changing gamedesc.");
			DrawPanelText(panel, "25) Reverted 3/5ths backstab assist for medics and fixed no assist glitch.");
			DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
		}
		case 54: //1.45
		{
			DrawPanelText(panel, "26) HHH can wallclimb.");
			DrawPanelText(panel, "27) HHH's weighdown timer is reset on wallclimb.");
			DrawPanelText(panel, "28) HHH now alerts their teleport target that he teleported to them.");
			DrawPanelText(panel, "29) HHH can get stuck in soldiers and scouts, but not other classes on teleport.");
			DrawPanelText(panel, "30) Can now charge super jump while holding space.");
			DrawPanelText(panel, "31) Nerfed Easter Bunny's rage eggs by 40% damage.");
			DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
		}
		case 53: //1.44
		{
			DrawPanelText(panel, "1) Fixed first round glich (thanks nergal).");
			DrawPanelText(panel, "2) Kunai starts at 65 HP instead of 60. Max 270 HP.");
			DrawPanelText(panel, "3) Kunai gives 180 HP on backstab instead of 100.");
			DrawPanelText(panel, "4) Demo boots now reduce fall damage like soldier boots and do stomp damage.");
			DrawPanelText(panel, "5) Fixed bushwacka disabling crits.");
			DrawPanelText(panel, "6) Air Strike gains ammo based on every 500 damage dealt.");
			DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
		}
		case 52: //1.44
		{
			DrawPanelText(panel, "7) Sydney Sleeper generates half the usual rage for Hale.");
			DrawPanelText(panel, "8) Other sniper rifles just do 3x damage as usual.");
			DrawPanelText(panel, "9) Huntsman gets 2x ammo, fortified compound fixed.");
			DrawPanelText(panel, "10) Festive flare gun now acts like mega-detonator.");
			DrawPanelText(panel, "11) Medic crossbow now gives 15pct uber instead of 10.");
			DrawPanelText(panel, "12) Festive crossbow is fixed to be like normal crossbow.");
			DrawPanelText(panel, "13) Medics now get 3/5 the damage of a backstab for assisting.");
			DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
		}
		case 51: //1.43
		{
			DrawPanelText(panel, "1) Backstab formula rebalanced to do better damage to lower HP Hales.");
			DrawPanelText(panel, "2) Damage Dealt now work properly with backstabs.");
			DrawPanelText(panel, "3) Slightly reworked Hale health formula.");
			DrawPanelText(panel, "4) (Anchor) Bosses take no pushback from damage while ducking on the ground.");
			DrawPanelText(panel, "5) Short circuit blocked until further notice.");
			DrawPanelText(panel, "--) This version courtesy of the TF2Data community.");
		}
		case 50: //1.43
		{
			DrawPanelText(panel, "6) Bushwacka blocks healing while in use.");
			DrawPanelText(panel, "7) Cannot wallclimb if your HP is low enough that it'll kill you.");
			DrawPanelText(panel, "8) Bushwacka doesn't disable crits.");
			DrawPanelText(panel, "9) 2013 festives and bread now get crits.");
			DrawPanelText(panel, "10) Fixed telefrag and mantread stomp damage.");
			DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
		}
		case 49: //1.43
		{
			DrawPanelText(panel, "11) L'etranger's 40% cloak is replaced with quiet decloak and -25% cloak regen rate.");
			DrawPanelText(panel, "12) Ambassador does 2.5x damage on headshots.");
			DrawPanelText(panel, "13) Diamondback gets 3 crits on backstab.");
			DrawPanelText(panel, "14) Diamondback crit shots do bonus damage similar to the Ambassador.");
			DrawPanelText(panel, "15) Manmelter always crits, while revenge crits do bonus damage.");
			DrawPanelText(panel, "---) This version courtesy of the TF2Data community.");
		}
		case 48: //142
		{
			DrawPanelText(panel, "1) Festive fixes");
			DrawPanelText(panel, "2) Hopefully fixed targes disappearing");
#if defined EASTER_BUNNY_ON
			DrawPanelText(panel, "3) Easter and April Fool's Day so close together... hmmm...");
#endif
		}
		case 47: //141
		{
			DrawPanelText(panel, "1) Fixed bosses disguising");
			DrawPanelText(panel, "2) Updated action slot whitelist");
			DrawPanelText(panel, "3) Updated sniper rifle list, Fest. Huntsman");
			DrawPanelText(panel, "4) Medigun speed works like Quick-Fix");
			DrawPanelText(panel, "5) Medigun+gunslinger vm fix");
			DrawPanelText(panel, "6) CBS gets Fest. Huntsman");
			DrawPanelText(panel, "7) Spies take more dmg while cloaked (normal watch)");
			DrawPanelText(panel, "8) Experimental backstab block animation");
		}
		case 46: //140
		{
			DrawPanelText(panel, "1) Dead Ringers have no cloak defense buff. Normal cloaks do.");
			DrawPanelText(panel, "2) Fixed Sniper Rifle reskin behavior");
			DrawPanelText(panel, "3) Boss has small amount of stun resistance after rage");
			DrawPanelText(panel, "4) Fixed HHH/CBS models");
		}
		case 45: //139c
		{
			DrawPanelText(panel, "1) Backstab disguising smoother/less obvious");
			DrawPanelText(panel, "2) Rage 'dings' dispenser/tele, to help locate Hale");
			DrawPanelText(panel, "3) Improved skip panel");
			DrawPanelText(panel, "4) Removed crits from sniper rifles, now do 2.9x damage");
			DrawPanelText(panel, "-- Sleeper does 2.4x damage, 2.9x if Hale's rage is >90pct");
			DrawPanelText(panel, "-- Bushwacka nerfs still apply");
			DrawPanelText(panel, "-- Minicrit- less damage, more knockback");
			DrawPanelText(panel, "5) Scaled sniper rifle glow time a bit better");
			DrawPanelText(panel, "6) Fixed Dead Ringer spy death icon");
		}
		case 44: //139c
		{
			DrawPanelText(panel, "7) BabyFaceBlaster will fill boost normally, but will hit 100 and drain+minicrits");
			DrawPanelText(panel, "8) Can't Eureka+destroy dispenser to insta-tele");
			DrawPanelText(panel, "9) Phlogger invuln during the taunt");
			DrawPanelText(panel, "10) Added !hale_resetq");
			DrawPanelText(panel, "11) Heatmaker gains Focus on hit (varies by charge)");
			DrawPanelText(panel, "12) Bosses get short defense buff after rage");
			DrawPanelText(panel, "13) Cozy Camper comes with SMG - 1.5s bleed, no random crit, -15% dmg");
			DrawPanelText(panel, "14) Valve buffed Crossbow. Balancing.");
			DrawPanelText(panel, "15) New cvars-hale_force_team, hale_enable_eureka");
		}
		case 43: //139c
		{
			DrawPanelText(panel, "16) Powerlord's Better Backstab Detection");
			DrawPanelText(panel, "17) Backburner has charged airblast");
			DrawPanelText(panel, "18) Skip Hale notification mixes things up");
			DrawPanelText(panel, "19) Bosses may or may not obey Pyrovision voice rules. Or both.");
		}
		case 42: //139
		{
			DrawPanelText(panel, "1) !hale_resetqueuepoints");
			DrawPanelText(panel, "-- From chat, asks for confirmation");
			DrawPanelText(panel, "-- From console, no confirmation!");
			DrawPanelText(panel, "2) Help panel stops repeatedly popping up");
			DrawPanelText(panel, "3) Medic is credited 100% of damage done during uber");
			DrawPanelText(panel, "4) Bushwacka changes:");
			DrawPanelText(panel, "-- Hit a wall to climb it");
			DrawPanelText(panel, "-- Slower fire rate");
			DrawPanelText(panel, "-- Disables crits on rifles (not Huntsman)");
			DrawPanelText(panel, "-- Effect does not occur during HHH round");
			DrawPanelText(panel, "...contd.");
		}

		case 41: //139
		{
			DrawPanelText(panel, "5) Late December increases chances of CBS appearing");
			DrawPanelText(panel, "6) If map changes mid-round, queue points not lost");
			DrawPanelText(panel, "7) Fixed HHH tele (again).");
			DrawPanelText(panel, "8) HHH tele removes Sniper Rifle glow");
			DrawPanelText(panel, "9) Mantread stomp deals 5x damage to Hale");
			DrawPanelText(panel, "10) Rage stun range- Vagineer increased, CBS decreased");
			DrawPanelText(panel, "11) Balanced CBS arrows");
			DrawPanelText(panel, "12) Minicrits will not play loud sound to all players");
			DrawPanelText(panel, "13) Dead Ringer will not be able to activate for 2s after backstab");
			DrawPanelText(panel, "-- Other spy watches can");
			DrawPanelText(panel, "14) Fixed crit issues");
			DrawPanelText(panel, "15) Hale queue now accepts negative points");
			DrawPanelText(panel, "...contd.");
		}
		case 40: //139
		{
			DrawPanelText(panel, "16) For server owners:");
			DrawPanelText(panel, "-- Translations updated");
			DrawPanelText(panel, "-- Added hale_spec_force_boss cvar");
			DrawPanelText(panel, "-- Now attempts to integrate tf2items config");
			DrawPanelText(panel, "-- With SteamTools, changes game desc");
			DrawPanelText(panel, "-- Plugin may warn if config is outdated");
			DrawPanelText(panel, "-- Jump/tele charge defines at top of code");
			DrawPanelText(panel, "17) For mapmakers:");
			DrawPanelText(panel, "-- Indicate that your map has music:");
			DrawPanelText(panel, "-- Add info_target with name 'hale_no_music'");
			DrawPanelText(panel, "18) Third Degree hit adds uber to healers");
			DrawPanelText(panel, "19) Knockback resistance on Hale/HHH");
		}
		case 39: //138
		{
			DrawPanelText(panel, "1) Bots will use rage.");
			DrawPanelText(panel, "2) Doors only forced open on specified maps");
			DrawPanelText(panel, "3) CBS spawns more during Winter holidays");
			DrawPanelText(panel, "4) Deathspam for teamswitch gone");
			DrawPanelText(panel, "5) More notice for next Hale");
			DrawPanelText(panel, "6) Wrap Assassin has 2 ammo");
			DrawPanelText(panel, "7) Holiday Punch slightly disorients Hale");
			DrawPanelText(panel, "-- If stunned Heavy punches Hale, removes stun");
			DrawPanelText(panel, "8) Mantreads increase rocketjump distance");
		}
		case 38: //138
		{
			DrawPanelText(panel, "9) Fixed CBS Huntsman rate of fire");
			DrawPanelText(panel, "10) Fixed permanent invuln Vagineer glitch");
			DrawPanelText(panel, "11) Jarate removes some Vagineer uber time and 1 CBS arrow");
			DrawPanelText(panel, "12) Low-end Medic assist damage now counted");
			DrawPanelText(panel, "13) Hitting Dead Ringers does more damage (as balancing)");
			DrawPanelText(panel, "14) Eureka Effect temporarily removed)");
			DrawPanelText(panel, "15) HHH won't get stuck in ceilings when teleporting");
			DrawPanelText(panel, "16) Further updates pending");
		}
		case 37:    //137
		{
			DrawPanelText(panel, "1) Fixed taunt/rage.");
			DrawPanelText(panel, "2) Fixed rage+high five.");
			DrawPanelText(panel, "3) hale_circuit_stun - Circuit Stun time (0 to disable)");
			DrawPanelText(panel, "4) Fixed coaching bug");
			DrawPanelText(panel, "5) Config file for map doors");
			DrawPanelText(panel, "6) Fixed floor-Hale");
			DrawPanelText(panel, "7) Fixed Circuit stun");
			DrawPanelText(panel, "8) Fixed negative health bug");
			DrawPanelText(panel, "9) hale_enabled isn't a dummy cvar anymore");
			DrawPanelText(panel, "10) hale_special cmd fixes");
		}
		case 36: //137
		{
			DrawPanelText(panel, "11) 1st-round cap enables after 1 min.");
			DrawPanelText(panel, "12) More invalid Hale checks.");
			DrawPanelText(panel, "13) Backstabs act like Razorbackstab (2s)");
			DrawPanelText(panel, "14) Fixed map check error");
			DrawPanelText(panel, "15) Wanga Prick -> Eternal Reward effect");
			DrawPanelText(panel, "16) Jarate removes 8% of Hale's rage meter");
			DrawPanelText(panel, "17) The Fan O' War removes 5% of the rage meter on hit");
			DrawPanelText(panel, "18) Removed Shortstop reload penalty");
			DrawPanelText(panel, "19) VSH_OnMusic forward");
		}
		case 35: //1369
		{
			DrawPanelText(panel, "1) Fixed spawn door blocking.");
			DrawPanelText(panel, "2) Cleaned up HUD text (health, etc).");
			DrawPanelText(panel, "3) VSH_OnDoJump now has a bool for superduper.");
			DrawPanelText(panel, "4) !halenoclass changed to !haleclassinfotoggle.");
			DrawPanelText(panel, "5) Fixed invalid clients becoming Hale");
			DrawPanelText(panel, "6) Removed teamscramble from first round.");
			DrawPanelText(panel, "7) Vagineer noises:");
			DrawPanelText(panel, "-- Nope for no");
			DrawPanelText(panel, "-- Gottam/mottag (same as jump but quieter) for Move Up");
			DrawPanelText(panel, "-- Hurr for everything else");
		}
		case 34: //1369
		{
			DrawPanelText(panel, "8) All map dispensers will be on the non-Hale team (fixes health bug)");
			DrawPanelText(panel, "9) Fixed command flags on overlay command");
			DrawPanelText(panel, "10) Fixed soldier shotgun not dealing midair minicrits.");
			DrawPanelText(panel, "11) Fixed invalid weapons on clients");
			DrawPanelText(panel, "12) Damage indicator (+spec damage indicator)");
			DrawPanelText(panel, "13) Hale speed remains during humiliation time");
			DrawPanelText(panel, "14) SuperDuperTele for HHH stuns for 4s instead of regular 2");
		}
		case 33: //1369
		{
			DrawPanelText(panel, "15) Battalion's Backup adds +10 max hp, but still only overheal to 300");
			DrawPanelText(panel, "-- Full rage meter when hit by Hale. Buff causes drastic defense boost.");
			DrawPanelText(panel, "16) Fixed a telefrag glitch");
			DrawPanelText(panel, "17) Powerjack is now +25hp on hit, heal up to +50 overheal");
			DrawPanelText(panel, "18) Backstab now shows the regular hit indicator (like other weapons do)");
			DrawPanelText(panel, "19) Kunai adds 100hp on backstab, up to 270");
			DrawPanelText(panel, "20) FaN/Scout crit knockback not nerfed to oblivion anymore");
			DrawPanelText(panel, "21) Removed Short Circuit stun (better effect being made)");
		}
		case 32: //1368
		{
			DrawPanelText(panel, "1) Now FaN and Scout crit knockback is REALLY lessened.");
			DrawPanelText(panel, "2) Medic says 'I'm charged' when he gets fully uber-charge with syringegun.");
			DrawPanelText(panel, "3) Team will scramble in 1st round, if 1st round is default arena.");
			DrawPanelText(panel, "4) Now client can disable info about changes of classes, displayed when round started.");
			DrawPanelText(panel, "5) Powerjack adds 50HPs per hit.");
			DrawPanelText(panel, "6) Short Circuit stuns Hale for 2.0 seconds.");
			DrawPanelText(panel, "7) Vagineer says \"hurr\"");
			//DrawPanelText(panel, "8) Added support of VSH achievements.");
		}
		case 31: //1367
		{
			DrawPanelText(panel, "1) Map-specific fixes:");
			DrawPanelText(panel, "-- Oilrig's pit no longer allows HHH to instatele");
			DrawPanelText(panel, "-- Arakawa's pit damage drastically lessened");
			DrawPanelText(panel, "2) General map fixes: disable spawn-blocking walls");
			DrawPanelText(panel, "3) Cap point now properly un/locks instead of fake-unlocking.");
			DrawPanelText(panel, "4) Tried fixing double-music playing.");
			DrawPanelText(panel, "5) Fixed Eternal Reward disguise glitch - edge case.");
			DrawPanelText(panel, "6) Help menus no longer glitch votes.");
		}
		case 30: //1366
		{
			DrawPanelText(panel, "1) Fixed superjump velocity code.");
			DrawPanelText(panel, "2) Fixed replaced Rocket Jumpers not minicritting Hale in midair.");
		}
		case 29: //1365
		{
			DrawPanelText(panel, "1) Half-Zatoichi is now allowed. Heal 35 health on hit, but must hit Hale to remove Honorbound.");
			DrawPanelText(panel, "-- Can add up to 25 overheal");
			DrawPanelText(panel, "-- Starts the round bloodied.");
			DrawPanelText(panel, "2) Fixed Hale not building rage when only Scouts remain.");
			DrawPanelText(panel, "3) Tried fixing Hale disconnect/nextround glitches (including music).");
			DrawPanelText(panel, "4) Candycane spawns healthpack on hit.");
		}
		case 28:    //1364
		{
			DrawPanelText(panel, "1) Added convar hale_first_round (default 0). If it's 0, first round will be default arena.");
			DrawPanelText(panel, "2) Added more translations.");
		}
		case 27:    //1363
		{
			DrawPanelText(panel, "1) Fixed a queue point exploit (VoiDeD is mean)");
			DrawPanelText(panel, "2) HHH has backstab/death sound now");
			DrawPanelText(panel, "3) First rounds are normal arena");
			DrawPanelText(panel, "-- Some weapon replacements still apply!");
			DrawPanelText(panel, "-- Teambalance is still off, too.");
			DrawPanelText(panel, "4) Fixed arena_ maps not switching teams occasionally");
			DrawPanelText(panel, "-- After 3 rounds with a team, has a chance to switch");
			DrawPanelText(panel, "-- Will add a cvar to keep Hale always blue/force team, soon");
			DrawPanelText(panel, "5) Fixed pit damage");
		}
		case 26:    //1361 and 2
		{
			DrawPanelText(panel, "1) CBS music");
			DrawPanelText(panel, "2) Soldiers minicrit Hale while he's in midair.");
			DrawPanelText(panel, "3) Direct Hit crits instead of minicrits");
			DrawPanelText(panel, "4) Reserve Shooter switches faster, +10% dmg");
			DrawPanelText(panel, "5) Added hale_stop_music cmd - admins stop music for all");
			DrawPanelText(panel, "6) FaN and Scout crit knockback is lessened");
			DrawPanelText(panel, "7) Your halemusic/halevoice settings are saved");
			DrawPanelText(panel, "1.362) Sounds aren't stupid .mdl files anymore");
			DrawPanelText(panel, "1.362) Fixed translations");
		}
		case 25:    //136
		{
			DrawPanelText(panel, "MEGA UPDATE by FlaminSarge! Check next few pages");
			DrawPanelText(panel, "SUGGEST MANNO-TECH WEAPON CHANGES");
			DrawPanelText(panel, "1) Updated CBS model");
			DrawPanelText(panel, "2) Fixed last man alive sound");
			DrawPanelText(panel, "3) Removed broken hale line, fixed one");
			DrawPanelText(panel, "4) New HHH rage sound");
			DrawPanelText(panel, "5) HHH music (/halemusic)");
			DrawPanelText(panel, "6) CBS jump noise");
			DrawPanelText(panel, "7) /halevoice and /halemusic to turn off voice/music");
			DrawPanelText(panel, "8) Updated natives/forwards (can change rage dist in fwd)");
		}
		case 24:    //136
		{
			DrawPanelText(panel, "9) hale_crits cvar to turn off hale random crits");
			DrawPanelText(panel, "10) Fixed sentries not repairing when raged");
			DrawPanelText(panel, "-- Set hale_ragesentrydamagemode 0 to force engineer to pick up sentry to repair");
			DrawPanelText(panel, "11) Now uses sourcemod autoconfig (tf/cfg/sourcemod/)");
			DrawPanelText(panel, "12) No longer requires saxton_hale_points.cfg file");
			DrawPanelText(panel, "-- Now using clientprefs for queue points");
			DrawPanelText(panel, "13) When on non-VSH map, team switch does not occur so often.");
			DrawPanelText(panel, "14) Should have full replay compatibility");
			DrawPanelText(panel, "15) Bots work with queue, are Hale less often");
		}
		case 23:    //136
		{
			DrawPanelText(panel, "16) Hale's health increased by 1 (in code)");
			DrawPanelText(panel, "17) Many many many many many fixes");
			DrawPanelText(panel, "18) Crossbow +150% damage +10 uber on hit");
			DrawPanelText(panel, "19) Syringegun has overdose speed boost");
			DrawPanelText(panel, "20) Sniper glow time scales with charge (2 to 8 seconds)");
			DrawPanelText(panel, "21) Eyelander/reskins add heads on hit");
			DrawPanelText(panel, "22) Axetinguisher/reskins use fire axe attributes");
			DrawPanelText(panel, "23) GRU/KGB is +50% speed but -7hp/s");
			DrawPanelText(panel, "24) Airblasting boss adds rage (no airblast reload though)");
			DrawPanelText(panel, "25) Airblasting uber vagineer adds time to uber and takes extra ammo");
		}
		case 22:    //136
		{
			DrawPanelText(panel, "26) Frontier Justice allowed, crits only when sentry sees Hale");
			DrawPanelText(panel, "27) Boss weighdown (look down + crouch) after 5 seconds in midair");
			DrawPanelText(panel, "28) FaN is back");
			DrawPanelText(panel, "29) Scout crits/minicrits do less knockback if not melee");
			DrawPanelText(panel, "30) Saxton has his own fists");
			DrawPanelText(panel, "31) Unlimited /halehp but after 3, longer cooldown");
			DrawPanelText(panel, "32) Fist kill icons");
			DrawPanelText(panel, "33) Fixed CBS arrow count (start at 9, but if less than 9 players, uses only that number of players)");
			DrawPanelText(panel, "34) Spy primary minicrits");
			DrawPanelText(panel, "35) Dead ringer fixed");
		}
		case 21:    //136
		{
			DrawPanelText(panel, "36) Flare gun replaced with detonator. Has large jump but more self-damage (like old detonator beta)");
			DrawPanelText(panel, "37) Eternal Reward backstab disguises as random faster classes");
			DrawPanelText(panel, "38) Kunai adds 60 health on backstab");
			DrawPanelText(panel, "39) Randomizer compatibility.");
			DrawPanelText(panel, "40) Medic uber works as normal with crits added (multiple targets, etc)");
			DrawPanelText(panel, "41) Crits stay when being healed, but adds minicrits too (for sentry, etc)");
			DrawPanelText(panel, "42) Fixed Sniper back weapon replacement");
		}
		case 20:    //136
		{
			DrawPanelText(panel, "43) Vagineer NOPE and Well Don't That Beat All!");
			DrawPanelText(panel, "44) Telefrags do 9001 damage");
			DrawPanelText(panel, "45) Speed boost when healing scouts (like Quick-Fix)");
			DrawPanelText(panel, "46) Rage builds (VERY slowly) if there are only Scouts left");
			DrawPanelText(panel, "47) Healing assist damage split between healers");
			DrawPanelText(panel, "48) Fixed backstab assist damage");
			DrawPanelText(panel, "49) Fixed HHH attacking during tele");
			DrawPanelText(panel, "50) Soldier boots - 1/10th fall damage");
			DrawPanelText(panel, "AND MORE! (I forget all of them)");
		}
		case 19:    //135_3
		{
			DrawPanelText(panel, "1)Added point system (/halenext).");
			DrawPanelText(panel, "2)Added [VSH] to VSH messages.");
			DrawPanelText(panel, "3)Removed native VSH_GetSaxtonHaleHealth() added native VSH_GetRoundState().");
			DrawPanelText(panel, "4)There is mini-crits for scout's pistols. Not full crits, like before.");
			DrawPanelText(panel, "5)Fixed issues associated with crits.");
			DrawPanelText(panel, "6)Added FORCE_GENERATION flag to stop errorlogs.");
			DrawPanelText(panel, "135_2 and 135_3)Bugfixes and updated translations.");
		}
		case 18:    //135
		{
			DrawPanelText(panel, "1)Special crits will not removed by Medic.");
			DrawPanelText(panel, "2)Sniper's glow is working again.");
			DrawPanelText(panel, "3)Less errors in console.");
			DrawPanelText(panel, "4)Less messages in chat.");
			DrawPanelText(panel, "5)Added more natives.");
			DrawPanelText(panel, "6)\"Over 9000\" sound returns! Thx you, FlaminSarge.");
			DrawPanelText(panel, "7)Hopefully no more errors in logs.");
		}
		case 17:    //134
		{
			DrawPanelText(panel, "1)Biohazard skin for CBS");
			DrawPanelText(panel, "2)TF2_IsPlayerInCondition() fixed");
			DrawPanelText(panel, "3)Now sniper rifle must be 100perc.charged to glow Hale.");
			DrawPanelText(panel, "4)Fixed Vagineer's model.");
			DrawPanelText(panel, "5)Added Natives.");
			DrawPanelText(panel, "6)Hunstman deals more damage.");
			DrawPanelText(panel, "7)Added reload time (5sec) for Pyro's airblast. ");
			DrawPanelText(panel, "1.34_1 1)Fixed airblast reload when VSH is disabled.");
			DrawPanelText(panel, "1.34_1 2)Fixed airblast reload after detonator's alt-fire.");
			DrawPanelText(panel, "1.34_1 3)Airblast reload time reduced to 3 seconds.");
			DrawPanelText(panel, "1.34_1 4)hale_special 3 is disabled.");
		}
		case 16:    //133
		{
			DrawPanelText(panel, "1)Fixed bugs, associated with Uber-update.");
			DrawPanelText(panel, "2)FaN replaced with Soda Popper.");
			DrawPanelText(panel, "3)Bazaar Bargain replaced with Sniper Rifle.");
			DrawPanelText(panel, "4)Sniper Rifle adding glow to Hale - anyone can see him for 5 seconds.");
			DrawPanelText(panel, "5)Crusader's Crossbow deals more damage.");
			DrawPanelText(panel, "6)Code optimizing.");
		}
		case 15:    //132
		{
			DrawPanelText(panel, "1)Added new Saxton's lines on...");
			DrawPanelText(panel, "  a)round start");
			DrawPanelText(panel, "  b)jump");
			DrawPanelText(panel, "  c)backstab");
			DrawPanelText(panel, "  d)destroy Sentry");
			DrawPanelText(panel, "  e)kill Scout, Pyro, Heavy, Engineer, Spy");
			DrawPanelText(panel, "  f)last man standing");
			DrawPanelText(panel, "  g)killing spree");
			DrawPanelText(panel, "2)Fixed bugged count of CBS' arrows.");
			DrawPanelText(panel, "3)Reduced Hale's damage versus DR by 20 HPs.");
			DrawPanelText(panel, "4)Now two specials can not be at a stretch.");
			DrawPanelText(panel, "v1.32_1 1)Fixed bug with replay.");
			DrawPanelText(panel, "v1.32_1 2)Fixed bug with help menu.");
		}
		case 14:    //131
			DrawPanelText(panel, "1)Now \"replay\" will not change team.");
		case 13:    //130
			DrawPanelText(panel, "1)Fixed bugs, associated with crushes, error logs, scores.");
		case 12:    //129
		{
			DrawPanelText(panel, "1)Fixed random crushes associated with CBS.");
			DrawPanelText(panel, "2)Now Hale's HP formula is ((760+x-1)*(x-1))^1.04");
			DrawPanelText(panel, "3)Added hale_special0. Use it to change next boss to Hale.");
			DrawPanelText(panel, "4)CBS has 9 arrows for bow-rage. Also he has stun rage, but on little distantion.");
			DrawPanelText(panel, "5)Teammates gets 2 scores per each 600 damage");
			DrawPanelText(panel, "6)Demoman with Targe has crits on his primary weapon.");
			DrawPanelText(panel, "7)Removed support of non-Arena maps, because nobody wasn't use it.");
			DrawPanelText(panel, "8)Pistol/Lugermorph has crits.");
		}
		case 11:    //128
		{
			DrawPanelText(panel, "VS Saxton Hale Mode is back!");
			DrawPanelText(panel, "1)Christian Brutal Sniper is a regular character.");
			DrawPanelText(panel, "2)CBS has 3 melee weapons ad bow-rage.");
			DrawPanelText(panel, "3)Added new lines for Vagineer.");
			DrawPanelText(panel, "4)Updated models of Vagineer and HHH jr.");
		}
		case 10:    //999
			DrawPanelText(panel, "Attachables are broken. Many \"thx\" to Valve.");
		case 9: //126
		{
			DrawPanelText(panel, "1)Added the second URL for auto-update.");
			DrawPanelText(panel, "2)Fixed problems, when auto-update was corrupt plugin.");
			DrawPanelText(panel, "3)Added a question for the next Hale, if he want to be him. (/haleme)");
			DrawPanelText(panel, "4)Eyelander and Half-Zatoichi was replaced with Claidheamh Mor.");
			DrawPanelText(panel, "5)Fan O'War replaced with Bat.");
			DrawPanelText(panel, "6)Dispenser and TP won't be destoyed after Engineer's death.");
			DrawPanelText(panel, "7)Mode uses the localization file.");
			DrawPanelText(panel, "8)Saxton Hale will be choosed randomly for the first 3 rounds (then by queue).");
		}
		case 8: //125
		{
			DrawPanelText(panel, "1)Fixed silent HHHjr's rage.");
			DrawPanelText(panel, "2)Now bots (sourcetv too) do not will be Hale");
			DrawPanelText(panel, "3)Fixed invalid uber on Vagineer's head.");
			DrawPanelText(panel, "4)Fixed other little bugs.");
		}
		case 7: //124
		{
			DrawPanelText(panel, "1)Fixed destroyed buildables associated with spy's fake death.");
			DrawPanelText(panel, "2)Syringe Gun replaced with Blutsauger.");
			DrawPanelText(panel, "3)Blutsauger, on hit: +5 to uber-charge.");
			DrawPanelText(panel, "4)Removed crits from Blutsauger.");
			DrawPanelText(panel, "5)CnD replaced with Invis Watch.");
			DrawPanelText(panel, "6)Fr.Justice replaced with shotgun");
			DrawPanelText(panel, "7)Fists of steel replaced with fists.");
			DrawPanelText(panel, "8)KGB replaced with GRU.");
			DrawPanelText(panel, "9)Added /haleclass.");
			DrawPanelText(panel, "10)Medic gets assist damage scores (1/2 from healing target's damage scores, 1/1 when uber-charged)");
		}
		case 6: //123
		{
			DrawPanelText(panel, "1)Added Super Duper Jump to rescue Hale from pit");
			DrawPanelText(panel, "2)Removed pyro's ammolimit");
			DrawPanelText(panel, "3)Fixed little bugs.");
		}
		case 5: //122
		{
			DrawPanelText(panel, "1.21)Point will be enabled when X or less players be alive.");
			DrawPanelText(panel, "1.22)Now it's working :) Also little optimize about player count.");
		}
		case 4: //120
		{
			DrawPanelText(panel, "1)Added new Hale's phrases.");
			DrawPanelText(panel, "2)More bugfixes.");
			DrawPanelText(panel, "3)Improved super-jump.");
		}
		case 3: //112
		{
			DrawPanelText(panel, "1)More bugfixes.");
			DrawPanelText(panel, "2)Now \"(Hale)<mapname>\" can be nominated for nextmap.");
			DrawPanelText(panel, "3)Medigun's uber gets uber and crits for Medic and his target.");
			DrawPanelText(panel, "4)Fixed infinite Specials.");
			DrawPanelText(panel, "5)And more bugfixes.");
		}
		case 2: //111
		{
			DrawPanelText(panel, "1)Fixed immortal spy");
			DrawPanelText(panel, "2)Fixed crashes associated with classlimits.");
		}
		case 1: //110
		{
			DrawPanelText(panel, "1)Not important changes on code.");
			DrawPanelText(panel, "2)Added hale_enabled convar.");
			DrawPanelText(panel, "3)Fixed bug, when all hats was removed...why?");
		}
		case 0: //100
		{
			DrawPanelText(panel, "Released!!!");
			DrawPanelText(panel, "On new version you will get info about changes.");
		}
		default:
		{
			DrawPanelText(panel, "-- Somehow you've managed to find a glitched version page!");
			DrawPanelText(panel, "-- Congratulations. Now go fight Hale.");
		}
	}
}
stock SetAmmo(client, wepslot, newAmmo)
{
	new weapon = GetPlayerWeaponSlot(client, wepslot);
	if (!IsValidEntity(weapon)) return;
	new type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (type < 0 || type > 31) return;
	SetEntProp(client, Prop_Send, "m_iAmmo", newAmmo, _, type);
}

stock GetAmmo(client, wepslot)
{
	if (!IsValidClient(client)) return 0;
	new weapon = GetPlayerWeaponSlot(client, wepslot);
	if (!IsValidEntity(weapon)) return 0;
	new type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (type < 0 || type > 31) return 0;
	return GetEntProp(client, Prop_Send, "m_iAmmo", _, type);
}

stock TF2_GetMetal(client)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return 0;
	return GetEntProp(client, Prop_Send, "m_iAmmo", _, 3);
}

stock TF2_SetMetal(client, metal)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return;
	SetEntProp(client, Prop_Send, "m_iAmmo", metal, _, 3);
}

stock GetHealingTarget(client)
{
	new String:s[64];
	new medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (medigun <= MaxClients || !IsValidEdict(medigun))
		return -1;
	GetEdictClassname(medigun, s, sizeof(s));
	if (strcmp(s, "tf_weapon_medigun", false) == 0)
	{
		if (GetEntProp(medigun, Prop_Send, "m_bHealing"))
			return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
	}
	return -1;
}

stock bool:IsValidClient(client, bool:replaycheck = true)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	if (replaycheck)
	{
		if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	}
	return true;
}

stock CreateVM(client, String:model[])
{
	new ent = CreateEntityByName("tf_wearable_vm");
	if (!IsValidEntity(ent)) return -1;
	SetEntProp(ent, Prop_Send, "m_nModelIndex", PrecacheModel(model));
	SetEntProp(ent, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL);
	SetEntProp(ent, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntProp(ent, Prop_Send, "m_usSolidFlags", 4);
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", 11);
	DispatchSpawn(ent);
	SetVariantString("!activator");
	ActivateEntity(ent);
	TF2_EquipWearable(client, ent);
	return ent;
}
//Moved to tf2_stocks.inc
/*stock TF2_EquipWearable(client, entity)
{
	SDKCall(hEquipWearable, client, entity);
}*/
stock AttachProjectileModel(entity, String:strModel[], String:strAnim[] = "")
{
	if (!IsValidEntity(entity)) return -1;
	new model = CreateEntityByName("prop_dynamic");
	if (IsValidEdict(model))
	{
		decl Float:pos[3];
		decl Float:ang[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Send, "m_angRotation", ang);
		TeleportEntity(model, pos, ang, NULL_VECTOR);
		DispatchKeyValue(model, "model", strModel);
		DispatchSpawn(model);
		SetVariantString("!activator");
		AcceptEntityInput(model, "SetParent", entity, model, 0);
		if (strAnim[0] != '\0')
		{
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetDefaultAnimation");
			SetVariantString(strAnim);
			AcceptEntityInput(model, "SetAnimation");
		}
		SetEntPropEnt(model, Prop_Send, "m_hOwnerEntity", entity);
		return model;
	} else {
		LogError("(AttachProjectileModel): Could not create prop_dynamic");
	}
	return -1;
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

/* Removes all weapons from a client's weapon slot
*
* @param client        Player's index.
* @param slot          Slot index (0-5)
* @noreturn
* @error               Invalid client, invalid slot or lack of mod support
*/
stock TF2_RemoveWeaponSlot2(client, slot)
{
   decl ew;
   new weaponIndex;
   while ((weaponIndex = GetPlayerWeaponSlot(client, slot)) != -1)
   {
	   ew = GetEntPropEnt(weaponIndex, Prop_Send, "m_hExtraWearable");
	   if(IsValidEntity(ew))
	   {
		   TF2_RemoveWearable(client, ew);
	   }
	   ew = GetEntPropEnt(weaponIndex, Prop_Send, "m_hExtraWearableViewModel");
	   if(IsValidEntity(ew))
	   {
		   TF2_RemoveWearable(client, ew);
	   }
	   RemovePlayerItem(client, weaponIndex);
	   AcceptEntityInput(weaponIndex, "Kill");
   }
}

/**
 * Removes all weapons from a client
 *
 * @param client        Player's index.
 * @noreturn
 */
stock TF2_RemoveAllWeapons2(client)
{
	for (new i = 0; i <= 5; i++)
	{
		TF2_RemoveWeaponSlot2(client, i);
	}
}

stock SetHaleHealthFix(client, oldhealth, maxhealth)
{
	//new originalhealth = oldhealth;
//  if (originalhealth < 4096)
//  {
//      SetEntProp(client, Prop_Send, "m_iHealth", originalhealth);
//      return;
//  }
//  oldhealth = oldhealth % 4096;
//  if (oldhealth < 5) originalhealth += 10;

//  SetEntProp(Hale, Prop_Data, "m_iHealth", HaleHealth);

	//SetEntProp(client, Prop_Send, "m_iHealth", originalhealth);

	SetEntProp(client, Prop_Data, "m_iHealth", oldhealth);
	SetEntProp(client, Prop_Data, "m_iMaxHealth", maxhealth);
}

stock CheckArena()
{
	if (PointType)
	{
		SetArenaCapEnableTime(float(45 + PointDelay * (playing - 1)));
	}
	else
	{
		SetArenaCapEnableTime(0.0);
		SetControlPoint(false);
	}
}
